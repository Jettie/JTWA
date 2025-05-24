--版本信息
local version = 250415

--author and header
local AURA_ICON = 132363
local AURA_NAME = "JT战士破甲雕文提醒WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

local sunderArmorGlyphId = 58387
-- local sunderArmorGlyphId = 58357 -- 测试 英勇打击雕文

local ttsText = "你还用着破甲雕文 注意更换天赋雕文"
local ttsSpeed = 2

local glyphSocketPositionName = {
    [1] = "大雕文-上",
    [2] = "小雕文-下",
    [3] = "小雕文-左上",
    [4] = "大雕文-右下",
    [5] = "小雕文-右上",
    [6] = "大雕文-左下",
}

local checkGlyph = function(checkGlyphId)
    if not checkGlyphId then return end
    local glyphInSocket = {}
    for i = 1, GetNumGlyphSockets() do
        local id = select(4,GetGlyphSocketInfo(i))
        if id then
            glyphInSocket[id] = i
        end
    end
    return glyphInSocket[checkGlyphId]
end

aura_env.CheckSAGlyph = function()
    local GlyphInSocket = checkGlyph(sunderArmorGlyphId)
     if GlyphInSocket then
        aura_env.glyphInSocket = GlyphInSocket
        return true
     else
        aura_env.glyphInSocket = nil
        return false
     end
end

aura_env.lastPrintTime = 0
aura_env.PrintGlyphInfo = function()
    local now = GetTime()
    if now - aura_env.lastPrintTime < 0.5 then return end
    aura_env.lastPrintTime = now
    local spellLink = GetSpellLink(sunderArmorGlyphId)
    print(HEADER_TEXT.."你还用着"..(spellLink or "破甲雕文").."("..(glyphSocketPositionName[aura_env.glyphInSocket] or "?")..") 注意更换天赋雕文")
    if aura_env.config.isVoice then
        C_VoiceChat.SpeakText(0, (ttsText or ""), 0, (ttsSpeed or 0), 100)
    end
end

