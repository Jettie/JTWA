--版本信息
local version = 250324

--solo header
local AURA_ICON = 237554
local AURA_NAME = "JT找背WA"
local SMALL_ICON = "|T"..(AURA_ICON or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_ICON = SMALL_ICON.."[%s]|CFF8FFFA2 "

--JTDebug
local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug : "..(text or "nil"))
    end
end
local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(Dalian) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))
end

local EXPANSION = GetExpansionLevel() -- 游戏版本判断

local BOSS_LEVEL = {
    [0] = 63,
    [1] = 73,
    [2] = 83,
}

--next melee skills
local heroicStrikeId = 47450
local cleaveId = 47520
local raptorStrikeId = 48996
local maulId = 48480

local HEROIC_STRIKE_IDS = {
    [47450] = true, -- Heroic Strike (rank 13)
    [47449] = true, -- Heroic Strike (rank 12)
    [30324] = true, -- Heroic Strike (rank 11)
    [29707] = true, -- Heroic Strike (rank 10)
    [25286] = true, -- Heroic Strike (rank 9)
    [11567] = true, -- Heroic Strike (rank 18)
    [11566] = true, -- Heroic Strike (rank 7)
    [11565] = true, -- Heroic Strike (rank 6)
    [11564] = true, -- Heroic Strike (rank 5)
    [1608] = true, -- Heroic Strike (rank 4)
    [285] = true, -- Heroic Strike (rank 3)
    [284] = true, -- Heroic Strike (rank 2)
    [78] = true, -- Heroic Strike (rank 1)
}
local CLEAVE_IDS = {
    [47520] = true, -- Cleave (rank 8)
    [47519] = true, -- Cleave (rank 7)
    [25231] = true, -- Cleave (rank 6)
    [20569] = true, -- Cleave (rank 5)
    [11609] = true, -- Cleave (rank 4)
    [11608] = true, -- Cleave (rank 3)
    [7369] = true, -- Cleave (rank 2)
    [845] = true, -- Cleave (rank 1)
}
local RAPTOR_STRIKE_IDS = {
    [48996] = true, -- Raptor Strike (rank 11)
    [48995] = true, -- Raptor Strike (rank 10)
    [27014] = true, -- Raptor Strike (rank 9)
    [14266] = true, -- Raptor Strike (rank 8)
    [14265] = true, -- Raptor Strike (rank 7)
    [14264] = true, -- Raptor Strike (rank 6)
    [14263] = true, -- Raptor Strike (rank 5)
    [14262] = true, -- Raptor Strike (rank 4)
    [14261] = true, -- Raptor Strike (rank 3)
    [14260] = true, -- Raptor Strike (rank 2)
    [2973] = true, -- Raptor Strike (rank 1)
}
local MAUL_IDS = {
    [48480] = true, -- Maul (rank 10)
    [48479] = true, -- Maul (rank 9)
    [26996] = true, -- Maul (rank 8)
    [9881] = true, -- Maul (rank 7)
    [9880] = true, -- Maul (rank 6)
    [9745] = true, -- Maul (rank 5)
    [8972] = true, -- Maul (rank 4)
    [6809] = true, -- Maul (rank 3)
    [6808] = true, -- Maul (rank 2)
    [6807] = true, -- Maul (rank 1)
}

--阵营判断raidBuff用
local FACTION = UnitFactionGroup("player")

--check melee talent for Melee DPS
local _, class = UnitClass("player")
local CheckMeleeTalent = function()
    if EXPANSION == 2 then

        if class == "ROGUE" then
            WeakAuras.ScanEvents("JT_BACKSTAB", aura_env.config.isBackstab, aura_env.config.isFaceText, aura_env.config.isVoice)
            return true
        elseif class == "WARRIOR" then
            for k,_ in pairs(HEROIC_STRIKE_IDS) do
                if IsSpellKnown(k) then
                    heroicStrikeId = k
                end
            end
            for k,_ in pairs(CLEAVE_IDS) do
                if IsSpellKnown(k) then
                    cleaveId = k
                end
            end
            --毁灭打击 /dump GetTalentInfo(3, 20) 致死打击 /dump GetTalentInfo(1, 14) 嗜血 /dump GetTalentInfo(2, 11)
            return select(5,GetTalentInfo(3, 20)) == 0 and true or false
        elseif class == "DEATHKNIGHT" then
            --/dump 大墓地的意志 GetTalentInfo(1, 17)
            return select(5,GetTalentInfo(1, 17)) == 0 and true or false
        elseif class == "SHAMAN" then
            --风暴打击 /dump GetTalentInfo(2, 13)
            return select(5,GetTalentInfo(2, 13)) > 0 and true or false
        elseif class == "PALADIN" then
            --神圣风暴 /dump GetTalentInfo(3, 24)
            return select(5,GetTalentInfo(3, 24)) > 0 and true or false
        elseif class == "DRUID" then
            WeakAuras.ScanEvents("JT_BACKSTAB", aura_env.config.isBackstab, aura_env.config.isFaceText, aura_env.config.isVoice)
            for k,_ in pairs(MAUL_IDS) do
                if IsSpellKnown(k) then
                    maulId = k
                end
            end

            --裂伤 /dump GetTalentInfo(2, 20)
            return select(5,GetTalentInfo(2, 20)) > 0 and true or false
        elseif class == "HUNTER" then
            for k,_ in pairs(RAPTOR_STRIKE_IDS) do
                if IsSpellKnown(k) then
                    raptorStrikeId = k
                end
            end

            return false
        end
    elseif EXPANSION == 0 then
        if class == "ROGUE" then
            --/dump GetTalentInfo(2, 19) 武器专家，1级+3 2级+5
            return true
        elseif class == "WARRIOR" then
            for k,_ in pairs(HEROIC_STRIKE_IDS) do
                if IsSpellKnown(k) then
                    heroicStrikeId = k
                end
            end
            for k,_ in pairs(CLEAVE_IDS) do
                if IsSpellKnown(k) then
                    cleaveId = k
                end
            end
            --破釜沉舟 /dump GetTalentInfo(3, 15) 
            return select(5,GetTalentInfo(3, 15)) == 0 and true or false
        elseif class == "SHAMAN" then
            --乱舞 /dump GetTalentInfo(2, 2)
            return select(5,GetTalentInfo(2, 2)) > 0 and true or false
        elseif class == "PALADIN" then
            --双手武器专精 /dump GetTalentInfo(3, 7) 复仇 /dump GetTalentInfo(3, 2)
            return ( select(5,GetTalentInfo(3, 2)) > 0 or select(5,GetTalentInfo(3, 7)) > 0 ) and true or false
        elseif class == "DRUID" then
            for k,_ in pairs(MAUL_IDS) do
                if IsSpellKnown(k) then
                    maulId = k
                end
            end
            --兽群领袖 /dump GetTalentInfo(2, 15) 兽群领袖 /dump GetTalentInfo(2, 野性之心)
            return ( select(5,GetTalentInfo(2, 15)) > 0 or select(5,GetTalentInfo(2, 14)) > 0 ) and true or false
        elseif class == "HUNTER" then
            for k,_ in pairs(RAPTOR_STRIKE_IDS) do
                if IsSpellKnown(k) then
                    raptorStrikeId = k
                end
            end

            return false
        end
    else
        return false
    end
end

local isMelee = CheckMeleeTalent()

--dummy init
local attackingDummy = false
local testingWithUnknownBuff = nil

--count
local swingParryCount = 0
local spellParryCount = 0
local blockedCount = 0
local totalBlockedDamage = 0
local startCombatTime = GetTime()
local swingDalianTimeWaste = 0
local spellDalianTimeWaste = 0
local lastDalianTime = 0

local SN = function(number)
    return string.format("%.1f",number)
end
local SR = function(number)
    return string.format("%.2f",number).."%"
end

local ReportDalian = function()
    local roll = math.random(100)
    local now = GetTime()
    --test 正式的时候加个not attackingDummy
    if aura_env.config.enableRollDalianwang and not attackingDummy then
        WeakAuras.ScanEvents("JT_VOTESLAPPER", roll)
    end

    if aura_env.config.enableReportDalian then
        if swingParryCount == 0 and spellParryCount == 0 and blockedCount == 0 then
            local perfectText = HEADER_TEXT.."颁奖Roll("..(aura_env.config.enableRollDalianwang and roll or "弃权")..") |CFFFF53A2Perfect! 完美表现!|R - |CFFFF53A20|R 招架 |CFFFF53A20|R 格挡!"
            print(perfectText)
        else
            local soloText = HEADER_TEXT.."颁奖Roll("..(aura_env.config.enableRollDalianwang and roll or "弃权")..") 招架: 普攻|CFFFF53A2"..swingParryCount.."|R次 技能|CFFFF53A2"..spellParryCount.."|R次 格挡|CFFFF53A2"..blockedCount.."|R次 累计格挡伤害:|CFFFFFFFF"..totalBlockedDamage
            print(soloText)

            local totalWaste = " |CFF1785D1(保守预估)|R 总计打脸时间 |CFFFF53A2"..SN(swingDalianTimeWaste + spellDalianTimeWaste).."|R / |CFFFFFFFF"..SN(now - startCombatTime).."|R(战斗时长) 秒 打脸占比 |CFFFF53A2"..SR(((swingDalianTimeWaste + spellDalianTimeWaste)*100)/(now - startCombatTime))
            print((ONLY_ICON):format("|CFF8FFFA2^o^|R")..totalWaste)
        end
    end
end

--检查身上的buff
-- local buffExists = {
--     ["野性赐福"] = "DRUID", --21850 --72588是鼓，同名 
--     ["野性印记"] = "DRUID", --9885 1126 1级
--     ["兽群领袖"] = "DRUID", --24932
--     ["王者祝福"] = "PALADIN", --20217
--     ["强效王者祝福"] = "PALADIN", --25898
--     ["寒冬号角"] = "DEATHKNIGHT", --57623
--     ["大地之力"] = "SHAMAN", --58646 --wlk的技能
--     ["风之优雅"] = "SHAMAN", --25360 --era的技能
--     ["暴怒"] = "WARRIOR", --29801
--     ["遗忘王者祝福"] = "NONE", -- 72586鼓
-- }

local buffIdToClass = {
    [21850] = "DRUID", --21850 --72588是鼓，同名 
    [9885] = "DRUID", --9885 1126 1级
    [24932] = "DRUID", --24932
    [20217] = "PALADIN", --20217
    [25898] = "PALADIN", --25898
    [57623] = "DEATHKNIGHT", --57623
    [58646] = "SHAMAN", --58646 --wlk的技能
    [25360] = "SHAMAN", --25360 --era的技能
    [29801] = "WARRIOR", --29801
    [72586] = "NONE", -- 72586 鼓
}
--[[
    [21850] -- 野性赐福
    [9885] -- 野性印记
    [24932] -- 兽群领袖
    [20217] -- 王者祝福
    [25898] -- 强效王者祝福
    [57623] -- 寒冬号角
    [58646] -- 大地之力
    [25360] -- 风之优雅
    [29801] -- 暴怒
    [72586] -- 遗忘王者祝福
]]
local buffExists = {}
local buildBuffExistsTable = function()
    for k, v in pairs(buffIdToClass) do
        local name = GetSpellInfo(k)
        if name then
            buffExists[name] = v
        end
    end
end
buildBuffExistsTable()

--敏捷转换暴击
local agiPerCrit = {
    [0] = {
        ["DEATHKNIGHT"] = 20,
        ["DRUID"] = 20,
        ["HUNTER"] = 33,
        ["MAGE"] = 20,
        ["PALADIN"] = 20,
        ["PRIEST"] = 20,
        ["ROGUE"] = 29,
        ["SHAMAN"] = 20,
        ["WARLOCK"] = 20,
        ["WARRIOR"] = 20,
    },
    [1] = {
        ["DEATHKNIGHT"] = 33,
        ["DRUID"] = 40,
        ["HUNTER"] = 40,
        ["MAGE"] = 25,
        ["PALADIN"] = 25,
        ["PRIEST"] = 25,
        ["ROGUE"] = 40,
        ["SHAMAN"] = 40,
        ["WARLOCK"] = 25,
        ["WARRIOR"] = 33,
    },
    [2] = {
        ["DEATHKNIGHT"] = 62.5,
        ["DRUID"] = 83.3,
        ["HUNTER"] = 83.3,
        ["MAGE"] = 51,
        ["PALADIN"] = 52.08,
        ["PRIEST"] = 52,
        ["ROGUE"] = 83.3,
        ["SHAMAN"] = 83.3,
        ["WARLOCK"] = 51,
        ["WARRIOR"] = 62.5,
    },
}

local isBuffedOnTest = function()
    if not attackingDummy then
        return false
    end

    for k, v in pairs(buffExists) do
        if WA_GetUnitBuff("player", k) then
            if class ~= v then
                testingWithUnknownBuff = true
                print(HEADER_TEXT.."检测到他人的BUFF: |CFFFF53A2"..k.."|R ..测试结果会|CFFFF0000不准确|R")
                return k
            end
        end
    end

    testingWithUnknownBuff = false
    return false
end

local isMyBuff = function(buffId)
    if not buffId then return end
    local buffName = WA_GetUnitBuff("player", buffId)
    if buffName then
        if buffExists[buffName] then
            if class == buffExists[buffName] then
                return true
            else
                if not testingWithUnknownBuff then
                    print(HEADER_TEXT.."检测到他人的BUFF: |CFF1785D1"..buffName.."|R..测试暴击阈值会不准确")
                    testingWithUnknownBuff = true
                end
            end
        end
    end
    return false
end

--敏捷获取的暴击（为了判断是否要减去暴击光环）,aagility==nil是自身全部敏捷
local getCritChanceFromAgi = function(agility)
    if not agility then
        agility = UnitStat("player", 2)
    end

    if agiPerCrit[EXPANSION] then
        if agiPerCrit[EXPANSION][class] then
            return agility / agiPerCrit[EXPANSION][class]
        end
    end
end

local CheckCritCap = function(isDalian, isOffhand)
    if not isMelee then return false end
    if EXPANSION == 2 then

        if testingWithUnknownBuff == nil then
            isBuffedOnTest() --检测一次
        end

        local THE_SHOT = 100 --总100
        local BOSS_REDUCE = 4.8 --骷髅怪+4.8免爆
        local GLANCING_REDUCE = 24 --偏斜几率24%
        local BASE_PARRY = 14 --招架（需要扣减精准）
        local BASE_DODGE = 6.5 --闪避（需要扣减精准）
        local BASE_BLOCK = 5 --格挡5%

        local function GetRaidBuff()
            if aura_env.config.raidBuff and attackingDummy then
                local AGI_MOW = ( isMyBuff(9885) or isMyBuff(21850) ) and 0 or 51 --野性印记
                local AGI_HOW = ( isMyBuff(57623) or isMyBuff(58646) ) and 0 or 155 --寒冬号角
                local AGI_IMPROVED_SOE = isMyBuff(58646) and (23 - math.floor(select(5,GetTalentInfo(2, 6)) * 0.05 * 155) )  or 23 --强化大地之力图腾
                local AGI_BOK = ( isMyBuff(20217) or isMyBuff(25898) ) and 0 or 0.1 --王者 10%
                local CRIT_RAMPAGE = ( isMyBuff(24932) or isMyBuff(29801) ) and 0 or 5 --暴怒或者兽群领袖
                local CRIT_MASTER_POISONER = 3 --奇毒
                local CRIT_PER_AGI = agiPerCrit[EXPANSION][class]

                local myAgi = UnitStat("player", 2)

                --模拟团队BUFF情况，包括BUFF和DEBUFF。
                local critFromRaidBuff = (math.floor(((myAgi * AGI_BOK ) + (AGI_MOW + AGI_HOW + (aura_env.config.dummyImpSOE and AGI_IMPROVED_SOE or 0)) * (1 +AGI_BOK))) / CRIT_PER_AGI ) + CRIT_RAMPAGE + CRIT_MASTER_POISONER
                return critFromRaidBuff
            else
                --排除团队BUFF，也要计算自身提供的DEBUFF暴击，因为这些不在面板显示
                if class == "ROGUE" then
                    local critPerTalent = 1
                    local talentLevel = select(5,GetTalentInfo(1, 16))
                    return critPerTalent * talentLevel
                elseif class == "PALADIN" then
                    local critPerTalent = 1
                    local talentLevel = select(5,GetTalentInfo(3, 8))
                    return critPerTalent * talentLevel
                elseif class == "SHAMAN" then
                    local critPerTalent = 3
                    local talentLevel = select(5,GetTalentInfo(1, 18))
                    return critPerTalent * talentLevel
                else
                    return 0
                end
            end
        end

        local hitByRating = GetCombatRatingBonus(6) --命中等级转化几率
        local buffedCrit = GetRaidBuff()
        local crit = GetCritChance() --面板全身暴击
        local combatCrit = crit + buffedCrit
        local otherHit = GetHitModifier() or 0 --除了命中等级之外的其他命中（天赋）
        local hit = hitByRating + otherHit
        local combatHit = hit
        local dualwieldReuce = select(2, UnitAttackSpeed("player")) and 27 or 8 --双武器判断27 or 0
        local hsCovered = ""
        --战士卡英勇的修正 --还需要记录数据
        if ( class == "WARRIOR" and (IsCurrentSpell(heroicStrikeId) or IsCurrentSpell(cleaveId)) ) then
            dualwieldReuce = 8
        elseif ( class == "WARRIOR" and not (IsCurrentSpell(heroicStrikeId) or IsCurrentSpell(cleaveId)) )then
            hsCovered = "(无英勇/顺劈)"
        end

        --获得主副手精准%
        local mhExp, ohExp = GetExpertisePercent()
        local thisExp = isOffhand and ohExp or mhExp
        local parry = isDalian and math.max(BASE_PARRY - thisExp, 0) or 0
        local block = isDalian and BASE_BLOCK or 0 --打脸不是？
        local dodge = math.max(BASE_DODGE - thisExp, 0)

        local final = THE_SHOT - math.max( (dualwieldReuce - combatHit), 0 ) - GLANCING_REDUCE + BOSS_REDUCE - ( combatCrit ) - parry - dodge - block

        local result = {
            time = ( GetTime() - startCombatTime ) or 0,
            final = final,
            crit = crit,
            combatCrit = combatCrit,
            hit = hit,
            combatHit = combatHit,
            dodge = dodge,
            isDalian = isDalian,
            isOffhand = isOffhand,
            hsCovered = hsCovered,
        }

        return result
    elseif EXPANSION == 0 then

        if testingWithUnknownBuff == nil then
            isBuffedOnTest() --检测一次
        end

        local getWeaponSkills = function()
            if class == "DRUID" then
                return 5 * UnitLevel("player")
            elseif class == "HUNTER" then
                local base, bonus = UnitRangedAttack("player")
                return base + bonus
            end

            local mhBase, mhExtra, ohBase, ohExtra = UnitAttackBothHands("player")
            local mhSkill = mhBase + mhExtra

            --UnitAttackBothHands不判断副手装没装东西，没装就是徒手战斗，只装备助手需要搭配IsDualWielding()
            local ohSkill = IsDualWielding() and (ohBase + ohExtra) or nil
            return mhSkill, ohSkill, mhBase, mhExtra, ohBase, ohExtra
        end

        local getRaidBuff = function()
            if aura_env.config.raidBuff and attackingDummy then
                local AGI_MOW = ( isMyBuff(9885) or isMyBuff(21850) ) and 0 or 16 --野性印记
                local AGI_HOW = (FACTION == "Horde") and ( isMyBuff(25360) and 0 or 77 ) or 0--风之优雅
                local AGI_IMPROVED_SOE = (FACTION == "Horde") and (aura_env.config.dummyImpSOE and (isMyBuff(58646) and (11 - math.floor(math.min(select(5,GetTalentInfo(2, 6)) * 0.08, 0.15) * 77) ) or 11) or 0 ) or 0--强化大地之力图腾
                local AGI_BOK = (FACTION == "Alliance") and (( isMyBuff(20217) or isMyBuff(25898) ) and 0 or 0.1) or 0--王者 10%
                local CRIT_RAMPAGE = isMyBuff(24932) and 0 or 3 --暴怒或者兽群领袖

                local crit = CRIT_RAMPAGE
                local agi = AGI_MOW + AGI_HOW + AGI_IMPROVED_SOE
                local modAgi = AGI_BOK
                local hit = 0

                return crit, agi, modAgi, hit
            else
                return 0, 0, 0, 0
            end
        end

        local getWorldBuff = function()
            if (aura_env.config.world.rallyingCryOfTheDragonslayer or aura_env.config.world.spiritOfZandalar or aura_env.config.world.songflowerSerenade) and attackingDummy then

                --屠龙者的咆哮 5暴击 355363 22888 |T134153:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 屠龙者的咆哮
                --icon 134153
                local rallyingCryOfTheDragonslayerCrit = aura_env.config.world.rallyingCryOfTheDragonslayer and ((WA_GetUnitBuff("player",22888) or WA_GetUnitBuff("player",355363)) and 0 or 5) or 0

                --赞达拉之魂 15%属性 355365 24425 |T132107:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 赞达拉之魂
                --icon 132107
                local spiritOfZandalarModStat = aura_env.config.world.spiritOfZandalar and ((WA_GetUnitBuff("player",22888) or WA_GetUnitBuff("player",355363)) and 0 or 0.15) or 0

                --酋长的祝福 355366
                --icon 135759

                --塞格的黑暗塔罗牌：伤害 10%上海 23768
                --icon 134334

                --风歌夜曲 5暴击 15属性 15366 |T135934:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 风歌夜曲
                --135934
                local songflowerSerenadeCrit = aura_env.config.world.songflowerSerenade and (WA_GetUnitBuff("player",15366) and 0 or 5) or 0
                local songflowerSerenadeAgi = aura_env.config.world.songflowerSerenade and (WA_GetUnitBuff("player",15366) and 0 or 15) or 0

                --塞格的黑暗塔罗牌：敏捷 10%敏捷 23736 不建议获取这个，推荐伤害 |T134334:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 塞格的黑暗塔罗牌：敏捷 - 没人用，建议关闭
                --icon 134334
                local SaygesDarkFortuneOfAgilityModAgi = aura_env.config.world.SaygesDarkFortuneOfAgility and (WA_GetUnitBuff("player",23736) and 0 or 0.1) or 0

                local crit = rallyingCryOfTheDragonslayerCrit + songflowerSerenadeCrit
                local agi = songflowerSerenadeAgi + SaygesDarkFortuneOfAgilityModAgi
                local modAgi = (1 + spiritOfZandalarModStat) - 1
                local hit = 0

                return crit, agi, modAgi, hit
            else
                return 0, 0, 0, 0
            end
        end

        local getBuffFromConsumable = function()
            if (aura_env.config.consumable.elixirOfTheMongoose or aura_env.config.consumable.scrollOfAgility or aura_env.config.consumable.mhElementalSharpeningStone or aura_env.config.consumable.ohElementalSharpeningStone or aura_env.config.consumable.strikeOfTheScorpok) and attackingDummy then

                --猫鼬药剂 2暴击 25敏 17538 |T134812:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 猫鼬药剂
                local elixirOfTheMongooseCrit = aura_env.config.consumable.elixirOfTheMongoose and (WA_GetUnitBuff("player",17538) and 0 or 2) or 0
                local elixirOfTheMongooseAgi = aura_env.config.consumable.elixirOfTheMongoose and (WA_GetUnitBuff("player",17538) and 0 or 25) or 0

                --敏捷卷轴 IV 17敏 12174 |T134934:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 敏捷卷轴 IV
                local scrollOfAgilityAgi = aura_env.config.consumable.scrollOfAgility and (WA_GetUnitBuff("player",12174) and 0 or 17) or 0

                --烤鱿鱼 10敏 18192 |T133899:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 烤鱿鱼
                local winterSquidAgi = aura_env.config.consumable.winterSquid and (WA_GetUnitBuff("player",12174) and 0 or 10) or 0

                --黑色欲望(情人节) IV 2命中 27723 |T135460:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 黑色欲望(情人节)
                local darkDesireHit = aura_env.config.consumable.darkDesire and (WA_GetUnitBuff("player",27723) and 0 or 2) or 0

                --元素磨刀石 2暴击 武器附魔 (select(4,GetWeaponEnchantInfo()) == 2506) |T135841:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 元素磨刀石
                local mhElementalSharpeningStoneCrit = aura_env.config.consumable.mhElementalSharpeningStone and ((select(4,GetWeaponEnchantInfo()) == 2506) and 0 or 2) or 0
                local ohElementalSharpeningStoneCrit = aura_env.config.consumable.ohElementalSharpeningStone and ((select(8,GetWeaponEnchantInfo()) == 2506) and 0 or 2) or 0

                --厚甲蝎药粉 25敏 10669 |T133849:14:14:0:0:64:64:4:60:4:60|t|CFFFFFFA2 厚甲蝎药粉
                local strikeOfTheScorpokAgi = aura_env.config.consumable.strikeOfTheScorpok and (WA_GetUnitBuff("player",10669) and 0 or 25) or 0

                local crit = elixirOfTheMongooseCrit + mhElementalSharpeningStoneCrit + ohElementalSharpeningStoneCrit
                local agi = strikeOfTheScorpokAgi + scrollOfAgilityAgi + elixirOfTheMongooseAgi + winterSquidAgi
                local modAgi = 0
                local hit = darkDesireHit

                return crit, agi, modAgi, hit
            else
                return 0, 0, 0, 0
            end
        end

        local getAllExtraBuff = function()
            local worldBuffCrit, worldBuffAgi, worldBuffModAgi, worldBuffModHit = getWorldBuff()
            local consumableCrit, consumableAgi, consumableModAgi, consumableModHit = getBuffFromConsumable()
            local raidBuffCrit, raidBuffAgi, raidBuffModAgi, raidBuffModHit = getRaidBuff()

            local totalCrit = worldBuffCrit + consumableCrit + raidBuffCrit
            local totalAgi = worldBuffAgi + consumableAgi + raidBuffAgi
            local totalModAgi = (1 + worldBuffModAgi) * (1 + consumableModAgi) * (1 + raidBuffModAgi) - 1
            local totalHit = worldBuffModHit + consumableModHit + raidBuffModHit

            local myAgi = UnitStat("player", 2)

            local extraAgi = math.floor(myAgi * totalModAgi) + math.floor(totalAgi * (1 + totalModAgi))
            local finalExtraCrit = totalCrit + getCritChanceFromAgi(extraAgi)

            return finalExtraCrit, totalHit
        end

        --基础值
        local THE_SHOT = 100 --总100
        local BOSS_REDUCE = 3 --骷髅怪+3免爆
        local CRIT_AURA_REDUCE = 1.8 --骷髅怪或者+3怪的暴击光环-1.8
        local GLANCING_REDUCE = 40 --偏斜几率24%
        local BASE_PARRY = 14 --招架（需要扣减精准）
        local BASE_DODGE = 6.5 --闪避（需要扣减精准）
        local BASE_BLOCK = 5 --格挡5%

        --武器技能
        local mhWeaponSkill, ohWeaponSkill, mhBaseWeaponSkill, mhExtraWeaponSkill, ohBaseWeaponSkill, ohExtraWeaponSkill = getWeaponSkills()
        local thisWeaponSkill = isOffhand and ohWeaponSkill or mhWeaponSkill
        local thisBaseWeaponSkill = isOffhand and ohBaseWeaponSkill or mhBaseWeaponSkill
        local thisExtraWeaponSkill = isOffhand and ohExtraWeaponSkill or mhExtraWeaponSkill
        local extraWeaponSkill = max(thisWeaponSkill - 300, thisExtraWeaponSkill)

        --暴击
        local baseCrit = GetCritChance() - extraWeaponSkill * 0.04
        local auraCritPenalty = (baseCrit - getCritChanceFromAgi()) > 0 and CRIT_AURA_REDUCE or 0
        local reducedCrit = max(baseCrit - BOSS_REDUCE - auraCritPenalty, 0)
        local allExtraBuffCrit, allExtraBuffHit = getAllExtraBuff()
        local finalCrit = reducedCrit + allExtraBuffCrit

        --crit 为了显示用，因为要包含技能部分，否则玩家会发现跟面板对不上会有困惑，实际面板是错的
        local crit = GetCritChance()
        local combatCrit = crit + allExtraBuffCrit

        --hit
        local dualwieldReuce = IsDualWielding() and 27 or 8 --双武器判断27 or 0
        local hitByRating = GetCombatRatingBonus(6) --60级=0
        local voidHit = (extraWeaponSkill > 5) and 0 or 1
        local hit = GetHitModifier() or 0 --60级是装备+天赋
        local hitFromWeaponSkill = (extraWeaponSkill <= 5) and (extraWeaponSkill * 0.2) or (1 + ( extraWeaponSkill - 5 ) * 0.1)
        local combatHit = hitByRating + hit + hitFromWeaponSkill + allExtraBuffHit

        --战士卡英勇的命中修正 --还需要记录数据
        local hsCovered = ""
        if ( class == "WARRIOR" and ( IsCurrentSpell(heroicStrikeId) or IsCurrentSpell(cleaveId) ) )then
            dualwieldReuce = 8 --普攻等于没有双持
        elseif ( class == "WARRIOR" and not ( IsCurrentSpell(heroicStrikeId) or IsCurrentSpell(cleaveId) ) )then
            hsCovered = "(无英勇)"
        end

        local parry = isDalian and math.max(BASE_PARRY - (extraWeaponSkill * 0.04), 0) or 0
        local block = isDalian and ( (extraWeaponSkill > 15) and (BASE_BLOCK - ((extraWeaponSkill - 15) * 0.1)) or BASE_BLOCK ) or 0 --打脸不是？ 15以上的武器技能才会开始减少格挡
        local dodge = math.max(BASE_DODGE - (extraWeaponSkill * 0.1), 0)

        --100-偏斜[40]-(双持未命中[27]-天赋命中[5]-玩家装备命中[]-武器技能未命中[分段]+命中无效化[1or0])-(怪物躲闪[6.5]-武器等级[]*0.1)+暴击减免[4.8]-(面板全身暴击) - (正面招架[14]-武器等级[]*0.04) - (正面格挡[5])

        local final = THE_SHOT - math.max( (dualwieldReuce + voidHit - combatHit), 0 ) - GLANCING_REDUCE - ( finalCrit ) - parry - dodge - block
        -- print("final="..final.." finalCrit="..finalCrit.." reducedCrit="..reducedCrit.." DW="..dualwieldReuce.." voidHit="..voidHit.." hit="..hit.." parry="..parry.." dodge="..dodge.." block="..block)
        jtprint("最终="..((final < 0 and "|CFFFF53A2" or "|CFFFFFFFF")..SR(final)).."|R 当前面板=|CFFFFFFFF"..SR(crit).."|R 模拟BUFF=|CFFFFFFFF"..SR(allExtraBuffCrit).."|R 模拟后面板=|CFFFFFFFF"..SR(combatCrit).."|R 真实暴击=|CFFFFFFFF"..SR(finalCrit).."|R 惩罚后面板=|CFFFFFFFF"..SR(reducedCrit).."|R")
        local result = {
            time = ( GetTime() - startCombatTime ) or 0,
            final = final,
            crit = crit,
            combatCrit = combatCrit,
            hit = hit,
            combatHit = combatHit,
            dodge = dodge,
            isDalian = isDalian,
            isOffhand = isOffhand,
            hsCovered = hsCovered,
        }

        return result
    else
        return false
    end
end

--最接近记录
local toCapFromBack = {
    time = 0,
    final = 100,
    crit = 0,
    combatCrit = 0,
    hit = 0,
    combatHit = 0,
    dodge = 0,
    isDalian = false,
    isOffhand = false,
    hsCovered = "",
}
local toCapFromFront = {
    time = 0,
    final = 100,
    crit = 0,
    combatCrit = 0,
    hit = 0,
    combatHit = 0,
    dodge = 0,
    isDalian = true,
    isOffhand = false,
    hsCovered = "",
}
--存log，最后统计打印。
local CritCapLogs = {}
local CritCapLogCount = 0

local SaveCritCapLogs = function(result)
    result.timestr = testingWithUnknownBuff and "|CFFFF0000有其他BUFF测试不准确|R" or date("%H:%M:%S")
    result.attackingDummy = attackingDummy
    CritCapLogs[#CritCapLogs+1] = result
    CritCapLogCount = CritCapLogCount + 1
    if #CritCapLogs > 200 then
        table.remove(CritCapLogs, 1)
    end
end

local calculateCritCap = function(isDalian, isOffhand)
    local result = CheckCritCap(isDalian, isOffhand)
    if not result then return end

    if isDalian then
        if result.final < toCapFromFront.final then
            toCapFromFront = result
        end
    else
        if result.final < toCapFromBack.final then
            toCapFromBack = result
        end
    end

    if result.final < 0 then
        SaveCritCapLogs(result)
    end
end

local reportCritCap = function()
    if not aura_env.config.enableCritCap then return end --开关不通报
    if next(CritCapLogs) then
        local link = "|cff71D5FF|Hgarrmission:JTE:CritCapFrame|h[点击查看]|h|r"
        print((ONLY_ICON):format("|CFFFF53A2>.<|R").."本次战斗有 |CFFFF53A2暴击阈值|R 问题 - "..link.."或点击头像附近红脸查看")
    end

    if toCapFromBack.time == 0 and toCapFromFront.time == 0 then
        return
    end

    local printCritCapInfo = function(result)
        local DALIAN_TEXT = result.isDalian and "|CFFFF53A2打脸|R" or "|CFFFFFF00打背|R"
        local TOCAP_TEXT = (result.final < 0 and "超出暴击阈值|CFFFF53A2" or "距离阈值还差|CFFFFFFFF")..SR(result.final).."|R"
        local HAND_TEXT = (result.isOffhand and "副手" or "主手")..(result.hsCovered or "")
        print((ONLY_ICON):format("|CFFFF53A2>.<|R")..(attackingDummy and "|CFF1785D1模拟|R" or "").."第|CFFFFFFFF"..SN(result.time).."|R秒"..HAND_TEXT..DALIAN_TEXT..TOCAP_TEXT.." 当时:暴击|CFFFFFFFF"..SR(result.crit)..(attackingDummy and ("(|CFF1785D1BUFF后|R"..SR(result.combatCrit)) or "")..")|R 命中|CFFFFFFFF"..SR(result.hit)..(attackingDummy and ("(|CFF1785D1战斗|R"..SR(result.combatHit)) or "")..")|R")
    end

    if toCapFromBack.final < 0 then
        printCritCapInfo(toCapFromBack)

        if EXPANSION == 2 then
            local limit = 80.8
            if toCapFromBack.combatCrit > limit then
                print((ONLY_ICON):format("|CFFFF53A2>.<|R").."你的暴击已经超出普攻暴击的|CFFFF53A2极限"..limit.."%|R，请查看红脸详情")
            end
        elseif EXPANSION == 0 then
            local limit = 64.8
            if toCapFromBack.combatCrit > limit then
                print((ONLY_ICON):format("|CFFFF53A2>.<|R").."你的暴击已经超出普攻暴击的|CFFFF53A2极限"..limit.."%|R，请查看红脸详情")
            end
        end

    else
        if toCapFromFront.final < 0 then
            printCritCapInfo(toCapFromFront)
            print((ONLY_ICON):format("|CFFFF53A2>.<|R").."|CFFFF53A2不要打脸!|R |CFFFFFF00正面更容易遇到阈值问题|R - 正面有招架+格挡")
        end
    end
end



local resetSlapperOnceMore = true
local ResetData = function()

    attackingDummy = false
    testingWithUnknownBuff = nil

    swingParryCount = 0
    spellParryCount = 0
    blockedCount = 0
    totalBlockedDamage = 0
    startCombatTime = GetTime()
    swingDalianTimeWaste = 0
    spellDalianTimeWaste = 0
    lastDalianTime = 0

    toCapFromBack = {
        time = 0,
        final = 100,
        crit = 0,
        combatCrit = 0,
        hit = 0,
        combatHit = 0,
        dodge = 0,
        isDalian = false,
        isOffhand = false,
        hsCovered = "",
    }
    toCapFromFront = {
        time = 0,
        final = 100,
        crit = 0,
        combatCrit = 0,
        hit = 0,
        combatHit = 0,
        dodge = 0,
        isDalian = true,
        isOffhand = false,
        hsCovered = "",
    }
    CritCapLogs = {}
    CritCapLogCount = 0
end

ResetData()

local ResetSlapper = function()
    jtprint("OnEn-start")
    if aura_env.config.enableRollDalianwang then
        WeakAuras.ScanEvents("JT_RESETSLAPPER")
        resetSlapperOnceMore = true
    elseif resetSlapperOnceMore then
        WeakAuras.ScanEvents("JT_RESETSLAPPER")
        resetSlapperOnceMore = false
    end
end

local passCritCaplogs = function()
    if #CritCapLogs > 0 then
        WeakAuras.ScanEvents("JT_CRITCAP_PASS_DATA", CritCapLogs, CritCapLogCount)
    end
end

--测试假人
local testTarget = {
    [31146] = true, -- 英雄训练假人
}
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

local CanTriggerDalian = function(destGUID)
    local targetName = UnitName("target")
    local targetGUID = UnitGUID("target")
    if ( aura_env.config.enableDummy and isTestTarget(targetGUID) ) then
        if not attackingDummy then
            attackingDummy = true
            print(HEADER_TEXT.."本次战斗攻击过 |CFF1785D1"..targetName.."|R 开始测试 - |R"..date("%H:%M:%S"))
            if IsInGroup() then
                print(HEADER_TEXT.."你在队伍中! 如果有队友的增益效果会影响测试结果!")
            end
        end
        return true
    elseif ( ( destGUID == targetGUID and not UnitIsUnit("targettarget","player") and UnitExists("targettarget")) ) then
        return true
    else
        return false
    end
end

local DalianleEvent = function()
    WeakAuras.ScanEvents("JT_DALIANLE", aura_env.config.isFaceText, aura_env.config.isVoice)
end

local playerGUID = UnitGUID("player")
local OnCLEUF = function(...)
    if not isMelee then return end

    local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, arg12, arg13, _, arg15, arg16, _, _, arg19, _, arg21 = ...
    if sourceGUID == playerGUID then
        local targetGUID = UnitGUID("target")
        -- local attackingBoss = ( destGUID == UnitGUID("target") and UnitAffectingCombat("player") and ( UnitClassification("target") == "worldboss" or UnitLevel("target") == -1 or UnitLevel("target") == BOSS_LEVEL[EXPANSION] ) and UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend("player","target") and UnitCanAttack("player","target") ) and true or false 
        local attackingBoss = ( destGUID == targetGUID and UnitAffectingCombat("player") and ( UnitClassification("target") == "worldboss" or UnitLevel("target") == -1 or UnitLevel("target") == BOSS_LEVEL[EXPANSION] or (EXPANSION == 0 and aura_env.config.enableDummy and isTestTarget(targetGUID)) ) and UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend("player","target") and UnitCanAttack("player","target") ) and true or false

        if not attackingDummy then CanTriggerDalian(destGUID) end

        if subevent == "SWING_MISSED" then
            --swing的副手是arg13
            local isOffhand = arg13

            if arg12 == "PARRY" then
                if CanTriggerDalian(destGUID) then DalianleEvent() end

                swingParryCount = swingParryCount + 1

                local mhSpeed, ohSpeed = UnitAttackSpeed("player")
                local thisSpeed = arg13 and ohSpeed or mhSpeed
                local wasteTime = math.min((timestamp - lastDalianTime), thisSpeed)
                lastDalianTime = timestamp
                swingDalianTimeWaste = swingDalianTimeWaste + wasteTime

                if aura_env.config.enableCritCap and attackingBoss then
                    calculateCritCap(true, isOffhand)
                end
            else
                if aura_env.config.enableCritCap and attackingBoss then
                    calculateCritCap(false, isOffhand)
                end
            end
        elseif subevent == "SPELL_MISSED" then
            --spell就不考虑副手了
            if arg15 == "PARRY" then
                if CanTriggerDalian(destGUID) then DalianleEvent() end

                spellParryCount = spellParryCount + 1
                -- local isOffhand = arg16
                lastDalianTime = timestamp

                local _,gcd = GetSpellCooldown(61304)
                spellDalianTimeWaste = spellDalianTimeWaste + gcd
            end
        elseif subevent == "SWING_DAMAGE" then

            local blocked = arg16
            local isOffhand = arg21
            if blocked then
                if CanTriggerDalian(destGUID) then DalianleEvent() end

                blockedCount = blockedCount + 1
                totalBlockedDamage = totalBlockedDamage + blocked

                --攻击如果是副手
                local mhSpeed, ohSpeed = UnitAttackSpeed("player")
                local thisSpeed = arg13 and ohSpeed or mhSpeed
                local wasteTime = math.min((timestamp - lastDalianTime), thisSpeed)
                lastDalianTime = timestamp
                swingDalianTimeWaste = swingDalianTimeWaste + wasteTime
                if aura_env.config.enableCritCap and attackingBoss then
                    calculateCritCap(true, isOffhand)
                end
            else
                if aura_env.config.enableCritCap and attackingBoss then
                    calculateCritCap(false, isOffhand)
                end
            end
        elseif subevent == "SPELL_DAMAGE" then
            --print(subevent.." blocked arg19="..tostring(arg19))
            local blocked = arg19
            if blocked then
                if CanTriggerDalian(destGUID) then DalianleEvent() end

                blockedCount = blockedCount + 1
                totalBlockedDamage = totalBlockedDamage + blocked

                lastDalianTime = timestamp

                local _,gcd = GetSpellCooldown(61304)
                spellDalianTimeWaste = spellDalianTimeWaste + gcd
            end
        end
    end
    return true
end

local OnEncounterStart = function(event, ...)
    if event == "ENCOUNTER_START" then
        ResetSlapper()
    end
    ResetData()
end

local OnEncounterEnd = function(event, ...)
    if event == "ENCOUNTER_END" or attackingDummy then
        ReportDalian()
    end
    reportCritCap()
    passCritCaplogs()
end

local OnTalentUpdate = function()
    isMelee = CheckMeleeTalent()
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "ENCOUNTER_START" or ( event == "PLAYER_REGEN_DISABLED" and aura_env.config.enableDummy ) then
        OnEncounterStart(event, ...)
    elseif event == "ENCOUNTER_END" or ( event == "PLAYER_REGEN_ENABLED" and aura_env.config.enableDummy and attackingDummy ) then
        OnEncounterEnd(event, ...)
    elseif event == "PLAYER_TALENT_UPDATE" then
        OnTalentUpdate()
    elseif event == "JT_D_DALIAN" then
        ToggleDebug()
    end
end