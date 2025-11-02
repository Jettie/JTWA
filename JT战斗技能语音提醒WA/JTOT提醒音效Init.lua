-- 版本信息
local version = 250712

aura_env.UnitDetailedThreatSituation = UnitDetailedThreatSituation

local _, class = UnitClass("player")

local EXPANSION = GetExpansionLevel()

local ignoreMaps = {
    [2] = {
        [265] = true, -- WLK 奴隶围栏 仲夏火焰节 屏蔽OT语音
    },

}
local mapId = C_Map.GetBestMapForUnit("player")

local ignoreNPCs = {
    [24207] = true, -- 奥斯塔德·怒风 屏蔽OT语音

    [36551] = true, -- 灵魂洪炉 隐身小骷髅

    [25740] = true, -- 仲夏节 BOSS
    [25755] = true, -- 仲夏节 小怪
    [25756] = true, -- 仲夏节 小怪

}

local isIgnored = function()
    if ignoreMaps[EXPANSION] and ignoreMaps[EXPANSION][mapId] then
        return true
    else
        local targetGUID = UnitGUID("target")
        if targetGUID and UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend("player","target") and UnitCanAttack("player","target") then
            local npcId = select(6, strsplit("-", targetGUID))
            local digitizedNpcId = tonumber(npcId)
            if digitizedNpcId and ignoreNPCs[digitizedNpcId] then
                return true
            end
        end
    end
end

aura_env.isTankingMute = function()
    -- 屏蔽地图
    if isIgnored() then
        return true
    end

    if class == "DRUID" then
        if GetShapeshiftFormID() == 8 or GetShapeshiftFormID() == 5 then
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
    elseif class == "PALADIN" then
        -- /dump GetTalentInfo(2, 7)
        if select(5,GetTalentInfo(2, 7)) > 0 then
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

