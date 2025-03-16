local IAYGF = aura_env

aura_env.show = true

local IAmYourGrandFather = false

--创建/显示按钮

local createButton = function()
    if not IAYGF.btn then
        IAYGF.btn = CreateFrame("Button", aura_env.id, aura_env.region)
        IAYGF.btn:SetAllPoints()
        IAYGF.btn:SetScript("OnClick", function(self, button, down)
            WeakAuras.ScanEvents("JT_IAYGF_TOGGLE")
        end)

        IAYGF.btn:RegisterForClicks("LeftButtonUp")
        IAYGF.btn:SetPassThroughButtons("RightButton")
    end
end
createButton()

aura_env.showButton = function()
    if not IAYGF.btn then
        createButton()
    end
    IAYGF.btn:SetScript("OnClick", function(self, button, down)
        WeakAuras.ScanEvents("JT_IAYGF_TOGGLE")
    end)
    IAYGF.btn:EnableMouse(true)
    IAYGF.btn:Show()
end
aura_env.showButton()

--隐藏按钮
aura_env.hideButton = function()
    if IAYGF.btn and IAYGF.btn:IsShown() then
        IAYGF.btn:EnableMouse(false)
        IAYGF.btn:Hide()
    end
end

aura_env.getTexture = function()
    if IAmYourGrandFather then
        return "common-icon-checkmark" --"voicechat-icon-speaker-mute" --"common-icon-checkmark"
    else
        return "" --voicechat-icon-speaker
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_WP_BUTTON" then
        aura_env.show, IAmYourGrandFather = ...
        if aura_env.show then
            aura_env.showButton()
        end
        return aura_env.show
    -- elseif event == "OPTIONS_CLOSE" or event == "STATUS" then
    --     if show then
    --         aura_env.showButton()
    --     end
    --     return show
    end
end

aura_env.OnHide = function(event, ...)
    if event == "JT_WP_BUTTON" then
        aura_env.show, IAmYourGrandFather = ...
        if not aura_env.show then
            aura_env.hideButton()
        end
        return not aura_env.show
    end
end