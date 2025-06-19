local thisSpellIds = {
    [45182] = true, -- 装死
}
local globleVariableName = "JTWA_GROUP_SKILL_IGNORE_MYSELF"
if not _G[globleVariableName] then
    _G[globleVariableName] = {}
end

local ignoreMyself = _G[globleVariableName]

local addIgnoreMyself = function()
    for k, v in pairs(thisSpellIds) do
        ignoreMyself[k] = true
    end
end
addIgnoreMyself()