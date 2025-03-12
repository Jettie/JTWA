local data = {
    [0] = {
        soundPath = "Rogue\\",
        soundFile = "没有致伤毒药武器",
        displayText = "无武器",
        ttsText = "无武器",
        ttsSpeed = 0,
        duration = 5,
    },
    [1] = {
        soundPath = "Common\\",
        soundFile = "换刀",
        displayText = "换刀",
        ttsText = "换刀",
        ttsSpeed = 0,
        duration = 3,
    },
    [2] = {
        soundPath = "Common\\",
        soundFile = "换回来",
        displayText = "换回来",
        ttsText = "换回来",
        ttsSpeed = 0,
        duration = 1,
    },
}

local SOUND_FILE_FORMAT = ".ogg"
local remindType = 0
local enableDisplayText = true
local enableVoice = true

aura_env.duration = 3
aura_env.displayText = ""
aura_env.remindType = remindType

--播放音频文件
local playJTSorTTS = function(file, ttsText, ttsSpeed)
    local function tryPSFOrTTS(filePath, text, speed)
        local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
        local filePSF = PATH_PSF..(filePath or "")
        local canplay = PlaySoundFile(filePSF, "Master")
        if not canplay then
            C_VoiceChat.SpeakText(0, (text or ""), 0, (speed or 0), 100)
        end
    end

    if JTS and JTS.P then
        local canplay = JTS.P(file)
        if not canplay then
            tryPSFOrTTS(file, ttsText, ttsSpeed)
        end
    else
        tryPSFOrTTS(file, ttsText, ttsSpeed)
    end
end

local OnSwapRemind = function(...)
    remindType, enableDisplayText, enableVoice = ...
    if data[remindType] then
        local soundPath = data[remindType].soundPath
        local soundFile = data[remindType].soundFile
        local file = soundPath..soundFile..SOUND_FILE_FORMAT

        local ttsText = data[remindType].ttsText
        local ttsSpeed = data[remindType].ttsSpeed

        if enableVoice then
            playJTSorTTS(file, ttsText, ttsSpeed)
        end

        aura_env.duration = enableDisplayText and data[remindType].duration or 1
        aura_env.displayText = enableDisplayText and data[remindType].displayText or ""
        aura_env.remindType = enableDisplayText and remindType or 0

        return enableVoice or enableDisplayText
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_SWAP_WP_REMIND" then
        return OnSwapRemind(...)
    end
end