--版本信息
local version = 250525

--author and header
local AURA_ICON = 135975
local AURA_NAME = "JT嫁祸不要密我WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 135975)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local config = aura_env.config
local muteToT = config.totDND
local LOAD_TEXT = config.totDND and "|cff00ff00已开启|r 将自动阻止嫁祸WA的密语" or "|cffff0000已关闭|r 现在开始接收密语"

local myName = UnitName("player")
local myClass = select(2, UnitClass("player"))

--重写职业名字染色，WA_ClassColorName会返回空置
local classColorName = function(unit)
    if unit and UnitExists(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if not class then
            return name
        else
            local classData = (RAID_CLASS_COLORS)[class]
            local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
            return coloredName
        end
    else
        return unit
    end
end

if config.totDND then
    if config.receiveWhisper then
        for i = 1, #config.receiveWhisper do
            if config.receiveWhisper[i].name == myName then
                muteToT = false
                LOAD_TEXT = "当前角色 |cffffffff"..classColorName(myName).."|r 为豁免角色，将继续接收嫁祸密语"
            end
        end
    end
end

print(HEADER_TEXT..LOAD_TEXT)


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

local OnGroupRosterUpdate = function()
    if not IsInGroup() then
        return
    else
        local channel = getChannel()
        local msg = muteToT and "dnd" or "undnd"
        if channel then
            C_ChatInfo.SendAddonMessage("JTETOTDISTRUB", msg, channel, nil)
        end
    end
end

aura_env.OnTrigger = function(event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        OnGroupRosterUpdate()
    end
end