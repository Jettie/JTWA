-- 版本信息
local version = 250816.3

--author and header
local AURA_ICON = 237538
local AURA_NAME = "JT鼠标施法圆环WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local HELLO_WORLD = HEADER_TEXT.."- 鼠标拖尾+GCD+施法条+延迟容限测试 - 作者:|R "..AUTHOR

print(HELLO_WORLD)

local _, myClass = UnitClass("player")

local gcdSpellId = 61304
local nameOfJTGCD = "JT_GCD_Circle"
local displayName = "GCD"

local lastGCDStartTime = 0.1

local forTimeFix = 0.02


aura_env.lastGCDDuration = 0
aura_env.lastExpirationTime = 0
aura_env.mySpellQueueWindow = 0

-- latencyData = {isSpellWithStart, sentTime, lastSentSpellId, timeDiff, lastCastChangeTime}
local latencyData = {
    isSpellWithStart = false,
}

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

-- 忽略频繁按键的下一次普攻附加技能
local ignoreActionSpellIdList = {
    -- 重殴
    [48480] = true,
    -- 英勇打击
    [47450] = true,
    -- 顺劈斩
    [47520] = true,
    -- 符文打击
    [56815] = true,
}

local ignoreActionSpellNameList = {}
local buildIgnoreActionSpellNameList = function()
    for spellId, _ in pairs(ignoreActionSpellIdList) do
        local name = GetSpellInfo(spellId)
        if name then
            ignoreActionSpellNameList[name] = true
        end
    end
end
buildIgnoreActionSpellNameList()

local isEnabledClass = function()
    if enableClassStringToOptionId[myClass] then
        if aura_env.config.enableClass then
            return aura_env.config.enableClass[enableClassStringToOptionId[myClass]] or false
        end
    end
    return false
end
local isEnabled = isEnabledClass()

-- JT Hook
local hookedVariableName = "JT_GCD_HOOKED_USEACTION"
if not _G[hookedVariableName] and isEnabled then
    local apiName = "UseAction"
    hooksecurefunc(apiName,function(self)
        local now = GetTime()
        local actionType, id, subType = GetActionInfo(self)
        WeakAuras.ScanEvents("JT_GCD_MONITOR_AB_CLICKED", actionType, id, subType)
    end)
    _G[hookedVariableName] = true
end

local isCastingMacro = function(macroText)
    if not macroText then
        return false
    end
    -- 将原字符串转换为小写（非ASCII字符如中文不受影响）
    local lowerStr = string.lower(macroText)
    -- 目标子串列表（包含需要检查的所有模式）
    local castCommands = {"/使用", "/施放", "/use", "/cast"}
    
    -- 遍历检查每个目标子串
    for _, target in ipairs(castCommands) do
        -- 检查转换后的字符串是否包含当前目标子串
        if string.find(lowerStr, target) then
            return true  -- 找到任意一个目标子串，立即返回true
        end
    end
    return false  -- 未找到任何目标子串，返回false
end

local getSQWValue = function()
    local sqwValue = GetCVar("SpellQueueWindow")
    local sqwValueNum = tonumber(sqwValue)
    if sqwValueNum then
        return sqwValueNum
    end
    return 0
end

local CreateGCDCircle = function(e, startTime, gcdDuration, gcdExpirationTime, spellQueueWindowTime, latencyWorld, realLatencyTime)
    if not e[nameOfJTGCD] then
        e[nameOfJTGCD] = {
            name = displayName,
            progressType = "timed",
        }
    end
    e[nameOfJTGCD].autoHide = true
    e[nameOfJTGCD].duration = gcdDuration
    e[nameOfJTGCD].expirationTime = gcdExpirationTime

    e[nameOfJTGCD].inSQW = false
    e[nameOfJTGCD].inSQWClicked = false
    e[nameOfJTGCD].showClickedText = false
    e[nameOfJTGCD].isCasting = false

    local latencyWorldTime = latencyWorld and math.max(0, latencyWorld/1000) or 0
    local thisLatency = realLatencyTime and math.max(0, realLatencyTime) or latencyWorldTime

    local ap = {
        [1] = {
            min = 0,
            max = gcdDuration - spellQueueWindowTime
        },
        [2] = {
            min = 0,
            max = thisLatency
        }
    }
    e[nameOfJTGCD].additionalProgress = ap

    e[nameOfJTGCD].show = true
    e[nameOfJTGCD].changed = true
    return true
end

--[[ 自定义变量
{
    additionalProgress = 2,
    expirationTime = true,
    duration = true,
    value = true,
    total = true,
    inSQW = {
        display = "JT延迟容限区间",
        type = "bool",
    },
    inSQWClicked = {
        display = "JT区间内点击",
        type = "bool",
    },
    showClickedText = {
        display = "JT显示OK",
        type = "bool",
    },
    isCasting = {
        display = "JT正在施法",
        type = "bool",
    }
}
]]

aura_env.OnTrigger = function(e, event, ...)
    if not isEnabled then
        return
    end
    if event == "PLAYER_REGEN_DISABLED" then
        aura_env.mySpellQueueWindow = getSQWValue()
        if aura_env.config.showSQWValue then
            WeakAuras.ScanEvents("JT_GCD_MONITOR_SQW_VALUE_DISPLAY", aura_env.mySpellQueueWindow)
        end
    elseif event == "JT_GCD_MONITOR_START" then
        local startTime, gcdDuration = GetSpellCooldown(gcdSpellId)

        if startTime == 0 or startTime == lastGCDStartTime then
            return
        end
        lastGCDStartTime = startTime

        local gcdExpirationTime = startTime + gcdDuration
        local now = GetTime()

        local diff = gcdExpirationTime - now
        local spellQueueWindowDelayTime = math.max(diff - math.max(0, aura_env.mySpellQueueWindow/1000), 0)
        
        aura_env.lastGCDDuration = gcdDuration
        aura_env.lastExpirationTime = gcdExpirationTime

        aura_env.mySpellQueueWindow = getSQWValue()
        local spellQueueWindowTime = math.max(gcdDuration - math.max(0, aura_env.mySpellQueueWindow/1000), 0)

        local latencyWorld = aura_env.config.showLatency and select(4, GetNetStats()) or 0
        local thisLatency = latencyWorld and math.max(0, latencyWorld/1000) or 0

        local realLatencyTime = latencyData.timeDiff and latencyData.timeDiff or 0
        realLatencyTime = realLatencyTime > 0 and realLatencyTime or thisLatency
        -- print("GCD S realLatencyTime:", realLatencyTime)
        WeakAuras.ScanEvents("JT_GCD_MONITOR_MARK_START", startTime, gcdDuration, gcdExpirationTime, aura_env.mySpellQueueWindow, realLatencyTime)

        C_Timer.After(spellQueueWindowDelayTime, function()
            WeakAuras.ScanEvents("JT_GCD_MONITOR_SQW_SHOW")
        end)

        if not (e[nameOfJTGCD] and e[nameOfJTGCD].expirationTime and e[nameOfJTGCD].expirationTime > gcdExpirationTime) then
            local latencyWorld = aura_env.config.showLatency and select(4, GetNetStats()) or 0
            return CreateGCDCircle(e, startTime, gcdDuration, gcdExpirationTime, spellQueueWindowTime, latencyWorld, realLatencyTime)
        end
    elseif event == "JT_GCD_MONITOR_STOP" then
        if e[nameOfJTGCD] then
            e[nameOfJTGCD].show = false
            e[nameOfJTGCD].changed = true
            return true
        end
    elseif event == "JT_GCD_MONITOR_SQW_SHOW" then
        if e[nameOfJTGCD] then
            local now = GetTime()
            if e[nameOfJTGCD].expirationTime and e[nameOfJTGCD].expirationTime > now then
                if e[nameOfJTGCD].expirationTime - aura_env.mySpellQueueWindow/1000 - forTimeFix <= now then
                    if not e[nameOfJTGCD].isCasting then
                        e[nameOfJTGCD].inSQW = true
                        e[nameOfJTGCD].changed = true
                        return true
                    end
                end
            end
        end
    elseif event == "JT_GCD_MONITOR_SQW_SHOW_ON_CAST" then
        if e[nameOfJTGCD] then
            local now = GetTime()
            if e[nameOfJTGCD].expirationTime and e[nameOfJTGCD].expirationTime > now then
                if e[nameOfJTGCD].expirationTime - aura_env.mySpellQueueWindow/1000 < now then
                    if e[nameOfJTGCD].isCasting then
                        e[nameOfJTGCD].inSQW = true
                        e[nameOfJTGCD].changed = true
                        return true
                    end
                end
            end
        end
    elseif event == "JT_GCD_MONITOR_AB_CLICKED" then
        local actionType, id, subType = ...
        if actionType == "spell" then
            local spellName = GetSpellInfo(id)
            if spellName and ignoreActionSpellNameList[spellName] then
                return
            end
        end
        if actionType == "macro" then
            local macroText = select(3,GetMacroInfo(id))
            if not isCastingMacro(macroText) then
                return
            end
        end
        if e[nameOfJTGCD] then
            local now = GetTime()
            if e[nameOfJTGCD].expirationTime then
                local inFourHundredMs = (e[nameOfJTGCD].expirationTime - now) < 0.4 and true or false
                if e[nameOfJTGCD].expirationTime > now then
                    if e[nameOfJTGCD].expirationTime - aura_env.mySpellQueueWindow/1000 < now then
                        if e[nameOfJTGCD].inSQW then
                            local duration = e[nameOfJTGCD].duration
                            local expirationTime = e[nameOfJTGCD].expirationTime
                            local spellQueueWindowTime = aura_env.mySpellQueueWindow/1000
                            WeakAuras.ScanEvents("JT_GCD_MONITOR_MARK", true, duration, expirationTime, spellQueueWindowTime, inFourHundredMs)

                            e[nameOfJTGCD].inSQWClicked = true
                            e[nameOfJTGCD].showClickedText = aura_env.config.showClickedText
                            e[nameOfJTGCD].changed = true
                            return true
                        end
                    end
                end

                local duration = e[nameOfJTGCD].duration
                local expirationTime = e[nameOfJTGCD].expirationTime
                local spellQueueWindowTime = aura_env.mySpellQueueWindow/1000
                WeakAuras.ScanEvents("JT_GCD_MONITOR_MARK", false, duration, expirationTime, spellQueueWindowTime, inFourHundredMs)
            end
        end
    elseif event == "UNIT_SPELLCAST_SENT" then
        local unit, target, castGUID, spellId = ...

        latencyData.isSpellWithStart = false

        latencyData.lastSentSpellId = spellId

        latencyData.sentTime = latencyData.lastCastChangeTime
        latencyData.lastCastChangeTime = nil
        -- print("1_SENT","latencyData.lastSentSpellId:", latencyData.lastSentSpellId,"latencyData.sentTime:", latencyData.sentTime)

    elseif event == "UNIT_SPELLCAST_START" then
        local unitTarget, castGUID, spellId = ...
        if unitTarget ~= "player" then return end

        -- 施法延迟部分
        if spellId == latencyData.lastSentSpellId then
            latencyData.isSpellWithStart = true
        end

        if latencyData.sentTime then
            latencyData.timeDiff = GetTime() - latencyData.sentTime
            latencyData.sentTime = nil
            -- print("2_START", "|cffff53a2latencyData.timeDiff|r:", latencyData.timeDiff)
        else
            -- print("2_START","latencyData.sentTime is nil")
        end

        -- print("UNIT_SPELLCAST_START", unitTarget, castGUID, spellId)
        local spell, displayName, icon, startTime, endTime, _, _, notInterruptible = UnitCastingInfo("player")
        -- print("spell=", spell, "displayName=", displayName, "icon=", icon, "startTime=", startTime, "endTime=", endTime, "notInterruptible=", notInterruptible)

        -- print("aura_env.lastExpirationTime=", aura_env.lastExpirationTime)
        if endTime and endTime > aura_env.lastExpirationTime then
            
            -- 需要重新计算公共冷却，修改为施法条
            local now = GetTime()
            local castTime = (endTime - startTime) / 1000
            local castExpirationTime = endTime / 1000
            local spellQueueWindowDelayTime = math.max((castExpirationTime - now) - math.max(0, aura_env.mySpellQueueWindow/1000), 0)

            aura_env.mySpellQueueWindow = getSQWValue()
            local spellQueueWindowTime = math.max(castTime - math.max(0, aura_env.mySpellQueueWindow/1000), 0)

            local latencyWorld = aura_env.config.showLatency and select(4, GetNetStats()) or 0
            local thisLatency = latencyWorld and math.max(0, latencyWorld/1000) or 0

            if e[nameOfJTGCD] and e[nameOfJTGCD].expirationTime > now then
                e[nameOfJTGCD].duration = castTime

                e[nameOfJTGCD].expirationTime = castExpirationTime
                e[nameOfJTGCD].additionalProgress = {
                    [1] = {
                        min = 0,
                        max = castTime - spellQueueWindowTime
                    },
                    [2] = {
                        min = 0,
                        max = thisLatency
                    }
                }

                e[nameOfJTGCD].isCasting = true

                e[nameOfJTGCD].show = true
                e[nameOfJTGCD].changed = true

                -- 发出输出给尝试施放标记做时间轴
                local realLatencyTime = latencyData.timeDiff and latencyData.timeDiff or 0
                realLatencyTime = realLatencyTime > 0 and realLatencyTime or thisLatency
                -- print("USC S realLatencyTime:", realLatencyTime)
                WeakAuras.ScanEvents("JT_GCD_MONITOR_MARK_START", startTime, castTime, castExpirationTime, aura_env.mySpellQueueWindow, realLatencyTime)

                C_Timer.After(spellQueueWindowDelayTime, function()
                    WeakAuras.ScanEvents("JT_GCD_MONITOR_SQW_SHOW_ON_CAST")
                end)

                return true
            elseif not e[nameOfJTGCD] then
                if endTime > now + 0.1 then
                    if startTime > 0 and startTime ~= lastGCDStartTime then
                        WeakAuras.ScanEvents("JT_GCD_MONITOR_START")
                        WeakAuras.ScanEvents("JT_GCD_MONITOR_WASTE_STOP")
                    end
                    -- return CreateGCDCircle(e, startTime, castTime, castExpirationTime, spellQueueWindowTime)
                end
            end
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitTarget, castGUID, spellId = ...
        if unitTarget ~= "player" then return end
        local startTime, gcdDuration = GetSpellCooldown(gcdSpellId)
        if startTime > 0 and startTime ~= lastGCDStartTime then
            WeakAuras.ScanEvents("JT_GCD_MONITOR_START")
            WeakAuras.ScanEvents("JT_GCD_MONITOR_WASTE_STOP")
        end

        -- 施法延迟部分
        if spellId == latencyData.lastSentSpellId then
            if not latencyData.isSpellWithStart then
                if latencyData.sentTime then
                    -- setSQW(50)
                    latencyData.timeDiff = GetTime() - latencyData.sentTime
                    latencyData.sentTime = nil
                    -- print("3_SUCCEEDED", "|cffff53a2latencyData.timeDiff|r:", latencyData.timeDiff)
                else
                    -- print("3_SUCCEEDED","no latencyData.sentTime and latencyData.sentTime is nil")
                end
            end
        else
            -- print("3_SUCCEEDED","spellId is not latencyData.lastSentSpellId",spellId,latencyData.lastSentSpellId)
        end
        latencyData.sentTime = nil
        latencyData.lastSentSpellId = nil
        -- print("3_SUCCEEDED","latencyData.sentTime set to nil")

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unitTarget, castGUID, spellId = ...
        if unitTarget ~= "player" then return end
        -- 把所有states隐藏
        if e[nameOfJTGCD] then
            e[nameOfJTGCD].show = false
            e[nameOfJTGCD].changed = true
            return true
        end
    elseif event == "CURRENT_SPELL_CAST_CHANGED" then
        local cancelledCast = ...

        -- 施法延迟部分
        latencyData.lastCastChangeTime = GetTime()

        -- print("7_CHANGED",latencyData.lastCastChangeTime)
    end
end