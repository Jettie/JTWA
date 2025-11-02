-- 版本信息
local version = 250810

aura_env.btnName = ">|cffff53a2通报|r<"

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
                WeakAuras.ScanEvents("JT_WA_DEFILE_DEJAVU_REPORT")
            end
            WeakAuras.ScanEvents("JT_WA_DEFILE_DEJAVU_REPORT_BTN_HIDE")
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

aura_env.OnTrigger = function(event, ...)
    if event == "JT_WA_DEFILE_DEJAVU_REPORT_BTN_SHOW" then
        aura_env.creatOrShowButton()
        return true
    end
end

aura_env.OnHide = function(event, ...)
    if event == "JT_WA_DEFILE_DEJAVU_REPORT_BTN_HIDE" then
        aura_env.hideButton()
        return true
    elseif event == "PLAYER_REGEN_DISABLED" then
        aura_env.hideButton()
        return true
    end
end