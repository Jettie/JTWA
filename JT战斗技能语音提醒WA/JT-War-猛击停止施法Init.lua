--版本信息
local version = 250516

--设置参数
local slamSpellId = 47475
local stopCastingSoundFile = "Common\\停止施法.ogg"
local stopCastingTTSText = "停止施法"
local stopCastingTTSSpeed = 5
local timer = nil

--播放音频文件
local playJTSorTTS = function(file,ttsText,ttsSpeed)
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

local OnUnitSpellCastStart = function(event, ...)
    local unitTarget, castGUID, spellID = ...
    if unitTarget == "player" and spellID == slamSpellId then
        if aura_env.config.isVoice then
            if timer and not timer:IsCancelled() then
                timer:Cancel()
            end
            timer = C_Timer.NewTimer(0.3, function()
                playJTSorTTS(stopCastingSoundFile, stopCastingTTSText, stopCastingTTSSpeed)
            end)
        end
    end
end

local OnUnitSpellCastStop = function(event, ...)
    local unitTarget, castGUID, spellID = ...
    if unitTarget == "player" and spellID == slamSpellId then
        if timer and not timer:IsCancelled() then
            timer:Cancel()
        end
    end
end

-- 触发器1
aura_env.OnTrigger = function(event, ...)
    if event == "UNIT_SPELLCAST_START" then
        return OnUnitSpellCastStart(event, ...)
    elseif event == "UNIT_SPELLCAST_STOP" then
        return OnUnitSpellCastStop(event, ...)
    end
end