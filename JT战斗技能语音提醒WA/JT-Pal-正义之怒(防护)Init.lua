-- 版本信息
local version = 250610

-- 防骑判断
local checkTankTalent = function()
    return select(5,GetTalentInfo(2, 21)) ~= 0 and true or false
end
aura_env.checkTankTalent = checkTankTalent

-- 强化正义之怒 奶骑可能会开
local checkImprovedRighteousFury = function()
    return select(5,GetTalentInfo(2, 10)) ~= 0 and true or false
end
aura_env.checkImprovedRighteousFury = checkImprovedRighteousFury

local checkRighteousFury = function()
    return WA_GetUnitBuff("player", 25780) and true or false
end
aura_env.checkRighteousFury = checkRighteousFury

aura_env.OnTrigger = function(event, ...)
    if event == "JT_RIGHTEOUS_FURY_CHECK"then
        return checkRighteousFury()
    elseif event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_REGEN_DISABLED" then
        C_Timer.After(1, function()
                WeakAuras.ScanEvents("JT_RIGHTEOUS_FURY_CHECK")
        end)
    end
end

