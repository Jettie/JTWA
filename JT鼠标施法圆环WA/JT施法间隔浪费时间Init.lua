
local _, myClass = UnitClass("player")

local gcdSpellId = 61304
local nameOfJTGCDWaste = "JT_GCD_Waste_Circle"
local displayName = "浪费"

local ignoreAndInvisibileTime = 0.05

local delayHide = 0.5

local enableClassStringToOptionId = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["DEATHKNIGHT"] = 3,
    ["HUNTER"] = 4,
    ["SHAMAN"] = 5,
    ["DRUID"] = 6,
    ["ROGUE"] = 7,
    ["MAGE"] = 8,
    ["PRIEST"] = 9,
    ["WARLOCK"] = 10,
    ["MONK"] = 11,
    ["DEMONHUNTER"] = 12,
}

local isEnabledClass = function()
    if enableClassStringToOptionId[myClass] then
        if aura_env.config.enableWasteClass then
            return aura_env.config.enableWasteClass[enableClassStringToOptionId[myClass]] or false
        end
    end
    return false
end
local isEnabled = isEnabledClass()

local CreateGCDCircle = function(e, startTime, gcdDuration)
    if not e[nameOfJTGCDWaste] then
        e[nameOfJTGCDWaste] = {
            name = displayName,
            progressType = "timed",
        }
    end
    e[nameOfJTGCDWaste].autoHide = true
    e[nameOfJTGCDWaste].duration = gcdDuration
    e[nameOfJTGCDWaste].expirationTime = startTime + gcdDuration

    e[nameOfJTGCDWaste].wasteTime = 0
    e[nameOfJTGCDWaste].showWasteTime = false

    e[nameOfJTGCDWaste].visible = false

    e[nameOfJTGCDWaste].sqw = GetCVar("SpellQueueWindow")

    e[nameOfJTGCDWaste].show = true
    e[nameOfJTGCDWaste].changed = true
    return true
end

--[[ 自定义变量
{
    expirationTime = true,
    duration = true,
    value = true,
    total = true,
    visible = {
        display = "JT开始显示浪费圈",
        type = "bool",
    },
    showWasteTime = {
        display = "JT显示浪费时间",
        type = "bool",
    },
    wasteTime = {
        display = "JT浪费时间",
        type = "number",
    },
}
]]

aura_env.OnTrigger = function(e, event, ...)
    if not isEnabled then
        return
    end
    if event == "JT_GCD_MONITOR_WASTE_START" then
        local lastGCDDuration = ...
        local nowTime = GetTime()
        local gcdStartTime, gcdDuration = GetSpellCooldown(gcdSpellId)
        
        -- print("nowTime=", nowTime, "gcdStartTime=", gcdStartTime, "gcdDuration=", gcdDuration)
        if gcdStartTime == 0 or nowTime > (gcdStartTime + ignoreAndInvisibileTime) then
            C_Timer.After(ignoreAndInvisibileTime, function()
                WeakAuras.ScanEvents("JT_GCD_MONITOR_WASTE_VISIBLE")
            end)
            return CreateGCDCircle(e, nowTime, lastGCDDuration)
        end
    elseif event == "JT_GCD_MONITOR_WASTE_VISIBLE" then
        if e[nameOfJTGCDWaste] then
            e[nameOfJTGCDWaste].visible = true
            e[nameOfJTGCDWaste].changed = true
            return true
        end
    elseif event == "JT_GCD_MONITOR_WASTE_STOP" then
        if e[nameOfJTGCDWaste] then
            local nowTime = GetTime()
            if e[nameOfJTGCDWaste].expirationTime then
                -- print("nowTime=", nowTime, "exptime=", e[nameOfJTGCDWaste].expirationTime)
                if nowTime < e[nameOfJTGCDWaste].expirationTime then
                    
                    local remainingTime = e[nameOfJTGCDWaste].expirationTime - nowTime
                    local wasteTime = e[nameOfJTGCDWaste].duration - remainingTime
                    -- print("浪费圈暂停 浪费时间:", wasteTime)
                    e[nameOfJTGCDWaste].wasteTime = 0 - math.floor(wasteTime * 100) / 100

                    if wasteTime > ignoreAndInvisibileTime then
                        e[nameOfJTGCDWaste].showWasteTime = true
                        WeakAuras.ScanEvents("JT_GCD_MONITOR_WASTETIME_SHOW")
                    end

                    e[nameOfJTGCDWaste].paused = true
                    e[nameOfJTGCDWaste].remaining = remainingTime
                    e[nameOfJTGCDWaste].changed = true

                    C_Timer.After(delayHide, function()
                        WeakAuras.ScanEvents("JT_GCD_MONITOR_WASTE_CLEAR")
                    end)
                    return true
                end
            end
            -- print("没有浪费圈了，或者当前圈已经结束")
            e[nameOfJTGCDWaste].show = false
            e[nameOfJTGCDWaste].changed = true
            return true
        end
    elseif event == "JT_GCD_MONITOR_WASTE_CLEAR" then
        if e[nameOfJTGCDWaste] then
            e[nameOfJTGCDWaste].show = false
            e[nameOfJTGCDWaste].changed = true
            return true
        end
    end
end