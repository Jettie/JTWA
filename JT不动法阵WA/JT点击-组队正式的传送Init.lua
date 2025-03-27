--版本信息
local version = 250324

local AURA_ICON = 237560
local AURA_NAME = "JT不动法阵WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "



--点击版改动部分写这里
local thisSpellText = "组队时|CFFFFF569正式的|R"
local spellId = 48020 -- 正式的 传送

-- local thisSpellText = "|CFF1785D1测试的|R"
-- local spellId = 1454 -- 测试的 生命分流

local spellName = GetSpellInfo(spellId)
local spellLink = GetSpellLink(spellId)

local castStr = "/cast %s"
local macroStr = castStr:format(spellName)

local CAN_NOT_CREATE_BTN_IN_COMBAT = HEADER_TEXT.."|CFFFF53A2战斗中无法初始化猛点按钮("..thisSpellText..(spellLink or "")..")|R 战斗结束后自动自动初始化"
local CAN_NOT_SHOW_BTN_IN_COMBAT = HEADER_TEXT.."战斗中无法|CFFFF53A2激活|R猛点按钮("..thisSpellText..(spellLink or "")..") 战斗结束后自动激活\n本次战斗中 |CFFFF53A2注意不要消失! 注意不要消失! 注意不要消失! |R"
local SHOW_BTN_AFTER_COMBAT = HEADER_TEXT.."战斗结束猛点按钮|CFFFF53A2激活|R成功("..thisSpellText..(spellLink or "")..")"
local CAN_NOT_HIDE_BTN_IN_COMBAT = HEADER_TEXT.."战斗中无法|CFFFFFFFF隐藏|R猛点按钮("..thisSpellText..(spellLink or "")..") 战斗结束后自动隐藏"
local HIDE_BTN_AFTER_COMBAT = HEADER_TEXT.."战斗结束猛点按钮|CFFFFFFFF隐藏|R成功("..thisSpellText..(spellLink or "")..")"
local INITIALIZED = HEADER_TEXT.."猛点按钮("..thisSpellText..(spellLink or "")..")初始化成功 (|CFFFF53A23.4.4版|R) - 作者:|R "..AUTHOR

--清空btn
local btnName = aura_env.id.."Button"

aura_env.btn = _G[btnName]

aura_env.createBtn = function()
    if not aura_env.btn then
        if not InCombatLockdown() then
            aura_env.btn = CreateFrame("Button", btnName, aura_env.region, "SecureActionButtonTemplate")
            aura_env.btn:SetAllPoints()
            aura_env.btn:SetAttribute("type","macro")
            aura_env.btn:SetAttribute("macrotext", macroStr)
            aura_env.btn:RegisterForClicks("LeftButtonDown","RightButtonDown")
            print(INITIALIZED)
            INITIALIZED = ""
        else
            print(CAN_NOT_CREATE_BTN_IN_COMBAT)
            aura_env.waitForOOC = true
        end
    end
end
aura_env.createBtn()

aura_env.showBtn = function()
    if aura_env.btn then
        if InCombatLockdown() then
            print(CAN_NOT_SHOW_BTN_IN_COMBAT)
            aura_env.waitForOOCShowBtn = true
            aura_env.waitForOOCHideBtn = false
        else
            aura_env.btn:Show()
        end
    else
        aura_env.createBtn()
    end
end

aura_env.hideBtn = function()
    if aura_env.btn then
        if InCombatLockdown() then
            print(CAN_NOT_HIDE_BTN_IN_COMBAT)
            aura_env.waitForOOCHideBtn = true
            aura_env.waitForOOCShowBtn = false
        else
            aura_env.btn:Hide()
        end
    else
        aura_env.createBtn()
    end
end

aura_env.OnPlayerRegenEnabled = function()
    if not aura_env.btn then
        if aura_env.waitForOOC then
            aura_env.creatButton()
            print(INITIALIZED)
            INITIALIZED = ""
            aura_env.waitForOOC = false
        end
    else
        if aura_env.waitForOOCShowBtn then
            aura_env.showBtn()
            print(SHOW_BTN_AFTER_COMBAT)
            aura_env.waitForOOCShowBtn = false
        end
        if aura_env.waitForOOCHideBtn then
            aura_env.hideBtn()
            print(HIDE_BTN_AFTER_COMBAT)
            aura_env.waitForOOCHideBtn = false
        end
    end
end