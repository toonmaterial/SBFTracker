local addOnName, addOnTitle = C_AddOns.GetAddOnInfo(...)

local function isLooted()
	local target = C_Item.GetItemInfo(219013)

	for slot = 1, GetNumLootItems() do
		local _, name = GetLootSlotInfo(slot)
		if name == target then return true end
	end
end

local function isProfessionLearned()
	return C_TradeSkillUI.IsRecipeProfessionLearned(442655)
end

local function getDB()
	SBFTrackerDB = SBFTrackerDB or {}
	return SBFTrackerDB
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("LOOT_READY")
f:SetScript("OnEvent", function(_, event)
	local db = getDB()
	local player = UnitName("player") .. "-" .. GetNormalizedRealmName()

	if not isProfessionLearned() then
		db[player] = nil
		return
	end

	db[player] = db[player] or {}
	local d = db[player]

	local _, classFile = UnitClass("player")
	d.classFile = classFile

	local now = GetServerTime()
	local lootReset = now + C_DateAndTime.GetSecondsUntilDailyReset()
	d.lootReset = d.lootReset or lootReset

	if event == "LOOT_READY" and isLooted() then
		d.loot = now
		d.lootReset = lootReset
	end
end)

local addOnData = { text = addOnName }

function addOnData.funcOnEnter(button)
	local db = getDB()
	local now = GetServerTime()

	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddLine(addOnTitle)
	GameTooltip:AddLine(" ")

	for player, d in pairs(db) do
		local text = "?"
		if now >= d.lootReset then
			text = "Reset"
		elseif d.loot then
			text = "Looted"
		end

		GameTooltip:AddDoubleLine(
			RAID_CLASS_COLORS[d.classFile]:WrapTextInColorCode(player),
			WHITE_FONT_COLOR:WrapTextInColorCode(text))
	end

	GameTooltip:Show()
end

function addOnData.funcOnLeave()
	GameTooltip:Hide()
end

AddonCompartmentFrame:RegisterAddon(addOnData)
