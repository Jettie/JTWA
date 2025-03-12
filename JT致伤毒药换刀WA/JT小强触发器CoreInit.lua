local anubarakLeechingSwarmId = 66118

local class = select(2, UnitClass("player"))
local myGUID = UnitGUID("player")

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

aura_env.saved = aura_env.saved or {}
local db = aura_env.saved
local IAmYourGrandFather = db.IAmYourGrandFather or false

local showGFButton = function()
    local show = aura_env.config.enableSwap
    local buttonStatus = IAmYourGrandFather

    WeakAuras.ScanEvents("JT_WP_BUTTONE", show, buttonStatus)
end
showGFButton()

--author and header
local AURA_ICON = 135743
local AURA_NAME = "JT三刀流WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

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

local testSpellId = 48659 -- 测试技能 扰乱
local isTesting = false

--测试假人
local testTarget = {
    [31146] = true, -- 英雄训练假人
}

local EXPANSION = GetExpansionLevel() -- 游戏版本判断

if EXPANSION == 0 then
    testTarget = {
        [31146] = true, -- 英雄训练假人

        --诅咒之地
        [5982] = true, -- 黑色屠戮者
        [5985] = true, -- 弯牙土狼
        [5988] = true, -- 厚甲毒刺蝎
        [5990] = true, -- 红石蜥蜴
        [5992] = true, -- 灰鬃野猪
        [6004] = true, -- 魔誓祭司
        [6005] = true, -- 魔誓暴徒
        [6006] = true, -- 魔誓专家
        [7668] = true, -- 拉瑟莱克的仆从
        [7669] = true, -- 戈洛尔的仆从
        [7670] = true, -- 奥利斯塔的仆从
        [7671] = true, -- 瑟温妮的仆从
    }
end

local isTestTarget = function(targetGUID)
    if not targetGUID then
        return false
    end
    local type, _, _, _, _, targetID = strsplit("-", targetGUID)
    local id = tonumber(targetID)
    if type == "Creature" and testTarget[id] then
        return true
    end
    return false
end

local OnCLEUF = function(...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if subevent == "SPELL_CAST_START" or subevent == "SPELL_CAST_SUCCESS" then
        local spellId, spellName, spellSchool = select(12, ...)
        if class == "ROGUE" and (spellId == anubarakLeechingSwarmId or ((JTDebug or isTestTarget(destGUID)) and spellId == testSpellId)) then
            --判断当前武器是否有致伤毒药
            local startText = "检测到 |CFF1785D1"..destName.."|R 使用 "..GetSpellLink(testSpellId).." |CFFFF53A2三刀流|R开启!"
            if JTDebug or isTestTarget(destGUID) then
                isTesting = true
                startText = "检测到测试目标 |CFF1785D1"..destName.."|R 使用 "..GetSpellLink(testSpellId).." 开始测试|CFFFF53A2三刀流|R"
            end

            print(HEADER_TEXT..startText)

            local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID, hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID = GetWeaponEnchantInfo()
            if (hasMainHandEnchant and woundPoisonEnchantIds[mainHandEnchantID]) or (hasOffHandEnchant and woundPoisonEnchantIds[offHandEnchantID]) then
                hasWoundPoisonWeapon = true
                WeakAuras.ScanEvents("JT_WOUND_POISON_START", hasWoundPoisonWeapon, aura_env.config.enableSwap, aura_env.config.enableDisplayText, aura_env.config.enableVoice, IAmYourGrandFather)
            else
                -- 获取武器临时附魔的AllStates
                WeakAuras.ScanEvents("JT_GET_WEAPON_ENCHANT", "JT_ANUBARAK_WP_TRIGGER")
            end
        end
    elseif subevent == "ENCHANT_APPLIED" and (myGUID == sourceGUID or myGUID == destGUID) then
        -- 有上毒行为，延迟一下再获取武器临时附魔的AllStates，检查是否有毒药
        C_Timer.After(1, function()
            WeakAuras.ScanEvents("JT_GET_WEAPON_ENCHANT", "JT_ANUBARAK_WP_TRIGGER")
        end)
    end
end

local OnJTEventFeedback = function(...)
    local AllStates = ...
    if AllStates and next(AllStates) then
        --检查allstates中是否有致伤武器
        for _ , stateData in pairs(AllStates) do
            if stateData.enchantId and woundPoisonEnchantIds[stateData.enchantId] then
                -- 背包里有致伤武器，提醒换刀
                hasWoundPoisonWeapon = true
            end
        end
    end
    WeakAuras.ScanEvents("JT_WOUND_POISON_START", hasWoundPoisonWeapon, aura_env.config.enableSwap, aura_env.config.enableDisplayText, aura_env.config.enableVoice, IAmYourGrandFather)
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "JT_ANUBARAK_WP_TRIGGER" then
        return OnJTEventFeedback(...)
    elseif event == "JT_I_AM_ROGUE_GRANDFATHER" then
        IAmYourGrandFather = ...
        db.IAmYourGrandFather = IAmYourGrandFather
        showGFButton()
    elseif event == "JT_D_ANUBARAK_WP" then
        ToggleDebug()
    elseif isTesting and event == "PLAYER_REGEN_ENABLED" then
        print(HEADER_TEXT.."测试战斗结束 |CFFFF53A2三刀流|R 收刀!")
        isTesting = false
        WeakAuras.ScanEvents("JT_WOUND_POISON_STOP")
    end
end