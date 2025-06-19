--版本信息
local version = 250619

--文字显示
aura_env.attacking = "OK"

local EXPANSION = GetExpansionLevel() -- 游戏版本判断

--近战职业判断
--check melee talent for isMelee
local _, class = UnitClass("player")
local CheckMeleeTalent = function()
    if class == "ROGUE" or class == "WARRIOR" or class == "DEATHKNIGHT" then
        return true
    elseif class == "SHAMAN" then
        --风暴打击 /dump GetTalentInfo(2, 13)
        return select(5,GetTalentInfo(2, 13)) > 0 and true or false
    elseif class == "PALADIN" then
        --神圣风暴 /dump GetTalentInfo(3, 24)
        return select(5,GetTalentInfo(3, 24)) > 0 and true or false
    elseif class == "DRUID" then
        --裂伤 /dump GetTalentInfo(2, 20)
        return select(5,GetTalentInfo(2, 20)) > 0 and true or false
    end
end

local isMelee = CheckMeleeTalent()

local isTankingMute = function()
    if class == "DRUID" then
        if GetShapeshiftFormID() == 8 then
            return true
        else
            return false
        end
    elseif class == "DEATHKNIGHT" then
        if WA_GetUnitBuff("player",48263) then
            return true
        else
            return false
        end
    elseif class == "PALADIN" then
        -- /dump GetTalentInfo(2, 7)
        if select(5,GetTalentInfo(2, 7)) > 0 then
            return true
        else
            return false
        end
    elseif class == "WARRIOR" then
        local offHandItemId = GetInventoryItemID("player", 17)
        if offHandItemId then
            if select(9,GetItemInfo(offHandItemId)) == "INVTYPE_SHIELD" then
                return true
            end
        end
        return false
    end
    return false
end

local RecheckTalent = function()
    isMelee = CheckMeleeTalent()
end

--摸到怪相关，新战斗，换目标，都会重置
local inRangeAndAttacking = false
local startAttackInThisCombat = 0
local alertAfterStart = 5 --摸到怪5秒后才开始提醒
local alertAfterChangeTarget = 2 --换目标之后，重新开始提醒，需要多久

--打不到相关
local oorTime = 0
local minOORAlertTime = 1

--没在打相关
local autoAttacking = false
local notAutoAttackStartTime = 0
local minBetweenAutoAttack = 2 --2秒内不会提醒，并且也不会中断打不到的累计时间。超出2秒就中断打不到。
local alertNotAutoAttackingTime = 4 --没在打4秒以上，就提醒没在打了。

--太近了相关
local tooClose = false
local tooCloseStartTime = 0
local alertTooCloseTime = 2 --没在打3秒以上，就提醒没在打了。

--muteBoss判断
local isEncounter = false --需要触发器判断是否boss战
local curEncounterID = 0

--TTS播报文字
local oorTTSText = "打不到"
local noAATTSText = "没在打"
local tooCloseTTSText = "太近了"

--需要触发器，初始化开战是5秒，后续重置后就是2秒或者3秒了。开战强制改5秒。

--打不到语音文件，4随1
local oorSoundList = {
    [1] = "Common\\打不到.ogg",
    [2] = "Common\\太远了.ogg",
    [3] = "Common\\靠近目标.ogg",
    [4] = "Common\\我离目标太远了.ogg"
}
local randomOORSound = function()
    if aura_env.config.randomOOR then
        return oorSoundList[math.random(#oorSoundList)]
    else
        return oorSoundList[1]
    end
end

--没在打语音文件，4随1
local noAASoundList = {
    [1] = "Common\\没在打.ogg",
    [2] = "Common\\发呆了.ogg",
    [3] = "Common\\快进攻.ogg"
}
local randomNoAASound = function()
    if aura_env.config.randomNoAA then
        return noAASoundList[math.random(#noAASoundList)]
    else
        return noAASoundList[1]
    end
end

local tooCloseSoundFile = "Common\\太近了.ogg"

--静音BOSS战EncounterID
local muteBoss = {
    --黑干
    [1112] = true,
    --洛欧塞布
    [1115] = true

}
local isMuteBoss = function()
    if muteBoss[curEncounterID] then
        return true
    end
    return false
end

--只提醒BOSS战
local alertCheck = function()
    if not aura_env.config.onlyBoss then
        return true
    else
        if isEncounter then
            return true
        end
    end
    return false
end

--距离太近提醒的Boss
local validBosses = {
    --训练假人
    --[31146] = true, -- 英雄训练假人
    [31144] = true, --宗师的训练假人

    --托里姆
    [32865] = true,

    --冰吼
    [34797] = true,

}
local isValidBoss = function(targetGUID)
    local type, _, _, _, _, targetID = strsplit("-", targetGUID)
    local id = tonumber(targetID)
    if type == "Creature" and validBosses[id] then
        return true
    end
    return false
end

--重新初始化时间
local initTimer = function()
    inRangeAndAttacking = false
    startAttackInThisCombat = 0
    autoAttacking = true
    notAutoAttackStartTime = 0
    oorTime = 0
    tooClose = false
    tooCloseStartTime = 0
end

--播放音频文件
local PlayJTSorTTS = function(file, ttsText, ttsSpeed)
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

aura_env.OnTrigger = function(event, ...)
    if event == 'PLAYER_REGEN_DISABLED' then
        initTimer()
        local speed = 0.05
        aura_env.ticker = C_Timer.NewTicker(speed, function() WeakAuras.ScanEvents("JT_RANGE_CHECK") end)
        RecheckTalent()
        return true
    elseif event == 'PLAYER_REGEN_ENABLED' then
        if aura_env.ticker and not aura_env.ticker:IsCancelled() then
            aura_env.ticker:Cancel()
        end
        aura_env.attacking = "OK"
        return true
    elseif event == 'ENCOUNTER_START' then
        local encounterID = ...
        if encounterID then
            curEncounterID = encounterID
            isEncounter = true
        end
        if isMuteBoss() then
            print("|T237554:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT找背WA|R]|CFF8FFFA2 这个BOSS屏蔽妹打和打不到语音")
        end
    elseif event == 'ENCOUNTER_END' then
        curEncounterID = 0
        isEncounter = false
    elseif event == 'PLAYER_TALENT_UPDATE' then
        RecheckTalent()
    elseif event == 'PLAYER_TARGET_CHANGED' then
        initTimer()
        startAttackInThisCombat = GetTime() - alertAfterStart + alertAfterChangeTarget

        --判断 是否近战 玩家战斗中 目标存在 目标没死 目标不是友方 目标可以攻击
    elseif event == "JT_RANGE_CHECK" then
        if isMelee and UnitAffectingCombat("player") and UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend("player","target") and UnitCanAttack("player","target") then
            if isValidBoss(UnitGUID("target")) and EXPANSION == 2 and IsItemInRange(35789, "target") and not isTankingMute() then
                --在近战范围，并且开始自动攻击时
                if not inRangeAndAttacking then
                    inRangeAndAttacking = true
                end
                if startAttackInThisCombat == 0 then
                    startAttackInThisCombat = GetTime()
                end
                autoAttacking = true
                oorTime = 0
                aura_env.attacking = "太近了"

                if not tooClose then
                    tooClose = true
                    tooCloseStartTime = GetTime()
                else
                    local now = GetTime()
                    local timeDiffTooClose = now - tooCloseStartTime

                    if timeDiffTooClose >= alertTooCloseTime and alertCheck() then
                        if aura_env.config.isVoice and not isMuteBoss() then

                            local file = tooCloseSoundFile
                            local ttsText = tooCloseTTSText
                            local ttsSpeed = 1

                            PlayJTSorTTS(file, ttsText, ttsSpeed)

                        end
                        tooClose = false
                    end

                end
            elseif not IsItemInRange(16114, "target") then
                --判断10码
                if WeakAuras.CheckRange("target", 8, "<=") then
                    --不在近战范围时,已战斗超过一定时间后，开始可以触发提示。
                    --打不到时间间隔小于1秒，不提示。
                    if oorTime == 0 then
                        oorTime = GetTime()
                    else
                        local now = GetTime()
                        local timeDiffOOR = now - oorTime
                        --print("打不到时间 "..timeDiffOOR)
                        if timeDiffOOR >= minOORAlertTime then
                            --超过1秒了，检查能不能提醒
                            --判断近战攻击时间是否足够5秒
                            if inRangeAndAttacking then
                                inRangeAndAttacking = false
                                --已经打了5秒以上之后超出距离才语音，没超过不提醒，但会重新计算近战时长
                                local stopTime = GetTime()
                                local timeDiff = stopTime - startAttackInThisCombat
                                if timeDiff >= alertAfterStart and alertCheck() then
                                    --打不到的MuteBoss
                                    if aura_env.config.isVoice and not isMuteBoss() then
                                        --打不到播放文件需要3个随机一下
                                        --print("摸到怪时间 "..timeDiff.." 打不到时间 "..timeDiffOOR)

                                        local file = randomOORSound()
                                        local ttsText = oorTTSText
                                        local ttsSpeed = 1

                                        PlayJTSorTTS(file, ttsText, ttsSpeed)
                                    end
                                end
                            end
                        end
                    end
                else
                    initTimer()
                end
                aura_env.attacking = "打不到"
            elseif IsCurrentSpell(6603) == false then
                --在近战范围，但没开始自动攻击时
                --2秒没打，可以认为断档了，重新统计时长。如果2秒内继续打就续上了
                if autoAttacking then
                    autoAttacking = false
                    notAutoAttackStartTime = GetTime()
                else
                    local now = GetTime()
                    local timeDiffNoAA = now - notAutoAttackStartTime
                    --print("没再打 "..timeDiffNoAA)
                    if timeDiffNoAA >= minBetweenAutoAttack then
                        --超过2秒，重新统计时长了。也就是2秒内既不会提醒没在打，也不会中断打不到的累计统计时长。
                        if inRangeAndAttacking then
                            inRangeAndAttacking = false
                        end
                        --如果额外多超过了5秒没攻击，那就要再次升级，提示没在打了
                        if timeDiffNoAA >= alertNotAutoAttackingTime and alertCheck() then
                            if aura_env.config.isVoice and not isMuteBoss() then
                                --没在打提醒

                                local file = randomNoAASound()
                                local ttsText = noAATTSText
                                local ttsSpeed = 1

                                PlayJTSorTTS(file, ttsText, ttsSpeed)
                            end
                            autoAttacking = true
                        end
                    end
                end
                aura_env.attacking = "没在打"
            else
                --在近战范围，并且开始自动攻击时
                if not inRangeAndAttacking then
                    inRangeAndAttacking = true
                end
                if startAttackInThisCombat == 0 then
                    startAttackInThisCombat = GetTime()
                end
                autoAttacking = true
                oorTime = 0
                aura_env.attacking = "OK"
            end
        else
            aura_env.attacking = "OK"
        end
        return aura_env.attacking
    end
end

