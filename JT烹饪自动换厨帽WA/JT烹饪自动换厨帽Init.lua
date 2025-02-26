--版本信息
local version = 250226

local AURA_ICON = 236571
local AURA_NAME = "JT烹饪自动换厨帽WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local INITIALIZED = HEADER_TEXT.."作者:|R "..AUTHOR

print(INITIALIZED)

local waitForCasting = nil
local waitForOOC = false

aura_env.saved = aura_env.saved or {}

local previousEquipmentId = {}
local tradeSkillId = 51296
local tradeSkillName = GetSpellInfo(tradeSkillId)

aura_env.chefHatId = 46349

local initData = function()
    if aura_env.saved then
        for slot, itemId in pairs(aura_env.saved) do
            local currentItemId = GetInventoryItemID("player", slot)
            if currentItemId == aura_env.chefHatId then
                previousEquipmentId[slot] = itemId
            else
                previousEquipmentId[slot] = nil
                aura_env.saved[slot] = nil
            end
        end
    end
end
initData()

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

aura_env.OnTrigger = function(event, ...)
    if event == "TRADE_SKILL_SHOW" then
        local curSkillName = GetTradeSkillLine()
        if curSkillName == tradeSkillName then
            return true
        end
    end
end

aura_env.TryHide = function(event, ...)
    if event == "TRADE_SKILL_CLOSE" then
        if IsEquippedItem(aura_env.chefHatId) then
            return trySwitchBack()
        else
            return true
        end
    elseif event == "TRADE_SKILL_SHOW" then
        if IsEquippedItem(aura_env.chefHatId) then
            if (not TradeSkillFrame or not TradeSkillFrame:IsShown() or (TradeSkillFrame:IsShown() and tradeSkillName ~= GetTradeSkillLine())) then
                return trySwitchBack()
            end
        else
            return true
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if IsEquippedItem(aura_env.chefHatId) then
            return trySwitchBack()
        else
            return true
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" or event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
        if IsEquippedItem(aura_env.chefHatId) then
            if (not TradeSkillFrame or not TradeSkillFrame:IsShown() or (TradeSkillFrame:IsShown() and tradeSkillName ~= GetTradeSkillLine())) and waitForCasting then
                return trySwitchBack()
            end
        else
            return true
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if IsEquippedItem(aura_env.chefHatId) then
            if (not TradeSkillFrame or not TradeSkillFrame:IsShown() or (TradeSkillFrame:IsShown() and tradeSkillName ~= GetTradeSkillLine())) and waitForOOC then
                return trySwitchBack()
            end
        else
            return true
        end
    end
end