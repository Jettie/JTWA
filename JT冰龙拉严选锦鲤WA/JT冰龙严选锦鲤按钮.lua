aura_env.show = true

local JTSindragosa = aura_env
JTSindragosa.btn = _G[aura_env.id]

--创建/显示按钮
aura_env.creatOrShowButton = function()
    if not JTSindragosa.btn then
        JTSindragosa.btn = CreateFrame("Button", aura_env.id, aura_env.region)
        JTSindragosa.btn:SetAllPoints()
        JTSindragosa.btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    JTSindragosa.btn:SetScript("OnClick", function(self, button, down)
            if button == "LeftButton" then
                WeakAuras.ScanEvents("JT_WA_SINDRAGOSA_SENDLIST")
            elseif button == "RightButton" then
                WeakAuras.ScanEvents("JT_WA_SINDRAGOSA_BTN_HIDE")
            end
    end)
    JTSindragosa.btn:Show()
end
aura_env.creatOrShowButton()
--隐藏按钮
aura_env.hideButton = function()
    if JTSindragosa.btn then
        JTSindragosa.btn:Hide()
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_WA_SINDRAGOSA_BTN_SHOW" then
        aura_env.show = true
    elseif event == "JT_WA_SINDRAGOSA_BTN_HIDE" then
        aura_env.show = false
    end
    return aura_env.show
end