aura_env.region.configGroup = "energy_bar"

-- 版本信息
local version = 250812

-- spellIds
local catFormId = 768
local shredId = 48572
local rakeId = 48574
local ripId = 49800

local defaultShredCost = 42
local defaultRakeCost = 35
local defaultRipCost = 25

local clearCastingBuffId = 16870

local stateName = ""

local checkOnlyOnceWithoutClearCastingBuff = false
local hasClearCastingBuff = false

--[[
{
    hasClearCastingBuff = {
        display = "检查能耗时有节能",
        type = "bool",
    },
    shredCost = {
        display = "撕碎消耗能量",
        type = "number",
    },
    rakeCost = {
        display = "斜掠消耗能量",
        type = "number",
    },
    ripCost = {
        display = "割裂消耗能量",
        type = "number",
    },
}
]]

aura_env.OnTrigger = function(e, event, ...)
    local unitTarget, castGUID, spellID = ...
    if event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_SPELLCAST_SUCCEEDED" and spellID == catFormId) or (event == "UNIT_SPELLCAST_SUCCEEDED" and spellID == shredId and checkOnlyOnceWithoutClearCastingBuff) then


        hasClearCastingBuff = WA_GetUnitBuff("player", clearCastingBuffId) and true or false

        if not hasClearCastingBuff and spellID == shredId then
            checkOnlyOnceWithoutClearCastingBuff = false
        end

        if not e[stateName] then
            e[stateName] = {
                shredCost = defaultShredCost,
                rakeCost = defaultRakeCost,
                ripCost = defaultRipCost,
                show = true,
                changed = true,
            }
        end

        local shredCost = hasClearCastingBuff and defaultShredCost or GetSpellPowerCost(shredId)[1].cost
        local rakeCost = hasClearCastingBuff and defaultRakeCost or GetSpellPowerCost(rakeId)[1].cost
        local ripCost = hasClearCastingBuff and defaultRipCost or GetSpellPowerCost(ripId)[1].cost

        e[stateName].hasClearCastingBuff = hasClearCastingBuff
        e[stateName].shredCost = shredCost
        e[stateName].rakeCost = rakeCost
        e[stateName].ripCost = ripCost

        e[stateName].changed = true
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- 进入战斗后检测一次没有节能BUFF的撕碎释放
        checkOnlyOnceWithoutClearCastingBuff = true
    end

    return true
end




