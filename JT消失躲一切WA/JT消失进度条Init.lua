--版本信息
local version = 250529
local soundPack = "Sonar"
local voicePackCheck = true --check过VP就会false


--设置参数
local vanishBarId = "VanishBar"
local barName = "准备消失"
local vanishSpellId = 26889 --消失法术ID
local vanishIcon = 132331 --消失的图标
local vanishMark = aura_env.config.vanishMark --自定义选项里设置
local timeRange = 0.1
local markWidth = 0.03 --54321的刻度宽度
local isTesting = false
local lastExpirationTime = nil

-- 动作图标隐藏处使用
aura_env.vanishMark = vanishMark
-- 条件中使用
aura_env.mute = false --消失CD=true时，给倒数静音

WeakAuras.ScanEvents("JT_VANISH_CONFIG", aura_env.config.isSound, aura_env.config.enableBtn)

--为了测试,用CD短的脚踢,闪避,疾跑这种没有GCD的技能替代消失
local kickSpellId = 1766
local evasionSpellId = 26669
local sprintSpellId = 11305

-- testTriggerSpellId[fakeSpellId] = fakeName
local testTriggerSpellId = {
    [51723] = "观察者奥尔加隆", --刀扇，8秒读条
    [48659] = "巨兽二型", --4级佯攻，4秒读条
    [1725] = "普崔塞德教授", --扰乱，2.5秒读条
    [5938] = "鲜血女王兰娜瑟尔", --毒刃，6秒读条
}
local testFakeVanishSpellId = {
    [26889] = true, --real vanish
    [26669] = true, --闪避
    [11305] = true, --疾跑
    [1766] = true, --脚踢
    [20572] = true, --血性狂怒
    [26297] = true, --狂暴
}

--清除数据isTesting=false lastExpirationTime=nil
local clearCurrentData = function()
    isTesting = false
    lastExpirationTime = nil
    WeakAuras.ScanEvents("JT_VANISH_CLICKER", 0)
end

--soundFile
local vanishInCDSoundFile = "Common\\消失没好快跑开.ogg"
local soundFile = {
    [0] = "Common\\棒.ogg",
    [1] = "Common\\一.ogg",
    [2] = "Common\\二.ogg",
    [3] = "Common\\三.ogg",
    [4] = "Common\\四.ogg",
    [5] = "Common\\五.ogg"
}
local getReadyToVanishSoundFile = "Common\\准备消失.ogg"
local getSoundFile = function(number,noVoicePack)
    local sonarFile = number == 0 and "Interface\\Addons\\WeakAuras\\Media\\Sounds\\AirHorn.ogg" or "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Sounds\\sonar.ogg"
    if noVoicePack then return sonarFile end
    if aura_env.config.soundType == 1 then
        return soundFile[number]
    else
        return sonarFile
    end
end
aura_env.getSoundFile = getSoundFile

local successSkillData = {
    [0] = { --野外测试
        ["临时占位"] = { --临时，占位
            spellId = 1784,
            duration = 8
        }
    },
    [175] = { --RAID10
        ["唤雷者布隆迪尔"] = { --过载
            spellId = 61869,
            duration = 6
        }
    },
    [176] = { --RAID25
        ["唤雷者布隆迪尔"] = { --过载
            spellId = 63481,
            duration = 6
        }
    },
    [193] = { --RAID10H
        ["占位"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [194] = { --RAID25H
        ["占位"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    }
}

--skillData[difficultyID][bossName] = {spellId=, duration=} | difficultyID = 175=raid10,176=raid25,193=raid10h,194=raid25h
local skillData = {
    [0] = { --野外测试
        ["锋鳞"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["欧尔莉亚"] = { --惊骇尖啸
            spellId = 64386,
            duration = 2
        },
        ["巨兽二型"] = { --震荡冲击
            spellId = 63631,
            duration = 4
        },
        ["观察者奥尔加隆"] = { --大爆炸
            spellId = 64584,
            duration = 8
        },
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["普崔塞德教授"] = { --催泪毒气
            spellId = 71617,
            duration = 2.5
        },
        ["辛达苟萨"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉纳王子"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["鲜血女王兰娜瑟尔"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [3] = { --RAID10
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["普崔塞德教授"] = { --催泪毒气
            spellId = 71617,
            duration = 2.5
        },
        ["辛达苟萨"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉纳王子"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["鲜血女王兰娜瑟尔"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [4] = { --RAID25
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["普崔塞德教授"] = { --催泪毒气
            spellId = 71617,
            duration = 2.5
        },
        ["辛达苟萨"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉纳王子"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["鲜血女王兰娜瑟尔"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [5] = { --RAID10H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["辛达苟萨"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉纳王子"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["鲜血女王兰娜瑟尔"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [6] = { --RAID25H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["辛达苟萨"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉纳王子"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["鲜血女王兰娜瑟尔"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [175] = { --ULD RAID10
        ["锋鳞"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["唤雷者布隆迪尔"] = { --过载
            spellId = 61869,
            duration = 6
        },
        ["欧尔莉亚"] = { --惊骇尖啸
            spellId = 64386,
            duration = 2
        },
        ["霍迪尔"] = { --快速冻结
            spellId = 61968,
            duration = 9
        },
        ["巨兽二型"] = { --震荡冲击
            spellId = 63631,
            duration = 4
        },
        ["观察者奥尔加隆"] = { --大爆炸
            spellId = 64443,
            duration = 8
        },
    },
    [176] = { --ULD RAID25
        ["锋鳞"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["唤雷者布隆迪尔"] = { --过载
            spellId = 63481,
            duration = 6
        },
        ["欧尔莉亚"] = { --惊骇尖啸
            spellId = 64386,
            duration = 2
        },
        ["霍迪尔"] = { --快速冻结
            spellId = 61968,
            duration = 9
        },
        ["巨兽二型"] = { --震荡冲击
            spellId = 63631,
            duration = 4
        },
        ["观察者奥尔加隆"] = { --大爆炸
            spellId = 64584,
            duration = 8
        },
    },
    [193] = { --RAID10H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
    },
    [194] = { --RAID25H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
    }
}

--locales zhTW
local skillData_zhTW = {
    [0] = { --野外测试
        ["锋鳞"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["欧尔莉亚"] = { --惊骇尖啸
            spellId = 64386,
            duration = 2
        },
        ["巨兽二型"] = { --震荡冲击
            spellId = 63631,
            duration = 4
        },
        ["观察者奥尔加隆"] = { --大爆炸
            spellId = 64584,
            duration = 8
        },
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["普崔塞德教授"] = { --催泪毒气
            spellId = 71617,
            duration = 2.5
        },
        ["辛达苟萨"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉纳王子"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["鲜血女王兰娜瑟尔"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [3] = { --RAID10
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["普崔希德教授"] = { -- 催泪毒气
            spellId = 71617,
            duration = 2.5
        },
        ["辛德拉苟莎"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉納爾親王"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["血腥女王菈娜薩爾"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [4] = { --RAID25
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["普崔希德教授"] = { -- 催泪毒气
            spellId = 71617,
            duration = 2.5
        },
        ["辛德拉苟莎"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉納爾親王"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["血腥女王菈娜薩爾"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [5] = { --RAID10H
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["辛德拉苟莎"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉納爾親王"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["血腥女王菈娜薩爾"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [6] = { --RAID25H
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
        ["辛德拉苟莎"] = { -- 严寒
            spellId = 70123,
            duration = 5.1
        },
        ["瓦拉納爾親王"] = { -- 煽动惊恐
            spellId = 72039,
            duration = 4.5
        },
        ["血腥女王菈娜薩爾"] = { -- 煽动惊恐
            spellId = 73070,
            duration = 6
        },
    },
    [175] = { --ULD RAID10
        ["銳鱗"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["風暴召喚者布倫迪爾"] = { --过载
            spellId = 61869,
            duration = 6
        },
        ["奧芮雅"] = { --惊骇尖啸
            spellId = 64386,
            duration = 2
        },
        ["霍迪爾"] = { --快速冻结
            spellId = 61968,
            duration = 9
        },
        ["戰輪MK II"] = { --震荡冲击
            spellId = 63631,
            duration = 4
        },
        ["『觀察者』艾爾加隆"] = { --大爆炸
            spellId = 64443,
            duration = 8
        },
    },
    [176] = { --ULD RAID25
        ["銳鱗"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["風暴召喚者布倫迪爾"] = { --过载
            spellId = 63481,
            duration = 6
        },
        ["奧芮雅"] = { --惊骇尖啸
            spellId = 64386,
            duration = 2
        },
        ["霍迪爾"] = { --快速冻结
            spellId = 61968,
            duration = 9
        },
        ["戰輪MK II"] = { --震荡冲击
            spellId = 63631,
            duration = 4
        },
        ["『觀察者』艾爾加隆"] = { --大爆炸
            spellId = 64584,
            duration = 8
        },
    },
    [193] = { --RAID10H
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
    },
    [194] = { --RAID25H
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        },
    }
}

if GetLocale() == "zhTW" then skillData = skillData_zhTW end

--播放音频文件
local playJTSorTTS = function(file,ttsText,ttsSpeed)
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
aura_env.playJTSorTTS = playJTSorTTS

--creatbar
local createBar = function(e, barid, show, progressType, total, value, name, icon, vanishInCD)
    e[barid] = {}
    e[barid] = {
        name = name,
        icon = icon,
        show = show,
        changed = true,
        additionalProgress = 1
    }
    if show and progressType then
        e[barid].progressType = progressType
        if progressType == "timed" then
            local ap = {}
            --如果消失没好
            if vanishInCD then
                --消音
                aura_env.mute = true
                --消失没好，快跑开
                if aura_env.config.isSound then
                    playJTSorTTS(vanishInCDSoundFile, "消失没好，快跑开", 3)
                end
            else
                aura_env.mute = false
                ap = {
                    {
                        min = -vanishMark,
                        max = vanishMark-vanishMark + 0.1
                    },
                    {
                        min = 0,
                        max = 0 + markWidth + 0
                    },
                    {
                        min = 1,
                        max = 0 + markWidth + 1
                    },
                    {
                        min = 2,
                        max = 0 + markWidth + 2
                    },
                    {
                        min = 3,
                        max = 0 + markWidth + 3
                    },
                    {
                        min = 4,
                        max = 0 + markWidth + 4
                    },
                    {
                        min = 5,
                        max = 0 + markWidth + 5
                    }
                }

                local count = math.ceil(total <= 6 and total or 6)
                local markCount = count >= 0 and count or 0
                local removeCount = 6 - markCount
                if removeCount > 0 then
                    for i = 1, removeCount do
                        table.remove(ap)
                    end
                end
            end

            e[barid].autoHide = true
            e[barid].duration = total
            e[barid].expirationTime = value and value or total + GetTime()
            e[barid].additionalProgress = ap

        elseif progressType == "static" then
            e[barid].total = total
            e[barid].value = value
        end
    end
end

--author and header
local AURA_ICON = 132331
local AURA_NAME = "JT消失躲一切WA"
local AUTHOR = "Jettie@SMTH"
local HEADER_TEXT = ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

--语音包检测
local CHECK_FILE = soundFile[5]
local SOUND_FILE_MISSING = "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local checkVoicePack = function()
    if voicePackCheck then
        local AURA_ICON = AURA_ICON or 135428
        local AURA_NAME = AURA_NAME or "JT系列WA"
        local AUTHOR = AUTHOR or "Jettie@SMTH"
        local HEADER_TEXT = HEADER_TEXT or ( ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 " )

        local CHECK_FILE = CHECK_FILE or "Common\\biubiubiu.ogg"
        local SOUND_FILE_MISSING = SOUND_FILE_MISSING or ( "将使用声呐嘟嘟嘟 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，使用54321倒数") )

        print(HEADER_TEXT.."作者:|R "..AUTHOR)

        if aura_env.config.isSound then
            local function tryCheckPSF(filePath)
                local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
                local file = PATH_PSF..(filePath or "")
                local canplay, soundHandle = PlaySoundFile(file, "Master")
                local voicePack
                if canplay then
                    StopSound(soundHandle)
                    voicePack = JTS and "JTSound" or "VoicePack"
                    print(HEADER_TEXT.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    voicePack = "TTS"
                    print(HEADER_TEXT.."|CFFFFE0B0未找到语音文件|R，"..SOUND_FILE_MISSING.."|R")
                end
                return voicePack
            end

            if JTS and JTS.P then
                local canplay, soundHandle = JTS.P(CHECK_FILE)
                if canplay and soundHandle then
                    StopSound(soundHandle)
                    soundPack = "JTSound"
                    print(HEADER_TEXT.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    soundPack = tryCheckPSF(CHECK_FILE)
                end
            else
                soundPack = tryCheckPSF(CHECK_FILE)
            end
        end
        voicePackCheck = false
    end
end

checkVoicePack()

--测试假人
local testTarget = {
    ["大师的训练假人"] = true,
    ["专家的训练假人"] = true
}
local isTestTarget = function()
    local targetName = UnitName("target")
    if targetName then
        if testTarget[targetName] then
            return true
        end
    end
    return false
end

--report
local report = function(text)
    if aura_env.config.report then
        local channel = nil
        if IsInRaid() and not  IsInGroup(LE_PARTY_CATEGORY_INSTANCE)  then
            channel = 'RAID'
        elseif IsInGroup(LE_PARTY_CATEGORY_HOME) and not  IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            channel = 'PARTY'
        elseif IsInRaid() and  IsInGroup(LE_PARTY_CATEGORY_INSTANCE)  then
            channel = 'INSTANCE_CHAT'
        end
        if channel then
            SendChatMessage(text,channel,nil,nil)
            return true
        end
    else
        return false
    end
end

local OnCLEUF = function(e, event, ...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    if subevent == "SPELL_CAST_START" then
        local spellId, spellName, spellSchool = select(12, ...)

        local difficultyID = select(3,GetInstanceInfo())
        if skillData[difficultyID] then
            if skillData[difficultyID][sourceName] then
                if skillData[difficultyID][sourceName].spellId == spellId then
                    local duration, expirationTime

                    --if spellId then print("法术ID="..spellId) end

                    --正常流程中，不是测试了
                    duration = skillData[difficultyID][sourceName].duration
                    expirationTime = duration + GetTime() - vanishMark
                    --临时存一下结束时间，用于跟消失时间做差值比较，输出报表
                    lastExpirationTime = expirationTime

                    --判断测试处理
                    if event == "JT_FAKE_CLEU" then
                        if aura_env.config.isTest then
                            isTesting = true
                            print(HEADER_TEXT.."模拟|R "..sourceName.." |CFF8FFFA2的技能|R "..GetSpellLink(skillData[difficultyID][sourceName].spellId))
                            print(HEADER_TEXT.."卡时间点使用"..GetSpellLink(kickSpellId).."/"..GetSpellLink(evasionSpellId).."/"..GetSpellLink(sprintSpellId).."模拟"..GetSpellLink(vanishSpellId).."进行测试|R")
                        else
                            --测试状态，但是自定义选项关闭了，那就不生成计时条了
                            clearCurrentData() --update isTesting=false lastExpirationTime=nil
                            expirationTime = nil
                        end
                    end

                    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                        print(HEADER_TEXT.."检测到|R "..sourceName.." |CFF8FFFA2的技能|R "..GetSpellLink(skillData[difficultyID][sourceName].spellId))
                    end

                    --判断消失是否CD或者CD是否来得及
                    local vanishCDStartTime, vanishDuration = GetSpellCooldown(vanishSpellId) --vanishDuration==0 是可以用
                    local reportText = "[JT消失躲一切WA]"
                    if expirationTime then
                        if vanishDuration == 0 or ( vanishCDStartTime + vanishDuration + vanishMark) <= expirationTime then
                            createBar(e, vanishBarId, true, "timed", duration, expirationTime, barName, vanishIcon)
                            if duration >= 6 and aura_env.config.isSound then
                                playJTSorTTS(getReadyToVanishSoundFile,"准备消失",3)
                            end
                            if aura_env.config.enableBtn then
                                WeakAuras.ScanEvents("JT_VANISH_BG", 1)
                            end

                            reportText = reportText.." 消失技能就绪，可以跟["..sourceName.."]的"..GetSpellLink(skillData[difficultyID][sourceName].spellId).."拼命啦!"
                        else
                            createBar(e, vanishBarId, true, "timed", duration, expirationTime, barName, vanishIcon, true) --消失CD
                            reportText = reportText.." 消失技能冷却中，溜了溜了，狗命要紧!"
                        end
                        report(reportText)
                    end
                    return true
                end
            end
        end
    elseif subevent == "SPELL_CAST_FAILED" then
        local spellId, spellName, spellSchool = select(12, ...)

        local difficultyID = select(3,GetInstanceInfo())
        if skillData[difficultyID] then
            if skillData[difficultyID][sourceName] then
                if skillData[difficultyID][sourceName].spellId == spellId then
                    if e[vanishBarId] then
                        e[vanishBarId].show = false
                        clearCurrentData()
                    end
                    return true
                end
            end
        end
    elseif subevent == "SPELL_CAST_SUCCESS" then
        local spellId, spellName, spellSchool = select(12, ...)

        --有些技能是施法居然是SUCCESS，垃圾暴雪，再跑一次一样的流程 successSkillData
        local difficultyID = select(3,GetInstanceInfo())
        if successSkillData[difficultyID] then
            if successSkillData[difficultyID][sourceName] then
                if successSkillData[difficultyID][sourceName].spellId == spellId then
                    local duration, expirationTime

                    --正常流程中，不是测试了
                    duration = successSkillData[difficultyID][sourceName].duration
                    expirationTime = duration + GetTime() - vanishMark
                    --临时存一下结束时间，用于跟消失时间做差值比较，输出报表
                    lastExpirationTime = expirationTime

                    --判断测试处理
                    if event == "JT_FAKE_CLEU" then
                        if aura_env.config.isTest then
                            isTesting = true
                            print(HEADER_TEXT.."模拟|R "..sourceName.." |CFF8FFFA2的技能|R "..GetSpellLink(successSkillData[difficultyID][sourceName].spellId))
                            print(HEADER_TEXT.."卡时间点使用"..GetSpellLink(kickSpellId).."/"..GetSpellLink(evasionSpellId).."/"..GetSpellLink(sprintSpellId).."模拟"..GetSpellLink(vanishSpellId).."进行测试|R")
                        else
                            --测试状态，但是自定义选项关闭了，那就不生成计时条了
                            clearCurrentData() --update isTesting=false lastExpirationTime=nil
                            expirationTime = nil
                        end
                    end

                    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                        print(HEADER_TEXT.."检测到|R "..sourceName.." |CFF8FFFA2的技能|R "..GetSpellLink(successSkillData[difficultyID][sourceName].spellId))
                    end

                    --判断消失是否CD或者CD是否来得及
                    local vanishCDStartTime, vanishDuration = GetSpellCooldown(vanishSpellId) --vanishDuration==0 是可以用
                    local reportText = "[JT消失躲一切WA]"
                    if expirationTime then
                        if vanishDuration == 0 or ( vanishCDStartTime + vanishDuration + vanishMark) <= expirationTime then
                            createBar(e, vanishBarId, true, "timed", duration, expirationTime, barName, vanishIcon)
                            if duration >= 6 and aura_env.config.isSound then
                                playJTSorTTS(getReadyToVanishSoundFile,"准备消失",3)
                            end
                            if aura_env.config.enableBtn then
                                WeakAuras.ScanEvents("JT_VANISH_BG", 1)
                            end

                            reportText = reportText.." 消失技能就绪，可以跟["..sourceName.."]的"..GetSpellLink(successSkillData[difficultyID][sourceName].spellId).."拼命啦!"
                        else
                            createBar(e, vanishBarId, true, "timed", duration, expirationTime, barName, vanishIcon, true) --消失CD
                            reportText = reportText.." 消失技能冷却中，溜了溜了，狗命要紧!"
                        end
                        report(reportText)
                    end
                    return true
                end
            end
        end

        --这才是常规处理，SUCCESS就清除
        if skillData[difficultyID] then
            if skillData[difficultyID][sourceName] then
                if skillData[difficultyID][sourceName].spellId == spellId then
                    if e[vanishBarId] then
                        e[vanishBarId].show = false
                        if aura_env.config.enableBtn then
                            WeakAuras.ScanEvents("JT_VANISH_CLICKER", 0)
                        end

                        clearCurrentData()
                    end
                    return true
                end
            end
        end
    end
end

local vanishTrigger = function(e, event, ...)
    local castTime, sourceName, spellId = ...

    local expirationTime = castTime - vanishMark
    local duration = expirationTime - GetTime()

    --临时存一下结束时间，用于跟消失时间做差值比较，输出报表
    lastExpirationTime = expirationTime

    print(HEADER_TEXT.."检测到|R "..(sourceName or "神仙").." |CFF8FFFA2的技能|R "..(spellId and GetSpellLink(spellId) or ""))

    --判断消失是否CD或者CD是否来得及
    local vanishCDStartTime, vanishDuration = GetSpellCooldown(vanishSpellId) --vanishDuration==0 是可以用
    local reportText = "[JT消失躲一切WA]"
    if expirationTime then
        if vanishDuration == 0 or ( vanishCDStartTime + vanishDuration + vanishMark) <= expirationTime then
            createBar(e, vanishBarId, true, "timed", duration, expirationTime, barName, vanishIcon)
            if duration >= 6 and aura_env.config.isSound then
                playJTSorTTS(getReadyToVanishSoundFile,"准备消失",3)
            end
            if aura_env.config.enableBtn then
                WeakAuras.ScanEvents("JT_VANISH_BG", 1)
            end

            reportText = reportText.." 消失技能就绪，可以跟["..(sourceName or "神仙").."]的"..(spellId and GetSpellLink(spellId) or "技能").."拼命啦!"
        else
            createBar(e, vanishBarId, true, "timed", duration, expirationTime, barName, vanishIcon, true) --消失CD
            reportText = reportText.." 消失技能冷却中，溜了溜了，狗命要紧!"
        end
        report(reportText)
    end
    return true
end

local OnUnitSpellCastSucceeded = function(...)
    local unitTarget, castGUID, spellId = ...
    if unitTarget == "player" then
        if testTriggerSpellId[spellId] then
            if isTestTarget() then
                --及时刷新一个difficultyID，只在0野外的时候才能发测试JT_FAKE_CLEU
                --重要的数据是sourceName和fakeSpellId，另一边要用这两个数据对照才能通过
                local difficultyID = select(3,GetInstanceInfo())
                if difficultyID == 0 then
                    local fakeEvent = "JT_FAKE_CLEU"
                    local timestamp = GetServerTime()
                    local subevent = "SPELL_CAST_START"
                    local hideCaster = false
                    local sourceGUID = "JT-Fake-sourceGUID"
                    local sourceName = testTriggerSpellId[spellId]
                    local sourceFlags = 2632
                    local sourceRaidFlags = 0
                    local destGUID = "JT-Fake-destGUID"
                    local destName = UnitName("player")
                    local destFlags = 1297
                    local destRaidFlags = 0
                    local fakeSpellId = skillData[difficultyID][sourceName] and skillData[difficultyID][sourceName].spellId
                    local spellName = "测试法术"
                    local spellSchool = 1
                    --伪造一个JT_FAKE_CLEU的EVENT
                    WeakAuras.ScanEvents(fakeEvent,timestamp,subevent,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,fakeSpellId,spellName,spellSchool)
                end
            end
        elseif ( isTesting and testFakeVanishSpellId[spellId] ) or (not isTesting and spellId == vanishSpellId ) then
            if lastExpirationTime then
                local now = GetTime()
                local timediffToBar = lastExpirationTime - now
                local timediffToSpell = timediffToBar + vanishMark

                --打印当前设置刻度值
                local separator = HEADER_TEXT.."------------------------------"
                print(separator)
                local vanishGoal = HEADER_TEXT.."自定义选项中|CFF6195FF预设消失点|R为:|R"..vanishMark
                print(vanishGoal)

                --打印推荐网速
                local _, _, _, latencyWorld = GetNetStats()
                if latencyWorld then
                    local netText = HEADER_TEXT.."你的当前延迟为:|R"..latencyWorld.."|CFF8FFFA2ms 推荐|CFF6195FF预设消失点|R为:|R"..(math.ceil(latencyWorld/50)*0.05+0.1).."|CFF8FFFA2秒|R"..(latencyWorld >= 300 and " |CFF8FFFA2延迟大于|R300 |CFF8FFFA2- 波动较大请自行掌握|R" or " ")
                    print(netText)
                end

                --打印本次对照刻度的时间情况
                local timePre
                if timediffToBar >= timeRange then
                    timePre = "|CFFFF0000提前|R"
                elseif timediffToBar > 0 then
                    timePre = "|CFF00FF00稍微提前|R"
                elseif timediffToBar == 0 then
                    timePre = "|CFFFFFF00刚好|R"
                elseif timediffToBar < 0 then
                    timePre = "|CFF00FF00稍微晚了|R"
                elseif timediffToBar < ( 0 - timeRange ) then
                    timePre = "|CFFFF0000晚了|R"
                elseif timediffToBar < ( 0 - timeRange - vanishMark) then
                    timePre = "|CFFFF00FF太晚了|R"
                end
                local textToGoal = HEADER_TEXT.."本次消失时间比 |CFF6195FF预设消失点|R"..timePre.."|R"..(math.floor((timediffToBar >= 0 and timediffToBar or (0-timediffToBar)) * 1000 ) / 1000).."|CFF8FFFA2秒|R"
                print(textToGoal)

                --打印对照真实计时条结束点的时间情况
                local forReal
                if timediffToSpell >= (timeRange *3) then
                    forReal = "|CFFFF0000太早了 必吃技能|R"
                elseif timediffToSpell >= (timeRange *1.5) then
                    forReal = "|CFF00FF00在安全线附近|R"
                elseif timediffToSpell >= timeRange then
                    forReal = "|CFF00FF00在安全时间之内|R"
                elseif timediffToSpell > 0 then
                    forReal = "|CFFFFFF00时间刚好 完美!|R"
                else
                    forReal = "|CFFFF0000晚了 结束了罪恶的一生!|R"
                end
                local textToReal = HEADER_TEXT.."如果是真实情况 你这次消失"..forReal
                print(textToReal)
                print(separator)

                --真的是用的消失的时候，尝试通报或者打印
                if spellId == vanishSpellId then

                    local vanishSuccessed = "成功在读条最后的"..(math.floor((timediffToSpell) * 1000 ) / 1000).."秒之前释放了"..GetSpellLink(vanishSpellId).."!生死有命富贵在天!"
                    if not report(vanishSuccessed) then print("[|CFF8FFFA2JT消失躲一切WA|R] |CFF8FFFA2"..vanishSuccessed) end
                end
                clearCurrentData()
            end
        end
    end
end

-- 触发器1
aura_env.OnTrigger = function(e, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "JT_CUSTOM_CLEU" or event == "JT_FAKE_CLEU" then
        return OnCLEUF(e, event, ...)
    elseif event == "JT_VANISH_TRIGGER_TIMER" then
        return vanishTrigger(e, event, ...)
    end
end

-- 触发器2
aura_env.OnEventTrigger = function(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        --Reset
        clearCurrentData()
        --checkVoicePack
        checkVoicePack()
    elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
        --Reset
        clearCurrentData()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        return OnUnitSpellCastSucceeded(...)
    end
end