--版本信息
local version = 250216
local requireJTSVersion = 1
local voicePack = "TTS"
local voicePackCheck = true --check过VP就会false
aura_env.soundFile = "ToTReminder\\取消嫁祸.ogg"

--variables
aura_env.canplay = false
aura_env.soundHandle = nil
aura_env.ttsplaying = false

--author and header
local AURA_ICON = 236283
local AURA_NAME = "JT嫁祸WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

--语音包检测
local CHECK_FILE = aura_env.soundFile
local SOUND_FILE_MISSING = "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
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


