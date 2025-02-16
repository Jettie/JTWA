aura_env.jhTarget = {
    A = nil,
    B = nil
}

aura_env.BuffIds = {
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

function aura_env.e(e, barid, show, progressType, total, value, name, icon)
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
aura_env.classColorName = function(unit)
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

aura_env.splitString = function(str, separator)
    local index = string.find(str, separator)
    if index then
        local part1 = string.sub(str, 1, index - 1)
        local part2 = string.sub(str, index + 1)
        return part1, part2
    else
        return
    end
end

