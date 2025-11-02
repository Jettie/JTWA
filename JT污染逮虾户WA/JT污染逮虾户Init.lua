-- 版本信息
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

    -- -- JT FAKE EVENT START
    -- elseif event == "JT_FAKE_EVENT" then
    --     return OnJTFakeEvent(event, ...)
    -- -- JT FAKE EVENT END

    end
end