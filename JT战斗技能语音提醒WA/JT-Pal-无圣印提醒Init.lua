-- 版本信息
local version = 250602

-- 圣印
local sealSpellIds = {
    [348704] = true, -- 腐蚀圣印
    [31801] = true, -- 复仇圣印
    [20375] = true, -- 命令圣印
    [21084] = true, -- 正义圣印
    [20164] = true, -- 公正圣印
    [20165] = true, -- 光明圣印
    [20166] = true, -- 智慧圣印
}

local checkSeal = function()
    local hasSeal = false
    for spellId in pairs(sealSpellIds) do
        if WA_GetUnitBuff("player", spellId) then
            -- print("seal found")
            hasSeal = true
            break
        end
    end
    -- print("seal ? ", hasSeal)
    return hasSeal
end

local delayedAlert = function()
    C_Timer.After(2.5, function()
            if not checkSeal() then
                WeakAuras.ScanEvents("JT_PAL_SEAL_NOT_FOUND")
            end
    end)
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_PAL_SEAL_NOT_FOUND"then
        return not checkSeal()
    elseif event == "PLAYER_REGEN_DISABLED" then
        delayedAlert()
    end
end

