-- 版本信息
local version = 250610

-- Sound
local delayTime = 5
local noPalAuraSoundFile = "Paladin\\没开光环.ogg"
local noPalAuraTTSText = "你还没开光环，注意检查"
local hasCrusaderAuraSoundFile = "Paladin\\战斗飙车光环.ogg"
local hasCrusaderAuraTTSText = "战斗了，你还在飙车"
local ttsSpeed = 1

-- 只用1级ID获取本地化技能名字
local sealSpellIds = {
    [19746] = true, -- 专注光环
    [465] = true, -- 虔诚光环 1级
    [7294] = true, -- 惩戒光环 1级
}

local sealSpellNames = {}

local buildSealSpellNames = function()
    for spellId in pairs(sealSpellIds) do
        local name = GetSpellInfo(spellId)
        if name then
            sealSpellNames[name] = true
        end
    end
end
buildSealSpellNames()

local checkSealByName = function()
    local hasSeal = true
    for name in pairs(sealSpellNames) do
        if not WA_GetUnitBuff("player", name) then
            hasSeal = false
            break
        end
    end
    return hasSeal
end

local shapeShiftFormList = {
    [0] = true, -- 无光环
    -- [1] = true, -- 虔诚光环
    -- [2] = true, -- 惩戒光环
    -- [3] = true, -- 专注光环
    -- [4] = true, -- 暗抗光环 (有等级)
    -- [5] = true, -- 冰抗光环 (有等级)
    -- [6] = true, -- 火抗光环 (有等级)
    [7] = true, -- 十字军光环
}

local delayedAlert = function()
    C_Timer.After(delayTime, function()
            local hasSeal = checkSealByName()
            local shapeShiftForm = GetShapeshiftForm()
            if not hasSeal and shapeShiftFormList[shapeShiftForm] then
                WeakAuras.ScanEvents("JT_PAL_AURA_NOT_FOUND")
            end
    end)
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

local tryAlert = function()
    local hasSeal = checkSealByName()
    if not hasSeal and InCombatLockdown() then
        local shapeShiftForm = GetShapeshiftForm()
        if shapeShiftForm == 0 then
            -- 没开光环
            PlayJTSorTTS(noPalAuraSoundFile, noPalAuraTTSText, ttsSpeed)
        elseif shapeShiftForm == 7 then
            -- 飙车光环
            PlayJTSorTTS(hasCrusaderAuraSoundFile, hasCrusaderAuraTTSText, ttsSpeed)
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "JT_PAL_AURA_NOT_FOUND"then
        tryAlert()
    elseif event == "PLAYER_REGEN_DISABLED" then
        delayedAlert()
    end
end