--版本信息
local version = 250511

local myGUID = UnitGUID("player")
local myName = UnitName("player")
local myClass = select(2, UnitClass("player"))

local totSpellId = 57934
local totThreatBuffId = 59628

local spellIdList = {
    ["ROGUE"] = 57934, -- 嫁祸
    ["HUNTER"] = 34477, -- 误导
    ["DEATHKNIGHT"] = 49016, -- 狂热
    -- ["PALADIN"] = 53563, -- 圣光道标
    ["WARRIOR"] = 50720, -- 警戒
    ["PRIEST"] = 10060, -- 灌注
    -- ["MAGE"] = 54646, -- 专注
    ["DRUID"] = 29166, -- 激活
    -- ["SHAMAN"] = 49284, -- 地盾
}
totSpellId = spellIdList[myClass] or totSpellId

local lastTrickTime = 0
local lastThreatBuffTIme = 0
local lastCancelTime = 0
local lastTrickTargetName = ""

local TOT_GLYPH_ID = (myClass == "ROGUE") and 63256 or nil
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

-- 队友增伤Buff数据
local totDamageBuffId = 57933
-- local totDamageBuffId = 48659 -- 测试用佯攻Buff

local lastToTDamageBuffExpirationTime = 0
local lastToTDamageBuffUnitGUID = nil
local lastToTDamageBuffRemoveTime = 0

local lastThreatBuffLasted = totDuration

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
        if subevent == "SPELL_CAST_SUCCESS" and sourceGUID == myGUID then
            --SPELL_CAST_SUCCESS 
            local spellId, spellName, spellSchool = select(12, ...)
            if spellId == totSpellId then
                lastTrickTime = timestamp
                lastTrickTargetName = destName

                if aura_env.config.enableWhisper and destName and destName ~= myName then
                    SendChatMessage("[JT嫁祸WA] 已经释放 "..GetSpellLink(totSpellId).."!","WHISPER",nil,destName)
                end
            end
        elseif subevent == "SPELL_AURA_APPLIED" and sourceGUID == myGUID and myClass == "ROGUE" then
            local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
            if spellId == totThreatBuffId then
                lastThreatBuffTIme = timestamp
                lastThreatBuffLasted = totDuration
            elseif spellId == totDamageBuffId then
                local broName = Ambiguate(destName,"all") or "好兄弟"
                local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = WA_GetUnitBuff(destName, spellId)
                if expirationTime and expirationTime > 0 then
                    lastToTDamageBuffExpirationTime = expirationTime
                    lastToTDamageBuffUnitGUID = destGUID
                    lastToTDamageBuffRemoveTime = 0
                end
            end
        elseif subevent == "SPELL_AURA_REMOVED" and sourceGUID == myGUID and myClass == "ROGUE" then
            local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
            if spellId == totThreatBuffId then
                if lastTrickTime and lastThreatBuffTIme then
                    lastCancelTime = timestamp
                    if lastThreatBuffTIme - lastTrickTime < 40 then
                        local buffTime = lastCancelTime - lastThreatBuffTIme
                        if lastCancelTime - lastThreatBuffTIme < totDuration then
                            lastThreatBuffLasted = buffTime
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
            elseif spellId == totDamageBuffId then
                local now = GetTime()
                if lastToTDamageBuffExpirationTime > 0 and now <= (lastToTDamageBuffExpirationTime - 0.5) then
                    --提前0.5秒结束，有取消嫌疑
                    local wasteTime = lastToTDamageBuffExpirationTime - now
                    local wasteTimeStr = string.format("%.1f",wasteTime)

                    -- print("嫁祸增伤还有 "..wasteTimeStr.." 秒就提前结束了，有取消嫌疑")
                    lastToTDamageBuffExpirationTime = 0
                    lastToTDamageBuffRemoveTime = now
                    --发送好兄弟取消嫁祸事件
                    WeakAuras.ScanEvents("JT_TOT_DAMAGE_CANCELLED", destGUID, wasteTimeStr, aura_env.config.enableCancelBuffText, aura_env.config.enableCancelBuffSound)
                end
            elseif subevent == "UNIT_DIED" and myClass == "ROGUE" then
                local now = GetTime()
                if lastToTDamageBuffRemoveTime > 0 and now <= (lastToTDamageBuffRemoveTime + 0.5) and lastToTDamageBuffUnitGUID == destGUID then
                    -- 嫁祸刚刚结束0.5秒，就死了，很可能是被自己嫁祸害死的……
                    -- 发送好兄弟挂了的事件
                    -- print("好兄弟挂了")
                    local lastedTimeStr = string.format("%.1f",lastThreatBuffLasted)
                    WeakAuras.ScanEvents("JT_TOT_CAUSE_DEATH", destGUID, lastedTimeStr, aura_env.config.enableCancelBuffText)

                    lastToTDamageBuffRemoveTime = 0
                    lastToTDamageBuffUnitGUID = nil
                end
                --UNIT_DIED,0000000000000000,nil,0x80000000,0x80000000,Player-4533-04FC3FB7,"圣弓灬游侠-维希度斯-CN",0x514,0x0,1
            end
        end

    elseif event == "GLYPH_UPDATED" then
        totDuration = checkGlyph(TOT_GLYPH_ID) and TOT_DURATION_WITH_GLYPH or TOT_DURATION
    end

    return true
end
