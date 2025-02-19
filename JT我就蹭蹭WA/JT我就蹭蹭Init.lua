--版本信息 糖水筵席修理虫洞拉人
local version = 250217

local AURA_ICON = 294476
local AURA_NAME = "JT我就蹭蹭WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local INITIALIZED = HEADER_TEXT.."- 虫洞.邮箱.大餐.修理.拉人.糖水 - 作者:|R "..AUTHOR

local faction = UnitFactionGroup("player")
local playerRealmIdString = tostring(GetRealmID())

local raceToFactionGroup = {
    ["Human"] = "Alliance",
    ["Orc"] = "Horde",
    ["Dwarf"] = "Alliance",
    ["NightElf"] = "Alliance",
    ["Scourge"] = "Horde",
    ["Tauren"] = "Horde",
    ["Gnome"] = "Alliance",
    ["Troll"] = "Horde",
    ["BloodElf"] = "Horde",
    ["Draenei"] = "Alliance",
}

--显示内容
aura_env.displayIcon = 132996
aura_env.displayText = "有人放宝贝了"
aura_env.isMacro = true
aura_env.displayClick = "点击找他"

local displayDuration = 13
local macroStr = "/run print(auraIcon..'[|CFF8FFFA2JT我就蹭蹭WA|R]|CFF8FFFA2 - 修改过WA的话，需要/reloadui重新初始化才可以使用点击')"

--ItemData, SPELL_CAST_START/SUCCESS, sourceName施法者, spellName法术名, destName法术目标名字, /tm 6会标记蓝方块
local itemData = {
    [67833] = { --虫洞
        type = "START",
        icon = 135778,
        duration = 10,
        textstr = "spellName 是 sourceName 划破天空开出来的",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [22700] = { --机器人74A
        type = "SUCCESS",
        icon = 132836,
        duration = 10,
        textstr = "上古机器人74A 是 sourceName 的存货",
        ismaccro = true,
        macrostr = "/targetexact 修理机器人74A型\n/f\n/tm 6"
    },
    [44389] = { --机器人110G
        type = "SUCCESS",
        icon = 133859,
        duration = 10,
        textstr = "战地机器人110G 是 sourceName 的存货",
        ismaccro = true,
        macrostr = "/targetexact 战地修理机器人110G\n/f\n/tm 6"
    },
    [54711] = { --废物机器人
        type = "SUCCESS",
        icon = 133872,
        duration = 10,
        textstr = "废物机器人 是 sourceName 放的",
        ismaccro = true,
        macrostr = "/targetexact 废物贩卖机器人\n/f\n/tm 6"
    },
    [67826] = { --基维斯
        type = "SUCCESS",
        icon = 133872,
        duration = 10,
        textstr = "spellName 是 sourceName 放的",
        ismaccro = true,
        macrostr = "/targetexact 基维斯\n/f\n/tm 6"
    },
    [54710] = { --随身邮箱
        type = "SUCCESS",
        icon = 133871,
        duration = 10,
        textstr = "spellName 是 sourceName 放的",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [57301] = { --猪头筵席
        type = "SUCCESS",
        icon = 132184,
        duration = 10,
        textstr = "spellName 是 sourceName 放的",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [57426] = { --鱼肉筵席
        type = "SUCCESS",
        icon = 237303,
        duration = 10,
        textstr = "spellName 是 sourceName 放的",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [58659] = { --召唤餐桌
        type = "SUCCESS",
        icon = 236210,
        duration = 10,
        textstr = "sourceName 正在 spellName",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [58887] = { --灵魂仪式
        type = "SUCCESS",
        icon = 135230,
        duration = 10,
        textstr = "sourceName 正在召唤 spellName",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [698] = { --召唤仪式
        type = "SUCCESS",
        icon = 135230,
        duration = 10,
        textstr = "sourceName 正在开启 spellName 准备拉人",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    },
    [18540] = { --末日仪式
        type = "SUCCESS",
        icon = 135230,
        duration = 10,
        textstr = "sourceName 正在开启 spellName 有胆就点门",
        ismaccro = true,
        macrostr = "/targetexact sourceName\n/f\n/tm 6"
    }
}

--清空btn
local btnName = aura_env.id.."Button"

aura_env.btn = _G[btnName]

--初始化btn
if not aura_env.btn then
    aura_env.btn = CreateFrame("Button", btnName, aura_env.region, "SecureActionButtonTemplate")
    aura_env.btn:SetAllPoints()
    aura_env.btn:SetAttribute("type","macro")
    aura_env.btn:SetAttribute("macrotext", macroStr)
    print(INITIALIZED)
end

--发送TTS播报
local sendTTSMessage = function(text)
    if aura_env.config.isVoice then
        C_VoiceChat.SpeakText(0, text, 0, 2, 100)
    end
end

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unitName, class)
    if not unitName then return "" end
    if class then
        local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
        local coloredName = ("|c%s%s|r"):format(classData.colorStr, unitName)
        return coloredName
    elseif UnitExists(unitName) then
        local name = UnitName(unitName)
        local _, class = UnitClass(unitName)
        if not class then
            return name
        else
            local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unitName
    end
end

local createBar = function(spellId, sourceName, spellName, sourceClass, destName, duration)
    --处理sourceName
    if not sourceName then sourceName = "神仙" end
    if not sourceClass then sourceClass = "PRIEST" end
    local coloredSourceName = classColorName(sourceName, sourceClass) or sourceName
    --取文本
    local displayText = string.gsub(itemData[spellId].textstr, "sourceName", coloredSourceName)
    local macroStr = string.gsub(itemData[spellId].macrostr, "sourceName", sourceName)
    --处理法术名字
    if spellName then
        spellName = WrapTextInColorCode(spellName, "ffff53a2")
        displayText = string.gsub(displayText, "spellName", spellName)
    end
    --处理目标名字
    if destName then
        displayText = string.gsub(displayText, "destName", classColorName(destName, sourceClass))
    end
    --保存图标和文本内容
    aura_env.displayIcon = itemData[spellId].icon or 132996
    aura_env.displayText = displayText or "有人放宝贝了"
    --增加计时
    if not duration then duration = 10 end
    displayDuration = itemData[spellId].duration or duration
    aura_env.region:SetDurationInfo(displayDuration, GetTime() + displayDuration)
    --处理宏内容
    aura_env.isMacro = itemData[spellId].ismaccro or false
    macroStr = macroStr or ""
    aura_env.btn:SetAttribute("macrotext", macroStr)
    --语音通报
    sendTTSMessage(aura_env.displayText)
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp,subevent,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellId,spellName,spellSchool,auraType,amount = ...
        if subevent == "SPELL_CAST_START" then
            if itemData[spellId] then
                if itemData[spellId].type == "START" then
                    local type, realmIdString = strsplit("-",sourceGUID)
                    if type == "Player" and realmIdString == playerRealmIdString then
                        local _, sourceClass, _, sourceRace = GetPlayerInfoByGUID(sourceGUID)
                        if raceToFactionGroup[sourceRace] == faction then
                            local spell, displayName, icon, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(sourceName)
                            local duration = endTime and (( endTime - startTime ) / 1000) or nil
                            createBar(spellId, sourceName, spellName, sourceClass, destName, duration)
                            return true
                        end
                    end
                end
            end
        elseif subevent == "SPELL_CAST_SUCCESS" then
            local type, realmIdString = strsplit("-",sourceGUID)
            if type == "Player" and realmIdString == playerRealmIdString then
                local _, sourceClass, _, sourceRace = GetPlayerInfoByGUID(sourceGUID)
                if raceToFactionGroup[sourceRace] == faction then
                    if itemData[spellId] then
                        if itemData[spellId].type == "SUCCESS" then
                            createBar(spellId, sourceName, spellName, sourceClass, destName)
                            return true
                        end
                    end
                end
            end
        end
    end
end