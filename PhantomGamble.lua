-- PhantomGamble Addon for Turtle WoW (1.12 compatible)

-- Variables
local AcceptOnes = "false"
local AcceptRolls = "false"
local totalrolls = 0
local tierolls = 0
local theMax
local lowname = ""
local highname = ""
local low = 0
local high = 0
local tie = 0
local highbreak = 0
local lowbreak = 0
local tiehigh = 0
local tielow = 0
local whispermethod = false

local chatmethods = { "RAID", "GUILD", "PARTY", "SAY" }
local chatmethod = chatmethods[1]

PG_Settings = { MinimapPos = 75 }

-- Helper function to send chat messages
local function ChatMsg(msg, chatType, language, channel)
	if not msg or msg == "" then return end
	
	chatType = chatType or chatmethod
	
	-- Validate chat type and fall back if needed
	if chatType == "RAID" then
		if not UnitInRaid("player") then
			if UnitInParty("player") then
				chatType = "PARTY"
			elseif IsInGuild() then
				chatType = "GUILD"
			else
				chatType = "SAY"
			end
		end
	elseif chatType == "PARTY" then
		if not UnitInParty("player") then
			if IsInGuild() then
				chatType = "GUILD"
			else
				chatType = "SAY"
			end
		end
	elseif chatType == "GUILD" then
		if not IsInGuild() then
			if UnitInParty("player") then
				chatType = "PARTY"
			else
				chatType = "SAY"
			end
		end
	end
	
	-- Debug output to see what's being sent
	-- DEFAULT_CHAT_FRAME:AddMessage("DEBUG: Sending to " .. chatType .. ": " .. msg)
	
	-- Send the message - use pcall to catch any errors
	if chatType == "CHANNEL" and channel then
		SendChatMessage(msg, chatType, nil, channel)
	else
		SendChatMessage(msg, chatType)
	end
end

local function Print(pre, red, text)
	if red == "" then red = "/PG" end
	DEFAULT_CHAT_FRAME:AddMessage(pre .. "|cff00ff00" .. red .. "|r: " .. text)
end

local function UpdateLayout()
	if not PhantomGamble_Frame then return end
	local width = PhantomGamble_Frame:GetWidth()
	local editWidth = math.max(60, width - 80)
	PhantomGamble_EditBox:SetWidth(editWidth)
	local btnWidth = math.max(80, width - 60)
	PhantomGamble_AcceptOnes_Button:SetWidth(btnWidth)
	PhantomGamble_LASTCALL_Button:SetWidth(btnWidth)
	PhantomGamble_ROLL_Button:SetWidth(btnWidth)
	local bottomBtnWidth = math.max(60, (width - 50) / 2)
	PhantomGamble_CHAT_Button:SetWidth(bottomBtnWidth)
	PhantomGamble_WHISPER_Button:SetWidth(bottomBtnWidth)
end

local function CreateMainFrame()
	local f = CreateFrame("Frame", "PhantomGamble_Frame", UIParent)
	f:SetWidth(250)
	f:SetHeight(220)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	f:SetMovable(true)
	f:SetResizable(true)
	f:EnableMouse(true)
	f:SetFrameStrata("DIALOG")
	f:SetMinResize(200, 180)
	f:SetMaxResize(400, 350)

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture(0, 0, 0, 0.85)
	bg:SetAllPoints(f)

	local borderTop = f:CreateTexture(nil, "BORDER")
	borderTop:SetTexture(0.6, 0.6, 0.6, 1)
	borderTop:SetHeight(2)
	borderTop:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	borderTop:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

	local borderBottom = f:CreateTexture(nil, "BORDER")
	borderBottom:SetTexture(0.6, 0.6, 0.6, 1)
	borderBottom:SetHeight(2)
	borderBottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
	borderBottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

	local borderLeft = f:CreateTexture(nil, "BORDER")
	borderLeft:SetTexture(0.6, 0.6, 0.6, 1)
	borderLeft:SetWidth(2)
	borderLeft:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	borderLeft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)

	local borderRight = f:CreateTexture(nil, "BORDER")
	borderRight:SetTexture(0.6, 0.6, 0.6, 1)
	borderRight:SetWidth(2)
	borderRight:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	borderRight:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

	local titleBg = f:CreateTexture(nil, "ARTWORK")
	titleBg:SetTexture(0.2, 0.2, 0.4, 1)
	titleBg:SetHeight(24)
	titleBg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
	titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", f, "TOP", 0, -8)
	title:SetText("|cffFFD700PhantomGamble|r")

	f:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" then this:StartMoving() end
	end)
	f:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)

	local editbox = CreateFrame("EditBox", "PhantomGamble_EditBox", f)
	editbox:SetWidth(100)
	editbox:SetHeight(28)
	editbox:SetPoint("TOP", f, "TOP", 0, -35)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetAutoFocus(false)
	editbox:SetNumeric(true)
	editbox:SetMaxLetters(6)
	editbox:SetJustifyH("CENTER")
	editbox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	editbox:SetScript("OnEnterPressed", function() this:ClearFocus() end)

	local editBg = editbox:CreateTexture(nil, "BACKGROUND")
	editBg:SetTexture(0.1, 0.1, 0.1, 0.8)
	editBg:SetAllPoints(editbox)

	local acceptBtn = CreateFrame("Button", "PhantomGamble_AcceptOnes_Button", f, "GameMenuButtonTemplate")
	acceptBtn:SetWidth(150)
	acceptBtn:SetHeight(22)
	acceptBtn:SetPoint("TOP", editbox, "BOTTOM", 0, -10)
	acceptBtn:SetText("Open Entry")
	acceptBtn:SetScript("OnClick", function() PhantomGamble_OnClickACCEPTONES() end)

	local lastcallBtn = CreateFrame("Button", "PhantomGamble_LASTCALL_Button", f, "GameMenuButtonTemplate")
	lastcallBtn:SetWidth(150)
	lastcallBtn:SetHeight(22)
	lastcallBtn:SetPoint("TOP", acceptBtn, "BOTTOM", 0, -5)
	lastcallBtn:SetText("Last Call")
	lastcallBtn:SetScript("OnClick", function() PhantomGamble_OnClickLASTCALL() end)

	local rollBtn = CreateFrame("Button", "PhantomGamble_ROLL_Button", f, "GameMenuButtonTemplate")
	rollBtn:SetWidth(150)
	rollBtn:SetHeight(22)
	rollBtn:SetPoint("TOP", lastcallBtn, "BOTTOM", 0, -5)
	rollBtn:SetText("Roll")
	rollBtn:SetScript("OnClick", function() PhantomGamble_OnClickROLL() end)

	local chatBtn = CreateFrame("Button", "PhantomGamble_CHAT_Button", f, "GameMenuButtonTemplate")
	chatBtn:SetWidth(80)
	chatBtn:SetHeight(20)
	chatBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, 35)
	chatBtn:SetText("RAID")
	chatBtn:SetScript("OnClick", function() PhantomGamble_OnClickCHAT() end)

	local whisperBtn = CreateFrame("Button", "PhantomGamble_WHISPER_Button", f, "GameMenuButtonTemplate")
	whisperBtn:SetWidth(100)
	whisperBtn:SetHeight(20)
	whisperBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 35)
	whisperBtn:SetText("(No Whispers)")
	whisperBtn:SetScript("OnClick", function() PhantomGamble_OnClickWHISPERS() end)

	local closeBtn = CreateFrame("Button", "PhantomGamble_CloseButton", f, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
	closeBtn:SetScript("OnClick", function() PhantomGamble_SlashCmd("hide") end)

	local resizeBtn = CreateFrame("Button", "PhantomGamble_ResizeButton", f)
	resizeBtn:SetWidth(16)
	resizeBtn:SetHeight(16)
	resizeBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
	resizeBtn:EnableMouse(true)
	local resizeTexture = resizeBtn:CreateTexture(nil, "OVERLAY")
	resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeTexture:SetAllPoints(resizeBtn)
	resizeBtn:SetScript("OnMouseDown", function() PhantomGamble_Frame:StartSizing("BOTTOMRIGHT") end)
	resizeBtn:SetScript("OnMouseUp", function() PhantomGamble_Frame:StopMovingOrSizing(); UpdateLayout() end)
	f:SetScript("OnSizeChanged", function() UpdateLayout() end)

	return f
end

local function CreateMinimapButton()
	local btn = CreateFrame("Button", "PG_MinimapButton", Minimap)
	btn:SetWidth(32)
	btn:SetHeight(32)
	btn:SetFrameStrata("MEDIUM")
	btn:SetFrameLevel(8)
	btn:EnableMouse(true)
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	btn:RegisterForDrag("LeftButton")
	btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local icon = btn:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
	icon:SetPoint("CENTER", btn, "CENTER", 0, 0)

	local border = btn:CreateTexture(nil, "OVERLAY")
	border:SetWidth(52)
	border:SetHeight(52)
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

	btn:SetScript("OnClick", function() PG_MinimapButton_OnClick() end)
	btn:SetScript("OnDragStart", function()
		this:LockHighlight()
		this:SetScript("OnUpdate", PG_MinimapButton_DraggingFrame_OnUpdate)
	end)
	btn:SetScript("OnDragStop", function()
		this:SetScript("OnUpdate", nil)
		this:UnlockHighlight()
	end)
	btn:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffFFD700PhantomGamble|r")
		GameTooltip:AddLine("Click to toggle window", 1, 1, 1)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	PG_MinimapButton_Reposition()
	return btn
end

function PG_MinimapButton_Reposition()
	if not PG_MinimapButton then return end
	if not PG_Settings then PG_Settings = { MinimapPos = 75 } end
	local angle = math.rad(PG_Settings.MinimapPos)
	local x = 52 - (80 * math.cos(angle))
	local y = (80 * math.sin(angle)) - 52
	PG_MinimapButton:ClearAllPoints()
	PG_MinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", x, y)
end

function PG_MinimapButton_DraggingFrame_OnUpdate()
	if not PG_Settings then PG_Settings = { MinimapPos = 75 } end
	local xpos, ypos = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	xpos, ypos = xpos / scale, ypos / scale
	local cx, cy = Minimap:GetCenter()
	PG_Settings.MinimapPos = math.deg(math.atan2(ypos - cy, xpos - cx))
	PG_MinimapButton_Reposition()
end

function PG_MinimapButton_OnClick()
	if PhantomGamble and PhantomGamble["active"] == 1 then
		PhantomGamble_Frame:Hide()
		PhantomGamble["active"] = 0
	else
		PhantomGamble_Frame:Show()
		if PhantomGamble then PhantomGamble["active"] = 1 end
	end
end

function PhantomGamble_SlashCmd(msg)
	msg = string.lower(msg or "")
	if msg == "" then
		Print("", "", "Commands: show, hide, reset, fullstats, resetstats, minimap, ban, unban, listban")
		return
	end
	if msg == "hide" then
		PhantomGamble_Frame:Hide()
		PhantomGamble["active"] = 0
	elseif msg == "show" then
		PhantomGamble_Frame:Show()
		PhantomGamble["active"] = 1
	elseif msg == "reset" then
		PhantomGamble_Reset()
		Print("", "", "PhantomGamble has been reset.")
	elseif msg == "fullstats" then
		PhantomGamble_OnClickSTATS(true)
	elseif msg == "resetstats" then
		PhantomGamble["stats"] = {}
		Print("", "", "Stats have been reset.")
	elseif msg == "minimap" then
		PhantomGamble["minimap"] = not PhantomGamble["minimap"]
		if PhantomGamble["minimap"] then PG_MinimapButton:Show() else PG_MinimapButton:Hide() end
	elseif string.sub(msg, 1, 4) == "ban " then
		local name = string.sub(msg, 5)
		if not PhantomGamble.bans then PhantomGamble.bans = {} end
		table.insert(PhantomGamble.bans, name)
		Print("", "", name .. " banned.")
	elseif string.sub(msg, 1, 6) == "unban " then
		local name = string.sub(msg, 7)
		if PhantomGamble.bans then
			for i, v in ipairs(PhantomGamble.bans) do
				if string.lower(v) == string.lower(name) then
					table.remove(PhantomGamble.bans, i)
					Print("", "", name .. " unbanned.")
					return
				end
			end
		end
	elseif msg == "listban" then
		if not PhantomGamble.bans or table.getn(PhantomGamble.bans) == 0 then
			Print("", "", "No bans.")
		else
			for i, v in ipairs(PhantomGamble.bans) do
				DEFAULT_CHAT_FRAME:AddMessage("  " .. v)
			end
		end
	else
		Print("", "", "Unknown command: " .. msg)
	end
end

SLASH_PHANTOMGAMBLE1 = "/phantomgamble"
SLASH_PHANTOMGAMBLE2 = "/pg"
SlashCmdList["PHANTOMGAMBLE"] = PhantomGamble_SlashCmd

function PhantomGamble_OnEvent()
	if event == "PLAYER_ENTERING_WORLD" then
		if not PhantomGamble_Frame then CreateMainFrame() end
		if not PG_MinimapButton then CreateMinimapButton() end

		if not PhantomGamble then
			PhantomGamble = {
				active = 1, chat = 1, channel = "gambling", whispers = false,
				strings = {}, lowtie = {}, hightie = {}, bans = {},
				minimap = true, lastroll = 100, stats = {}, joinstats = {}
			}
		end

		PhantomGamble_EditBox:SetText(tostring(PhantomGamble["lastroll"] or 100))
		chatmethod = chatmethods[PhantomGamble["chat"] or 1] or "RAID"
		PhantomGamble_CHAT_Button:SetText(chatmethod)

		if PhantomGamble["minimap"] then PG_MinimapButton:Show() else PG_MinimapButton:Hide() end
		whispermethod = PhantomGamble["whispers"] or false
		PhantomGamble_WHISPER_Button:SetText(whispermethod and "(Whispers)" or "(No Whispers)")

		if PhantomGamble["active"] == 1 then PhantomGamble_Frame:Show() else PhantomGamble_Frame:Hide() end
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00PhantomGamble loaded!|r Type |cffFFD700/pg|r for commands.")
	end

	if (event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_RAID") and AcceptOnes == "true" and PhantomGamble["chat"] == 1 then
		PhantomGamble_ParseChatMsg(arg1, arg2)
	end
	if event == "CHAT_MSG_GUILD" and AcceptOnes == "true" and PhantomGamble["chat"] == 2 then
		PhantomGamble_ParseChatMsg(arg1, arg2)
	end
	if event == "CHAT_MSG_PARTY" and AcceptOnes == "true" and PhantomGamble["chat"] == 3 then
		PhantomGamble_ParseChatMsg(arg1, arg2)
	end
	if event == "CHAT_MSG_SAY" and AcceptOnes == "true" and PhantomGamble["chat"] == 4 then
		PhantomGamble_ParseChatMsg(arg1, arg2)
	end
	if event == "CHAT_MSG_SYSTEM" and AcceptRolls == "true" then
		PhantomGamble_ParseRoll(tostring(arg1))
	end
end

function PhantomGamble_ParseChatMsg(msg, sender)
	if msg == "1" then
		if PhantomGamble_ChkBan(sender) == 0 then
			PhantomGamble_Add(sender)
			if totalrolls >= 2 then
				PhantomGamble_AcceptOnes_Button:Disable()
			end
		else
			ChatMsg("Sorry, you're banned!")
		end
	elseif msg == "-1" then
		PhantomGamble_Remove(sender)
	end
end

function PhantomGamble_OnClickCHAT()
	PhantomGamble["chat"] = (PhantomGamble["chat"] or 1) + 1
	if PhantomGamble["chat"] > 4 then PhantomGamble["chat"] = 1 end
	chatmethod = chatmethods[PhantomGamble["chat"]]
	PhantomGamble_CHAT_Button:SetText(chatmethod)
end

function PhantomGamble_OnClickWHISPERS()
	PhantomGamble["whispers"] = not PhantomGamble["whispers"]
	whispermethod = PhantomGamble["whispers"]
	PhantomGamble_WHISPER_Button:SetText(whispermethod and "(Whispers)" or "(No Whispers)")
end

function PhantomGamble_OnClickACCEPTONES()
	local editText = PhantomGamble_EditBox:GetText()
	if editText ~= "" and editText ~= "1" and tonumber(editText) then
		PhantomGamble_Reset()
		PhantomGamble_ROLL_Button:Disable()
		PhantomGamble_LASTCALL_Button:Disable()
		AcceptOnes = "true"
		ChatMsg("Welcome to PhantomGamble! Roll Amount: " .. editText .. " gold. Type 1 to Join or -1 to withdraw.")
		PhantomGamble["lastroll"] = editText
		theMax = tonumber(editText)
		low = theMax + 1
		PhantomGamble_AcceptOnes_Button:SetText("New Game")
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Please enter a valid number.|r")
	end
end

function PhantomGamble_OnClickLASTCALL()
	ChatMsg("Last Call to join!")
	PhantomGamble_LASTCALL_Button:Disable()
	PhantomGamble_ROLL_Button:Enable()
end

function PhantomGamble_OnClickROLL()
	if totalrolls > 1 then
		AcceptOnes = "false"
		AcceptRolls = "true"
		ChatMsg("Roll now! Type /random 1-" .. theMax)
		PhantomGamble_List()
	elseif AcceptOnes == "true" then
		ChatMsg("Not enough Players!")
	end
end

function PhantomGamble_OnClickSTATS(full)
	if not PhantomGamble["stats"] or not next(PhantomGamble["stats"]) then
		DEFAULT_CHAT_FRAME:AddMessage("No stats yet!")
		return
	end
	DEFAULT_CHAT_FRAME:AddMessage("--- PhantomGamble Stats ---")
	for name, amount in pairs(PhantomGamble["stats"]) do
		local sign = amount >= 0 and "won" or "lost"
		DEFAULT_CHAT_FRAME:AddMessage(string.format("%s %s %d gold", name, sign, math.abs(amount)))
	end
end

function PhantomGamble_Report()
	local goldowed = high - low
	if goldowed ~= 0 then
		lowname = string.upper(string.sub(lowname, 1, 1)) .. string.sub(lowname, 2)
		highname = string.upper(string.sub(highname, 1, 1)) .. string.sub(highname, 2)
		PhantomGamble["stats"][highname] = (PhantomGamble["stats"][highname] or 0) + goldowed
		PhantomGamble["stats"][lowname] = (PhantomGamble["stats"][lowname] or 0) - goldowed
		ChatMsg(string.format("%s owes %s %d gold.", lowname, highname, goldowed))
	else
		ChatMsg("It was a tie! No payouts!")
	end
	PhantomGamble_Reset()
	PhantomGamble_AcceptOnes_Button:SetText("Open Entry")
	PhantomGamble_CHAT_Button:Enable()
end

function PhantomGamble_Reset()
	totalrolls, low, high, lowname, highname = 0, 0, 0, "", ""
	tie, highbreak, lowbreak = 0, 0, 0
	AcceptOnes, AcceptRolls = "false", "false"
	if PhantomGamble then
		PhantomGamble.strings = {}
		PhantomGamble.lowtie = {}
		PhantomGamble.hightie = {}
	end
end

function PhantomGamble_Add(name)
	if not PhantomGamble.strings then PhantomGamble.strings = {} end
	for i, v in ipairs(PhantomGamble.strings) do
		if string.lower(v) == string.lower(name) then return end
	end
	table.insert(PhantomGamble.strings, name)
	totalrolls = table.getn(PhantomGamble.strings)
	if whispermethod then SendChatMessage("You joined!", "WHISPER", nil, name) end
	Print("", "", name .. " joined. Players: " .. totalrolls)
	if totalrolls >= 1 then PhantomGamble_LASTCALL_Button:Enable() end
end

function PhantomGamble_Remove(name)
	if not PhantomGamble.strings then return end
	for i, v in ipairs(PhantomGamble.strings) do
		if string.lower(v) == string.lower(name) then
			table.remove(PhantomGamble.strings, i)
			totalrolls = table.getn(PhantomGamble.strings)
			Print("", "", name .. " left. Players: " .. totalrolls)
			return
		end
	end
end

function PhantomGamble_ChkBan(name)
	if not PhantomGamble or not PhantomGamble.bans then return 0 end
	for i, v in ipairs(PhantomGamble.bans) do
		if string.lower(v) == string.lower(name) then return 1 end
	end
	return 0
end

function PhantomGamble_List()
	if not PhantomGamble.strings or table.getn(PhantomGamble.strings) == 0 then
		ChatMsg("No players.")
		return
	end
	local list = ""
	for i, v in ipairs(PhantomGamble.strings) do
		list = list .. (list ~= "" and ", " or "") .. v
	end
	ChatMsg("Players: " .. list)
end

function PhantomGamble_ParseRoll(msg)
	local _, _, name, roll, minroll, maxroll = string.find(msg, "(.+) rolls (%d+) %((%d+)%-(%d+)%)")
	if not name then return end
	roll, minroll, maxroll = tonumber(roll), tonumber(minroll), tonumber(maxroll)

	local found, idx = false, nil
	if PhantomGamble.strings then
		for i, v in ipairs(PhantomGamble.strings) do
			if string.lower(v) == string.lower(name) then
				found, idx = true, i
				break
			end
		end
	end
	if not found then return end
	table.remove(PhantomGamble.strings, idx)

	if maxroll ~= theMax or minroll ~= 1 then
		ChatMsg(name .. " rolled wrong range!")
		return
	end

	if roll > high then high, highname = roll, name end
	if roll < low then low, lowname = roll, name end

	totalrolls = totalrolls - 1
	Print("", "", name .. " rolled " .. roll .. ". Waiting: " .. totalrolls)
	if totalrolls == 0 then PhantomGamble_Report() end
end

local PhantomGamble_EventFrame = CreateFrame("Frame", "PhantomGamble_EventFrame", UIParent)
PhantomGamble_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
PhantomGamble_EventFrame:RegisterEvent("CHAT_MSG_RAID")
PhantomGamble_EventFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
PhantomGamble_EventFrame:RegisterEvent("CHAT_MSG_GUILD")
PhantomGamble_EventFrame:RegisterEvent("CHAT_MSG_PARTY")
PhantomGamble_EventFrame:RegisterEvent("CHAT_MSG_SAY")
PhantomGamble_EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
PhantomGamble_EventFrame:SetScript("OnEvent", PhantomGamble_OnEvent)
