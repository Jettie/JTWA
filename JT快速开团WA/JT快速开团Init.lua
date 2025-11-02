--版本信息
local version = 250813

--author and header
local AURA_ICON = 135922
local AURA_NAME = "JT快速开团WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local HELLO_WORLD = HEADER_TEXT.."- (|cffffffff白字/s说|r)频道输入 |cffffffff怎么开团|r 查看说明 - 作者:|R "..AUTHOR

print(HELLO_WORLD)

local myGUID = UnitGUID("player")
local myName = UnitName("player")

aura_env.saved = aura_env.saved or {}

local checkMeetingHorn = function()
    local meetingHornAddOnName = "MeetingHorn"
    local checkMeetingHornLoaded = IsAddOnLoaded(meetingHornAddOnName)
    if checkMeetingHornLoaded then
        local cMeetingHorn = LibStub("AceAddon-3.0"):GetAddon(meetingHornAddOnName)
        local cLFG = cMeetingHorn:GetModule('LFG')
---@diagnostic disable-next-line: undefined-field
        local cActivity = cMeetingHorn:GetClass('Activity')
        return checkMeetingHornLoaded, cMeetingHorn, cLFG, cActivity
    end
    return checkMeetingHornLoaded, nil, nil, nil
end

local isMeetingHornLoaded, meetingHorn, LFG, activity = checkMeetingHorn()

local myYY = aura_env.saved and aura_env.saved.myYY or nil

local lastSendYY = {}
local lastSendYYToEveryone = 0
local sendYYInterval = 60

local buildLastSendYYTable = function()
    -- 如果aura_env.config.enalbeSendYY为真，则1-25人每个人都发一次。如果为假，则只有每5人发一次
    if aura_env.config.enalbeSendYY == 1 then
        lastSendYYToEveryone = 0
        -- print(HEADER_TEXT.."有人进组就发YY")
    elseif aura_env.config.enalbeSendYY == 2 then
        for i = 1, 25 do
            if i % 5 == 0 then
                lastSendYY[i] = 0
            end
        end
        -- print(HEADER_TEXT.."每5人进组发一次YY")
    else
        -- print(HEADER_TEXT.."不再发送YY")
    end
end
buildLastSendYYTable()

local lastGroupNumbers = 0
local OnGroupRosterUpdate = function(event, ...)
    if not IsInRaid() then
        return
    end

    if not UnitIsGroupLeader("player") then
        return
    end

    local groupNumbers = GetNumGroupMembers()
    if groupNumbers <= lastGroupNumbers then
        return
    end
    lastGroupNumbers = groupNumbers

    local currentTime = GetTime()
    local thisText = ""
    local yyText = "本团YY:"..(myYY or "未设置").." "
    local waitText = "组团不易，请耐心等待。"
    local setText = (not myYY) and "聊天输入:设置我的YY YY号 即可设置" or ""
    if aura_env.config.enalbeSendYY == 1 then
        if currentTime - lastSendYYToEveryone > sendYYInterval then
            lastSendYYToEveryone = currentTime
            thisText = ONLY_TEXT..yyText..waitText..setText
            SendChatMessage(thisText, "RAID", nil, nil)
            return
        end
    elseif aura_env.config.enalbeSendYY == 2 then
        if lastSendYY[groupNumbers] then
            local lastSendTime = lastSendYY[groupNumbers]
            if currentTime - lastSendTime > sendYYInterval then
                lastSendYY[groupNumbers] = currentTime
                thisText = ONLY_TEXT..yyText..waitText..setText
                SendChatMessage(thisText, "RAID", nil, nil)
                return
            end
        end
    end
end

--[[
    1 纳克萨玛斯（25人）
    2 纳克萨玛斯（10人）
    3 黑曜石圣殿（25人）
    4 黑曜石圣殿（10人）
    5 永恒之眼（25人）
    6 永恒之眼（10人）
    7 阿尔卡冯的宝库（25人）
    8 阿尔卡冯的宝库（10人）
    9 奥杜尔（25人）
    10 奥杜尔（10人）
    11 十字军的试炼（25人）
    12 十字军的试炼（25人英雄）
    13 十字军的试炼（10人）
    14 十字军的试炼（10人英雄）
    15 奥妮克希亚的巢穴（25人）
    16 奥妮克希亚的巢穴（10人）
    17 冰冠堡垒（25人）
    18 冰冠堡垒（25人英雄）
    19 冰冠堡垒（10人）
    20 冰冠堡垒（10人英雄）
    21 红玉圣殿（25人）
    22 红玉圣殿（25人英雄）
    23 红玉圣殿（10人）
    24 红玉圣殿（10人英雄）
]]

--[[
|cffff53a2在喊话宏中，按照|cffffffff口令格式多一个空格|r即可自动创建集结号|r
|cffff53a2修改喊话宏时，也会|cffffffff自动更新集结号说明|r|r

|cff8fffa2在 |cffff4040喊话/Y|r 频道喊话
|cffff404025ICC SMTH速推团 来 FS LR FQ|r
即可在集结号的25人冰冠堡垒中快速开团

也可以在自己的喊话宏中按照口令格式写就可以自动开团
|cffffffff/Y 25ICC SMTH速推团 来 FS LR FQ|r

注意：自动开团需要在 |cfffff56925ICC|r |cffffffff口令后面加|r|cffff53a2一个空格|r才可以识别

各个团本口令如下|r
|cfffff56925H红玉|r 红玉圣殿（25人英雄）
|cfffff56910H红玉|r 红玉圣殿（10人英雄）
|cfffff56925红玉|r 红玉圣殿（25人）
|cfffff56910红玉|r 红玉圣殿（10人）

|cfffff56925HICC|r 冰冠堡垒（25人英雄）
|cfffff56910HICC|r 冰冠堡垒（10人英雄）
|cfffff56925ICC|r 冰冠堡垒（25人）
|cfffff56910ICC|r 冰冠堡垒（10人）

|cfffff56925HTOC|r 十字军的试炼（25人英雄）
|cfffff56910HTOC|r 十字军的试炼（10人英雄）
|cfffff56925TOC|r 十字军的试炼（25人）
|cfffff56910TOC|r 十字军的试炼（10人）

|cfffff56925宝库|r 阿尔卡冯的宝库（25人）
|cfffff56916宝库|r 阿尔卡冯的宝库（25人）
|cfffff56910宝库|r 阿尔卡冯的宝库（10人）

|cfffff56925黑龙|r 奥妮克希亚的巢穴（25人）
|cfffff56910黑龙|r 奥妮克希亚的巢穴（10人）

|cfffff569周常|r 任意周常
]]

local commandTextToInstanceNum = {
    -- 1 纳克萨玛斯（25人）
    ["25naxx"] = 1,
    ["25人naxx"] = 1,
    ["naxx25"] = 1,
    ["naxx25人"] = 1,
    -- 2 纳克萨玛斯（10人）
    ["10naxx"] = 2,
    ["10人naxx"] = 2,
    ["naxx10"] = 2,
    ["naxx10人"] = 2,
    -- 3 黑曜石圣殿（25人）
    ["25黑曜石"] = 3,
    ["25人黑曜石"] = 3,
    ["黑曜石25"] = 3,
    ["黑曜石25人"] = 3,
    -- 4 黑曜石圣殿（10人）
    ["10黑曜石"] = 4,
    ["10人黑曜石"] = 4,
    ["黑曜石10"] = 4,
    ["黑曜石10人"] = 4,
    -- 5 永恒之眼（25人）
    ["25蓝龙"] = 5,
    ["25人蓝龙"] = 5,
    ["蓝龙25"] = 5,
    ["蓝龙25人"] = 5,
    -- 6 永恒之眼（10人）
    ["10蓝龙"] = 6,
    ["10人蓝龙"] = 6,
    ["蓝龙10"] = 6,
    ["蓝龙10人"] = 6,
    -- 7 阿尔卡冯的宝库（25人）
    ["25宝库"] = 7,
    ["25人宝库"] = 7,
    ["宝库25"] = 7,
    ["宝库25人"] = 7,
    ["16宝库"] = 7,
    ["16人宝库"] = 7,
    ["宝库16"] = 7,
    ["宝库16人"] = 7,
    ["16精品宝库"] = 7,
    ["16人精品宝库"] = 7,
    ["精品宝库16"] = 7,
    ["精品宝库16人"] = 7,
    ["16精品"] = 7,
    ["16人精品"] = 7,
    ["精品16"] = 7,
    ["精品16人"] = 7,
    -- 8 阿尔卡冯的宝库（10人）
    ["10宝库"] = 8,
    ["10人宝库"] = 8,
    ["宝库10"] = 8,
    ["宝库10人"] = 8,
    -- 9 奥杜尔（25人）
    ["25uld"] = 9,
    ["25人uld"] = 9,
    ["uld25"] = 9,
    ["uld25人"] = 9,
    ["25奥杜尔"] = 9,
    ["25人奥杜尔"] = 9,
    ["奥杜尔25"] = 9,
    ["奥杜尔25人"] = 9,
    -- 10 奥杜尔（10人）
    ["10uld"] = 10,
    ["10人uld"] = 10,
    ["uld10"] = 10,
    ["uld10人"] = 10,
    ["10奥杜尔"] = 10,
    ["10人奥杜尔"] = 10,
    ["奥杜尔10"] = 10,
    ["奥杜尔10人"] = 10,
    -- 11 十字军的试炼（25人）
    ["25toc"] = 11,
    ["25人toc"] = 11,
    ["toc25"] = 11,
    ["toc25人"] = 11,
    -- 12 十字军的试炼（25人英雄）
    ["25htoc"] = 12,
    ["25人htoc"] = 12,
    ["htoc25"] = 12,
    ["htoc25人"] = 12,
    -- 13 十字军的试炼（10人）
    ["10toc"] = 13,
    ["10人toc"] = 13,
    ["toc10"] = 13,
    ["toc10人"] = 13,
    -- 14 十字军的试炼（10人英雄）
    ["10htoc"] = 14,
    ["10人htoc"] = 14,
    ["htoc10"] = 14,
    ["htoc10人"] = 14,
    -- 15 奥妮克希亚的巢穴（25人）
    ["25黑龙"] = 15,
    ["25人黑龙"] = 15,
    ["黑龙25"] = 15,
    ["黑龙25人"] = 15,
    -- 16 奥妮克希亚的巢穴（10人）
    ["10黑龙"] = 16,
    ["10人黑龙"] = 16,
    ["黑龙10"] = 16,
    ["黑龙10人"] = 16,
    ["周常"] = 16,
    -- 17 冰冠堡垒（25人）
    ["25icc"] = 17,
    ["25人icc"] = 17,
    ["icc25"] = 17,
    ["icc25人"] = 17,
    -- 18 冰冠堡垒（25人英雄）
    ["25hicc"] = 18,
    ["25人hicc"] = 18,
    ["hicc25"] = 18,
    ["hicc25人"] = 18,
    -- 19 冰冠堡垒（10人）
    ["10icc"] = 19,
    ["10人icc"] = 19,
    ["icc10"] = 19,
    ["icc10人"] = 19,
    -- 20 冰冠堡垒（10人英雄）
    ["10hicc"] = 20,
    ["10人hicc"] = 20,
    ["hicc10"] = 20,
    ["hicc10人"] = 20,
    -- 21 红玉圣殿（25人）
    ["25红玉"] = 21,
    ["25人红玉"] = 21,
    ["红玉25"] = 21,
    ["红玉25人"] = 21,
    ["25RS"] = 21,
    ["25人RS"] = 21,
    ["RS25"] = 21,
    ["RS25人"] = 21,
    -- 22 红玉圣殿（25人英雄）
    ["25h红玉"] = 22,
    ["25人h红玉"] = 22,
    ["h红玉25"] = 22,
    ["h红玉25人"] = 22,
    ["25hrs"] = 22,
    ["25人hrs"] = 22,
    ["hrs25"] = 22,
    ["hrs25人"] = 22,
    -- 23 红玉圣殿（10人）
    ["10红玉"] = 23,
    ["10人红玉"] = 23,
    ["红玉10"] = 23,
    ["红玉10人"] = 23,
    ["10rs"] = 23,
    ["10人rs"] = 23,
    ["rs10"] = 23,
    ["rs10人"] = 23,
    -- 24 红玉圣殿（10人英雄）
    ["10h红玉"] = 24,
    ["10人h红玉"] = 24,
    ["h红玉10"] = 24,
    ["h红玉10人"] = 24,
    ["10hrs"] = 24,
    ["10人hrs"] = 24,
    ["hrs10"] = 24,
    ["hrs10人"] = 24,
}

local modeId = 4 -- 1自强 2带薪 3ROLL 4AA 5才到 6传送 7其他

local channelNameOfLFG = {
    ["寻求组队"] = true,
    ["大脚世界频道"] = true,
}

-- 貌似发消息不灵 以后再试
local isInLFGChannel = function()
    local channels = {GetChannelList()}
    if not channels then
        return
    end
    for i = 1, #channels, 3 do
        local id = channels[i]
        local name = channels[i + 1]
        if channelNameOfLFG[name] then
            return id
        end
    end
end
local sendToTheOtherChannelDelayTime = 3
local sendSameMessageInTheOtherChannelDelayed = function(waitText)
    local channel = "CHANNEL"
    local channelId = isInLFGChannel()
    if channelId then
        local thisText = ONLY_TEXT..waitText
        -- print("after 3 seconds, send message to the other channel")
        -- print("waitText = ", thisText, "channel = ", channel, "channelId = ", channelId)
        C_Timer.After(sendToTheOtherChannelDelayTime, function()
            SendChatMessage(thisText, channel, nil, channelId)
        end)
    end
end

local OnYellOrLFGChannle = function(event, ...)
    local waitText, _, _, _, _, _, _, _, channelBaseName, _, _, GUID = ...
    if not aura_env.config.enableAutoCreate then return end
    if GUID == myGUID then --自己发的
        if event == "CHAT_MSG_CHANNEL" and not channelNameOfLFG[channelBaseName] then
            return
        end
        local lowerText = waitText:lower()
        local command, arg = strsplit(" ", lowerText)
        if commandTextToInstanceNum[command] then
            local instanceNum = commandTextToInstanceNum[command]
            if isMeetingHornLoaded then

---@diagnostic disable-next-line: undefined-field, need-check-nil
                local hasActivity = LFG:GetCurrentActivity()
---@diagnostic disable-next-line: undefined-field, need-check-nil
                LFG:CreateActivity(activity:New(instanceNum, modeId, waitText), true)
                if not hasActivity then
                    PlaySound(SOUNDKIT.IG_PLAYER_INVITE)
                    print(HEADER_TEXT.."已自动创建集结号团队")
                end
            end
        end
    end
end

local setYYCommand = {
    ["设置我的yy"] = true,
    ["设置yy"] = true,
}

local helpCommand = {
    ["怎么开团"] = true,
    ["如何开团"] = true,
}

local help = function()
    print(HEADER_TEXT.."在 |cffff4040喊话/Y|r 频道喊话|r")
    print(HEADER_TEXT.."|cffff404025ICC SMTH速推团 来 FS LR FQ|r")
    print(HEADER_TEXT.."即可在集结号的25人冰冠堡垒中快速开团")

    print(HEADER_TEXT.."也可以在自己的喊话宏中按照口令格式写就可以自动开团")
    print(HEADER_TEXT.."|cffffffff/Y 25ICC SMTH速推团 来 FS LR FQ|r")

    print(HEADER_TEXT.."注意：自动开团需要在 |cfffff56925ICC|r |cffffffff口令后面加|r|cffff53a2一个空格|r才可以识别")
end

local commandHandler = function(waitText)
    local command, arg = strsplit(" ", waitText)
    local lowerCommand = command:lower()
    if setYYCommand[lowerCommand] then
        local numInArgString = arg and arg:gsub("%D", "") or ""
        local numInArg = tonumber(numInArgString)
        if numInArg then
            myYY = numInArg
            aura_env.saved.myYY = numInArg
        end
        print(HEADER_TEXT.."已将YY设置为: |cff71d5ff"..(myYY or "未设置").."|r")
    elseif helpCommand[lowerCommand] then
        help()
    end
end

local OnMessageReceived = function(event, ...)
    if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_PARTY" or event =="CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" or event =="CHAT_MSG_RAID" or event =="CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_GUILD" then
        local waitText, _, _, _, _, _, _, _, _, _, _, GUID = ...
        if GUID == myGUID then
            return commandHandler(waitText)
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "CHAT_MSG_YELL" or event == "CHAT_MSG_CHANNEL" then
        return OnYellOrLFGChannle(event, ...)
    elseif event == "CHAT_MSG_SAY" or event == "CHAT_MSG_PARTY" or event =="CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" or event =="CHAT_MSG_RAID" or event =="CHAT_MSG_RAID_LEADER" then
        return OnMessageReceived(event, ...)
    elseif event == "GROUP_ROSTER_UPDATE" or "JT_GROUP_ROSTER_UPDATE" then
        return OnGroupRosterUpdate(event, ...)
    end
end
