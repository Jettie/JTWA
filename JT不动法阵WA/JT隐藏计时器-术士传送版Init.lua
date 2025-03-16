--版本信息
aura_env.version = 250313

local vanishIcon = 237560

--EncounterID 
local curEncounterID = 0
local timeToVanish = 3
aura_env.timeToVanish = 3

aura_env.enableBtn = true

--MessageText
local triggerMessage = {
    [629] = {
        [1] = {
            text = "当下一名斗士出场时，空气都会为之冻结！它是冰吼，胜或是死，勇士们！",
            time = 37,
            spellId = 66683,
        },
        [2] = {
            text = "%%s等着(%S+)，发出一阵震耳欲聋的怒吼！",
            time = 58,
            spellId = 66683,
        },
        --测试
        [3] = {
            text = "胡扯了半天",
            time = 6,
            spellId = 66683,
        },
    }
}

local triggerMessage_zhTW = {
    [629] = {
        [1] = {
            text = "下一場參賽者的出場連空氣都會為之凝結:冰嚎!戰個你死我活吧，勇士們!",
            time = 37,
            spellId = 66683,
        },
        [2] = {
            text = "%%s怒視著(%S+)，並發出震耳的咆哮!",
            time = 58,
            spellId = 66683,
        },
        --测试
        [3] = {
            text = "胡扯了半天",
            time = 6,
            spellId = 66683,
        },
    }
}

--zhTW
if GetLocale() == "zhTW" then
    triggerMessage = triggerMessage_zhTW
end

--For JT_FAKE_CLEU --3秒预警，1秒读条
local testTriggerSpellId = {
    [47893] = "冰吼", --邪甲术 4级
    [47892] = "冰吼", --邪甲术 3级
    [28189] = "冰吼", --邪甲术 3级
    [28176] = "冰吼", --邪甲术 1级
}

local skillData = {
    [0] = { --野外测试
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
}
--测试假人
local testTarget = {
    ["大师的训练假人"] = true,
    ["专家的训练假人"] = true
}
aura_env.isTesting = false
local isTestTarget = function()
    local targetName = UnitName("target")
    if targetName then
        if testTarget[targetName] then
            aura_env.isTesting = true
            return true
        end
    end
    aura_env.isTesting = false
    return false
end
aura_env.fakeEvent = {}
aura_env.OnUnitSpellCastSucceeded = function(event, ...)
    local unitTarget, _, spellId = ...
    if unitTarget == "player" then
        if testTriggerSpellId[spellId] then
            if isTestTarget() then
                --及时刷新一个difficultyID，只在0野外的时候才能发测试JT_FAKE_CLEU
                --重要的数据是sourceName和fakeSpellId，另一边要用这两个数据对照才能通过
                local difficultyID = select(3,GetInstanceInfo())
                if difficultyID == 0 then
                    WeakAuras.ScanEvents("JT_TEST_MSG", "JT说了一句什么话，胡扯了半天？")
                    aura_env.fakeEvent = {
                        fakeEvent = "JT_FAKE_CLEU",
                        timestamp = GetServerTime(),
                        subevent = "SPELL_CAST_START",
                        hideCaster = false,
                        sourceGUID = "JT-Fake-sourceGUID",
                        sourceName = testTriggerSpellId[spellId],
                        sourceFlags = 2632,
                        sourceRaidFlags = 0,
                        destGUID = "JT-Fake-destGUID",
                        destName = UnitName("player"),
                        destFlags = 1297,
                        destRaidFlags = 0,
                        fakeSpellId = skillData[difficultyID][testTriggerSpellId[spellId]] and skillData[difficultyID][testTriggerSpellId[spellId]].spellId,
                        spellName = "测试法术",
                        spellSchool = 1,
                    }
                    
                end
            end
        end
    end
end

--creatbar
local createBar = function(e, barid, show, progressType, total, value, name, icon, spellId)
    e[barid] = {}
    e[barid] = {
        name = name,
        icon = icon,
        show = show,
        spellId = spellId,
        changed = true,
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

aura_env.onMessageTrigger = function(e, event, ...)
    if event == "CHAT_MSG_RAID_BOSS_EMOTE" then
        if triggerMessage[curEncounterID] then
            
            local msg, npcName = ...
            
            for k, v in pairs(triggerMessage[curEncounterID]) do
                if (msg:match(v.text) or msg:find(v.text)) then
                    local barid = "Timer"..curEncounterID..k
                    local duration = math.max((v.time - timeToVanish),0.1)
                    local expirationTime = duration + GetTime()
                    local name = npcName or "神仙"
                    local icon = vanishIcon
                    local spellId = v.spellId
                    
                    createBar(e, barid, true, "timed", duration, expirationTime, name, icon, spellId)
                    return true
                end
            end
        end
    elseif event == "CHAT_MSG_MONSTER_YELL" then
        if triggerMessage[curEncounterID] then
            
            local msg, npcName = ...
            
            for k, v in pairs(triggerMessage[curEncounterID]) do
                if (msg:match(v.text) or msg:find(v.text)) then
                    local barid = "Timer"..curEncounterID..k
                    local duration = math.max((v.time - timeToVanish),0.1)
                    local expirationTime = duration + GetTime()
                    local name = npcName or "神仙"
                    local icon = vanishIcon
                    local spellId = v.spellId
                    
                    createBar(e, barid, true, "timed", duration, expirationTime, name, icon, spellId)
                    return true
                end
            end
        end
    elseif event == "JT_TEST_MSG" then
        local curEncounterID = 629
        if triggerMessage[curEncounterID] then
            
            local msg, npcName = ...
            
            for k, v in pairs(triggerMessage[curEncounterID]) do
                if (msg:match(v.text) or msg:find(v.text)) then
                    local barid = "Timer"..curEncounterID..k
                    local duration = math.max((v.time - timeToVanish),0.1)
                    local expirationTime = duration + GetTime()
                    local name = npcName or "神仙"
                    local icon = vanishIcon
                    local spellId = v.spellId
                    
                    createBar(e, barid, true, "timed", duration, expirationTime, name, icon, spellId)
                    return true
                end
            end
        end
    elseif event == "JT_VANISH_CONFIG" then
        aura_env.isSound, aura_env.enableBtn = ...
    elseif event == "ENCOUNTER_START" then
        local encounterID = ...
        curEncounterID = encounterID or 0
    elseif event == "ENCOUNTER_END" then
        curEncounterID = 0
        if e then
            if next(e) then
                for k, _ in pairs(e) do
                    e[k].show = false
                    e[k].changed = true
                end
                return true
            end
        end
    end
end

