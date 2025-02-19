--版本信息
local version = 250219

local isBackstab = false
local isFaceText = false
local isVoice = false

aura_env.OnTrigger = function(event, ...)
    if event == "UI_ERROR_MESSAGE" then
        local errorType, message = ...
        if isBackstab and message == SPELL_FAILED_NOT_BEHIND then
            WeakAuras.ScanEvents("JT_DALIANLE", isFaceText, isVoice)
        end
    elseif event == "JT_BACKSTAB" then
        isBackstab, isFaceText, isVoice = ...
    end
end


