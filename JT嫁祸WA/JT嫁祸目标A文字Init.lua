-- 按钮文字
local buttonId = 1

local macroSymbol = {
	[1] = "|cff94EF00JTA|r",
	[2] = "|cffEF573EJTB|r",
	[3] = "|cff28ABE0JTX|r",
	[4] = "|cffF4D81EJTY|r",
}

local theMacroSymbol = macroSymbol[buttonId]
local theSpellShortName = "嫁祸"
local theText = ""
local missingText = "(|CFFFF53A2失踪|R)"

local theTargetName = ""
local enableButton = false
local enableClick = false

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

local resetText = function()
    if enableButton then
        if enableClick and (IsInGroup() or IsInRaid()) then
            theText = theTargetName == "" and ("<-点击设置"..theSpellShortName..theMacroSymbol) or theTargetName
        else
            theText = theTargetName
        end
    else
        theText = ""
    end
end
resetText()

aura_env.OnTrigger = function(event, ...)
    if event == "JT_TOT_UPDATE_TARGET" then
        local id, setSpellShortName, setTargetName, isMissing = ...
        if id == buttonId then
            theSpellShortName = setSpellShortName or theSpellShortName
            if setTargetName and setTargetName ~= "" then
                theTargetName = theSpellShortName..theMacroSymbol.." "..classColorName(setTargetName)..(isMissing and missingText or "")
                theText = theTargetName
                resetText()
            else
                theTargetName = ""
                resetText()
            end
            return true
        end
    end
end

aura_env.TryToSetText = function(event, ...)
    if event == "JT_TOT_UPDATE_TARGET_BUTTON_TEXT" then
        local id, setEnableButton, setEnableClick = ...
        if id == buttonId then
            enableButton = setEnableButton
            enableClick = setEnableClick
            resetText()
        end
        return true
    end
end

aura_env.getText = function()
    return theText or ""
end
