#include "SttPipe.h"

#include <chrono>
#include <cstring>

static const wchar_t *const PIPE_NAME = L"\\\\.\\pipe\\uksf_stt";

CSttPipe *CSttPipe::getInstance() {
    static CSttPipe instance;
    return &instance;
}

CSttPipe::~CSttPipe() {
    stop();
}

void CSttPipe::start() {
    bool expected = false;
    if (!m_running.compare_exchange_strong(expected, true)) {
        return; // already running
    }
    m_thread = std::thread(&CSttPipe::writerLoop, this);
}

void CSttPipe::stop() {
    if (!m_running.exchange(false)) {
        return; // not running
    }
    m_cv.notify_all();
    // Unblock a writer parked in a blocking WriteFile so join() can complete.
    HANDLE pipe = m_pipe;
    if (pipe != INVALID_HANDLE_VALUE) {
        CancelIoEx(pipe, nullptr);
    }
    if (m_thread.joinable()) {
        m_thread.join();
    }
    closePipe();
}

void CSttPipe::beginUtterance(uint32_t sampleRate, uint32_t channels) {
    const uint32_t uttId = ++m_uttId;
    m_currentUttId.store(uttId, std::memory_order_relaxed);
    Frame frame;
    frame.type = FRAME_START;
    frame.payload.resize(12);
    std::memcpy(&frame.payload[0], &sampleRate, 4);
    std::memcpy(&frame.payload[4], &channels, 4);
    std::memcpy(&frame.payload[8], &uttId, 4);
    enqueue(std::move(frame));
}

void CSttPipe::pushPcm(const short *samples, int count) {
    if (count <= 0) {
        return;
    }
    Frame frame;
    frame.type = FRAME_DATA;
    frame.payload.resize(static_cast<size_t>(count) * sizeof(short));
    std::memcpy(frame.payload.data(), samples, frame.payload.size());
    enqueue(std::move(frame));
}

void CSttPipe::endUtterance() {
    const uint32_t uttId = m_currentUttId.load(std::memory_order_relaxed);
    Frame frame;
    frame.type = FRAME_END;
    frame.payload.resize(4);
    std::memcpy(&frame.payload[0], &uttId, 4);
    enqueue(std::move(frame));
}

void CSttPipe::enqueue(Frame &&frame) {
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (frame.type == FRAME_START) {
            m_dropping = false;
        }
        if (m_dropping) {
            return; // utterance abandoned after overflow; wait for the next START
        }
        m_queuedBytes += frame.payload.size();
        m_queue.push_back(std::move(frame));
        // STT absent/slow: drop the whole utterance rather than leave a buffer
        // with START/END but missing DATA in between.
        if (m_queuedBytes > MAX_QUEUED_BYTES) {
            m_queue.clear();
            m_queuedBytes = 0;
            m_dropping = true;
            return;
        }
    }
    m_cv.notify_one();
}

void CSttPipe::preconnect() {
    // Wake the writer for a connect-only cycle; the actual CreateFile happens on the
    // writer thread, never on the game thread that asked.
    m_preconnect.store(true, std::memory_order_relaxed);
    m_cv.notify_one();
}

void CSttPipe::writerLoop() {
    bool needStart = false; // after a drop, resync on the next START
    while (m_running.load()) {
        Frame frame;
        {
            std::unique_lock<std::mutex> lock(m_mutex);
            // While a preconnect is wanted, wake periodically: the STT server may not be
            // listening yet when the gate opens, and a single failed attempt would leave
            // the connection to be made inside the first utterance, which is then dropped.
            const auto ready = [this] { return !m_running.load() || !m_queue.empty() || m_preconnect.load(); };
            if (m_preconnect.load()) {
                m_cv.wait_for(lock, std::chrono::milliseconds(PRECONNECT_RETRY_MS), ready);
            } else {
                m_cv.wait(lock, ready);
            }
            if (!m_running.load()) {
                break;
            }
            if (m_preconnect.load() && ensureConnected()) {
                m_preconnect.store(false, std::memory_order_relaxed); // connected; stop retrying
            }
            if (m_queue.empty()) {
                continue;
            }
            frame = std::move(m_queue.front());
            m_queue.pop_front();
            m_queuedBytes -= frame.payload.size();
        }

        if (!ensureConnected()) {
            needStart = true;
            continue; // STT not up; drop this frame (queue is already bounded)
        }
        if (needStart) {
            if (frame.type != FRAME_START) {
                continue; // skip mid-utterance frames until a clean START
            }
            needStart = false;
        }

        const uint32_t header[2] = {frame.type, static_cast<uint32_t>(frame.payload.size())};
        if (!writeAll(reinterpret_cast<const uint8_t *>(header), sizeof(header)) ||
            (!frame.payload.empty() && !writeAll(frame.payload.data(), frame.payload.size()))) {
            closePipe();
            needStart = true; // resync after the reconnect
        }
    }
}

bool CSttPipe::ensureConnected() {
    if (m_pipe != INVALID_HANDLE_VALUE) {
        return true;
    }
    const ULONGLONG now = GetTickCount64();
    if (now - m_lastConnectAttempt < CONNECT_THROTTLE_MS) {
        return false; // throttle reconnect attempts
    }
    m_lastConnectAttempt = now;
    HANDLE handle = CreateFileW(PIPE_NAME, GENERIC_WRITE, 0, nullptr, OPEN_EXISTING, 0, nullptr);
    if (handle == INVALID_HANDLE_VALUE) {
        return false;
    }
    m_pipe = handle;
    return true;
}

bool CSttPipe::writeAll(const uint8_t *data, size_t len) {
    size_t offset = 0;
    while (offset < len) {
        DWORD wrote = 0;
        if (!WriteFile(m_pipe, data + offset, static_cast<DWORD>(len - offset), &wrote, nullptr) || wrote == 0) {
            return false;
        }
        offset += wrote;
    }
    return true;
}

void CSttPipe::closePipe() {
    if (m_pipe != INVALID_HANDLE_VALUE) {
        CloseHandle(m_pipe);
        m_pipe = INVALID_HANDLE_VALUE;
    }
}
