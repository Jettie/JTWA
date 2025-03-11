local myName = UnitName("player")

local spellId = aura_env.state.spellId
local destName = aura_env.state.destName

if IsInGroup() then
    -- 密语目标
    if aura_env.config.whisperTarget then
        SendChatMessage("已对你使用 "..(GetSpellLink(spellId) or "").." ! 别睡了, 起来嗨!", "WHISPER", nil, destName)
    end

    -- 密语团长
    if aura_env.config.reportToRL then
        for i = 1, GetNumGroupMembers() do
            local name, rank, subgroup = GetRaidRosterInfo(i)
            if name ~= myName then
                if rank == 2 then
                    SendChatMessage("报告! "..destName.." 已经被我复活了!", "WHISPER", nil, name)
                end
            end
        end
    end

    --团队通报
    if aura_env.config.reportInRaid then
        SendChatMessage("已对 "..destName.." 使用了 "..(GetSpellLink(spellId) or "").." ! 快叫他起床!", "RAID")
    end
end

