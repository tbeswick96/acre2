#include "SttPipe.h"

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
    if (m_thread.joinable()) {
        m_thread.join();
    }
    closePipe();
}

void CSttPipe::beginUtterance(uint32_t sampleRate, uint32_t channels) {
    Frame frame;
    frame.type = FRAME_START;
    frame.payload.resize(12);
    const uint32_t uttId = ++m_uttId;
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
    Frame frame;
    frame.type = FRAME_END;
    frame.payload.resize(4);
    std::memcpy(&frame.payload[0], &m_uttId, 4);
    enqueue(std::move(frame));
}

void CSttPipe::enqueue(Frame &&frame) {
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_queuedBytes += frame.payload.size();
        m_queue.push_back(std::move(frame));
        // Bound memory if STT is absent/slow: drop the OLDEST DATA frames,
        // preserving START/END boundary markers so the stream stays parseable.
        while (m_queuedBytes > MAX_QUEUED_BYTES && !m_queue.empty()) {
            auto it = m_queue.begin();
            for (; it != m_queue.end(); ++it) {
                if (it->type == FRAME_DATA) {
                    break;
                }
            }
            if (it == m_queue.end()) {
                break; // only control frames remain
            }
            m_queuedBytes -= it->payload.size();
            m_queue.erase(it);
        }
    }
    m_cv.notify_one();
}

void CSttPipe::writerLoop() {
    while (m_running.load()) {
        Frame frame;
        {
            std::unique_lock<std::mutex> lock(m_mutex);
            m_cv.wait(lock, [this] { return !m_running.load() || !m_queue.empty(); });
            if (!m_running.load()) {
                break;
            }
            frame = std::move(m_queue.front());
            m_queue.pop_front();
            m_queuedBytes -= frame.payload.size();
        }

        if (!ensureConnected()) {
            continue; // STT not up; drop this frame (queue is already bounded)
        }

        const uint32_t header[2] = {frame.type, static_cast<uint32_t>(frame.payload.size())};
        if (!writeAll(reinterpret_cast<const uint8_t *>(header), sizeof(header)) ||
            (!frame.payload.empty() && !writeAll(frame.payload.data(), frame.payload.size()))) {
            closePipe(); // write failed; reconnect on the next frame
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
