--版本信息
local version = 250615
local requireJTSVersion = 32
local soundPack = "TTS"
local voicePackCheck = true

--初始化饰品触发
local equipmentBuffList = {}

local lastEquipmentBuffExpirationTime = nil
local lastEquipmentBuffSoundHandle = nil
--目前只检查饰品格子
local enableSlots = {
    [13] = {
        slot = 13,
        path = "Trinket\\",
    },
    [14] = {
        slot = 14,
        path = "Trinket\\",
    },
    -- [18] = {
    --     slot = 18,
    --     path = "Ranged\\",
    -- },
}
local equippedInSlots = false --全都没穿装备就不检测了

local playerGUID = UnitGUID("player")

--饰品ID与饰品触发BUFFID
--数据来自Merfin的WA，包含了神像，圣契和图腾，暂时没有做触发
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
    -- 敏捷 急速 攻强 力量 暴击 破甲
    [50344] = 71577, [50345] = 71572, [50351] = 71432,
    [50355] = 71396, [50361] = 71635, [50357] = 71579,
    [50356] = 71586, [51378] = 42292, [51377] = 42292,
    [50346] = 71574, [50354] = 71607, [50726] = 71607,
    [54569] = 75458, [54572] = 75466, [54571] = 75477,
    [54573] = 75490, [50366] = 71641, [50349] = 71639,
    [50348] = 71644, [50365] = 71636, [50706] = 71432,
    [50363] = { 71556, 71560, 71558, 71561, 71559, 71557 },
    -- 敏捷 急速 攻强 力量 暴击 破甲
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
    [60771] = true, [71229] = true, [71227] = true,
    [67380] = true, [67383] = true, [64963] = true,
    [60828] = true, [62146] = true, [67385] = true,
    [60819] = true, [60795] = true, [65182] = true,
    [67371] = true, [67364] = true, [67378] = true,
    [71187] = true, [71192] = true, [71197] = true,
    [28093] = true, [53365] = true, [60512] = true,
    [60513] = true, [60514] = true, [60515] = true,
}

-- soundFileData [itemID] = sound file
-- itemID exists and filename == nil is ignored 

local SOUND_FILE_PATH = "Trinket\\"
local SOUND_FILE_FORMAT = ".ogg"
local SOUND_FILE_DEFALT_NAME = "饰品触发"
local SOUND_FILE_DOUBLE_PROC = "双饰品爆发"
local SOUND_FILE_NAME = {
    [47290] = "主宰之力", [40255] = "消逝诅咒", [47477] = "亡者统治", [42987] = "伟大",
    [47881] = "亡灵复仇", [47213] = "深渊符文", [48018] = "动荡能量", [50341] = "器官",
    [47271] = "亡者慰藉", [45313] = "熔炉之石", [50364] = "完美之牙", [50353] = "能量涌动",
    [47316] = "亡者统治", [46021] = "皇家徽记", [50343] = "密语尖牙", [40682] = "日晷",
    [45866] = "元素聚焦", [40684] = "真实之镜", [47088] = "抗阻甲虫", [45148] = "活焰",
    [47879] = "动荡能量", [44912] = "知识之流", [54588] = "暮光龙鳞", [40685] = "精魄",
    [45522] = "古神之血", [47727] = "矮人热忱", [48019] = "束缚之石", [45286] = "蓝铁",
    [45466] = "命运之鳞", [47728] = "禁锢之光", [47131] = "死亡裁决", [47216] = "黑心",
    [50355] = "圣战徽记", [49076] = "秘银怀表", [47464] = "死亡选择", [44253] = "伟大",
    [45518] = "天堂之焰", [50339] = "纯冰薄片", [50363] = "死神意志", [50344] = "器官",
    [45263] = "天谴之石", [47214] = "胜利旌旗", [47188] = "死者统治", [50348] = "能量涌动",
    [50361] = "完美之牙", [47725] = "胜者召唤", [47949] = "矮人热忱", [44254] = "伟大",
    [50342] = "密语尖牙", [45292] = "能量弯管", [47947] = "禁锢之光", [44255] = "伟大",
    [45507] = "将军之心", [39229] = "蜘蛛拥抱", [50346] = "纯冰薄片", [47882] = "伊崔格",
    [45609] = "彗星之痕", [45929] = "西芙记忆", [47948] = "胜者召唤", [50351] = "小憎恶",
    [43573] = "悲苦之泪", [50357] = "谬论之笔", [49686] = "谬论之笔", [50360] = "护符匣",
    [47080] = "抗阻甲虫", [47041] = "败者慰藉", [47059] = "败者慰藉", [50340] = "望远镜",
    [54572] = "暮光龙鳞", [49078] = "远古卤蛋", [47726] = "动荡能量", [45490] = "潘多拉",
    [47880] = "束缚之石", [50198] = "钉壳毒蝎", [47946] = "动荡能量", [40531] = "诺甘农",
    [50356] = "枯骨之钥", [45158] = "钢铁之心", [54569] = "暮光龙鳞", [50352] = "镇魂币",
    [40256] = "死亡之钟", [49074] = "铬银杯垫", [54590] = "暮光龙鳞", [48021] = "伊崔格",
    [47115] = "死亡裁决", [46051] = "陨星水晶", [54571] = "暮光龙鳞", [50706] = "小憎恶",
    [47303] = "死亡选择", [45931] = "雷神符石", [54591] = "暮光龙鳞", [50365] = "护符匣",
    [50362] = "死神意志", [46038] = "黑暗物质", [54573] = "暮光龙鳞", [50345] = "望远镜",
    [47182] = "死者统治", [45308] = "龙母之眼", [54589] = "暮光龙鳞", [50349] = "镇魂币",
    [50259] = "永冻冰晶", [47451] = "主宰之力", [50235] = "伊克的烂指", [37111] = "护魂者", --新增护魂者
    [44914] = "泰坦之砧", [48020] = "亡灵复仇", [40371] = "歹徒的徽记", [45535] = "信仰证明",
    [50260] = "消融之雪", [47432] = "亡者慰藉", [39257] = "洛欧塞布之影",
    --Brewfest 2024 zhCN
    [230755] = "纪念品", [230756] = "远古卤蛋", [230757] = "秘银怀表",
    [230758] = "铬银杯垫", [230759] = "光明酒杯", [230761] = "黑暗酒杯",
    --WotLK New Items zhCN
    [248753] = "陨星水晶", [248754] = "钢铁之心",
    --PvP Medallion
    [42122] = "徽章", [42123] = "徽章", [42124] = "徽章", [42126] = "徽章",
    [46081] = "徽章", [46082] = "徽章", [46083] = "徽章", [46084] = "徽章",
    [46085] = "徽章", [51378] = "徽章", [51377] = "徽章",
    -- TOC vendor trinket
    [48724] = "复苏饰物", [48722] = "水晶之心", [47734] = "霸权印记", [47735] = "无惧雕饰",
    --JT Mod
    [47215] = "屈服之泪",


    
    
    -- Idols
    [50457] = "神像触发", [47670] = "神像触发", [50454] = "神像触发",
    [47671] = "神像触发", [50456] = "神像触发", [47668] = "神像触发",
    [45509] = "神像触发", [38360] = "神像触发", [42582] = "神像触发",
    [42587] = "神像触发", [42574] = "神像触发", [42575] = "神像触发",
    [42583] = "神像触发", [42588] = "神像触发", [42584] = "神像触发",
    [42589] = "神像触发", [42585] = "神像触发", [42591] = "神像触发",
    [51429] = "神像触发", [51437] = "神像触发",
    
    -- Totems
    [50463] = "图腾触发", [47667] = "图腾触发", [50458] = "图腾触发",
    [50464] = "图腾触发", [47665] = "图腾触发", [40322] = "图腾触发",
    [47666] = "图腾触发", [40708] = "图腾触发", [42601] = "图腾触发",
    [42606] = "图腾触发", [42593] = "图腾触发", [42594] = "图腾触发",
    [42602] = "图腾触发", [42607] = "图腾触发", [42603] = "图腾触发",
    [42608] = "图腾触发", [42604] = "图腾触发", [42609] = "图腾触发",
    [51507] = "图腾触发", [51513] = "图腾触发",
    
    -- Sigils
    [50462] = "魔印触发", [50459] = "魔印触发", [47672] = "魔印触发",
    [47673] = "恶意魔印", [45144] = "魔印触发", [40714] = "魔印触发",
    [40715] = "魔印触发", [42619] = "魔印触发", [42620] = "魔印触发",
    [42621] = "魔印触发", [42622] = "魔印触发", [51417] = "魔印触发",
    
    -- Librams
    [40706] = "圣契触发", [40707] = "圣契触发", [42851] = "圣契触发",
    [42611] = "圣契触发", [42852] = "圣契触发", [45145] = "圣契触发",
    [42853] = "圣契触发", [47661] = "圣契触发", [47662] = "圣契触发",
    [47664] = "圣契触发", [42854] = "圣契触发", [50455] = "圣契触发",
    [50460] = "圣契触发", [50461] = "圣契触发", [51478] = "圣契触发",
}

local MULTIPLE_BUFF_ITEMS = {
    [50362] = {
        [71485] = "死神敏捷",
        [71492] = "死神急速",
        [71486] = "死神攻强",
        [71484] = "死神力量",
        [71491] = "死神暴击",
        [71487] = "死神破甲",
    },
    [50363] = {
        [71556] = "死神敏捷",
        [71560] = "死神急速",
        [71558] = "死神攻强",
        [71561] = "死神力量",
        [71559] = "死神暴击",
        [71557] = "死神破甲",
    },
}

--过滤掉叠层类食品，待完工满层提醒
local isRemindEquipment = function(equipmentSlot)
    local _,_, enable = GetInventoryItemCooldown("player", equipmentSlot)
    
    if enable == 1 then
        return true
    end
    
    if enable == 0 then
        local itemID = GetInventoryItemID("player", equipmentSlot)
        local cooldown = NO_COOLDOWN_ITEMS_DATA[ITEM_DATA[itemID]]
        if cooldown then
            return false
        end
        
        return true
    end
end

local DEFAULT_TTS_SPEED = 5

--根据穿戴的饰品ID，取出可能触发的BUFFID LIST，用BUFFID可以判断是否是叠层，用物品格子里的物品id可以判断是否使用
local loadBuffToList = function(equipmentSlot)
    local list = equipmentBuffList
    local itemID = GetInventoryItemID("player",equipmentSlot)
    -- todo ignore itemID will return
    if itemID and isRemindEquipment(equipmentSlot) then
        local equipmentBuffs = ITEM_DATA[itemID]
        if equipmentBuffs then
            if type(equipmentBuffs) == "table" then
                for _, v in pairs(equipmentBuffs) do
                    local soundFile = SOUND_FILE_NAME[itemID] or SOUND_FILE_DEFALT_NAME

                    -- 多BUFF物品处理 -> 死神的意志
                    if MULTIPLE_BUFF_ITEMS[itemID] and MULTIPLE_BUFF_ITEMS[itemID][v] then
                        soundFile = MULTIPLE_BUFF_ITEMS[itemID][v]
                    end

                    list[v] = {}
                    list[v].file = soundFile
                    list[v].slot = equipmentSlot
                    list[v].tts = SOUND_FILE_NAME[itemID]
                end
            elseif type(equipmentBuffs) ~= "table" then
                local soundFile = SOUND_FILE_NAME[itemID] or SOUND_FILE_DEFALT_NAME
                list[equipmentBuffs] = {}
                list[equipmentBuffs].file = soundFile
                list[equipmentBuffs].slot = equipmentSlot
                list[equipmentBuffs].tts = SOUND_FILE_NAME[itemID]
                --equipmentBuffTTSText[equipmentBuffs] = SOUND_FILE_NAME[itemID]
            end
        end
        return true
    else
        return false
    end
end

local getEquipmentBuffList = function()
    --清空重新算
    equipmentBuffList = {}
    for k, _ in pairs(enableSlots) do
        local isEquipped = loadBuffToList(k)
        equippedInSlots = equippedInSlots or isEquipped
    end
end

local printEquipmentBuffList = function()
    local list = equipmentBuffList
    if not next(list) then print("empty table"); return end
    for k, v in pairs(list) do
        print("k: "..k.." v.file: "..v.file.." v.slot: "..v.slot.." v.tts: "..v.tts)
    end
    print("done")
end

local tryPlaySound = function(playTable)
    if ( playTable and aura_env.config.isVoice ) or ( playTable.file == SOUND_FILE_DOUBLE_PROC and aura_env.config.doubleProc ) then
        local soundFileName = playTable.file
        local soundFilePath = enableSlots[playTable.slot].path
        local ttsText = playTable.tts or SOUND_FILE_DEFALT_NAME
        local ttsSpeed = DEFAULT_TTS_SPEED
        
        local file = soundFilePath..soundFileName..SOUND_FILE_FORMAT
        local function tryPSFOrTTS(filePath, text, speed)
            local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
            local filePSF = PATH_PSF..(filePath or "")
            local canplay, soundHandle = PlaySoundFile(filePSF, "Master")
            if not canplay then
                C_VoiceChat.SpeakText(0, (text or ""), 0, (speed or 0), 100)
            else
                lastEquipmentBuffSoundHandle = soundHandle
                return canplay, soundHandle
            end
        end
        
        if JTS and JTS.P then
            local canplay, soundHandle = JTS.P(file)
            if not canplay then
                tryPSFOrTTS(file, ttsText, ttsSpeed)
            else
                lastEquipmentBuffSoundHandle = soundHandle
                return canplay, soundHandle
            end
        else
            tryPSFOrTTS(file, ttsText, ttsSpeed)
        end
    else
        return false,nil
    end
end

--for addonmsg
local regPrefix = function()
    local prefixList = {
        ["JTESAY"] = true,
        ["JTEGUILD"] = true,
        ["JTERAID"] = true,
        ["JTEPARTY"] = true,
        ["JTETTS"] = true,
        ["JTECHECK"] = true,
        ["JTECHECKRESPONSE"] = true,
    }
    for k,v in pairs(prefixList) do
        local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(k)
    end
end
regPrefix()

--author and header
local AURA_ICON = 133434
local AURA_NAME = "JT饰品触发语音提醒WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

--语音包检测
local CHECK_FILE = SOUND_FILE_PATH..SOUND_FILE_DEFALT_NAME..SOUND_FILE_FORMAT
local SOUND_FILE_MISSING = "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local REQUIRE_VERSION = requireJTSVersion
local checkVoicePack = function()
    if voicePackCheck then
        local auraIcon = AURA_ICON or 135428
        local auraName = AURA_NAME or "JT系列WA"
        local author = AUTHOR or "Jettie@SMTH"
        local smallIcon = "|T"..(auraIcon or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
        local headerText = smallIcon.."[|CFF8FFFA2"..auraName.."|R]|CFF8FFFA2 "

        local checkFile = CHECK_FILE or "Common\\biubiubiu.ogg"
        local soundFileMissing = SOUND_FILE_MISSING or ( "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听") )
        local requireVersion = REQUIRE_VERSION or 0

        print(headerText.."作者:|R "..author)

        if aura_env.config.isVoice then
            local function tryCheckPSF(filePath)
                local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
                local file = PATH_PSF..(filePath or "")
                local canplay, soundHandle = PlaySoundFile(file, "Master")
                local voicePack
                if canplay then
                    StopSound(soundHandle)
                    voicePack = JTS and "JTSound" or "VoicePack"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    voicePack = "TTS"
                    print(headerText.."|CFFFFE0B0未找到语音文件|R，"..soundFileMissing.."|R")
                end
                return voicePack
            end

            if JTS and JTS.P then
                local canplay, soundHandle = JTS.P(checkFile, requireVersion)
                if canplay and soundHandle then
                    StopSound(soundHandle)
                    soundPack = "JTSound"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    soundPack = tryCheckPSF(checkFile)
                end
            else
                soundPack = tryCheckPSF(checkFile)
            end
        end
        voicePackCheck = false
    end
end

--拆分字符串
local splitString = function(str, separator)
    local index = string.find(str, separator)
    if index then
        local part1 = string.sub(str, 1, index - 1)
        local part2 = string.sub(str, index + 1)
        return part1, part2
    else
        return
    end
end

--initial
checkVoicePack()
getEquipmentBuffList()

local OnCLEUF = function(event, ...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...
    --SPELL_AURA_APPLIED SPELL_AURA_REMOVED SPELL_AURA_APPLIED_DOSE SPELL_AURA_REMOVED_DOSE SPELL_AURA_REFRESH #amount
    local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
    
    if not next(equipmentBuffList) then
        return false
    end
    
    if ( subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" ) and sourceGUID == playerGUID then
        for k, v in pairs(equipmentBuffList) do
            if k == spellId then
                if aura_env.config.doubleProc then
                    local _, _, _, _, duration, expirationTime = WA_GetUnitBuff("player",k)
                    if not lastEquipmentBuffExpirationTime then
                        lastEquipmentBuffExpirationTime = expirationTime
                    else
                        local last, now = lastEquipmentBuffExpirationTime, GetTime()
                        lastEquipmentBuffExpirationTime = expirationTime
                        if last - now >= 3 then
                            if lastEquipmentBuffSoundHandle then
                                StopSound(lastEquipmentBuffSoundHandle)
                                lastEquipmentBuffSoundHandle = nil
                            end
                            local doubleProcTable = {
                                file = SOUND_FILE_DOUBLE_PROC,
                                slot = v.slot,
                                tts = SOUND_FILE_DOUBLE_PROC,
                            }
                            tryPlaySound(doubleProcTable)
                            return true
                        end
                    end
                end
                tryPlaySound(v)
            end
        end
    end
end

local OnChatMSGAddon = function(...)
    local prefix, text, channel, sender, target, zoneChannelID, localID, channelName, instanceID = ...
    if prefix == "JTECHECK" then
        local ver = version or 0
        if text == "trinketsound" then
            local vpColor = soundPack == "JTSound" and "|CFFFF53A2" or "|CFF1785D1"
            local msg = "TrinketSound Ver: "..ver.." Sound: "..vpColor..soundPack
            C_ChatInfo.SendAddonMessage("JTECHECKRESPONSE", msg, channel, nil)
        end
    else
        if not JTS then
            local convertChannel = {
                ["JTESAY"] = "SAY",
                ["JTEGUILD"] = "GUILD",
                ["JTERAID"] = "RAID",
                ["JTEPARTY"] = "PARTY"
            }
            
            if prefix == "JTETTS" then
                local name, msg = splitString(text, ":")
                if msg then
                    if name == string.lower(UnitName("player")) or name == "all" then
                        C_VoiceChat.SpeakText(0, msg, 0, 2, 100)
                    end
                end
            elseif convertChannel[prefix] then
                local sourceName = splitString(sender,"-") and splitString(sender,"-") or sender
                local name, msg = splitString(text, ":")
                local channel = convertChannel[prefix]
                if msg then
                    if name == string.lower(UnitName("player")) or name == "all" then
                        SendChatMessage(msg, channel, nil,nil)
                    end
                end
            end
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        return OnCLEUF(event, CombatLogGetCurrentEventInfo())
    elseif event == "PLAYER_ENTERING_WORLD" then
        checkVoicePack()
        getEquipmentBuffList()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        getEquipmentBuffList()
        --printEquipmentBuffList()
    elseif event == "CHAT_MSG_ADDON" then
        OnChatMSGAddon(...)
    end
end

