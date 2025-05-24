--版本信息
local version = 250511

aura_env.displayText = ""

local CANCEL_TEXT = "|cff8FFFA2%s 的增伤提前 |Cffff53a2%s|r 秒结束了|r"
local DEATH_TEXT = "|cffff53a2%s 牺牲了 上一次嫁祸转移了 %s 秒仇恨|r"

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unit)
    if unit and UnitExists(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if not class then
            return name
        else
            local classData = (RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unit
    end
end

local playCancelSound = function(sourceName, ttsSpeed)
    --sourceName = "西门吹雪大侠"
    local nameLength = strlen(sourceName)
    local timePerLetter = 0.06
    local timeStatic = 0.15
    local ttsSpeakTime = nameLength * timePerLetter + timeStatic
    
    local cancelDamageBuffSoundFile = "Rogue\\嫁祸增伤提前结束.ogg"
    local cancelDamageBuffTTSText = " 的嫁祸增伤提前结束了"
    
    -- 先播名字
    
    C_VoiceChat.SpeakText(0, sourceName, 0, (ttsSpeed or 0), 100)
    
    -- 再播提示音
    C_Timer.After(ttsSpeakTime, function()
            local canplay = JTS.P(cancelDamageBuffSoundFile)
            if not canplay then
                C_VoiceChat.SpeakText(0, cancelDamageBuffTTSText, 0, (ttsSpeed or 0), 100)
            end
    end)
end


aura_env.OnTrigger = function(event, ...)
    if event == "JT_TOT_DAMAGE_CANCELLED" then
        local destGUID, wasteTime, enableText, enableSound = ...
        local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(destGUID)
        local broName = Ambiguate(name, "all") or "好兄弟"
        local coloredBroName = classColorName(broName)
        local cancelText = CANCEL_TEXT:format(coloredBroName, wasteTime)
        aura_env.displayText = cancelText
        if enableSound then
            playCancelSound(broName, 1)
        end
        return enableText
    elseif event == "JT_TOT_CAUSE_DEATH" then
        local destGUID, threatBuffLasted, enableText = ...
        local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(destGUID)
        local broName = Ambiguate(name, "all") or "好兄弟"
        local coloredBroName = classColorName(broName)
        local deathText = DEATH_TEXT:format(coloredBroName, threatBuffLasted)
        aura_env.displayText = deathText
        return enableText
    end
end

