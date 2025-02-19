--版本信息
local version = 250217

local modifiedNpcOption = {
    [34885] = { --测试 TOC帐篷里的卡普萨里斯夫人
        [94637] = { -- 我想要看看你卖的货物。
            atlas = "Mobile-Blacksmithing",
            width = 100,
            height = 100,
        },
    },
    [32691] = { --测试 达拉然监狱路口的 大法师范尔希·古德宾格
        [93870] = { -- 我想要看看你卖的货物。
            atlas = "communities-icon-invitemail",
            width = 100,
            height = 100,
        },
        [93871] = { -- 我想要看看你卖的货物。
            atlas = "Mobile-TreasureIcon",
            width = 100,
            height = 100,
        },
        [93872] = { -- 我想要看看你卖的货物。
            atlas = "Mobile-BonusIcon",
            width = 100,
            height = 100,
        },
    },
    [35646] = { --虫洞
        [94236] = { -- 风暴峭壁
            atlas = "warboard-zone-wotlk-StormPeaks",
            width = 134,
            height = 61,
            border = true,
        },
        [94237] = { -- 冰冠冰川
            atlas = "warboard-zone-wotlk-Icecrown",
            width = 134,
            height = 61,
            border = true,
        },
        [94238] = { -- 索拉查盆地
            atlas = "warboard-zone-wotlk-SholazarBasin",
            width = 134,
            height = 61,
            border = true,
        },
        [94239] = { -- 嚎风峡湾
            atlas = "warboard-zone-wotlk-HowlingFjord",
            width = 134,
            height = 61,
            border = true,
        },
        [94240] = { -- 北风苔原
            atlas = "warboard-zone-wotlk-BoreanTundra",
            width = 134,
            height = 61,
            border = true,
        },
        --下面两个是猜的？ID
        [94241] = { -- ？
            atlas = "_GarrMissionLocation-Underground-Back",
            width = 134,
            height = 61,
            border = true,
        },
        [94235] = { -- ？
            atlas = "_GarrMissionLocation-Underground-Back",
            width = 134,
            height = 61,
            border = true,
        },
    },
    [35642] = { --基维斯
        [94233] = { -- 让我看看你的货物。
            atlas = "Mobile-Blacksmithing",
            width = 100,
            height = 100,
            name = "修理",
        },
        [94234] = { -- 我想要查看一下我的储物箱。
            atlas = "Mobile-BonusIcon",
            width = 100,
            height = 100,
            name = "银行",
        },
    },
    [33238] = { --银色侍从
        --联盟的选项应该不同,需要更新选项ID
        [94690] = { -- 访问邮箱。
            atlas = "communities-icon-invitemail",
            width = 100,
            height = 100,
            name = "邮箱",
        },
        [94691] = { -- 拜访一名商人。
            atlas = "Mobile-TreasureIcon",
            width = 100,
            height = 100,
            name = "商店",
        },
        [94692] = { -- 前往一家银行。
            atlas = "Mobile-BonusIcon",
            width = 100,
            height = 100,
            name = "银行",
        },
    },
    [33239] = { --银色小步兵
        -- [94685] -- 雷霆崖冠军的旗帜
        -- [94686] -- 银月城冠军的旗帜
        -- [94687] -- 奥格瑞玛冠军的旗帜
        -- [94688] -- 被遗忘者冠军的旗帜
        -- [94689] -- 暗矛冠军的旗帜

        [94690] = { -- 访问邮箱。
            atlas = "communities-icon-invitemail",
            width = 100,
            height = 100,
            name = "邮箱",
        },
        [94691] = { -- 拜访一名商人。
            atlas = "Mobile-TreasureIcon",
            width = 100,
            height = 100,
            name = "商店",
        },
        [94692] = { -- 前往一家银行。
            atlas = "Mobile-BonusIcon",
            width = 100,
            height = 100,
            name = "银行",
        },

        --测试 当小步兵进入CD时
        -- [94685] = { -- 访问邮箱。
        --     atlas = "communities-icon-invitemail", --Mobile-QuestIcon
        --     width = 100,
        --     height = 100,
        -- },
        -- [94686] = { -- 拜访一名商人。
        --     atlas = "Mobile-TreasureIcon",
        --     width = 100,
        --     height = 100,
        -- },
        -- [94687] = { -- 前往一家银行。
        --     atlas = "Mobile-BonusIcon",
        --     width = 100,
        --     height = 100,
        -- },
    },
}

local buildBaseState = function(unitId, optionTable, i, modCount)
    local s = optionTable[i]
    local modOption = modifiedNpcOption[unitId]

    s.index = modCount
    s.optionNum = #optionTable
    s.unitId = unitId
    s.modCount = modCount

    local mo = modOption[s.gossipOptionID]
    if mo then
        s.name = mo.name or s.name
        s.renamed = mo.name and true or false
        s.atlas = mo.atlas or "Mobile-QuestIcon"
        s.width = mo.width or 64
        s.height = mo.height or 64
        s.border = mo.border or false
    end
    s.spaceX = 0
    s.spaceY = 10
    s.xOffset = 0
    s.yOffset = 0 - ( (modCount - 1) * (s.height + s.spaceY) ) -20
    return s
end

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
                        e[stateName] = {}

                        e[stateName] = buildBaseState(unitId, optionTable, i, modCount)
                        modCount = modCount + 1

                        e[stateName].show = true
                        e[stateName].changed = true
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

