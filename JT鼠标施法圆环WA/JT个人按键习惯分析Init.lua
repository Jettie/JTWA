-- 版本信息
local version = 250823

--author and header
local AURA_ICON = 237538
local AURA_NAME = "JT鼠标施法圆环WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "
local ONLY_ICON = SMALL_ICON.."[%s]|CFF8FFFA2 "

--[[
400ms内按键的统计数据
当次gcd中没有按键的忽略
基于总统计次数，去掉部分过高频率和过低频率的按键次数
]]

local myName = UnitName("player")
local myGUID = UnitGUID("player")
local myClassName, myClass, myClassId = UnitClass("player")

aura_env.saved = aura_env.saved or {}

local JTClickAnalyze = aura_env

local db = aura_env.saved
if myGUID and not db[myGUID] then
    db[myGUID] = {}
end
local myDB = db[myGUID]
local HISTORY_MAX_NUM = 20
local newData = false

local combatData = {}
local recordData = {}

local resetData = function()
    combatData = {}
    recordData = {}
end

--施法延迟与延迟容限关系
local latencyToSQWSuggestion = {
    [200] = "很高，建议使用|cffffffff250-400|r之间的延迟容限来确保连贯",
    [100] = "偏高，建议在|cffffffff200-400|r之间反复测试",
    [1] = "很低，可以在|cffffffff100-400|r之间反复测试",
}
local getSuggestionFromLatency = function(latency)
    if not latency or type(latency) ~= "number" then
        return nil
    end
    local thisLatency = math.floor(latency)
    for k, v in pairs(latencyToSQWSuggestion) do
        if thisLatency >= k then
            return v
        end
    end
    return nil
end

-- 获取专精
local getMainSpec = function()
    -- 存储各专精信息的表（索引从1开始）
    local specs = {}

    -- 收集所有专精的基础信息（仅保留需要的字段）
    for tabId = 1, 3 do
        local _, name, _, icon, pointsSpent = GetTalentTabInfo(tabId)
        specs[tabId] = {
            id = tabId,
            name = name,
            icon = icon,
            points = pointsSpent
        }
    end

    -- 查找主专精（按已点技能数降序，取第一个最大值）
    local mainSpec = specs[1]  -- 默认取第一个专精
    for _, spec in ipairs(specs) do
        if spec.points > mainSpec.points then
            mainSpec = spec
        end
    end

    -- 可选：如果所有专精都未加点（points<=0），返回0；否则返回主专精信息
    return mainSpec.points > 0 and mainSpec.id or nil
end

--inSQW几率与延迟容限推荐关系
local defaultSQWWorkedRateRange = {
    [75] = 3,
    [50] = 2,
    [30] = 1,
}

local rateRangeOfClass = {
    ["WARRIOR"] = {
        [1] = {20,40,60},
        [2] = {20,40,60},
        [3] = {20,40,60},
    },
    ["PALADIN"] = {
        [1] = {30,50,70},
        [2] = {20,40,60},
        [3] = {20,40,60},
    },
    ["DEATHKNIGHT"] = {
        [1] = {20,40,60},
        [2] = {20,40,60},
        [3] = {20,40,60},
    },
    ["HUNTER"] = {
        [1] = {20,40,60},
        [2] = {20,40,60},
        [3] = {20,40,60},
    },
    ["SHAMAN"] = {
        [1] = {30,50,70},
        [2] = {20,40,60},
        [3] = {30,50,70},
    },
    ["DRUID"] = {
        [1] = {30,50,70},
        [2] = {20,40,60},
        [3] = {30,50,70},
    },
    ["ROGUE"] = {
        [1] = {20,40,60},
        [2] = {20,40,60},
        [3] = {20,40,60},
    },
    ["MAGE"] = {
        [1] = {30,50,70},
        [2] = {30,50,70},
        [3] = {30,50,70},
    },
    ["PRIEST"] = {
        [1] = {30,50,70},
        [2] = {30,50,70},
        [3] = {30,50,70},
    },
    ["WARLOCK"] = {
        [1] = {30,50,70},
        [2] = {30,50,70},
        [3] = {30,50,70},
    },
}

local myRateRange = defaultSQWWorkedRateRange

local buildMyRateRange = function()
    local mySpec = getMainSpec()
    myRateRange = rateRangeOfClass[myClass] and (rateRangeOfClass[myClass][mySpec] or defaultSQWWorkedRateRange) or defaultSQWWorkedRateRange
end
buildMyRateRange()

local getSuggestionFormInSQW = function(inSQWRate, currentSQWTIme)
    -- 基于我的职业和专精inSQWRate获取Range代号
    local inSQWRange = 0
    for i, rate in ipairs(myRateRange) do
        if inSQWRate >= rate then
            inSQWRange = i
        end
    end
    if inSQWRange == 3 then
        if currentSQWTIme > 200 then
            -- 很不错 如果觉得粘手可以略微降低延迟容限
            return "很不错 如果觉得粘手可以略微降低延迟容限"
        elseif currentSQWTIme <= 200 then
            -- 很不错 当前延迟容限很适合你
            return "很不错 当前延迟容限很适合你"
        end
    elseif inSQWRange == 2 then
        if currentSQWTIme < 200 then
            -- 一般 可以尝试提升延迟容限到200
            return "一般 可以尝试提升延迟容限到200"
        elseif currentSQWTIme >= 400 then
            -- 一般 建议提升按键频率
            return "一般 建议提升按键频率"
        elseif currentSQWTIme >= 200 then
            -- 一般 可以尝试略微提升延迟容限
            return "一般 可以尝试略微提升延迟容限"
        end
    elseif inSQWRange == 1 then
        if currentSQWTIme < 200 then
            -- 较低 可以尝试提升延迟容限到200
            return "较低 可以尝试提升延迟容限到200"
        elseif currentSQWTIme >= 400 then
            -- 较低 建议提升按键频率
            return "较低 建议提升按键频率"
        elseif currentSQWTIme >= 200 then
            -- 较低 可以尝试略微提升延迟容限
            return "较低 可以尝试略微提升延迟容限"
        end
    elseif inSQWRange == 0 then
        if currentSQWTIme < 200 then
            -- 很低 可以尝试提升延迟容限到200
            return "很低 可以尝试提升延迟容限到200"
        elseif currentSQWTIme >= 400 then
            -- 很低 建议提升按键频率
            return "很低 建议提升按键频率"
        elseif currentSQWTIme >= 200 then
            -- 很低 可以尝试略微提升延迟容限
            return "很低 可以尝试略微提升延迟容限"
        end
    end
end

--in400ms几率与延迟容限推荐关系
local getSuggestionFormInFourHundredMS = function(averageInFourHundredMs, currentSQWTIme)
    local suggestionText = ""
    if not averageInFourHundredMs or type(averageInFourHundredMs) ~= "number" or averageInFourHundredMs == 0 then
        return ""
    end
    
    if averageInFourHundredMs >= 0.9 then
        local suggestSQW = 400/averageInFourHundredMs
        -- suggestSQW 向上取整整5
        suggestSQW = math.min(400, math.ceil(suggestSQW/5)*5)
        suggestionText = "基于400ms内平均按键次数，建议设置延迟容限为: |cffffffff"..suggestSQW.."|r"
    else
        suggestionText = "400ms内的按键次数较少，建议提升按键频率(尤其是GCD临结束前的时候)|r"
    end
    return suggestionText
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

-- colorLatency
local colorLatency = function(latency)
    if not latency then
        return ""
    end
    if latency <= 100 then
        return "|cff8fffa2"..latency.."ms|r"
    elseif latency <= 200 then
        return "|cfffff569"..latency.."ms|r"
    else
        return "|cffff53a2"..latency.."ms|r"
    end
end

-- colorSQWWorkedRate
local colorSQWWorkedRate = function(sqwWorkedRate)
    if not sqwWorkedRate then
        return ""
    end
    
    local thisColoredRange = 0
    for i, rate in ipairs(myRateRange) do
        if sqwWorkedRate >= rate then
            thisColoredRange = i
        end
    end
    
    if thisColoredRange == 3 then
        return "|cff8fffa2"..sqwWorkedRate.."%|r"
    elseif thisColoredRange == 2 then
        return "|cfffff569"..sqwWorkedRate.."%|r"
    elseif thisColoredRange == 1 then
        return "|cffff53a2"..sqwWorkedRate.."%|r"
    elseif thisColoredRange == 0 then
        return "|cffffffff"..sqwWorkedRate.."%|r"
    end
end

-- 保存本次报告到myDB
local saveReport = function(data)
    if not myDB then
        return
    end

    newData = true
    table.insert(myDB, data)
    if #myDB > HISTORY_MAX_NUM then
        table.remove(myDB, 1)
    end
end

--测试假人
local isAttackingDummy = false
local attackingDummyWarning = "|cffff0000注意|r: 攻击训练假人测试时，延迟比副本高，建议在|cffff53a2副本BOSS战实战测试|r"
local dummyNpcIds = {
    [31146] = true, -- 英雄训练假人
    [31144] = true, --宗师的训练假人
    [32666] = true, -- 专家的训练假人
    [32667] = true, -- 大师的训练假人

    -- 黑锋要塞
    [32543] = true, -- 精兵的训练假人
    [32546] = true, -- 黑锋骑士的训练假人
    [32547] = true, -- 大领主的训练假人
}

local isDummyGUID = function(unitGUID)
    if not unitGUID then
        return false
    end
    local unitType, _, _, _, _, unitId = strsplit("-", unitGUID)
    local id = tonumber(unitId)
    if unitType == "Creature" and dummyNpcIds[id] then
        return true
    end
    return false
end

local isHeroic = function(difficultyID)
    local heroicId = {
        [5] = true,
        [6] = true,
        [193] = true,
        [194] = true,
    }
    return heroicId[difficultyID]
end

local heroicString = "|cff00ff00H|r"
local victorySting = "|cff00ff00胜利|r"
local defeatString = "|cffff0000失败|r"

local iconStr = function(iconId)
	if iconId and type(iconId) == "number" then
		return "|T"..iconId..":12:12:0:0:64:64:4:60:4:60|t"
	else
		return ""
	end
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
-- local encounterTitleLine = "|cff8fffa2====[ |cfffff569#"..(index or "#").."|r ]==== |cfffff569"..encounterName.."|r("..(isHeroic(difficultyID) and heroicString or "")..groupSize..")-"..(success and victorySting or defeatString).." ] ==== "..dateString.." ====|r"
local calculateResult = function()
    if not recordData or #recordData == 0 then
        return
    end

    local thisEmoji = "|cff8fffa2o_o|r"
    local thisHeader = (ONLY_ICON):format(thisEmoji)

    local totalCount = #recordData

    local ignoreHigh = 0
    local ignoreLow = 0

    if totalCount >= 10 then
        ignoreHigh = math.floor(totalCount / 10)
        ignoreLow = math.floor(totalCount / 10)
    end

    -- 按照markInFourHundredMs由低向高排序
    table.sort(recordData, function(a, b)
        return a.totalMark < b.totalMark
    end)

    -- 移除recordData中前面的ignoreLow个和最后的ignoreHigh个
    if ignoreHigh > 0 then
        for i = 1, ignoreHigh do
            table.remove(recordData, totalCount - i + 1)
        end
    end
    if ignoreLow > 0 then
        for i = 1, ignoreLow do
            table.remove(recordData, 1)
        end
    end

    -- 剩余的recordData所有元素，计算markInFourHundredMs的平均值
    local totalMarkInFourHundredMs = 0
    for i, v in ipairs(recordData) do
        totalMarkInFourHundredMs = totalMarkInFourHundredMs + v.markInFourHundredMs
    end
    local averageMarkInFourHundredMs = math.floor(totalMarkInFourHundredMs * 100 / totalCount) / 100

    -- 剩余的recordData所有元素，计算markOutFourHundredMs的平均值
    local totalMarkOutFourHundredMs = 0
    for i, v in ipairs(recordData) do
        totalMarkOutFourHundredMs = totalMarkOutFourHundredMs + v.markOutFourHundredMs
    end
    local averageMarkOutFourHundredMs = math.floor(totalMarkOutFourHundredMs * 100 / totalCount) / 100

    -- 剩余的recordData所有元素，计算totalMark的平均值
    local totalTotalMark = 0
    for i, v in ipairs(recordData) do
        totalTotalMark = totalTotalMark + v.totalMark
    end
    local averageTotalMark = math.floor(totalTotalMark * 100 / totalCount) / 100

    -- 剩余的recordData所有元素，计算realLatencyTime的平均值
    local totalRealLatencyTime = 0
    local latencyTotalCount = totalCount
    for i, v in ipairs(recordData) do
        local latency = math.floor(v.realLatencyTime * 1000)

        -- 忽略掉大于1秒的延迟
        if v.realLatencyTime >= 1 then
            latencyTotalCount = latencyTotalCount - 1
        else
            totalRealLatencyTime = totalRealLatencyTime + v.realLatencyTime
        end
    end
    local averageRealLatencyTime = math.floor(totalRealLatencyTime * 1000/ latencyTotalCount)

    local sqwSetup = {}
    local sqwSetupCount = 0
    local highestSQWTime = 0
    for i, v in ipairs(recordData) do
        if not sqwSetup[v.spellQueueWindowTime] then
            sqwSetup[v.spellQueueWindowTime] = 1
            sqwSetupCount = sqwSetupCount + 1
            highestSQWTime = v.spellQueueWindowTime > highestSQWTime and v.spellQueueWindowTime or highestSQWTime
        else
            sqwSetup[v.spellQueueWindowTime] = sqwSetup[v.spellQueueWindowTime] + 1
        end
    end
    -- sqwSetup 中 key 按照 由高至低排序
    table.sort(sqwSetup, function(a, b)
        return a > b
    end)
    local sqwSetText = ""
    for k, v in pairs(sqwSetup) do
        sqwSetText = "|cffffffff"..sqwSetText..k.."|rms(|cffffffff"..v.."次|r) "
    end

    -- 当前的设置下，SQW生效的次数
    local sqwWorkedCount = 0
    for i, v in ipairs(recordData) do
        if v.isThisSQWWorked then
            sqwWorkedCount = sqwWorkedCount + 1
        end
    end
    local sqwWorkedRate = math.floor(sqwWorkedCount / totalCount * 100)

    -- DevTools_Dump(recordData)

    -- print("sqwWorkedRate = ", sqwWorkedRate, sqwWorkedCount, totalCount, highestSQWTime)

    -- 输出结果
    -- [JT鼠标施法圆环WA] 按键习惯分析 -- encounterName.."|r("..(isHeroic(difficultyID) and heroicString or "")..groupSize..")-".." ] ==== "..dateString.." ====|r
    print(HEADER_TEXT.."按键习惯分析 ==["..(combatData.playerClassId and classColorName(combatData.playerName, combatData.playerClassId) or "").."]==[ |cfffff569"..combatData.encounterName.."|r"..(isHeroic(combatData.difficultyID) and heroicString or "")..(combatData.groupSize or "").." ]== "..combatData.dateString.." ==|r")
    -- [o_o] 技能平均按键: 2.3次 400ms内平均按键: 1.5次 400ms外平均按键: 0.8次
    -- [o_o] 基于400ms内平均按键次数，建议设置延迟容限为400ms
    -- [o_o] 平均实战施法延迟: 120ms 很低，建议在100-400的延迟容限中反复测试
    -- [o_o] 平均施法延迟: 120ms 很低，建议在100-400的延迟容限中反复测试
    -- [o_o] 使用延迟容限2种: 400ms(30次) 100ms(3次)
    -- [o_o] 施法队列生效率: 30% 较低 可以尝试略微提升延迟容限
    
    print(thisHeader.."技能平均按键: |cffffffff"..averageTotalMark.."次|r 400ms内: |cffffffff"..averageMarkInFourHundredMs.."次|r 400ms外: |cffffffff"..averageMarkOutFourHundredMs.."次|r")
    print(thisHeader..(getSuggestionFormInFourHundredMS(averageMarkInFourHundredMs, highestSQWTime) or ""))
    print(thisHeader.."平均实战施法延迟: "..colorLatency(averageRealLatencyTime).." "..(getSuggestionFromLatency(averageRealLatencyTime) or ""))

    print(thisHeader.."使用延迟容限 |cffffffff"..sqwSetupCount.."|r 种: "..sqwSetText)
    print(thisHeader.."施法队列生效率: "..colorSQWWorkedRate(sqwWorkedRate).." |cffffffff"..(getSuggestionFormInSQW(sqwWorkedRate, highestSQWTime) or "").."|r")

    if isAttackingDummy then
        print(thisHeader..attackingDummyWarning)
    end

    local historyData = {
        combatData = combatData,

        totalCount = totalCount,
        averageMarkInFourHundredMs = averageMarkInFourHundredMs,
        averageMarkOutFourHundredMs = averageMarkOutFourHundredMs,
        averageTotalMark = averageTotalMark,
        averageRealLatencyTime = averageRealLatencyTime,
        sqwSetupCount = sqwSetupCount,
        sqwSetText = sqwSetText,
        sqwWorkedRate = sqwWorkedRate,
        highestSQWTime = highestSQWTime,

        isAttackingDummy = isAttackingDummy,
    }
    -- DevTools_Dump(historyData)
    saveReport(historyData)
end

local function BuildJTClickAnalyzeHistoryFrame()
    JTClickAnalyze.frame = CreateFrame('Frame', 'JTClickAnalyzeHistoryFrame', aura_env.region, "BackdropTemplate")
    --JTClickAnalyze.frame:SetTemplate('Transparent')
    -- JTClickAnalyze.frame:Size(700, 500)
    JTClickAnalyze.frame:SetWidth(950)
    JTClickAnalyze.frame:SetHeight(600)
    if ElvUI then
        JTClickAnalyze.frame:SetTemplate('Transparent')
    else
        JTClickAnalyze.frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = {left = 8, right = 8, top = 10, bottom = 10}
        })
    end
    JTClickAnalyze.frame:SetPoint('CENTER', UIParent, 'CENTER', -80, 15)
    JTClickAnalyze.frame:Hide()
    JTClickAnalyze.frame:EnableMouse(true)
    JTClickAnalyze.frame:SetMovable(true)
    JTClickAnalyze.frame:SetResizable(true)

    JTClickAnalyze.frame:SetScript('OnMouseDown', function(self, button)
            if button == 'LeftButton' and not self.isMoving then
                self:StartMoving()
                self.isMoving = true
            end
    end)
    JTClickAnalyze.frame:SetScript('OnMouseUp', function(self, button)
            if button == 'LeftButton' and self.isMoving then
                self:StopMovingOrSizing()
                self.isMoving = false
            elseif button == 'RightButton' then
                self:Hide()
            end
    end)
    JTClickAnalyze.frame:SetScript('OnHide', function(self)
            if self.isMoving  then
                self:StopMovingOrSizing()
                self.isMoving = false
            end
    end)
    JTClickAnalyze.scrollArea = CreateFrame('ScrollFrame', 'JTClickAnalyzeHistoryScrollFrame', JTClickAnalyze.frame, 'UIPanelScrollFrameTemplate')
    JTClickAnalyze.scrollArea:SetPoint('TOPLEFT', JTClickAnalyze.frame, 'TOPLEFT', 8, -30)
    JTClickAnalyze.scrollArea:SetPoint('BOTTOMRIGHT', JTClickAnalyze.frame, 'BOTTOMRIGHT', -30, 8)
    if ElvUI then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleScrollBar(JTClickAnalyze.scrollArea.ScrollBar)
    end
    JTClickAnalyze.scrollArea:SetScript('OnSizeChanged', function(scroll)
            JTClickAnalyze.editBox:SetWidth(scroll:GetWidth())
            JTClickAnalyze.editBox:SetHeight(scroll:GetHeight())
    end)
    JTClickAnalyze.scrollArea:HookScript('OnVerticalScroll', function(scroll, offset)
            JTClickAnalyze.editBox:SetHitRectInsets(0, 0, offset, (JTClickAnalyze.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)

    JTClickAnalyze.editBox = CreateFrame('EditBox', 'JTClickAnalyzeHistoryFrameEditBox', JTClickAnalyze.frame)
    JTClickAnalyze.editBox:SetMultiLine(true)
    JTClickAnalyze.editBox:SetMaxLetters(99999)
    JTClickAnalyze.editBox:EnableMouse(true)
    JTClickAnalyze.editBox:SetScript('OnMouseUp', function(self, button)
            if button == 'RightButton' then
                if JTClickAnalyze.frame:IsShown() then
                    JTClickAnalyze.frame:Hide()
                end
            end
    end)
    JTClickAnalyze.editBox:SetAutoFocus(false)
    JTClickAnalyze.editBox:SetFontObject('ChatFontNormal')
    JTClickAnalyze.editBox:SetWidth(JTClickAnalyze.scrollArea:GetWidth())
    JTClickAnalyze.editBox:SetHeight(200)
    JTClickAnalyze.editBox:SetScript('OnEscapePressed', function() JTClickAnalyze.frame:Hide() end)
    JTClickAnalyze.scrollArea:SetScrollChild(JTClickAnalyze.editBox)
    JTClickAnalyze.editBox:SetScript('OnTextChanged', function(_, userInput)
            if userInput then return end
            local _, Max = JTClickAnalyze.scrollArea.ScrollBar:GetMinMaxValues()
            for _ = 1, Max do
                ScrollFrameTemplate_OnMouseWheel(JTClickAnalyze.scrollArea, -1)
            end
    end)

    JTClickAnalyze.close = CreateFrame('Button', 'JTClickAnalyzeHistoryFrameCloseButton', JTClickAnalyze.frame, 'UIPanelCloseButton')
    JTClickAnalyze.close:SetPoint('TOPRIGHT')
    JTClickAnalyze.close:SetFrameLevel(JTClickAnalyze.close:GetFrameLevel() + 1)
    JTClickAnalyze.close:EnableMouse(true)
    JTClickAnalyze.close:SetScript('OnMouseUp', function(self, button)
            if button == 'RightButton' then
                if JTClickAnalyze.frame:IsShown() then
                    JTClickAnalyze.frame:Hide()
                end
            end
    end)
    if ElvUI then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleCloseButton(JTClickAnalyze.close)
    end
end
BuildJTClickAnalyzeHistoryFrame()

local makeReportText = function(encounterData, index)
    local thisCombatData = encounterData.combatData

    local totalCount = encounterData.totalCount or 0
    local averageMarkInFourHundredMs = encounterData.averageMarkInFourHundredMs or 0
    local averageMarkOutFourHundredMs = encounterData.averageMarkOutFourHundredMs or 0
    local averageTotalMark = encounterData.averageTotalMark or 0
    local averageRealLatencyTime = encounterData.averageRealLatencyTime or 1
    local sqwSetupCount = encounterData.sqwSetupCount or 1
    local sqwSetText = encounterData.sqwSetText or ""
    local sqwWorkedRate = encounterData.sqwWorkedRate or 0
    local highestSQWTime = encounterData.highestSQWTime or 0
    local thisIsAttackingDummy = encounterData.isAttackingDummy or false


    local header = (ONLY_ICON):format("|cff8fffa2o_o|r")
    local titleLine = "==[ |cfffff569#"..(index or "#").."|r ]==["..(thisCombatData.playerClassId and classColorName(thisCombatData.playerName, thisCombatData.playerClassId) or "").."]==[ |cfffff569"..thisCombatData.encounterName.."|r"..(isHeroic(combatData.difficultyID) and heroicString or "")..(thisCombatData.groupSize or "").." ]== "..thisCombatData.dateString.." ==|r"

    local logLine1 = header.."技能平均按键: |cffffffff"..averageTotalMark.."次|r 400ms内: |cffffffff"..averageMarkInFourHundredMs.."次|r 400ms外: |cffffffff"..averageMarkOutFourHundredMs.."次|r".."|r"
    local logLine2 = header..(getSuggestionFormInFourHundredMS(averageMarkInFourHundredMs, highestSQWTime) or "").."|r"
    local logLine3 = header.."平均实战施法延迟: "..colorLatency(averageRealLatencyTime).." "..(getSuggestionFromLatency(averageRealLatencyTime) or "").."|r"
    local logLine4 = header.."使用延迟容限 |cffffffff"..sqwSetupCount.."|r 种: "..sqwSetText
    local logLine5 = header.."施法队列生效率: "..colorSQWWorkedRate(sqwWorkedRate).." |cffffffff"..(getSuggestionFormInSQW(sqwWorkedRate, highestSQWTime) or "").."|r".."|r"

    local logLines = logLine1.."\n"..logLine2.."\n"..logLine3.."\n"..logLine4.."\n"..logLine5

    if thisIsAttackingDummy then
        logLines = logLines.."\n"..header..attackingDummyWarning.."|r"
    end

    -- 添加一个空行
    logLines = logLines.."\n"
    return header, titleLine, logLines
end

local ToggleJTClickAnalyzeHistory = function()
    if next(myDB) then
        if not JTClickAnalyze.frame:IsShown() then
            if newData then
                local textTable = {}
                local textFirstLine = HEADER_TEXT.."==== 历史BOSS战斗数据 ====|R"

                local count = 0
                for i, encounterData in ipairs(myDB)  do
                    local header, titleLine, logLines = makeReportText(encounterData, i)

                    local thisText = header..titleLine.."\n"..logLines
                    textTable[#textTable + 1] = thisText

                    count = count + 1
                end

                newData = false

                local textLastLine = (HEADER_TEXT.."====总计|CFFFFFFFF"..#myDB.."|R次BOSS战纪录====|R")
                local authorLine = HEADER_TEXT.." 分析自己的按键习惯找到合适的延迟容限 - |cffffffff作者:|R "..AUTHOR.."|r"
                local helpLine = HEADER_TEXT.." 在WA的 |cffffffff自定义选项|r 中可以 |cffff0000开启|r/|cff00ff00关闭|r 分析功能与按钮"
                JTClickAnalyze.frame:Show()
                local combineTable = table.concat(textTable, ' \n', 1, count)

                local text = textFirstLine.."\n"..combineTable.."\n"..textLastLine.."\n"..authorLine.."\n"..helpLine
                JTClickAnalyze.editBox:SetText(text)
            else
                JTClickAnalyze.frame:Show()
            end
        else
            JTClickAnalyze.frame:Hide()
        end
    else
        print(HEADER_TEXT.."没有分析记录 去副本战斗吧")
    end
end

local resetAllHistory = function()
    myDB = {}
---@diagnostic disable-next-line: need-check-nil
    db[myGUID] = {}

    newData = true
    if JTClickAnalyze.frame:IsShown() then
        JTClickAnalyze.frame:Hide()
    end
    PlaySoundFile("Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Sounds\\kaching.ogg","Master")
end

local thisBtnName = aura_env.id.."Button"
aura_env.btn = _G[thisBtnName]

--创建/显示按钮
local creatOrShowButton = function()
    if not aura_env.btn then
        aura_env.btn = CreateFrame("Button", thisBtnName, aura_env.region)
        aura_env.btn:SetAllPoints()
        aura_env.btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    aura_env.btn:SetScript("OnClick", function(self, button, down)
        if button == "LeftButton" then
            ToggleJTClickAnalyzeHistory()
        elseif button == "RightButton" then
            resetAllHistory()
            WeakAuras.ScanEvents("JT_GCD_MONITOR_ANALYSIS_BTN_HIDE")
        end
    end)
    if next(myDB) then
        aura_env.btn:Show()
        return true
    elseif aura_env.btn and aura_env.btn:IsShown() then
        aura_env.btn:Hide()
    end
end
creatOrShowButton()

--隐藏按钮
local hideButton = function()
    if aura_env.btn and aura_env.btn:IsShown() then
        aura_env.btn:Hide()
    end
end

local OnPlayerRegenDisabled = function()
    local targetGUID = UnitGUID("target")
    if targetGUID and isDummyGUID(targetGUID) then
        -- 在攻击假人 提示副本外与副本内的施法延迟是不同的，建议在副本内测试
        resetData()

        isAttackingDummy = true

        print(HEADER_TEXT..attackingDummyWarning)

        local encounterID = 0
        local encounterName = UnitName("target") or "未知目标"
        local difficultyID = 0
        local groupSize = nil
        
        local DATE_FORMAT = "%Y年%m月%d日 %H:%M:%S"
        local dateString = date(DATE_FORMAT)

        combatData = {
            playerGUID = myGUID,
            playerName = myName,
            playerClass = myClass,
            playerClassName = myClassName,
            playerClassId = myClassId,
            
            dateString = dateString,

            encounterID = encounterID,
            encounterName = encounterName,
            difficultyID = difficultyID,
            groupSize = groupSize,
        }
    end
end

local OnPlayerRegenEnabled = function()
    if isAttackingDummy then
        -- report data
        calculateResult()
        isAttackingDummy = false

        return creatOrShowButton()
    end
end

local OnEncounterStart = function(...)
    resetData()
    local encounterID, encounterName, difficultyID, groupSize = ...
    
    local DATE_FORMAT = "%Y年%m月%d日 %H:%M:%S"
    local dateString = date(DATE_FORMAT)

    combatData = {
        playerGUID = myGUID,
        playerName = myName,
        playerClass = myClass,
        playerClassName = myClassName,
        playerClassId = myClassId,

        dateString = dateString,

        encounterID = encounterID,
        encounterName = encounterName,
        difficultyID = difficultyID,
        groupSize = groupSize,
    }

end

local OnEncounterEnd = function(...)
    calculateResult()
    return creatOrShowButton()
end

local OnJTGCDMonitorAnalysisRecord = function(event, ...)
    -- WeakAuras.ScanEvents("JT_GCD_MONITOR_ANALYSIS_RECORD", markInFourHundredMs)
    local isThisSQWWorked, markInFourHundredMs, markOutFourHundredMs, spellQueueWindowTime, realLatencyTime = ...

    local thisRecord = {
        isThisSQWWorked = isThisSQWWorked,
        markInFourHundredMs = markInFourHundredMs,
        markOutFourHundredMs = markOutFourHundredMs,
        totalMark = markInFourHundredMs + markOutFourHundredMs,
        spellQueueWindowTime = spellQueueWindowTime,
        realLatencyTime = realLatencyTime,
    }

    table.insert(recordData, thisRecord)
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTECHECK"] = true,
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
        if text == "gcdmonitor" then
            local msg = "GCD Monitor Ring Ver: "..ver
            C_ChatInfo.SendAddonMessage("JTECHECKRESPONSE", msg, channel, nil)
        end
    end
end

local showHistoryCommand = {
    ["查看按键分析"] = true,
}

local commandHandler = function(waitText)
    local command, arg = strsplit(" ", waitText)
    local lowerCommand = command:lower()
    if showHistoryCommand[lowerCommand] then
        -- 显示历史弹窗
        newData = true
        ToggleJTClickAnalyzeHistory()
        if next(myDB) then
            return true
        end
    end
end

local OnMessageReceived = function(event, ...)
    if event == "CHAT_MSG_SAY" then
        local waitText, _, _, _, _, _, _, _, _, _, _, GUID = ...
        if GUID == myGUID then
            return commandHandler(waitText)
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        OnPlayerRegenDisabled()
    elseif event == "PLAYER_REGEN_ENABLED" then
        return OnPlayerRegenEnabled()
    elseif event == "ENCOUNTER_START" then
        OnEncounterStart(...)
    elseif event == "ENCOUNTER_END" then
        return OnEncounterEnd(...)
    elseif event == "PLAYER_TALENT_UPDATE" then
        buildMyRateRange()
    elseif event == "JT_GCD_MONITOR_ANALYSIS_RECORD" then
        OnJTGCDMonitorAnalysisRecord(event, ...)
    elseif event == "CHAT_MSG_ADDON" then
        OnChatMSGAddon(...)
    elseif event == "CHAT_MSG_SAY" then
        return OnMessageReceived(event, ...)
    end
end

aura_env.OnHide = function(event, ...)
    if event == "PLAYER_REGEN_DISABLED" or event == "JT_GCD_MONITOR_ANALYSIS_BTN_HIDE" then
        hideButton()
        return true
    end
end