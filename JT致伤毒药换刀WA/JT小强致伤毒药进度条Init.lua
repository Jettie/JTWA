
local HEADER_TEXT = "|T135743:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT三刀流WA|R]|CFF8FFFA2 "

local woundPoisonDebuffIds = {
    [57975] = true, -- 7级 致伤毒药
    [57974] = true, -- 6级 致伤毒药
    [27189] = true, -- 5级 致伤毒药
    [13224] = true, -- 4级 致伤毒药
    [13223] = true, -- 3级 致伤毒药
    [13222] = true, -- 2级 致伤毒药
    [13218] = true, -- 1级 致伤毒药
}

local woundPoisonEnchantIds = {
    [3773] = true, -- 致伤药膏 VII
    [3772] = true, -- 致伤药膏 VI
    [2644] = true, -- 致伤药膏 V
    [706] = true, -- 致伤药膏 IV
    [705] = true, -- 致伤药膏 III
    [704] = true, -- 致伤药膏 II
    [703] = true, -- 致伤药膏
}

local hasWoundPoisonWeapon = false

local enableSwap = true
local enableDisplayText = true
local enableVoice = true
local IAmYourGrandFather = false

local lastRemindSwapBackTime = 0

-- remindType 0没有致伤 1换致伤 2换回来
local sendRemindEvent = function(remindType)
    if remindType == 2 then
        if lastRemindSwapBackTime + 3 > GetTime() then
            return
        else
            lastRemindSwapBackTime = GetTime()
        end
    end

    WeakAuras.ScanEvents("JT_SWAP_WP_REMIND", remindType, enableDisplayText, enableVoice)
end

aura_env.tryRemindToWP = function()
    if not enableSwap or IAmYourGrandFather then return end
    if hasWoundPoisonWeapon then
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID, hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID = GetWeaponEnchantInfo()
        if not (woundPoisonEnchantIds[mainHandEnchantID] or woundPoisonEnchantIds[offHandEnchantID]) then
            -- 身上没有致伤，提醒换刀
            local remindType = 1 -- remindType 0没有致伤 1换致伤 2换回来
            sendRemindEvent(remindType)

        end
    else
        -- 没有致伤武器注意上毒
        local remindType = 0 -- remindType 0没有致伤 1换致伤 2换回来
        sendRemindEvent(remindType)
    end
end

aura_env.tryRemindSwapBack = function()
    if not enableSwap or IAmYourGrandFather then return end
    if hasWoundPoisonWeapon then
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID, hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID = GetWeaponEnchantInfo()
        if woundPoisonEnchantIds[mainHandEnchantID] or woundPoisonEnchantIds[offHandEnchantID] then
            -- 身上装备着致伤武器提醒换回来
            local remindType = 2 -- remindType 0没有致伤 1换致伤 2换回来
            sendRemindEvent(remindType)
        end
    else
        -- 没有致伤武器注意上毒
        local remindType = 0 -- remindType 0没有致伤 1换致伤 2换回来
        sendRemindEvent(remindType)
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "JT_WOUND_POISON_START" then
        hasWoundPoisonWeapon, enableSwap, enableDisplayText, enableVoice, IAmYourGrandFather = ...

        local stateName = "WP"
        if not e[stateName] then
            e[stateName] = {
                name = stateName,
                icon = 134197,
                autoHide = false,
                show = true,
                changed = true,
            }
        else
            e[stateName].show = true
            e[stateName].changed = true
        end
        return true
    elseif event == "ENCOUNTER_END" or event == "JT_WOUND_POISON_STOP" then
        for stateName, state in pairs(e) do
            if stateName then
                state.show = false
                state.changed = true
            end
        end
        if event == "ENCOUNTER_END" then
            print("|T135743:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT三刀流WA|R]|CFF8FFFA2 战斗结束 |CFFFF53A2三刀流|R 收刀!")
        end
        return true
    elseif event == "JT_I_AM_ROGUE_GRANDFATHER" then
        IAmYourGrandFather = ...
    end
end

aura_env.OnCancel = function(e, event, ...)
    if event == "ENCOUNTER_END" then
        return true
    end
end