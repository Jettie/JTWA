local anubarakLeechingSwarmId = 66118

local class = select(2, UnitClass("player"))

local OnCLEUF = function(e, ...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if subevent == "SPELL_CAST_START" or subevent == "SPELL_CAST_SUCCESS" then
        local spellId, spellName, spellSchool = select(12, ...)
        if class == "ROGUE" and spellId == anubarakLeechingSwarmId then
            --判断当前武器是否有致伤毒
            local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID, hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID = GetWeaponEnchantInfo()
            if hasMainHandEnchant and mainHandEnchantID == 3868 or hasOffHandEnchant and offHandEnchantID == 3868 then
                -- 武器上有致伤不提醒
            else
                --检查allstates中是否有致伤武器
                for stateName , stateData in pairs(e) do
                    if stateData.enchantId == 3868 and stateData.isEquipped then

                    end
                end
            end
            WeakAuras.ScanEvents("JT_WOUND_POISON_START")
        end
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, CombatLogGetCurrentEventInfo())
    end
end