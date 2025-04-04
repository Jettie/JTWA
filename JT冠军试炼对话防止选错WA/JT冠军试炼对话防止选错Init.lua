--版本信息
local version = 250325
local soundPack = "TTS"

--author and header
local AURA_ICON = 132351
local AURA_NAME = "JT系列WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "
local HEADER_SHORT = SMALL_ICON.."[|CFF8FFFA2凸|R]|CFF8FFFA2 "
local ONLY_TEXT = "["..AURA_NAME.."] "

local modifiedNpcOption = {
    [35004] = { -- 冠军的试炼 对话防点错
        [94715] = { -- 我准备好了。 (第一个BOSS墨迹选项)
            name = "-= |CFF1785D1等队友跳过|R =-",
            lyric = "|CFFFFFFFF#|R去看海|CFFFFFFFF#|R\n|CFFFFFFFF#|R绕世界流浪|CFFFFFFFF#|R",
            tip = "你第一次打没有跳过选项",
            blockClick = true,
        },
        [94718] = { -- 我准备好了。但是，我倒是愿意不参加这庆典。 (第一个BOSS跳过选项)
            name = "-= 点击跳过入场 =-",
            lyric = "|CFFFFFFFF#|R我害怕你心碎|CFFFFFFFF#|R\n|CFFFFFFFF#|R没人帮你擦眼泪|CFFFFFFFF#|R",
            message = ONLY_TEXT.."防点错 已跳过登场过程",
        },

        -- 使用 94718 选项作为测试
        -- --测试1 只有一个选项
        -- [94718] = { -- 我准备好了。但是，我倒是愿意不参加这庆典。 (第一个BOSS跳过选项)
        --     name = "-= |CFF1785D1等队友跳过|R =-",
        --     lyric = "|CFFFFFFFF#|R去看海|CFFFFFFFF#|R\n|CFFFFFFFF#|R绕世界流浪|CFFFFFFFF#|R",
        --     tip = "你第一次打没有跳过选项",
        --     blockClick = true,
        -- },

        -- --测试2
        -- [94718] = { -- 我准备好了。但是，我倒是愿意不参加这庆典。 (第一个BOSS跳过选项)
        --     name = "-= 点击开始战斗 =-",
        --     lyric = "|CFFFFFFFF#|R别管那是非|CFFFFFFFF#|R\n|CFFFFFFFF#|R只要我们感觉对|CFFFFFFFF#|R",
        --     tip = "注意图腾和队友位置 别ADD!",
        -- },
        -- --测试3
        -- [94718] = { -- 我准备好了。但是，我倒是愿意不参加这庆典。 (第一个BOSS跳过选项)
        --     name = "-= 点击开始战斗 =-",
        --     lyric = "|CFFFFFFFF#|R别离开身边|CFFFFFFFF#|R\n|CFFFFFFFF#|R拥有你|CFFFFFFFF#|R\n|CFFFFFFFF#|R我的世界才能完美|CFFFFFFFF#|R",
        -- },

        [94716] = { -- 我已经为下一个挑战做好了准备。 (第二个BOSS)
            name = "-= 点击开始战斗 =-",
            lyric = "|CFFFFFFFF#|R别管那是非|CFFFFFFFF#|R\n|CFFFFFFFF#|R只要我们感觉对|CFFFFFFFF#|R",
            message = ONLY_TEXT.."已对话开门 大家后退 注意收图腾！",
            tip = "注意图腾和队友位置 别ADD!",
        },
        [94717] = { -- 我准备好了。 (第三个BOSS)
            name = "-= 点击开始战斗 =-",
            lyric = "|CFFFFFFFF#|R别离开身边|CFFFFFFFF#|R\n|CFFFFFFFF#|R拥有你|CFFFFFFFF#|R\n|CFFFFFFFF#|R我的世界才能完美|CFFFFFFFF#|R",
            message = ONLY_TEXT.."已对话 黑骑士即将登场 大家恢复好状态准备迎战！",
        },
    },
    -- [32686] = { --测试 联盟银行出门左转拐角的 托马斯·里约加因
    --     [93870] = {
    --         name = "-= 点击跳过入场 =-",
    --         lyric = "|CFFFFFFFF#|R我害怕你心碎|CFFFFFFFF#|R\n|CFFFFFFFF#|R没人帮你擦眼泪|CFFFFFFFF#|R",
    --     },
    -- },
}

local buildBaseState = function(unitId, optionTable, i, modCount)
    -- 根据提供的 unitId, optionTable, 索引 i 和 modCount 构建基本状态
    local s = optionTable[i]
    local modOption = modifiedNpcOption[unitId]

    s.index = modCount
    s.optionNum = #optionTable
    s.unitId = unitId
    s.modCount = modCount

    -- 检查是否有修改过的选项配置
    local mo = modOption[s.gossipOptionID]
    if mo then
        s.name = mo.name or s.name
        s.renamed = mo.name and true or false
        s.atlas = mo.atlas or "ClassTrial-End-Frame"
        s.width = mo.width or 340
        s.height = mo.height or 200
        s.border = mo.border or false
    end

    -- 设置选项的间距和偏移量
    s.spaceX = 0
    s.spaceY = 10
    s.xOffset = 0
    s.yOffset = 0 - ( (modCount - 1) * (s.height + s.spaceY) ) -20
    return s
end
-- 隐藏所有按钮
local hideAll = function(e, ...)
    if aura_env.btn then
        if next(aura_env.btn) then
            for k, v in pairs(aura_env.btn) do
                if aura_env.btn[k]:IsShown() then
                    aura_env.btn[k]:Hide()
                end
            end
        end
    end
    if e then
        if next(e) then
            for k, _ in pairs(e) do
                e[k].show = false
                e[k].changed = true
            end
            return true
        end
    end
end

local OnFrameShow = function(e, ...)
    local targetGUID = UnitGUID("target")
    hideAll(e, ...)
    if targetGUID then
        local id = select(6, strsplit("-", targetGUID))
        local unitId = tonumber(id)
        if modifiedNpcOption[unitId] then
            local optionTable = C_GossipInfo.GetOptions()
            if next(optionTable) then
                local modCount = 1
                for i = #optionTable, 1, -1 do

                    --[[ 例子
                        flags=0, 
                        gossipOptionID=93489, 
                        name="请让我接受训练。", 
                        status=0, 
                        orderIndex=0, 
                        icon=132058, 
                        selectOptionWhenOnlyOption=false 
                    ]]

                    local stateName = unitId..optionTable[i].gossipOptionID
                    if modifiedNpcOption[unitId][optionTable[i].gossipOptionID] then
                        --针对第一次的双选项额外处理
                        if not (#optionTable >= 2 and optionTable[i].gossipOptionID == 94715) then
                            e[stateName] = {}

                            e[stateName] = buildBaseState(unitId, optionTable, i, modCount)
                            modCount = modCount + 1

                            e[stateName].blockClick = modifiedNpcOption[unitId][optionTable[i].gossipOptionID].blockClick
                            e[stateName].lyric = modifiedNpcOption[unitId][optionTable[i].gossipOptionID].lyric
                            e[stateName].message = modifiedNpcOption[unitId][optionTable[i].gossipOptionID].message
                            e[stateName].tip = modifiedNpcOption[unitId][optionTable[i].gossipOptionID].tip

                            e[stateName].show = true
                            e[stateName].changed = true

                            if optionTable[i].gossipOptionID == 94716 then
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

                                -- 发送频道名和消息
                                local c = getChannel()

                                local msg = modifiedNpcOption[unitId][optionTable[i].gossipOptionID].message
                                if c and msg then
                                    SendChatMessage(msg, c, nil, nil)
                                    SendChatMessage(msg, "SAY", nil, nil)
                                end
                            end
                        end
                    end
                end
            end
            return true
        end
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "GOSSIP_SHOW" then
        return OnFrameShow(e, ...)
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        return hideAll(e, ...)
    end
end

