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
    if (enabled) {
        CSttPipe::getInstance()->start();
        if (self) {
            self->setMicCaptureGate(TRUE);
        }
    } else {
        if (self) {
            self->setMicCaptureGate(FALSE);
        }
        CEngine::getInstance()->getSoundEngine()->endSttStreamIfActive();
        CSttPipe::getInstance()->requestStop();
    }

    return acre::Result::ok;
}
public:
    inline void setName(const char *const value) final { m_Name = value; }
    inline const char* getName() const final { return m_Name; }

protected:
    const char* m_Name;
};
