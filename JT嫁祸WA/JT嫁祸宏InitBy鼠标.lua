--版本信息 该WA创意源自 NGA 鼠标 所制作的 盗贼嫁祸快捷键设置WA
local version = 250320

--author and header
local AURA_ICON = 236283
local AURA_NAME = "JT嫁祸WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

aura_env.jhTargetA = ""
aura_env.jhTargetB = ""
aura_env.waitForUpdating={
    A = false,
    B = false
}
aura_env.waitForUpdatingName={
    A = nil,
    B = nil
}
aura_env.waitForUpdatingRealm={
    A = nil,
    B = nil
}

--[[ 不做宏 也不做按钮了

local jhBtn_Container
if not jhBtn_Container then
    jhBtn_Container = CreateFrame("Frame", "jhBtn_Container", UIParent)
end

if not _G["jhBtnA"] then
    aura_env.jhBtnA = CreateFrame(
        "Button",
        "jhBtnA",
        jhBtn_Container,
        "SecureActionButtonTemplate"
    ) 
    
    aura_env.jhBtnA:SetAttribute("type1", "macro")
    aura_env.jhBtnA:SetAttribute("macrotext", "/stopmacro [nogroup]\n/cast [@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]嫁祸诀窍")
else
    aura_env.jhBtnA = _G["jhBtnA"]
end


if not _G["jhBtnB"] then
    aura_env.jhBtnB = CreateFrame(
        "Button",
        "jhBtnB",
        jhBtn_Container,
        "SecureActionButtonTemplate"
    ) 
    
    aura_env.jhBtnB:SetAttribute("type1", "macro")
    aura_env.jhBtnB:SetAttribute("macrotext", "/stopmacro [nogroup]\n/cast [@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]嫁祸诀窍")
else
    aura_env.jhBtnB = _G["jhBtnB"]
end

jhBtn_Container:Show()
]]


aura_env.isTargetValid = function() 
    if not UnitInParty("player") then
        return false
    end
    
    if UnitName("mouseover") then
        if UnitName("mouseover") == UnitName("player") then
            return false
        else
            return UnitInRaid("mouseover") or UnitInParty("mouseover")
        end
        
    else
        if UnitName("target") then
            if UnitName("target") == UnitName("player") then
                return false
            else
                return UnitInRaid("target") or UnitInParty("target")
            end
        end
    end
end

aura_env.setTarget = function(states,btn,setName,setRealm)
    
    
    local targetName, targetRealm = UnitName("target")
    
    if UnitName("mouseover") then
        targetName, targetRealm = UnitName("mouseover")
    end
    
    if setName and UnitExists(setName) then
        targetName, targetRealm = setName, setRealm
    end
    
    local tBtn = nil
    local colorBtn = btn == "A" and "|cff94EF00" or "|cffEF573E"
    
    if btn == "A" then 
        tBtn = aura_env.jhBtnA
        aura_env.jhTargetA = targetName
    end
    if btn == "B" then 
        tBtn = aura_env.jhBtnB
        aura_env.jhTargetB = targetName
    end
    
    if not aura_env.isTargetValid() and not setName then
        states['jhNotice'] = {
            show = true,
            changed = true,
            progressType = "timed",
            duration = 3,
            expirationTime = GetTime()+3,
            name = "只能嫁祸队友",
            autoHide = true
        }
        return states
    end
    
    if InCombatLockdown() and not setName then
        if aura_env.waitForUpdatingName[btn] ~= targetName then
            print("[|CFF8FFFA2JT嫁祸WA|R]|CFF8FFFA2 正在战斗，稍后更新嫁祸"..colorBtn..btn.."|r: "..WA_ClassColorName(targetName))
        end
        
        aura_env.waitForUpdating[btn] = true
        aura_env.waitForUpdatingName[btn] = targetName
        aura_env.waitForUpdatingRealm[btn] = targetRealm
        states['jhNotice'] = {
            show = true,
            changed = true,
            progressType = "timed",
            duration = 3,
            expirationTime = GetTime()+3,
            name = "正在战斗，稍后更新目标",
            autoHide = true
        }
        return states
    end
    
    states['jhNotice'] = {
        show = true,
        changed = true,
        progressType = "timed",
        duration = 3,
        expirationTime = GetTime()+3,
        name = "设置成功，目标"..colorBtn..btn.."："..aura_env.classColorName(targetName),
        autoHide = true
    }
    
    local macroContent = "/cast [target="..targetName..",help,exists,nodead][@targettarget,help,nodead]嫁祸诀窍"
    if ( btn == "A" and aura_env.config.mouseOverA ) or ( btn == "B" and aura_env.config.mouseOverB ) then
        macroContent = "/cast [@mouseover,help,exists,nodead][target="..targetName..",help,exists,nodead][@targettarget,help,nodead]嫁祸诀窍"
    end
    
    local whisperName = ( targetRealm and targetRealm ~= "" ) and targetName.."-"..targetRealm or targetName
    
    if aura_env.config.oorWhisper then
        macroContent = "/run local u,pi='"..whisperName.."','嫁祸诀窍';if IsSpellInRange(pi,u)==0 and GetSpellCooldown(pi)==0 then SendChatMessage(' (:o): 太远了，嫁祸不到你!','WHISPER',nil,'"..whisperName.."') end\n"..macroContent
    end
    
    print("|T236283:12:12:0:0:64:64:4:60:4:60|t[|CFF8FFFA2JT嫁祸WA|R]|CFF8FFFA2 设置成功，嫁祸"..colorBtn..btn.."|r: "..aura_env.classColorName(whisperName))
    
    -- tBtn:SetAttribute("macrotext", macroContent)
    
    WeakAuras.ScanEvents("JHUPDATENAME",btn,targetName)
    return states
end

aura_env.clearAllData = function() 
    aura_env.jhTargetA = ""
    aura_env.jhTargetB = ""
    aura_env.waitForUpdating={
        A = false,
        B = false
    }
    aura_env.jhBtnA:SetAttribute("macrotext", "/stopmacro [nogroup]\n/cast [@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]嫁祸诀窍")
    aura_env.jhBtnB:SetAttribute("macrotext", "/stopmacro [nogroup]\n/cast [@mouseover,help,exists,nodead][@target,help,exists,nodead][@targettarget,help,nodead]嫁祸诀窍")
    WeakAuras.ScanEvents("JHUPDATENAME","CLEAR")
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

aura_env.OnTrigger = function(e, event, ...)
    if event == "SETJHTARGETA" then
        aura_env.setTarget(e,"A")
        return true
    end
    
    if event == "SETJHTARGETB" then
        aura_env.setTarget(e,"B")
        return true
    end
    
    if event == "PLAYER_REGEN_ENABLED" then
        if aura_env.waitForUpdating["A"] then 
            e = aura_env.setTarget(e,"A",aura_env.waitForUpdatingName["A"],aura_env.waitForUpdatingRealm["A"]) 
            aura_env.waitForUpdating["A"] = false
        end
        
        if aura_env.waitForUpdating["B"] then 
            e = aura_env.setTarget(e,"B",aura_env.waitForUpdatingName["B"],aura_env.waitForUpdatingRealm["B"])
            aura_env.waitForUpdating["B"] = false
        end
        
        return true
    end
    
    if event == "GROUP_ROSTER_UPDATE" then
        if not IsInGroup() and not IsInRaid() then
            aura_env.clearAllData()
        end
    end

end