#pragma once

#include <windows.h>
#include <atomic>
#include <condition_variable>
#include <cstdint>
#include <deque>
#include <mutex>
#include <thread>
#include <vector>

// Writes the local player's gated microphone PCM to the STT named pipe
// (\\.\pipe\uksf_stt) as a framed stream. ACRE is the pipe CLIENT; the STT
// process is the server. All blocking pipe I/O happens on the writer thread,
// so the real-time audio callback only ever does a cheap enqueue.
//
// Wire protocol (little-endian): each frame is [uint32 type][uint32 payloadLen][payload].
//   START (type 1): payload = uint32 sampleRate, uint32 channels, uint32 uttId
//   DATA  (type 2): payload = raw interleaved int16 PCM
//   END   (type 3): payload = uint32 uttId
class CSttPipe {
public:
    static CSttPipe *getInstance();

    void start(); // spawn the writer thread (idempotent)
    void stop();  // signal + join + close pipe (idempotent)

    // Producer API -- safe to call from any thread; never blocks on pipe I/O.
    void beginUtterance(uint32_t sampleRate, uint32_t channels);
    void pushPcm(const short *samples, int count); // count = total samples (sampleCount * channels)
    void endUtterance();

    // Connect to the STT server ahead of speech. Without this the handshake happens
    // inside the first utterance, which the writer then drops as "STT absent".
    void preconnect();

private:
    CSttPipe() = default;
    ~CSttPipe();
    CSttPipe(const CSttPipe &) = delete;
    CSttPipe &operator=(const CSttPipe &) = delete;

    enum FrameType : uint32_t { FRAME_START = 1, FRAME_DATA = 2, FRAME_END = 3 };
    struct Frame {
        uint32_t type = 0;
        std::vector<uint8_t> payload;
    };

    void enqueue(Frame &&frame);
    void writerLoop();
    bool ensureConnected();
    bool writeAll(const uint8_t *data, size_t len);
    void closePipe();

    std::deque<Frame> m_queue;
    size_t m_queuedBytes = 0;
    std::mutex m_mutex;
    std::condition_variable m_cv;
    std::thread m_thread;
    std::atomic<bool> m_running{false};

    HANDLE m_pipe = INVALID_HANDLE_VALUE;
    std::atomic<bool> m_preconnect{false};
    ULONGLONG m_lastConnectAttempt = 0;
    uint32_t m_uttId = 0;                    // audio thread only
    std::atomic<uint32_t> m_currentUttId{0}; // set at START (audio), read at END (any thread)
    bool m_dropping = false;                 // guarded by m_mutex

    static constexpr size_t MAX_QUEUED_BYTES = 2 * 1024 * 1024; // ~10s @ 48k mono int16
    static constexpr ULONGLONG CONNECT_THROTTLE_MS = 500;
};
