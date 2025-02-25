--版本信息
local version = 250225

local AURA_ICON = 132931
local AURA_NAME = "JT钓鱼换装WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local INITIALIZED = HEADER_TEXT.."- 换鱼竿自动换渔帽渔鞋 - 作者:|R "..AUTHOR

print(INITIALIZED)

local fishingGear = {}

aura_env.printWhenEquipped = function(itemId)
    local itemLink = select(2, GetItemInfo(itemId))
    if itemLink then
        print(HEADER_TEXT.."|CFFFF53A2自动装备|R "..(itemLink or itemId))
    end
end

aura_env.SaveInventoryItemId = function(slot)
    local itemId = GetInventoryItemID("player", slot)
    if itemId then
        fishingGear[slot] = itemId
    end
end

aura_env.OnHide = function()
    if next(fishingGear) then
        local text = ""
        for slot, itemId in pairs(fishingGear) do
            local currentItemId = GetInventoryItemID("player", slot)
            if currentItemId ~= itemId then
                EquipItemByName(itemId, slot)
                fishingGear[slot] = nil
                local itemLink = select(2, GetItemInfo(itemId))
                text = text == "" and (text..(itemLink or itemId)) or (text.." 和 "..(itemLink or itemId))
            end
        end
        if text ~= "" then
            print(HEADER_TEXT.."自动换回 "..text)
        end
    end
end

