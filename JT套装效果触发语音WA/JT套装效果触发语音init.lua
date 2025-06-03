--版本信息
local version = 250602
local requireJTSVersion = 15
local soundPack = "TTS"
local voicePackCheck = true --check过VP就会false

local myGUID = UnitGUID("player")

--author and header
local AURA_ICON = 135053
local AURA_NAME = "JT套装效果触发语音WA"
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
    print(HEADER_TEXT.."JTD(ItemSet) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))
end

local SOUND_FILE_PATH = "ItemSet\\"
local SOUND_FILE_FORMAT = ".ogg"
local SOUND_FILE_DEFALT_NAME = "优势"

local tierBuff = {
    ["WARRIOR"] = {
        -- T10 
        -- DPS
        [70855] = "二剃十", -- 2T10
        -- TANK

        -- T9
        -- DPS
        -- TANK

        -- T8
        -- DPS
        [64937] = "二剃八", -- 2T8
        -- TANK

        -- T7
        -- DPS
        [61571] = "四剃七", -- 4T7
        -- TANK

    },
    ["PALADIN"] = {
        -- T10 
        -- DPS
        -- [70769] = "二剃十", -- 2T10 -- 这个是个cast的法术改在tierCast里了
        -- TANK
        [70760] = "四剃十", -- 4T10
        -- HEAL
        -- [70757] = "四剃十", -- 4T10

        -- T9
        -- DPS
        -- TANK
        -- [64883] = "二剃酒", -- 2T9
        -- HEAL

        -- T8
        -- DPS
        -- TANK
        -- HEAL

        -- T7
        -- DPS
        -- TANK
        -- HEAL
    },
    ["DEATHKNIGHT"] = {
        -- T10 
        -- DPS
        [70657] = "四剃十", -- 4T10
        -- TANK
        [70654] = "四剃十", -- 4T10

        -- T9
        -- DPS
        [67117] = "二剃酒", -- 2T9
        -- TANK

        -- T8
        -- DPS
        -- TANK

        -- T7
        -- DPS
        -- TANK
    },
    ["HUNTER"] = {
        -- T10 
        -- DPS
        [70728] = "二剃十", -- 2T10
        [71007] = "四剃十", -- 4T10

        -- T9
        -- DPS
        [67151] = "四剃酒", -- 4T9

        -- T8
        -- DPS
        [64861] = "四剃八", -- 4T8

        -- T7
        -- DPS
    },
    ["SHAMAN"] = {
        -- T10 
        -- DPS
        [70831] = "四剃十", -- 4T10 enhance
        -- HEAL
        -- [70806] = "二剃十", -- 2T10

        -- T9
        -- DPS
        -- HEAL

        -- T8
        -- DPS
        -- HEAL

        -- T7
        -- DPS
        -- HEAL
    },
    ["DRUID"] = {
        -- T10 
        -- DPS
        -- TANK
        -- HEAL

        -- T9
        -- DPS
        -- TANK
        -- HEAL

        -- T8
        -- DPS
        [64823] = "四剃八", -- 4T8 Balance
        -- TANK
        -- HEAL

        -- T7
        -- DPS
        -- TANK
        -- HEAL
    },
    ["ROGUE"] = {
        -- T10 
        -- DPS
        [70802] = "四剃十", -- 4T10

        -- T9
        -- DPS
        [67210] = "二剃酒", -- 2T9

        -- T8
        -- DPS

        -- T7
        -- DPS
    },
    ["MAGE"] = {
        -- T10 
        -- DPS
        [70747] = "四剃十", -- 4T10

        -- T9
        -- DPS

        -- T8
        -- DPS
        [64868] = "二剃八", -- 2T8

        -- T7
        -- DPS
        [62215] = "二剃七", -- 2T7
    },
    ["PRIEST"] = {
        -- T10 
        -- DPS
        -- HEAL

        -- T9
        -- DPS
        -- HEAL

        -- T8
        -- DPS
        [64907] = "四剃八", -- 4T8
        -- HEAL
        -- [64911] = "四剃八", -- 4T8

        -- T7
        -- DPS
        -- HEAL
    },
    ["WARLOCK"] = {
        -- T10 
        -- DPS
        [70840] = "四剃十", -- 4T10

        -- T9
        -- DPS

        -- T8
        -- DPS

        -- T7
        -- DPS
        [61595] = "二剃七", -- 2T7
        [61082] = "四剃七" -- 4T7
    },
}

local tierCast = {
    ["PALADIN"] = {
        -- T10 
        -- DPS
        [70769] = "二剃十", -- 2T10
    }
}

-------------------------------------------------------------------------------------------------
---
if aura_env.config.chooseSoundFile == 2 then
    print(HEADER_TEXT.."将使用|CFFFF53A2特效名称|R语音 ( |CFFFFFFFF不洁之能|R ) |R")
    tierBuff = {
        ["WARRIOR"] = {
            -- T10 
            -- DPS
            [70855] = "渴饮敌血", -- 2T10
            -- TANK

            -- T9
            -- DPS
            -- TANK

            -- T8
            -- DPS
            [64937] = "迅疾反射", -- 2T8
            -- TANK

            -- T7
            -- DPS
            [61571] = "失落者的灵魂", -- 4T7
            -- TANK

        },
        ["PALADIN"] = {
            -- T10 
            -- DPS
            -- [70769] = "风暴刷新", -- 2T10 -- 这个是个cast的法术改在tierCast里了
            -- TANK
            [70760] = "解脱", -- 4T10
            -- HEAL
            -- [70757] = "圣洁", -- 4T10

            -- T9
            -- DPS
            -- TANK
            -- [64883] = "庇护", -- 2T9
            -- HEAL

            -- T8
            -- DPS
            -- TANK
            -- HEAL

            -- T7
            -- DPS
            -- TANK
            -- HEAL
        },
        ["DEATHKNIGHT"] = {
            -- T10 
            -- DPS
            [70657] = "优势", -- 4T10
            -- TANK
            [70654] = "血凝成甲", -- 4T10

            -- T9
            -- DPS
            [67117] = "不洁之能", -- 2T9
            -- TANK

            -- T8
            -- DPS
            -- TANK

            -- T7
            -- DPS
            -- TANK
        },
        ["HUNTER"] = {
            -- T10 
            -- DPS
            [70728] = "攻击弱点", -- 2T10
            [71007] = "钉刺大师", -- 4T10

            -- T9
            -- DPS
            [67151] = "宠物攻强", -- 4T9

            -- T8
            -- DPS
            [64861] = "精准射击", -- 4T8

            -- T7
            -- DPS
        },
        ["SHAMAN"] = {
            -- T10 
            -- DPS
            [70831] = "漩涡能量", -- 4T10 enhance
            -- HEAL
            -- [70806] = "激流", -- 2T10

            -- T9
            -- DPS
            -- HEAL

            -- T8
            -- DPS
            -- HEAL

            -- T7
            -- DPS
            -- HEAL
        },
        ["DRUID"] = {
            -- T10 
            -- DPS
            -- TANK
            -- HEAL

            -- T9
            -- DPS
            -- TANK
            -- HEAL

            -- T8
            -- DPS
            [64823] = "艾露恩之怒", -- 4T8 Balance
            -- TANK
            -- HEAL

            -- T7
            -- DPS
            -- TANK
            -- HEAL
        },
        ["ROGUE"] = {
            -- T10 
            -- DPS
            [70802] = "恶意伤害", -- 4T10

            -- T9
            -- DPS
            [67210] = "节能", -- 2T9

            -- T8
            -- DPS

            -- T7
            -- DPS
        },
        ["MAGE"] = {
            -- T10 
            -- DPS
            [70747] = "四核强能", -- 4T10

            -- T9
            -- DPS

            -- T8
            -- DPS
            [64868] = "实践", -- 2T8

            -- T7
            -- DPS
            [62215] = "法力涌动", -- 2T7
        },
        ["PRIEST"] = {
            -- T10 
            -- DPS
            -- HEAL

            -- T9
            -- DPS
            -- HEAL

            -- T8
            -- DPS
            [64907] = "狡诈思维", -- 4T8
            -- HEAL
            --[64911] = "戒律之力", -- 4T8

            -- T7
            -- DPS
            -- HEAL
        },
        ["WARLOCK"] = {
            -- T10 
            -- DPS
            [70840] = "邪念", -- 4T10

            -- T9
            -- DPS

            -- T8
            -- DPS

            -- T7
            -- DPS
            [61595] = "恶魔之魂", -- 2T7
            [61082] = "诅咒者的灵魂" -- 4T7
        },
    }

    tierCast = {
        ["PALADIN"] = {
            -- T10 
            -- DPS
            [70769] = "风暴刷新", -- 2T10
        }
    }
else
    print(HEADER_TEXT.."将使用|CFFFF53A2套装编号|R语音 ( |CFFFFFFFF2T9|R ) |R")
end

local ignoreRefreshSpellIds = {
    -- 忽略的刷新技能ID
    [64937] = true, -- 迅疾反射
}

-- 这些技能触发的音效会延迟0.3秒播放 避免与技能重合
local delaySpellIds = {
    [64937] = true, -- 战士 DPS 2T8 迅疾反射
    [70760] = true, -- 圣骑士 TANK 4T10 解脱
    [67117] = true, -- 死亡骑士 DPS 2T9 不洁之能

    [70657] = true, -- 死亡骑士 DPS 4T10 优势
    [70654] = true, -- 死亡骑士 TANK 4T10 血凝成甲

    --Shaman
    -- [70806] = true, -- 萨满 DPS 2T10 激流

    --Druid
    --Rogue
    [70802] = true, -- 盗贼 DPS 4T10 恶意伤害

    --Mage
    [70747] = true, -- 法师 DPS 4T10 四核强能
    [62215] = true, -- 法师 DPS 2T7 法力涌动

    --Priest
    [64907] = true, -- 牧师 DPS 4T8 狡诈思维
    -- [64911] = true, -- 牧师 DPS 4T8 戒律之力

    --Warlock
    [61082] = true, -- 术士 DPS 4T7 诅咒者的灵魂
}

--语音包检测
local CHECK_FILE = SOUND_FILE_PATH..SOUND_FILE_DEFALT_NAME..SOUND_FILE_FORMAT
local SOUND_FILE_MISSING = "无法播放五杀音效 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local REQUIRE_VERSION = requireJTSVersion
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

local class = select(2, UnitClass("player"))
local myTierBuff = tierBuff[class]
local myTierCast = tierCast[class]
local delayTime = 0.3

--播放音频文件
local playJTSorTTS = function(file, ttsText, ttsSpeed)
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

local OnCLEUF = function(...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...

    if (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and myGUID == sourceGUID then
        local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
        if subevent == "SPELL_AURA_REFRESH" and ignoreRefreshSpellIds[spellId] then return end
        if myTierBuff[spellId] then
            local buffName = myTierBuff[spellId]
            local file = SOUND_FILE_PATH..buffName..SOUND_FILE_FORMAT
            local ttsText = buffName
            local ttsSpeed = 1

            local delay = delaySpellIds[spellId] and delayTime or 0
            C_Timer.After(delay, function()
                playJTSorTTS(file, ttsText, ttsSpeed)
            end)
        end
    elseif subevent == "SPELL_CAST_SUCCESS" and myGUID == sourceGUID then
        local spellId, spellName, spellSchool = select(12, ...)
        if not myTierCast then return end
        if myTierCast[spellId] then
            local castName = myTierCast[spellId]
            local file = SOUND_FILE_PATH..castName..SOUND_FILE_FORMAT
            local ttsText = castName
            local ttsSpeed = 1

            local delay = delaySpellIds[spellId] and delayTime or 0
            C_Timer.After(delay, function()
                playJTSorTTS(file, ttsText, ttsSpeed)
            end)
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "JT_D_ITEMSET" then
        ToggleDebug()
    elseif event == "JT_TEST" then
        local spellId = ...
        if myTierBuff[spellId] then
            local buffName = myTierBuff[spellId]
            local file = SOUND_FILE_PATH..buffName..SOUND_FILE_FORMAT
            local ttsText = buffName
            local ttsSpeed = 1
            playJTSorTTS(file, ttsText, ttsSpeed)
        end
    end
end