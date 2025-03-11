--版本信息
local version = 250304

local AURA_ICON = 236571
local AURA_NAME = "JT烹饪自动换厨帽WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local baseFireSpellId = 818
local baseFireSpellName = GetSpellInfo(baseFireSpellId)

local tradeSkillId = 51296
local tradeSkillName = GetSpellInfo(tradeSkillId)

local waitForOOC = false

local btnName = aura_env.id.."Button"

aura_env.btn = _G[btnName]

local macroStr = "/cast "..baseFireSpellName

local creatOrShowButton = function()
    if not aura_env.btn then
        aura_env.btn = CreateFrame("Button", btnName, aura_env.region, "SecureActionButtonTemplate")
        aura_env.btn:SetAllPoints()
        aura_env.btn:SetAttribute("type","macro")
        aura_env.btn:SetAttribute("macrotext", macroStr)
        aura_env.btn:SetPassThroughButtons("RightButton")
    end
end
creatOrShowButton()

local tryHideBtn = function()
    waitForOOC = InCombatLockdown()
    
    if waitForOOC then
        return false
    else
        return true
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "TRADE_SKILL_SHOW" then
        local curSkillName = GetTradeSkillLine()
        if curSkillName == tradeSkillName then
            return true
        end
    end
end

aura_env.TryHide = function(event, ...)
    if not TradeSkillFrame then return end
    if event == "TRADE_SKILL_CLOSE" then
        return tryHideBtn()
    elseif event == "TRADE_SKILL_SHOW" then
        if (not TradeSkillFrame or not TradeSkillFrame:IsShown() or (TradeSkillFrame:IsShown() and tradeSkillName ~= GetTradeSkillLine())) then
            return tryHideBtn()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        return tryHideBtn()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if (not TradeSkillFrame or not TradeSkillFrame:IsShown() or (TradeSkillFrame:IsShown() and tradeSkillName ~= GetTradeSkillLine())) and waitForOOC then
            return tryHideBtn()
        end
    end
end

