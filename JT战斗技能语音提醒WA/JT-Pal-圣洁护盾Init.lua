--版本信息
local version = 250411

local myGUID = UnitGUID("player")
local myName = UnitName("player")
local myClass = select(2, UnitClass("player"))

local thisSpellId = 53601
local thisSpellBuffId = 53601

--author and header
local AURA_ICON = 236249
local AURA_NAME = "JT嫁祸WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local HEADER_SHORT = SMALL_ICON.."[|CFF8FFFA2凸|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local spellIdList = {
    ["PALADIN"] = 53601, -- 圣光道标
}
thisSpellId = spellIdList[myClass] or thisSpellId

local lastCastSuccessTime = 0
local BUFF_DURATION = 60

local buffIsAboutToExpireSoundFile = "Paladin\\补护盾.ogg"
local buffIsAboutToExpireTTSText = "补护盾"
local buffIsAboutToExpireTTSSpeed = 2
local buffIsAboutToExpireTimer
local alertTimeBeforeBuffExpire = 5

local buffRemovedSoundFile = "Paladin\\护盾断了.ogg"
local buffRemovedTTSText = "护盾断了"
local buffRemovedTTSSpeed = 2

local thisSpellDuration = BUFF_DURATION

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
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, arg13, arg14, arg15, arg16 = ...
        if subevent == "SPELL_CAST_SUCCESS" and spellId == thisSpellId and sourceGUID == myGUID then
            lastCastSuccessTime = GetTime()
        elseif subevent == "SPELL_AURA_REMOVED" and spellId == thisSpellBuffId and sourceGUID == myGUID then
            -- 先移除之前的即将到期Timer
            if buffIsAboutToExpireTimer and not buffIsAboutToExpireTimer:IsCancelled() then
                buffIsAboutToExpireTimer:Cancel()
            end

            local now = GetTime()
            if now - lastCastSuccessTime < 0.5 then
            else
                if now - lastCastSuccessTime < thisSpellDuration - 0.2 or now - lastCastSuccessTime >= thisSpellDuration - 0.1 then
                    if aura_env.config.isVoice then
                        PlayJTSorTTS(buffRemovedSoundFile, buffRemovedTTSText, buffRemovedTTSSpeed)
                    end
                end
            end
        elseif (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and spellId == thisSpellBuffId and sourceGUID == myGUID then
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, 
            shouldConsolidate, spellId = WA_GetUnitBuff("player", thisSpellBuffId)

            if name then
                if not buffIsAboutToExpireTimer or buffIsAboutToExpireTimer:IsCancelled() then
                    buffIsAboutToExpireTimer = C_Timer.NewTimer(duration - alertTimeBeforeBuffExpire, function()
                        if aura_env.config.isVoice then
                            PlayJTSorTTS(buffIsAboutToExpireSoundFile, buffIsAboutToExpireTTSText, buffIsAboutToExpireTTSSpeed)
                        end
                    end)
                end
            end
        end
    end
end

