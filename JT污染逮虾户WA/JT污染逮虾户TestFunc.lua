-- 版本信息 FAKE!!!!!!!!
local isFakeEventVersion = true
local fakeEventVersionText = "|cffff0000现在是FAKE版本 - 现在是FAKE版本 - 现在是FAKE版本 - 现在是FAKE版本 - 现在是FAKE版本|r"

if isFakeEventVersion then
    print(fakeEventVersionText)
    print(fakeEventVersionText)
    print(fakeEventVersionText)
    PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2)
end

local version = 250811

--author and header
local AURA_ICON = 133900
local AURA_NAME = "JT污染逮虾户WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local HELLO_WORLD = HEADER_TEXT.."- 看谁火箭鞋用的快 - 作者:|R "..AUTHOR

print(HELLO_WORLD)

aura_env.saved = aura_env.saved or {}

aura_env.displayText = HEADER_TEXT.."|r"
local timestampText = ""

local thisEncounterId = 0
local thisEncounterName = ""
local thisEncounterDifficultyId = 0
local thisEncounterGroupSize = 0

local isInValidEncounter = false
local validEncounterIds = {
    [856] = true, -- 巫妖王BOSS战
}

local lichkingNpcId = 36597

local combatStartTime = 0

local necroticPlagueSpellId = 70337 -- 死疽
local necroticPlagueName, _, necroticPlagueIcon = GetSpellInfo(necroticPlagueSpellId)
local defileSpellId = 72762 -- 污染
local defileName, _, defileIcon = GetSpellInfo(defileSpellId)
local defileCastTime = 2 -- 污染施法时间
local nitroBoostsBuffId = 54861 -- 工程火箭鞋
local nitroBoostsName = "火箭鞋"
local nitroBoostsIcon = select(3, GetSpellInfo(nitroBoostsBuffId))
local nitroBoostsCDTime = 180 -- 工程火箭鞋CD

local otherSpellIds = {
    -- 闪现术
    [1953] = GetSpellInfo(1953),
    -- 疾跑
    [11305] = GetSpellInfo(11305),
    -- 急奔
    [33357] = GetSpellInfo(33357),
}

local ignoreShortCDSpellIds = {
    -- 闪现术
    [1953] = true,
}

local logTypeIdToName = {
    [0] = "开战",
    [1] = necroticPlagueName,
    [2] = defileName,
    [3] = nitroBoostsName,
    [4] = "其他",
    [5] = nitroBoostsName.."CD"
}

local logTypeIdToIcon = {
    [1] = necroticPlagueIcon,
    [2] = defileIcon,
}

local currentType = 0 -- 当前阶段类型
local currentTypeStartTime = 0 -- 当前阶段开始时间
local lastSpellTargetGUID = nil -- 上次污染目标GUID

local dejavuLog = {} -- Main Log Table
local nitroBoostsCD = {} -- GUID = {name = "Jettie", cdTime = 12345}

-- allCounts[typeId] = count
local allCounts = {
    [0] = 0,
    [1] = 0,
    [2] = 0,
}

local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug : "..(text or "nil"))
    end
end

local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(DefileDejavu) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))

    --test data
    if JTDebug then

    end
end

local saveDejavuLog = function(encounterID, encounterName, difficultyID, groupSize, success)
    if not (#dejavuLog > 0) then
        return
    end

    local DATE_FORMAT = "%Y年%m月%d日 %H:%M:%S"
    local dateString = date(DATE_FORMAT)
    local theEncounterId = encounterID or 0
    local theEncounterName = encounterName or "未知战斗"
    local thisDifficultyID = difficultyID or 0
    local thisGroupSize = groupSize or 0
    local thisSuccess = success or 0

    local thisEncounterInfo = {
        dateString = dateString,

        data = dejavuLog,

        id = theEncounterId,
        name = theEncounterName,
        difficulty = thisDifficultyID,
        groupSize = thisGroupSize,
        success = thisSuccess,
    }

    -- 发WA事件存储历史数据
    if aura_env.config.enableHistory then
        WeakAuras.ScanEvents("JT_DEFILE_DEJAVU_HISTORY_DATA", thisEncounterInfo)
    end
end

local initData = function()
    aura_env.displayText = HEADER_TEXT.."|r"
    timestampText = ""
    WeakAuras.ScanEvents("JT_WA_DEFILE_DEJAVU_TIMESTAMPTEXT", timestampText)

    dejavuLog = {}
    nitroBoostsCD = {}
    allCounts = {
        [0] = 0,
        [1] = 0,
        [2] = 0,
    }
    currentType = 0 -- 当前阶段类型
    currentTypeStartTime = 0 -- 当前阶段开始时间
    lastSpellTargetGUID = nil -- 上次污染目标GUID
end

local isValidBoss = function()
    return validEncounterIds[thisEncounterId]
end

local iconStr = function(iconId)
	if iconId and type(iconId) == "number" then
		return "|T"..iconId..":12:12:0:0:64:64:4:60:4:60|t"
	else
		return ""
	end
end

local getDefileTarget = function()
    local getNpcIdFromGUID = function(guid)
        if not guid then
            return nil
        end
        local unitType, _, _, _, _, npcId = strsplit("-", guid)
        if unitType == "Creature" and npcId then
            return tonumber(npcId)
        end
        return nil
    end

    local commonUnit = {"target", "focus", "mouseover"}
    local bossUnit = {"boss1", "boss2", "boss3", "boss4", "boss5"}

    local getLichKingUnit = function()
        for _, unit in ipairs(commonUnit) do
            local guid = UnitGUID(unit)
            local npcId = getNpcIdFromGUID(guid)
            if npcId == lichkingNpcId then
                return unit
            end
        end
        for _, unit in ipairs(bossUnit) do
            local guid = UnitGUID(unit)
            local npcId = getNpcIdFromGUID(guid)
            if npcId == lichkingNpcId then
                return unit
            end
        end

        -- 遍历 1-40个nameplate，找到lichking
        for i = 1, 40 do
            local nameplateName = "nameplate".. i
            local guid = UnitGUID(nameplateName)
            local npcId = getNpcIdFromGUID(guid)
            if npcId == lichkingNpcId then
                return nameplateName
            end
        end
    end

    local lichkingUnit = getLichKingUnit()
    if not lichkingUnit then
        return nil
    end

    local lichkingTargetUnit = lichkingUnit.. "target"

    if UnitExists(lichkingTargetUnit) and (UnitInRaid(lichkingTargetUnit) or UnitInParty(lichkingTargetUnit)) then
        return lichkingTargetUnit
    end
    return nil
end

local toTimeString = function(time)
    local strTime = ""
    if (time <= 60) then
        strTime = string.format("0:%02d", time)
    elseif (time > 60) then
        strTime = string.format("%d:%02d", time / 60, time % 60)
    end
    return strTime
end

local toTimeStringWithHour = function(time)
    local hours = math.floor(time / 3600)
    local remaining = time % 3600
    local minutes = math.floor(remaining / 60)
    local seconds = remaining % 60

    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, seconds)
    else
        return string.format("%02d:%02d", minutes, seconds)
    end
end

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unitName, classId)
    if not unitName then return "" end
    if not classId then return unitName end
    local classStr = select(2,GetClassInfo(classId))
    if classStr then
        local classData = (RAID_CLASS_COLORS)[classStr]
        local coloredName = ("|c%s%s|r"):format(classData.colorStr, unitName)
        return coloredName
    elseif UnitExists(unitName) then
        local name = UnitName(unitName)
        local _, class = UnitClass(unitName)
        if not class then
            return name
        else
            local classData = (RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unitName
    end
end

local insertToLogAndDisplay = function(logTable)
    if not logTable then
        return
    end

    table.insert(dejavuLog, logTable)

    local thisText = ""

    local combatTimeText = logTable.combatTime and "|cff71d5ff"..toTimeString(logTable.combatTime).."|r" or ""

    local dashText = " - "
    local coloredDashText = "|cff1785d1"..dashText.."|r"
    local stageIconString = logTypeIdToIcon[logTable.stageType] and iconStr(logTypeIdToIcon[logTable.stageType]) or ""
    local stageNameText = logTypeIdToName[logTable.stageType] or ""
    local stageNumText = "#"..(logTable.stageTypeCount or "?")

    local compareTimeTextColor = logTable.compareTime <= 1.5 and "|cff8fffa2" or "|cffff53a2"
    local compareTimeText = logTable.compareTime and (compareTimeTextColor.."+"..(math.floor(logTable.compareTime * 100) / 100).."|rs") or ""
    local spellIconString = iconStr(select(3, GetSpellInfo(logTable.spellId)))
    local spellNameText = logTable.spellName or ""
    local sourceNameText = logTable.name and (logTable.sourceClassId and classColorName(logTable.name, logTable.sourceClassId) or logTable.name) or ""
    local destNameText = logTable.destName and "-> "..(logTable.destClassId and classColorName(logTable.destName, logTable.destClassId) or logTable.destName) or ""
    local spellTargetText = logTable.isSpellTarget and " (目标)" or ""

    local warningText = "|cffff53a2".."注意! CD!CD!".."|r"
    local cdTimeText = logTable.cdRemainingTime and ("CD(-"..toTimeString(logTable.cdRemainingTime)..")") or ""
    if logTable.type == 1 then
        thisText = coloredDashText..stageIconString..stageNameText..stageNumText.." ".. destNameText.. spellTargetText
    elseif logTable.type == 2 then
        thisText = coloredDashText..stageIconString..stageNameText..stageNumText.." ".. destNameText.. spellTargetText
    elseif logTable.type == 3 then
        thisText = coloredDashText..stageIconString..stageNameText..stageNumText.. " ".. compareTimeText.. " "..spellIconString..spellNameText.. " ".. sourceNameText..spellTargetText
    elseif logTable.type == 4 then
        -- 0:34 死疽#1 +1.02s 疾跑 -> 小丑杰罗姆
        thisText = coloredDashText..stageIconString..stageNameText..stageNumText.. " ".. compareTimeText.. " "..spellIconString..spellNameText.. " ".. sourceNameText..spellTargetText
    elseif logTable.type == 5 then
        -- 6:42 注意! CD!CD! 火箭鞋CD(1.00s) 污染#6 -> 脑袋中了九箭
        thisText = coloredDashText..warningText.." "..stageIconString..stageNameText..stageNumText.. " ".. spellIconString..spellNameText..cdTimeText.. " ".. sourceNameText..spellTargetText
    end
    aura_env.displayText = aura_env.displayText .. "\n" .. thisText

    timestampText = timestampText.."\n"..combatTimeText
    WeakAuras.ScanEvents("JT_WA_DEFILE_DEJAVU_TIMESTAMPTEXT", timestampText)
end

local OnCLEUF = function(...)
    if not isValidBoss() then
        -- print("not valid boss encounterId:", thisEncounterId)
        return
    else
        -- print("valid boss encounterId:", thisEncounterId)
    end
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if subevent == "SPELL_CAST_SUCCESS" then
        local spellId, spellName, spellSchool = select(12, ...)
        -- 死疽
        if spellId == necroticPlagueSpellId then
            local logType = 1
            currentType = 1
            allCounts[logType] = allCounts[logType] + 1
            lastSpellTargetGUID = destGUID

            local thisGUID = sourceGUID
            local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
            local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
            local thisName = shortSourceName

            local thisStageType = currentType
            local thisStageTypeCount = allCounts[thisStageType]

            local now = GetTime()
            local combatTime = now - combatStartTime
            currentTypeStartTime = now

            local thisLog = {
                type = logType,

                combatTime = combatTime,

                name = thisName,

                time = now,

                stageType = thisStageType,
                stageTypeCount = thisStageTypeCount,
                compareTime = 0,

                spellId = spellId,
                spellName = logTypeIdToName[logType],

                destName = shortDestName,
                destGUID = destGUID,
                destClassId = select(3, UnitClass(shortDestName)),
            }
            insertToLogAndDisplay(thisLog)
        end
    elseif subevent == "SPELL_CAST_START" then
        local spellId, spellName, spellSchool = select(12, ...)
        -- 污染
        if spellId == defileSpellId then
            local logType = 2
            currentType = 2
            allCounts[logType] = allCounts[logType] + 1
            lastSpellTargetGUID = nil

            local thisGUID = sourceGUID
            local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
            local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
            local thisName = shortSourceName

            local thisStageType = currentType
            local thisStageTypeCount = allCounts[thisStageType]

            local now = GetTime()
            local combatTime = now - combatStartTime
            currentTypeStartTime = now

            local thisLog = {
                type = logType,

                combatTime = combatTime,

                name = thisName,

                time = now,

                stageType = thisStageType,
                stageTypeCount = thisStageTypeCount,
                compareTime = 0,

                spellId = spellId,
                spellName = logTypeIdToName[logType],
            }

            C_Timer.After(0.3, function()
                WeakAuras.ScanEvents("JT_WA_DEFILE_TARGET_CHECK", thisLog)
            end)
        end
    elseif subevent == "SPELL_AURA_APPLIED" then
        local spellId, spellName, spellSchool = select(12, ...)
        -- 火箭鞋
        if spellId == nitroBoostsBuffId then
            local logType = 3
            local thisGUID = sourceGUID

            local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
            local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
            local thisName = shortSourceName
            local thisClassId = select(3, UnitClass(shortSourceName))

            local thisStageType = currentType
            local thisStageTypeCount = allCounts[thisStageType]

            local now = GetTime()
            local combatTime = now - combatStartTime
            local compareTime
            if currentType == 0 then
                compareTime = combatTime
            elseif currentType == 1 or currentType == 2 then
                compareTime = now - currentTypeStartTime
            end
            if not nitroBoostsCD[thisGUID] then
                nitroBoostsCD[thisGUID] = {
                    name = thisName,
                    sourceClassId = thisClassId,
                    cdTime = now + nitroBoostsCDTime,
                }
            else
                nitroBoostsCD[thisGUID].cdTime = now + nitroBoostsCDTime
            end

            local isSpellTarget = false
            if lastSpellTargetGUID and lastSpellTargetGUID == thisGUID then
                isSpellTarget = true
            end

            local thisLog = {
                type = logType,

                combatTime = combatTime,

                name = thisName,
                sourceClassId = thisClassId,

                time = now,

                stageType = thisStageType,
                stageTypeCount = thisStageTypeCount,
                compareTime = compareTime,

                spellId = spellId,
                spellName = logTypeIdToName[logType],

                isSpellTarget = isSpellTarget,
            }
            insertToLogAndDisplay(thisLog)
        elseif otherSpellIds[spellId] then
            local logType = 4
            local thisGUID = sourceGUID

            local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
            local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
            local thisName = shortSourceName
            local thisClassId = select(3, UnitClass(shortSourceName))

            local thisStageType = currentType
            local thisStageTypeCount = allCounts[thisStageType]

            local now = GetTime()
            local combatTime = now - combatStartTime
            local compareTime
            if currentType == 0 then
                compareTime = combatTime
            elseif currentType == 1 or currentType == 2 then
                compareTime = now - currentTypeStartTime
            end

            local isSpellTarget = false
            if lastSpellTargetGUID and lastSpellTargetGUID == thisGUID then
                isSpellTarget = true
            end

            -- 如果不是技能的目标，又是ignoreShortCDSpellIds中的技能，且技能施放时间大于6秒，则不再记录了
            if not isSpellTarget and compareTime > 6 and ignoreShortCDSpellIds[spellId] then
                return
            end

            local thisLog = {
                type = logType,

                combatTime = combatTime,

                name = thisName,
                sourceClassId = thisClassId,
                time = now,

                stageType = thisStageType,
                stageTypeCount = thisStageTypeCount,
                compareTime = compareTime,

                spellId = spellId,
                spellName = otherSpellIds[spellId],

                isSpellTarget = isSpellTarget,
            }
            insertToLogAndDisplay(thisLog)
        end
    end
    return true
end

local OnJTWADefileTargetCheck = function(...)
    local thisLog = ...
    local defileTargetNitroBoostsCDLog = nil
    local defileTargetUnit = getDefileTarget()
    if defileTargetUnit and UnitExists(defileTargetUnit) then
        local defileTargetName = UnitName(defileTargetUnit)
        local defileTargetGUID = UnitGUID(defileTargetUnit)
        local defileTargetClassId = select(3, UnitClass(defileTargetName))

        lastSpellTargetGUID = defileTargetGUID

        thisLog.destName = defileTargetName
        thisLog.destGUID = defileTargetGUID
        thisLog.destClassId = defileTargetClassId

        local now = GetTime()
        if defileTargetGUID and nitroBoostsCD[defileTargetGUID] and nitroBoostsCD[defileTargetGUID].cdTime > now then
            local logType = 5
            local thisName = defileTargetName
            local thisClassId = defileTargetClassId
            local thisStageType = 2
            local thisStageTypeCount = allCounts[thisStageType]
            local combatTime = now - combatStartTime
            local compareTime = 0
            local spellId = nitroBoostsBuffId
            local spellName = nitroBoostsName
            local isSpellTarget = true

            local cdRemainingTime = nitroBoostsCD[defileTargetGUID].cdTime - now

            defileTargetNitroBoostsCDLog = {
                type = logType,
                combatTime = combatTime,
                name = thisName,
                sourceClassId = thisClassId,
                time = GetTime(),
                stageType = thisStageType,
                stageTypeCount = thisStageTypeCount,
                compareTime = compareTime,
                spellId = spellId,
                spellName = spellName,
                isSpellTarget = isSpellTarget,

                cdRemainingTime = cdRemainingTime,
            }
        end
    end
    insertToLogAndDisplay(thisLog)
    if defileTargetNitroBoostsCDLog then
        insertToLogAndDisplay(defileTargetNitroBoostsCDLog)
    end
    return true
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

local reportDejavuLog = function()
    local reportTextTable = {}
    if #dejavuLog > 0 then
        local titleLine = "===="..ONLY_TEXT.."===="
        table.insert(reportTextTable, titleLine)
        for i, log in ipairs(dejavuLog) do
            local thisText = ""
            local combatTimeText = log.combatTime and toTimeString(log.combatTime) or ""
            local dashText = " - "
            local coloredDashText = "|cff1785d1"..dashText.."|r"
            local stageIconString = logTypeIdToIcon[log.stageType] and iconStr(logTypeIdToIcon[log.stageType]) or ""
            local stageNameText = logTypeIdToName[log.stageType] or ""
            local stageNumText = "#"..(log.stageTypeCount or "?")
            local compareTimeTextColor = log.compareTime <= 1.5 and "|cff8fffa2" or "|cffff53a2"
            local compareTimeText = log.compareTime and ("+"..(math.floor(log.compareTime * 100) / 100).."s") or ""
            local spellIconString = iconStr(select(3, GetSpellInfo(log.spellId)))
            local spellNameText = log.spellName or ""
            local sourceNameText = log.name and log.name or ""
            local destNameText = log.destName and "-> "..log.destName or ""
            local spellTargetText = log.isSpellTarget and " (目标)" or ""
            local warningText = "注意! CD!CD!"
            local cdTimeText = log.cdRemainingTime and ("CD(-"..toTimeString(log.cdRemainingTime)..")") or ""
            if log.type == 1 then
                thisText = combatTimeText..dashText..stageNameText..stageNumText.." ".. destNameText.. spellTargetText
            elseif log.type == 2 then
                thisText = combatTimeText..dashText..stageNameText..stageNumText.." ".. destNameText.. spellTargetText
            elseif log.type == 3 then
                thisText = combatTimeText..dashText..stageNameText..stageNumText.. " ".. compareTimeText.. " "..spellNameText.. " ".. sourceNameText..spellTargetText
            elseif log.type == 4 then
                -- 0:34 死疽#1 +1.02s 疾跑 -> 小丑杰罗姆
                thisText = combatTimeText..dashText..stageNameText..stageNumText.. " ".. compareTimeText.. " "..spellNameText.. " ".. sourceNameText..spellTargetText
            elseif log.type == 5 then
                -- 6:42 注意! CD!CD! 火箭鞋CD(1.00s) 污染#6 -> 脑袋中了九箭
                thisText = combatTimeText..dashText..warningText.." "..stageNameText..stageNumText.. " ".. spellNameText..cdTimeText.. " ".. sourceNameText..spellTargetText
            end
            table.insert(reportTextTable, thisText)
        end
        table.insert(reportTextTable, titleLine)
    end

    if JTDebug then
        DevTools_Dump(reportTextTable)
    end

    sendMsgToRaidOrGroup(reportTextTable)
end

-- JT FAKE EVENT FUNCTION START

--[[

0:33 死疽#1 -> 小丑杰罗姆
43.8828-44.8968=-1.014s
0:34 死疽#1 +1.02s 疾跑 -> 小丑杰罗姆

1:04 死疽#2 -> 云清揚
14.5658-15.8918=-1.326s
1:06 死疽#2 +1.33 火箭鞋 -> 云清揚

1:35 死疽#3 -> 蛋总会划船
45.2878-46.2588=-0.971s
1:36 死疽#3 +0.97s 火箭鞋 -> 蛋总会划船

2:09 死疽#4 -> 咸鱼不翻身
19.2988-20.8848=-1.586s
2:11 死疽#4 +1.59 火箭鞋 -> 咸鱼不翻身

3:59 污染#1 -> 百分百圣佑
09.3278-10.3208=-0.993s
4:00 污染#1 +0.99s 火箭鞋 -> 百分百圣佑

4:31 污染#2 -> 小渊
41.6948-42.5828=-0.888s
4:32 污染#2 +0.89s 火箭鞋 -> 小渊

5:04 污染#3 -> 脑袋中了九箭
14.0948-15.1398=-1.045s
5:05 污染#3 +1.05s 火箭鞋 -> 脑袋中了九箭

5:36 污染#4 -> 咸鱼不翻身

6:08 污染#5 -> 伊邪娜羙
18.8118-19.7988=-0.987s
6:09 污染#5 +0.99s 火箭鞋 -> 伊邪娜羙

6:42 污染#6 -> 脑袋中了九箭
6:42 注意! CD!CD! 火箭鞋CD(1.00s) 污染#6 -> 脑袋中了九箭
52.8058-57.2168=-4.411s
6:47 污染#6 +4.41s 火箭鞋 -> 玉泉生辉
52.8058-59.3038=-6.498s
6:49 污染#6 +6.50s 火箭鞋 -> 强效王者祝福

8/6/2025 21:53:43.8828  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,70337,"死疽",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,93586773,103151165,0,0,0,0,0,-1,0,0,0,472.27,-2106.50,192,5.7653,83
8/6/2025 21:53:44.8968  SPELL_AURA_APPLIED,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,11305,"疾跑",0x1,BUFF
8/6/2025 21:53:44.8978  SPELL_CAST_SUCCESS,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,0000000000000000,nil,0x80000000,0x80000000,11305,"疾跑",0x1,Player-4533-077ED21C,0000000000000000,98,100,7659,612,12061,0,0,3,55,100,0,470.84,-2106.83,192,5.9671,260
8/6/2025 21:53:46.4628  SPELL_DISPEL,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,51886,"净化灵魂",0x8,70337,"死疽",32,DEBUFF

8/6/2025 21:54:14.5658  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,70337,"死疽",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,86854159,103151165,0,0,0,0,0,-1,0,0,0,493.06,-2109.76,192,6.1468,83
8/6/2025 21:54:15.8918  SPELL_AURA_APPLIED,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF
8/6/2025 21:54:17.1928  SPELL_DISPEL_FAILED,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,51886,"净化灵魂",0x8,70337,"死疽",32

8/6/2025 21:54:45.2878  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,70337,"死疽",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,80711892,103151165,0,0,0,0,0,-1,0,0,0,523.21,-2110.71,192,6.1355,83
8/6/2025 21:54:46.2588  SPELL_AURA_APPLIED,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF
8/6/2025 21:54:47.5018  SPELL_DISPEL,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,51886,"净化灵魂",0x8,70337,"死疽",32,DEBUFF

8/6/2025 21:55:19.2988  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Player-4533-0586EBA6,"咸鱼不翻身-维希度斯-CN",0x80000514,0x80000000,70337,"死疽",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,73393684,103151165,0,0,0,0,0,-1,0,0,0,533.85,-2110.40,192,2.2660,83
8/6/2025 21:55:20.8848  SPELL_AURA_APPLIED,Player-4533-0586EBA6,"咸鱼不翻身-维希度斯-CN",0x80000514,0x80000000,Player-4533-0586EBA6,"咸鱼不翻身-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF
8/6/2025 21:55:22.3258  SPELL_DISPEL,Player-4533-06341104,"蛋总会划船-维希度斯-CN",0x80000514,0x80000000,Player-4533-0586EBA6,"咸鱼不翻身-维希度斯-CN",0x80000514,0x80000000,51886,"净化灵魂",0x8,70337,"死疽",32,DEBUFF


8/6/2025 21:57:09.3278  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
8/6/2025 21:57:09.5168  EMOTE,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",巫妖王开始施展污染！

8/6/2025 21:57:10.3208  SPELL_AURA_APPLIED,Player-4533-0658ADB2,"百分百圣佑-维希度斯-CN",0x80000512,0x80000040,Player-4533-0658ADB2,"百分百圣佑-维希度斯-CN",0x80000512,0x80000040,54861,"硝化甘油推进器",0x1,BUFF

8/6/2025 21:57:11.3318  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,68479682,103151165,0,0,0,0,0,-1,0,0,0,524.85,-2136.19,192,3.2910,83
8/6/2025 21:57:11.3318  SPELL_SUMMON,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,Creature-0-4891-631-12167-38757-0000135F37,"污浊者",0x80000a28,0x80000000,72762,"污染",0x20



8/6/2025 21:57:41.6948  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
8/6/2025 21:57:41.8708  EMOTE,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",巫妖王开始施展污染！

8/6/2025 21:57:42.5828  SPELL_AURA_APPLIED,Player-4533-0738FC6F,"小渊-维希度斯-CN",0x80000514,0x80000040,Player-4533-0738FC6F,"小渊-维希度斯-CN",0x80000514,0x80000040,54861,"硝化甘油推进器",0x1,BUFF

8/6/2025 21:57:43.7038  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,64144976,103151165,0,0,0,0,0,-1,0,0,0,504.93,-2123.94,192,6.0218,83
8/6/2025 21:57:43.7038  SPELL_SUMMON,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Creature-0-4891-631-12167-38757-0000135F57,"污浊者",0x80000a28,0x80000000,72762,"污染",0x20



8/6/2025 21:58:14.0948  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
8/6/2025 21:58:14.2658  EMOTE,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",巫妖王开始施展污染！

8/6/2025 21:58:15.1398  SPELL_AURA_APPLIED,Player-4533-0616E6A9,"脑袋中了九箭-维希度斯-CN",0x80000512,0x80000040,Player-4533-0616E6A9,"脑袋中了九箭-维希度斯-CN",0x80000512,0x80000040,54861,"硝化甘油推进器",0x1,BUFF

8/6/2025 21:58:16.0808  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,59783570,103151165,0,0,0,0,0,-1,0,0,0,507.22,-2120.79,192,0.0297,83
8/6/2025 21:58:16.0808  SPELL_SUMMON,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Creature-0-4891-631-12167-38757-0000135F78,"污浊者",0x80000a28,0x80000000,72762,"污染",0x20



8/6/2025 21:58:46.4258  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
8/6/2025 21:58:46.6078  EMOTE,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",巫妖王开始施展污染！

8/6/2025 21:58:49.4318  SPELL_DAMAGE,Creature-0-4891-631-12167-38757-0000135F98,"污浊者",0x80000a48,0x80000000,Player-4533-0586EBA6,"咸鱼不翻身-维希度斯-CN",0x80000514,0x80000040,72754,"污染",0x20,Player-4533-0586EBA6,0000000000000000,77,100,1758,5609,22015,0,0,0,30030,31191,0,485.68,-2137.02,192,4.3727,264,6790,10000,-1,32,3000,0,0,nil,nil,nil,AOE
8/6/2025 21:58:49.4318  SPELL_AURA_APPLIED,Creature-0-4891-631-12167-38757-0000135F98,"污浊者",0x80000a48,0x80000000,Player-4533-0586EBA6,"咸鱼不翻身-维希度斯-CN",0x80000514,0x80000040,72754,"污染",0x20,DEBUFF

8/6/2025 21:58:48.4368  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,55585261,103151165,0,0,0,0,0,-1,0,0,0,520.79,-2137.62,192,2.8323,83
8/6/2025 21:58:48.4368  SPELL_SUMMON,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Creature-0-4891-631-12167-38757-0000135F98,"污浊者",0x80000a28,0x80000000,72762,"污染",0x20



8/6/2025 21:59:18.8118  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
8/6/2025 21:59:19.0138  EMOTE,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",巫妖王开始施展污染！

8/6/2025 21:59:19.7988  SPELL_AURA_APPLIED,Player-4533-03A596FC,"伊邪娜羙-维希度斯-CN",0x80000514,0x80000040,Player-4533-03A596FC,"伊邪娜羙-维希度斯-CN",0x80000514,0x80000040,54861,"硝化甘油推进器",0x1,BUFF

8/6/2025 21:59:20.8108  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,50019326,103151165,0,0,0,0,0,-1,0,0,0,505.35,-2125.83,192,5.9674,83
8/6/2025 21:59:20.8108  SPELL_SUMMON,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,Creature-0-4891-631-12167-38757-0000135FB8,"污浊者",0x80000a28,0x80000000,72762,"污染",0x20




8/6/2025 21:59:52.8058  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
8/6/2025 21:59:52.9998  EMOTE,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",巫妖王开始施展污染！

脑袋中了九箭

8/6/2025 21:59:54.8178  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,47083891,103151165,0,0,0,0,0,-1,0,0,0,500.29,-2124.92,192,5.3668,83
8/6/2025 21:59:54.8178  SPELL_SUMMON,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Creature-0-4891-631-12167-38757-0000135FDA,"污浊者",0x80000a28,0x80000000,72762,"污染",0x20

8/6/2025 21:59:57.2168  SPELL_AURA_APPLIED,Player-4533-04F36A75,"玉泉生辉-维希度斯-CN",0x80000514,0x80000000,Player-4533-04F36A75,"玉泉生辉-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF

8/6/2025 21:59:59.3038  SPELL_AURA_APPLIED,Player-4533-078B33C8,"强效王者祝福-维希度斯-CN",0x80000514,0x80000000,Player-4533-078B33C8,"强效王者祝福-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF

0:21 开战#0 +21s 火箭鞋 -> Jep

0:33 死疽#1 -> 小丑杰罗姆
0:34 死疽#1 +1.02s 疾跑 -> 小丑杰罗姆

1:04 死疽#2 -> 云清揚
1:06 死疽#2 +1.33 火箭鞋 -> 云清揚

1:35 死疽#3 -> 蛋总会划船
1:36 死疽#3 +0.97s 火箭鞋 -> 蛋总会划船

2:09 死疽#4 -> 咸鱼不翻身
2:11 死疽#4 +1.59 火箭鞋 -> 咸鱼不翻身

3:59 污染#1 -> 百分百圣佑
4:00 污染#1 +0.99s 火箭鞋 -> 百分百圣佑

4:31 污染#2 -> 小渊
4:32 污染#2 +0.89s 火箭鞋 -> 小渊

5:04 污染#3 -> 脑袋中了九箭
5:05 污染#3 +1.05s 火箭鞋 -> 脑袋中了九箭

5:36 污染#4 -> 咸鱼不翻身

6:08 污染#5 -> 伊邪娜羙
6:09 污染#5 +0.99s 火箭鞋 -> 伊邪娜羙

6:42 污染#6 -> 脑袋中了九箭
6:42 注意! CD!CD! 火箭鞋CD(1.00s) 污染#6 -> 脑袋中了九箭
6:47 污染#6 +4.41s 火箭鞋 -> 玉泉生辉
6:49 污染#6 +6.50s 火箭鞋 -> 强效王者祝福

]]



--[[ Test Macros

/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","ENCOUNTER_START",856)

8/6/2025 21:59:59.3038  SPELL_AURA_APPLIED,Player-4533-078B33C8,"强效王者祝福-维希度斯-CN",0x80000514,0x80000000,Player-4533-078B33C8,"强效王者祝福-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_AURA_APPLIED",nil,"Player-4533-078B33C8","强效王者祝福-维希度斯-CN","","","Player-4533-078B33C8","强效王者祝福-维希度斯-CN","","",54861,"推进器")
8/6/2025 21:53:43.8828  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,70337,"死疽",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,93586773,103151165,0,0,0,0,0,-1,0,0,0,472.27,-2106.50,192,5.7653,83
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_CAST_SUCCESS",nil,"Creature-0-4891-631-12167-36597-0000135D20","巫妖王","","","Player-4533-077ED21C","小丑杰罗姆-维希度斯-CN","","",70337,"死疽")
8/6/2025 21:53:44.8978  SPELL_CAST_SUCCESS,Player-4533-077ED21C,"小丑杰罗姆-维希度斯-CN",0x80000514,0x80000000,0000000000000000,nil,0x80000000,0x80000000,11305,"疾跑",0x1,Player-4533-077ED21C,0000000000000000,98,100,7659,612,12061,0,0,3,55,100,0,470.84,-2106.83,192,5.9671,260
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_AURA_APPLIED",nil,"Player-4533-077ED21C","小丑杰罗姆-维希度斯-CN","","","0000000000000000",nil,nil,nil,11305,"疾跑",0x1)

8/6/2025 21:54:14.5658  SPELL_CAST_SUCCESS,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,70337,"死疽",0x20,Creature-0-4891-631-12167-36597-0000135D20,0000000000000000,86854159,103151165,0,0,0,0,0,-1,0,0,0,493.06,-2109.76,192,6.1468,83
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_CAST_SUCCESS",nil,"Creature-0-4891-631-12167-36597-0000135D20","巫妖王","","","Player-4533-0589E0E5","云清揚-维希度斯-CN","","",70337,"死疽")
8/6/2025 21:54:15.8918  SPELL_AURA_APPLIED,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,Player-4533-0589E0E5,"云清揚-维希度斯-CN",0x80000514,0x80000000,54861,"硝化甘油推进器",0x1,BUFF
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_AURA_APPLIED",nil,"Player-4533-0589E0E5","云清揚-维希度斯-CN","","","Player-4533-0589E0E5","云清揚-维希度斯-CN",nil,nil,54861,"硝化甘油推进器")


8/6/2025 21:57:09.3278  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80000a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_CAST_START",nil,"Creature-0-4891-631-12167-36597-0000135D20","巫妖王","","","0000000000000000",nil,"","",72762,"污染")

8/6/2025 21:57:10.3208  SPELL_AURA_APPLIED,Player-4533-0658ADB2,"百分百圣佑-维希度斯-CN",0x80000512,0x80000040,Player-4533-0658ADB2,"百分百圣佑-维希度斯-CN",0x80000512,0x80000040,54861,"硝化甘油推进器",0x1,BUFF
8/6/2025 21:57:10.3208  SPELL_AURA_APPLIED,Player-4533-05C507B1,"Jsm-维希度斯-CN",0x80000512,0x80000040,Player-4533-05C507B1,"Jsm-维希度斯-CN",0x80000512,0x80000040,54861,"硝化甘油推进器",0x1,BUFF

/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_AURA_APPLIED",nil,"Player-4533-05C507B1","Jsm-维希度斯-CN","","","Player-4533-05C507B1","Jsm-维希度斯-CN",nil,nil,54861,"推进器")

8/6/2025 21:57:41.6948  SPELL_CAST_START,Creature-0-4891-631-12167-36597-0000135D20,"巫妖王",0x80010a48,0x80000000,0000000000000000,nil,0x80000000,0x80000000,72762,"污染",0x20
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_CAST_START",nil,"Creature-0-4891-631-12167-36597-0000135D20","巫妖王","","","0000000000000000",nil,"","",72762,"污染")

8/6/2025 21:57:42.5828  SPELL_AURA_APPLIED,Player-4533-0738FC6F,"小渊-维希度斯-CN",0x80000514,0x80000040,Player-4533-0738FC6F,"小渊-维希度斯-CN",0x80000514,0x80000040,54861,"硝化甘油推进器",0x1,BUFF
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"SPELL_AURA_APPLIED",nil,"Player-4533-0738FC6F","小渊-维希度斯-CN","","","Player-4533-0738FC6F","小渊-维希度斯-CN",nil,nil,54861,"推进器")


/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","CLEU",time(),"UNIT_DIED",nil,"0000000000000000",nil,nil,nil,"Player-4533-0582AD62","我是死人坦克-维希度斯-CN")
/run WeakAuras.ScanEvents("JT_FAKE_EVENT","DEFILE_DEJAVU","ENCOUNTER_END",856,"JT测试巫妖王",4,25,true)

]]
local thisWATag = "DEFILE_DEJAVU"
local OnJTFakeEvent = function(event, ...)
    -- 由于是FAKE EVENT 所以导致...都需要在select后+2，select(3, ...)
    local waTag, fakeEvent = ...
    if waTag == thisWATag then
        print("FAKE EVENT: ", "waTag=", waTag, "fakeEvent=", fakeEvent)
        if fakeEvent == "CLEU" then
            local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, arg12, _, _, arg15, arg16, _, _, arg19 = select(3, ...)
            -- print("FAKE EVENT: ", "fakeEvent=", fakeEvent, "timestamp=", timestamp, "subevent=", subevent, "sourceGUID=", sourceGUID, "sourceName=", sourceName, "destGUID=", destGUID, "destName=", destName, "arg12=", arg12, "arg15=", arg15, "arg16=", arg16, "arg19=", arg19)

            if subevent == "SPELL_CAST_SUCCESS" then
                local spellId, spellName, spellSchool = select(14, ...)
                print("FAKE EVENT: ", "fakeEvent=", fakeEvent, "sourceName=", sourceName, "destName=", destName, "spellId=", spellId, "spellName=", spellName)
                -- 死疽
                if spellId == necroticPlagueSpellId then
                    local logType = 1
                    currentType = 1
                    allCounts[logType] = allCounts[logType] + 1
                    lastSpellTargetGUID = destGUID

                    local thisGUID = sourceGUID
                    local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
                    local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
                    local thisName = shortSourceName

                    local thisStageType = currentType
                    local thisStageTypeCount = allCounts[thisStageType]

                    local now = GetTime()
                    local combatTime = now - combatStartTime
                    currentTypeStartTime = now

                    local thisLog = {
                        type = logType,

                        combatTime = combatTime,

                        name = thisName,

                        time = now,

                        stageType = thisStageType,
                        stageTypeCount = thisStageTypeCount,
                        compareTime = 0,

                        spellId = spellId,
                        spellName = logTypeIdToName[logType],

                        destName = shortDestName,
                        destGUID = destGUID,
                        destClassId = select(3, UnitClass(shortDestName)),
                    }
                    insertToLogAndDisplay(thisLog)
                end
            elseif subevent == "SPELL_CAST_START" then
                local spellId, spellName, spellSchool = select(14, ...)
                print("FAKE EVENT: ", "fakeEvent=", fakeEvent, "sourceName=", sourceName, "destName=", destName, "spellId=", spellId, "spellName=", spellName)
                -- 污染
                if spellId == defileSpellId then
                    local logType = 2
                    currentType = 2
                    allCounts[logType] = allCounts[logType] + 1
                    lastSpellTargetGUID = nil

                    local thisGUID = sourceGUID
                    local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
                    local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
                    local thisName = shortSourceName

                    local thisStageType = currentType
                    local thisStageTypeCount = allCounts[thisStageType]

                    local now = GetTime()
                    local combatTime = now - combatStartTime
                    currentTypeStartTime = now

                    local thisLog = {
                        type = logType,

                        combatTime = combatTime,

                        name = thisName,

                        time = now,

                        stageType = thisStageType,
                        stageTypeCount = thisStageTypeCount,
                        compareTime = 0,

                        spellId = spellId,
                        spellName = logTypeIdToName[logType],
                    }

                    C_Timer.After(0.3, function()
                        WeakAuras.ScanEvents("JT_FAKE_EVENT", "DEFILE_DEJAVU", "JT_WA_DEFILE_TARGET_CHECK", thisLog)
                    end)
                end
            elseif subevent == "SPELL_AURA_APPLIED" then
                local spellId, spellName, spellSchool = select(14, ...)
                print("FAKE EVENT: ", "fakeEvent=", fakeEvent, "sourceName=", sourceName, "destName=", destName, "spellId=", spellId, "spellName=", spellName)
                -- 火箭鞋
                if spellId == nitroBoostsBuffId then
                    local logType = 3
                    local thisGUID = sourceGUID

                    local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
                    local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
                    local thisName = shortSourceName
---@diagnostic disable-next-line: param-type-mismatch
                    local thisClassId = select(3, UnitClass(shortSourceName))

                    local thisStageType = currentType
                    local thisStageTypeCount = allCounts[thisStageType]

                    local now = GetTime()
                    local combatTime = now - combatStartTime
                    local compareTime
                    if currentType == 0 then
                        compareTime = combatTime
                    elseif currentType == 1 or currentType == 2 then
                        compareTime = now - currentTypeStartTime
                    end
                    if not nitroBoostsCD[thisGUID] then
---@diagnostic disable-next-line: need-check-nil
                        nitroBoostsCD[thisGUID] = {
                            name = thisName,
                            sourceClassId = thisClassId,
                            cdTime = now + nitroBoostsCDTime,
                        }
                    else
                        nitroBoostsCD[thisGUID].cdTime = now + nitroBoostsCDTime
                    end

                    local isSpellTarget = false
                    if lastSpellTargetGUID and lastSpellTargetGUID == thisGUID then
                        isSpellTarget = true
                    end

                    local thisLog = {
                        type = logType,

                        combatTime = combatTime,

                        name = thisName,
                        sourceClassId = thisClassId,

                        time = now,

                        stageType = thisStageType,
                        stageTypeCount = thisStageTypeCount,
                        compareTime = compareTime,

                        spellId = spellId,
                        spellName = logTypeIdToName[logType],

                        isSpellTarget = isSpellTarget,
                    }
                    insertToLogAndDisplay(thisLog)
                elseif otherSpellIds[spellId] then
                    local logType = 4
                    local thisGUID = sourceGUID

                    local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or "神仙"
                    local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or "神仙"
                    local thisName = shortSourceName
---@diagnostic disable-next-line: param-type-mismatch
                    local thisClassId = select(3, UnitClass(shortSourceName))

                    local thisStageType = currentType
                    local thisStageTypeCount = allCounts[thisStageType]

                    local now = GetTime()
                    local combatTime = now - combatStartTime
                    local compareTime
                    if currentType == 0 then
                        compareTime = combatTime
                    elseif currentType == 1 or currentType == 2 then
                        compareTime = now - currentTypeStartTime
                    end

                    local isSpellTarget = false
                    if lastSpellTargetGUID and lastSpellTargetGUID == thisGUID then
                        isSpellTarget = true
                    end

                    -- 如果不是技能的目标，又是ignoreShortCDSpellIds中的技能，且技能施放时间大于6秒，则不再记录了
                    if not isSpellTarget and compareTime > 6 and ignoreShortCDSpellIds[spellId] then
                        return
                    end

                    local thisLog = {
                        type = logType,

                        combatTime = combatTime,

                        name = thisName,
                        sourceClassId = thisClassId,
                        time = now,

                        stageType = thisStageType,
                        stageTypeCount = thisStageTypeCount,
                        compareTime = compareTime,

                        spellId = spellId,
                        spellName = otherSpellIds[spellId],

                        isSpellTarget = isSpellTarget,
                    }
                    insertToLogAndDisplay(thisLog)
                end
            end
            return true
        elseif fakeEvent == "JT_WA_DEFILE_TARGET_CHECK" then
            local thisLog = select(3, ...)
            local defileTargetNitroBoostsCDLog = nil
            local defileTargetUnit = getDefileTarget()
            -- if defileTargetUnit and UnitExists(defileTargetUnit) then
            if true then
                -- local defileTargetName = UnitName(defileTargetUnit)
                -- local defileTargetGUID = UnitGUID(defileTargetUnit)
                -- local defileTargetClassId = select(3, UnitClass(defileTargetName))

                local defileTargetName = "Jsm"
                local defileTargetGUID = "Player-4533-05C507B1"
                local defileTargetClassId = 7

                lastSpellTargetGUID = defileTargetGUID

                thisLog.destName = defileTargetName
                thisLog.destGUID = defileTargetGUID
                thisLog.destClassId = defileTargetClassId

                local now = GetTime()
                if defileTargetGUID and nitroBoostsCD[defileTargetGUID] and nitroBoostsCD[defileTargetGUID].cdTime > now then
                    print("找到CD记录")
                    local logType = 5
                    local thisName = defileTargetName
                    local thisClassId = defileTargetClassId
                    local thisStageType = 2
                    local thisStageTypeCount = allCounts[thisStageType]
                    local combatTime = now - combatStartTime
                    local compareTime = 0
                    local spellId = nitroBoostsBuffId
                    local spellName = nitroBoostsName
                    local isSpellTarget = true

                    local cdRemainingTime = nitroBoostsCD[defileTargetGUID].cdTime - now

                    defileTargetNitroBoostsCDLog = {
                        type = logType,
                        combatTime = combatTime,
                        name = thisName,
                        sourceClassId = thisClassId,
                        time = GetTime(),
                        stageType = thisStageType,
                        stageTypeCount = thisStageTypeCount,
                        compareTime = compareTime,
                        spellId = spellId,
                        spellName = spellName,
                        isSpellTarget = isSpellTarget,

                        cdRemainingTime = cdRemainingTime,
                    }
                end
            end
            insertToLogAndDisplay(thisLog)
            if defileTargetNitroBoostsCDLog then
                insertToLogAndDisplay(defileTargetNitroBoostsCDLog)
            end
            return true
        elseif fakeEvent == "ENCOUNTER_START" then
            -- /run WeakAuras.ScanEvents("JT_FAKE_EVENT", "PARRY_KILLER", "ENCOUNTER_START", 855)
            print("ENCOUNTER_START: ", "fakeEvent=", fakeEvent)
            local encounterID, encounterName, difficultyID, groupSize = select(3, ...)

---@diagnostic disable-next-line: cast-local-type
            thisEncounterId, thisEncounterName, thisEncounterDifficultyId, thisEncounterGroupSize = encounterID, encounterName, difficultyID, groupSize
            isInValidEncounter = isValidBoss()

            if isInValidEncounter then
                combatStartTime = GetTime()
                initData()
                return true
            end
        elseif fakeEvent == "ENCOUNTER_END" then
            local encounterID, encounterName, difficultyID, groupSize, success = select(3, ...)
            if thisEncounterId == encounterID then
                thisEncounterId = 0
                isInValidEncounter = isValidBoss()
                saveDejavuLog(encounterID, encounterName, difficultyID, groupSize, success)
            end

            -- Show Report Button
            if aura_env.config.enableReportButton and #dejavuLog > 0 then
                WeakAuras.ScanEvents("JT_WA_DEFILE_DEJAVU_REPORT_BTN_SHOW")
            end
        end
    end
end

-- JT FAKE EVENT FUNCTION END

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "JT_WA_DEFILE_TARGET_CHECK" then
        return OnJTWADefileTargetCheck(...)
    elseif event == "ENCOUNTER_START" then
        local encounterID, encounterName, difficultyID, groupSize = ...

        thisEncounterId, thisEncounterName, thisEncounterDifficultyId, thisEncounterGroupSize = encounterID, encounterName, difficultyID, groupSize
        isInValidEncounter = isValidBoss()

        if isInValidEncounter then
            combatStartTime = GetTime()
            initData()
            return true
        end
    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, difficultyID, groupSize, success = ...
        if thisEncounterId == encounterID then
            thisEncounterId = 0
            isInValidEncounter = isValidBoss()
            saveDejavuLog(encounterID, encounterName, difficultyID, groupSize, success)
        end

        -- Show Report Button
        if aura_env.config.enableReportButton and #dejavuLog > 0 then
            WeakAuras.ScanEvents("JT_WA_DEFILE_DEJAVU_REPORT_BTN_SHOW")
        end
    elseif event == "JT_WA_DEFILE_DEJAVU_REPORT" then
        reportDejavuLog()
    elseif event == "JT_D_DEFILE_DEJAVU" then
        ToggleDebug()

    -- JT FAKE EVENT START
    elseif event == "JT_FAKE_EVENT" then
        return OnJTFakeEvent(event, ...)
    -- JT FAKE EVENT END

    end
end