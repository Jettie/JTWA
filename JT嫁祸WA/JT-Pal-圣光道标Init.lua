--版本信息
local version = 250407

local myGUID = UnitGUID("player")
local myName = UnitName("player")
local myClass = select(2, UnitClass("player"))

local thisSpellId = 53563
local thisSpellBuffId = 53563

--author and header
local AURA_ICON = 236247
local AURA_NAME = "JT嫁祸WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local HEADER_SHORT = SMALL_ICON.."[|CFF8FFFA2凸|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local spellIdList = {
    -- ["ROGUE"] = 57934, -- 嫁祸
    -- ["HUNTER"] = 34477, -- 误导
    -- ["DEATHKNIGHT"] = 49016, -- 狂热
    -- ["PRIEST"] = 10060, -- 灌注
    -- ["MAGE"] = 54646, -- 专注
    -- ["DRUID"] = 29166, -- 激活
    ["PALADIN"] = 53563, -- 圣光道标
    -- ["SHAMAN"] = 49281, -- 萨满闪电盾测试
}
thisSpellId = spellIdList[myClass] or thisSpellId

local lastCastSuccessTime = 0
local THIS_GLYPH_ID = (myClass == "PALADIN") and 63218 or nil
local BUFF_DURATION = 60
local BUFF_DURATION_WITH_GLYPH = 90

local buffIsAboutToExpireSoundFile = "Paladin\\快补道标.ogg"
local buffIsAboutToExpireTTSText = "快补道标"
local buffIsAboutToExpireTTSSpeed = 2
local buffIsAboutToExpireTimer
local alertTimeBeforeBuffExpire = 5

local buffRemovedSoundFile = "Paladin\\道标断了.ogg"
local buffRemovedTTSText = "道标断了"
local buffRemovedTTSSpeed = 2


local checkGlyph = function(checkGlyphId)
    if not checkGlyphId then return end
    local glyphInSocket = {}
    for i = 1, GetNumGlyphSockets() do
        local id = select(4,GetGlyphSocketInfo(i))
        if id then
            glyphInSocket[id] = true
        end
    end
    return glyphInSocket[checkGlyphId]
end
local thisSpellDuration = checkGlyph(THIS_GLYPH_ID) and BUFF_DURATION_WITH_GLYPH or BUFF_DURATION

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

            if aura_env.config.enableWhisper and destName and destName ~= myName then
                SendChatMessage(ONLY_TEXT.."已经释放 "..GetSpellLink(thisSpellId).."!",  "WHISPER", nil, destName)
            end

        elseif subevent == "SPELL_AURA_REMOVED" and spellId == thisSpellBuffId and sourceGUID == myGUID then
            -- 先移除之前的即将到期Timer
            if buffIsAboutToExpireTimer and not buffIsAboutToExpireTimer:IsCancelled() then
                buffIsAboutToExpireTimer:Cancel()
            end

            local now = GetTime()
            -- print("lastCastSuccessTime=", lastCastSuccessTime, " now=", now, " thisSpellDuration=", thisSpellDuration)
            if now - lastCastSuccessTime < 0.5 then
                -- 移除时间与释放时间间隔过短，是手动释放的，不提示
                -- print("too soon")
            else
                if now - lastCastSuccessTime < thisSpellDuration - 0.2 or now - lastCastSuccessTime >= thisSpellDuration - 0.1 then
                    -- 移除时间提前结束 说明目标身上道标提前断了，需要提示断了，也可能是目标挂了
                    -- 移除时间延后结束 说明目标身上道标延后断了，需要提示延后断了
                    if aura_env.config.isVoice then
                        PlayJTSorTTS(buffRemovedSoundFile, buffRemovedTTSText, buffRemovedTTSSpeed)
                    end
                end
            end
        elseif (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and spellId == thisSpellBuffId and sourceGUID == myGUID then
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, 
            shouldConsolidate, spellId = WA_GetUnitBuff("player", thisSpellBuffId)
            --print("name=", name, " icon=", icon, " count=", count, " debuffType=", debuffType, " duration=", duration, " expirationTime=", expirationTime, " unitCaster=", unitCaster, " isStealable=", isStealable, " shouldConsolidate=", shouldConsolidate, " spellId=", spellId)

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

    elseif event == "GLYPH_UPDATED" then
        thisSpellDuration = checkGlyph(THIS_GLYPH_ID) and BUFF_DURATION_WITH_GLYPH or BUFF_DURATION
    end
end

