local noRFSoundFile = "Paladin\\没有正义之怒.ogg"
local noRFTTSText = "你没开正义之怒，注意检查"

local hasRFSoundFile = "Paladin\\有正义之怒.ogg"
local hasRFTTSText = "你还开着正义之怒，注意检查"

local isTanking = aura_env.checkTankTalent()
local hasRighteousFury = aura_env.checkRighteousFury()
local hasImprovedRighteousFury = aura_env.checkImprovedRighteousFury()

if aura_env.config.isVoice then
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

