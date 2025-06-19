--版本信息
local version = 250526

--author and header
local AURA_ICON = 236283
local AURA_NAME = "JT嫁祸WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local MSG_HEADER = "[JT嫁祸WA] "

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

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unit)
    if unit and UnitExists(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if not class then
            return name
        else
            local classData = (RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unit
    end
end

-- DO NOT DISTURB
local doNotDisturbList = {}
--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTESAY"] = true,
        ["JTEGUILD"] = true,
        ["JTERAID"] = true,
        ["JTEPARTY"] = true,
        ["JTETTS"] = true,
        ["JTECHECK"] = true,
        ["JTECHECKRESPONSE"] = true,
        ["JTETOTDISTRUB"] = true,
    }
    for k,_ in pairs(prefixList) do
        C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

local OnChatMSGAddon = function(...)
    local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...
    if prefix == "JTECHECK" then
        local ver = version or 0
        if text == "tot" then
            local msg = "ToTHelper Ver: "..ver
            C_ChatInfo.SendAddonMessage("JTECHECKRESPONSE", msg, channel, nil)
        end
    elseif prefix == "JTETOTDISTRUB" then
        local unitName = Ambiguate(sender,"all") or "不愿被密语打扰的好兄弟"
        if text == "dnd" then
            if not doNotDisturbList[unitName] then
                print(HEADER_TEXT.."队友 "..classColorName(unitName).." 关闭了密语(改为仅自己可见的消息)")
            end
            doNotDisturbList[unitName] = true
        elseif text == "undnd" then
            if doNotDisturbList[unitName] then
                print(HEADER_TEXT.."队友 "..classColorName(unitName).." 主动开启了密语")
            end
            doNotDisturbList[unitName] = nil
        end
    end
end

local OnGroupRosterUpdate = function()
    if not IsInGroup() then
        if not doNotDisturbList == {} then
            local names = ""
            for k, v in pairs(doNotDisturbList) do
                names = names..classColorName(k).." "
            end

            doNotDisturbList = {}
            print(HEADER_TEXT.."防止密语模式已关闭，队伍中 "..(names or "没有人 ").."的防密语模式已清除")
        end
    end
end

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

                    local msg = "已经释放 "..(GetSpellLink(totSpellId) or "嫁祸诀窍").."!"
                    if not doNotDisturbList[destName] then
                        SendChatMessage((MSG_HEADER..msg),"WHISPER",nil,destName)
                    else
                        print(HEADER_TEXT.."|cffFF80FF"..msg)
                    end
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
                                local myMessage = "我在 "..(GetSpellLink(totThreatBuffId) or "嫁祸诀窍").." 第 "..string.format("%.2f",buffTime).." 秒时取消了仇恨转移"
                                local msg = extraText..myMessage..tail
                                if not doNotDisturbList[lastTrickTargetName] then
                                    SendChatMessage(msg,"WHISPER",nil,lastTrickTargetName)
                                else
                                    print(HEADER_TEXT.."|cffFF80FF"..extraText..myMessage)
                                end
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
    elseif event == "CHAT_MSG_ADDON" then
        OnChatMSGAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        OnGroupRosterUpdate()
    end

    return true
end
