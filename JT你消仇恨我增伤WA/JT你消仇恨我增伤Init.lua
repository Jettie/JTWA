-- 版本信息
local version = 250602

aura_env.barid = "ToTThreatBar"

aura_env.ToTSourceName = nil
aura_env.msgCancelMacro = true
aura_env.ToTCountInCombat = 0

local totDamageBuffId = 57933 --嫁祸增伤
--totDamageBuffId = 48659 --佯攻测试

aura_env.ToTThreatBuffId = 59628 --嫁祸仇恨转移
--aura_env.ToTThreatBuffId = 6774 --切割测试

--check talent for tank
local _, class = UnitClass("player")

local isTanking = function()
    if class == "DRUID" then
        if GetShapeshiftFormID() == 8 then
            return true
        else
            return false
        end
    elseif class == "DEATHKNIGHT" then
        if WA_GetUnitBuff("player",48263) then
            return true
        else
            return false
        end
    elseif class == "WARRIOR" then
        local offHandItemId = GetInventoryItemID("player", 17)
        if offHandItemId then
            if select(9,GetItemInfo(offHandItemId)) == "INVTYPE_SHIELD" then
                return true
            end
        end
        return false
    end
    return false
end
aura_env.isTanking = isTanking

function aura_env.e(e, barid, show, progressType, total, value, name, icon)
    e[barid] = {
        name = name,
        icon = icon,
        show = show,
        totThreatBuffStatus = true,
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

local OnCLEUF = function(e, event, ...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        local spellId, spellName, spellSchool = select(12, ...)
        if spellId == totDamageBuffId then
            local targetName = splitString(destName,"-") and splitString(destName,"-") or destName
            if targetName == UnitName("player") then
                aura_env.ToTSourceName = splitString(sourceName,"-") and splitString(sourceName,"-") or sourceName

                if aura_env.ToTSourceName then
                    local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = WA_GetUnitBuff(aura_env.ToTSourceName, aura_env.ToTThreatBuffId)
                    local displayText = classColorName(aura_env.ToTSourceName)
                    aura_env.e(e, aura_env.barid, true, "timed", duration, expirationTime, displayText, icon)
                    return true
                end
            end
        end

    elseif subevent == "SPELL_AURA_REMOVED" then
        local spellId, spellName, spellSchool = select(12, ...)
        if spellId == aura_env.ToTThreatBuffId then
            local rogueName = splitString(sourceName,"-") and splitString(sourceName,"-") or sourceName
            if rogueName == aura_env.ToTSourceName then
                if e[aura_env.barid].expirationTime > GetTime() + 0.1 and not UnitIsDead(aura_env.ToTSourceName) then

                    e[aura_env.barid].totThreatBuffStatus = false
                    e[aura_env.barid].duration = 2
                    e[aura_env.barid].expirationTime = 2 + GetTime()
                    e[aura_env.barid].changed = true

                    aura_env.msgCancelMacro = false
                    return true
                end
            end
        end
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, event, CombatLogGetCurrentEventInfo())
    elseif event == "PLAYER_REGEN_ENABLED" then
        aura_env.ToTCountInCombat = 0
    end
end