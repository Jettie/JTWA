aura_env.timestampText = ""

aura_env.OnTrigger = function(event, ...)
    if event == "JT_WA_DEFILE_DEJAVU_TIMESTAMPTEXT" then
        aura_env.timestampText = ...
        if aura_env.timestampText and aura_env.timestampText ~= "" then
            return true
        end
    end
end

aura_env.OnHide = function(event, ...)
    if event == "JT_WA_DEFILE_DEJAVU_TIMESTAMPTEXT" then
        aura_env.timestampText = ...
        if not aura_env.timestampText or  aura_env.timestampText == "" then
            return true
        end
    end
end