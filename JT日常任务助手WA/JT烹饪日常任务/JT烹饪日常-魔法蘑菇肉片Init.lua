---@diagnostic disable: undefined-field
--版本信息
local version = 250302

--任务信息
local questInfo = {
    --联盟任务 nil就用部落的
    allianceId = 13100,
    --部落任务 nil就用联盟的
    hordeId = 13112,
    --烹饪任务使用任务物品ID
    useItemId = 43101,
    --是否需要使用基础营火
    requireFire = true,
}
questInfo.allianceId = questInfo.allianceId or questInfo.hordeId
questInfo.hordeId = questInfo.hordeId or questInfo.allianceId

local faction = UnitFactionGroup("player")
local thisQuestId = faction == "Alliance" and questInfo.allianceId or questInfo.hordeId

aura_env.complete = false
aura_env.displayText = ""

local baseMacro = questInfo.useItemId and "/use item:" or ""
local macroStr = baseMacro..(questInfo.useItemId or "")..(questInfo.requireFire and "\n/cast 基础营火" or "")

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
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" or event == "QUEST_LOG_UPDATE" then
        if aura_env.complete then
            return true
        else
            for questLogId = 1, GetNumQuestLogEntries() do
                local isComplete, _, questId = select(6, GetQuestLogTitle(questLogId))
                if isComplete == 1 and questId == thisQuestId then
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
end

aura_env.OnQuestUpdate = function(event, ...)
    if event == "QUEST_LOG_UPDATE" then
        if C_QuestLog.IsOnQuest(thisQuestId) then
            local info = C_QuestLog.GetQuestObjectives(thisQuestId) 
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

local checkIsOnQuest = function()
    local questID = thisQuestId
    if C_QuestLog.IsOnQuest(questID) then
        return true
    end
end

aura_env.CheckIsOnQuest = function(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if aura_env.waitOOC then
            return checkIsOnQuest()
        end
    else
        if not InCombatLockdown() then
            return checkIsOnQuest()
        else
            aura_env.waitOOC = true
        end
    end
end