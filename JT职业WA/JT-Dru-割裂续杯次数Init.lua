-- 版本信息
local version = 250822

local myGUID = UnitGUID("player")
local myName = UnitName("player")

local ripSpellId = 49800
local ripSpellName = GetSpellInfo(ripSpellId) or "割裂"

local shredGlyphId = 54815
local shredSpellId = 48572
local shredSpellName = GetSpellInfo(shredSpellId) or "撕碎"

local ripTargets = {}

--[[
{
    renewUsed = {
        display = "已经续杯",
        type = "bool",
    },
}
]]

local checkGlyph = function(checkGlyphId)
    if not checkGlyphId then return end
    local glyphInSocket = {}
    for i = 1, GetNumGlyphSockets() do
        local id = select(4,GetGlyphSocketInfo(i))
        if id then
            glyphInSocket[id] = true
        end
    end
    return glyphInSocket[checkGlyphId]
end
local hasShredGlyph = checkGlyph(shredGlyphId)

local barNames = {
    [1] = "1",
    [2] = "2",
    [3] = "3",
}

local createBars = function(e, ripData)
    if ripData and next(ripData) then
        local guid = ripData.guid
        local destName = ripData.destName
        local spellId = ripData.spellId
        local duration = ripData.duration
        local expirationTime = ripData.expirationTime
        local maxRenewCount = ripData.maxRenewCount
        local renewCount = ripData.renewCount

        local show = true
        local now = GetTime()
        if now > expirationTime then
            ripTargets[guid] = nil
            show = false
        end
        for i, barName in ipairs(barNames) do
            if not e[barName] then
                e[barName] = {
                    guid = guid,
                    barName = barName,
                    index = i,
                }
            end
            
            local bar = e[barName]
            bar.maxRenewCount = maxRenewCount
            bar.renewCount = renewCount

            bar.renewUsed = (renewCount >= i) and true or false

            bar.show = show
            bar.changed = true
            -- print("created", barName, bar.renewUsed)
        end
        return true
    end
end

local OnCLEUF = function(e, event, ...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, arg13, arg14, arg15, arg16 = ...
    if sourceGUID ~= myGUID then return end

    if not hasShredGlyph then return end

    if subevent == "SPELL_CAST_SUCCESS" then
        local thisSpellName = GetSpellInfo(spellId)
        if thisSpellName == shredSpellName then
            local ripData = ripTargets[destGUID]
            if ripData then
                ripData.renewCount = (ripData.renewCount < ripData.maxRenewCount) and ripData.renewCount + 1 or ripData.maxRenewCount
                local nowExpirationTime = select(6, GetSpellCooldown(ripData.spellId))
                ripData.expirationTime = nowExpirationTime or ripData.expirationTime
                -- print("割裂续杯："..destName)
                createBars(e, ripData)
                return true
            end
        end
    elseif subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        local thisSpellName = GetSpellInfo(spellId)
        if thisSpellName == ripSpellName then
            local name, icon, count, debuffType, duration, expirationTime, caster, isStealable = WA_GetUnitDebuff("target", spellId)
            local now = GetTime()
            if name then
                local ripData = {
                    guid = destGUID,
                    destName = destName,
                    spellId = spellId,
                    duration = duration,
                    expirationTime = expirationTime,
                    maxRenewCount = 3,
                    renewCount = 0,
                }

                ripTargets[destGUID] = ripData

                if destGUID == UnitGUID("target") then
                    -- print("割裂成功："..destName)
                    createBars(e, ripData)
                    return true
                end
            end
        end
    elseif subevent == "SPELL_AURA_REMOVED" then
        local thisSpellName = GetSpellInfo(spellId)
        if thisSpellName == ripSpellName then
            ripTargets[destGUID] = nil
            for i, barName in ipairs(barNames) do
                local bar = e[barName]
                if bar and bar.guid == destGUID then
                    bar.show = false
                    bar.changed = true
                    -- print("割裂结束："..destName)
                end
            end
            return true
        end
    end
end

local OnPlayerTargetChanged = function(e, event, ...)
    local guid = UnitGUID("target")
    if guid then
        local ripData = ripTargets[guid]
        if ripData then
            -- print("目标切换："..ripData.destName)
            createBars(e, ripData)
            return true
        end
    end

    for k, v in pairs(e) do
        v.show = false
        v.changed = true
    end
    return true
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, event, CombatLogGetCurrentEventInfo())
    elseif event == "PLAYER_TARGET_CHANGED" then
        return OnPlayerTargetChanged(e, event, ...)
    end
end