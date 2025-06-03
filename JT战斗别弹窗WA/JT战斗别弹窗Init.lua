--版本信息
local version = 250527

--author and header
local AURA_ICON = 135975
local AURA_NAME = "JT战斗别弹窗WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 135975)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local waitForOOC = false
local alerted = false

local globalName = "JTSIIsHooked"

aura_env.isHooked = _G[globalName]

local setHook = function()
    if not InviteTeamView then
        -- print("no ui")
        return
    else
        if not aura_env.isHooked then
            -- print("not hooked")
            hooksecurefunc(InviteTeamView, "Show", function()
                    if InCombatLockdown() then
                        if not alerted then
                            print(HEADER_TEXT.." 收到消息 战斗结束后显示SI窗口")
                            alerted = true
                        end
                        waitForOOC = true
                        InviteTeamView:Hide()
                    end
            end)
            aura_env.isHooked = true
            -- print("hooked")
        else
            -- print("already hooked")
        end
    end
end
setHook()

print(HEADER_TEXT.." 防止 |cff1785D1SenderInfo|r 在战斗中密语弹窗 |cffFFFFFF"..AUTHOR.."|r")

aura_env.OnTrigger = function(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if waitForOOC then
            waitForOOC = false
            InviteTeamView:Show()
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if not aura_env.isHooked then
            setHook()
        else
            -- print("already hooked")
        end
        if InviteTeamView and InviteTeamView:IsShown() then
            print(HEADER_TEXT.." 开始战斗 |cff1785D1SenderInfo|r窗口隐藏 战斗结束后自动显示")
            waitForOOC = true
            InviteTeamView:Hide()
        end
    end
end

