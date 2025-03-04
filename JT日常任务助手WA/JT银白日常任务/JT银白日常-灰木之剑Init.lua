---@diagnostic disable: undefined-field
--版本信息
local version = 250302

--任务信息
local questInfo = {
    ["Alliance"] = {
        [13666] = true,
        [13603] = true,
        [13741] = true,
        [13746] = true,
        [13752] = true,
        [13757] = true,
    },
    ["Horde"] = {
        [13673] = true,
        [13762] = true,
        [13768] = true,
        [13773] = true,
        [13778] = true,
        [13783] = true,
    },
}
--烹饪任务使用任务物品ID
local useItemId = 44986

local faction = UnitFactionGroup("player")
local thisQuestIds = questInfo[faction]

aura_env.complete = false
aura_env.displayText = ""

local macroStr = "/stopmacro [mounted]\n/use item:"..useItemId.."\n/kiss"

local btnName = aura_env.id.."Button"

aura_env.btn = _G[btnName]

if not aura_env.btn then
    aura_env.btn = CreateFrame("Button", btnName, aura_env.region, "SecureActionButtonTemplate")
    aura_env.btn:SetAllPoints()
    aura_env.btn:SetAttribute("type","macro")
    aura_env.btn:SetAttribute("macrotext", macroStr)
    aura_env.btn:SetPassThroughButtons("RightButton")
end

aura_env.OnTrigger = function(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if aura_env.waitOOC then
            aura_env.complete = true
            return true
        end
    end

    if aura_env.complete then
        return true
    else
        for questLogId = 1, GetNumQuestLogEntries() do
            local isComplete, _, questId = select(6, GetQuestLogTitle(questLogId))
            if isComplete == 1 and thisQuestIds[questId] then
                if not InCombatLockdown() then
                    aura_env.complete = true
                    return true
                else
                    aura_env.waitOOC = true
                end
            end
        end
    end
end

aura_env.OnQuestUpdate = function(event, ...)
    if event == "QUEST_LOG_UPDATE" then
        for questId, _ in pairs(thisQuestIds) do
            if C_QuestLog.IsOnQuest(questId) then
                local info = C_QuestLog.GetQuestObjectives(questId)
                local result = ""
                local nums = #info
                for i= 1, nums do
                    if not info[i].isFinished then
                        result = result .. info[i].text
                    end
                    if i < nums then
                        result = result.."\n"
                    end
                end
                aura_env.displayText = result
                return true
            end
        end
    end
end

aura_env.tipText = "鼠标悬浮到每一个湖蛙身上\n真身会自动标记为 {rt3}菱形\n"
aura_env.guideText = ""
aura_env.isMounted = IsMounted() and "\n|CFFFF53A2下坐骑点按钮" or ""
aura_env.found = false
aura_env.findFrog = function(event, ...)
    if event == "UPDATE_MOUSEOVER_UNIT" and not aura_env.found then
        local moGUID = UnitGUID("mouseover")
        if moGUID then
            local moType, _, _, _, _, moID = strsplit("-", moGUID)
            if moType == "Creature" then
                local id = tonumber(moID)
                if id == 33224 then
                    aura_env.tipText = ""
                    aura_env.guideText = "|CFFFF53A2就是这只！{rt3}菱形|R 选中她为目标！"
                    WeakAuras.ScanEvents("AT_FROG_FOUND")
                    if GetRaidTargetIndex("mouseover") ~= 3 then
                        SetRaidTarget("mouseover", 3)
                    end
                    aura_env.found = true
                    return true
                elseif moID == 33211 then
                    aura_env.guideText = "|CFFFFFFFF不是这只！|R"
                end
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" and aura_env.found then
        local moGUID = UnitGUID("target")
        if moGUID then
            local moType, _, _, _, _, moID = strsplit("-", moGUID)
            if moType == "Creature" then
                local id = tonumber(moID)
                if id == 33224 then
                    aura_env.tipText = ""
                    aura_env.guideText = "|CFFFF53A2就是这只！{rt3}菱形|R 点击按钮！"
                    aura_env.isMounted = IsMounted() and "\n|CFFFF53A2下坐骑" or ""
                    return true
                end
            end
        end
    elseif event == "AT_FROG_FOUND" and aura_env.found then
        aura_env.isMounted = IsMounted() and "\n|CFFFF53A2下坐骑" or ""
        return true
    elseif event == "UNIT_AURA" and aura_env.found then
        aura_env.isMounted = IsMounted() and "\n|CFFFF53A2下坐骑" or ""
        return true
    end
end
