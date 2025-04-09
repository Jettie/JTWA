--table .func .param
local checkTable = {
    -- 3码 可能是4码 42732
    [1] = {
        [1] = {
            func = "TEXT",
            param = "3码",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 3,
        },
        [3] = { -- /dump IsItemInRange(33063)
            func = "ITEM",
            param = 33063,
        },
        [4] = { -- /dump IsItemInRange(35789)
            func = "ITEM",
            param = 35789,
        },
    },
    -- 5码(近战范围)
    [2] = {
        
        [1] = {
            func = "TEXT",
            param = "5码(近战范围)",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 5,
        },
        [3] = { -- /dump IsItemInRange(16114)
            func = "ITEM",
            param = 16114,
        },
    },
    -- 6码
    [3] = {
        [1] = {
            func = "TEXT",
            param = "6码",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 6,
        },
        [3] = { -- /dump IsItemInRange(35789)
            func = "ITEM",
            param = 42732,
        },
    },
    -- 7码
    [4] = {
        [1] = {
            func = "TEXT",
            param = "7码",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 7,
        },
        [3] = { -- /dump CheckInteractDistance("target",3)
            func = "INTERACT",
            param = 3,
        },
    },
    -- 8码
    [5] = {
        [1] = {
            func = "TEXT",
            param = "8码",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 8,
        },
        [3] = { -- /dump IsItemInRange(29052)
            func = "ITEM",
            param = 29052,
        },
        [4] = { -- /dump IsItemInRange(33278)
            func = "ITEM",
            param = 33278,
        },
        [5] = { -- /dump IsItemInRange(34368)
            func = "ITEM",
            param = 34368,
        },
        [6] = { -- /dump IsItemInRange(35943)
            func = "ITEM",
            param = 35943,
        },
        [7] = { -- /dump IsItemInRange(37932)
            func = "ITEM",
            param = 37932,
        },
    },
    -- 9码
    [6] = {
        [1] = {
            func = "TEXT",
            param = "9码",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 9,
        },
        [3] = { -- /dump CheckInteractDistance("target",2)
            func = "INTERACT",
            param = 2,
        },
    },
    -- 10码
    [7] = {
        [1] = {
            func = "TEXT",
            param = "10码",
        },
        [2] = { -- WeakAuras.CheckRange("target", 5, "<=")
            func = "WARC",
            param = 10,
        },
        [3] = { -- /dump IsItemInRange(32321)
            func = "ITEM",
            param = 32321,
        },
        [4] = { -- /dump IsItemInRange(17626)
            func = "ITEM",
            param = 17626,
        },
        [5] = { -- /dump IsItemInRange(50131)
            func = "ITEM",
            param = 50131,
        },
        [6] = { -- /dump IsItemInRange(52709)
            func = "ITEM",
            param = 52709,
        },
        [7] = { -- /dump IsItemInRange(54215)
            func = "ITEM",
            param = 54215,
        },
    },
}

local goCheckTarget = function(subTable, unitTarget)
    local func = subTable.func
    if func == "ITEM" then
        local itemId = subTable.param
        local target = unitTarget or "target"
        local check = IsItemInRange(itemId, target)
        local result = (check == true) and "|CFF8FFFA2是|R" or ((check == false) and "|CFFFF53A2否|R" or "|CFFFFF569无效|R")
        local textStr = "    |CFFFFF569"..func.."(|CFFFFFFFF"..itemId.."|R) = "..result.."|R"
        return textStr
    elseif func == "INTERACT" then
        local distIndex = subTable.param
        local target = unitTarget or "target"
        local check = CheckInteractDistance(target, distIndex)
        local result = (check == true) and "|CFF8FFFA2是|R" or ((check == false) and "|CFFFF53A2否|R" or "|CFFFFF569无效|R")
        local textStr = "    |CFFFFF569"..func.."(|CFFFFFFFF"..distIndex.."|R) = "..result.."|R"
        return textStr
    elseif func == "WARC" then
        local dist = subTable.param
        local target = unitTarget or "target"
        local check = WeakAuras.CheckRange(target, dist, "<=")
        local result = (check == true) and "|CFF8FFFA2是|R" or ((check == false) and "|CFFFF53A2否|R" or "|CFFFFF569无效|R")
        local textStr = "    |CFF00FFFF"..func.."(|CFFFFFFFF"..dist.."|R) = "..result.."|R"
        return textStr
    elseif func == "TEXT" then
        local text = subTable.param
        local textStr = "|CFF1785D1"..text.."|R"
        return textStr
    end
end

local getText = function(unit)
    local unitToText = {
        ["target"] = "目标",
        ["focus"] = "焦点",
    }
    
    if not UnitExists(unit) then
        
        local textStr = "当前没有"..unitToText[unit] or "ERROR"
        return textStr
    end
    
    local displayText = "|CFFFFFFFF"..unitToText[unit].."距离|R\n"
    
    for i = 1, #checkTable do
        for j = 1, #checkTable[i] do
            local subTable = checkTable[i][j]
            
            local line = goCheckTarget(subTable, unit)
            --print(line)
            --print(subTable.param)
            displayText = displayText..line.."\n"
        end
    end
    return displayText
end

aura_env.check = function()
    aura_env.targetText = getText("target")
    aura_env.focusText = getText("focus")
end

aura_env.OnTrigger = function(event)
    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        if UnitExists("target") or UnitExists("focus") then
            local speed = 0.05
            aura_env.ticker = C_Timer.NewTicker(speed, function() WeakAuras.ScanEvents("JT_RANGE_CHECK_WA") end)
            return true
        else
            if aura_env.ticker then
                aura_env.ticker:Cancel()
            end
            return false
        end
    elseif event == "JT_RANGE_CHECK_WA" then
        aura_env.check()
        return true
    end
end

--[[

    -- 3码 可能是4码
    /dump IsItemInRange(33063)
    https://db.nfuwow.com/80/?item=33063
    /dump IsItemInRange(35789)
    https://db.nfuwow.com/80/?item=35789

    -- 5码(近战范围)
    local 5yard = "5码"
    /dump IsItemInRange(16114)
    -- 7码 
    /dump CheckInteractDistance("target",3)
    -- 8码 
    /dump IsItemInRange(29052)
    /dump IsItemInRange(34368)
    /dump IsItemInRange(33278)
    /dump IsItemInRange(35943)
    /dump IsItemInRange(37932)
    -- 9码
    /dump CheckInteractDistance("target",2)
    -- 10码
    /dump IsItemInRange(32321)
    /dump IsItemInRange(17626)
    /dump IsItemInRange(50131)
    /dump IsItemInRange(52709)
    /dump IsItemInRange(54215)
    --超级远，大号ID
    /dump IsItemInRange(206272)

    --杀戮测试用
    /dump IsItemInRange(34368,"target")
    /dump IsItemInRange(32321,"focus")

    --距离比较
    /dump CheckInteractDistance("target",3)
    /dump IsItemInRange(34368,"target")
    /dump CheckInteractDistance("target",2)
    /dump IsItemInRange(32321,"target")
    /dump IsItemInRange(17626)

    /dump C_Item.IsItemInRange(32321)
]]

