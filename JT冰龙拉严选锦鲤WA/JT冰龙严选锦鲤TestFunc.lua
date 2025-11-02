-- 版本信息
local version = 250806

--solo header
local AURA_ICON = 135864
local AURA_NAME = "JT冰龙严选锦鲤WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local HELLO_WORLD = HEADER_TEXT.."- 推荐去龙肚子的人员 - 作者:|R "..AUTHOR

print(HELLO_WORLD)

local memberList = {}
local theOne = nil
local suggestionList = {}

local myName = UnitName("player")

local isInValidEncounter = false

local validEncounterId = {
    [855] = true, -- 辛达苟萨]
}

local isValidBoss = function(thisEncounterId)
    return validEncounterId[thisEncounterId]
end

local calculateSuggestion = function(unsortedMemberList)
    theOne = unsortedMemberList[1]

    suggestionList = {}

    for i, member in ipairs(unsortedMemberList) do
        if #suggestionList >= 5 then return end
        if member.combatRole == "TANK" then
            if member.class ~= "DEATHKNIGHT" then
                table.insert(suggestionList, member)
            end
        elseif member.combatRole ~= "HEALER" then
            if member.class == "WARRIOR" or member.class == "DEATHKNIGHT" or member.class == "PALADIN" or member.class == "ROGUE" then
                table.insert(suggestionList, member)
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

local reportSuggestion = function()
    local reportText = ONLY_TEXT
    local theOneText = ""
    local suggestionText = ""

    if theOne then
        local theOneClassName = UnitExists(theOne.name) and " ("..UnitClass(theOne.name)..")" or ""
        theOneText = ONLY_TEXT.."本团 *大锦鲤* 是 -> ".. theOne.name.. theOneClassName
    end

    if #suggestionList > 0 then
        suggestionText = "建议去龙肚子: "
        for i, suggestion in ipairs(suggestionList) do
            suggestionText = suggestionText.. suggestion.name.. " "
        end
        suggestionText = suggestionText.. " (靠前的优先)"
        reportText = reportText..suggestionText

        local channel = getChannel()
        if channel then
            SendChatMessage(theOneText, channel, nil, nil)
            C_Timer.After(0.5, function()
                SendChatMessage(reportText, channel, nil, nil)
            end)
        end
    end
end

local buildMemberList = function()
    if not IsInRaid() then
        print(HEADER_TEXT.."仅在团队中才能推荐锦鲤")
        return
    end
    for unit in WA_IterateGroupMembers() do
        local unitGUID = UnitGUID(unit)
        if unitGUID then
            local unitType, unitServerId, unitGUIDString = strsplit("-", unitGUID)
            if unitType == "Player" then
                local unitName = UnitName(unit)
                local unitClass = select(2, UnitClass(unit))
                local guidNum = tonumber(unitGUIDString, 16)
                local unitIndex = UnitInRaid(unit)
                local combatRole = unitIndex and select(12, GetRaidRosterInfo(unitIndex)) or "NONE"

                -- --测试
                -- role = "maintank" or "mainassist"
                -- combatRole = "DAMAGER", "TANK" or "HEALER". Returns "NONE" otherwise.
                -- UnitGroupRolesAssigned("player")

                table.insert(memberList, {
                    name = unitName,
                    class = unitClass,
                    combatRole = combatRole,
                    unitGUID = unitGUID,
                    guidNum = guidNum,
                })
            end
        end
    end

    table.sort(memberList, function(a, b)
        return a.guidNum < b.guidNum
    end)

    calculateSuggestion(memberList)
end

local initData = function()
    memberList = {}
    theOne = nil
    suggestionList = {}
end

local OnGroupRosterUpdate = function(event, ...)
    if not IsInRaid() then
        print(HEADER_TEXT.."仅在团队中才能推荐锦鲤")
        return
    end

    if #suggestionList > 0 then
        for i, player in ipairs(suggestionList) do
            local unitIndex = UnitInRaid(player.name)
            if unitIndex then
                local combatRole = select(12, GetRaidRosterInfo(unitIndex))
                if combatRole ~= player.combatRole then
                    -- 推荐人员职责变化 重新计算
                    buildMemberList()
                    reportSuggestion()
                    break
                end
            else
                -- 推荐人员不在团队中 重新计算
                buildMemberList()
                reportSuggestion()
                break
            end
        end
    else
        -- 没有推荐人员 重新计算
        buildMemberList()
        reportSuggestion()
    end
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTEDRAGONROLL"] = true,
        ["JTEDRAGONSHUTUP"] = true,
    }
    for k, _ in pairs(prefixList) do
        C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

local reporterRollList = {}

local receiveMessage = function(...)
    local prefix, text, _, sender = ...
    local senderName = Ambiguate(sender,"all")
    if prefix == "JTEDRAGONROLL" then
        local roll = tonumber(text)
        if roll then
            reporterRollList[senderName] = {
                sender = senderName,
                roll = roll,
            }
        end
    elseif prefix == "JTEDRAGONSHUTUP" then
        -- 隐藏按钮
        WeakAuras.ScanEvents("JT_WA_SINDRAGOSA_BTN_HIDE")
    end
end

local rollReporter = function()
    if not aura_env.config.enableReport then
        return
    end

    local roll = math.random(1, 100)
    local msg = tostring(roll)

    local prefix = "JTEDRAGONROLL"

    local channel = getChannel()
    C_ChatInfo.SendAddonMessage(prefix, msg, channel,nil)
end

local getFinalReporter = function()
    if not next(reporterRollList) then
        return
    end

    local finalReporter
    for k, v in pairs(reporterRollList) do
        if not finalReporter then
            finalReporter = reporterRollList[k]
        else
            if v.roll > finalReporter.roll then
                finalReporter = reporterRollList[k]
            end
        end
    end
    return finalReporter
end

local youCanShutUp = function()
    -- 通过CHAT_MSG_ADDON告诉队友我已经发送了推荐锦鲤
    local prefix = "JTEDRAGONSHUTUP"
    local msg = myName
    local channel = getChannel()

    if channel then
        C_ChatInfo.SendAddonMessage(prefix, msg, channel,nil)
    end
end

local OnEncounterStart = function(event, ...)
    if not isInValidEncounter then
        return
    end

    initData()
    buildMemberList()
    rollReporter()
    C_Timer.After(3, function()
        WeakAuras.ScanEvents("JT_SINDRAGOSA_REPORT")
    end)
end

-- JT FAKE EVENT FUNCTION START

-- 测试部分
--[[
6/16/2025 21:42:40.1678  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-007446E5,"牧无梦-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1678  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-00D807AD,"随寓而安-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1678  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-01DB404F,"山东高速-维希度斯-CN",0x512,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1678  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-0347B00B,"哈蘇-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1688  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-034D76DE,"巴啦啦小神仙-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1688  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-0415DF2C,"纯野生奥特曼-维希度斯-CN",0x40514,0x20,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1688  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-0445D3D2,"沒頭腦-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1688  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-049C7F07,"天敲-维希度斯-CN",0x512,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1698  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-04AD01D1,"乐小兮-维希度斯-CN",0x40514,0x2,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1698  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-04E9736E,"萌瑶七分甜-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1698  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-0592E597,"药不能停-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1698  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-05B54C17,"Jettie-维希度斯-CN",0x511,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1708  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-05BA301F,"露结为霜-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1708  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-05BF55DE,"你爱鱼腥草吗-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1708  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-05D760A9,"日落星辰-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1718  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-062E064A,"魅之猎-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1718  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-06349B2A,"尛民哥-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1718  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-06561FB4,"紫宸小萨-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1718  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-06DF7FD9,"港珠澳-维希度斯-CN",0x512,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1728  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-06EEEDE7,"大马泥猴-维希度斯-CN",0x514,0x4,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1728  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-070BAB7D,"鱼辉-维希度斯-CN",0x514,0x8,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1728  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-0712ECF3,"飞天逸-维希度斯-CN",0x514,0x1,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1728  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-072B833E,"之欧极易昂-维希度斯-CN",0x512,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1738  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-07699CAC,"小德民哥-维希度斯-CN",0x80514,0x0,70084,"冰霜光环",0x10,DEBUFF
6/16/2025 21:42:40.1738  SPELL_AURA_APPLIED,Creature-0-4891-631-2497-36853-0000501F16,"辛达苟萨",0x10a48,0x0,Player-4533-077E6063,"水产魔蟹-维希度斯-CN",0x514,0x0,70084,"冰霜光环",0x10,DEBUFF
]]
local playerList = {
    [1] = {
        guid = "Player-4533-06561FB4",
        name = "紫宸小萨",
        class = "SHAMAN",
        combatRole = "HEALER",
    },
    [2] = {
        guid = "Player-4533-06349B2A",
        name = "尛民哥",
        class = "PALADIN",
        combatRole = "HEALER",
    },
    [3] = {
        guid = "Player-4533-01DB404F",
        name = "山东高速",
        class = "WARRIOR",
        combatRole = "DAMAGER",
    },
    [4] = {
        guid = "Player-4533-04AD01D1",
        name = "乐小兮",
        class = "DEATHKNIGHT",
        combatRole = "TANK",
    },
    [5] = {
        guid = "Player-4533-007446E5",
        name = "牧无梦",
        class = "PRIEST",
        combatRole = "HEALER",
    },
    [6] = {
        guid = "Player-4533-0445D3D2",
        name = "沒頭腦",
        class = "PALADIN",
        combatRole = "HEALER",
    },
    [7] = {
        guid = "Player-4533-00D807AD",
        name = "随寓而安",
        class = "ROGUE",
        combatRole = "DAMAGER",
    },
    [8] = {
        guid = "Player-4533-05D760A9",
        name = "日落星辰",
        class = "SHAMAN",
        combatRole = "HEALER",
    },
    [9] = {
        guid = "Player-4533-05B54C17",
        name = "Jettie",
        class = "ROGUE",
        combatRole = "DAMAGER",
    },
    [10] = {
        guid = "Player-4533-05BF55DE",
        name = "你爱鱼腥草吗",
        class = "PRIEST",
        combatRole = "HEALER",
    },
    [11] = {
        guid = "Player-4533-05BA301F",
        name = "露结为霜",
        class = "DRUID",
        combatRole = "DAMAGER",
    },
    [12] = {
        guid = "Player-4533-0712ECF3",
        name = "飞天逸",
        class = "DEATHKNIGHT",
        combatRole = "DAMAGER",
    },
    [13] = {
        guid = "Player-4533-072B833E",
        name = "之欧极易昂",
        class = "PALADIN",
        combatRole = "DAMAGER",
    },
    [14] = {
        guid = "Player-4533-06DF7FD9",
        name = "港珠澳",
        class = "PALADIN",
        combatRole = "DAMAGER",
    },
    [15] = {
        guid = "Player-4533-07699CAC",
        name = "小德民哥",
        class = "DRUID",
        combatRole = "DAMAGER",
    },
    [16] = {
        guid = "Player-4533-0415DF2C",
        name = "纯野生奥特曼",
        class = "PALADIN",
        combatRole = "TANK",
    },
    [17] = {
        guid = "Player-4533-0347B00B",
        name = "哈蘇",
        class = "MAGE",
        combatRole = "DAMAGER",
    },
    [18] = {
        guid = "Player-4533-062E064A",
        name = "魅之猎",
        class = "HUNTER",
        combatRole = "DAMAGER",
    },
    [19] = {
        guid = "Player-4533-0592E597",
        name = "药不能停",
        class = "HUNTER",
        combatRole = "DAMAGER",
    },
    [20] = {
        guid = "Player-4533-049C7F07",
        name = "天敲",
        class = "MAGE",
        combatRole = "DAMAGER",
    },
    [21] = {
        guid = "Player-4533-034D76DE",
        name = "巴啦啦小神仙",
        class = "MAGE",
        combatRole = "DAMAGER",
    },
    [22] = {
        guid = "Player-4533-06EEEDE7",
        name = "大马泥猴",
        class = "DRUID",
        combatRole = "DAMAGER",
    },
    [23] = {
        guid = "Player-4533-070BAB7D",
        name = "鱼辉",
        class = "SHAMAN",
        combatRole = "HEALER",
    },
    [24] = {
        guid = "Player-4533-077E6063",
        name = "水产魔蟹",
        class = "WARLOCK",
        combatRole = "DAMAGER",
    },
    [25] = {
        guid = "Player-4533-04E9736E",
        name = "萌瑶七分甜",
        class = "MAGE",
        combatRole = "DAMAGER",
    },
}

local testSortedMemberList = {}

for i, player in ipairs(playerList) do
    local thisGUID = player.guid
    local unitType, unitServerId, unitGUIDString = strsplit("-", thisGUID)
    local unitName = player.name
    local unitClass = player.class
    local combatRole = player.combatRole

    local guidNum = tonumber(unitGUIDString, 16)

    table.insert(testSortedMemberList, {
        name = unitName,
        class = unitClass,
        combatRole = combatRole,
        guidNum = guidNum,
        oldId = i,
    })
end

table.sort(testSortedMemberList, function(a, b)
    if a.guidNum < b.guidNum then
        return true
    else
        return false
    end
end)

-- for i, member in ipairs(testSortedMemberList) do
--     print(i, member.oldId, member.name, member.class, member.combatRole)
-- end

local OnJTTestSindragosa = function()
    initData()
    calculateSuggestion(testSortedMemberList)

    -- print(HEADER_TEXT.."大锦鲤:")
    -- DevTools_Dump(theOne)
    -- print(HEADER_TEXT.."锦鲤排序后名单:")
    -- DevTools_Dump(testSortedMemberList)
    -- print(HEADER_TEXT.."建议锦鲤:")
    -- DevTools_Dump(suggestionList)
    -- print(HEADER_TEXT.."即将通报:")

    local saveGetChannel = getChannel
    getChannel = function()
        return "GUILD"
    end

    rollReporter()

    getChannel = saveGetChannel

    C_Timer.After(3, function()
        WeakAuras.ScanEvents("JT_FAKE_EVENT", "SINDRAGOSA_LUCKYMAN", "JT_SINDRAGOSA_REPORT")
    end)
end

-- 测试部分 END

--[[ Test Macros

/run WeakAuras.ScanEvents("JT_FAKE_EVENT", "SINDRAGOSA_LUCKYMAN", "ENCOUNTER_START", 855)

]]
local thisWATag = "SINDRAGOSA_LUCKYMAN"
local OnJTFakeEvent = function(event, ...)
    -- 由于是FAKE EVENT 所以导致...都需要在select后+2，select(3, ...)
    local waTag, fakeEvent = ...
    if waTag == thisWATag then
        print("FAKE EVENT: ", "waTag=", waTag, "fakeEvent=", fakeEvent)
        if fakeEvent == "ENCOUNTER_START" then
            -- /run WeakAuras.ScanEvents("JT_FAKE_EVENT", "SINDRAGOSA_LUCKYMAN", "ENCOUNTER_START", 855)
            print(fakeEvent, ":", "fakeEvent=", fakeEvent)
            local thisEncounterId = select(3, ...)
            isInValidEncounter = isValidBoss(thisEncounterId)

            OnJTTestSindragosa()
        elseif fakeEvent == "JT_SINDRAGOSA_REPORT" then
            -- /run WeakAuras.ScanEvents("JT_FAKE_EVENT", "SINDRAGOSA_LUCKYMAN", "JT_SINDRAGOSA_REPORT")
            print(fakeEvent, ":", "fakeEvent=", fakeEvent)
            -- DevTools_Dump(suggestionList)
            -- DevTools_Dump(theOne)
            -- DevTools_Dump(reporterRollList)
            local finalReporter = getFinalReporter()
            if finalReporter then
                local sender = finalReporter.sender and (strsplit("-", finalReporter.sender) and strsplit("-", finalReporter.sender) or finalReporter.sender) or nil
                if sender == myName and aura_env.config.enableReport then

                    local saveGetChannel = getChannel
                    getChannel = function()
                        return "GUILD"
                    end

                    reportSuggestion()

                    getChannel = saveGetChannel
                end
            end
        end
    end
end

-- JT FAKE EVENT FUNCTION END

aura_env.OnTrigger = function(event, ...)
    if event == "ENCOUNTER_START" then
        local thisEncounterId = ...
        isInValidEncounter = isValidBoss(thisEncounterId)

        return OnEncounterStart(event, ...)
    elseif event == "JT_SINDRAGOSA_REPORT" then
        local finalReporter = getFinalReporter()

        if finalReporter then
            local sender = finalReporter.sender and (strsplit("-", finalReporter.sender) and strsplit("-", finalReporter.sender) or finalReporter.sender) or nil
            if sender == myName and aura_env.config.enableReport then
                reportSuggestion()
            end
        end
    elseif event == "CHAT_MSG_ADDON" then
        return receiveMessage(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- return OnGroupRosterUpdate()
    elseif event == "JT_WA_SINDRAGOSA_SENDLIST" then
        initData()
        buildMemberList()

        rollReporter()
        C_Timer.After(3, function()
            WeakAuras.ScanEvents("JT_SINDRAGOSA_REPORT")
        end)
        youCanShutUp()

    -- JT FAKE EVENT START
    elseif event == "JT_FAKE_EVENT" then
        OnJTFakeEvent(event, ...)
    -- JT FAKE EVENT END

    end
end