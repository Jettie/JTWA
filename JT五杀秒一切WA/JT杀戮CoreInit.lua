--版本信息
local version = 250223
local requireJTSVersion = 12
local soundPack = "TTS"
local voicePackCheck = true --check过VP就会false
local killingSpreeFiveShaFile = "Common\\KillingSpree.ogg"
local killingSpreeNowFile = "Common\\杀.ogg"

--author and header
local AURA_ICON = 236277
local AURA_NAME = "JT五杀秒一切WA"
local AUTHOR = "Jettie@SMTH"
local SMALL_ICON = "|T"..(AURA_ICON or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
local HEADER_TEXT = SMALL_ICON.."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 "

--JTDebug
local JTDebug = false
local jtprint = function(text)
    if JTDebug then
        print(HEADER_TEXT.."Debug |CFFFF53A2:|R "..(text or "nil"))
    end
end
local ToggleDebug = function()
    JTDebug = not JTDebug
    print(HEADER_TEXT.."JTD(KillingSpree) : Debug - "..(JTDebug and "|CFF00FF00ON|R" or "|CFFFF0000OFF|R"))
end

--语音包检测
local CHECK_FILE = killingSpreeFiveShaFile
local SOUND_FILE_MISSING = "无法播放五杀音效 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听")
local REQUIRE_VERSION = requireJTSVersion
local checkVoicePack = function()
    if voicePackCheck then
        local auraIcon = AURA_ICON or 135428
        local auraName = AURA_NAME or "JT系列WA"
        local author = AUTHOR or "Jettie@SMTH"
        local smallIcon = "|T"..(auraIcon or 133434)..":12:12:0:0:64:64:4:60:4:60|t"
        local headerText = smallIcon.."[|CFF8FFFA2"..auraName.."|R]|CFF8FFFA2 "

        local checkFile = CHECK_FILE or "Common\\biubiubiu.ogg"
        local soundFileMissing = SOUND_FILE_MISSING or ( "将使用TTS播报声 -"..(JTS and "请更新最新版 |CFFFF53A2JTSound|R 插件" or "建议安装 |CFFFF53A2JTSound|R 语音包插件，好听耐听") )
        local requireVersion = REQUIRE_VERSION or 0

        print(headerText.."作者:|R "..author)

        if aura_env.config.isVoice then
            local function tryCheckPSF(filePath)
                local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
                local file = PATH_PSF..(filePath or "")
                local canplay, soundHandle = PlaySoundFile(file, "Master")
                local voicePack
                if canplay then
                    StopSound(soundHandle)
                    voicePack = JTS and "JTSound" or "VoicePack"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    voicePack = "TTS"
                    print(headerText.."|CFFFFE0B0未找到语音文件|R，"..soundFileMissing.."|R")
                end
                return voicePack
            end

            if JTS and JTS.P then
                local canplay, soundHandle = JTS.P(checkFile, requireVersion)
                if canplay and soundHandle then
                    StopSound(soundHandle)
                    soundPack = "JTSound"
                    print(headerText.."|CFFFF53A2Perfect!|R 检测到语音包|R")
                else
                    soundPack = tryCheckPSF(checkFile)
                end
            else
                soundPack = tryCheckPSF(checkFile)
            end
        end
        voicePackCheck = false
    end
end
checkVoicePack()

--杀戮触发
local myGUID = UnitGUID("player")

local timers = {}

local killingSpreeSpellId = 51690
local killingSpreeBuffId = 51690
local mhKillingSpreeDamageSpellId = 57841
local ohKillingSpreeDamageSpellId = 57842

local KILLING_SPREE_GLYPH_ID = 63252
local KS_CD = 120
local KS_CD_WITH_GLYPH = 75
local checkGlyph = function(checkGlyphId)
    if not checkGlyphId then return end
    local glyphInSocket = {}
    for i = 1, GetNumGlyphSockets() do
        local id = select(3,GetGlyphSocketInfo(i))
        if id then
            glyphInSocket[id] = true
        end
    end
    return glyphInSocket[checkGlyphId]
end

local killingSpreeCD = checkGlyph(KILLING_SPREE_GLYPH_ID) and KS_CD_WITH_GLYPH or KS_CD

local initData = function()
    --准备reset伤害统计数据，暂时没有
end

local checkUnitInRange = function(unit)
    return IsItemInRange(32321, unit)
end

local checkTargetIsClose = function()
    return IsItemInRange(34368, "target")
end

local lastCount = 0
local createSha = function(e, id, shaNumber, shaTarget)
    local shaId = id
    e[shaId] = {}
    if shaNumber and shaTarget then
        e[shaId] = {
            name = "sha"..id,
            icon = 236277,
            total = 5,
            value = 5, -- + GetTime(),

            index = id,
            shaNumber = shaNumber,

            unitGUID = shaTarget.unitGUID,
            isTarget = shaTarget.isTarget,
            isInRange = shaTarget.isInRange,
            checkTargetIsClose = shaTarget.checkTargetIsClose,

            show = true,
            changed = true,
        }
    end
end

local OnKillingSpreeHit = function(e, ...)
    local isBloodAnime =  aura_env.config.isBloodAnime
    local destGUID, offhand, show, amount = ...

    if show then
        --优先刷新对应GUID的state
        for k, v in pairs(e) do
            if v.unitGUID == destGUID and v.show == true then
                e[k].beaten = true

                if offhand then
                    e[k].ohHits = e[k].ohHits and (e[k].ohHits + 1) or 1
                else
                    e[k].blood = isBloodAnime
                    e[k].mhHits = e[k].mhHits and (e[k].mhHits + 1) or 1
                end

                e[k].totalHits = e[k].totalHits and (e[k].totalHits + 1) or 1
                e[k].hits = math.max((e[k].mhHits or 0), (e[k].ohHits or 0))

                e[k].damage = e[k].damage and (e[k].damage + amount) or amount

                e[k].changed = true
                return true
            end
        end
        --没有对应GUID，就先找个没有被打过的state，强制修改为当前GUID
        for k, v in pairs(e) do
            if not v.beaten and v.show == true then
                e[k].unitGUID = destGUID
                e[k].beaten = true

                if offhand then
                    e[k].ohHits = e[k].ohHits and (e[k].ohHits + 1) or 1
                else
                    e[k].blood = isBloodAnime
                    e[k].mhHits = e[k].mhHits and (e[k].mhHits + 1) or 1
                end

                e[k].totalHits = e[k].totalHits and (e[k].totalHits + 1) or 1
                e[k].hits = math.max((e[k].mhHits or 0), (e[k].ohHits or 0))

                e[k].damage = e[k].damage and (e[k].damage + amount) or amount

                e[k].changed = true
                return true
            end
        end
        --所有state都被打过，还有新的hit，需要补state
        local eTemp 
        for i = 1, 5 do
            if e[i] and e[i].beaten then
                eTemp = eTemp or e[i]
            end

            if not e[i] then

                local newSha = {
                    unitGUID = destGUID,
                    isTarget = (destGUID == ((UnitExists("target") and not UnitIsDead("target")) and UnitGUID("target") or nil)) and true or false,
                    isInRange = true,
                    checkTargetIsClose = false
                }

                local shaNumber = eTemp and (eTemp.shaNumber or i) or i
                createSha(e, i, shaNumber, newSha)

                for _, v in pairs(e) do
                    v.shaNumber = v.shaNumber < 5 and v.shaNumber + 1 or v.shaNumber
                end
                return true
            end
        end
    else
        for k, v in pairs(e) do
            if v.unitGUID == destGUID and v.blood then
                e[k].blood = false
                e[k].changed = true
                return true
            end
        end
    end
end

local OnKillingSpreeCheck = function(e, ...)
    local targetGUID = ((UnitExists("target") and not UnitIsDead("target")) and UnitGUID("target") or nil)

    local count = 0
    local targetIncluded = false

    local shaFive = {}
    local startIfNotTarget = targetGUID and 1 or 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitCanAttack("player", unit) then
            local unitGUID = UnitGUID(unit)
            local isInRange = checkUnitInRange(unit)

            if targetGUID and unitGUID == targetGUID then
                targetIncluded = true

                count = count + 1
                shaFive[1] = {
                    unitGUID = unitGUID,
                    isTarget = true,
                    isInRange = isInRange,
                    checkTargetIsClose = checkTargetIsClose()
                }

            elseif isInRange then
                count = count + 1
                if startIfNotTarget <= 4 then
                    shaFive[startIfNotTarget+1] = {
                        unitGUID = unitGUID,
                        isTarget = false,
                        isInRange = isInRange,
                        checkTargetIsClose = false
                    }
                    startIfNotTarget = startIfNotTarget + 1
                end
            end
        end
    end

    if lastCount ~= count then
        jtprint("count=|CFFFFFFFF"..count.."|R shaFive=|CFFFFFFFF"..#shaFive.."|R targetIncluded="..(targetIncluded and "true" or "|CFFFF53A2false|R"))
        lastCount = count
    end

    for i = 1, 5 do
        if i > #shaFive then
            createSha(e, i)
        else

            local shaTarget = shaFive[i]
            local name = "sha"..i
            local total = 3
            local value = total + GetTime()
            createSha(e, i, #shaFive, shaTarget)
        end
    end
    return true
end

local stopChecking = function()
    if timers.checkingTicker then
        timers.checkingTicker:Cancel()
    end
end

local startChecking = function(forceStart)
    if (not IsSpellKnown(killingSpreeSpellId) or not UnitAffectingCombat("player")) and not forceStart then return end
    if aura_env.config.onlyBoss and not WeakAuras.CurrentEncounter then return end

    local ksCDStartTime, ksDuration = GetSpellCooldown(killingSpreeSpellId)
    local ksCD = (ksCDStartTime + ksDuration) - GetTime()
    local ksCDModified = forceStart and 2 or ksCD
    if ksCDModified < 3 then
        local speed = 0.05
        if not timers.checkingTicker or timers.checkingTicker:IsCancelled() then
            initData()
            timers.checkingTicker = C_Timer.NewTicker(speed, function() WeakAuras.ScanEvents("JT_KILLINGSPREE_CHECK") end)
        end
    end
end

local killingSpreeLogs = {}
local lastLog = {}
local calculateResult = function(subevent, amount, offhand)
    local result = {}

    --杀戮打了多少伤害
    --杀戮命中情况，打出了几次杀戮，命中几下，总计多少伤害
    --杀戮buff存在期间，打了几次普攻
end

local clearAll = function(e)
    stopChecking()
    for k, v in pairs(e) do
        if v.show then
            e[k].show = false
        end
    end
    return true
end

local OnCLEUF = function(e, ...)
    --All args
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24 = ...

    if subevent == "SPELL_CAST_SUCCESS" and myGUID == sourceGUID then
        local spellId, spellName, spellSchool = select(12, ...)
        if spellId == killingSpreeSpellId then
            WeakAuras.ScanEvents("JT_KILLINGSPREE_STOPCHECK")
            --杀戮开始的时候刷新一次检测
            WeakAuras.ScanEvents("JT_KILLINGSPREE_CHECK")
            local remindKillingSpreeTime = killingSpreeCD - 1

            timers.nextKSTimer = C_Timer.NewTimer(remindKillingSpreeTime, function()
                    WeakAuras.ScanEvents("JT_KILLINGSPREE_STARTCHECK")
            end)
        end
    elseif subevent == "SPELL_AURA_APPLIED" and myGUID == sourceGUID then
        local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
    elseif subevent == "SPELL_AURA_REMOVED" and myGUID == sourceGUID then
        local spellId, spellName, spellSchool, auraType, amount = select(12, ...)
        if spellId == killingSpreeBuffId then
            local waitTime = 3.5
            if not timers.checkingTicker or timers.checkingTicker:IsCancelled() then
                timers.checkingTicker = C_Timer.NewTicker(waitTime, function()
                        WeakAuras.ScanEvents("JT_KILLINGSPREE_HIDE")
                end)
            end
        end
    elseif subevent == "SWING_DAMAGE" and myGUID == sourceGUID then
        local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
        local isKSBuffed = WA_GetUnitBuff("player", killingSpreeBuffId)
        if isKSBuffed then
            calculateResult(subevent, amount)
        end
    elseif subevent == "SPELL_DAMAGE" and myGUID == sourceGUID then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
        if spellId == mhKillingSpreeDamageSpellId then
            local offhand = false
            WeakAuras.ScanEvents("JT_KILLINGSPREE_HIT", destGUID, offhand, true, amount) -- isOffhand 0主手1副手
            calculateResult(subevent, amount, offhand)
            --仅主手触发飙血
            C_Timer.After(0.4, function()
                    WeakAuras.ScanEvents("JT_KILLINGSPREE_HIT", destGUID, offhand, false)
            end)
        elseif spellId == ohKillingSpreeDamageSpellId then
            local offhand = true
            WeakAuras.ScanEvents("JT_KILLINGSPREE_HIT", destGUID, offhand, true, amount)
            calculateResult(subevent, amount, offhand)
            -- C_Timer.After(0.4, function()
            --     WeakAuras.ScanEvents("JT_KILLINGSPREE_HIT", destGUID, offhand, false)
            -- end)
        end
    end
end

aura_env.canTriggerSha = false --当身边多余2个目标时为true，再次为1个目标时播放-杀
aura_env.playKillingSpreeSound = function(isFiveSha)
    if aura_env.config.isVoice then
        local file = isFiveSha and killingSpreeFiveShaFile or killingSpreeNowFile
        local function tryPSF(filePath)
            local PATH_PSF = ([[Interface\AddOns\JTSound\Sound\]])
            local filePSF = PATH_PSF..(filePath or "")
            PlaySoundFile(filePSF, "Master")
        end

        if JTS and JTS.P then
            local canplay = JTS.P(file)
            if not canplay then
                tryPSF(file)
            end
        else
            tryPSF(file)
        end
    end
end

aura_env.OnTrigger = function(e, event, ...)
    if event == "JT_KILLINGSPREE_CHECK" then
        return OnKillingSpreeCheck(e, ...)
    elseif event == "PLAYER_REGEN_DISABLED" then
        WeakAuras.ScanEvents("JT_KILLINGSPREE_STARTCHECK")
    elseif event == "JT_KILLINGSPREE_STARTCHECK" then
        local forceStart = ...
        if forceStart then
            print(HEADER_TEXT.."Start checking (|CFFFFFFFFForced|R)")
        end
        startChecking(forceStart)
    elseif event == 'PLAYER_REGEN_ENABLED' then
        return clearAll(e)
    elseif event == "JT_KILLINGSPREE_STOPCHECK" then
        stopChecking()
    elseif event == "JT_KILLINGSPREE_CHECK" then
        return OnKillingSpreeCheck(e, ...)
    elseif event == "JT_KILLINGSPREE_HIDE" then
        return clearAll(e)
    elseif event == "JT_KILLINGSPREE_HIT" then
        return OnKillingSpreeHit(e, ...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCLEUF(e, CombatLogGetCurrentEventInfo())
    elseif event == "GLYPH_UPDATED" then
        killingSpreeCD = checkGlyph(KILLING_SPREE_GLYPH_ID) and KS_CD_WITH_GLYPH or KS_CD
    elseif event == "OPTIONS" then
        stopChecking()
    elseif event == "JT_D_KILLINGSPREE" then
        ToggleDebug()
    end
end



