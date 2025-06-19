--版本信息
local version = 250530

local myGUID = UnitGUID("player")
local myName = UnitName("player")
local myClass = select(2, UnitClass("player"))

local THIS_GLYPH_ID = 405004 -- 清算雕文

local checkGlyph = function(checkGlyphId)
    if not checkGlyphId then return end
    local glyphInSocket = {}
    for i = 1, GetNumGlyphSockets() do
        local id = select(4,GetGlyphSocketInfo(i))
        if id then
            glyphInSocket[id] = true
        end
    end
    return glyphInSocket[checkGlyphId]
end

aura_env.isGlyphActive = function()
    return checkGlyph(THIS_GLYPH_ID)
end
