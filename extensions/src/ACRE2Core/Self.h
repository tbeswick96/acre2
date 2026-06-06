#pragma once

#include "compat.h"
#include "Macros.h"
#include "Types.h"

#include "Player.h"

#include <atomic>
#include <string>

class CSelf : public CPlayer {
public:
    CSelf() : CPlayer() {
        this->setSpeaking(false);
        this->setCurveModel(acre::CurveModel::original);
        this->setCurrentLanguageId(0);
        this->setMicCaptureGate(FALSE);
    };
    DECLARE_MEMBER(acre::CurveModel, CurveModel);
    DECLARE_MEMBER(BOOL, Speaking);
    DECLARE_MEMBER(int, CurrentLanguageId);

public:
    // Written by the RPC thread, read by the audio capture thread.
    void setMicCaptureGate(BOOL value) { m_MicCaptureGate.store(value != FALSE, std::memory_order_relaxed); }
    BOOL getMicCaptureGate() { return m_MicCaptureGate.load(std::memory_order_relaxed) ? TRUE : FALSE; }

private:
    std::atomic<bool> m_MicCaptureGate{false};
};