--版本信息
local version = 250311

--author and header
local AURA_ICON = 135743
local AURA_NAME = "JT冠军的钱包WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local myName = UnitName("player")

local autoChoose = {
    [11] = true, -- 占位id 11啥也没有
}

local autoOpenitems = {
    [45724] = true, -- 冠军的钱包
    [46007] = true, -- 钓鱼宝藏
    [44113] = true, -- 小香料袋
    [45328] = true,-- 浮肿的鳗鱼

    [199210] = true,  -- 诺森德冒险补给品
    [200238] = true,  -- 诺森德冒险补给品
    [200239] = true,  -- 诺森德冒险补给品

    [33844] = true, -- 一桶鱼
    [33857] = true, -- 一箱肉
}

local configListOfAutoOpenItems = {
    [1] = 45724, -- 冠军的钱包
    [2] = 46007, -- 钓鱼宝藏
    [3] = 44113, -- 小香料袋
    [4] = 45328, -- 浮肿的鳗鱼

    [5] = {199210, 200238, 200239}, -- 诺森德冒险补给品
}

local configListOfAutoChooseItems = {
    [1] = 45724, -- 冠军的钱包
}

local autoChooseWritOrPurseId = aura_env.config.autoChooseWritOrPurse == 1 and 46114 or 45724

local initData = function()
    -- 特定角色选择 冠军的文书
    for k, v in pairs(aura_env.config.forceWrit) do
        if v.playerName == myName then
            autoChooseWritOrPurseId = 46114
        end
    end

    -- 自动选择任务奖励
    for i, v in ipairs(aura_env.config.autoChooseItems) do
        if not v then
            local itemId = configListOfAutoChooseItems[i]
            autoChoose[itemId] = nil
        end
        -- 额外添加冠军的钱包的自动选择
        autoChoose[autoChooseWritOrPurseId] = true
    end

    -- 自动开启背包物品
    for i, v in ipairs(aura_env.config.autoOpenItems) do
        if not v then
            local itemId = configListOfAutoOpenItems[i]
            if type(itemId) == 'table' then
                for _, item in ipairs(itemId) do
                    autoOpenitems[item] = nil
                end
            else
                autoOpenitems[itemId] = nil
            end
        end
    end
end
initData()

aura_env.OnTrigger = function(event, ...)
    if event == "QUEST_COMPLETE" then
        local rewards = GetNumQuestChoices()
        for i = 1, rewards do
            local itemId = select(6, GetQuestItemInfo("choice", i))
            if autoChoose[itemId] then
                GetQuestReward(i)
                break
            end
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        for bag = 4, 0, -1 do
            local numSlots = C_Container.GetContainerNumSlots(bag)
            if numSlots > 0 then 
                for slot = numSlots, 1, -1 do 
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    if type(info) == 'table' and info and not info.isLocked and autoOpenitems[info.itemID] then
                        C_Container.UseContainerItem(bag, slot)
                        print(HEADER_TEXT.."自动开启背包物品："..select(2, GetItemInfo(info.itemID)))
                    end
                end
            end
        end
    end
end

