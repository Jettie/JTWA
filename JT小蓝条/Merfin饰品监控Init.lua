-- 版本信息
local version = 250626

-- [itemId] = procId,
-- [itemId] = { procId1, procId2 },
local ITEM_DATA = {
    [37111] = {60512, 60513, 60514, 60515}, [23835] = 99999, [23836] = 99999, [32782] = 41301, [24390] = 31794,
    [28040] = 33662, [28041] = 33667, [28042] = 33668, [25829] = 33828,
    [24551] = 32140, [27922] = { 33511, 33513 }, [27924] = { 33511, 33513 },
    [24376] = 31771, [27927] = { 33522, 33523 }, [27926] = { 33522, 33523 },
    [25787] = 32600, [25786] = 99999, [25619] = 32355, [25620] = 32355,
    [28108] = 33759, [28109] = 33746, [25937] = 39200, [25936] = 39201,
    [31856] = { 39439, 39441 }, [31858] = 99999, [31859] = 99999,
    [31857] = 39443, [26055] = 33012, [27416] = 33014, [31617] = 33667,
    [25628] = 32362, [25633] = 32362, [31615] = 33662, [32771] = 41263,
    [29181] = 99999, [25634] = 32367, [32770] = 41261, [29776] = 35733,
    [32864] = 40815, [30300] = 36372, [29370] = 35163, [29383] = 35166,
    [29376] = 35165, [38290] = 51953, [38288] = 51954, [38287] = 51955,
    [29387] = 35169, [38289] = 51952, [30293] = 36347, [28034] = { 33648, 33649 },
    [27891] = 33479, [27900] = 33486, [30340] = 36432, [32658] = 40729,
    [27683] = 33370, [27529] = 33089, [28288] = 33807, [34472] = 45053,
    [28785] = 37658, [32654] = 40724, [28190] = 33370, [28370] = 34210,
    [28121] = 34106, [28727] = 29601, [29132] = 35337, [28590] = 38332,
    [24128] = 31047, [30346] = 99999, [28418] = 34321, [30841] = 37877,
    [28528] = 34519, [32534] = 40538, [28223] = 34000, [30349] = 99999,
    [29179] = 35337, [24126] = 31040, [27770] = 39228, [30343] = 99999,
    [28235] = 99999, [30345] = 99999, [24125] = 31039, [30344] = 99999,
    [34473] = 45058, [34471] = 45064, [28234] = 99999, [30350] = 99999,
    [28237] = 99999, [24124] = 31038, [28242] = 99999, [30348] = 99999,
    [28240] = 99999, [28239] = 99999, [30351] = 99999, [24127] = 31045,
    [27828] = 33400, [28243] = 99999, [28238] = 99999, [28241] = 99999,
    [28236] = 99999, [28830] = 34775, [28789] = 34747, [28823] = 37706,
    [35702] = 46784, [35700] = 46783, [35694] = 46782, [35703] = 46785,
    [35693] = 46780, [30627] = 42084, [30626] = 38348, [30720] = 37445,
    [30447] = 37198, [30664] = { 37343, 37340, 37341, 37342, 37344 },
    [30450] = 37174, [30619] = 38324, [37864] = 99999, [30620] = 38325,
    [37865] = 99999, [30663] = 37243, [30665] = 40402, [30629] = 38351,
    [30448] = 37508, [37128] = 48042, [37127] = 48041, [34029] = 43995,
    [33831] = 43716, [33832] = 44055, [34050] = 44055, [34576] = 44055,
    [34578] = 44055, [33829] = 43712, [34049] = 44055, [34580] = 44055,
    [34163] = 44055, [34579] = 44055, [35326] = 44055, [35327] = 44055,
    [34162] = 44055, [34577] = 44055, [33830] = 43713, [33828] = 43710,
    [32505] = 40477, [32501] = 40464, [32483] = 40396, [32496] = 37656,
    [34427] = 45040, [34429] = 45044, [34428] = 45049, [34430] = 45052,
    [10725] = 99999, [41589] = 44055, [35935] = 47215, [38257] = 47816,
    [36874] = 47816, [38073] = 33662, [38760] = 48875, [44308] = 60318,

    [21625] = 26467, [38358] = 51353,
    [40865] = 54808, [40767] = 55018, [43837] = 61617,
    [38763] = 61426, [38764] = 61427, [38765] = 61428,
    [43836] = 61620, [44013] = 59657, [44015] = 59657,
    [44014] = 59658, [36993] = 60214, [36972] = 60471,
    [38359] = 51348, [37064] = 60307, [37220] = 60218,
    [37660] = 60479, [45131] = 63250, [45219] = 63250,
    [37390] = 60302, [37264] = 60483, [37657] = 60520,
    [40430] = 60525, [37844] = 60521, [37734] = 60517,
    [37166] = 60305, [37638] = 60180, [37873] = 60480,
    [37872] = 60215, [37723] = 60299, [42341] = 56121,
    [44063] = 59757, [42418] = 56188, [42413] = 56186,
    [42395] = 56184, [41121] = 55039,
    [42987] = { 60229, 60233, 60234, 60235 },
    [44253] = { 60229, 60233, 60234, 60235 },
    [44255] = { 60229, 60233, 60234, 60235 },
    [44254] = { 60229, 60233, 60234, 60235 },
    [42990] = 60203, [19288] = 23684, [42989] = 60196,
    [42988] = 57350, [44912] = 60064, [40682] = 60064,
    [49706] = 60064, [44914] = 60065, [40684] = 60065,
    [49074] = 60065, [39229] = 60492, [43573] = 58904,
    [37835] = 49623, [40685] = 60062, [49078] = 60062,
    [47213] = 67669, [47214] = 67671, [47215] = 67666,
    [40683] = 60054, [39388] = 60527, [39292] = 60180,
    [39257] = 60439, [49080] = 68443, [49116] = 68271,
    [49118] = 68270, [42122] = 42292, [42123] = 42292,
    [37254] = 48333, [40382] = 60538, [40256] = 60437,
    [40258] = 60530, [40373] = 60488, [40255] = 60494,
    [40371] = 60443, [40432] = 60486, [40431] = 60314,
    [40372] = 60258, [46088] = 64527, [46087] = 64525,
    [46086] = 64524, [40257] = 60286, [42129] = 55915,
    [42130] = 55915, [42132] = 55915, [42128] = 55915,
    [46083] = 42292, [46085] = 42292, [46081] = 42292,
    [46084] = 42292, [46082] = 42292,
    [45286] = 65014, [45866] = 65004, [45308] = 65006,
    [46021] = 65012, [45313] = 65011, [45292] = 65008,
    [45507] = 64765, [45929] = 65003, [45490] = 64741,
    [45931] = 65019, [46038] = 65024, [45522] = 64790,
    [45466] = 64707, [46051] = 64999,
    [40531] = 60319,
    --[45158] = 64763,    
    [40532] = 60526, [42126] = 42292, [42124] = 42292,
    [46312] = 64983, [50198] = 71403, [47881] = 67738,
    [47725] = 67738, [47879] = 67736, [47726] = 67736,
    [47882] = 67728, [47727] = 67728, [47880] = 67726,
    [47728] = 67726, [50259] = 71564, [50235] = 71569,
    [50260] = 71568, [45535] = 64739, [45518] = 64713,
    [45609] = 64772, [46017] = 64411,
    [47303] = { 67703, 67708 }, [47115] = { 67703, 67708 },
    [47271] = 67696, [47041] = 67696, [48020] = 67747,
    [47948] = 67747, [47316] = 67713, [47182] = 67713,
    [48018] = 67744, [47946] = 67744, [48021] = 67742,
    [47949] = 67742, [48019] = 67740, [47947] = 67740,
    [48724] = 67684, [48722] = 67683, [47290] = 67699,
    [47080] = 67699,
    [47734] = 67695, [47735] = 67694, [42133] = 67596,
    [42134] = 67596, [42136] = 67596, [42137] = 67596,
    [42135] = 67596, [50342] = 71401, [50341] = 71575,
    [50340] = 71570, [50339] = 71565,
    [47464] = { 67772, 67773 }, [47131] = { 67772, 67773 },
    [47432] = 67750, [47059] = 67750, [47477] = 67759,
    [47188] = 67759, [47451] = 67753, [47088] = 67753,
    [50353] = 71601, [50358] = 71584, [50343] = 71541,
    [50360] = 71605, [50359] = 71610, [50352] = 71633,
    [50362] = { 71485, 71492, 71486, 71484, 71491, 71487 },
    [50344] = 71577, [50345] = 71572, [50351] = 71432,
    [50355] = 71396, [50361] = 71635, [50357] = 71579,
    [50356] = 71586, [51378] = 42292, [51377] = 42292,
    [50346] = 71574, [50354] = 71607, [50726] = 71607,
    [54569] = 75458, [54572] = 75466, [54571] = 75477,
    [54573] = 75490, [50366] = 71641, [50349] = 71639,
    [50348] = 71644, [50365] = 71636, [50706] = 71432,
    [50363] = { 71556, 71560, 71558, 71561, 71559, 71557 },
    [50364] = 71638, [50397] = 72416, [50398] = 72416,
    [50401] = 72412, [50402] = 72412, [52571] = 72412,
    [52572] = 72412, [50399] = 72418, [50400] = 72418,
    [50403] = 72414, [50404] = 72414, [54590] = 75456,
    [54588] = 75473, [54591] = 75480, [54589] = 75495,
    --Brewfest 2024 zhCN
    [230755] = 467349, [230756] = 467350, [230757] = 467352,
    [230758] = 467354, [230759] = 467356, [230761] = 999999,
    --WotLK BuffId modified zhCN
    [45263] = 398488, [45148] = 398475,
    [45158] = 398478,
    --WotLK New Item zhCN
    [248753] = 1247618, [248754] = 1247619,
    [249819] = 1249836, [249820] = 1249838, [249821] = 1249840,
    --JT mod
    [47216] = 67631,

    -- Idols
    [50457] = 71177, [47670] = 67360, [50454] = 71184,
    [47671] = 67358, [50456] = 71175, [47668] = 67355,
    [45509] = 64951, [38360] = 57909, [42582] = 60566,
    [42587] = 60547, [42574] = 60544, [42575] = 60565,
    [42583] = 60567, [42588] = 60549, [42584] = 60568,
    [42589] = 60551, [42585] = 60569, [42591] = 60553,
    [51429] = 60555, [51437] = 60570,

    -- Totems
    [50463] = 71216, [47667] = 67391, [50458] = 71199,
    [50464] = 71220, [47665] = 67388, [40322] = 60766,
    [47666] = 67385, [40708] = 60771, [42601] = 60566,
    [42606] = 60547, [42593] = 60544, [42594] = 60565,
    [42602] = 60567, [42607] = 60549, [42603] = 60568,
    [42608] = 60551, [42604] = 60569, [42609] = 60553,
    [51507] = 60555, [51513] = 60570,

    -- Sigils
    [50462] = 71229, [50459] = 71227, [47672] = 67380,
    [47673] = 67383, [45144] = 64963, [40714] = 62146,
    [40715] = 60828, [42619] = 60547, [42620] = 60549,
    [42621] = 60551, [42622] = 60553, [51417] = 60555,

    -- Librams
    [40706] = 60819, [40707] = 60795, [42851] = 60547,
    [42611] = 60544, [42852] = 60549, [45145] = 65182,
    [42853] = 60551, [47661] = 67371, [47662] = 67364,
    [47664] = 67378, [42854] = 60553, [50455] = 71187,
    [50460] = 71192, [50461] = 71197, [51478] = 60555,

}

-- [enchantId] = procId
local ENCHANT_DATA = {
    [3859] = 55001, --降落伞-弹力蛛丝
    [3722] = 55637,
    [3728] = 55767,
    [3730] = 55775,
    [3790] = 59626,
    [3603] = 54757,
    [3604] = 54758,
    [3606] = 54861,
    [3789] = 59620,
    [3869] = 64440,
    [3870] = 64568,
    [2673] = 28093,
    [3368] = 53365,
    [3369] = 53386,
    --JT remove Parachute
    [3605] = 55001, --降落伞-高弹力衬垫
}

-- [gemId] = procId
local GEMS_DATA = {
    [41401] = 55382, -- Insightful Earthsiege Diamond
    [41385] = 55341, -- Invigorating Earthsiege Diamond
    [41400] = 55379, -- Thundering Skyflare Diamond 
}

-- [procId] = cooldown
local COOLDOWNS_DATA = {
    [72416] = 60,
    [72412] = 60,
    [72418] = 60,
    [72414] = 60,
    [51348] = 10,
    [51353] = 10,
    [54808] = 60,
    [55018] = 60,
    [64790] = 50,
    [65014] = 50,
    [71485] = 105,
    [71492] = 105,
    [71486] = 105,
    [71484] = 105,
    [71491] = 105,
    [71487] = 105,
    [71556] = 105,
    [71560] = 105,
    [71558] = 105,
    [71561] = 105,
    [71559] = 105,
    [71557] = 105,
    [71605] = 100,
    [71636] = 100,
    [55637] = 60,
    [55775] = 60,
    [55767] = 60,
    [59626] = 35,
    [64568] = 10,
    [55382] = 15,
    [40373] = 15,

    --WotLK New Item zhCN
    [1249836] = 50, -- 黑心
    [1249838] = 50, -- 胜利旌旗
    [1249840] = 45, -- 深渊符文

    --JT add
    [60065] = 50, --真实之镜
    [467354] = 50, --铬银杯垫
    [60064] = 50, --知识之流
    [60218] = 50, --蛛丝精华
    [67671] = 50, --胜利旌旗
}

-- [itemId] = extraProcId
local EXTRA_PROCS_DATA = {
    [50348] = 71643,
    [50353] = 71600,
    [47879] = 67735,
    [47726] = 67735,
    [48018] = 67743,
    [47946] = 67743,
    [47880] = 67723,
    [47728] = 67723,
    [48019] = 67739,
    [47947] = 67739,
    [47881] = 67737,
    [47725] = 67737,
    [48020] = 67746,
    [47948] = 67746,
    [46051] = 65000,
    [248753] = 1247617,
}

-- [procId] = true (f.e. Balance Idols)
local NO_COOLDOWN_ITEMS_DATA = {
    [60486] = true, [60525] = true, [60314] = true,
    [60196] = true, [71575] = true, [71577] = true,
    [71570] = true, [71572] = true, [71432] = true,
    [71396] = true, [65006] = true, [71600] = true,
    [71643] = true, [67696] = true, [67750] = true,
    [67713] = true, [67759] = true, [71177] = true,
    [67360] = true, [59620] = true, [64440] = true,
    [71184] = true, [67358] = true, [71175] = true,
    [67355] = true, [64951] = true, [57909] = true,
    [60566] = true, [60547] = true, [60544] = true,
    [60565] = true, [60567] = true, [60549] = true,
    [60568] = true, [60551] = true, [60569] = true,
    [60553] = true, [60555] = true, [60570] = true,
    [71216] = true, [67391] = true, [71199] = true,
    [71220] = true, [67388] = true, [60766] = true,
    [60771] = true,
    [71229] = true, [71227] = true,
    [67380] = true, [67383] = true, [64963] = true,
    [60828] = true, [62146] = true, [67385] = true,
    [60819] = true, [60795] = true, [65182] = true,
    [67371] = true, [67364] = true, [67378] = true,
    [71187] = true, [71192] = true, [71197] = true,
    [28093] = true, [53365] = true, [60512] = true,
    [60513] = true, [60514] = true, [60515] = true,
}

local INVALID_EVENTS = {
    SPELL_DISPEL            = true,
    SPELL_DISPEL_FAILED     = true,
    SPELL_STOLEN            = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_BROKEN       = true,
    SPELL_AURA_BROKEN_SPELL = true,
    SPELL_CAST_FAILED       = true,
    SPELL_PERIODIC_HEAL     = true,
    SPELL_CAST_SUCCESS      = true,
}

local hexNoGUID = "0x0000000000000000"

local tinsert = table.insert
local stformat = string.format
local substr = string.sub
local myGUID = UnitGUID("player")

local ItemWidget = aura_env
local cfg = ItemWidget.config

local items = {
    -- [itemId] = {
    --     equipmentSlot = number,
    --     procs = table,
    --     isProc = boolean,
    --     itemTexture = string, (constant)
    --     procTexture = string,
    --     stacks = number,
    --     cooldown = number, (constant)
    --     duration = number, (as cooldown duration)
    --     expirationTime = number, (as cooldown expTime)
    --     procDuration = number, (as proc duration)
    --     procExpirationTime = number, (as proc expTime)
    -- }
}

local equipmentSlots = {
    -- [equipmentSlot] = itemId,
}

local procs = {
    -- [procId] = itemId,
}

local extraProcs = {
    -- [extraProcId] = itemId,
}

local settings = {
    equipmentSlots = {},
    order = {},
    advanced = {},
    registerAnyOnUse = cfg.display.registerAnyOnUse,
    showAlways = cfg.display.showAlways,
    showProc = cfg.display.showProc,
    itemTextureAlways = cfg.display.itemTextureAlways,
}

ItemWidget.settings = settings

local InitConfig = function()

    for slot, enable in ipairs(cfg.display.equipmentSlots) do
        if enable then
            settings.equipmentSlots[slot] = true
        end
    end

    local validEnchants = {
        [1] = 3859,
        [2] = 3722,
        [3] = 3728,
        [4] = 3730,
        [5] = 3603,
        [6] = 3604,
        [7] = 3606,
        [8] = 3790,
        [9] = 3789,
        [10] = 3869,
        [11] = 3870,
        [12] = 2673,
        [13] = 3370,
        [14] = 3605,
    }

    for i, v in ipairs(cfg.display.validEnchants) do
        if not v then
            local enchantId = validEnchants[i]
            ENCHANT_DATA[enchantId] = nil
        end
    end

    local validMetaGems = {
        [1] = 41385, -- Invigorating Earthsiege Diamond
        [2] = 41400, -- Thundering Skyflare Diamond
        [3] = 41401, -- Insightful Earthsiege Diamond
    }

    for i, v in ipairs(cfg.display.validMetaGems) do
        if not v then
            local metaGemId = validMetaGems[i]
            GEMS_DATA[metaGemId] = nil
        end
    end

    for equipmentSlot, index in pairs(cfg.display.order) do
        local equipmentSlot = tonumber(equipmentSlot)
        if equipmentSlot then
            settings.order[equipmentSlot] = index
        end
    end

    for _, optionsData in ipairs(cfg.advanced) do
        local itemId = optionsData.itemId

        if optionsData.disable then
            ITEM_DATA[itemId] = nil
        end

        settings.advanced[itemId] = {
            disableGlow = optionsData.disableGlow
        }
    end

end

-- return: table - numbers
local GetValuesTable = function(value)
    local t = {}
    if type(value) == "table" then
        for _, v in pairs(value) do
            tinsert(t, v)
        end
    elseif type(value) ~= "table" then
        tinsert(t, value)
    end
    return t
end

-- return: number - itemId, number - enchantId
local GetSlotItemInfo = function(equipmentSlot)

    local itemLink = GetInventoryItemLink("player", equipmentSlot)

    if itemLink then
        local itemString = select(3, strfind(itemLink, "|H(.+)|h"))
        local _, itemId, enchantId, metaGem = strsplit(":", itemString)
        return tonumber(itemId), tonumber(enchantId), tonumber(metaGem)
    end

end

-- return: string - custom type names ("NO_CD", "ON_USE", "INTERNAL"), number - cooldown time 
local GetCooldownInfo = function(equipmentSlot, procId)
    local _,_, enable = GetInventoryItemCooldown("player", equipmentSlot)

    if enable == 1 then
        return "ON_USE", nil
    end

    if enable == 0 then
        local cooldown = NO_COOLDOWN_ITEMS_DATA[procId]

        if cooldown then
            return "NO_CD", 0
        end

        return "INTERNAL", COOLDOWNS_DATA[procId] or 45
    end
end

local CanRegister = function(equipmentSlot, procId)
    if procId then
        return true
    end

    if settings.registerAnyOnUse then
        local _,_, enable = GetInventoryItemCooldown("player", equipmentSlot)
        return enable == 1
    end
end

local SetState = {

    AutoHide = function()
        return not settings.showAlways
    end,

    Show = function(state)
        return settings.showAlways or GetTime() < state.expirationTime
    end,

    Duration = function(itemId)
        local isProc = items[itemId].isProc
        return (isProc and settings.showProc) and items[itemId].procDuration or items[itemId].duration or 0
    end,

    ExpirationTime = function(itemId)
        local isProc = items[itemId].isProc
        return (isProc and settings.showProc) and items[itemId].procExpirationTime or items[itemId].expirationTime or GetTime()
    end,

    Index = function(equipmentSlot)
        return settings.order[equipmentSlot]
    end,

    Icon = function(itemId)
        local isProc = items[itemId].isProc
        return (isProc and settings.showProc and not settings.itemTextureAlways) and items[itemId].procTexture or items[itemId].itemTexture
    end,

    Stacks = function(itemId)
        local isProc = items[itemId].isProc
        return (isProc and settings.showProc) and items[itemId].stacks or 0
    end,

    IsProc = function(itemId)
        local isProc = items[itemId].isProc
        return isProc and settings.showProc
    end,

}

local InitAura = function(allstates, equipmentSlot, itemId)
    local stateName = stformat("IW_Slot%d", equipmentSlot)

    allstates[stateName] = allstates[stateName] or {
        progressType = "timed",
        autoHide = SetState.AutoHide(),
        index = SetState.Index(equipmentSlot),
        itemType = items[itemId].type,
        itemId = itemId,
        equipmentSlot = equipmentSlot,
    }

    allstates[stateName].stacks = SetState.Stacks(itemId)
    allstates[stateName].isProc = SetState.IsProc(itemId)
    allstates[stateName].icon = SetState.Icon(itemId)
    allstates[stateName].duration = SetState.Duration(itemId)
    allstates[stateName].expirationTime = SetState.ExpirationTime(itemId)
    allstates[stateName].show = SetState.Show(allstates[stateName])
    allstates[stateName].changed = true
    --For JT Trinket Blue Bar
    WeakAuras.ScanEvents("MERFIN_ALLSTATES_UPDATE", allstates[stateName].autoHide, allstates[stateName].index, allstates[stateName].itemType, allstates[stateName].itemId, allstates[stateName].equipmentSlot, allstates[stateName].stacks, allstates[stateName].isProc, allstates[stateName].icon, allstates[stateName].duration, allstates[stateName].expirationTime, allstates[stateName].show)

end

local RemoveAura = function(allstates, equipmentSlot)
    equipmentSlots[equipmentSlot] = nil
    local stateName = stformat("IW_Slot%d", equipmentSlot)
    if allstates[stateName] then
        allstates[stateName].show = false
        allstates[stateName].changed = true
        --For JT Trinket Blue Bar
        WeakAuras.ScanEvents("MERFIN_ALLSTATES_REMOVE", allstates[stateName].equipmentSlot)
    end

    return true
end

local InitItem = function(equipmentSlot, itemId, procId)

    if items[itemId] then
        items[itemId].equipmentSlot = equipmentSlot
        return
    end

    items[itemId] = {
        procs = {},
        extraProc = EXTRA_PROCS_DATA[itemId],
        itemTexture = GetItemIcon(itemId),
        expirationTime = GetTime(),
        equipmentSlot = equipmentSlot
    }

    if not procId then
        items[itemId].type = "ON_USE"
        return true
    end

    local p = GetValuesTable(procId)

    for _, procId in pairs(p) do
        tinsert(items[itemId].procs, procId)
        procs[procId] = itemId
        if not items[itemId].type then
            local type, cooldown = GetCooldownInfo(equipmentSlot, procId)

            items[itemId].type = type

            if type == "INTERNAL" then
                items[itemId].cooldown = cooldown
            end
        end
    end

    local extraProcId = EXTRA_PROCS_DATA[itemId]

    if extraProcId then
        extraProcs[extraProcId] = itemId
    end

end

local InitEquipmentSlot = function(allstates, equipmentSlot)

    local itemId, enchantId, metaGem = GetSlotItemInfo(equipmentSlot)

    if itemId then
        local procId = ITEM_DATA[itemId] or ENCHANT_DATA[enchantId] or GEMS_DATA[metaGem]
        if CanRegister(equipmentSlot, procId) then
            equipmentSlots[equipmentSlot] = itemId
            InitItem(equipmentSlot, itemId, procId)
            return true
        end
    end

    if equipmentSlots[equipmentSlot] then
        equipmentSlots[equipmentSlot] = nil
    end

end

-- return: number - cooldown
local LoadLastSession = function(allstates, equipmentSlot, itemId)
    aura_env.saved = aura_env.saved or {}
    local db = aura_env.saved[WeakAuras.me]
    if not db then return end

    if db[itemId] then
        local expirationTimeOS = db[itemId].expirationTimeOS
        local cooldown = expirationTimeOS - time()
        return cooldown
    end
end

local OnUse = function(allstates, equipmentSlot, itemId)
    local startTime, duration = GetInventoryItemCooldown("player", equipmentSlot)
    if duration > 0 then
        local expirationTime = startTime + duration
        if expirationTime > items[itemId].expirationTime then
            items[itemId].duration = duration
            items[itemId].expirationTime = expirationTime
            return true
        end
    end
end

local BagUpdateCooldown = function(allstates)
    local update = false

    for equipmentSlot in pairs(settings.equipmentSlots) do
        local itemId = GetInventoryItemID("player", equipmentSlot)
        if itemId and itemId == equipmentSlots[equipmentSlot]
        and items[itemId].type == "ON_USE"
        and (not settings.showProc or not items[itemId].isProc)
        and OnUse(allstates, equipmentSlot, itemId) then

            items[itemId].stacks = 0
            InitAura(allstates, equipmentSlot, itemId)
            update = true

        end
    end

    return update
end

local EquipmentSlotChanged = function(allstates, equipmentSlot, isEmpty)

    if not isEmpty and InitEquipmentSlot(allstates, equipmentSlot) then

        local timestamp = GetTime()

        local itemId = equipmentSlots[equipmentSlot]
        local type = items[itemId].type

        items[itemId].icon = items[itemId].itemTexture
        items[itemId].stacks = 0
        items[itemId].isProc = false

        if type == "ON_USE" then

            OnUse(allstates, equipmentSlot, itemId)

        elseif type == "INTERNAL" then
            local currentCooldown = items[itemId].expirationTime - timestamp
            local savedCooldown = LoadLastSession(allstates, equipmentSlot, itemId)

            if currentCooldown > 30 then
                items[itemId].duration = items[itemId].cooldown
                items[itemId].expirationTime = timestamp + items[itemId].cooldown

            elseif not savedCooldown or savedCooldown < items[itemId].cooldown then
                items[itemId].duration = items[itemId].cooldown
                items[itemId].expirationTime = timestamp + items[itemId].cooldown

            elseif savedCooldown > 30 then
                items[itemId].duration = items[itemId].cooldown
                items[itemId].expirationTime = savedCooldown + timestamp

            end

        elseif type == "NO_CD" then

            if equipmentSlot ~= 18 then
                items[itemId].duration = 30
                items[itemId].expirationTime = timestamp + 30
            end

        end

        return InitAura(allstates, equipmentSlot, itemId)
    end

    return RemoveAura(allstates, equipmentSlot)

end

local OnExtraProc = function(itemId, extraProcId)
    local _,_, stacks = WA_GetUnitBuff("player", extraProcId)
    items[itemId].stacks = stacks
end

local OnProc = function(allstates, equipmentSlot, itemId, spellId)

    local _, icon, stacks, _, buffDuration, buffExpirationTime = WA_GetUnitBuff("player", spellId)

    if items[itemId].type == "INTERNAL" then
        local cooldown = items[itemId].cooldown
        items[itemId].duration = cooldown
        items[itemId].expirationTime = buffExpirationTime - buffDuration + cooldown
    end

    items[itemId].isProc = true
    items[itemId].procTexture = icon
    items[itemId].procDuration = buffDuration
    items[itemId].procExpirationTime = buffExpirationTime
    items[itemId].stacks = stacks

end

local OnCLEUF = function(allstates, ...)
    local _, subEvent, _, sourceGUID, _,_,_, destGUID, _,_,_, spellId = ...

    if not subEvent then return end
    if INVALID_EVENTS[subEvent] then return end
    if substr(subEvent, 0, 6) ~= "SPELL_" then return end

    if ((destGUID == myGUID and ((not sourceGUID or sourceGUID == hexNoGUID) or sourceGUID == destGUID)) or sourceGUID == myGUID) then

        if procs[spellId] then

            local itemId = procs[spellId]
            local equipmentSlot = items[itemId].equipmentSlot
            local type = items[itemId].type

            if GetInventoryItemID("player", equipmentSlot) ~= itemId then return end

            if subEvent == "SPELL_AURA_APPLIED"
            or subEvent == "SPELL_AURA_REFRESH"
            or subEvent == "SPELL_AURA_APPLIED_DOSE" then

                OnProc(allstates, equipmentSlot, itemId, spellId)
                InitAura(allstates, equipmentSlot, itemId)

            elseif subEvent == "SPELL_AURA_REMOVED" then
                items[itemId].isProc = false
                items[itemId].stacks = 0

                if type == "ON_USE" then
                    OnUse(allstates, equipmentSlot, itemId)

                elseif type == "NO_CD" then
                    items[itemId].duration = 0
                    items[itemId].expirationTime = GetTime()
                end

            elseif type == "INTERNAL" then
                items[itemId].isProc = false
                items[itemId].duration = items[itemId].cooldown
                items[itemId].expirationTime = items[itemId].duration + GetTime()
            end

            InitAura(allstates, equipmentSlot, itemId)
            return true
        end

        if extraProcs[spellId] then

            if subEvent == "SPELL_AURA_APPLIED"
            or subEvent == "SPELL_AURA_REFRESH"
            or subEvent == "SPELL_AURA_APPLIED_DOSE"
            or subEvent == "SPELL_AURA_REMOVED" then

                local itemId = extraProcs[spellId]
                local equipmentSlot = items[itemId].equipmentSlot

                OnExtraProc(itemId, spellId)
                InitAura(allstates, equipmentSlot, itemId)
                return true

            end
        end
    end
end

local OnInit = function(allstates)
    InitConfig()

    local updated = false
    for equipmentSlot in pairs(settings.equipmentSlots) do
        if InitEquipmentSlot(allstates, equipmentSlot) then
            updated = true
        end
    end

    if not updated then return end

    -- display active item procs or load last session
    for equipmentSlot, itemId in pairs(equipmentSlots) do

        local isBuffed = false
        for _, procId in ipairs(items[itemId].procs) do
            if WA_GetUnitBuff("player", procId) then
                isBuffed = true
                OnProc(allstates, equipmentSlot, itemId, procId)
                if items[itemId].extraProc then
                    OnExtraProc(itemId, items[itemId].extraProc)
                end
                break
            end
        end

        if not isBuffed then

            items[itemId].isProc = false
            items[itemId].stacks = 0

            local type = items[itemId].type
            if type == "INTERNAL" or type == "NO_CD" then
                local savedCooldown = LoadLastSession(allstates, equipmentSlot, itemId)

                if savedCooldown and savedCooldown > 0 then
                    items[itemId].duration = items[itemId].cooldown or type == "NO_CD" and 30
                    items[itemId].expirationTime = savedCooldown + GetTime()
                end
            end

            if type == "ON_USE" then
                OnUse(allstates, equipmentSlot, itemId)
            end

        end

        InitAura(allstates, equipmentSlot, itemId)
    end

    return true
end

local SaveLastSession = function()
    aura_env.saved = aura_env.saved or {}
    aura_env.saved[WeakAuras.me] = {}
    local db = aura_env.saved[WeakAuras.me]
    for itemId, itemData in pairs(items) do
        local expirationTime = itemData.expirationTime
        db[itemId] = db[itemId] or {}
        db[itemId].expirationTimeOS = expirationTime - GetTime() + time()
    end
end

ItemWidget.OnTrigger = function(allstates, event, ...)

    if event == "OPTIONS" then

        if WeakAuras.IsOptionsOpen() and ItemWidget.initialized then
            ItemWidget.initialized = false
            SaveLastSession()
        end

        return OnInit(allstates)

    elseif event == "OPTIONS_CLOSE" then

        ItemWidget.initialized = true
        return OnInit(allstates)

    elseif ItemWidget.initialized then

        if event == "PLAYER_EQUIPMENT_CHANGED" then
            local equipmentSlot, isEmpty = ...
            if settings.equipmentSlots[equipmentSlot] then
                EquipmentSlotChanged(allstates, equipmentSlot, isEmpty)
                return true
            end

        elseif event == "BAG_UPDATE_COOLDOWN" then
            return BagUpdateCooldown(allstates)

        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            return OnCLEUF(allstates, CombatLogGetCurrentEventInfo())

        elseif event == "PLAYER_LOGOUT" then
            SaveLastSession()
        end
    end
end