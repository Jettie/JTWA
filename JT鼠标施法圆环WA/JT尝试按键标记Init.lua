-- 版本信息
local version = 250816

local _, myClass = UnitClass("player")

aura_env.mySQW = 0

local displayName = "GCD_Mark"

local markWidth = 0.01
local thickMarkWidth = 0.02
local isMarking = false
local numOfMark = 0
local isThisSQWWorked = false
local markInFourHundredMs = 0
local markOutFourHundredMs = 0

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
        if aura_env.config.enableClass then
            return aura_env.config.enableClass[enableClassStringToOptionId[myClass]] or false
        end
    end
    return false
end
local isEnabled = isEnabledClass()

--[[ 自定义变量
{
    additionalProgress = 1,
    expirationTime = true,
    duration = true,
    value = true,
    total = true,
    inSQW = {
        display = "JT延迟容限区间",
        type = "bool",
    },
}
]]

local markNow = function(e, inSQW, duration, expirationTime, spellQueueWindowTime, isInFourHundredMs)
    numOfMark = numOfMark + 1
    isThisSQWWorked = inSQW or isThisSQWWorked

    -- 400ms内按键的统计数据
    if isInFourHundredMs then
        markInFourHundredMs = markInFourHundredMs + 1
    else
        markOutFourHundredMs = markOutFourHundredMs + 1
    end

    local thisWidth = inSQW and thickMarkWidth or markWidth
    local now = GetTime()
    local markMin = math.floor((expirationTime - now)*1000) / 1000
    local markMax = markMin + thisWidth

    e[numOfMark] = {
        name = displayName,
        progressType = "timed",
        autoHide = true,
        duration = duration,
        expirationTime = expirationTime,
        inSQW = inSQW,
        additionalProgress = {
            [1] = {
                min = markMin,
                max = markMax,
            }
        },
        show = true,
        changed = true,
    }
    return true
end

local OnStart = function(e, event, ...)
    -- WeakAuras.ScanEvents("JT_GCD_MONITOR_MARK_START", startTime, castTime, castExpirationTime, spellQueueWindowTime)
    local startTime, castTime, castExpirationTime, spellQueueWindowTime, realLatencyTime = ...

    isMarking = true

    -- 发送记录的事件 上个GCD的统计数据
    if aura_env.config.enableAnalysis and numOfMark > 0 then
        WeakAuras.ScanEvents("JT_GCD_MONITOR_ANALYSIS_RECORD", isThisSQWWorked, markInFourHundredMs, markOutFourHundredMs, spellQueueWindowTime, realLatencyTime)
    end
    -- clearAllData
    numOfMark = 0
    markInFourHundredMs = 0
    markOutFourHundredMs = 0
    isThisSQWWorked = false
end

local OnStop = function(e, event, ...)
    isMarking = false

    -- clearAllData
    numOfMark = 0
    markInFourHundredMs = 0
    markOutFourHundredMs = 0

    for k, v in pairs(e) do
        if k then
            v.show = false
            v.changed = true
        end
    end
    return true
end

local OnMark = function(e, event, ...)
    local inSQW, duration, expirationTime, spellQueueWindowTime, isInFourHundredMs = ...
    if isMarking then
        return markNow(e, inSQW, duration, expirationTime, spellQueueWindowTime, isInFourHundredMs)
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if not isEnabled then
        return
    end
    if event == "JT_GCD_MONITOR_MARK_START" then
        OnStart(e, event, ...)
    elseif event == "JT_GCD_MONITOR_MARK" then
        return OnMark(e, event, ...)

    elseif event == "JT_GCD_MONITOR_STOP" then
        return OnStop(e, event, ...)
    end
end