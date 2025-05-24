--ToDo需要早点存储身上装备情况。这个后面再改吧。
--版本信息
local version = 250505

local AURA_ICON = 132931
local AURA_NAME = "JT钓鱼换装WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

aura_env.saved = aura_env.saved or {}

local fishingSpellId = 7620
local fishingSpellName = GetSpellInfo(fishingSpellId)
local spellFailedEquippedItemClass = false
local failedTime = 0

local waitForCasting = nil

local previousEquipmentId = {}

local fishingPoles = {
    [19970] = INVSLOT_MAINHAND, -- 奥金钓鱼竿 40 钓鱼300
    [44050] = INVSLOT_MAINHAND, -- 精致的卡鲁亚克鱼竿 30 钓鱼300
    [45992] = INVSLOT_MAINHAND, -- 珠宝鱼竿 30 钓鱼300 lvl70
    [45991] = INVSLOT_MAINHAND, -- 骨质鱼竿 30 钓鱼300 lvl70
    [45858] = INVSLOT_MAINHAND, -- 纳特的好运鱼竿 25 钓鱼225
    [25978] = INVSLOT_MAINHAND, -- 塞瑟的石墨鱼竿 20 钓鱼200 60
    [19022] = INVSLOT_MAINHAND, -- 纳特·帕格的超级钓鱼竿FC-5000型 20 钓鱼100
    [6367] = INVSLOT_MAINHAND, -- 粗铁鱼竿 20 钓鱼100
    [6366] = INVSLOT_MAINHAND, -- 暗木鱼竿 15 钓鱼50 lvl15
    [6365] = INVSLOT_MAINHAND, -- 强化钓鱼竿 5 钓鱼10 lvl5
    [12225] = INVSLOT_MAINHAND, -- 布拉普家族鱼竿 3 钓鱼1
    [6256] = INVSLOT_MAINHAND, -- 鱼竿
    --[45120] = INVSLOT_MAINHAND, -- 普通鱼竿 --数据库说不可用
}

local initData = function()
    if aura_env.saved then
        for slot, itemId in pairs(aura_env.saved) do
            local currentItemId = GetInventoryItemID("player", slot)
            if fishingPoles[currentItemId] or (slot == INVSLOT_OFFHAND and (previousEquipmentId[INVSLOT_MAINHAND] or aura_env.saved[INVSLOT_MAINHAND])) then
                previousEquipmentId[slot] = itemId
            else
                previousEquipmentId[slot] = nil
                aura_env.saved[slot] = nil
            end
        end
    end
end
initData()

local trySwitchBackMH = function()
    waitForCasting = UnitCastingInfo("player")
    if waitForCasting then
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
aura_env.trySwitchBackMH = trySwitchBackMH

local isFishingPoleEquipped = function()
    local currentItemId = GetInventoryItemID("player", INVSLOT_MAINHAND)
    local itemType = currentItemId and select(13, GetItemInfo(currentItemId)) or nil
    return itemType == LE_ITEM_WEAPON_FISHINGPOLE
end
aura_env.isFishingPoleEquipped = isFishingPoleEquipped

local isFishingGearEquipped = function()
    if next(previousEquipmentId) then
        for slot, itemId in pairs(previousEquipmentId) do
            local currentItemId = GetInventoryItemID("player", slot)
            if fishingPoles[currentItemId] then
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
    if event == "UI_ERROR_MESSAGE" then
        local errorType, message = ...
        if errorType == LE_GAME_ERR_SPELL_FAILED_EQUIPPED_ITEM_CLASS_S then
            spellFailedEquippedItemClass = true
            failedTime = GetTime()
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local equipmentSlot, hasCurrent = ...
        if equipmentSlot == INVSLOT_MAINHAND then
            if isFishingPoleEquipped() then
                print("not fishing pole")
                -- local slot = INVSLOT_MAINHAND
                -- local slotOH = INVSLOT_OFFHAND
                -- aura_env.SaveInventoryItemId(slot)
                -- aura_env.SaveInventoryItemId(slotOH)
            end
        end
    elseif event == "UNIT_SPELLCAST_FAILED" then
        local unitTarget, castGUID, spellId = ...
        if unitTarget == "player" and fishingSpellName == GetSpellInfo(spellId) then
            local now = GetTime()
            if spellFailedEquippedItemClass and now - failedTime < 0.1 then
                return true
            end
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        if isFishingPoleEquipped() then
            if waitForCasting then
                return trySwitchBackMH()
            end
        end
    end
end
