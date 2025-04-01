--版本信息
local version = 250331
local soundPack = "TTS"

--author and header
local AURA_ICON = 132351
local AURA_NAME = "JT我从不记仇WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local HEADER_SHORT = SMALL_ICON.."[|CFF8FFFA2凸|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "
local ONLY_TEXT_SHORT = "[凸] "

local INITIALIZED = HEADER_TEXT.."- 是仇是怨还是爱 你说了算 - 作者:|R "..AUTHOR
print(INITIALIZED)

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

local myName = UnitName("player")
local myGUID = UnitGUID("player")
local realmName = GetRealmName()

local dataByFriendName = {}
local dataByGuildName = {}

aura_env.saved = aura_env.saved or {}
aura_env.saved[realmName] = aura_env.saved[realmName] or {}

local db = aura_env.saved[realmName]
db.friendList = db.friendList or {}

local dataFriendList = db.friendList
-- DevTools_Dump(dataFriendList)
local buildDearFriends = function()
    for i, data in ipairs(db.friendList) do
        if data.name then
            dataByFriendName[data.name] = data
            dataByFriendName[data.name].index = i
        end
        if data.guild then
            if not dataByGuildName[data.guild] then
                dataByGuildName[data.guild] = {}
            end
            dataByGuildName[data.guild][data.name] = data
            dataByGuildName[data.guild][data.name].index = i
        end
    end
end
buildDearFriends()

-- 降低GroupRossterUpdate频率
local lastNumGroupMembers = 0
db.lastGroupRosterUpdate = db.lastGroupRosterUpdate or 0
local groupRosterUpdateInterval = 300


-- 报过一次就不报了，每次离队重置
db.blessed = db.blessed or {}
local blessed = db.blessed
db.blessedGuildMember = db.blessedGuildMember or {}
local blessedGuildMember = db.blessedGuildMember
db.voiceAnounced = db.voiceAnounced or {}
local voiceAnounced = db.voiceAnounced

-- 短时间内连续遇到，就先只报1个
db.lastBlessingTime = db.lastBlessingTime or 0
local intervalTimeConfig = {
    [1] = 600, -- 10分钟
    [2] = 1200, -- 20分钟
    [3] = 1800, -- 30分钟
}

local intervalTime = intervalTimeConfig[aura_env.config.intervalTime] or 0

local DATE_FORMAT = "%Y年%m月%d日"

-- 获取频道名
local getChannel = function()
    local channel
    if IsInRaid() and not IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        channel = "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        channel = "INSTANCE_CHAT"
    elseif IsInGroup() and IsInGroup(LE_PARTY_CATEGORY_HOME) then
        channel = "PARTY"
    end
    return channel
end

-- Link 处理
local makeLink = function(name)
    local link = " |cffFFFF00|Hgarrmission:" .. "JTIRYSOB:" ..name.."|h[立即控诉>" .. name .. "<]|h|r"
    return link
end

hooksecurefunc("SetItemRef", function(link, _, button)
    local _, arg2, arg3 = strsplit(":", link)
    if arg2 ~= "JTIRYSOB" then return end
    local name = arg3
    if name then
        if dataByFriendName[name] and not blessed[name] then
            local channel = getChannel()

            local shortName = name
            local data = dataByFriendName[shortName]
            local classId = data.classId
            local guild = data.guild
            local blessingWords = data.blessingWords
            local theDate = data.theDate

            local theName = shortName
            if channel then

                local message1 = ONLY_TEXT..(guild and ("<"..guild.."> 公会的 ") or "")..""..(classId and GetClassInfo(classId) or "").." "..(theName or "").." 在 "..(theDate or "").." 产生矛盾"
                local message2 = ONLY_TEXT_SHORT.."说你呢 "..(theName or "").." : "..(blessingWords or "")

                SendChatMessage(message1, channel, nil, nil)
                SendChatMessage(message2, channel, nil, nil)
                blessed[shortName] = aura_env.config.enableOnlyOnce

            end
        end
    end
end)

-- 检测同队的人
local OnGroupRosterUpdate = function(event,...)

    if WeakAuras.IsOptionsOpen() then return end
    if IsInGroup() then
        local now = time()
        if db.lastGroupRosterUpdate + groupRosterUpdateInterval > now then
            -- print("|CFF8FFFA2小于频率限制 |R"..groupRosterUpdateInterval)
            -- return
        end

        local numGroupMembers = IsInGroup() and GetNumGroupMembers() or (JTDebug and 1 or 0)
        if numGroupMembers == lastNumGroupMembers then
            -- print("|CFF8FFFA2人数没变，不检查|R "..(now or ""))
            return
        else
            print("|CFFFF53A2人数变了，检查|R "..(now or ""))
            lastNumGroupMembers = numGroupMembers
        end

        for i = 1, numGroupMembers do
            local channel = getChannel()
            local name = GetRaidRosterInfo(i)
            local shortName = name and Ambiguate(name,"all") or (name or "")
            if shortName then
                local guildName = name and GetGuildInfo(name) or nil
                local trimmedGuildName = string.gsub(guildName or "", "%s+", "")
                if not (blessed[shortName] or blessedGuildMember[shortName]) then
                    local timeRemaining = db.lastBlessingTime + intervalTime - now
                    local timeRemainingFloored = math.floor(timeRemaining)

                    if dataByFriendName[shortName] then
                        local data = dataByFriendName[shortName]
                        local classId = data.classId
                        local guild = data.guild
                        local blessingWords = data.blessingWords
                        local theDate = data.theDate

                        local theName = shortName

                        if not aura_env.config.enableAll then
                            print(HEADER_TEXT.."检测到仇人! WA自定义选项中的总开关未开启，不会通报")
                            return
                        end
                        if channel then

                            local message1 = ONLY_TEXT..(guild and ("<"..guild.."> 公会的 ") or "")..""..(classId and GetClassInfo(classId) or "").." "..(theName or "").." 在 "..(theDate or "").." 产生矛盾"
                            local message2 = ONLY_TEXT_SHORT.."说你呢 "..(theName or "").." : "..(blessingWords or "")

                            if timeRemaining < 0 then
                                SendChatMessage(message1, channel, nil, nil)
                                SendChatMessage(message2, channel, nil, nil)
                                blessed[shortName] = aura_env.config.enableOnlyOnce

                                db.lastGroupRosterUpdate = now
                                db.lastBlessingTime = now
                            else
                                local link = makeLink(name)
                                local messagePrint = "[("..timeRemainingFloored.."秒)防刷屏]检测还有仇人! "..(guild and ("<"..guild.."> 公会的 ") or "")..""..(classId and GetClassInfo(classId) or "").." "..(theName or "")..link
                                print(HEADER_TEXT..messagePrint)
                            end
                            
                            if not voiceAnounced[shortName] then
                                local ttsText = "冤家路窄 "..shortName.." 跟你在同一个队伍中"
                                local ttsSpeed = 0
                                C_VoiceChat.SpeakText(0, (ttsText or ""), 0, (ttsSpeed or 0), 100)
                                voiceAnounced[shortName] = true
                            end
                        end
                    elseif aura_env.config.enableSameGuild and (dataByGuildName[guildName] or dataByGuildName[trimmedGuildName]) then
                        local data = dataByGuildName[guildName] or dataByGuildName[trimmedGuildName]
                        for member, memberData in pairs(data) do
                            local classId = memberData.classId
                            local guild = memberData.guild
                            local blessingWords = memberData.blessingWords
                            local theDate = memberData.theDate

                            local theName = member

                            if not aura_env.config.enableAll then
                                print(HEADER_TEXT.."检测到仇人! WA自定义选项中的总开关未开启，不会通报")
                                return
                            end


                            if channel then
                                local message1 = ONLY_TEXT..(guild and ("<"..guild.."> 你们公会的 ") or "")..""..(classId and GetClassInfo(classId) or "").." "..(theName or "").." 在 "..(theDate or "").." 产生矛盾"
                                local message2 = ONLY_TEXT_SHORT.."说你呢 "..(theName or "").." : "..(blessingWords or "")

                                if timeRemaining < 0 then
                                    SendChatMessage(message1, channel, nil, nil)
                                    SendChatMessage(message2, channel, nil, nil)
                                    blessedGuildMember[shortName] = true
                                else
                                    local link = makeLink(theName)
                                    local messagePrint = "[("..timeRemainingFloored.."秒)防刷屏]检测到公会内仇人! "..(guild and ("<"..guild.."> 公会的 ") or "")..""..(classId and GetClassInfo(classId) or "").." "..(theName or "")..link
                                    print(HEADER_TEXT..messagePrint)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        print(HEADER_TEXT.."不在队伍中 通报间隔重置")
        blessed = {}
        blessedGuildMember = {}
        voiceAnounced = {}
        lastNumGroupMembers = 0

        db.lastBlessingTime = 0
        db.lastGroupRosterUpdate = 0
    end
end

local cmdMakeFriend = {
    ["记仇"] = true,
    ["我记下了"] = true,
    ["我记仇"] = true,
    ["我不记仇"] = true,
    ["我要记仇"] = true,
    ["我要记下仇"] = true,
    ["我要记仇人"] = true,
    ["我要记下仇人"] = true,
    ["我记住了"] = true,
    ["我记仇了"] = true,
    ["我记住你了"] = true,
    ["交朋友"] = true,
    ["加个好友"] = true,
}

local cmdShowFriends = {
    ["我的仇人"] = true,
    ["查看我的仇人"] = true,
    ["查看仇人"] = true,
    ["查看仇人列表"] = true,
    ["我的朋友"] = true,
}

local cmdForgive = {
    ["原谅"] = true,
    ["我原谅了"] = true,
    ["忘记仇人"] = true,
    ["我原谅你了"] = true,
    ["我不记仇人"] = true,
    ["我原谅你"] = true,
}

local cmdHelp = {
    ["我从不记仇"] = true,
    ["怎么记仇"] = true,
    ["彩笔"] = true,
    ["菜比"] = true,
    ["有病"] = true,
}

local cmdForgiveAll = {
    ["原谅全部"] = true,
    ["全部原谅"] = true,
    ["全部忘记"] = true,
    ["忘记一切"] = true,
    ["大赦天下"] = true,
    ["朕免你死罪"] = true,
    ["原谅全世界"] = true,
}

local helpMakeFriend = function()
    print(HEADER_TEXT.."记录仇人 和 祝福语 下次组队遇到|CFFFFF569本人|R或者|CFF1785D1同公会|R的就会自动发言祝福它")
    print(HEADER_SHORT.."命令格式：直接在 WoW 聊天框 |CFFFFFFFF/s/p/ra|R 频道(|CFFFFFFFF白字/小队/团队|R)输入即可")
    print(HEADER_SHORT.."(新增) - 我要记仇 选中目标后说 |CFFFF53A2记仇|R 即可")
    print(HEADER_SHORT.."|CFFFF53A2记仇|R |CFFFFF569玩家名字|R-|CFF1785D1工会名字|R |CFFFFFFFF我要吐槽的文字内容")
    print(HEADER_SHORT.."(查看) - 查看我的仇人命令")
    print(HEADER_SHORT.."|CFFFF53A2我的仇人|R")
    print(HEADER_SHORT.."(移除) - 原谅我的仇人 来放他一马")
    print(HEADER_SHORT.."|CFFFF53A2原谅|R |CFFFFF569玩家名字|R")
end

local splitNameAndGuild = function(nameAndGuild)
    local separator = "-"
    local separatorLen = strlen(separator)
    local index = strfind(nameAndGuild, separator)
    if index then
        return nameAndGuild:sub(1, index - 1), nameAndGuild:sub(index + separatorLen)
    else
        local atSeparator = "@"
        local atSeparatorLen = strlen(atSeparator)
        index = strfind(nameAndGuild, atSeparator)
        if index then
            return nameAndGuild:sub(1, index - 1), nameAndGuild:sub(index + atSeparatorLen)
        else
            local fullWidthSeparator = "－"
            local fullWidthSeparatorLen = strlen(fullWidthSeparator)
            index = strfind(nameAndGuild, fullWidthSeparator)
            if index then
                return nameAndGuild:sub(1, index - 1), nameAndGuild:sub(index + fullWidthSeparatorLen)
            else
                local fullWidthAtSeparator = "＠"
                local fullWidthAtSeparatorLen = strlen(fullWidthAtSeparator)
                index = strfind(nameAndGuild, fullWidthAtSeparator)
                if index then
                    return nameAndGuild:sub(1, index - 1), nameAndGuild:sub(index + fullWidthAtSeparatorLen)
                else
                    return nameAndGuild, nil
                end
            end
        end
    end
end

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unitName, classId)
    if not unitName then return "" end
    if not classId then return unitName end
    local classStr = select(2,GetClassInfo(classId))
    if classStr then
        local classData = (RAID_CLASS_COLORS)[classStr]
        local coloredName = ("|c%s%s|r"):format(classData.colorStr, unitName)
        return coloredName
    elseif UnitExists(unitName) then
        local name = UnitName(unitName)
        local _, class = UnitClass(unitName)
        if not class then
            return name
        else
            local classData = (RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unitName
    end
end

local makeFriend = function(args)
    local name, guild, classId, nameAndGuild, blessWords
    if not args or args == "" then
        if UnitExists("target") then
            if UnitIsPlayer("target") then
                name = UnitName("target")
                guild = GetGuildInfo("target") or nil
                classId = select(3, UnitClass("target"))
            else
                print(HEADER_TEXT.."你选择的目标不是玩家 不能标记仇人")
                return
            end
        else
            helpMakeFriend()
            return
        end
    else
        nameAndGuild, blessWords = args:match("^(%S+)%s*(.-)$")
        name, guild = splitNameAndGuild(nameAndGuild)
    end

    local thisMF
    if name then
        local nameStr = string.gsub(name, '[0-9]', '')
        if nameStr ~= name then
            print(HEADER_TEXT.."名字不对，WoW的名字里没有数字! ")
            print(HEADER_SHORT.."命令格式：直接在 WoW 聊天框 |CFFFFFFFF/s/p/ra|R 频道(|CFFFFFFFF白字/小队/团队|R)输入即可")
            print(HEADER_SHORT.."记仇 |CFFFFF569玩家名字|R-|CFF1785D1工会名字|R |CFFFFFFFF我要吐槽的文字内容")
            return
        end
        local thisDate = date(DATE_FORMAT)
        -- 如果没有职业 尝试获取职业
        classId = classId or (UnitExists(name) and select(3, UnitClass(name)) or nil)

        -- 尝试自动获取工会名
        local unitGuild = UnitExists(name) and (GetGuildInfo(name) or nil) or nil
        if unitGuild then
            guild = unitGuild
        end

        thisMF = {
            name = name,
            guild = guild,
            classId = classId,
            blessingWords = (blessWords ~= "") and blessWords or "我忘了发生了啥，但肯定有事，我记住你了",
            theDate = thisDate,
        }

        local channel = getChannel()
        local EULASAYS = ONLY_TEXT..(name and name or "").." 这个仇我记下了!"

        if dataByFriendName[name] then
            -- 已经记过仇了
            local oldDate = dataByFriendName[name]
            dataByFriendName[name] = thisMF
            dataByFriendName[name].index = oldDate.index
            dataByFriendName[name].guild = dataByFriendName[name].guild or oldDate.guild
            dataByFriendName[name].classId = dataByFriendName[name].classId or oldDate.classId

            dataFriendList[oldDate.index] = dataByFriendName[name]

            print(HEADER_TEXT..(classId and classColorName(name, classId) or name)..(guild and " <|CFF1785D1"..guild.."|R>" or "").." 的老故事更新了! 指定没他好果子吃!")
            
            local rememberText = ONLY_TEXT_SHORT..name.." 我跟你说 : "..dataByFriendName[name].blessingWords
            if channel then
                SendChatMessage(rememberText, channel, nil, nil)
                SendChatMessage(EULASAYS, channel, nil, nil)
            end
        else

            dataByFriendName[name] = thisMF
            dataFriendList[#dataFriendList + 1] = dataByFriendName[name]
            print(HEADER_TEXT.."已经将 "..(classId and GetClassInfo(classId) or "").." "..(classId and classColorName(name, classId) or name)..(guild and " <|CFF1785D1"..guild.."|R>" or "").." 记录在案! 下次遇到有他好看的! ")

            local rememberText = ONLY_TEXT_SHORT..name.." 我跟你说 : "..dataByFriendName[name].blessingWords
            if channel then
                SendChatMessage(rememberText, channel, nil, nil)
                SendChatMessage(EULASAYS, channel, nil, nil)
            end
        end

        if thisMF.guild then
            if not dataByGuildName[thisMF.guild] then
                dataByGuildName[thisMF.guild] = {}
            end

            dataByGuildName[thisMF.guild][name] = thisMF
            dataByGuildName[thisMF.guild][name].index = #dataFriendList
        end
    end
end

local showFriends = function(args)
    local friendIndex = tonumber(args)
    if friendIndex then
        if friendIndex > 0 and friendIndex <= #dataFriendList then
            print(HEADER_TEXT.."你选择了第"..friendIndex.."个仇人:")
            local data = dataFriendList[friendIndex]
            local name = data.name
            local guild = data.guild
            local classId = data.classId
            local blessingWords = data.blessingWords
            local theDate = data.theDate

            print(HEADER_SHORT.."|CFFFF53A2#|R|CFFFFFFFF"..friendIndex.."|r. "..(classId and classColorName(name, classId) or name)..(guild and " <|CFF1785D1"..guild.."|R>" or "").." 日期: "..theDate)
            print(HEADER_SHORT.."祝福的话: |CFFFFFFFF"..blessingWords.."|R")
            return
        else
            print(HEADER_TEXT.."你选择的第 |CFFFF53A2#|R|CFFFFFFFF"..friendIndex.."|r 号仇人不存在! ")
            return
        end
    end

    if #dataFriendList == 0 then
        print(HEADER_TEXT.."你还没有记录任何仇人! ")
        print(HEADER_SHORT.."(新增) - 我要记仇")
        print(HEADER_SHORT.."|CFFFF53A2记仇|R |CFFFFF569玩家名字|R-|CFF1785D1工会名字|R |CFFFFFFFF我要吐槽的文字内容")
        return
    end

    print(HEADER_TEXT.."你有以下"..#dataFriendList.."个仇人:")
    for i, data in ipairs(dataFriendList) do
        local name = data.name
        local guild = data.guild
        local classId = data.classId
        local theDate = data.theDate

        print(HEADER_SHORT.."|CFFFF53A2#|R|CFFFFFFFF"..i.."|r. "..(classId and classColorName(name, classId) or name)..(guild and " <|CFF1785D1"..guild.."|R>" or "").." 日期: "..theDate)
    end
    print(HEADER_SHORT.."输入 |CFFFFFFFF我的仇人 序号|r (如: |CFFFFFFFF我的仇人 1|R) 查看对应的祝福语详情")
    print(HEADER_SHORT.."输入 |CFFFF53A2原谅|R |CFFFFF569玩家名字|R 移除对应的记录")

end

local forgiveFriend = function(args)
    local name, guild
    if not args or args == "" then
        if UnitExists("target") then
            if UnitIsPlayer("target") then
                name = UnitName("target")
                guild = GetGuildInfo(name) or nil
            else
                print(HEADER_TEXT.."你选择的目标不是玩家 不能标记仇人")
                return
            end
        else
            print(HEADER_TEXT.."命令格式：直接在 WoW 聊天框 |CFFFFFFFF/s/p/ra|R 频道(|CFFFFFFFF白字/小队/团队|R)输入即可")
            print(HEADER_SHORT.."(移除) - 原谅我的仇人 来放他一马")
            print(HEADER_SHORT.."|CFFFF53A2原谅|R |CFFFFF569玩家名字|R")
            return
        end
    else
        local nameAndGuild = args:match("^(%S+)$")
        name = splitNameAndGuild(nameAndGuild)
    end

    if name then
        local numberName = tonumber(name)
        if numberName then
            if dataFriendList[numberName] then
                local thisName = dataFriendList[numberName].name
                local guild = dataFriendList[numberName].guild
                local classId = dataFriendList[numberName].classId

                --先清理工会记录部分
                if dataByGuildName[dataFriendList[numberName].guild] then
                    dataByGuildName[dataFriendList[numberName].guild][thisName] = nil
                end
                dataByFriendName[thisName] = nil

                local channel = getChannel()
                if channel then
                    SendChatMessage(ONLY_TEXT_SHORT..thisName.." 我原谅你了! ", channel, nil, nil)
                end
                print(HEADER_TEXT.."已经原谅了第 |CFFFF53A2#|R|CFFFFFFFF"..numberName.."|r 号仇人! "..(classId and GetClassInfo(classId) or "").." "..(classId and classColorName(thisName, classId) or thisName)..(guild and " <|CFF1785D1"..guild.."|R>" or ""))
                tremove(dataFriendList, numberName)
                return
            end
        end
        if dataByFriendName[name] then
            local index = dataByFriendName[name].index
            local guild = dataByFriendName[name].guild
            local classId = dataByFriendName[name].classId

            --先清理工会记录部分
            if dataByGuildName[dataByFriendName[name].guild] then
                dataByGuildName[dataByFriendName[name].guild][name] = nil
            end

            --再清理好友记录部分
            local channel = getChannel()
            if channel then
                SendChatMessage(ONLY_TEXT_SHORT..name.." 我原谅你了! ", channel, nil, nil)
            end
            print(HEADER_TEXT.."已经将"..(classId and classColorName(name, classId) or name)..(guild and " <|CFF1785D1"..guild.."|R>" or "").." 的记录删除! ")
            dataByFriendName[name] = nil
            tremove(dataFriendList, index)
        else
            print(HEADER_TEXT.."你还没有记录"..name.."! ")
        end
    else
        print(HEADER_TEXT.."命令格式：直接在 WoW 聊天框 |CFFFFFFFF/s/p/ra|R 频道(|CFFFFFFFF白字/小队/团队|R)输入即可")
        print(HEADER_SHORT.."(移除) - 原谅我的仇人 来放他一马")
        print(HEADER_SHORT.."|CFFFF53A2原谅|R |CFFFFF569玩家名字|R")
    end
end

local forgiveAll = function(args)
    if not args then
        print(HEADER_TEXT.."命令格式：直接在 WoW 聊天框 |CFFFFFFFF/s/p/ra|R 频道(|CFFFFFFFF白字/小队/团队|R)输入即可")
        print(HEADER_SHORT.."(移除全部) - 大赦天下 朕免你死罪")
        print(HEADER_SHORT.."|CFFFF53A2原谅全世界|R")
        return
    end

    local numOfFriends = #dataFriendList or 0
    local text = #dataFriendList == 0 and "你没有任何仇人!" or "你真善，原谅了 "..numOfFriends.." 个人!"

    local channel = getChannel()
    if channel and #dataFriendList > 0 then
        SendChatMessage(ONLY_TEXT..text, channel, nil, nil)
    end
    print(HEADER_TEXT..text)

    dataByFriendName = {}
    dataFriendList = {}

end

local commandHandler = function(text)
    local cleanText = text:trim(" ")
    local cmd, args = cleanText:match("^(%S+)%s*(.-)$")

    -- 命令分发
    if cmdMakeFriend[cmd] then
        -- 记仇 再次记仇可以修改
        makeFriend(args)
    elseif cmdShowFriends[cmd] then
        -- 查看
        showFriends(args)
    elseif cmdForgive[cmd] then
        -- 原谅
        forgiveFriend(args)
    elseif cmdForgiveAll[cmd] then
        -- 原谅全部
        forgiveAll(args)
    elseif cmdHelp[cmd] then
        -- 帮助
        helpMakeFriend()
    end
end

local OnMessageReceived = function(event, ...)
    if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_PARTY" or event =="CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" or event =="CHAT_MSG_RAID" or event =="CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_GUILD" then
        local text, _, _, _, _, _, _, _, _, _, _, guid = ...
        if guid == myGUID then --自己发的
            --本人发的是指令
            return commandHandler(text)
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_PARTY" or event =="CHAT_MSG_PARTY_LEADER" or event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" or event =="CHAT_MSG_RAID" or event =="CHAT_MSG_RAID_LEADER" then
        return OnMessageReceived(event, ...)
    elseif event == "GROUP_ROSTER_UPDATE" or "JT_GROUP_ROSTER_UPDATE" then
        return OnGroupRosterUpdate(event, ...)
    end
end
