-- 版本信息
local version = 250606

local mhBarName = "主手"
local ohBarName = "副手"
local defaultBarName = "普攻"

local thisSpellId = 53385 -- 神圣风暴
local gcdSpellId = 61304 -- GCD

local myGUID = UnitGUID("player")


local createBar = function(e, barName, duration, isSwingFirst)
    barName = barName or defaultBarName
    duration = duration or 3
    if not e[barName] then
        e[barName] = {
            name = barName,
            autoHide = false,
            progressType = "timed",
            show = true,
        }
    end
    e[barName].duration = duration
    e[barName].expirationTime = duration + GetTime()
    e[barName].isSwingFirst = isSwingFirst
    e[barName].show = true
    e[barName].changed = true
    return true
end

local OnCLEUF = function(e, event, ...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if sourceGUID ~= myGUID then
        return
    end
    if subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED" then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)

        -- 神圣风暴CD情况
        local thisSpellCDStart, thisSpellCDDuration = GetSpellCooldown(thisSpellId)
        local thisSepllCDReadyTime = thisSpellCDStart + thisSpellCDDuration

        -- GCD情况
        local gcdStart, gcdDuration = GetSpellCooldown(gcdSpellId)
        local gcdReadyTime = gcdStart + gcdDuration

        local mhAttackSpeed, ohAttackSpeed = UnitAttackSpeed("player")
        local thisSpeed = isOffHand and ohAttackSpeed or mhAttackSpeed
        local thisSwingReadyTime = thisSpeed + GetTime()

        local nextSwingFirst = (thisSwingReadyTime < thisSepllCDReadyTime) and true or false

        if isOffHand then
            if ohAttackSpeed then
                return createBar(e, ohBarName, ohAttackSpeed, nextSwingFirst)
            end
        else
            if mhAttackSpeed then
                return createBar(e, mhBarName, mhAttackSpeed, nextSwingFirst)
            end
        end
    elseif subevent == "SPELL_CAST_SUCCESS" then
        local spellId, spellName, spellSchool = select(12, ...)
        if spellId == thisSpellId then
            C_Timer.After(0.1, function()
                WeakAuras.ScanEvents("JT_PAL_DIVINE_STORM_CAST")
            end)
        end
    end
end

local OnDivineStormCast = function(e, event, ...)
    -- 神圣风暴CD情况
    local thisSpellCDStart, thisSpellCDDuration = GetSpellCooldown(thisSpellId)
    local thisSepllCDReadyTime = thisSpellCDStart + thisSpellCDDuration

    -- GCD情况
    local gcdStart, gcdDuration = GetSpellCooldown(gcdSpellId)
    local gcdReadyTime = gcdStart + gcdDuration

    for barName, barData in pairs(e) do
        if barData and barData.show then
            local thisSwingReadyTime = barData.expirationTime
            local nextSwingFirst = (thisSwingReadyTime < thisSepllCDReadyTime) and true or false

            barData.isSwingFirst = nextSwingFirst
            barData.changed = true
        end
    end
    -- DevTools_Dump(e)
    return true
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, event, CombatLogGetCurrentEventInfo())
    elseif event == "JT_PAL_DIVINE_STORM_CAST" then
        return OnDivineStormCast(e, event, ...)
    end
end