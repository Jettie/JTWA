-- 版本信息
local version = 250327

local targetNames = {}

local buttonIdToName = {
    [1] = "JTA",
    [2] = "JTB",
    [3] = "JTX",
    [4] = "JTY",
}

local buddyBuffIds = {
    --[18499] = true, --测试，狂暴之怒
    [12292] = aura_env.config.enableDeathWish, --死亡之愿

    [12880] = aura_env.config.enableEnrage, --激怒1/5
    [14201] = aura_env.config.enableEnrage, --激怒2/5
    [14202] = aura_env.config.enableEnrage, --激怒3/5
    [14203] = aura_env.config.enableEnrage, --激怒4/5
    [14204] = aura_env.config.enableEnrage, --激怒5/5

    [31884] = aura_env.config.enableAvengingWrath, --复仇之怒

    [49016] = aura_env.config.enableHysteria, --邪恶狂热
    --[29131] = true --测试，血性狂暴
}

local createBar = function(e, barid, show, progressType, total, value, name, icon)
    e[barid] = {
        name = name,
        icon = icon,
        show = show,
        totTarget = barid,
        changed = true
    }

    if show and progressType then
        e[barid].progressType = progressType
        if progressType == "timed" then
            e[barid].autoHide = true
            e[barid].duration = total
            e[barid].expirationTime = value and value or total + GetTime()

        elseif progressType == "static" then
            e[barid].total = total
            e[barid].value = value
        end
    end
end

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unit)
    if unit and UnitExists(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if not class then
            return name
        else
            local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unit
    end
end

local splitString = function(str, separator)
    local index = string.find(str, separator)
    if index then
        local part1 = string.sub(str, 1, index - 1)
        local part2 = string.sub(str, index + 1)
        return part1, part2
    else
        return
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
        if ( subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" ) then
            local spellId, spellName, spellSchool, auraType, amount = select(12, ...)

            local focusName = UnitName("focus")
            local unitName = splitString(destName,"-") and splitString(destName,"-") or destName

            if unitName and buddyBuffIds[spellId] then
                local barid
                if unitName == focusName then
                    barid = "F"
                else
                    for k, v in pairs(targetNames) do
                        if v == unitName then
                            barid = buttonIdToName[k]
                            break
                        end
                    end
                end

                if barid then
                    --战士+狂热的判断
                    if spellId == 49016 then
                        local _, unitClass = UnitClass(unitName)
                        if unitClass ~= "WARRIOR" then
                            return false
                        end
                    end

                    local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = WA_GetUnitBuff(unitName, spellId)

                    local displayText = classColorName(unitName)

                    createBar(e, barid, true, "timed", duration, expirationTime, displayText, icon)
                    return true
                end
            end
        end
    end
end

aura_env.updateTargetName = function(event, ...)
    if event == "JT_TOT_UPDATE_TARGET" then
        local id, setSpellShortName, setTargetName, isMissing = ...
        if id and setTargetName then
            targetNames[id] = setTargetName
        end
    end
end