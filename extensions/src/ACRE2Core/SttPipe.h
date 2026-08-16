#pragma once

#include "compat.h"
#include <atomic>
#include <condition_variable>
#include <cstdint>
#include <deque>
#include <mutex>
#include <thread>
#include <vector>

// Writes the local player's direct-speech mic PCM to \\.\pipe\uksf_stt as a
// framed stream. ACRE is the pipe SERVER (created at plugin init). UKSF is
// the client and connects at sttStart. All blocking pipe I/O happens on the
// writer thread; the audio callback only enqueues.
//
// Wire protocol (little-endian): [uint32 type][uint32 payloadLen][payload].
//   START (type 1): uint32 sampleRate, uint32 channels, uint32 uttId
//   DATA  (type 2): raw interleaved int16 PCM
//   END   (type 3): uint32 uttId
class CSttPipe {
public:
    static CSttPipe *getInstance();

    void start(); // create the pipe + writer (idempotent)
    void stop();  // signal + join + close (idempotent)

    // Producer API -- any thread; never blocks on pipe I/O.
    void beginUtterance(uint32_t sampleRate, uint32_t channels);
    void pushPcm(const short *samples, int count);
    void endUtterance();

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
    bool ensureListening();
    bool acceptClient();
    bool writeAll(const uint8_t *data, size_t len);
    void dropClient();
    void closePipe();
    void wakeAccept();

    std::deque<Frame> m_queue;
    size_t m_queuedBytes = 0;
    std::mutex m_mutex;
    std::condition_variable m_cv;
    std::thread m_thread;
    std::atomic<bool> m_running{false};

    HANDLE m_pipe = INVALID_HANDLE_VALUE;
    uint32_t m_uttId = 0;
    std::atomic<uint32_t> m_currentUttId{0};
    bool m_dropping = false;

    static constexpr size_t MAX_QUEUED_BYTES = 2 * 1024 * 1024;
};
