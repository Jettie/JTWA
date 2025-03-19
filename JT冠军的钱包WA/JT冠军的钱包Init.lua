--版本信息
local version = 250311

--author and header
local AURA_ICON = 133203
local AURA_NAME = "JT冠军的钱包WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local myName = UnitName("player")

local autoChoose = {
    [16114] = true, -- 占位id 工头的木棒
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
    
    [35348] = true, -- 钓鱼宝藏-城中的鳄鱼
    [34863] = true, -- 钓鱼宝藏-TBC
}

local configListOfAutoOpenItems = {
    [1] = 45724, -- 冠军的钱包
    [2] = 46007, -- 钓鱼宝藏
    [3] = 44113, -- 小香料袋
    [4] = 45328, -- 浮肿的鳗鱼
    
    [5] = {199210, 200238, 200239}, -- 诺森德冒险补给品
    
    [6] = 33844, -- 一桶鱼
    [7] = 33857, -- 一箱肉
    
    [8] = {35348, 34863}, -- 钓鱼宝藏TBC
}

local configListOfAutoChooseItems = {
    [1] = 16114, -- 占位id 工头的木棒
}

local autoChooseWritOrPurseId = aura_env.config.autoChooseWritOrPurse == 1 and 46114 or 45724
local autoChooseFishOrMeatId = aura_env.config.autoChooseFishOrMeat == 1 and 33844 or 33857

local autoChooseByName = {}

local initData = function()
    -- 特定角色选择 冠军的文书
    for k, v in pairs(aura_env.config.forceWrit) do
        if v.playerName == myName then
            autoChooseWritOrPurseId = 46114
        end
    end

    -- 特定角色选择 一桶鱼
    for k, v in pairs(aura_env.config.forceFish) do
        if v.playerName == myName then
            autoChooseFishOrMeatId = 33844
        end
    end
    
    -- 自动选择任务奖励
    for i, v in ipairs(aura_env.config.autoChooseItems) do
        if not v then
            local itemId = configListOfAutoChooseItems[i]
            autoChoose[itemId] = nil
        end
    end

    -- 额外添加冠军的钱包的自动选择
    autoChoose[autoChooseWritOrPurseId] = true
    -- 额外添加TBC的钓鱼宝藏的自动选择
    autoChoose[autoChooseFishOrMeatId] = true

    -- 因为 GetQuestItemInfo 的第六个参数拿不到itemId，所以转化为物品名字
    for k, v in pairs(autoChoose) do
        if k and v then
            local itemName = GetItemInfo(k)
            if itemName then
                autoChooseByName[itemName] = true
            end
        end
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
            local itemName = GetQuestItemInfo("choice", i)
            local itemId = GetItemInfoInstant(itemName) 
            if itemId then
                local itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)
                local iconStr = "|T"..itemIcon..":12:12:0:0:64:64:4:60:4:60|t"
                --if autoChooseByName[itemName] then
                if autoChoose[itemId] then
                    print(HEADER_TEXT.."自动选择任务奖励："..(iconStr or "")..(select(2, GetItemInfo(itemId)) or ""))
                    GetQuestReward(i)
                    break
                end
            elseif itemName then
                -- itemId 是有可能取不到的 保险起见还是都用itemName吧
                if autoChooseByName[itemName] then
                    print(HEADER_TEXT.."自动选择任务奖励："..itemName)
                    GetQuestReward(i)
                    break
                end
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

