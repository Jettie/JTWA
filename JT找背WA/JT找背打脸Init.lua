--版本信息
local version = 250216
local requireJTSVersion = 12
local voicePack = "TTS"
local voicePackCheck = true --check过VP就会false

aura_env.soundFile = "Common\\打脸了.ogg"
aura_env.isVoice = true
aura_env.ttstext = "打脸了"

aura_env.faceText = "你在打脸"

if not ( GetLocale() == "zhCN" or GetLocale() == "zhTW" ) then
    -- change Attacking Face voice to english if not cn client.
    aura_env.ttstext = "ticking face"
end

--check if tanking for Dru & DK
local _, class = UnitClass("player")

--静音BOSS战EncounterID
local curEncounterID = 0
local muteBoss = {
    --塔迪乌斯
    [1120] = true,
    --欧尔莉亚
    [750] = true,
    --科隆加恩
    [749] = true
    
}

aura_env.isTankingMute = function()
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
    elseif class == "WARRIOR" then
        if select(9,GetItemInfo(GetInventoryItemID("player", 17))) == "INVTYPE_SHIELD" then
            return true
        else
            return false
        end
    end
    return false
end

aura_env.isMuteBoss = function()
    if muteBoss[curEncounterID] then
        return true
    end
    return false
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTESAY"] = true,
        ["JTEGUILD"] = true,
        ["JTERAID"] = true,
        ["JTEPARTY"] = true,
        ["JTETTS"] = true,
        ["JTECHECK"] = true,
        ["JTECHECKRESPONSE"] = true,
    }
    for k,_ in pairs(prefixList) do
        C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

--author and header
local AURA_ICON = 237554
local AURA_NAME = "JT找背WA"
local AUTHOR = "Jettie@SMTH"
local HEADER_TEXT = ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 妹打打脸打不到 " 

--语音包检测
local CHECK_FILE = aura_env.soundFile
local SOUND_FILE_MISSING = "将使用么得感情的TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local REQUIRE_VERSION = requireJTSVersion
local checkVoicePack = function()
    if voicePackCheck then
        local auraIcon = AURA_ICON or 135428
        local auraName = AURA_NAME or "JT系列WA"
        local author = AUTHOR or "Jettie@SMTH"
        local smallIcon = "|T"..(auraIcon or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
        local headerText = smallIcon.."[|CFF8FFFA2"..auraName.."|R]|CFF8FFFA2 "

        local checkFile = CHECK_FILE or "Common\\biubiubiu.ogg"
        local soundFileMissing = SOUND_FILE_MISSING or ( "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听") )
        local requireVersion = REQUIRE_VERSION or 0

        print(headerText.."作者:|R "..author)

        if aura_env.isVoice then
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
                    voicePack = "JTSound"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    voicePack = tryCheckPSF(checkFile)
                end
            else
                voicePack = tryCheckPSF(checkFile)
            end
        end
        voicePackCheck = false
    end
end
checkVoicePack()

aura_env.OnTrigger = function(event, ...)
    if event == "JT_DALIANLE"  then
        local textShow, isVoice = ...
        aura_env.faceText = textShow and "你在打脸" or ""
        aura_env.isVoice = isVoice
        return true
    elseif event == "PLAYER_REGEN_DISABLED" then
        if WeakAuras.CurrentEncounter then
            curEncounterID = WeakAuras.CurrentEncounter.id or 0
        else
            curEncounterID = 0
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, text, channel = ...
        if prefix == "JTECHECK" then
            local ver = version or 0
            if text == "dalianle" then
                local vpColor = voicePack == "JTSound" and "|CFFFF53A2" or "|CFF1785D1"
                local msg = "dalianle Ver: "..ver.." Sound: "..vpColor..voicePack
                C_ChatInfo.SendAddonMessage("JTECHECKRESPONSE", msg, channel, nil)
            end
        end
        return false
    end
end

