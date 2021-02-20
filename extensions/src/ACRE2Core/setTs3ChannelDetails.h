#pragma once

#include "IRpcFunction.h"
#include "Log.h"
#include "TextMessage.h"
#include "Engine.h"
#include "StringConversions.h"
#include "String"

#include <sstream>

RPC_FUNCTION(setTs3ChannelDetails) {
    const  std::vector<std::wstring> details = {
        StringConversions::stringToWstring(std::string((char *)vMessage->getParameter(0))),
        StringConversions::stringToWstring(std::string((char *)vMessage->getParameter(1))),
        StringConversions::stringToWstring(std::string((char *)vMessage->getParameter(2)))
    };

    CEngine::getInstance()->getClient()->updateTs3ChannelDetails(details);
    return acre::Result::ok;
}
public:
    inline void setName(const char *const value) final { m_Name = value; }
    inline const char* getName() const final { return m_Name; }

protected:
    const char* m_Name;
};


