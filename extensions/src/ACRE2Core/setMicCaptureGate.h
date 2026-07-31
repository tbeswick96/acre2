#pragma once

#include "compat.h"
#include "Types.h"
#include "Macros.h"
#include "Log.h"
#include "IRpcFunction.h"

#include "IServer.h"
#include "Engine.h"
#include "SttPipe.h"

#include "TextMessage.h"

RPC_FUNCTION(setMicCaptureGate) {

    const bool enabled = vMessage->getParameterAsInt(0) == 1;

    CSelf *self = CEngine::getInstance()->getSelf();
    if (self) {
        self->setMicCaptureGate(enabled ? TRUE : FALSE);
    }
    if (enabled) {
        // Connect to the STT server now, while nobody is talking. The writer otherwise
        // handshakes inside the first utterance and drops it as "STT absent".
        CSttPipe::getInstance()->preconnect();
    }

    return acre::Result::ok;
}
public:
    inline void setName(const char *const value) final { m_Name = value; }
    inline const char* getName() const final { return m_Name; }

protected:
    const char* m_Name;
};
