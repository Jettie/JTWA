

local HEADER_TEXT = "|T135743:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT三刀流WA|R]|CFF8FFFA2 "

--JTDebug
local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug |CFFFF53A2:|R "..(text or "nil"))
    end
end
local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(WP) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))
end

local woundPoisonEnchantIds = {
    [3773] = true, -- 致伤药膏 VII
    [3772] = true, -- 致伤药膏 VI
    [2644] = true, -- 致伤药膏 V
    [706] = true, -- 致伤药膏 IV
    [705] = true, -- 致伤药膏 III
    [704] = true, -- 致伤药膏 II
    [703] = true, -- 致伤药膏
}

local healingEffectsReduceSpellIds = {
    -- 致伤毒药
    [57975] = true, -- 致伤药膏 VII
    [57974] = true, -- 致伤药膏 VI
    [27189] = true, -- 致伤药膏 V
    [13224] = true, -- 致伤药膏 IV
    [13223] = true, -- 致伤药膏 III
    [13222] = true, -- 致伤药膏 II
    [13218] = true, -- 致伤药膏

    -- 致死打击
    [47486] = true, -- 致死打击 8级
    [47485] = true, -- 致死打击 7级
    [30330] = true, -- 致死打击 6级
    [25248] = true, -- 致死打击 5级
    [21553] = true, -- 致死打击 4级
    [21552] = true, -- 致死打击 3级
    [21551] = true, -- 致死打击 2级
    [12294] = true, -- 致死打击 1级

    -- 瞄准射击
    [49050] = true, -- 瞄准射击 9级
    [49049] = true, -- 瞄准射击 8级
    [27065] = true, -- 瞄准射击 7级
    [20904] = true, -- 瞄准射击 6级
    [20903] = true, -- 瞄准射击 5级
    [20902] = true, -- 瞄准射击 4级
    [20901] = true, -- 瞄准射击 3级
    [20900] = true, -- 瞄准射击 2级
    [19434] = true, -- 瞄准射击 1级
}

local isSwapping = false

local hasWoundPoisonWeapon = false

local enableSwap = false
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

local OnCLEUF = function(e, ...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
        if healingEffectsReduceSpellIds[spellId] then

        end
    end
end

aura_env.OnTryToMakingBar = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, CombatLogGetCurrentEventInfo())
    end
end

local barShow = function (e)
    if not isSwapping or IAmYourGrandFather then return end
    if not hasWoundPoisonWeapon then
        WeakAuras.ScanEvents("JT_SWAP_WP_REMIND", 0, enableDisplayText, enableVoice)
    end
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
end


aura_env.OnTrigger = function(e, event, ...)
    if event == "JT_WOUND_POISON_START" then
        hasWoundPoisonWeapon, enableSwap, enableDisplayText, enableVoice, IAmYourGrandFather = ...
        if enableSwap then
            isSwapping = true
        end
        return barShow(e)
    elseif event == "ENCOUNTER_END" or event == "JT_WOUND_POISON_STOP" then
        for stateName, state in pairs(e) do
            if stateName then
                state.show = false
                state.changed = true
            end
        end
        
        isSwapping = false

        if event == "ENCOUNTER_END" then
            local encounterId = ...
            if encounterId == 645 then
                print(HEADER_TEXT.."战斗结束 |CFFFF53A2[三刀流]|R 收刀!")
            end
        end
        return true
    elseif event == "JT_I_AM_ROGUE_GRANDFATHER" then
        IAmYourGrandFather = ...
        if IAmYourGrandFather then
            for stateName, state in pairs(e) do
                if stateName then
                    state.show = false
                    state.changed = true
                end
            end
            print(HEADER_TEXT.."|CFFFFF569我是贼爷|R模式开启! |CFFFF53A2[三刀流]|R 收刀!")
            return true
        else
            print(HEADER_TEXT.."|CFFFFF569我是贼爷|R模式关闭! |CFFFF53A2[三刀流]|R 开启!")
            return barShow(e)
        end
    end
end

aura_env.OnCancel = function(e, event, ...)
    if event == "ENCOUNTER_END" then
        return true
    end
end