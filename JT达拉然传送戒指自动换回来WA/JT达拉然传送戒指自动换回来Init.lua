--版本信息
local version = 250525

--solo header
local AURA_ICON = 133416
local AURA_NAME = "JT系列WA"
local HEADER_TEXT = ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[|CFF8FFFA2"..AURA_NAME.."|R]|CFF8FFFA2 " 
local ONLY_ICON = ( AURA_ICON and "|T"..AURA_ICON..":12:12:0:0:64:64:4:60:4:60|t" or "|T236283:12:12:0:0:64:64:4:60:4:60|t" ).."[%s]|CFF8FFFA2 "

print(ONLY_ICON:format("|CFF8FFFA2JT达拉然传送戒指自动换回来WA|R").."作者:|R Jettie@SMTH")

local msgJTE = true

local kirinTorTeleportId = 54406
--local kirinTorTeleportId = 51723 --刀扇测试

local waitToSwitchBack = {}
local previousEquipmentId = {}
local kirinTorRings = {
    --ilv 200
    [40585] = true,
    [40586] = true,
    [44934] = true,
    [44935] = true,
    --ilv 213
    [45688] = true,
    [45689] = true,
    [45690] = true,
    [45691] = true,
    --ilv 226
    [48954] = true,
    [48955] = true,
    [48956] = true,
    [48957] = true,
    --ilv 251
    [51557] = true,
    [51558] = true,
    [51559] = true,
    [51560] = true,
}
--测试物品名字，等ICC更新后再测一次删除
local printItemNames = function()
    local count = 0
    for k, v in pairs(kirinTorRings) do
        local name = GetItemInfo(k)
        print(HEADER_TEXT.."id="..k.." name="..(name or "NONAME"))
        if name then
            count = count + 1
        end
    end
    print(HEADER_TEXT.."Total #|CFFFFFFFF"..count.." rings.")
end

local saveInventoryItemId = function()
    --装备记录
    for i = 1, 19 do
        local itemId = GetInventoryItemID("player", i)
        if itemId then
            previousEquipmentId[i] = itemId
        end
    end
end
saveInventoryItemId()

local secondsToTimeStr = function(seconds)
    -- 计算小时
    local hours = math.floor(seconds / 3600)
    -- 计算剩余的分钟数
    local minutes = math.floor((seconds % 3600) / 60)
    -- 计算剩余的秒数
    local secs = seconds % 60
    
    -- 格式化输出，确保小时、分钟和秒都是两位数
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, secs)
    
    return timeString
end

local OnEquipmentChanged = function(equipmentSlot, hasCurrent)
    --肯瑞托传送戒指换回来功能,穿戴肯瑞托戒指时记录
    if equipmentSlot == INVSLOT_FINGER1 or equipmentSlot == INVSLOT_FINGER2 then
        local newId = GetInventoryItemID("player", equipmentSlot)
        if kirinTorRings[newId] then
            for k, v in pairs(waitToSwitchBack) do
                if v == newId then
                    waitToSwitchBack[k] = nil
                end
            end
            waitToSwitchBack[equipmentSlot] = (previousEquipmentId[equipmentSlot] ~= newId) and previousEquipmentId[equipmentSlot] or nil
            local itemLink = select(2, GetItemInfo(newId))
            local previousItemLink = select(2, GetItemInfo(waitToSwitchBack[equipmentSlot]))
            print(ONLY_ICON:format("|CFF8FFFA2JT达拉然传送戒指自动换回来WA|R").."已佩戴 "..(itemLink or "[肯瑞托戒指]").. " 等待传送后换回 "..(previousItemLink or "之前的戒指"))

            if GetItemCooldown(newId) > 0 and not IsAltKeyDown() then
				-- 物品冷却中
				-- 肯瑞托戒指
				local itemIdFinger1 = GetInventoryItemID("player", INVSLOT_FINGER1)
				local itemIdFinger2 = GetInventoryItemID("player", INVSLOT_FINGER2)

				local thisItemId = kirinTorRings[itemIdFinger1] and itemIdFinger1 or (kirinTorRings[itemIdFinger2] and itemIdFinger2 or nil)
				local thisSlot = kirinTorRings[itemIdFinger1] and INVSLOT_FINGER1 or (kirinTorRings[itemIdFinger2] and INVSLOT_FINGER2 or nil)

				if thisSlot then
					local start, duration, enable = GetInventoryItemCooldown("player", thisSlot)
						if enable == 1 and start > 0 then
							local timeLeft = start + duration - GetTime()
							local kirinLink = thisItemId and GetItemInfo(thisItemId) or "[肯瑞托戒指]"
						if waitToSwitchBack[thisSlot] then
							EquipItemByName(waitToSwitchBack[thisSlot], thisSlot)
							print(HEADER_TEXT.."冷却中，剩余时间: |CFFFFFFFF"..secondsToTimeStr(timeLeft).."|R 秒, 已自动换回之前的"..previousItemLink.."(按住 |CFFFFFFFFAlt|R 键拖到装备栏强制穿戴)")
							waitToSwitchBack[thisSlot] = nil
						end
					end
				end
            end

        else
            if waitToSwitchBack[equipmentSlot] then
                waitToSwitchBack[equipmentSlot] = nil
            end
        end
    end
    saveInventoryItemId()
end

local OnSpellCastSucceeded = function(...)
    local unitTarget, castGUID, spellId = ...
    if unitTarget == "player" and spellId == kirinTorTeleportId then
        if not JTE or not JTE.waitToSwitchBack then
            if next(waitToSwitchBack) then
                for k, v in pairs(waitToSwitchBack) do
                    EquipItemByName(v, k)
                    local _, itemLink = GetItemInfo(v)
                    print(HEADER_TEXT.."肯瑞托戒指"..(GetSpellLink(kirinTorTeleportId) or "传送").."后自动换回之前的: "..(itemLink or v))
                end
                waitToSwitchBack = {}
            end
        else
            --提醒建议使用JTE的快捷键
            if msgJTE then
                print(ONLY_ICON:format("|CFF8FFFA2JT达拉然传送戒指自动换回来WA|R").."检测到|CFF1785D1JTE|R插件: 换回功能已经包含在|CFF1785D1JTE|R中，|cffff53a2建议删除本WA|r")
                msgJTE = false
            end
        end
    end
end

local OnUIErrorMessage = function(event, message)
    if message == ERR_ITEM_COOLDOWN then
		-- 物品冷却中
		-- 肯瑞托戒指
		local itemIdFinger1 = GetInventoryItemID("player", INVSLOT_FINGER1)
		local itemIdFinger2 = GetInventoryItemID("player", INVSLOT_FINGER2)

		local thisItemId = kirinTorRings[itemIdFinger1] and itemIdFinger1 or (kirinTorRings[itemIdFinger2] and itemIdFinger2 or nil)
		local thisSlot = kirinTorRings[itemIdFinger1] and INVSLOT_FINGER1 or (kirinTorRings[itemIdFinger2] and INVSLOT_FINGER2 or nil)

		if thisSlot then
			local start, duration, enable = GetInventoryItemCooldown("player", thisSlot)
			if enable == 1 and start > 0 then
				local timeLeft = start + duration - GetTime()
				local kirinLink = thisItemId and GetItemInfo(thisItemId) or "[肯瑞托戒指]"
				if waitToSwitchBack[thisSlot] then
					EquipItemByName(waitToSwitchBack[thisSlot], thisSlot)
					local previousItemLink = select(2, GetItemInfo(waitToSwitchBack[thisSlot]))
					print(HEADER_TEXT.."冷却中，剩余时间: |CFFFFFFFF"..secondsToTimeStr(timeLeft).."|R 秒, 已自动换回之前的"..previousItemLink)
					waitToSwitchBack[thisSlot] = nil
				end
			end
		end
	end
end

aura_env.OnTrigger = function(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        saveInventoryItemId()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        OnEquipmentChanged(...)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnSpellCastSucceeded(...)
    elseif event == "UI_ERROR_MESSAGE" then
        OnUIErrorMessage(...)
    end
end

