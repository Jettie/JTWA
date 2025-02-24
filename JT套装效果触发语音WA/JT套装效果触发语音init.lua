--版本信息
local version = 250224
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
        [67151] = "宠物攻强", -- 2T9

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
        -- [70802] = "恶意伤害", -- 4T10

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
        [64911] = "戒律之力", -- 4T8

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
        if myTierBuff[spellId] then
            local buffName = myTierBuff[spellId]
            local file = SOUND_FILE_PATH..buffName..SOUND_FILE_FORMAT
            local ttsText = buffName
            local ttsSpeed = 1
            playJTSorTTS(file, ttsText, ttsSpeed)
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