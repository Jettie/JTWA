-- 版本信息
local version = 250620

local noRFSoundFile = "Paladin\\没有正义之怒.ogg"
local noRFTTSText = "你没开正义之怒，注意检查"

local hasRFSoundFile = "Paladin\\有正义之怒.ogg"
local hasRFTTSText = "你还开着正义之怒，注意检查"

-- 防骑判断
local checkTankTalent = function()
    return select(5,GetTalentInfo(2, 21)) ~= 0 and true or false
end

-- 强化正义之怒 奶骑可能会开
local checkImprovedRighteousFury = function()
    return select(5,GetTalentInfo(2, 10)) ~= 0 and true or false
end

local checkRighteousFury = function()
    return WA_GetUnitBuff("player", 25780) and true or false
end

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

local tryRemind = function()
    if aura_env.config.isVoice then
        local isTanking = checkTankTalent()
        local hasRighteousFury = checkRighteousFury()
        local hasImprovedRighteousFury = checkImprovedRighteousFury()

        local file = ""
        local ttsText = ""
        local ttsSpeed = 1

        if isTanking and not hasRighteousFury then
            file = noRFSoundFile
            ttsText = noRFTTSText
        elseif not isTanking and hasRighteousFury and not hasImprovedRighteousFury then
            file = hasRFSoundFile
            ttsText = hasRFTTSText
        else
            return
        end
        
        playJTSorTTS(file, ttsText, ttsSpeed)
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_RIGHTEOUS_FURY_CHECK"then
        tryRemind()
    elseif event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_REGEN_DISABLED" then
        C_Timer.After(1, function()
                WeakAuras.ScanEvents("JT_RIGHTEOUS_FURY_CHECK")
        end)
    end
end

