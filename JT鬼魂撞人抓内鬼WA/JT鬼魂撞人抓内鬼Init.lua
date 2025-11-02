-- 版本信息
local version = 250722.5

--solo header
local AURA_ICON = 237557
local AURA_NAME = "JT鬼魂撞人抓内鬼WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local HELLO_WORLD = HEADER_TEXT.."- 战斗结束通报撞魂人 - 作者:|R "..AUTHOR
print(HELLO_WORLD)

local myName = UnitName("player")

local MELEE_ID = 6603

local isInValidEncounter = false
local thisEncounterId = 0
local encounterStartTime = 0


local spiritNumber = 0
local spiritList = {}
local spiritHitList = {}

local ladyDeathwhisperEncounterId = 846
local ladyDeathwhisper = 36855
local summonSpirit = 71426
local vengefulShadeId = 38222
local vengefulBlastSpellId = 71544


local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug : "..(text or "nil"))
    end
end

local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(VSHitter) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))

    --test data
    if JTDebug then

        isInValidEncounter = true

        encounterStartTime = GetTime() - 66

        spiritList = {
            ["Creature-0-4527-631-4225-38222-00007B871F"] = {
                number = 1,
                guid = "Creature-0-4527-631-4225-38222-00007B871F",
                friendlyFire = {
                    ["Player-4533-041B1E7F"] = 100,
                    ["Player-4533-041B1E80"] = 110,
                    ["Player-4533-041B1E81"] = 120,
                },
            },
            ["Creature-0-4527-631-4225-38222-00007B8757"] = {
                number = 2,
                guid = "Creature-0-4527-631-4225-38222-00007B8757",
                friendlyFire = {
                    ["Player-4533-041B1E7F"] = 100,
                    ["Player-4533-041B1E80"] = 110,
                    ["Player-4533-041B1E81"] = 120,
                    ["Player-4533-041B1E82"] = 130,
                    ["Player-4533-041B1E83"] = 140,
                },
            },
            ["Creature-0-4527-631-4225-38222-00007B8758"] = {
                number = 3,
                guid = "Creature-0-4527-631-4225-38222-00007B8758",
                friendlyFire = {
                    ["Player-4533-041B1E83"] = 77,
                },
            },
        }
        spiritHitList = {
            [1] = {
                spiritGUID = "Creature-0-4527-631-4225-38222-00007B871F",
                badGuyGUID = "Player-4533-041B1E80",
                badGuyName = "测试的JT1",
                hitTime = GetTime() - 10,
            },
            [2] = {
                spiritGUID = "Creature-0-4527-631-4225-38222-00007B8757",
                badGuyGUID = "Player-4533-041B1E81",
                badGuyName = "测试的JT2-服务器名",
                hitTime = GetTime() - 20,
            },
            [3] = {
                spiritGUID = "Creature-0-4527-631-4225-38222-00007B8758",
                badGuyGUID = "Player-4533-041B1E83",
                badGuyName = "测试的JT3",
                hitTime = GetTime() - 30,
            },
        }
        DevTools_Dump(spiritList)
        DevTools_Dump(spiritHitList)
    end
end

local isValidBoss = function()
    return ladyDeathwhisperEncounterId == thisEncounterId and true or false
end

local OnCLEUF = function(...)
    if not isInValidEncounter then return end

    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, arg12, _, _, arg15, arg16, _, _, arg19 = ...

    local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or nil
    local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or nil

    -- SPELL_SUMMON,Creature-0-4527-631-4225-36855-00007B7C98,"亡语者女士",0x80010a48,0x80000000,Creature-0-4527-631-4225-38222-00007B871F,"怨毒之影",0x80000a28,0x80000000,71426,"召唤灵魂",0x1
    -- BOSS 召唤的小怪
    if subevent == "SPELL_SUMMON" and not (UnitInRaid(shortSourceName) or UnitInParty(shortSourceName)) then
        if sourceGUID and destGUID then
            local unitType, _, _, _, _, npcId = strsplit("-", sourceGUID)
            local numNpcId = tonumber(npcId)
            if unitType == "Creature" and numNpcId == ladyDeathwhisper then
                -- 亡语者召唤 怨毒之影
                -- if arg12 == summonSpirit then
                    -- 存入spiritList
                    spiritNumber = spiritNumber + 1
                    spiritList[destGUID] = {
                        number = spiritNumber,
                        guid = destGUID,
                        friendlyFire = {},
                    }
                -- end
            end
        end
    end

    if UnitIsPlayer(shortDestName) then
        if subevent == "SWING_MISSED" or subevent == "SWING_DAMAGE" then
            if sourceGUID then
                local unitType, _, _, _, _, npcId = strsplit("-", sourceGUID)
                local numNpcId = tonumber(npcId)
                if unitType == "Creature" and numNpcId == vengefulShadeId then
                    -- 怨毒之影每次攻击人，就是触发了误伤，先记录HitList
                    
                        local badGuyGUID = destGUID
                        local badGuyName = shortDestName
                        
                        table.insert(spiritHitList, {
                            spiritGUID = sourceGUID,
                            badGuyGUID = badGuyGUID,
                            badGuyName = badGuyName,
                            hitTime = GetTime(),
                        })
                end
            end
        elseif subevent == "SPELL_DAMAGE" then
            local spellId = arg12
            local amount = arg15
            if sourceGUID then
                local unitType, _, _, _, _, npcId = strsplit("-", sourceGUID)
                local numNpcId = tonumber(npcId)
                if unitType == "Creature" and numNpcId == vengefulShadeId then
                    if not spiritList[sourceGUID] then
                        spiritList[sourceGUID] = {
                            number = 0,
                            guid = sourceGUID,
                            friendlyFire = {},
                        }
                    end

                    spiritList[sourceGUID].friendlyFire[destGUID] = amount

                end
            end
        end
    end
end


local getChannel = function()
    if IsInRaid() and not IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        return "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInGroup() and IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "PARTY"
    end
end

local sendMsgInterval = 0.3

local sendMsgToRaidOrGroup = function(textTableOrStr, intervalTime)
    intervalTime = intervalTime or 0
    local channel = getChannel()

    if JTDebug then
        channel = "GUILD" -- test in GUILD
    end

    if not channel then return end
    if type(textTableOrStr) == "string" then
        textTableOrStr = {textTableOrStr}
    end
    for i, v in ipairs(textTableOrStr) do
        C_Timer.After(intervalTime, function()
            -- for _, textLine in ipairs(textTableOrStr[i]) do
                SendChatMessage(v, channel, nil, nil)
            -- end
        end)
        intervalTime = intervalTime + sendMsgInterval
    end
    return intervalTime
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTEVSHITTER"] = true,
    }
    for k, _ in pairs(prefixList) do
        C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

local hitterReporter = {}

local receiveMessage = function(...)
    local prefix, text, _, sender = ...
    local senderName = Ambiguate(sender,"all")
    if prefix == "JTEVSHITTER" then
        local roll = tonumber(text)
        if roll then
            hitterReporter[senderName] = {
                sender = senderName,
                roll = roll,
            }
        end
        jtprint("MSG received! "..senderName.." rolls "..roll)
    end
end

local rollReporter = function(success)
    if not aura_env.config.enableReport then return end
    if not isInValidEncounter then
        jtprint("isInValidEncounter false")
        return
    end
    local roll = math.random(1, 100)
    local msg = tostring(roll)

    if JTDebug then
        -- DevTools_Dump()
    end

    local prefix = "JTEVSHITTER"

    local channel = getChannel()

    if JTDebug then
        channel = "GUILD" -- test in GUILD
    end

    C_ChatInfo.SendAddonMessage(prefix, msg, channel,nil)
end

local reportTheHitter = function()

    if not next(hitterReporter) then return end

    local finalReporter
    for k, v in pairs(hitterReporter) do
        if not finalReporter then
            finalReporter = hitterReporter[k]
        else
            if v.roll > finalReporter.roll then
                finalReporter = hitterReporter[k]
            end
        end
    end

    -- DevTools_Dump(finalReporter)


    local thisText = ONLY_TEXT.."没有人撞魂！"

    local topLine = "==== Roll("..(finalReporter and finalReporter.roll or "?")..") 赢了我来说几句 ===="
    local bottomLine = "==== "..ONLY_TEXT.."===="

    local reportContent = {}
    if #spiritHitList > 0 then
        table.insert(reportContent, topLine)
        for i, v in ipairs(spiritHitList) do
            local badGuyFullName = v.badGuyName
            local badGuyName = badGuyFullName and (strsplit("-", badGuyFullName) and strsplit("-", badGuyFullName) or badGuyFullName) or "?神秘人?"
            local badGuyGUID = v.badGuyGUID
            local spiritGUID = v.spiritGUID
            local hitTime = v.hitTime - encounterStartTime
            local thisSpiritNumber = spiritList[spiritGUID].number

            local friendlyFire = spiritList[spiritGUID].friendlyFire

            local friendlyHitCount = 0
            local friendlyFireTotalAmount = 0
            local selfHit = true
            for key, value in pairs(friendlyFire) do
                if key ~= badGuyGUID then
                    selfHit = false
                end
                if value then
                    friendlyHitCount = friendlyHitCount + 1
                    friendlyFireTotalAmount = friendlyFireTotalAmount + value
                end
            end

            -- 把v.deadTime换成 2:15 这种格式
            local strTime = ""
            if (hitTime <= 60) then
                strTime = format("00:%0.2d", hitTime)
            elseif (hitTime > 60) then
                strTime = format("%d:%0.2d", hitTime / 60, hitTime % 60)
            end

            -- 01:11 第 3 个 怨毒之影 追上了 AAAAAA 爆炸攻击附近 4 名玩家，累计误伤: 1888888
            if friendlyHitCount > 0 then
                if friendlyHitCount == 1 and selfHit then
                    -- 01:11 第 3 个 怨毒之影 追上了 AAAAAA 只炸到了自己，误伤: 1888888
                    thisText = strTime.." 第 "..thisSpiritNumber.." 个 怨毒之影 追上了 "..badGuyName.." 只炸到了自己，误伤: "..friendlyFireTotalAmount.." 点"
                else
                    -- 01:11 第 3 个 怨毒之影 追上了 AAAAAA 爆炸攻击附近 4 名玩家，累计误伤: 1888888
                    thisText = strTime.." 第 "..thisSpiritNumber.." 个 怨毒之影 追上了 "..badGuyName.." 爆炸攻击附近 "..friendlyHitCount.." 名玩家，累计误伤: "..friendlyFireTotalAmount..""
                end
            end
            table.insert(reportContent, thisText)
        end
        table.insert(reportContent, bottomLine)
    else
        table.insert(reportContent, thisText)
    end

    if JTDebug then
        DevTools_Dump(reportContent)
    end

    if finalReporter then
        local sender = finalReporter.sender and (strsplit("-", finalReporter.sender) and strsplit("-", finalReporter.sender) or finalReporter.sender) or nil
        -- local sender = Ambiguate(finalReporter.sender,"all")
        if sender == myName and aura_env.config.enableReport then
            sendMsgToRaidOrGroup(reportContent, sendMsgInterval)
            return
        else
            jtprint("Debug : On. send to GUILD")
            -- sendMsgToRaidOrGroup(reportContent, sendMsgInterval)
            return
        end
    end
end

local resetData = function()
    spiritNumber = 0
    spiritList = {}
    spiritHitList = {}
    hitterReporter = {}
end

-- 通过CHAT_MSG_ADDON接收消息 通讯roll点，看这次谁来通报
aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "ENCOUNTER_START" then
        local encounterId = ...
        thisEncounterId = encounterId
        isInValidEncounter = isValidBoss()
        encounterStartTime = GetTime()
        resetData()
    elseif event == "ENCOUNTER_END" or event == "JT_E_VSHITTER_REPORT" then
        local success = select(5, ...)
        rollReporter(success)
        isInValidEncounter = false
        C_Timer.After(3, function()
            WeakAuras.ScanEvents("JT_VSHITTER_BADGUY")
        end)
    elseif event == "JT_VSHITTER_BADGUY" then
        reportTheHitter()
    elseif event == "CHAT_MSG_ADDON" then
        receiveMessage(...)
    elseif event == "JT_D_VSHITTERLOG" then
        ToggleDebug()

    -- -- JT FAKE EVENT START
    -- elseif event == "JT_FAKE_EVENT" then
    --     OnJTFakeEvent(event, ...)
    -- -- JT FAKE EVENT END

    end
end