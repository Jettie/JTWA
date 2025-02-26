--版本信息
local version = 250226

local AURA_ICON = 132931
local AURA_NAME = "JT钓鱼换装WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local INITIALIZED = HEADER_TEXT.."- 换鱼竿自动换渔帽渔鞋 - 作者:|R "..AUTHOR

print(INITIALIZED)

aura_env.saved = aura_env.saved or {}

local waitForCasting = nil
local waitForOOC = false

local previousEquipmentId = {}

local fishingGears = {
    [33820] = INVSLOT_HEAD, -- 饱经风霜的渔帽
    [19972] = INVSLOT_HEAD, -- 幸运渔帽
    [7996] = INVSLOT_HEAD, -- 破旧的渔帽
    [19969] = INVSLOT_FEET, -- 纳特·帕格的超级钓鱼靴
    --[23073] = INVSLOT_FEET, -- 偏移之鞋
}

local initData = function()
    if aura_env.saved then
        for slot, itemId in pairs(aura_env.saved) do
            local currentItemId = GetInventoryItemID("player", slot)
            if fishingGears[currentItemId] then
                previousEquipmentId[slot] = itemId
            else
                previousEquipmentId[slot] = nil
                aura_env.saved[slot] = nil
            end
        end
    end
end
initData()

local trySwitchBack = function()
    waitForOOC = InCombatLockdown()
    waitForCasting = UnitCastingInfo("player")

    if waitForOOC then
        local text = "战斗中……脱战后换回之前装备"
        print(HEADER_TEXT..text)
        return false
    elseif waitForCasting then
        local text = "施法中……施法结束后换回之前装备"
        print(HEADER_TEXT..text)
        return false
    else
        if next(previousEquipmentId) then
            local text = ""
            for slot, itemId in pairs(previousEquipmentId) do
                if itemId then
                    EquipItemByName(itemId, slot)
                    previousEquipmentId[slot] = nil
                    aura_env.saved[slot] = nil
                    local itemLink = select(2, GetItemInfo(itemId))
                    text = text == "" and (text..(itemLink or itemId)) or (text.." 和 "..(itemLink or itemId))
                end
            end
            if text ~= "" then
                print(HEADER_TEXT.."自动换回 "..text)
            end
        end
        return true
    end
end

local isFishingPoleEquipped = function()
    local currentItemId = GetInventoryItemID("player", INVSLOT_MAINHAND)
    local itemType = select(13, GetItemInfo(currentItemId))
    return itemType == LE_ITEM_WEAPON_FISHINGPOLE
end
aura_env.isFishingPoleEquipped = isFishingPoleEquipped

local isFishingGearEquipped = function()
    if next(previousEquipmentId) then
        for slot, itemId in pairs(previousEquipmentId) do
            local currentItemId = GetInventoryItemID("player", slot)
            if fishingGears[currentItemId] then
                return true
            end
        end
    end
end
aura_env.isFishingGearEquipped = isFishingGearEquipped

aura_env.printWhenEquipped = function(itemId)
    local itemLink = select(2, GetItemInfo(itemId))
    if itemLink then
        print(HEADER_TEXT.."|CFFFF53A2自动装备|R "..(itemLink or itemId))
    end
end

aura_env.SaveInventoryItemId = function(slot)
    local itemId = GetInventoryItemID("player", slot)
    if itemId then
        previousEquipmentId[slot] = itemId
        aura_env.saved[slot] = itemId
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        local equipmentSlot, hasCurrent = ...
        if equipmentSlot == INVSLOT_MAINHAND then
            if isFishingPoleEquipped() then
                return true
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if isFishingPoleEquipped() then
            return true
        end
    end
end

aura_env.TryHide = function(event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        local equipmentSlot, hasCurrent = ...
        if equipmentSlot == INVSLOT_MAINHAND then
            if not isFishingPoleEquipped() then
                return trySwitchBack()
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if isFishingGearEquipped() then
            if not isFishingPoleEquipped() then
                return trySwitchBack()
            end
        else
            return true
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" or event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
        if isFishingGearEquipped() then
            if waitForCasting and not isFishingPoleEquipped() then
                return trySwitchBack()
            end
        else
            return true
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if isFishingGearEquipped() then
            if waitForOOC and not isFishingPoleEquipped() then
                return trySwitchBack()
            end
        else
            return true
        end
    end
end