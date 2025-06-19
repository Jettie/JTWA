-- 版本信息
local version = 250530

local mhBarName = "主手"
local ohBarName = "副手"

local myGUID = UnitGUID("player")

local createBar = function(e, barName, duration)
    barName = barName or "普攻"
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
        local mhAttackSpeed, ohAttackSpeed = UnitAttackSpeed("player")
        if isOffHand then
            if ohAttackSpeed then
                return createBar(e, ohBarName, ohAttackSpeed)
            end

        else
            if mhAttackSpeed then
                return createBar(e, mhBarName, mhAttackSpeed)
            end
        end
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, event, CombatLogGetCurrentEventInfo())
    end
end