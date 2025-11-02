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

    -- -- JT FAKE EVENT START
    -- elseif event == "JT_FAKE_EVENT" then
    --     OnJTFakeEvent(event, ...)
    -- -- JT FAKE EVENT END

    end
end