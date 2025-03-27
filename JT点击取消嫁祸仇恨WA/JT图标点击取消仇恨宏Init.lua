--版本信息
local version = 250324

local AURA_ICON = 236283
local AURA_NAME = "JT点击取消嫁祸仇恨WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local CAN_NOT_CREATE_BTN_IN_COMBAT = "|CFFFF53A2战斗中无法初始化无脑点击按钮|R 战斗结束后自动创建"
local INITIALIZED = HEADER_TEXT.."- 无脑点击取消仇恨按钮创建成功 (|CFFFF53A23.4.4版|R) - 作者:|R "..AUTHOR

--点击版改动部分写这里
local macroStr = "/cancelaura 嫁祸诀窍"
--local macroStr = "/cancelaura 佯攻" --佯攻测试

aura_env.displayClick = "点击取消\n嫁祸诀窍\n仇恨转移"

--清空btn
local btnName = aura_env.id.."Button"

aura_env.btn = _G[btnName]

aura_env.createBtn = function()
    if not aura_env.btn then
        -- 战斗中无法创建按钮
        if not InCombatLockdown() then
            aura_env.btn = CreateFrame("Button", btnName, aura_env.region, "SecureActionButtonTemplate")
            aura_env.btn:SetAllPoints()
            aura_env.btn:SetAttribute("type","macro")
            aura_env.btn:SetAttribute("macrotext", macroStr)
            aura_env.btn:RegisterForClicks("LeftButtonDown")
            aura_env.btn:SetPassThroughButtons("RightButton")
            print(INITIALIZED)
            INITIALIZED = ""
        else
            print(CAN_NOT_CREATE_BTN_IN_COMBAT)
            aura_env.waitForOOCToCreate = true
        end
    end
end
aura_env.createBtn()

aura_env.OnPlayerRegenEnabled = function(self)
    if not aura_env.btn then
        if aura_env.waitForOOCToCreate then
            aura_env.creatButton()
            print(INITIALIZED)
            INITIALIZED = ""
            aura_env.waitForOOCToCreate = false
        end
    elseif aura_env.btn:IsShown() and aura_env.waitForOOCHide then
        aura_env.btn:Hide()
        aura_env.waitForOOCHide = false
    elseif not aura_env.btn:IsShown() and aura_env.waitForOOCToShow then
        aura_env.btn:Show()
        aura_env.waitForOOCToShow = false
    end
end

aura_env.tryToShowButton = function(self)
    if not aura_env.btn then
        aura_env.createBtn()
    else
        if InCombatLockdown() then
            aura_env.waitForOOCToShow = true
            aura_env.waitForOOCHide = false
        else
            aura_env.btn:Show()
        end
    end
end

aura_env.tryToHideButton = function(self)
    if aura_env.btn then
        if InCombatLockdown() then
            aura_env.waitForOOCHide = true
            aura_env.waitForOOCToShow = false
        else
            aura_env.btn:Hide()
        end
    end
end