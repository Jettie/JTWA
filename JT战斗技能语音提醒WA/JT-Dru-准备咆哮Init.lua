-- 版本信息
local version = 250801

local file = "Druid\\准备咆哮.ogg"
local ttsText = "准备咆哮"
local ttsSpeed = 4

local remindInterval = 5 -- 割裂提醒间隔（秒）
local lastRemindTime = 0 -- 上次提醒时间

--播放音频文件
local PlayJTSorTTS = function(file, ttsText, ttsSpeed)
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

local tryRemind = function()
    if aura_env.config.isVoice then
        local now = GetTime()
        if now - lastRemindTime > remindInterval then
            lastRemindTime = now
            PlayJTSorTTS(file, ttsText, ttsSpeed)
        end
    end
end
aura_env.tryRemind = tryRemind