--版本信息
local version = 250320
local requireJTSVersion = 22
local soundPack = "TTS"
local voicePackCheck = true --check过VP就会false

local myGUID = UnitGUID("player")
local class = select(2, UnitClass("player"))
local level = UnitLevel("player")
local EXPANSION = GetExpansionLevel() -- 游戏版本判断

local MAX_PLAYER_LEVEL = GetMaxLevelForExpansionLevel(EXPANSION)
local LOW_LEVEL_ENCHANT_TEXT = (level == MAX_PLAYER_LEVEL and (class == "ROGUE" and "低级毒" or "低级强化") or "")

--author and header
local AURA_ICON = 135743
local AURA_NAME = "JT武器附魔WA"
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

local SOUND_FILE_PATH = class == "ROGUE" and "Rogue\\" or "Common\\"
local SOUND_FILE_FORMAT = ".ogg"
local SOUND_FILE_DEFALT_NAME = "武器强化即将到期"

--语音包检测
local CHECK_FILE = SOUND_FILE_PATH..SOUND_FILE_DEFALT_NAME..SOUND_FILE_FORMAT
local SOUND_FILE_MISSING = "无法播放毒药提醒音效 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local REQUIRE_VERSION = requireJTSVersion
local checkVoicePack = function()
    if voicePackCheck then
        local auraIcon = AURA_ICON or 135451
        local auraName = AURA_NAME or "JT系列WA"
        local author = AUTHOR or "Jettie@SMTH"
        local smallIcon = "|T"..(auraIcon or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
        local headerText = smallIcon.."[|CFF8FFFA2"..auraName.."|R]|CFF8FFFA2 毒药/武器强化 "

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

local iconStr = function(iconId)
    if iconId and type(iconId) == "number" then
        return "|T"..iconId..":12:12:0:0:64:64:4:60:4:60|t"
    else
        return ""
    end
end

local saveAllStatesData = function(allStates)
    aura_env.saved = aura_env.saved or {}
    aura_env.saved[WeakAuras.me] = {}
    local db = aura_env.saved[WeakAuras.me]
    db.e = {}

    local now = GetTime()
    local timestamp = time()

    for stateName, stateData in pairs(allStates) do
        db.e[stateName] = stateData

        db.e[stateName].saveTime = now
        db.e[stateName].saveTimeOS = timestamp
        -- db.e[stateName].expirationTimeOS = db.e[stateName].expirationTime - now + timestamp
        db.e[stateName].beforeShow = stateData.show
        db.e[stateName].beforeChanged = stateData.changed
    end
end

local optionsOpen = function ()
    if WeakAuras.IsOptionsOpen() then
        aura_env.saved = aura_env.saved or {}
        aura_env.saved.initialized = aura_env.saved.initialized
    end
end

local firstLoad = true --第一次加载才会修正,认为是第一次登录,后续不用修正
local loadAllStatesData = function(allStates)

    aura_env.saved = aura_env.saved or {}
    local db = aura_env.saved[WeakAuras.me]
    if not db or not db.e then
        firstLoad = false --没数据也算是修正过了
        return
    end

    local now = GetTime()
    local timestamp = time()
    for stateName, stateData in pairs(db.e) do
        allStates[stateName] = stateData

        if firstLoad then
            if stateData.expirationTimeOS then
                allStates[stateName].expirationTime = stateData.expirationTimeOS and (stateData.expirationTimeOS + now - timestamp) or allStates[stateName].expirationTime
            end
            if stateData.saveTimeOS then
                allStates[stateName].saveTime = stateData.saveTimeOS and (stateData.saveTimeOS + now - timestamp) or allStates[stateName].saveTime
            end
        end
        allStates[stateName].show = stateData.beforeShow
        allStates[stateName].changed = stateData.beforeChanged
    end
    firstLoad = false
    return true
end

local FREEZE_TIME = 120 --单位秒
local FREEZE_IN_BAG_TEXT = "超过"..FREEZE_TIME.."秒，请|CFFFF53A2检查背包中的武器|R"..(class == "ROGUE" and "毒药" or "强化")

local DEFAULT_SOUND_PATH = "Common\\"
local tempEnchantData = {
    ["ROGUE"] = {
        ["减速毒药"] = {
            enchantId = 22,
            enchantItemId = 3775,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["麻痹毒药"] = {
            enchantId = 35,
            enchantItemId = 5237,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["速效药膏 IX"] = {
            enchantId = 3769,
            enchantItemId = 43231,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["速效药膏 VIII"] = {
            enchantId = 3768,
            enchantItemId = 43230,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药 VII"] = {
            enchantId = 2641,
            enchantItemId = 21927,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药 VI"] = {
            enchantId = 625,
            enchantItemId = 8928,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药 V"] = {
            enchantId = 624,
            enchantItemId = 8927,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药 IV"] = {
            enchantId = 623,
            enchantItemId = 8926,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药 III"] = {
            enchantId = 325,
            enchantItemId = 6950,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药 II"] = {
            enchantId = 324,
            enchantItemId = 6949,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["速效毒药"] = {
            enchantId = 323,
            enchantItemId = 6947,
            duration = 3600,
            modPath = "Rogue\\",
        },

        -- 致命
        ["致命药膏 IX"] = {
            enchantId = 3771,
            enchantItemId = 43233,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["致命药膏 VIII"] = {
            enchantId = 3770,
            enchantItemId = 43232,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药 VII"] = {
            enchantId = 2643,
            enchantItemId = 22054,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药 VI"] = {
            enchantId = 2642,
            enchantItemId = 22053,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药 V"] = {
            enchantId = 2630,
            enchantItemId = 20844,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药 IV"] = {
            enchantId = 627,
            enchantItemId = 8985,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药 III"] = {
            enchantId = 626,
            enchantItemId = 8984,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药 II"] = {
            enchantId = 8,
            enchantItemId = 2893,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致命毒药"] = {
            enchantId = 7,
            enchantItemId = 2892,
            duration = 3600,
            modPath = "Rogue\\",
        },

        -- 致伤
        ["致伤药膏 VII"] = {
            enchantId = 3773,
            enchantItemId = 43235,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["致伤药膏 VI"] = {
            enchantId = 3772,
            enchantItemId = 43234,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 V"] = {
            enchantId = 2644,
            enchantItemId = 22055,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 IV"] = {
            enchantId = 706,
            enchantItemId = 10922,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 III"] = {
            enchantId = 705,
            enchantItemId = 10921,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 II"] = {
            enchantId = 704,
            enchantItemId = 10920,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药"] = {
            enchantId = 703,
            enchantItemId = 10918,
            duration = 3600,
            modPath = "Rogue\\",
        },

        -- 麻醉
        ["麻醉药膏 II"] = {
            enchantId = 3774,
            enchantItemId = 43237,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["麻醉毒药"] = {
            enchantId = 2640,
            enchantItemId = 21835,
            duration = 3600,
            modPath = "Rogue\\",
        },
    },
    ["SHAMAN"] = {
        -- 火舌
        ["火舌 10"] = {
            enchantId = 3781,
            enchantSpellId = 58790,
            duration = 1800,
            topRank = true,
        },
        ["火舌 9"] = {
            enchantId = 3780,
            enchantSpellId = 58789,
            duration = 1800,
            topRank = true,
        },
        ["风怒 8"] = {
            enchantId = 3787,
            enchantSpellId = 58804,
            duration = 1800,
            topRank = true,
        },
        ["冰封 9"] = {
            enchantId = 3784,
            enchantSpellId = 58796,
            duration = 1800,
            topRank = true,
        },
        ["石化 4"] = {
            enchantId = 3032,
            enchantSpellId = 10399,
            duration = 1800,
            topRank = true,
        },
        ["大地生命 6"] = {
            enchantId = 3350,
            enchantSpellId = 51994,
            duration = 1800,
            topRank = true,
        },
    },
    ["WARLOCK"] = {
        -- 法术石
        ["完美法术石"] = {
            enchantId = 3620,
            enchantItemId = 41196,
            duration = 3600,
            topRank = true,
        },
        ["恶魔法术石"] = {
            enchantId = 3619,
            enchantItemId = 41195,
            duration = 3600,
        },
        ["特效法术石"] = {
            enchantId = 3618,
            enchantItemId = 41194,
            duration = 3600,
        },
        ["极效法术石"] = {
            enchantId = 3617,
            enchantItemId = 41193,
            duration = 3600,
        },
        ["强效法术石"] = {
            enchantId = 3616,
            enchantItemId = 41192,
            duration = 3600,
        },
        ["法术石"] = {
            enchantId = 3615,
            enchantItemId = 41191,
            duration = 3600,
        },
        -- 火焰石
        ["完美火焰石"] = {
            enchantId = 3614,
            enchantItemId = 41174,
            duration = 3600,
            topRank = true,
        },
        ["邪能火焰石"] = {
            enchantId = 3613,
            enchantItemId = 41173,
            duration = 3600,
        },
        ["特效火焰石"] = {
            enchantId = 3597,
            enchantItemId = 40773,
            duration = 3600,
        },
        ["极效火焰石"] = {
            enchantId = 3612,
            enchantItemId = 41172,
            duration = 3600,
        },
        ["强效火焰石"] = {
            enchantId = 3611,
            enchantItemId = 41171,
            duration = 3600,
        },
        ["火焰石"] = {
            enchantId = 3610,
            enchantItemId = 41169,
            duration = 3600,
        },
        ["次级火焰石"] = {
            enchantId = 3609,
            enchantItemId = 41170,
            duration = 3600,
        },
    },
}

local thisTempEnchantData = tempEnchantData[class] or {}

local enchantIdToName = {}

local buildEnchantIdToName = function()
    for enchantName, enchantData in pairs(thisTempEnchantData) do
        enchantIdToName[enchantData.enchantId] = enchantName
    end
end
buildEnchantIdToName()

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

local canDualWield = false
local dualWeaponType = {}
if class == "ROGUE" then
    canDualWield = true
    dualWeaponType = {
        [LE_ITEM_WEAPON_AXE1H] = true,
        [LE_ITEM_WEAPON_MACE1H] = true,
        [LE_ITEM_WEAPON_SWORD1H] = true,
        [LE_ITEM_WEAPON_UNARMED] = true,
        [LE_ITEM_WEAPON_DAGGER] = true,
    }
elseif class == "DEATHKNIGHT" then
    canDualWield = true
    dualWeaponType = {
        [LE_ITEM_WEAPON_AXE1H] = true,
        [LE_ITEM_WEAPON_MACE1H] = true,
        [LE_ITEM_WEAPON_SWORD1H] = true,
    }
elseif class == "WARRIOR" and select(5, GetTalentInfo(2, 24)) == 1 then
    canDualWield = true
    dualWeaponType = {
        [LE_ITEM_WEAPON_AXE1H] = true,
        [LE_ITEM_WEAPON_MACE1H] = true,
        [LE_ITEM_WEAPON_SWORD1H] = true,
        [LE_ITEM_WEAPON_UNARMED] = true,
        [LE_ITEM_WEAPON_DAGGER] = true,
        --双手
        [LE_ITEM_WEAPON_AXE2H] = true,
        [LE_ITEM_WEAPON_MACE2H] = true,
        [LE_ITEM_WEAPON_POLEARM] = true,
        [LE_ITEM_WEAPON_SWORD2H] = true,
        [LE_ITEM_WEAPON_STAFF] = true,
    }
elseif class == "SHAMAN" and select(5,GetTalentInfo(2, 17)) == 1 then
    canDualWield = true
    dualWeaponType = {
        [LE_ITEM_WEAPON_DAGGER] = true,
        [LE_ITEM_WEAPON_AXE1H] = true,
        [LE_ITEM_WEAPON_MACE1H] = true,
        [LE_ITEM_WEAPON_UNARMED] = true,
    }
end

local tickerSpeed = 1
local weaponEnchantTicker

local tickerStart = function()
    if WeakAuras.IsOptionsOpen() then return end
    if not weaponEnchantTicker or weaponEnchantTicker:IsCancelled() then
        weaponEnchantTicker = C_Timer.NewTicker(tickerSpeed, function()
            WeakAuras.ScanEvents("JT_WEAPON_ENCHANT_TICK")
        end)
    end
end

local tickerStop = function()
    if weaponEnchantTicker and not weaponEnchantTicker:IsCancelled() then
        weaponEnchantTicker:Cancel()
    end
end

local OnTicker = function(e, ...)
    local cancelTicking = true
    local now = GetTime()
    for timerName, timerData in pairs(e) do
        if timerName and not (timerName == "MHeNONE" or timerName == "OHeNONE" or timerName == "MHeEMPTY" or timerName == "OHeEMPTY") then
            cancelTicking = false
        end
        if timerData and timerData.expirationTime then
            timerData.value = timerData.expirationTime - now
            timerData.changed = true
        end
    end
    if cancelTicking then
        tickerStop()
    end
    return true
end

local createTimer = function(e, spellName, itemId, itemName, expirationInMS)
    local enchantInfo = thisTempEnchantData[spellName]
    if not enchantInfo then
        return false
    end
    local timerName = "i"..itemId.."e"..enchantInfo.enchantId
    if not e[timerName] then
        e[timerName] = {
            name = timerName,
            itemId = itemId,
            icon = GetItemIcon(itemId),
            enchantId = enchantInfo.enchantId,
            enchantName = enchantInfo.enchantItemId and (GetItemInfo(enchantInfo.enchantItemId)) or (enchantInfo.enchantSpellId and GetSpellInfo(enchantInfo.enchantSpellId) or (spellName)),
            enchantIconStr = enchantInfo.enchantItemId and iconStr(GetItemIcon(enchantInfo.enchantItemId)) or (enchantInfo.enchantSpellId and iconStr(GetSpellTexture(enchantInfo.enchantSpellId)) or (spellName)),
            soundPath = enchantInfo.modPath or DEFAULT_SOUND_PATH,
            topRank = enchantInfo.topRank or false,
            notTopRankText = LOW_LEVEL_ENCHANT_TEXT,
            autoHide = true,
        }
    end
    local now = GetTime()
    local timestamp = time()
    local duration = expirationInMS and math.floor(expirationInMS / 1000) or thisTempEnchantData[spellName].duration
    local expirationTime = now + duration

    e[timerName].progressType = "static"
    e[timerName].offlineFreeze = false

    e[timerName].avoidImmediateUpdate = now
    e[timerName].value = duration
    e[timerName].total = duration

    -- e[timerName].index = 1

    e[timerName].duration = duration
    e[timerName].expirationTime = expirationTime
    e[timerName].expirationTimeOS = duration + timestamp

    e[timerName].show = true
    e[timerName].changed = true
    saveAllStatesData(e)
    tickerStart()
    return true
end

local recentlyRemoved = {}

local removeTimer = function(e, spellName, itemId, itemName)
    local enchantInfo = thisTempEnchantData[spellName]
    local timerName = "i"..itemId.."e"..enchantInfo.enchantId
    if e[timerName] then
        e[timerName].show = false
        e[timerName].changed = true

        recentlyRemoved[timerName] = e[timerName]
        recentlyRemoved[timerName].removeTime = GetTime()

        saveAllStatesData(e)
        return true
    end
end

local createNoEnchantTimer = function(e, mhItemId, ohItemId, isOffhand)
    --本职业没有附魔的情况会直接不显示
    if not next(thisTempEnchantData) then
        return
    end
    --处理没附魔的情况
    local thisItemId = mhItemId
    if isOffhand then
        thisItemId = ohItemId
    end

    local hasEnchantName = thisItemId and "eNONE" or "eEMPTY"
    local slotName = (isOffhand and "OH" or "MH")..hasEnchantName
    local icon = thisItemId and GetItemIcon(thisItemId) or (isOffhand and 136524 or 136518)

    -- 如果是副手，判断是否能双持
    if isOffhand then
        if not (canDualWield and (not mhItemId or (mhItemId and dualWeaponType[select(13, GetItemInfo(mhItemId))])) and (not ohItemId or ohItemId and select(12, GetItemInfo(ohItemId)) == LE_ITEM_CLASS_WEAPON)) then
            return
        end
    end

    if not e[slotName] then
        e[slotName] = {
            progressType = "static",
            total = 0,
            value = 1,
            enchantIconStr = "无",
            autoHide = true,
        }
    end

    e[slotName].name = slotName
    e[slotName].itemId = thisItemId
    e[slotName].icon = icon

    e[slotName].index = isOffhand and 2 or 3
    e[slotName].isEquipped = true
    e[slotName].offlineFreeze = false

    e[slotName].show = true
    e[slotName].changed = true
end

local OnCLEUF = function(e, ...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...

    if subevent == "ENCHANT_APPLIED" and (myGUID == sourceGUID or myGUID == destGUID) then
        -- 毒药buff名 物品ID 物品名称
        local spellName, itemId, itemName = select(12, ...)
        if thisTempEnchantData and thisTempEnchantData[spellName] then
            return createTimer(e, spellName, itemId, itemName)
        end
    elseif subevent == "ENCHANT_REMOVED" and (myGUID == sourceGUID or myGUID == destGUID) then
        -- 毒药buff名 物品ID 物品名称
        local spellName, itemId, itemName = select(12, ...)
        if thisTempEnchantData and thisTempEnchantData[spellName] then
            return removeTimer(e, spellName, itemId, itemName)
        end
    end
end

-- 每次登录第一次不要刷新时间，因为刚刚登录的时候GetWeaponEnchantInfo()会返回0，导致刷新时间为0
local skipFirstUpdate = true
-- 换地图的时候会有多次背包更新，这里避免频繁刷新
local avoidFrequentlyUpdate = {
    mh = 0,
    oh = 0,
}
local UpdateWeaponEnchant = function(e, ...)

    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID, hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID = GetWeaponEnchantInfo()

    local mhItemId = GetInventoryItemID("player", INVSLOT_MAINHAND)
    local ohItemId = GetInventoryItemID("player", INVSLOT_OFFHAND)

    if not mhItemId or not hasMainHandEnchant then
        createNoEnchantTimer(e, mhItemId, ohItemId, false)
    end

    if not ohItemId or not hasOffHandEnchant then
        createNoEnchantTimer(e, mhItemId, ohItemId, true)
    end

    local mhTimerName = (mhItemId and hasMainHandEnchant) and "i"..mhItemId.."e"..mainHandEnchantID or nil
    local ohTimerName = (ohItemId and hasOffHandEnchant) and "i"..ohItemId.."e"..offHandEnchantID or nil

    local playerLogin = ...
    local now = GetTime()
    if mhTimerName then
        if not e[mhTimerName] then
            if createTimer(e, enchantIdToName[mainHandEnchantID], mhItemId, GetItemInfo(mhItemId), mainHandExpiration) then
                e[mhTimerName].isEquipped = true

                e[mhTimerName].index = 3
                e[mhTimerName].isOffhand = false
                e[mhTimerName].changed = true
            end
        else
            -- 刷新为准确时间, 因为数据延迟，所以加1秒避免刷新为错误数据
            if not skipFirstUpdate and e[mhTimerName].avoidImmediateUpdate + 1 < now and avoidFrequentlyUpdate.mh + 0.1 < now then
                local duration = mainHandExpiration and math.floor(mainHandExpiration / 1000)
                e[mhTimerName].duration = duration
                e[mhTimerName].expirationTime = now + duration
                avoidFrequentlyUpdate.mh = now
            end
            e[mhTimerName].isEquipped = true
            e[mhTimerName].offlineFreeze = false

            e[mhTimerName].index = 3
            e[mhTimerName].isOffhand = false
            e[mhTimerName].changed = true
        end
    end
    if ohTimerName then
        if not e[ohTimerName] then
            if createTimer(e, enchantIdToName[offHandEnchantID], ohItemId, GetItemInfo(ohItemId), offHandExpiration) then
                e[ohTimerName].isEquipped = true

                e[ohTimerName].index = 2
                e[ohTimerName].isOffhand = true
                e[ohTimerName].changed = true
            end
        else
            -- 刷新为准确时间, 因为数据延迟，所以加1秒避免刷新为错误数据
            if not skipFirstUpdate and e[ohTimerName].avoidImmediateUpdate + 1 < now and avoidFrequentlyUpdate.oh + 0.1 < now then
                local duration = offHandExpiration and math.floor(offHandExpiration / 1000)
                e[ohTimerName].duration = duration
                e[ohTimerName].expirationTime = now + duration
                avoidFrequentlyUpdate.oh = now
            end
            e[ohTimerName].isEquipped = true
            e[ohTimerName].offlineFreeze = false

            e[ohTimerName].index = 2
            e[ohTimerName].isOffhand = true
            e[ohTimerName].changed = true
        end
    end

    skipFirstUpdate = false -- 第一次刷新跳过

    local hasEnchant = hasMainHandEnchant or hasOffHandEnchant
    local freezeCount = 0

    for timerName, timerData in pairs(e) do
        -- if timerData.isEquipped then
        if not (timerName == mhTimerName or timerName == ohTimerName or timerName == "MHeNONE" or timerName == "OHeNONE" or timerName == "MHeEMPTY" or timerName == "OHeEMPTY") then
            if aura_env.config.itemInBag and timerData.expirationTime and timerData.expirationTime >= now and not (recentlyRemoved[timerName] and recentlyRemoved[timerName].removeTime + 1 >= now) then
                if playerLogin and timerData.saveTime and timerData.saveTime + FREEZE_TIME < now then
                    timerData.offlineFreeze = playerLogin
                    freezeCount = freezeCount + 1
                end
                timerData.index = 1
                timerData.isEquipped = false
                timerData.changed = true

                hasEnchant = true
            else
                timerData.show = false
                timerData.changed = true
            end
        end
        -- end

        --移除所有非穿戴的空和无附魔的
        if ((hasMainHandEnchant or not mhItemId) and timerName == "MHeNONE") or ((hasOffHandEnchant or not ohItemId) and timerName == "OHeNONE") or (mhItemId and timerName == "MHeEMPTY") or (ohItemId and timerName == "OHeEMPTY") then
            timerData.show = false
            timerData.changed = true
        end
    end
    if freezeCount > 0 then
        print(HEADER_TEXT..FREEZE_IN_BAG_TEXT.."!("..freezeCount..")(穿戴一下刷新时间)")
    end
    if hasEnchant then
        tickerStart()
    end
    saveAllStatesData(e)
    return true
end

local OnGetWeaponEnchant = function(e, ...)
    local sendEventName = ...
    if e then
        WeakAuras.ScanEvents(sendEventName, e)
    end
end

local soundFile = {
    aboutToExpire = "武器强化即将到期",
    expired = "武器强化到期了",
    aboutToExpireInBag = "背包武器强化即将到期",
    expiredInBag = "背包武器强化到期了",
}
local soundTTSText = {
    aboutToExpire = "武器强化快要到期了",
    expired = "武器强化到期了",
    aboutToExpireInBag = "背包中的武器强化即将到期",
    expiredInBag = "背包中的武器强化到期了",
}
local ttsSpeed = 1
if class == "ROGUE" then
    soundTTSText = {
        aboutToExpire = "毒药快要到期了",
        expired = "毒药已经到期了",
        aboutToExpireInBag = "背包中的武器毒药即将到期",
        expiredInBag = "背包中的武器毒药到期了",
    }
end

-- 毒药即将到期时播放提示音
local aboutToExpire = function(isEquipped)
    if not aura_env.config.enableAboutToExpire then return end
    local aboutToExpireSoundFileName = isEquipped and soundFile.aboutToExpire or soundFile.aboutToExpireInBag
    local aboutToExpireSoundFile = SOUND_FILE_PATH..aboutToExpireSoundFileName..SOUND_FILE_FORMAT
    local aboutToExpireTTSText = isEquipped and soundTTSText.aboutToExpire or soundTTSText.aboutToExpireInBag
    playJTSorTTS(aboutToExpireSoundFile, aboutToExpireTTSText, ttsSpeed)
end
aura_env.OnAboutToExpire = aboutToExpire

-- 毒药已经到期时播放提示音
local expired = function(isEquipped)
    if not aura_env.config.enableExpire then return end
    local expiredSoundFileName = isEquipped and soundFile.expired or soundFile.expiredInBag
    local expiredSoundFile = SOUND_FILE_PATH..expiredSoundFileName..SOUND_FILE_FORMAT
    local expiredTTSText = isEquipped and soundTTSText.expired or soundTTSText.expiredInBag
    playJTSorTTS(expiredSoundFile, expiredTTSText, ttsSpeed)
end
aura_env.OnExpired = expired

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, CombatLogGetCurrentEventInfo())
    elseif event == "OPTIONS" then
        tickerStop()
        loadAllStatesData(e)
        return UpdateWeaponEnchant(e, true)
    elseif event == "OPTIONS_CLOSE" or event == "STATUS" then
        loadAllStatesData(e)
        return UpdateWeaponEnchant(e, true)
    elseif event == "JT_WEAPON_ENCHANT_TICK" then
        return OnTicker(e, ...)
    elseif event == "JT_LOGIN_INIT" then
        -- loadAllStatesData(e)
        -- 延迟1秒触发，防止数据延迟导致刷新错误，并刷新未暂停导致的过期数据 因为第一次武器附魔数据获取不到
        return UpdateWeaponEnchant(e, true)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- 延迟1秒触发，防止数据延迟导致刷新错误，并刷新未暂停导致的过期数据
        C_Timer.After(1, function()
                WeakAuras.ScanEvents("JT_LOGIN_INIT")
        end)
    elseif event == "JT_D_WEAPON_ENCHANT" then
        ToggleDebug()
    elseif event == "JT_GET_WEAPON_ENCHANT" then
        OnGetWeaponEnchant(e, ...)
    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" then
            return UpdateWeaponEnchant(e)
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local equipmentSlot, hasCurrent = ...
        if (equipmentSlot == INVSLOT_MAINHAND or equipmentSlot == INVSLOT_OFFHAND) then
            return UpdateWeaponEnchant(e)
        end
    end
end
