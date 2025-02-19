--版本信息
local version = 250217

local modifiedNpcOption = {
    [35004] = { -- 冠军的试炼 对话防点错
        [94718] = { -- 我准备好了。但是，我倒是愿意不参加这庆典。
            atlas = "ClassTrial-End-Frame",
            width = 340,
            height = 200,
            name = "-= 点击跳过入场 =-",
        },
    },
    [32686] = { --测试 联盟银行出门左转拐角的 托马斯·里约加因
        [93870] = {
            atlas = "ClassTrial-End-Frame",
            width = 340,
            height = 200,
            name = "-= 点击跳过入场 =-",
        },
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

