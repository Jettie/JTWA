local woundPoisonEnchantIds = {
    [3773] = true, -- 致伤药膏 VII
    [3772] = true, -- 致伤药膏 VI
    [2644] = true, -- 致伤药膏 V
    [706] = true, -- 致伤药膏 IV
    [705] = true, -- 致伤药膏 III
    [704] = true, -- 致伤药膏 II
    [703] = true, -- 致伤药膏
}

local remindType = 0 -- 检测没致伤毒药的情况

aura_env.enableSwap = true
aura_env.enableDisplayText = true
aura_env.enableVoice = true

aura_env.woundPoisonChecked = false
aura_env.configChecked = false
aura_env.IAmYourGrandFather = false
aura_env.hasWoundPoisonWeapon = false

local tryRemindNoWP = function()
    if aura_env.woundPoisonChecked and aura_env.configChecked and aura_env.enableSwap and not aura_env.IAmYourGrandFather and not aura_env.hasWoundPoisonWeapon then
        WeakAuras.ScanEvents("JT_SWAP_WP_REMIND", remindType, aura_env.enableDisplayText, aura_env.enableVoice)
    end
end

local OnWPCheck = function(...)
    local AllStates = ...
    aura_env.hasWoundPoisonWeapon = false
    if AllStates and next(AllStates) then
        --检查allstates中是否有致伤武器
        for _ , stateData in pairs(AllStates) do
            if stateData.enchantId and woundPoisonEnchantIds[stateData.enchantId] then
                aura_env.hasWoundPoisonWeapon = true
            end
        end
    end
    aura_env.woundPoisonChecked = true
    tryRemindNoWP()
end

local OnConfigCheck = function(...)
    aura_env.enableSwap, aura_env.enableDisplayText, aura_env.enableVoice, aura_env.IAmYourGrandFather = ...
    aura_env.configChecked = true
    tryRemindNoWP()
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_WP_CHECK_FEEDBACK" then
        return OnWPCheck(...)
    elseif event == "JT_ANUBARAK_CONFIG_FEEDBACK" then
        return OnConfigCheck(...)
    elseif event == "JT_I_AM_ROGUE_GRANDFATHER" then
        aura_env.IAmYourGrandFather = ...
        if aura_env.IAmYourGrandFather then
            print("|T135743:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT三刀流WA|R]|CFF8FFFA2 贼爷再此! 不打致死!")
        end
    end
end

