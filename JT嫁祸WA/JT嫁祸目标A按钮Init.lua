-- 嫁祸按钮
local buttonId = 1
local version = 16
local AURA_NAME = "JT嫁祸WA"

local enableButton = (select(2, UnitClass("player")) == "ROGUE" and (buttonId == 1)) or false
local headerText = "|T236283:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT嫁祸WA|R]|CFF8FFFA2 "

-- 登记JTE WA版本号
local RVDB = function(WAname, WAversion)
    if JTE and JTE.RVDB then
        local n = WAname or aura_env.id
        local v = version or 0
        JTE.RVDB(n, v)
    end
end
-- 只有A按钮登记，BXY按钮不登记
if buttonId == 1 then
    RVDB(AURA_NAME, version)
    if JTE and JTE.ToTWALoaded then
        JTE.ToTWALoaded()
    end
end

local waitForOOCForGroupRosterUpdate = false
local waitForOOCForSettingButton = false
local waitForOOCForSettingButtonPassthrough = false

local buttonName = aura_env.id.."Button"
aura_env.btn = _G[buttonName]

--创建按钮
local creatButton = function()
    if not aura_env.btn and aura_env.config.enableClick then
        aura_env.btn = CreateFrame("Button", buttonName, aura_env.region)
        aura_env.btn:SetAllPoints()
        aura_env.btn:SetScript("OnClick", function(self, button, down)
                if button == "LeftButton" then
                    if JTE and JTE.SetToTMacroTarget then
                        JTE.SetToTMacroTarget(buttonId, true)
                    elseif JTE then
                        print(headerText.."设置嫁祸目标功能需要更新你的|CFFFF53A2JTE|R插件")
                    else
                        print(headerText.."设置嫁祸目标功能需要安装|CFFFF53A2JTE|R插件")
                    end
                end
        end)
        aura_env.btn:RegisterForClicks("LeftButtonDown")
    end
end
creatButton()

--刷新按钮
local setButton = function()
    if aura_env.btn then
        if aura_env.config.enableClick and enableButton and (IsInGroup() or IsInRaid()) then
            aura_env.btn:SetPassThroughButtons("RightButton")
        else
            aura_env.btn:SetPassThroughButtons("LeftButton", "RightButton")
        end
    else
        creatButton()
    end
    WeakAuras.ScanEvents("JT_TOT_UPDATE_TARGET_BUTTON_TEXT", buttonId, enableButton, aura_env.config.enableClick)
end
setButton()

aura_env.isButtonEnabled = function()
    if aura_env.config.enableClick and enableButton then
        return true
    else
        if aura_env.btn then
            if InCombatLockdown() then
                waitForOOCForSettingButtonPassthrough = true
            else
                aura_env.btn:SetPassThroughButtons("LeftButton", "RightButton")
            end
        end
        return false
    end
end

aura_env.isButtonDisabled = function()
    if aura_env.config.enableClick and enableButton then
        return false
    else
        if aura_env.btn then
            if InCombatLockdown() then
                waitForOOCForSettingButtonPassthrough = true
            else
                aura_env.btn:SetPassThroughButtons("LeftButton", "RightButton")
            end
        end
        return true
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_TOT_BUTTON_SHOW" then
        local id = ...
        if id == buttonId then
            enableButton = true
            if InCombatLockdown() then
                waitForOOCForSettingButton = true
            else
                setButton()
            end
            return true
        end
    end
end

aura_env.OnHide = function(event, ...)
    if event == "JT_TOT_BUTTON_HIDE" then
        local id = ...
        if id == buttonId then
            enableButton = false
            if InCombatLockdown() then
                waitForOOCForSettingButton = true
            else
                setButton()
            end
            return true
        end
    end
end

aura_env.TryToSetButton = function(event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        if InCombatLockdown() then
            waitForOOCForGroupRosterUpdate = true
        else
            setButton()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if waitForOOCForGroupRosterUpdate or waitForOOCForSettingButton then
            waitForOOCForGroupRosterUpdate = false
            waitForOOCForSettingButton = false
            setButton()
        end
        if waitForOOCForSettingButtonPassthrough then
            if aura_env.btn and not (aura_env.config.enableClick and enableButton) then
                aura_env.btn:SetPassThroughButtons("LeftButton", "RightButton")
            end
        end
    elseif event == "OPTIONS" or event == "STATUS" then
        if JTE and JTE.ToTReactivateButton then
            JTE.ToTReactivateButton(buttonId)
        end
    end
end