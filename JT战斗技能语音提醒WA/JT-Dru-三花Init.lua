-- 版本信息
local version = 250806

local lifeBloomSpellId = 33763
local lifeBloomSpellName = GetSpellInfo(lifeBloomSpellId) or "生命绽放"

local myGUID = UnitGUID("player")

local lifeBloomSoundFile = {
    [1] = "花",
    [2] = "二花",
    [3] = "三花",
}
local lifeBloomTTSText = {
    [1] = "花",
    [2] = "二花",
    [3] = "三花",
}
local ttsSpeed = 1
local soundFilePath = "Druid\\"
local soundFileFormat = ".ogg"

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

aura_env.OnTrigger = function(event, ...)
    if not aura_env.config.isVoice then return end
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, extraAmount, extraAmount2, extraAmount3 = CombatLogGetCurrentEventInfo()
        if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") and sourceGUID == myGUID then
            local thisSpellName = GetSpellInfo(spellId) or "未知法术"
            local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or nil
            if thisSpellName == lifeBloomSpellName and UnitExists(shortDestName) then
                local stack = select(3,WA_GetUnitBuff(shortDestName, spellId))
                if lifeBloomSoundFile[stack] then
                    local thisSoundFile = soundFilePath..lifeBloomSoundFile[stack]..soundFileFormat
                    local thisTTSText = lifeBloomTTSText[stack]
                    PlayJTSorTTS(thisSoundFile, thisTTSText, ttsSpeed)

                end
            end
        end
    end
end