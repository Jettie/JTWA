--版本信息
local version = 250524

local validEncounterIds = {
    [853] = true, -- 鲜血女王兰娜瑟尔
}

local timeToStartVanishBarIn25 = 223.3 -- 25人 -- 正式 第一次+100.3秒后开始消失进度条
local timeToStartVanishBarIn10 = 239.3 -- 10人 
-- local timeToStartVanishBar = 20 -- 测试3秒

-- 10人比25人快5秒
local getThisVanishBarTime = function()
    local difficultyID = select(3,GetInstanceInfo())
    if difficultyID == 3 or difficultyID == 5 then
        return timeToStartVanishBarIn10
    else
        return timeToStartVanishBarIn25
    end
end

local bossName = "鲜血女王兰娜瑟尔"
local bossSpellId = 73070

-- zhTW
local bossName_TW = "血腥女王菈娜薩爾"
if GetLocale() == "zhTW" then bossName = bossName_TW end

local timer = nil

local OnEncounterStart = function(event, ...)
    local encounterID, encounterName, difficultyID, groupSize = ...
    if validEncounterIds[encounterID] then
        if timer and not timer:IsCancelled() then
            timer:Cancel()
        end

        timer = C_Timer.NewTimer(getThisVanishBarTime(), function()
            local fakeEvent = "JT_CUSTOM_CLEU"
            local timestamp = GetServerTime()
            local subevent = "SPELL_CAST_START"
            local hideCaster = false
            local sourceGUID = "JT-Fake-sourceGUID"
            local sourceName = bossName
            local sourceFlags = 2632
            local sourceRaidFlags = 0
            local destGUID = "JT-Fake-destGUID"
            local destName = UnitName("player")
            local destFlags = 1297
            local destRaidFlags = 0
            local fakeSpellId = bossSpellId
            local spellName = "测试法术"
            local spellSchool = 1

            --伪造一个JT_CUSTOM_CLEU的EVENT
            WeakAuras.ScanEvents(fakeEvent,timestamp,subevent,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,fakeSpellId,spellName,spellSchool)
        end)

        -- return true
    end
end

local OnEncounterEnd = function(event, ...)
    local encounterID, encounterName, difficultyID, groupSize = ...
    if validEncounterIds[encounterID] then
        if timer and not timer:IsCancelled() then
            timer:Cancel()
        end
        -- return true
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "ENCOUNTER_START" or event == "JT_FAKE_TIMER_ENCOUNTER_START" then
        return OnEncounterStart(event, ...)
    elseif event == "ENCOUNTER_END" or event == "JT_FAKE_TIMER_ENCOUNTER_END" then
        return OnEncounterEnd(event, ...)
    end
end