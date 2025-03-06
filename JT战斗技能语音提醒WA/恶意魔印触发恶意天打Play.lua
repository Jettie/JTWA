--天打
if aura_env.config.isVoice then
    local file = "DK\\天打.ogg"
    local ttsText = "天打"
    local ttsSpeed = 1
    
    local function tryPSFOrTTS(filePath, text, speed)
        local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
        local filePSF = PATH_PSF..(filePath or "")
        local canplay, soundHandle = PlaySoundFile(filePSF, "Master")
        if not canplay then
            C_VoiceChat.SpeakText(0, (text or ""), 0, (speed or 0), 100)
            aura_env.ttsPlaying = true
            aura_env.lastTTSPlayTime = GetTime()
        else
            aura_env.soundHandle = soundHandle
            aura_env.lastSoundPlayTime = GetTime()
        end
    end
    
    if JTS and JTS.P then
        local canplay, soundHandle = JTS.P(file)
        if not canplay then
            tryPSFOrTTS(file, ttsText, ttsSpeed)
        else
            aura_env.soundHandle = soundHandle
            aura_env.lastSoundPlayTime = GetTime()
        end
    else
        tryPSFOrTTS(file, ttsText, ttsSpeed)
    end
end

-- 恶意天打
if aura_env.config.isVoice and aura_env.config.isSigilOfVirulence then
    local file = "DK\\恶意天打.ogg"
    local ttsText = "恶意魔印"
    local ttsSpeed = 1
    
    local function tryPSFOrTTS(filePath, text, speed)
        local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
        local filePSF = PATH_PSF..(filePath or "")
        local canplay, soundHandle = PlaySoundFile(filePSF, "Master")
        if not canplay then
            if aura_env.soundHandle and aura_env.lastSoundPlayTime + 0.2 > GetTime() then
                StopSound(aura_env.soundHandle)
                aura_env.soundHandle = nil
            end
            if aura_env.ttsPlaying and aura_env.lastTTSPlayTime + 0.2 > GetTime() then
                C_VoiceChat.StopSpeakingText()
                aura_env.ttsPlaying = false
            end
            C_VoiceChat.SpeakText(0, (text or ""), 0, (speed or 0), 100)
        else
            if aura_env.soundHandle and aura_env.lastSoundPlayTime + 0.2 > GetTime() then
                StopSound(aura_env.soundHandle)
                aura_env.soundHandle = nil
            end
        end
    end
    
    if JTS and JTS.P then
        local canplay, soundHandle = JTS.P(file)
        if not canplay then
            tryPSFOrTTS(file, ttsText, ttsSpeed)
        else
            if aura_env.soundHandle and aura_env.lastSoundPlayTime + 0.2 > GetTime() then
                StopSound(aura_env.soundHandle)
                aura_env.soundHandle = nil
            end
        end
    else
        tryPSFOrTTS(file, ttsText, ttsSpeed)
    end
end

