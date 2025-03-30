--版本信息
local version = 250330

local playerGUID = UnitGUID("player")
local myClass = select(2, UnitClass("player"))

local totSpellId = 57934
local totThreatBuffId = 59628

local spellIdList = {
    ["ROGUE"] = 57934, -- 嫁祸
    ["HUNTER"] = 34477, -- 误导
    ["DEATHKNIGHT"] = 49016, -- 狂热
    ["PRIEST"] = 10060, -- 灌注
    ["MAGE"] = 54646, -- 专注
    ["DRUID"] = 29166, -- 激活
}
totSpellId = spellIdList[myClass] or totSpellId

local lastTrickTime = 0
local lastThreatBuffTIme = 0
local lastCancelTime = 0
local lastTrickTargetName = ""

local TOT_GLYPH_ID = 63256
local TOT_DURATION = 5.9
local TOT_DURATION_WITH_GLYPH = 9.9
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
local totDuration = checkGlyph(TOT_GLYPH_ID) and TOT_DURATION_WITH_GLYPH or TOT_DURATION

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, arg13, arg14, arg15, arg16 = ...
        if subevent == "SPELL_CAST_SUCCESS" and spellId == totSpellId and sourceGUID == playerGUID then
            lastTrickTime = timestamp
            lastTrickTargetName = destName

            if aura_env.config.enableWhisper then
                SendChatMessage("[JT嫁祸WA] 已经释放 "..GetSpellLink(totSpellId).."!","WHISPER",nil,destName)
            end
        elseif subevent == "SPELL_AURA_APPLIED" and spellId == totThreatBuffId and sourceGUID == playerGUID then
            lastThreatBuffTIme = timestamp
        elseif subevent == "SPELL_AURA_REMOVED" and spellId == totThreatBuffId and sourceGUID == playerGUID then
            if lastTrickTime and lastThreatBuffTIme then
                lastCancelTime = timestamp
                if lastThreatBuffTIme - lastTrickTime < 40 then
                    local buffTime = lastCancelTime - lastThreatBuffTIme
                    if lastCancelTime - lastThreatBuffTIme < totDuration then
                        if aura_env.config.enableCancelWhisper then
                            local extraText = (buffTime > 4) and "" or "(;P): 放心抽，使劲打! "
                            local tail = (buffTime > 0 and buffTime < 1) and " - 你看我这NB的手速！" or ""
                            SendChatMessage(extraText.."我在 "..GetSpellLink(totThreatBuffId).."第 "..string.format("%.2f",buffTime).." 秒时取消了仇恨转移"..tail,"WHISPER",nil,lastTrickTargetName)
                            return true
                        else
                            return false
                        end
                    end
                end
            end
        end

    elseif event == "GLYPH_UPDATED" then
        totDuration = checkGlyph(TOT_GLYPH_ID) and TOT_DURATION_WITH_GLYPH or TOT_DURATION
    end

    return true
end

