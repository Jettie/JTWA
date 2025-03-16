--版本信息
local version = 250313

--Header
local AURA_ICON = 237554
local AURA_NAME = "JT找背WA"
local SMALL_ICON = "|T"..(AURA_ICON or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_ICON = SMALL_ICON.."[%s]|CFF8FFFA2 "

aura_env.saved = aura_env.saved or {}

local waitForOOC = false

local SR = function(number)
    return string.format("%.2f",number).."%"
end

local JTCritCap = aura_env
local CritCapLogCount = 0
local newData = true

JTCritCap.btn = _G[aura_env.id]

local function BuildCritCapDetailsFrame()
    JTCritCap.frame = CreateFrame('Frame', 'CritCapDetailsFrame', aura_env.region, "BackdropTemplate")
    --JTCritCap.frame:SetTemplate('Transparent')
    -- JTCritCap.frame:Size(700, 500)
    JTCritCap.frame:SetWidth(950)
    JTCritCap.frame:SetHeight(600)
    if ElvUI then
        JTCritCap.frame:SetTemplate('Transparent')
    else
        JTCritCap.frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = {left = 8, right = 8, top = 10, bottom = 10}
        })
    end
    JTCritCap.frame:SetPoint('CENTER', UIParent, 'CENTER', -80, 15)
    JTCritCap.frame:Hide()
    JTCritCap.frame:EnableMouse(true)
    JTCritCap.frame:SetMovable(true)
    JTCritCap.frame:SetResizable(true)
    
    JTCritCap.frame:SetScript('OnMouseDown', function(self, button)
            if button == 'LeftButton' and not self.isMoving then
                self:StartMoving()
                self.isMoving = true
            end
    end)
    JTCritCap.frame:SetScript('OnMouseUp', function(self, button)
            if button == 'LeftButton' and self.isMoving then
                self:StopMovingOrSizing()
                self.isMoving = false
            elseif button == 'RightButton' then
                self:Hide()
            end
    end)
    JTCritCap.frame:SetScript('OnHide', function(self)
            if self.isMoving  then
                self:StopMovingOrSizing()
                self.isMoving = false
            end
    end)
    JTCritCap.scrollArea = CreateFrame('ScrollFrame', 'CritCapDetailsScrollFrame', JTCritCap.frame, 'UIPanelScrollFrameTemplate')
    JTCritCap.scrollArea:SetPoint('TOPLEFT', JTCritCap.frame, 'TOPLEFT', 8, -30)
    JTCritCap.scrollArea:SetPoint('BOTTOMRIGHT', JTCritCap.frame, 'BOTTOMRIGHT', -30, 8)
    if ElvUI then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleScrollBar(JTCritCap.scrollArea.ScrollBar)
    end
    JTCritCap.scrollArea:SetScript('OnSizeChanged', function(scroll)
            JTCritCap.editBox:SetWidth(scroll:GetWidth())
            JTCritCap.editBox:SetHeight(scroll:GetHeight())
    end)
    JTCritCap.scrollArea:HookScript('OnVerticalScroll', function(scroll, offset)
            JTCritCap.editBox:SetHitRectInsets(0, 0, offset, (JTCritCap.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    
    JTCritCap.editBox = CreateFrame('EditBox', 'CritCapDetailsFrameEditBox', JTCritCap.frame)
    JTCritCap.editBox:SetMultiLine(true)
    JTCritCap.editBox:SetMaxLetters(99999)
    JTCritCap.editBox:EnableMouse(true)
    JTCritCap.editBox:SetScript('OnMouseUp', function(self, button)
            if button == 'RightButton' then
                if JTCritCap.frame:IsShown() then
                    JTCritCap.frame:Hide()
                end
            end
    end)
    JTCritCap.editBox:SetAutoFocus(false)
    JTCritCap.editBox:SetFontObject('ChatFontNormal')
    JTCritCap.editBox:SetWidth(JTCritCap.scrollArea:GetWidth())
    JTCritCap.editBox:SetHeight(200)
    JTCritCap.editBox:SetScript('OnEscapePressed', function() JTCritCap.frame:Hide() end)
    JTCritCap.scrollArea:SetScrollChild(JTCritCap.editBox)
    JTCritCap.editBox:SetScript('OnTextChanged', function(_, userInput)
            if userInput then return end
            local _, Max = JTCritCap.scrollArea.ScrollBar:GetMinMaxValues()
            for _ = 1, Max do
                ScrollFrameTemplate_OnMouseWheel(JTCritCap.scrollArea, -1)
            end
    end)
    
    JTCritCap.close = CreateFrame('Button', 'CritCapDetailsFrameCloseButton', JTCritCap.frame, 'UIPanelCloseButton')
    JTCritCap.close:SetPoint('TOPRIGHT')
    JTCritCap.close:SetFrameLevel(JTCritCap.close:GetFrameLevel() + 1)
    JTCritCap.close:EnableMouse(true)
    JTCritCap.close:SetScript('OnMouseUp', function(self, button)
            if button == 'RightButton' then
                if JTCritCap.frame:IsShown() then
                    JTCritCap.frame:Hide()
                end
            end
    end)
    if ElvUI then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleCloseButton(JTCritCap.close)
    end
end
BuildCritCapDetailsFrame()

local function ToggleCritCapDetails()
    if next(JTCritCap.saved) then
        if not JTCritCap.frame:IsShown() then
            if newData then
                
                local textTable = {}
                local textFirstLine = HEADER_TEXT.."==== "..date("%Y/%m/%d").." ====|R"
                
                local needMoreMoving = true
                local count = 0
                for _, v in pairs(JTCritCap.saved)  do
                    local result = v
                    needMoreMoving = result.isDalian and needMoreMoving or false
                    textTable[#textTable + 1] = ((ONLY_ICON):format("|CFFFF53A2>.<|R")..(result.attackingDummy and "|CFF1785D1模拟|R" or "").."|CFFFFFFFF"..(result.timestr).."|R"..(result.isOffhand and "副手" or "主手")..(result.hsCovered or "")..(result.isDalian and "|CFFFF53A2打脸|R" or "|CFFFFFF00打背|R")..((result.final < 0 and "超阈值|CFFFF53A2" or "离阈值还差|CFFFFFFFF")..SR(result.final).."|R").." 当时:暴击|CFFFFFFFF"..SR(result.crit)..(result.attackingDummy and ("(|CFF1785D1BUFF后|R"..SR(result.combatCrit)) or "")..")|R 命中|CFFFFFFFF"..SR(result.hit)..(result.attackingDummy and ("(|CFF1785D1战斗|R"..SR(result.combatHit)) or "")..")|R|R")
                    count = count + 1
                end
                
                newData = false
                
                local textLastLine = (HEADER_TEXT.."====|CFFFFFFFF总计"..CritCapLogCount.."次暴击溢出|R("..(needMoreMoving and "|CFFFFFF00需要提升找背技巧|R" or "|CFFFF53A2需要提升命中|R")..")====|R")
                
                if needMoreMoving then
                    local mhExp, ohExp = GetExpertisePercent()
                    local mhParry = math.max((14 - mhExp),0)
                    local ohParry = math.max((14 - ohExp),0)
                    local mhParryColored = ( (mhParry > 0 ) and "|CFFFF53A2" or "CFFFFFFFF" )..mhParry.."%|R"
                    local ohParryColored = ( (ohParry > 0 ) and "|CFFFF53A2" or "CFFFFFFFF" )..ohParry.."%|R"
                    textLastLine = textLastLine.."\n\n"..((ONLY_ICON):format("|CFFFF53A2>.<|R").."|CFFFF53A2不要打脸!|R |CFFFFFF00正面更容易遇到阈值问题|R - 会有较高的|CFFFFFF00招架|R+|CFFFFFF00格挡|R\n")..((ONLY_ICON):format("|CFFFF53A2>.<|R").."以|CFF1785D1当前装备|R在怪物正面|CFFFF53A2打脸|R时: |CFFFFFF00招架率|R: (主手"..mhParryColored.."/副手"..ohParryColored..") |CFFFFFF00格挡率|R: |CFFFF53A25%|R")
                end
                
                JTCritCap.frame:Show()
                local combineTable = table.concat(textTable, ' \n', 1, count)
                local text = textFirstLine.."\n"..combineTable.."\n"..textLastLine
                JTCritCap.editBox:SetText(text)
                WeakAuras.ScanEvents("JT_CRITCAP_RESET_TIP")
            else
                JTCritCap.frame:Show()
            end
        else
            JTCritCap.frame:Hide()
        end
    end
end

--创建/显示按钮
aura_env.creatOrShowButton = function()
    if not JTCritCap.btn then
        JTCritCap.btn = CreateFrame("Button", aura_env.id, aura_env.region)
        JTCritCap.btn:SetAllPoints()
        JTCritCap.btn:SetScript("OnClick", function(self, button, down)
                if button == "LeftButton" then
                    ToggleCritCapDetails()
                elseif button == "RightButton" then
                    WeakAuras.ScanEvents("JT_CRITCAP_BTN_HIDE")
                end
        end)
        JTCritCap.btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        -- JTCritCap.btn:Hide()
    else
        JTCritCap.btn:SetScript("OnClick", function(self, button, down)
                if button == "LeftButton" then
                    ToggleCritCapDetails()
                elseif button == "RightButton" then
                    WeakAuras.ScanEvents("JT_CRITCAP_BTN_HIDE")
                end
        end)
        JTCritCap.btn:Show()
    end
end

aura_env.creatOrShowButton()
--隐藏按钮
aura_env.hideButton = function()
    if JTCritCap.frame:IsShown() then
        JTCritCap.frame:Hide()
    end
    if JTCritCap.btn then
        JTCritCap.btn:Hide()
        JTCritCap.saved = {}
        CritCapLogCount = 0
        newData = true
    end
end

local CombineData = function(...)
    local passData, passCount = ...
    if #passData > 0 then
        if #passData >= 200 then
            JTCritCap.saved = {}
        end
        if ( #JTCritCap.saved + #passData ) > 200 then
            local toRemove = #JTCritCap.saved + #passData - 200
            for i = 1, #passData do
                table.insert(JTCritCap.saved, passData[i])
                if toRemove > 0 then
                    table.remove(JTCritCap.saved, 1)
                    toRemove = toRemove - 1
                end
            end
        else
            for i = 1, #passData do
                table.insert(JTCritCap.saved, passData[i])
            end
        end
        CritCapLogCount = CritCapLogCount + passCount
        newData = true
    end
end

hooksecurefunc("SetItemRef", function(link)
        local arg1, arg2, arg3 = strsplit(":", link)
        if arg2 == "JTE" and arg3 == "CritCapFrame" then
            ToggleCritCapDetails()
        end
end)

aura_env.OnTrigger = function(event, ...)
    if event == "JT_CRITCAP_PASS_DATA" then
        CombineData(...)
        if InCombatLockdown() then
            waitForOOC = true
        else
            return true
        end
    elseif event == "PLAYER_REGEN_ENABLED" and waitForOOC then
        waitForOOC = false
        return true
    end
end

