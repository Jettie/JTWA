-- 版本信息
local version = 250823

--author and header
local AURA_ICON = 133900
local AURA_NAME = "JT污染逮虾户WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "
local ONLY_ICON = SMALL_ICON.."[%s]|CFF8FFFA2 "

aura_env.btnName = ">|cffff53a2历史|r<"

aura_env.saved = aura_env.saved or {}

local myGUID = UnitGUID('player')

local newData = true
local maxDataCount = 20

local JTDefileDejavu = aura_env

local function BuildDefileDejavuHistoryFrame()
    JTDefileDejavu.frame = CreateFrame('Frame', 'DefileDejavuHistoryFrame', aura_env.region, "BackdropTemplate")
    --JTDefileDejavu.frame:SetTemplate('Transparent')
    -- JTDefileDejavu.frame:Size(700, 500)
    JTDefileDejavu.frame:SetWidth(950)
    JTDefileDejavu.frame:SetHeight(600)
    if ElvUI then
        JTDefileDejavu.frame:SetTemplate('Transparent')
    else
        JTDefileDejavu.frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = {left = 8, right = 8, top = 10, bottom = 10}
        })
    end
    JTDefileDejavu.frame:SetPoint('CENTER', UIParent, 'CENTER', -80, 15)
    JTDefileDejavu.frame:Hide()
    JTDefileDejavu.frame:EnableMouse(true)
    JTDefileDejavu.frame:SetMovable(true)
    JTDefileDejavu.frame:SetResizable(true)

    JTDefileDejavu.frame:SetScript('OnMouseDown', function(self, button)
            if button == 'LeftButton' and not self.isMoving then
                self:StartMoving()
                self.isMoving = true
            end
    end)
    JTDefileDejavu.frame:SetScript('OnMouseUp', function(self, button)
            if button == 'LeftButton' and self.isMoving then
                self:StopMovingOrSizing()
                self.isMoving = false
            elseif button == 'RightButton' then
                self:Hide()
            end
    end)
    JTDefileDejavu.frame:SetScript('OnHide', function(self)
            if self.isMoving  then
                self:StopMovingOrSizing()
                self.isMoving = false
            end
    end)
    JTDefileDejavu.scrollArea = CreateFrame('ScrollFrame', 'DefileDejavuHistoryScrollFrame', JTDefileDejavu.frame, 'UIPanelScrollFrameTemplate')
    JTDefileDejavu.scrollArea:SetPoint('TOPLEFT', JTDefileDejavu.frame, 'TOPLEFT', 8, -30)
    JTDefileDejavu.scrollArea:SetPoint('BOTTOMRIGHT', JTDefileDejavu.frame, 'BOTTOMRIGHT', -30, 8)
    if ElvUI then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleScrollBar(JTDefileDejavu.scrollArea.ScrollBar)
    end
    JTDefileDejavu.scrollArea:SetScript('OnSizeChanged', function(scroll)
            JTDefileDejavu.editBox:SetWidth(scroll:GetWidth())
            JTDefileDejavu.editBox:SetHeight(scroll:GetHeight())
    end)
    JTDefileDejavu.scrollArea:HookScript('OnVerticalScroll', function(scroll, offset)
            JTDefileDejavu.editBox:SetHitRectInsets(0, 0, offset, (JTDefileDejavu.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)

    JTDefileDejavu.editBox = CreateFrame('EditBox', 'DefileDejavuHistoryFrameEditBox', JTDefileDejavu.frame)
    JTDefileDejavu.editBox:SetMultiLine(true)
    JTDefileDejavu.editBox:SetMaxLetters(99999)
    JTDefileDejavu.editBox:EnableMouse(true)
    JTDefileDejavu.editBox:SetScript('OnMouseUp', function(self, button)
            if button == 'RightButton' then
                if JTDefileDejavu.frame:IsShown() then
                    JTDefileDejavu.frame:Hide()
                end
            end
    end)
    JTDefileDejavu.editBox:SetAutoFocus(false)
    JTDefileDejavu.editBox:SetFontObject('ChatFontNormal')
    JTDefileDejavu.editBox:SetWidth(JTDefileDejavu.scrollArea:GetWidth())
    JTDefileDejavu.editBox:SetHeight(200)
    JTDefileDejavu.editBox:SetScript('OnEscapePressed', function() JTDefileDejavu.frame:Hide() end)
    JTDefileDejavu.scrollArea:SetScrollChild(JTDefileDejavu.editBox)
    JTDefileDejavu.editBox:SetScript('OnTextChanged', function(_, userInput)
            if userInput then return end
            local _, Max = JTDefileDejavu.scrollArea.ScrollBar:GetMinMaxValues()
            for _ = 1, Max do
                ScrollFrameTemplate_OnMouseWheel(JTDefileDejavu.scrollArea, -1)
            end
    end)

    JTDefileDejavu.close = CreateFrame('Button', 'DefileDejavuHistoryFrameCloseButton', JTDefileDejavu.frame, 'UIPanelCloseButton')
    JTDefileDejavu.close:SetPoint('TOPRIGHT')
    JTDefileDejavu.close:SetFrameLevel(JTDefileDejavu.close:GetFrameLevel() + 1)
    JTDefileDejavu.close:EnableMouse(true)
    JTDefileDejavu.close:SetScript('OnMouseUp', function(self, button)
            if button == 'RightButton' then
                if JTDefileDejavu.frame:IsShown() then
                    JTDefileDejavu.frame:Hide()
                end
            end
    end)
    if ElvUI then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleCloseButton(JTDefileDejavu.close)
    end
end
BuildDefileDejavuHistoryFrame()

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

local validMapIds = {
    [192] = true, -- 巫妖王BOSS战
}

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

local makeReportText = function(encounterData, index)
    local dateString = encounterData.dateString

    local data = encounterData.data

    local encounterID = encounterData.id
    local encounterName = encounterData.name
    local difficultyID = encounterData.difficulty
    local groupSize = encounterData.groupSize
    local success = encounterData.success

    local thisEmoji = "|cff8fffa2T.T|r"
    local thisHeader = (ONLY_ICON):format(thisEmoji).."|r"

    local thisEncounterLogText = ""
    for _, logTable in pairs(data) do
        if not logTable then
            return
        end

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
            thisText = thisHeader.." "..combatTimeText..coloredDashText..stageIconString..stageNameText..stageNumText.." ".. destNameText.. spellTargetText
        elseif logTable.type == 2 then
            thisText = thisHeader.." "..combatTimeText..coloredDashText..stageIconString..stageNameText..stageNumText.." ".. destNameText.. spellTargetText
        elseif logTable.type == 3 then
            thisText = thisHeader.." "..combatTimeText..coloredDashText..stageIconString..stageNameText..stageNumText.. " ".. compareTimeText.. " "..spellIconString..spellNameText.. " ".. sourceNameText..spellTargetText
        elseif logTable.type == 4 then
            -- 0:34 死疽#1 +1.02s 疾跑 -> 小丑杰罗姆
            thisText = thisHeader.." "..combatTimeText..coloredDashText..stageIconString..stageNameText..stageNumText.. " ".. compareTimeText.. " "..spellIconString..spellNameText.. " ".. sourceNameText..spellTargetText
        elseif logTable.type == 5 then
            -- 6:42 注意! CD!CD! 火箭鞋CD(1.00s) 污染#6 -> 脑袋中了九箭
            thisText = thisHeader.." "..combatTimeText..coloredDashText..warningText.." "..stageIconString..stageNameText..stageNumText.. " ".. spellIconString..spellNameText..cdTimeText.. " ".. sourceNameText..spellTargetText
        end
        
        thisEncounterLogText = thisEncounterLogText..thisText.."\n"

    end

    

    local encounterTitleLine = "|cff8fffa2====[ |cfffff569#"..(index or "#").."|r ]==== |cfffff569"..encounterName.."|r("..(isHeroic(difficultyID) and heroicString or "")..groupSize..")-"..(success and victorySting or defeatString).." ] ==== "..dateString.." ====|r"

    return thisHeader, encounterTitleLine, thisEncounterLogText
end

local ToggleDefileDejavuHistory = function()
    if next(JTDefileDejavu.saved) then
        if not JTDefileDejavu.frame:IsShown() then
            if newData then
                local textTable = {}
                local textFirstLine = HEADER_TEXT.."==== 历史BOSS战斗数据 ====|R"

                local count = 0
                for i, encounterData in ipairs(JTDefileDejavu.saved)  do
                    local header, titleLine, logLines = makeReportText(encounterData, i)

                    local thisText = header..titleLine.."\n"..logLines
                    textTable[#textTable + 1] = thisText

                    count = count + 1
                end

                newData = false

                local textLastLine = (HEADER_TEXT.."====总计|CFFFFFFFF"..#JTDefileDejavu.saved.."|R次BOSS战纪录====|R")
                local authorLine = HEADER_TEXT.." 看谁火箭鞋用的快 - 作者:|R "..AUTHOR
                JTDefileDejavu.frame:Show()
                local combineTable = table.concat(textTable, ' \n', 1, count)

                local text = textFirstLine.."\n"..combineTable.."\n"..textLastLine.."\n"..authorLine
                JTDefileDejavu.editBox:SetText(text)
            else
                JTDefileDejavu.frame:Show()
            end
        else
            JTDefileDejavu.frame:Hide()
        end
    else
        print(HEADER_TEXT.."没有巫妖王记录 去副本战斗吧")
    end
end

local resetAllHistory = function()
    JTDefileDejavu.saved = {}
    newData = true
    if JTDefileDejavu.frame:IsShown() then
        JTDefileDejavu.frame:Hide()
    end
    PlaySoundFile("Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Sounds\\kaching.ogg","Master")
end

local thisBtnName = aura_env.id.."Button"
aura_env.btn = _G[thisBtnName]

--创建/显示按钮
aura_env.creatOrShowButton = function()
    if not aura_env.btn then
        aura_env.btn = CreateFrame("Button", thisBtnName, aura_env.region)
        aura_env.btn:SetAllPoints()
        aura_env.btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    aura_env.btn:SetScript("OnClick", function(self, button, down)
        if button == "LeftButton" then
            ToggleDefileDejavuHistory()
        elseif button == "RightButton" then
            resetAllHistory()
            WeakAuras.ScanEvents("JT_DEFILE_DEJAVU_HISTORY_BTN_HIDE")
        end
    end)
    aura_env.btn:Show()
end
aura_env.creatOrShowButton()

--隐藏按钮
aura_env.hideButton = function()
    if aura_env.btn and aura_env.btn:IsShown() then
        aura_env.btn:Hide()
    end
end

local saveData = function(...)
    local encounterData = ...

    if next(encounterData) then
        -- 先存起来
        table.insert(JTDefileDejavu.saved, encounterData)
        newData = true
        -- 超出最大数量就删除最早的
        if #JTDefileDejavu.saved > maxDataCount then
            table.remove(JTDefileDejavu.saved, 1)
        end
    end
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
        if text == "dejavu" then
            local msg = "WuRan Deja Vu Ver: "..ver
            C_ChatInfo.SendAddonMessage("JTECHECKRESPONSE", msg, channel, nil)
        end
    end
end

local showHistoryCommand = {
    ["污染逮虾户"] = true,
    ["查看污染"] = true,
    ["查看污染历史"] = true,
    ["查看逮虾户"] = true,
    ["查看污染逮虾户"] = true,
}

local commandHandler = function(waitText)
    local command, arg = strsplit(" ", waitText)
    local lowerCommand = command:lower()
    if showHistoryCommand[lowerCommand] then
        -- 显示历史弹窗
        newData = true
        ToggleDefileDejavuHistory()
        if next(JTDefileDejavu.saved) then
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
    if event == "JT_DEFILE_DEJAVU_HISTORY_DATA" then
        saveData(...)
        if next(JTDefileDejavu.saved) then
            aura_env.creatOrShowButton()
        end
        return true
    elseif event == "PLAYER_REGEN_ENABLED" then
        if next(JTDefileDejavu.saved) then
            aura_env.creatOrShowButton()
        end
        local mapId = C_Map.GetBestMapForUnit("player")
        return validMapIds[mapId]
    elseif event == "CHAT_MSG_ADDON" then
        OnChatMSGAddon(...)
    elseif event == "CHAT_MSG_SAY" then
        return OnMessageReceived(event, ...)
    end
end

aura_env.OnHide = function(event, ...)
    if event == "PLAYER_REGEN_DISABLED" or event == "JT_DEFILE_DEJAVU_HISTORY_BTN_HIDE" then
        aura_env.hideButton()
        return true
    end
end