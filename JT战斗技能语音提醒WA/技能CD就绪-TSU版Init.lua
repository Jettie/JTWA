local thisSpellId = 49938
local file = "DK\\凋零好了.ogg"
local ttsText = "凋零就绪"
local ttsSpeed = 1
local timeBeforeExpire = 0.5

local thisSpellName = GetSpellInfo(thisSpellId)
local createCDTimerById = function(e, spellId)
    local startTime, duration = GetSpellCooldown(spellId)
    local expirationTime = startTime + duration

    if expirationTime > 0 then
        local remindTime = expirationTime - timeBeforeExpire
        local remindDuration = duration - timeBeforeExpire
        if remindTime > 0 then
            if not e[spellId] then
                e[spellId] = {
                    spellId = spellId,
                    show = true,
                    changed = true,
                    progressType = "timed",
                    autoHide = true,
                }
            end
            e[spellId].expirationTime = remindTime
            e[spellId].duration = remindDuration
            return true
        end
    end
end

aura_env.OnHide = function()
    if aura_env.config.isVoice then
        if GetSpellCooldown(aura_env.state.spellId) == 0 then return end
        local function tryPSFOrTTS(filePath, text, speed)
            local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
            local filePSF = PATH_PSF..(filePath or "")
            local canplay = PlaySoundFile(filePSF, "Master")
            if not canplay then
                C_VoiceChat.SpeakText(0, (text or ""), 0, (speed or 0), 100)
            end
        end

        if JTS and JTS.P then
            local canplay = JTS.P(file)
            if not canplay then
                tryPSFOrTTS(file, ttsText, ttsSpeed)
            end
        else
            tryPSFOrTTS(file, ttsText, ttsSpeed)
        end
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitTarget, _, spellId = ...
        if unitTarget == "player" and (spellId == thisSpellId or thisSpellName == GetSpellInfo(spellId)) then
            -- GetSpellCooldown need a tiny delay
            C_Timer.After(0.1,function()
                WeakAuras.ScanEvents("JT_SPELLREADY", spellId)
            end)
        end
    elseif event == "JT_SPELLREADY" then
        local spellId = ...
        if (spellId == thisSpellId or thisSpellName == GetSpellInfo(spellId)) then
            return createCDTimerById(e, spellId)
        end
    end
end
