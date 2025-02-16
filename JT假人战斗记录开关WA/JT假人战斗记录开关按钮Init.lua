aura_env.clickToStart = "|CFF8FFFA2点击开启|R\n战斗记录\n"
aura_env.clickToEnd = "|CFFFF53A2点击结束|R\n战斗记录\n"
aura_env.processing = "."

aura_env.logging = LoggingCombat() and true or false

aura_env.btnText = aura_env.clickToStart

aura_env.btn = _G[aura_env.id]

--创建按钮
function aura_env.creatButton()
    if not aura_env.btn then
        aura_env.btn = CreateFrame("Button", aura_env.id, aura_env.region)
        aura_env.btn:SetAllPoints()
        aura_env.btn:SetScript("OnClick", function(self, button, down)
                if button == "LeftButton" then
                    local status = LoggingCombat()
                    local s = status
                    if status == nil then
                        WeakAuras.ScanEvents('JT_ISLOGGING',LoggingCombat())
                    elseif status ~= nil then
                        if status == true then
                            LoggingCombat(false)

                            WeakAuras.ScanEvents('JT_ISLOGGING',LoggingCombat())
                        elseif status == false then
                            LoggingCombat(true)

                            WeakAuras.ScanEvents('JT_ISLOGGING',LoggingCombat())
                        end
                    end
                    --WeakAuras.ScanEvents('JT_FAKETOTTARGET',"A")
                end
                --print("Pressed A", button, down and "down" or "up")
        end)
        aura_env.btn:RegisterForClicks("LeftButtonDown")
        aura_env.btn:SetPassThroughButtons("RightButton")
    end
end

aura_env.creatButton()