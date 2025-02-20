--版本信息
local version = 250216

--solo header
local AURA_ICON = 237554
local AURA_NAME = "JT找背WA"
local SMALL_ICON = "|T"..(AURA_ICON or 135451)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug : "..(text or "nil"))
    end
end

local isEncounter = false
local encounterID = 0
local parryCountLogs = {}

local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(Slapper) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))

    --test data
    if JTDebug then
        parryCountLogs = {
            ["找背-法尔班克斯"] = {
                swingTaken = 0,
                block = 0,
                name = "找背-法尔班克斯",
                parry = 1
            },
            Jettie = {
                swingTaken = 44,
                block = 1,
                name = "Jettie",
                parry = 0
            },
            ["Jed"] = {
                name = "Jed",
                parry = 0,
                block = 5,
                swingTaken = 35,

            },
            ["打脸-海加尔"] = {
                name = "打脸-海加尔",
                parry = 0,
                block = 3,
                swingTaken = 33,

            },
        }
    end
end

--字符串拆分处理
local function splitString(str, separator)
    local index = string.find(str, separator)
    if index then
        local part1 = string.sub(str, 1, index - 1)
        local part2 = string.sub(str, index + 1)
        return part1, part2
    else
        return
    end
end

local isValidBoss = function()
    
    if WeakAuras.CurrentEncounter then
        encounterID = WeakAuras.CurrentEncounter.id
    else
        return false
    end
    
    local ignoreList = {
        [749] = true, -- 科隆加恩
    }
    return not ignoreList[encounterID]
end


local initPlayer = function(playerName)
    local initData = {
        name = playerName,
        parry = 0,
        block = 0,
        swingTaken = 0,
    }
    parryCountLogs[playerName] = initData
end

local OnCLEUF = function(...)
    if not isEncounter then return end
    
    local _, subevent, _, _, sourceName, _, _, _, destName, _, _, arg12, _, _, arg15, arg16, _, _, arg19 = ...
    if UnitInRaid(sourceName) or UnitInParty(sourceName) then
        if subevent == "SWING_MISSED" then
            if arg12 == "PARRY" then
                if not parryCountLogs[sourceName] then
                    initPlayer(sourceName)
                    parryCountLogs[sourceName].parry = 1
                else
                    parryCountLogs[sourceName].parry = parryCountLogs[sourceName].parry + 1
                end
            end
        elseif subevent == "SPELL_MISSED" then
            if arg15 == "PARRY" then
                if not parryCountLogs[sourceName] then
                    initPlayer(sourceName)
                    parryCountLogs[sourceName].parry = 1
                else
                    parryCountLogs[sourceName].parry = parryCountLogs[sourceName].parry + 1
                end
            end
        elseif subevent == "SWING_DAMAGE" then
            local blocked = arg16
            if blocked then
                if not parryCountLogs[sourceName] then
                    initPlayer(sourceName)
                    parryCountLogs[sourceName].block = 1
                else
                    parryCountLogs[sourceName].block = parryCountLogs[sourceName].block + 1
                end
            end
        elseif subevent == "SPELL_DAMAGE" then
            local blocked = arg19
            if blocked then
                if not parryCountLogs[sourceName] then
                    initPlayer(sourceName)
                    parryCountLogs[sourceName].block = 1
                else
                    parryCountLogs[sourceName].block = parryCountLogs[sourceName].block + 1
                end
            end
        end
    else
        if UnitInRaid(destName) or UnitInParty(destName) then
            
            if subevent == "SWING_MISSED" or subevent == "SWING_DAMAGE" then
                if not parryCountLogs[destName] then
                    initPlayer(destName)
                    parryCountLogs[destName].swingTaken = 1
                else
                    parryCountLogs[destName].swingTaken = parryCountLogs[destName].swingTaken + 1
                end
            end
        end
    end
    return
end

local TANK_NUMBER = {
    --冬拥湖
    [772] = 2, --土
    [774] = 2, --风
    [776] = 2, --火
    [885] = 2, --水

    --NAXX
    [1107] = 2, --阿奴布雷坎
    [1110] = 3, --黑女巫法琳娜
    [1116] = 1, --迈克斯纳
    [1117] = 3, --瘟疫使者诺斯 
    [1112] = 1, --肮脏的希尔盖
    [1115] = 1, --洛欧塞布
    [1113] = 3, --教官拉苏维奥斯
    [1109] = 3, --收割者戈提克
    [1121] = 3, --天启四骑士
    [1118] = 3, --帕奇维克
    [1111] = 3, --格罗布鲁斯
    [1108] = 3, --格拉斯
    [1120] = 2, --塔迪乌斯
    [1119] = 1, --萨菲隆
    [1114] = 3, --克尔苏加德

    --黑曜石
    [736] = 2, --塔尼布隆
    [738] = 2, --沙德隆
    [740] = 2, --维斯匹龙
    [742] = 3, --萨塔里奥

    --永恒之眼
    [734] = 2, --玛里苟斯

    --奥杜尔
    [744] = 1, --烈焰巨兽
    [745] = 1, --掌炉者伊格尼斯
    [746] = 3, --锋鳞
    [747] = 2, --XT-002拆解者
    [748] = 2, --钢铁议会
    [749] = 2, --科隆加恩
    [750] = 3, --欧尔莉亚
    [753] = 2, --弗蕾雅
    [751] = 2, --霍迪尔
    [754] = 1, --米米尔隆
    [752] = 2, --托里姆
    [755] = 2, --维扎克斯将军
    [756] = 2, --尤格-萨隆
    [757] = 2, --观察者奥尔加隆

    --TOC
    [629] = 2, --诺森德猛兽
    [633] = 2, --加拉克苏斯达王
    [637] = 3, --阵营冠军
    [641] = 2, --瓦格里双子
    [645] = 3, --阿奴布雷坎

    --ICC
    [845] = 3, --玛洛加尔领主
    [846] = 3, --亡语者女士
    [847] = 2, --炮舰战
    [848] = 2, --死亡使者萨鲁法尔
    [849] = 2, --烂肠
    [850] = 2, --腐面
    [851] = 2, --普崔塞德教授
    [852] = 2, --鲜血议会
    [853] = 3, --兰娜瑟尔女王
    [854] = 2, --踏梦者瓦莉瑟瑞娅
    [855] = 2, --辛达苟萨
    [856] = 2, --巫妖王

    --红玉圣殿
    [890] = 2, --战争之子巴尔萨鲁斯
    [893] = 2, --萨瑞瑟里安将军
    [891] = 2, --赛维亚娜·怒火
    [887] = 3, --海里昂
}

local getTheKingOfFaceSlapper = function()
    if not next(parryCountLogs) then return end

    local tankNumber = (TANK_NUMBER[encounterID] or (IsInRaid() and 3 or 1))
    jtprint("Sorted. And tankNumber= "..tankNumber)

    --先去掉坦克，可能是1-3个坦克，再排名
    local topList = {}

    for i = 1 , tankNumber do
        topList[i] = {
            name = tostring(i),
            swingTaken = 0,
        }
    end

    local totalSwingTaken = 0
    for _, v in pairs(parryCountLogs) do
        totalSwingTaken = totalSwingTaken + v.swingTaken
        for i = 1, tankNumber do
            if v.swingTaken >= topList[i].swingTaken then
                for j = tankNumber, i, -1 do
                    if j > i then
                        topList[j] = topList[j - 1]
                    else
                        topList[j] = {
                            name = v.name,
                            swingTaken = v.swingTaken,
                        }
                    end
                end
                break
            end
        end
    end

    for i = 1 , tankNumber do
        if topList[i].swingTaken > ( totalSwingTaken * 0.2 ) then
            jtprint("removeingTank .. top "..i.." [ "..topList[i].name.." ].swingTaken = "..parryCountLogs[topList[i].name].swingTaken.." totalSwingTaken= "..totalSwingTaken)
            parryCountLogs[topList[i].name] = nil
        end
    end 

    --找出我心中的打脸王
    local slapperKing
    for k, v in pairs(parryCountLogs) do
        if (v.parry + v.block) >= 1 then
            if not slapperKing then
                slapperKing = parryCountLogs[k]
            else
                if (v.parry + v.block) > (slapperKing.parry + slapperKing.block) then
                    slapperKing = parryCountLogs[k]
                end
            end
        end
    end
    return slapperKing
end

local voteSlapper = function(roll)

    if JTDebug then
        DevTools_Dump(parryCountLogs)
    end

    local winner = getTheKingOfFaceSlapper()
    if not winner then return end

    local prefix = "JTEDALIANWANG"

    -- 名字:parry次数-block次数-总次数#发言ROLL点
    -- Jettie:30-60-90#77 strsplit(":","Jettie:30:60:90:77")

    roll = roll or math.random(100) -- test for nil

    local msg = winner.name..":"..winner.parry..":"..winner.block..":"..(winner.parry + winner.block)..":"..roll

    local channel
    if IsInRaid() and not IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        channel = "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        channel = "INSTANCE_CHAT"
    elseif IsInGroup() and IsInGroup(LE_PARTY_CATEGORY_HOME) then
        channel = "PARTY"
    end

    --发送消息
    --C_ChatInfo.SendAddonMessage("JTEDALIANWANG", "Jettie:30-60-90#77", "GUILD",nil)

    if JTDebug then
        channel = "GUILD" -- test in GUILD
    end

    if channel then
        C_ChatInfo.SendAddonMessage(prefix, msg, channel,nil)
    end
    jtprint("Sended in "..(channel or "nil").." prefix= "..prefix.." msg= "..msg)
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTEDALIANWANG"] = true,
    }
    for k, _ in pairs(prefixList) do
        C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

local thePool = {}

local transMessage = function(textStr)
    local name, parry, block, total, roll = strsplit(":", textStr)
    return name, parry, block, total, roll
end

local receiveMessage = function(...)
    local prefix, text, _, sender = ...
    if prefix == "JTEDALIANWANG" then
        local name, parry, block, total, roll = transMessage(text)
        if not thePool[name] then
            thePool[name] = {
                name = name,
                vote = 1,
                parry = parry,
                block = block,
                total = total,
                roll = roll,
                sender = sender,
            }
        else
            thePool[name].vote = thePool[name].vote + 1
            thePool[name].parry = parry > thePool[name].parry and parry or thePool[name].parry
            thePool[name].block = block > thePool[name].block and block or thePool[name].block
            thePool[name].total = total > thePool[name].total and total or thePool[name].total
            thePool[name].roll = roll > thePool[name].roll and roll or thePool[name].roll
            thePool[name].sender = roll > thePool[name].roll and sender or thePool[name].sender

        end
        jtprint("MSG received! "..name.." vote+1 now: "..thePool[name].vote.." counts.")
    end
end

local sayMyName = function()
    if not next(thePool) then return end
    local finalSlapper
    for k, v in pairs(thePool) do
        if not finalSlapper then
            finalSlapper = thePool[k]
        else
            if v.total > finalSlapper.total then
                finalSlapper = thePool[k]
            end
        end
    end
    if finalSlapper then
        local sender = splitString(finalSlapper.sender,"-") and splitString(finalSlapper.sender,"-") or finalSlapper.sender

        if sender == UnitName("player") then
            --[JT找背WA] Roll(99) 我来宣布：这次战斗中【Jetank】以10招架20格挡总计 30 次打脸，荣获【打脸王】的称号！
            local mySpeech = "[JT找背WA] Roll("..finalSlapper.roll..") 我来宣布：经过"..finalSlapper.vote.."人投票，这次战斗中【"..finalSlapper.name.."】以"..finalSlapper.parry.."招架"..finalSlapper.block.."格挡总计 "..finalSlapper.total.." 次打脸，荣获【打脸王】的称号！"

            local channel
            if IsInRaid() and not IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
                channel = "RAID"
            elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                channel = "INSTANCE_CHAT"
            elseif IsInGroup() and IsInGroup(LE_PARTY_CATEGORY_HOME) then
                channel = "PARTY"
            end

            if JTDebug then
                channel = "GUILD" -- test in GUILD
            end

            if channel then
                SendChatMessage(mySpeech,channel,nil,nil)
            end
        end
    end
end

local initAllData = function()
    parryCountLogs = {}
    thePool = {}
    print(HEADER_TEXT.."【打脸王】竞赛开始了")
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(CombatLogGetCurrentEventInfo())
    elseif event == "JT_RESETSLAPPER" then
        isEncounter = isValidBoss()
        initAllData()
    elseif event == "JT_VOTESLAPPER" then
        isEncounter = isValidBoss() --尝试停止记录，成功失败无影响
        local roll = ...
        voteSlapper(roll)
        C_Timer.After(3, function()
                WeakAuras.ScanEvents("JT_SAYMYNAME")
        end)
    elseif event == "JT_SAYMYNAME" then
        sayMyName()
    elseif event == "CHAT_MSG_ADDON" then
        receiveMessage(...)
    elseif event == "JT_D_SLAPPER" then
        ToggleDebug()
    end
end

