-- 版本信息
local version = 250814.2

--solo header
local AURA_ICON = 134155
local AURA_NAME = "JT冰龙招架抓内鬼WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local HELLO_WORLD = HEADER_TEXT.."- 冰龙是谁在打招架 - 作者:|R "..AUTHOR

print(HELLO_WORLD)

local myName = UnitName("player")

local MELEE_ID = 6603

-- 保存parry的时间
local saveParryLogTime = aura_env.saveParryLogTime or 6

local isInValidEncounter = false
local thisEncounterId = 0
local encounterStartTime = 0

-- 初始化几个数据表
-- parryLogs[1] = {guid = "Player-1234567890", name = "name1", parry = true, timestamp = 1234567890}
local parryLogs = {}

-- 有新的parry发生时，更新parryLogs，并移除超过saveParryLogTime秒之前的parry记录
local function updateParryCountLogs(newParryData)
    local guid = newParryData.guid
    local name = newParryData.name
    local spell = newParryData.spell
    local parry = newParryData.parry
    local timestamp = newParryData.timestamp

    table.insert(parryLogs, {
        guid = guid,
        name = name,
        spell = spell,
        parry = parry,
        timestamp = timestamp,
    })

    local removeIndex = {}
    for i, v in ipairs(parryLogs) do
        if v.timestamp < timestamp - saveParryLogTime then
            table.insert(removeIndex, i)
        end
    end

    -- 需要先正序排序，再倒叙remove
    table.sort(removeIndex, function(a, b)
        return a < b
    end)

    -- 需要倒叙的remove
    for i = #removeIndex, 1, -1 do
        table.remove(parryLogs, removeIndex[i])
    end
end

local refreshParryCountLogs = function()
    local removeIndex = {}
    for i, v in ipairs(parryLogs) do
        if v.beforeDeadTime + saveParryLogTime < 0 then
            table.insert(removeIndex, i)
        end
    end

    -- 需要先将removeIndex正序排序，再倒叙remove
    table.sort(removeIndex, function(a, b)
        return a < b
    end)

    -- 需要倒叙的remove
    for i = #removeIndex, 1, -1 do
        table.remove(parryLogs, removeIndex[i])
    end
    return
end

-- swingTakenList[1] = {guid = "Player-1234567890", name = "name1", swingTaken = 10}
local swingTakenList = {}

-- top5SwingTakenList[1] = {guid = "Player-1234567890", name = "name1", swingTaken = 10}
local top5SwingTakenList = {}

-- 有人阵亡时计算swingTakenList中，swingTaken大于等于2的前5名，存入top5SwingTakenList，并以此作为是否为坦克的判断
local function calculateTop5SwingTaken()
    for k, v in pairs(swingTakenList) do
        if v.swingTaken >= 2 then
            table.insert(top5SwingTakenList, v)
            -- 需要计算取swingTaken最多的5个人
            table.sort(top5SwingTakenList, function(a, b)
                return a.swingTaken > b.swingTaken
            end)
            if #top5SwingTakenList > 5 then
                table.remove(top5SwingTakenList, 6)
            end
        end
    end
end

-- unitDeadList[1] = {guid = "Player-1234567890", name = "name1", timestamp = 1234567890}
local unitDeadList = {}

-- 有人阵亡时，记录到unitDeadList，并将当时的parryLogs,也存入unitDeadList
local function saveTankDead(deadManData)
    local guid = deadManData.guid
    local name = deadManData.name
    local timestamp = deadManData.timestamp
    local deadTime = time() - encounterStartTime

    

    -- 计算parryLogs中，每条记录的timestamp与deadManData.timestamp的差值，存入parryLogs
    for k, v in pairs(parryLogs) do
        local timeDiff =v.timestamp - timestamp
        parryLogs[k].beforeDeadTime = timeDiff
    end

    refreshParryCountLogs()

    table.insert(unitDeadList, {
        guid = guid,
        name = name,
        timestamp = timestamp,
        deadTime = deadTime,
        parryLogs = parryLogs,
    })

    parryLogs = {}
end

-- Creature-0-4527-631-4225-36853-00007BA789
local validEncounterIdToBossNpcIdList = {
    -- 冰冠堡垒
    [855] = {
        36853,
    }, -- 辛达苟萨

    -- 红玉
    [890] = {
        39751,
    }, -- 战争之子巴尔萨鲁斯
    [893] = {
        39746,
    }, -- 萨瑞瑟里安将军
    [891] = {
        39747,
    },
    [887] = {
        39863,
        40142,
    }, -- 海里昂
}

local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug : "..(text or "nil"))
    end
end

local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(ParryKiller) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))

    --test data
    if JTDebug then
        parryLogs = {
            [1]= {
                guid = "Player-1234567890",
                name = "Jettie",
                spell = MELEE_ID,
                parry = true,
                timestamp = time() -5,
            },
            [2]= {
                guid = "Player-1234567891",
                name = "Jsm",
                spell = MELEE_ID,
                parry = true,
                timestamp = time() -4,
            },
            [3]= {
                guid = "Player-1234567892",
                name = "Jetank",
                spell = MELEE_ID,
                parry = true,
                timestamp = time() -3,
            },
            [4]= {
                guid = "Player-1234567893",
                name = "Jepal",
                spell = MELEE_ID,
                parry = true,
                timestamp = time() -2,
            },
        }
        swingTakenList = {
            [1]= {
                guid = "Player-4533-0627610A",
                name = "JTANK",
                swingTaken = 111,
            },
            [2]= {
                guid = "Player-4533-0627610B",
                name = "Jedith",
                swingTaken = 11,
            },
            [3]= {
                guid = "Player-4533-0627610C",
                name = "Jsm",
                swingTaken = 2,
            },
            [4]= {
                guid = "Player-4533-0627610D",
                name = "Jettie",
                swingTaken = 1,
            },
            [5]= {
                guid = "Player-4533-0627610E",
                name = "Jep",
                swingTaken = 1,
            },
            [6]= {
                guid = "Player-4533-0627610F",
                name = "Jedru",
                swingTaken = 1,
            }
        }

        unitDeadList = {
            [1]= {
                guid = "Player-4533-0627610A",
                name = "JTANK1",
                timestamp = time() - 10,
                deadTime = 10,
                parryLogs = {
                    [1]= {
                        guid = "Player-1234567890",
                        name = "Jetank",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -5,
                        beforeDeadTime = -5,
                    },
                    [2]= {
                        guid = "Player-1234567891",
                        name = "Jsm",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -4,
                        beforeDeadTime = -4,
                    },
                    [3]= {
                        guid = "Player-1234567892",
                        name = "Jedith",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -3,
                        beforeDeadTime = -3,
                    },
                    [4]= {
                        guid = "Player-1234567893",
                        name = "Jep",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -2,
                        beforeDeadTime = -2,
                    },
                },
            },
            [2]= {
                guid = "Player-4533-0627610B",
                name = "辛达苟萨1",
                timestamp = time() - 10,
                deadTime = 10,
                parryLogs = {
                    [1]= {
                        guid = "Player-1234567890",
                        name = "Jetank",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -5,
                        beforeDeadTime = -5,
                    },
                    [2]= {
                        guid = "Player-1234567891",
                        name = "Jsm",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -4,
                        beforeDeadTime = -4,
                    },
                    [3]= {
                        guid = "Player-1234567892",
                        name = "Jedith",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -3,
                        beforeDeadTime = -3,
                    },
                    [4]= {
                        guid = "Player-1234567893",
                        name = "Jep",
                        spell = MELEE_ID,
                        parry = true,
                        timestamp = time() -2,
                        beforeDeadTime = -2,
                    },
                },
            },
        }
        validEncounterIdToBossNpcIdList[831] = {
            36502,
        } -- 灵魂洪炉 噬魂者

        calculateTop5SwingTaken()
    end
end

local isValidBoss = function()
    return validEncounterIdToBossNpcIdList[thisEncounterId] and true or false
end

local validBossNpcIds = {}
local initValidNpcIds = function()
    local bossNpcId = validEncounterIdToBossNpcIdList[thisEncounterId]
    if bossNpcId then
        for _, v in ipairs(bossNpcId) do
            validBossNpcIds[v] = true
        end
    end
end

local resetData = function()
    parryLogs = {}
    swingTakenList = {}
    top5SwingTakenList = {}
    unitDeadList = {}
end

local destIsValidBoss = function(targetName)
    local unitType, _, _, _, _, npcId = strsplit("-", targetName)
    local numNpcId = tonumber(npcId)
    if unitType == "Creature" and validBossNpcIds[numNpcId] then
        return true
    end
    return false
end

-- for pet owner name
local scanTool = CreateFrame( "GameTooltip", "ScanTooltip", nil, "GameTooltipTemplate" )
scanTool:SetOwner( WorldFrame, "ANCHOR_NONE" )
local scanText = _G["ScanTooltipTextLeft2"]
local getPetOwner = function(petName)
   scanTool:ClearLines()
   scanTool:SetUnit(petName)
   local ownerText = scanText:GetText()
   if not ownerText then return nil end
   local owner, _ = string.split("'",ownerText)
   return owner -- This is the pet's owner
end

local OnCLEUF = function(...)
    if not isInValidEncounter then return end

    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, arg12, _, _, arg15, arg16, _, _, arg19 = ...

    local shortSourceName = sourceName and (strsplit("-", sourceName) and strsplit("-", sourceName) or sourceName) or nil
    local shortDestName = destName and (strsplit("-", destName) and strsplit("-", destName) or destName) or nil

    if UnitInRaid(shortSourceName) or UnitInParty(shortSourceName) or destIsValidBoss(destName) then
        local isAPet = (UnitInRaid(shortSourceName) or UnitInParty(shortSourceName)) and false or true
        local petOwnerName = isAPet and getPetOwner(shortSourceName) or nil

        if subevent == "SWING_MISSED" then
            if arg12 == "PARRY" then
                -- 整理parryData
                local parryData = {
                    guid = sourceGUID,
                    name = shortSourceName,
                    spell = MELEE_ID,
                    parry = true,
                    timestamp = timestamp,
                    isAPet = (isAPet and petOwnerName) and true or false,
                    petOwnerName = petOwnerName,
                }
                updateParryCountLogs(parryData)
            end
        elseif subevent == "SPELL_MISSED" then
            if arg15 == "PARRY" then
                -- 整理parryData
                local parryData = {
                    guid = sourceGUID,
                    name = shortSourceName,
                    spell = arg12,
                    parry = true,
                    timestamp = timestamp,
                    isAPet = (isAPet and petOwnerName) and true or false,
                    petOwnerName = petOwnerName,
                }
                updateParryCountLogs(parryData)
            end
        end
    else
        if UnitInRaid(shortDestName) or UnitInParty(shortDestName) then
            if subevent == "SWING_MISSED" or subevent == "SWING_DAMAGE" then
                if sourceGUID and destGUID then
                    local unitType, _, _, _, _, npcId = strsplit("-", sourceGUID)
                    local numNpcId = tonumber(npcId)
                    if unitType == "Creature" and validBossNpcIds[numNpcId] then
                        -- Boss每次攻击都存入swingTakenList中，用于检查是否为坦克
                        if not swingTakenList[destGUID] then
                            swingTakenList[destGUID] = {
                                guid = destGUID,
                                name = shortDestName,
                                swingTaken = 1,
                            }
                        else
                            swingTakenList[destGUID].swingTaken = swingTakenList[destGUID].swingTaken + 1
                        end
                    end
                end
            elseif subevent == "UNIT_DIED" then
                -- UNIT_DIED,0000000000000000,nil,0x80000000,0x80000000,Player-4533-0582AD60,"赛亚人的奶爸-维希度斯-CN",0x80000514,0x80000000,0
                calculateTop5SwingTaken()

                local isTank = false
                for _, v in ipairs(top5SwingTakenList) do
                    if v.guid == destGUID then
                        isTank = true
                        break
                    end
                end

                if isTank then
                    -- 记录坦克死亡信息
                    local deadManData = {
                        guid = destGUID,
                        name = shortDestName,
                        timestamp = timestamp,
                    }

                    saveTankDead(deadManData)
                end
            end
        end
    end
    return
end

local getChannel = function()
    if IsInRaid() and not IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        return "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInGroup() and IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "PARTY"
    end
end

local sendMsgInterval = 0.3

local sendMsgToRaidOrGroup = function(textTableOrStr, intervalTime)
    intervalTime = intervalTime or 0
    local channel = getChannel()

    if JTDebug then
        channel = "GUILD" -- test in GUILD
    end

    if not channel then return end

    if type(textTableOrStr) == "string" then
        textTableOrStr = {textTableOrStr}
    end
    for i, v in ipairs(textTableOrStr) do
        C_Timer.After(intervalTime, function()
            -- for _, textLine in ipairs(textTableOrStr[i]) do
                SendChatMessage(v, channel, nil, nil)
            -- end
        end)
        intervalTime = intervalTime + sendMsgInterval
    end
    return intervalTime
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTEPARRYKILLER"] = true,
    }
    for k, _ in pairs(prefixList) do
        C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

local killerReporter = {}

local receiveMessage = function(...)
    local prefix, text, _, sender = ...
    local senderName = Ambiguate(sender,"all")
    if prefix == "JTEPARRYKILLER" then
        local roll = tonumber(text)
        if roll then
            killerReporter[senderName] = {
                sender = senderName,
                roll = roll,
            }
        end
        jtprint("MSG received! "..senderName.." rolls "..roll)
    end
end

local rollReporter = function(success)
    if (success and not aura_env.config.enableReportWhenSuccess) or not aura_env.config.enableReport then
        return
    end

    local roll = math.random(1, 100)
    local msg = tostring(roll)

    if JTDebug then
        DevTools_Dump(parryLogs)
        DevTools_Dump(top5SwingTakenList)
    end

    local prefix = "JTEPARRYKILLER"

    local channel = getChannel()

    if JTDebug then
        channel = "GUILD" -- test in GUILD
    end

    C_ChatInfo.SendAddonMessage(prefix, msg, channel,nil)
end

local reportKiller = function()
    if not next(killerReporter) then
        return
    end

    local finalReporter
    for k, v in pairs(killerReporter) do
        if not finalReporter then
            finalReporter = killerReporter[k]
        else
            if v.roll > finalReporter.roll then
                finalReporter = killerReporter[k]
            end
        end
    end

    -- ==== Roll(33) 赢了我来说几句 ====
    -- -6.1s AAAAAA 的 攻击 招架了
    -- -3s BBBBBB 的 影袭 招架了
    -- 战斗开始后2:15秒 CCCCCC 死了
    -- --------------------------
    -- -6.1s AAAAAA 的 攻击 招架了
    -- -3s BBBBBB 的 影袭 招架了
    -- 战斗开始后2:15秒 CCCCCC 死了
    -- --------------------------
    -- 坦克阵亡前 6秒 无人打出招架
    -- 战斗开始后2:15秒 CCCCCC 死了
    -- ====== [JT让我看看WA] ======

    local topLine = "==== Roll("..(finalReporter and finalReporter.roll or "?")..") 赢了我来说几句 ===="
    local bottomLine = "==== "..ONLY_TEXT.."===="

    local reportContent = {}
    if #unitDeadList > 0 then
        table.insert(reportContent, topLine)
        for i, v in ipairs(unitDeadList) do
            -- 把v.deadTime换成 2:15 这种格式
            local strTime = ""
            if (v.deadTime <= 60) then
                strTime = format("00:%0.2d", v.deadTime)
            elseif (v.deadTime > 60) then
                strTime = format("%d:%0.2d", v.deadTime / 60, v.deadTime % 60)
            end

            if #v.parryLogs > 0 then
                for j, p in ipairs(v.parryLogs) do
                    local timeDiff = math.floor(p.beforeDeadTime * 100) / 100
                    local spellLink = GetSpellLink(p.spell) or "未知技能"
                    local parryStr = p.parry and "招架" or "未招架"
                    table.insert(reportContent, timeDiff.."s "..p.name..(p.isAPet and "("..p.petOwnerName..")" or "").." 的 "..spellLink.." "..parryStr.."了")
                end

                local deadTimeStr = "战斗开始后>"..strTime.."<秒"
                table.insert(reportContent, deadTimeStr.." "..v.name.." 死了")
                if i < #unitDeadList then
                    table.insert(reportContent, "----------------")
                end
            else
                table.insert(reportContent, ">"..strTime.."<秒 坦克 "..v.name.." 阵亡前 "..saveParryLogTime.." 秒 无人打出招架")
            end
        end
        table.insert(reportContent, bottomLine)
    end

    if JTDebug then
        DevTools_Dump(reportContent)
    end

    if finalReporter then
        local sender = finalReporter.sender and (strsplit("-", finalReporter.sender) and strsplit("-", finalReporter.sender) or finalReporter.sender) or nil
        -- local sender = Ambiguate(finalReporter.sender,"all")
        if sender == myName and aura_env.config.enableReport then
            sendMsgToRaidOrGroup(reportContent, sendMsgInterval)
            return
        else
            jtprint("Debug : On. send to GUILD")
            --sendMsgToRaidOrGroup(reportContent, sendMsgInterval)
            return
        end
    end
end

-- 通过CHAT_MSG_ADDON接收消息 通讯roll点，看这次谁来通报

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "ENCOUNTER_START" then
        local encounterID = ...
        thisEncounterId = encounterID
        isInValidEncounter = isValidBoss()
        encounterStartTime = time()
        resetData()
        initValidNpcIds()
    elseif event == "ENCOUNTER_END" or event == "JT_E_PARRYLOG_REPORT" then
        local success = select(5, ...)
        rollReporter(success)
        isInValidEncounter = false
        C_Timer.After(3, function()
            WeakAuras.ScanEvents("JT_PARRYKILLER_BADGUY")
        end)
    elseif event == "JT_PARRYKILLER_BADGUY" then
        reportKiller()
    elseif event == "CHAT_MSG_ADDON" then
        receiveMessage(...)
    elseif event == "JT_D_PARRYLOG" then
        ToggleDebug()

    -- -- JT FAKE EVENT START
    -- elseif event == "JT_FAKE_EVENT" then
    --     OnJTFakeEvent(event, ...)
    -- -- JT FAKE EVENT END

    end
end