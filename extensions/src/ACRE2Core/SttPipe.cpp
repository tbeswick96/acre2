#include "SttPipe.h"
#include "Log.h"

#include <cstring>
#include <sddl.h>

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
        return;
    }
    m_thread = std::thread(&CSttPipe::writerLoop, this);
}

void CSttPipe::stop() {
    if (!m_running.exchange(false)) {
        return;
    }
    m_cv.notify_all();
    wakeAccept();
    if (m_pipe != INVALID_HANDLE_VALUE) {
        CancelIoEx(m_pipe, nullptr);
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
            return;
        }
        m_queuedBytes += frame.payload.size();
        m_queue.push_back(std::move(frame));
        if (m_queuedBytes > MAX_QUEUED_BYTES) {
            m_queue.clear();
            m_queuedBytes = 0;
            m_dropping = true;
        }
    }
    m_cv.notify_one();
}

void CSttPipe::writerLoop() {
    while (m_running.load()) {
        if (!ensureListening()) {
            Sleep(500);
            continue;
        }
        if (!acceptClient()) {
            if (!m_running.load()) {
                break;
            }
            dropClient();
            continue;
        }
        LOG("STT client connected");

        // New client: skip leftover mid-utterance frames until a START.
        bool needStart = true;
        while (m_running.load()) {
            Frame frame;
            {
                std::unique_lock<std::mutex> lock(m_mutex);
                m_cv.wait(lock, [this] { return !m_running.load() || !m_queue.empty(); });
                if (!m_running.load()) {
                    return;
                }
                frame = std::move(m_queue.front());
                m_queue.pop_front();
                m_queuedBytes -= frame.payload.size();
            }
            if (needStart) {
                if (frame.type != FRAME_START) {
                    continue;
                }
                needStart = false;
            }
            const uint32_t header[2] = {frame.type, static_cast<uint32_t>(frame.payload.size())};
            if (!writeAll(reinterpret_cast<const uint8_t *>(header), sizeof(header)) ||
                (!frame.payload.empty() && !writeAll(frame.payload.data(), frame.payload.size()))) {
                LOG("STT client disconnected");
                dropClient();
                break;
            }
        }
    }
}

bool CSttPipe::ensureListening() {
    if (m_pipe != INVALID_HANDLE_VALUE) {
        return true;
    }

    SECURITY_DESCRIPTOR sd;
    if (!InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION)) {
        LOG("STT InitializeSecurityDescriptor: %u", GetLastError());
        return false;
    }
    if (!SetSecurityDescriptorDacl(&sd, TRUE, nullptr, FALSE)) {
        LOG("STT SetSecurityDescriptorDacl: %u", GetLastError());
        return false;
    }
    SECURITY_ATTRIBUTES sa = { sizeof(SECURITY_ATTRIBUTES), &sd, TRUE };

    HANDLE handle = CreateNamedPipeW(
        PIPE_NAME,
        PIPE_ACCESS_OUTBOUND,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
        1,
        1 << 16,
        0,
        0,
        &sa
    );
    if (handle == INVALID_HANDLE_VALUE) {
        LOG("STT CreateNamedPipe failed: %u", GetLastError());
        return false;
    }
    m_pipe = handle;
    LOG("STT pipe listening on \\\\.\\pipe\\uksf_stt");
    return true;
}

bool CSttPipe::acceptClient() {
    if (ConnectNamedPipe(m_pipe, nullptr)) {
        return true;
    }
    const DWORD err = GetLastError();
    return err == ERROR_PIPE_CONNECTED;
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

void CSttPipe::dropClient() {
    if (m_pipe != INVALID_HANDLE_VALUE) {
        FlushFileBuffers(m_pipe);
        DisconnectNamedPipe(m_pipe);
    }
}

void CSttPipe::closePipe() {
    if (m_pipe != INVALID_HANDLE_VALUE) {
        FlushFileBuffers(m_pipe);
        DisconnectNamedPipe(m_pipe);
        CloseHandle(m_pipe);
        m_pipe = INVALID_HANDLE_VALUE;
    }
}

void CSttPipe::wakeAccept() {
    // Unblock ConnectNamedPipe so stop() can join. Same trick as CNamedPipeServer.
    HANDLE poke = CreateFileW(PIPE_NAME, GENERIC_READ, 0, nullptr, OPEN_EXISTING, 0, nullptr);
    if (poke != INVALID_HANDLE_VALUE) {
        CloseHandle(poke);
    }
}
