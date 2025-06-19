--版本信息
local version = 250612
local soundPack = "TTS"
local voicePackCheck = true --check过VP就会false

local myGUID = UnitGUID("player")

--所有技能table
local RAID_SKILLS = {
    -- --测试数据
    -- [1784] = {
    --     file = "Common\\地狱火.ogg",--地狱火
    --     ttsText = "地狱火",
    --     ttsSpeed = 0
    -- },
    -- [48659] = {
    --     file = "Common\\冰箱.ogg",--破釜沉舟
    --     ttsText = "冰箱",
    --     ttsSpeed = 0
    -- },
    -- [51723] = {
    --     file = "Common\\光环掌握.ogg",--光环掌握
    --     ttsText = "光环掌握",
    --     ttsSpeed = 3
    -- },
    -- [48638] = {
    --     file = "Common\\嘲讽抵抗.ogg",--嘲讽抵抗
    --     ttsText = "嘲讽抵抗",
    --     ttsSpeed = 2
    -- },
    
    --id to sound file
    --taunt skills |T136080:14:14:0:0:64:64:4:60:4:60|t |T132270:14:14:0:0:64:64:4:60:4:60|t |T135068:14:14:0:0:64:64:4:60:4:60|t |T135984:14:14:0:0:64:64:4:60:4:60|t |T237532:14:14:0:0:64:64:4:60:4:60|t |T136088:14:14:0:0:64:64:4:60:4:60|t
    --des  |T237532:14:14:0:0:64:64:4:60:4:60|t 嘲讽 |n |T136088:14:14:0:0:64:64:4:60:4:60|t 低吼 |n |T136080:14:14:0:0:64:64:4:60:4:60|t 正义防御 |n |T132270:14:14:0:0:64:64:4:60:4:60|t 清算之手(坦克) |n |T135068:14:14:0:0:64:64:4:60:4:60|t 死亡之握(坦克) |n |T135984:14:14:0:0:64:64:4:60:4:60|t 黑暗命令
    [355] = {
        file = "Common\\嘲讽抵抗.ogg", -- |T237532:14:14:0:0:64:64:4:60:4:60|t 嘲讽
        ttsText = "嘲讽抵抗",
        ttsSpeed = 2
    },
    [6795] = {
        file = "Common\\嘲讽抵抗.ogg", -- |T136088:14:14:0:0:64:64:4:60:4:60|t 低吼
        ttsText = "嘲讽抵抗",
        ttsSpeed = 2
    },
    [31789] = {
        file = "Common\\嘲讽抵抗.ogg", -- |T136080:14:14:0:0:64:64:4:60:4:60|t 正义防御
        ttsText = "嘲讽抵抗",
        ttsSpeed = 2
    },
    [62124] = {
        file = "Common\\嘲讽抵抗.ogg", -- |T132270:14:14:0:0:64:64:4:60:4:60|t 清算之手(坦克)
        ttsText = "嘲讽抵抗",
        ttsSpeed = 2
    },
    [49576] = {
        file = "Common\\嘲讽抵抗.ogg", -- |T135068:14:14:0:0:64:64:4:60:4:60|t 死亡之握(坦克)
        ttsText = "嘲讽抵抗",
        ttsSpeed = 2
    },
    [56222] = {
        file = "Common\\嘲讽抵抗.ogg", -- |T135984:14:14:0:0:64:64:4:60:4:60|t 黑暗命令
        ttsText = "嘲讽抵抗",
        ttsSpeed = 2
    },
    
    --COMMON
    [19805] = {
        file = "Common\\高级活动假人.ogg", -- |T132762:14:14:0:0:64:64:4:60:4:60|t 高级活动假人
        ttsText = "高级活动假人",
        ttsSpeed = 5
    },
    [4072] = {
        file = "Common\\高级假人.ogg", -- |T132765:14:14:0:0:64:64:4:60:4:60|t 高级假人
        ttsText = "高级假人",
        ttsSpeed = 2
    },
    [4071] = {
        file = "Common\\活动假人.ogg", -- |T132766:14:14:0:0:64:64:4:60:4:60|t 活动假人
        ttsText = "活动假人",
        ttsSpeed = 2
    },
    
    --normal skills
    --WAR |T626008:14:14:0:0:64:64:4:60:4:60|t |cffc79c6e战士|r
    [871] = {
        file = "Common\\盾墙.ogg",-- |T132362:14:14:0:0:64:64:4:60:4:60|t 盾墙
        ttsText = "盾墙",
        ttsSpeed = 0
    },
    [12976] = {
        file = "Common\\破釜.ogg",-- |T135871:14:14:0:0:64:64:4:60:4:60|t 破釜沉舟
        ttsText = "破釜",
        ttsSpeed = 0
    },
    
    --PAL |T626003:14:14:0:0:64:64:4:60:4:60|t |cfff58cba圣骑士|r
    [66233] = {
        file = "Common\\春哥了.ogg",-- |T135870:14:14:0:0:64:64:4:60:4:60|t 炽热防御者
        ttsText = "春哥了",
        ttsSpeed = 1
    },
    [64205] = {
        file = "Common\\神圣牺牲.ogg",-- |T253400:14:14:0:0:64:64:4:60:4:60|t 神圣牺牲
        ttsText = "神圣牺牲",
        ttsSpeed = 3
    },
    [498] = {
        file = "Common\\圣佑.ogg",-- |T135954:14:14:0:0:64:64:4:60:4:60|t 圣佑术
        ttsText = "圣佑",
        ttsSpeed = 0
    },
    [642] = {
        file = "Common\\无敌.ogg",-- |T135896:14:14:0:0:64:64:4:60:4:60|t 圣盾术
        ttsText = "无敌",
        ttsSpeed = 0
    },
    [31821] = {
        file = "Common\\光环掌握.ogg",-- |T135872:14:14:0:0:64:64:4:60:4:60|t 光环掌握
        ttsText = "光环掌握",
        ttsSpeed = 3
    },
    [48788] = {
        file = "Common\\圣疗.ogg",-- |T135928:14:14:0:0:64:64:4:60:4:60|t 圣疗术
        ttsText = "圣疗",
        ttsSpeed = 0
    },
    [10278] = {
        file = "Common\\保护.ogg",-- |T135964:14:14:0:0:64:64:4:60:4:60|t 保护之手
        ttsText = "保护",
        ttsSpeed = 0
    },
    [6940] = {
        file = "Common\\牺牲.ogg",-- |T135966:14:14:0:0:64:64:4:60:4:60|t 牺牲之手
        ttsText = "牺牲",
        ttsSpeed = 0
    },
    [19752] = {
        file = "Common\\干涉.ogg",-- |T136106:14:14:0:0:64:64:4:60:4:60|t 神圣干涉
        ttsText = "干涉",
        ttsSpeed = 0
    },
    
    --DK |T135771:14:14:0:0:64:64:4:60:4:60|t |cffc41f3b死亡骑士|r
    [48792] = {
        file = "Common\\冰韧.ogg",-- |T237525:14:14:0:0:64:64:4:60:4:60|t 冰封之韧
        ttsText = "冰韧",
        ttsSpeed = 0
    },
    [55233] = {
        file = "Common\\吸血鬼之血.ogg",-- |T136168:14:14:0:0:64:64:4:60:4:60|t 吸血鬼之血
        ttsText = "吸血鬼之血",
        ttsSpeed = 0
    },
    [48707] = {
        file = "Common\\绿霸.ogg",-- |T136120:14:14:0:0:64:64:4:60:4:60|t 反魔法护罩
        ttsText = "绿霸",
        ttsSpeed = 0
    },
    
    --SM |T626006:14:14:0:0:64:64:4:60:4:60|t |cff0070de萨满祭司|r
    [2825] = {
        file = "Common\\嗜血.ogg",-- |T136012:14:14:0:0:64:64:4:60:4:60|t 嗜血
        ttsText = "嗜雪",
        ttsSpeed = 0
    },
    [32182] = {
        file = "Common\\英勇.ogg",-- |T132313:14:14:0:0:64:64:4:60:4:60|t 英勇
        ttsText = "英勇",
        ttsSpeed = 0
    },
    [16190] = {
        file = "Common\\法力之潮.ogg",-- |T135861:14:14:0:0:64:64:4:60:4:60|t 法力之潮图腾
        ttsText = "法力之潮",
        ttsSpeed = 0
    },
    
    --HT |T626000:14:14:0:0:64:64:4:60:4:60|t |cffabd473猎人|r
    [19263] = {
        file = "Common\\威慑.ogg",-- |T132369:14:14:0:0:64:64:4:60:4:60|t 威慑
        ttsText = "威慑",
        ttsSpeed = 0
    },
    
    --DRU |T625999:14:14:0:0:64:64:4:60:4:60|t |cffff7d0a德鲁伊|r
    [61336] = {
        file = "Common\\生存本能.ogg",-- |T236169:14:14:0:0:64:64:4:60:4:60|t 生存本能
        ttsText = "生存本能",
        ttsSpeed = 0
    },
    [22812] = {
        file = "Common\\树皮.ogg",-- |T136097:14:14:0:0:64:64:4:60:4:60|t 树皮术
        ttsText = "树皮",
        ttsSpeed = 0
    },
    [29166] = {
        file = "Common\\激活.ogg",-- |T136048:14:14:0:0:64:64:4:60:4:60|t 激活
        ttsText = "激活",
        ttsSpeed = 0
    },
    
    --ROG |T626005:14:14:0:0:64:64:4:60:4:60|t |cfffff569盗贼|r
    [45182] = {
        file = "Common\\装死.ogg",-- |T132285:14:14:0:0:64:64:4:60:4:60|t 装死
        ttsText = "装死",
        ttsSpeed = 0
    },
    
    --PRI |T626004:14:14:0:0:64:64:4:60:4:60|t |cffffffff牧师|r
    [33206] = {
        file = "Common\\压制.ogg",-- |T135936:14:14:0:0:64:64:4:60:4:60|t 痛苦压制
        ttsText = "压制",
        ttsSpeed = 0
    },
    [6346] = {
        file = "Common\\防恐.ogg",-- |T135902:14:14:0:0:64:64:4:60:4:60|t 防护恐惧结界
        ttsText = "防恐",
        ttsSpeed = 0
    },
    [47788] = {
        file = "Common\\守护之魂.ogg",-- |T237542:14:14:0:0:64:64:4:60:4:60|t 守护之魂
        ttsText = "守护之魂",
        ttsSpeed = 3
    },
    [64843] = {
        file = "Common\\神歌.ogg",-- |T237540:14:14:0:0:64:64:4:60:4:60|t 神圣赞美诗
        ttsText = "神歌",
        ttsSpeed = 0
    },
    [64901] = {
        file = "Common\\蓝歌.ogg",-- |T135982:14:14:0:0:64:64:4:60:4:60|t 希望圣歌
        ttsText = "蓝歌",
        ttsSpeed = 0
    },
    [47585] = {
        file = "Common\\消散.ogg",-- |T237563:14:14:0:0:64:64:4:60:4:60|t 消散
        ttsText = "消散",
        ttsSpeed = 0
    },
    
    --MAGE |T626001:14:14:0:0:64:64:4:60:4:60|t |cff40c7eb法师|r
    [45438] = {
        file = "Common\\冰箱.ogg",-- |T135841:14:14:0:0:64:64:4:60:4:60|t 寒冰屏障
        ttsText = "冰箱",
        ttsSpeed = 0
    },
    
    --PRI |T626007:14:14:0:0:64:64:4:60:4:60|t |cff8787ed术士|r
    [1122] = {
        file = "Common\\地狱火.ogg",-- |T136219:14:14:0:0:64:64:4:60:4:60|t 地狱火
        ttsText = "地狱火",
        ttsSpeed = 0
    },
}

local REQUIRE_ROLE = {
    -- --测试
    -- [48638] = "MAINTANK", --测试 邪恶攻击-嘲讽抵抗
    
    [22812] = "MAINTANK", -- 树皮术
    [62124] = "MAINTANK", -- 清算之手 坦克嘲讽技能
    -- [498] = "MAINTANK", -- 圣佑术
    -- [642] = "MAINTANK", -- 圣盾术
    [48707] = "MAINTANK", -- 反魔法护罩 坦克保命技能
    [49576] = "MAINTANK", -- 死亡之握 坦克嘲讽技能
}
local REQUIRE_COMBATROLE = {
    -- --测试
    -- [48638] = "TANK", --测试 邪恶攻击-嘲讽抵抗
    
    [22812] = "TANK", -- 树皮术
    [62124] = "TANK", -- 清算之手 坦克嘲讽技能
    -- [498] = "TANK", -- 圣佑术
    -- [642] = "TANK", -- 圣盾术
    [48707] = "TANK", -- 反魔法护罩 坦克保命技能
    [49576] = "TANK",-- 死亡之握 坦克嘲讽技能
}

local SUBEVENT_FIX = {
    -- --测试
    -- [51723] = "SPELL_CAST_SUCCESS", --测试 刀扇-法嘲
    -- [48638] = "SPELL_MISSED", --测试 邪恶攻击-嘲讽抵抗
    
    --defauls (not in the table) is SPELL_AURA_APPLIED
    --common
    [19805] = "SPELL_CAST_SUCCESS", -- 高级活动假人
    [4072] = "SPELL_CAST_SUCCESS", -- 高级假人
    [4071] = "SPELL_CAST_SUCCESS", -- 活动假人
    
    --shaman
    [2825] = "SPELL_CAST_SUCCESS", -- 嗜血
    [32182] = "SPELL_CAST_SUCCESS", -- 英勇
    [16190] = "SPELL_CAST_SUCCESS", --法力之潮图腾
    
    --paladin
    [48788] = "SPELL_CAST_SUCCESS", --圣疗术
    [19752] = "SPELL_CAST_SUCCESS", --神圣干涉
    [64205] = "SPELL_CAST_SUCCESS", --神圣牺牲
    
    --warlock
    [1122] = "SPELL_CAST_SUCCESS", --地狱火
    
    --taunt skill MISSED
    [31789] = "SPELL_MISSED", --正义防御
    [62124] = "SPELL_MISSED", --清算之手
    [49576] = "SPELL_MISSED", --死亡之握
    [56222] = "SPELL_MISSED", --黑暗命令
    [355] = "SPELL_MISSED", --嘲讽
    [6795] = "SPELL_MISSED", --低吼
}

local SKILLS = {}

local ReorganizeSkills = function()
    if not RAID_SKILLS then return end
    
    for k, v in pairs(RAID_SKILLS) do
        if SUBEVENT_FIX[k] then
            local subevent = SUBEVENT_FIX[k]
            if not SKILLS[subevent] then
                SKILLS[subevent] = {}
            end
            SKILLS[subevent][k] = v
        else
            local subevent = "SPELL_AURA_APPLIED"
            if not SKILLS[subevent] then
                SKILLS[subevent] = {}
            end
            SKILLS[subevent][k] = v
        end
    end
end

local InitConfig = function()
    local validSkills = {
        ["common"] = {
            [1] = 19805, --高级活动假人
            [2] = 4072, --高级假人
            [3] = 4071, --活动假人
        },
        ["warrior"] = {
            [1] = 871, --盾墙
            [2] = 12976, --破釜沉舟
        },
        
        ["paladin"] = {
            [1] = 66233,  --炽热防御者
            [2] = 64205, --神圣牺牲
            [3] = 498, --圣佑术
            [4] = 642, --圣盾术
            [5] = 31821, --神圣牺牲
            [6] = 48788, --圣疗术
            [7] = 10278, --保护之手
            [8] = 6940, --牺牲之手
            [9] = 19752, --神圣干涉
        },
        
        ["deathknight"] = {
            [1] = 48792, --冰封之韧
            [2] = 55233, --吸血鬼之血
            [3] = 48707, --反魔法护罩
        },
        ["hunter"] = {
            [1] = 19263, --威慑
        },
        ["shaman"] = {
            [1] = 2825, --法力之潮图腾
            [2] = 16190, --法力之潮图腾
            [3] = 32182, --法力之潮图腾
        },
        
        ["druid"] = {
            [1] = 61336, --生存本能
            [2] = 22812, --树皮术
            [3] = 29166, --激活
        },
        
        ["rogue"] = {
            [1] = 45182, --装死
        },
        ["priest"] = {
            [1] = 33206, --痛苦压制
            [2] = 6346, --防护恐惧结界
            [3] = 47788, --守护之魂
            [4] = 64843, --神圣赞美诗
            [5] = 64901, --希望圣歌
            [6] = 47585, --消散   
        },
        ["mage"] = {
            [1] = 45438, --寒冰屏障
        },
        ["warlock"] = {
            [1] = 1122, --地狱火
        },
    }
    
    for key, value in pairs(aura_env.config.enableSkills) do
        if value and type(value) == "table" then
            for i , v in ipairs(value) do
                if not v then
                    if validSkills[key] then
                        --print("validSkills[key] = true")
                        if validSkills[key][i] then
                            local disableSkillId = validSkills[key][i]
                            RAID_SKILLS[disableSkillId] = nil
                        end
                    end
                end
            end
        end
    end
    
    --嘲讽抵抗
    local tauntResistSkill = {
        -- --测试
        -- [48638] = true, --测试，邪恶攻击
        
        [31789] = true, --正义防御
        [62124] = true, --清算之手
        [49576] = true, --死亡之握
        [56222] = true, --黑暗命令
        [355] = true, --嘲讽
        [6795] = true, --低吼
    }
    if not aura_env.config.enableTauntResist then
        for k, v in pairs(tauntResistSkill) do
            RAID_SKILLS[k] = nil
        end
    end
    ReorganizeSkills()
end
InitConfig()

local globleVariableName = "JTWA_GROUP_SKILL_IGNORE_MYSELF"
if not _G[globleVariableName] then
    _G[globleVariableName] = {}
end
local ignoreMyself = _G[globleVariableName]

-- print("JTWA_GROUP_SKILL_IGNORE_MYSELF")
-- DevTools_Dump(ignoreMyself)

--[[

-- 其他语音WA在初始化时添加以下代码来忽略自己的技能 避免双重播放导致音量变大
local thisSpellIds = {
    [31821] = true, -- 光环掌握
}
local globleVariableName = "JTWA_GROUP_SKILL_IGNORE_MYSELF"
local ignoreMyself = _G[globleVariableName] or {}

local addIgnoreMyself = function()
    for k, v in pairs(thisSpellIds) do
        ignoreMyself[k] = true
    end
end
addIgnoreMyself()

]]

--播放音频文件
local PlayJTSorTTS = function(file,ttsText,ttsSpeed)
    
    local function tryPSFOrTTS(filePath, text, speed)
        local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
        local filePSF = PATH_PSF..(filePath or "")
        local canplay = PlaySoundFile(filePSF, "Master")
        if not canplay then
            C_VoiceChat.SpeakText(0, (text or ""), 0, (speed or 0), 100)
        end
    end
    
    if JTS and JTS.P then
        local canplay = JTS.P(file)
        if not canplay then
            tryPSFOrTTS(file, ttsText, ttsSpeed)
        end
    else
        tryPSFOrTTS(file, ttsText, ttsSpeed)
    end
end

--author and header
local AURA_ICON = 135936
local AURA_NAME = "JT团队关键技能语音提醒WA"
local AUTHOR = "Jettie@SMTH"
local HEADER_TEXT = ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 " 

--语音包检测
local CHECK_FILE = "Common\\盾墙.ogg"
local REQUIRE_VERSION = 7
local SOUND_FILE_MISSING = "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local checkVoicePack = function()
    if voicePackCheck then
        local auraIcon = AURA_ICON or 135451
        local auraName = AURA_NAME or "JT系列WA"
        local author = AUTHOR or "Jettie@SMTH"
        local smallIcon = "|T"..(auraIcon or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
        local headerText = smallIcon.."[|CFF8FFFA2"..auraName.."|R]|CFF8FFFA2 "

        local checkFile = CHECK_FILE or "Common\\biubiubiu.ogg"
        local soundFileMissing = SOUND_FILE_MISSING or ( "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听") )
        local requireVersion = REQUIRE_VERSION or 0

        print(headerText.."作者:|R "..author)

        if aura_env.config.isVoice then
            local function tryCheckPSF(filePath)
                local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
                local file = PATH_PSF..(filePath or "")
                local canplay, soundHandle = PlaySoundFile(file, "Master")
                local voicePack
                if canplay then
                    StopSound(soundHandle)
                    voicePack = JTS and "JTSound" or "VoicePack"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    voicePack = "TTS"
                    print(headerText.."|CFFFFE0B0未找到语音文件|R，"..soundFileMissing.."|R")
                end
                return voicePack
            end

            if JTS and JTS.P then
                local canplay, soundHandle = JTS.P(checkFile, requireVersion)
                if canplay and soundHandle then
                    StopSound(soundHandle)
                    soundPack = "JTSound"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    soundPack = tryCheckPSF(checkFile)
                end
            else
                soundPack = tryCheckPSF(checkFile)
            end
        end
        voicePackCheck = false
    end
end
checkVoicePack()

-- 符合条件才播报 true
local checkRoleOrCombatRole = function(sourceName, spellId)
    if not REQUIRE_ROLE[spellId] and not REQUIRE_COMBATROLE[spellId] then
        -- print("技能没有主坦克或者团队职责要求")
        return true
    end

    local UnitIndex = UnitInRaid(sourceName)
    if not UnitIndex then
        -- print("不在团队中")
        return true
    else
        
        local _, _, _, _, _, _, _, _, _, role, _, combatRole = GetRaidRosterInfo(UnitIndex)
        -- --测试
        -- role = "MAINTANK"
        -- combatRole = "TANK"
        -- UnitGroupRolesAssigned("player")
        if ( role == REQUIRE_ROLE[spellId] or combatRole == REQUIRE_COMBATROLE[spellId] ) then
            -- print("技能要求主坦克或者团队职责，并且符合条件")
            return true
        else
            return false
        end
    end
end

local OnCLEUF = function(...)
    if not aura_env.config.isVoice then
        return false
    end
    local _, subevent, _, sourceGUID, sourceName, _,_, destGUID, destName,_,_, spellId = ...
    
    if not ( UnitInRaid(sourceName) or UnitInParty(sourceName) or UnitInRaid(destName) or UnitInParty(destName)) then
        return false
    end
    
    if not subevent then return end
    
    if SKILLS[subevent] then
        if SKILLS[subevent][spellId] then
            -- 是否忽略我自己
            if sourceGUID == myGUID and ignoreMyself[spellId] then
                -- print("遇到了忽略技能的技能 团队WA没有播放", spellId)
                return false
            end
            if checkRoleOrCombatRole(sourceName, spellId) then --判断role和combatRole
                PlayJTSorTTS(RAID_SKILLS[spellId].file,RAID_SKILLS[spellId].ttsText,RAID_SKILLS[spellId].ttsSpeed)
                return true
            end
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "OPTIONS_CLOSE" then
        return InitConfig()
    end
end