--版本信息 点击取消嫁祸仇恨
aura_env.version = 241120
local headerIconId = 236283
local auraIcon = headerIconId and "|T"..headerIconId..":12:12:0:0:64:64:4:60:4:60|t" or "|T135451:12:12:0:0:64:64:4:60:4:60|t"
aura_env.initialized = auraIcon.."[|CFF8FFFA2JT点击取消嫁祸仇恨WA|R]|CFF8FFFA2 - 看到图标 - 鼠标点击一下 - 作者:|R Jettie@SMTH"

--点击版改动部分写这里
local macroStr = "/cancelaura 嫁祸诀窍"
--local macroStr = "/cancelaura 佯攻" --佯攻测试

aura_env.displayClick = "点击取消\n嫁祸诀窍\n仇恨转移"

--清空btn
local btnName = aura_env.id.."Button"

aura_env.btn = _G[btnName]

--初始化btn
if not aura_env.btn then
    -- 战斗中无法创建按钮
    if not InCombatLockdown() then
        aura_env.btn = CreateFrame("Button", btnName, aura_env.region, "SecureActionButtonTemplate")
        aura_env.btn:SetAllPoints()
        aura_env.btn:SetAttribute("type","macro")
        aura_env.btn:SetAttribute("macrotext", macroStr)
        aura_env.btn:RegisterForClicks("LeftButtonDown")
        aura_env.btn:SetPassThroughButtons("RightButton")
        print(aura_env.initialized)
        aura_env.initialized = ""
    else
        aura_env.waitForOOC = true
    end
end

--重写职业名字染色，WA_ClassColorName会返回空置
aura_env.classColorName = function(unit)
    if unit and UnitExists(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if not class then
            return name
        else
            local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unit
    end
end

