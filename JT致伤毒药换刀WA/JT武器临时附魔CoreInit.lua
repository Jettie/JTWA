--版本信息
local version = 250312
local requireJTSVersion = 19
local soundPack = "TTS"
local voicePackCheck = true --check过VP就会false

local myGUID = UnitGUID("player")

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

local SOUND_FILE_PATH = "ItemSet\\"
local SOUND_FILE_FORMAT = ".ogg"
local SOUND_FILE_DEFALT_NAME = "优势"

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

local class = select(2, UnitClass("player"))
local level = UnitLevel("player")
local EXPANSION = GetExpansionLevel() -- 游戏版本判断

local MAX_PLAYER_LEVEL = GetMaxLevelForExpansionLevel(EXPANSION)

local FREEZE_TIME = 120 --单位秒
local FREEZE_IN_BAG_TEXT = "超过"..FREEZE_TIME.."秒，请|CFFFF53A2检查背包中的武器|R"..(class == "ROGUE" and "毒药" or "强化")

local LOW_LEVEL_ENCHANT_TEXT = (level == MAX_PLAYER_LEVEL and (class == "ROGUE" and "低级毒" or "低级强化") or "")

local DEFAULT_SOUND_PATH = "Common\\"
local tempEnchantData = {
    ["ROGUE"] = {
        ["减速毒药"] = {
            enchantId = 22,
            shortName = "减速",
            enchantItemId = 3775,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["麻痹毒药"] = {
            enchantId = 35,
            shortName = "麻痹",
            enchantItemId = 5237,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["速效药膏 IX"] = {
            enchantId = 3769,
            shortName = "速效",
            enchantItemId = 43231,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        -- 致命
        ["致命药膏 IX"] = {
            enchantId = 3771,
            shortName = "致命",
            enchantItemId = 43233,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        -- 致伤
        ["致伤药膏 VII"] = {
            enchantId = 3773,
            shortName = "致伤",
            enchantItemId = 43235,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["致伤药膏 VI"] = {
            enchantId = 3772,
            shortName = "致伤",
            enchantItemId = 43234,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 V"] = {
            enchantId = 2644,
            shortName = "致伤",
            enchantItemId = 22055,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 IV"] = {
            enchantId = 706,
            shortName = "致伤",
            enchantItemId = 10922,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 III"] = {
            enchantId = 705,
            shortName = "致伤",
            enchantItemId = 10921,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药 II"] = {
            enchantId = 704,
            shortName = "致伤",
            enchantItemId = 10920,
            duration = 3600,
            modPath = "Rogue\\",
        },
        ["致伤毒药"] = {
            enchantId = 703,
            shortName = "致伤",
            enchantItemId = 10918,
            duration = 3600,
            modPath = "Rogue\\",
        },

        -- 麻醉
        ["麻醉药膏 II"] = {
            enchantId = 3774,
            shortName = "麻醉",
            enchantItemId = 43237,
            duration = 3600,
            topRank = true,
            modPath = "Rogue\\",
        },
        ["麻醉毒药"] = {
            enchantId = 2640,
            shortName = "麻醉",
            enchantItemId = 21835,
            duration = 3600,
            modPath = "Rogue\\",
        },
    },
    ["SHAMAN"] = {
        --测试
        ["火舌 9"] = {
            enchantId = 3780,
            shortName = "火9",
            enchantSpellId = 58789,
            duration = 1800,
            topRank = true,
        },
        ["火舌 10"] = {
            enchantId = 3781,
            shortName = "火10",
            enchantSpellId = 58790,
            duration = 1800,
            topRank = true,
        },
        ["风怒 8"] = {
            enchantId = 3787,
            shortName = "风怒",
            enchantSpellId = 58804,
            duration = 1800,
            topRank = true,
        },
        ["冰封 9"] = {
            enchantId = 3784,
            shortName = "冰封",
            enchantSpellId = 58796,
            duration = 1800,
            topRank = true,
        },
        ["石化 4"] = {
            enchantId = 3032,
            shortName = "石化",
            enchantSpellId = 10399,
            duration = 1800,
            topRank = true,
        },
        ["大地生命 6"] = {
            enchantId = 3350,
            shortName = "大地",
            enchantSpellId = 51994,
            duration = 1800,
            topRank = true,
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
        [LE_ITEM_WEAPON_AXE1H] = true,
        [LE_ITEM_WEAPON_MACE1H] = true,
        [LE_ITEM_WEAPON_UNARMED] = true,
        [LE_ITEM_WEAPON_DAGGER] = true,
    }
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
            enchantName = enchantInfo.shortName,
            enchantIconStr = enchantInfo.enchantItemId and iconStr(GetItemIcon(enchantInfo.enchantItemId)) or (enchantInfo.enchantSpellId and iconStr(GetSpellTexture(enchantInfo.enchantSpellId)) or enchantInfo.shortName),
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

    e[timerName].progressType = "timed"
    e[timerName].offlineFreeze = false

    e[timerName].avoidImmediateUpdate = now
    e[timerName].total = duration

    e[timerName].duration = duration
    e[timerName].expirationTime = expirationTime
    e[timerName].expirationTimeOS = duration + timestamp

    e[timerName].show = true
    e[timerName].changed = true
    saveAllStatesData(e)
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

    local freezeCount = 0
    for timerName, timerData in pairs(e) do
        -- if timerData.isEquipped then
            if not (timerName == mhTimerName or timerName == ohTimerName or timerName == "MHeNONE" or timerName == "OHeNONE" or timerName == "MHeEMPTY" or timerName == "OHeEMPTY") then
                if aura_env.config.itemInBag and timerData.expirationTime and timerData.expirationTime >= now and not (recentlyRemoved[timerName] and recentlyRemoved[timerName].removeTime + 1 >= now) and not (timerData.itemId == mhItemId or timerData.itemId == ohItemId) then
                    if playerLogin and timerData.saveTime and timerData.saveTime + FREEZE_TIME < now then
                        timerData.offlineFreeze = playerLogin
                        freezeCount = freezeCount + 1
                    end
                    timerData.index = 1
                    timerData.isEquipped = false
                    timerData.changed = true
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
    local aboutToExpireSoundFile = isEquipped and soundFile.aboutToExpire or soundFile.aboutToExpireInBag
    local aboutToExpireTTSText = isEquipped and soundTTSText.aboutToExpire or soundTTSText.aboutToExpireInBag
    playJTSorTTS(aboutToExpireSoundFile, aboutToExpireTTSText, ttsSpeed)
end
aura_env.OnAboutToExpire = aboutToExpire

-- 毒药已经到期时播放提示音
local expired = function(isEquipped)
    local expiredSoundFile = isEquipped and soundFile.expired or soundFile.expiredInBag
    local expiredTTSText = isEquipped and soundTTSText.expired or soundTTSText.expiredInBag
    playJTSorTTS(expiredSoundFile, expiredTTSText, ttsSpeed)
end
aura_env.OnExpired = expired

aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(e, CombatLogGetCurrentEventInfo())
    elseif event == "OPTIONS" then
        loadAllStatesData(e)
        return UpdateWeaponEnchant(e, true)
    elseif event == "OPTIONS_CLOSE" or event == "STATUS" then
        loadAllStatesData(e)
        return UpdateWeaponEnchant(e, true)
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
    -- elseif event == "PLAYER_LOGOUT" then
    --     saveAllStatesData(e)
    end
end