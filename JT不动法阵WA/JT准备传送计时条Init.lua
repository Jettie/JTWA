--版本信息
aura_env.version = 250313
aura_env.voicePack = "Sonar"
aura_env.voicePackCheck = true --check过VP就会false
aura_env.mute = false --传送CD=true时，给倒数静音

--设置参数
aura_env.barid = "VanishBar"
aura_env.barName = "准备传送"
aura_env.vanishSpellId = 48020 --传送法术ID
aura_env.vanishIcon = 237560 --传送的图标
aura_env.vanishMark = aura_env.config.vanishMark --自定义选项里设置
aura_env.timeRange = 0.1
aura_env.markWidth = 0.03 --54321的刻度宽度
aura_env.isTesting = false
aura_env.lastExpirationTime = nil

WeakAuras.ScanEvents("JT_VANISH_CONFIG", aura_env.config.isSound, aura_env.config.enableBtn)

--为了测试,用CD短的脚踢,闪避,疾跑这种没有GCD的技能替代传送
aura_env.kickSpellId = 57946 --生命分流 8级
aura_env.evasionSpellId = 27222 --生命分流 7级
aura_env.sprintSpellId = 11689 --生命分流 6级

-- aura_env.testTriggerSpellId[fakeSpellId] = fakeName
aura_env.testTriggerSpellId = {
    [51723] = "观察者奥尔加隆", --刀扇，8秒读条
    [48659] = "巨兽二型", --4级佯攻，4秒读条
    [1725] = "欧尔莉亚", --扰乱，2秒读条
    [5938] = "锋鳞", --毒刃，1.5秒读条
}
aura_env.testFakeVanishSpellId = {
    [48020] = true, --real teleport
    [57946] = true, --生命分流 8级
    [27222] = true, --生命分流 7级
    [11689] = true, --生命分流 6级
    [11688] = true, --生命分流 5级
    [11687] = true, --生命分流 4级
    [1456] = true, --生命分流 3级
    [1455] = true, --生命分流 2级
    [1454] = true, --生命分流 1级
}

--清除数据aura_env.isTesting=false aura_env.lastExpirationTime=nil
aura_env.clearCurrentData = function()
    aura_env.isTesting = false
    aura_env.lastExpirationTime = nil
    WeakAuras.ScanEvents("JT_VANISH_CLICKER", 0)
end

--soundFile
local vanishInCDSoundFile = "Warlock\\传送没好快跑开.ogg"
local soundFile = {
    [0] = "Common\\棒.ogg",
    [1] = "Common\\一.ogg",
    [2] = "Common\\二.ogg",
    [3] = "Common\\三.ogg",
    [4] = "Common\\四.ogg",
    [5] = "Common\\五.ogg"
}
aura_env.getReadyToVanishSoundFile = "Warlock\\准备传送.ogg"
aura_env.getSoundFile = function(number,noVoicePack)
    local sonarFile = number == 0 and "Interface\\Addons\\WeakAuras\\Media\\Sounds\\AirHorn.ogg" or "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Sounds\\sonar.ogg"
    if noVoicePack then return sonarFile end
    if aura_env.config.soundType == 1 then
        return soundFile[number]
    else
        return sonarFile
    end
end

aura_env.successSkillData = {
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
aura_env.skillData = {
    [0] = { --野外测试
        ["Jettie"] = { --虫洞
            spellId = 67833,
            duration = 6
        },
        ["Jsm"] = { --萨满星界传送
            spellId = 556,
            duration = 6
        },
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
        }
    },
    [3] = { --RAID10
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [4] = { --RAID25
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [5] = { --RAID10H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [6] = { --RAID25H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
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
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
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
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },  
    [193] = { --RAID10H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [194] = { --RAID25H
        ["冰吼"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    }
}

--locales zhTW
local skillData_zhTW = {
    [0] = { --野外测试
        ["Jettie"] = { --虫洞
            spellId = 67833,
            duration = 6
        },
        ["Jsm"] = { --萨满星界传送
            spellId = 556,
            duration = 6
        },
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
        }
    },
    [175] = { --RAID10
        ["銳鱗"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["風暴召喚者布倫迪爾"] = { --过载 --00:37.140    唤雷者布隆迪尔 casts 过载 --00:43.138    唤雷者布隆迪尔's 过载 fades from 唤雷者布隆迪尔 --00:43.138    月小兔's 真言术：盾 absorbs 4211 damage of 唤雷者布隆迪尔's 过载 on Jettie
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
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [176] = { --RAID25
        ["銳鱗"] = { --龙翼打击
            spellId = 62666,
            duration = 1.5
        },
        ["風暴召喚者布倫迪爾"] = { --过载 --00:35.605    唤雷者布隆迪尔 casts 过载 --00:41.616    唤雷者布隆迪尔's 过载 fades from 唤雷者布隆迪尔 --00:41.632    北小兔's 真言术：盾 absorbs 507 damage of 唤雷者布隆迪尔's 过载 on Jettie
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
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },  
    [193] = { --RAID10H
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    },
    [194] = { --RAID25H
        ["冰嚎"] = { --重型撞击
            spellId = 66683,
            duration = 1
        }
    }
}

if GetLocale() == "zhTW" then aura_env.skillData = skillData_zhTW end

--creatbar
function aura_env.e(e, barid, show, progressType, total, value, name, icon, vanishInCD)
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
            --如果传送没好
            if vanishInCD then
                --消音
                aura_env.mute = true
                --传送没好，快跑开
                if aura_env.config.isSound then
                    aura_env.playJTSorTTS(vanishInCDSoundFile, "传送没好，快跑开", 3)
                end
            else
                aura_env.mute = false
                ap = {
                    {
                        min = -aura_env.vanishMark,
                        max = aura_env.vanishMark-aura_env.vanishMark + 0.1
                    },
                    {
                        min = 0,
                        max = 0 + aura_env.markWidth + 0
                    },
                    {
                        min = 1,
                        max = 0 + aura_env.markWidth + 1
                    },
                    {
                        min = 2,
                        max = 0 + aura_env.markWidth + 2
                    },
                    {
                        min = 3,
                        max = 0 + aura_env.markWidth + 3
                    },
                    {
                        min = 4,
                        max = 0 + aura_env.markWidth + 4
                    },
                    {
                        min = 5,
                        max = 0 + aura_env.markWidth + 5
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

--播放音频文件
aura_env.playJTSorTTS = function(file,ttsText,ttsSpeed)
    
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


--重写职业名字染色，WA_ClassColorName会返回空置
aura_env.classColorName = function(unit)
    if unit and UnitExists(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if not class then
            return name
        else
            local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unit
    end
end


--author and header
local AURA_ICON = 237560
local AURA_NAME = "JT不动法阵WA"
local AUTHOR = "Jettie@SMTH"
local HEADER_TEXT = ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 " 

--header
aura_env.headerText = HEADER_TEXT

--语音包检测
local CHECK_FILE = soundFile[5]
local SOUND_FILE_MISSING = "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
aura_env.checkVoicePack = function()
    if aura_env.voicePackCheck then
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
                if canplay then
                    StopSound(soundHandle)
                    aura_env.voicePack = "JTSound"
                    print(HEADER_TEXT.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    aura_env.voicePack = tryCheckPSF(CHECK_FILE)
                end
            else
                aura_env.voicePack = tryCheckPSF(CHECK_FILE)
            end
        end
        aura_env.voicePackCheck = false
    end
end

aura_env.checkVoicePack()

--测试假人
local testTarget = {
    ["大师的训练假人"] = true,
    ["专家的训练假人"] = true
}
aura_env.isTestTarget = function()
    local targetName = UnitName("target")
    if targetName then
        if testTarget[targetName] then
            return true
        end
    end
    return false
end

--report
function aura_env.report(text)
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


