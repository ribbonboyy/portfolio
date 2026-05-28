-- I do not want to leak any source code and I also don't want to write any so I will just provide the entire frontend side of my Ro-Link game but with some parts deleted
-- Ro-Links a biolink (and the first of its kind on roblox) game. Link: https://www.roblox.com/games/71121446584935/Ro-Link

-- To put the way Ro-Link works in a _VERY_ simple way: The player can click between pages, and on these pages interact with the system.
-- (main) Menu (front) page: They can see featured pages, search for pages (using an on-platform username), register (and if already registered view their Ro-Link or edit it)
-- Edit: They can edit the page here, when saved, all data gets saved to datastores (those are handled on the server side)
-- Profiles (BiolinkTemplate), each 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local Players           = game:GetService("Players")

local MainGUI = script.Parent
MainGUI.IgnoreGuiInset = true

local Menu            = MainGUI:WaitForChild("Menu")
local Register        = MainGUI:WaitForChild("Register")
local Edit            = MainGUI:WaitForChild("Edit")
local BiolinkTemplate = MainGUI:WaitForChild("BiolinkTemplate")

local Background        = BiolinkTemplate:WaitForChild("Background")
local Dish              = Background:WaitForChild("Dish")
local FeaturedContainer = Menu:WaitForChild("Featured")
local FeaturedTemplate  = FeaturedContainer:WaitForChild("FeaturedTemplate")

local GameFrameTemplate
if Background:FindFirstChild("AAGame") then
	GameFrameTemplate = Background.AAGame:Clone()
	Background.AAGame:Destroy()
end

local RblxProfileTemplate
if Background:FindFirstChild("RblxProfile") then
	RblxProfileTemplate = Background.RblxProfile:Clone()
	Background.RblxProfile:Destroy()
end

local PronounsTemplate
if Background:FindFirstChild("ZZPronouns") then
	PronounsTemplate = Background.ZZPronouns:Clone()
	Background.ZZPronouns:Destroy()
end

local ExtraBioTemplate
if Background:FindFirstChild("ZDSomething") then
	ExtraBioTemplate = Background.ZDSomething:Clone()
	Background.ZDSomething:Destroy()
end

local EditFrame  = Edit:WaitForChild("EditFrame")
local BasicFrame = Edit:WaitForChild("Basics")
local LinksFrame = Edit:WaitForChild("Links")

local BioInput          = BasicFrame:WaitForChild("Bio"):WaitForChild("Bio")
local DisplayInput      = BasicFrame:WaitForChild("DisplayName"):WaitForChild("DisplayName")
local PFPInput          = BasicFrame:WaitForChild("ProfilePicture"):WaitForChild("ProfilePicture")
local ColorInput        = EditFrame:WaitForChild("BGColor"):WaitForChild("Color")
local BGPicInput        = EditFrame:WaitForChild("BGPic"):WaitForChild("ID")
local ThemeInput        = EditFrame:WaitForChild("ProfileTheme"):WaitForChild("ColorTheme")
local TranspInput       = EditFrame:WaitForChild("FrameTransp"):WaitForChild("Transparency")
local GameListNameInput = EditFrame:WaitForChild("GameListing"):WaitForChild("GameListName")
local GameListIDInput   = EditFrame:WaitForChild("GameListing"):WaitForChild("GameListID")

local ProfileBooleanButton = EditFrame:WaitForChild("RBLXProfile"):WaitForChild("ProfileBooleanButton")
local showRblxProfileEnabled = false

local TypewriterBooleanButton = EditFrame:WaitForChild("Typewriter"):WaitForChild("TypewriterBooleanButton")
local typewriterEnabled = false

local ActivityBooleanButton = EditFrame:WaitForChild("Showactivity"):WaitForChild("ActivityBooleanButton")
local showActivityEnabled = false

local PronounsEnabledButton = EditFrame:WaitForChild("PronounsEnable"):WaitForChild("PronounsEnabled")
local pronounsEnabled = false

local ExtraBioEnabledButton = EditFrame:WaitForChild("AdditionalBioEnabled"):WaitForChild("ExtraEnabled")
local extraBioEnabled = false

local PronounsInput  = EditFrame:WaitForChild("Pronouns"):WaitForChild("Pronouns")
local ExtraBioInput  = EditFrame:WaitForChild("ExtraBio"):WaitForChild("Bio")

local L1NameInput = LinksFrame:WaitForChild("Link1"):WaitForChild("Link1Name")
local L1IDInput   = LinksFrame:WaitForChild("Link1"):WaitForChild("Link1ID")
local L2NameInput = LinksFrame:WaitForChild("Link2"):WaitForChild("Link2Name")
local L2IDInput   = LinksFrame:WaitForChild("Link2"):WaitForChild("Link2ID")

local ShareLinkInput = Edit:WaitForChild("ShareLinkBox")
local BASE_URL = "https://www.roblox.com/games/start?placeId=71121446584935&launchData="

local ViewYourBtn = Menu:WaitForChild("ViewYour")
local EditYourBtn = Menu:WaitForChild("EditYour")
local CreateBtn   = Menu:WaitForChild("CreateYourOwn")
local SearchBox   = Menu:WaitForChild("SearchThing")
local SearchBtn   = Menu:WaitForChild("Search")

local remotesFolder     = ReplicatedStorage:WaitForChild("BioLinkRemotes")
local SearchProfile     = remotesFolder:WaitForChild("SearchProfile")
local RegisterName      = remotesFolder:WaitForChild("RegisterName")
local SaveProfile       = remotesFolder:WaitForChild("SaveProfile")
local GetOwnProfile     = remotesFolder:WaitForChild("GetOwnProfile")
local RecordView        = remotesFolder:WaitForChild("RecordView")
local GetFeatured       = remotesFolder:WaitForChild("GetFeatured")
local GetRobloxUserInfo = remotesFolder:WaitForChild("GetRobloxUserInfo")
local GetPresence       = remotesFolder:WaitForChild("GetPresence")

local isOnCooldown    = false
local linkClickStates = {}

local function setToggle(state, button, value)
	state[1] = value
	button.Text = value and "Enabled" or "Disabled"
end

local showRblxState     = { false }
local typewriterState   = { false }
local activityState     = { false }
local pronounsState     = { false }
local extraBioState     = { false }

local function setProfileToggle(v)
	showRblxProfileEnabled = v
	ProfileBooleanButton.Text = v and "Enabled" or "Disabled"
end

local function setTypewriterToggle(v)
	typewriterEnabled = v
	TypewriterBooleanButton.Text = v and "Enabled" or "Disabled"
end

local function setActivityToggle(v)
	showActivityEnabled = v
	ActivityBooleanButton.Text = v and "Enabled" or "Disabled"
end

local function setPronounsToggle(v)
	pronounsEnabled = v
	PronounsEnabledButton.Text = v and "Enabled" or "Disabled"
end

local function setExtraBioToggle(v)
	extraBioEnabled = v
	ExtraBioEnabledButton.Text = v and "Enabled" or "Disabled"
end

setProfileToggle(false)
setTypewriterToggle(false)
setActivityToggle(false)
setPronounsToggle(false)
setExtraBioToggle(false)

ProfileBooleanButton.MouseButton1Click:Connect(function()
	setProfileToggle(not showRblxProfileEnabled)
end)
TypewriterBooleanButton.MouseButton1Click:Connect(function()
	setTypewriterToggle(not typewriterEnabled)
end)
ActivityBooleanButton.MouseButton1Click:Connect(function()
	setActivityToggle(not showActivityEnabled)
end)
PronounsEnabledButton.MouseButton1Click:Connect(function()
	setPronounsToggle(not pronounsEnabled)
end)
ExtraBioEnabledButton.MouseButton1Click:Connect(function()
	setExtraBioToggle(not extraBioEnabled)
end)

BiolinkTemplate.Size        = UDim2.fromScale(1, 1)
BiolinkTemplate.Position    = UDim2.fromScale(0.5, 0.5)
BiolinkTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
Background.Size             = UDim2.fromScale(1, 1)
Background.Position         = UDim2.fromScale(0.5, 0.5)
Background.AnchorPoint      = Vector2.new(0.5, 0.5)

Register.Visible        = false
Edit.Visible            = false
BiolinkTemplate.Visible = false
Menu.Visible            = true

local function getContrastColor(color)
	local luminance = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
	return luminance > 0.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
end

local function showNotice(text, duration)
	Register.Fail.Text    = text
	Register.Fail.Visible = true
	task.delay(duration or 2, function()
		Register.Fail.Visible = false
	end)
end

local function refreshFeatured()
	for _, child in ipairs(FeaturedContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "FeaturedTemplate" then
			child:Destroy()
		end
	end

	local featuredData = GetFeatured:InvokeServer()
	if not featuredData then return end

	for _, data in ipairs(featuredData) do
		local card = FeaturedTemplate:Clone()
		card.Visible = true
		card.Name    = "FeaturedCard"

		local ok, tCol = pcall(function() return Color3.fromHex(data.Theme or "#0d0d0d") end)
		local finalTCol = ok and tCol or Color3.fromRGB(255, 255, 255)
		card.BackgroundColor3 = finalTCol

		local txtCol = getContrastColor(finalTCol)
		if card:FindFirstChild("NameLabel") then
			card.NameLabel.Text       = data.AccountName
			card.NameLabel.TextColor3 = txtCol
		end
		if card:FindFirstChild("Views") then
			card.Views.Text       = (data.Views or 0) .. " views"
			card.Views.TextColor3 = txtCol
		end
		if card:FindFirstChild("PFP") then
			card.PFP.Image = data.PFP or "rbxassetid://0"
		end

		card:WaitForChild("GoToProfile").MouseButton1Click:Connect(function()
			local ok2, pData = SearchProfile:InvokeServer(data.LinkName)
			if ok2 then openBiolink(pData) end
		end)

		card.Parent = FeaturedContainer
	end
end

local function checkBiolinkStatus()
	local data = GetOwnProfile:InvokeServer()
	if data then
		ViewYourBtn.Visible = true
		EditYourBtn.Visible = true
		CreateBtn.Visible   = false
	else
		ViewYourBtn.Visible = false
		EditYourBtn.Visible = false
		CreateBtn.Visible   = true
	end
end

local PRESENCE_COLORS = {
	Game    = Color3.fromRGB(100, 220, 100),
	Online  = Color3.fromRGB(80,  160, 255),
	Studio  = Color3.fromRGB(255, 165, 60),
	Offline = Color3.fromRGB(130, 130, 130),
}

function openBiolink(data)
	if not data then return end

	RecordView:InvokeServer(data.OwnerId or data.UserId)

	local linksContainer  = Dish:WaitForChild("Links")
	local badgesContainer = Dish:WaitForChild("Badges")
	local templateBadge   = badgesContainer:WaitForChild("BasicBadge")
	local bNameLbl        = Dish:WaitForChild("BName")
	local bioLbl          = Dish:WaitForChild("Bio")
	local viewsLbl        = Dish:FindFirstChild("BZViews")
	local pfpImg          = Dish:WaitForChild("APFP")

	local pfpVal = string.match(tostring(data.PFP or ""), "%d+")
	if pfpVal and pfpVal ~= "" and pfpVal ~= "0" then
		pfpImg.Image   = "rbxassetid://" .. pfpVal
		pfpImg.Visible = true
	else
		pfpImg.Visible = false
	end

	bNameLbl.Text = data.DisplayName or ("@" .. (data.LinkName or ""))
	if viewsLbl then viewsLbl.Text = (data.Views or 0) .. " Views" end

	local okBG, bgColor = pcall(function() return Color3.fromHex(data.BGColor or "#ffffff") end)
	BiolinkTemplate:FindFirstChild("Background").BackgroundColor3 = okBG and bgColor or Color3.new(1, 1, 1)

	local bgPicVal = string.match(tostring(data.BGPic or ""), "%d+")
	if bgPicVal and bgPicVal ~= "" and bgPicVal ~= "0" then
		Background.Image             = "rbxassetid://" .. bgPicVal
		Background.ImageTransparency = 0
	else
		Background.Image             = ""
		Background.ImageTransparency = 1
	end

	local okTheme, themeColor = pcall(function() return Color3.fromHex(data.ProfileTheme or "#0d0d0d") end)
	local finalTheme = okTheme and themeColor or Color3.fromRGB(13, 13, 13)
	local textColor  = getContrastColor(finalTheme)

	Dish.BackgroundColor3       = finalTheme
	Dish.BackgroundTransparency = tonumber(data.FrameTransp) or 0
	bNameLbl.TextColor3         = textColor
	bioLbl.TextColor3           = textColor
	if viewsLbl then viewsLbl.TextColor3 = textColor end

	if data.TypewriterEnabled then
		local fullText = data.Bio or ""
		bioLbl.Text = ""
		task.spawn(function()
			for i = 1, #fullText do
				bioLbl.Text = string.sub(fullText, 1, i)
				task.wait(0.04)
			end
		end)
	else
		bioLbl.Text = data.Bio or ""
	end

	local locationFrame = Dish:FindFirstChild("BZZLocation")
	if locationFrame then
		local loc = tostring(data.Location or "")
		if loc ~= "" then
			locationFrame.Visible = true
			local locLabel = locationFrame:FindFirstChild("Location")
			if locLabel then
				locLabel.Text       = loc
				locLabel.TextColor3 = textColor
			end
		else
			locationFrame.Visible = false
		end
	end

	local presenceFrame = Dish:FindFirstChild("Presence")
	if presenceFrame then
		presenceFrame.Visible = false
	end

	if data.ShowActivity then
		local ownerId = data.OwnerId or data.UserId
		if ownerId and presenceFrame then
			presenceFrame.Visible = true
			task.spawn(function()
				local status = GetPresence:InvokeServer(ownerId)
				local col    = PRESENCE_COLORS[status] or PRESENCE_COLORS.Offline
				presenceFrame.BackgroundColor3 = col
				local presenceLabel = presenceFrame:FindFirstChildWhichIsA("TextLabel")
				if presenceLabel then
					presenceLabel.Text = status
				end
			end)
		end
	end

	local existingTooltip = BiolinkTemplate:FindFirstChild("_BadgeTooltip")
	if existingTooltip then existingTooltip:Destroy() end

	local tooltip = Instance.new("Frame")
	tooltip.Name                   = "_BadgeTooltip"
	tooltip.Size                   = UDim2.new(0.269, 0, 0.102, 0)
	tooltip.Position               = UDim2.new(0.362, 0, 1.2,   0)
	tooltip.AnchorPoint            = Vector2.new(0, 1)
	tooltip.BackgroundColor3       = Color3.fromRGB(20, 20, 20)
	tooltip.BackgroundTransparency = 0.1
	tooltip.BorderSizePixel        = 0
	tooltip.ZIndex                 = 10
	tooltip.ClipsDescendants       = false
	tooltip.Parent                 = BiolinkTemplate

	local tooltipCorner        = Instance.new("UICorner", tooltip)
	tooltipCorner.CornerRadius = UDim.new(0, 10)

	local tooltipLabel                  = Instance.new("TextLabel", tooltip)
	tooltipLabel.Size                   = UDim2.fromScale(1, 1)
	tooltipLabel.BackgroundTransparency = 1
	tooltipLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
	tooltipLabel.TextScaled             = true
	tooltipLabel.Font                   = Enum.Font.GothamBold
	tooltipLabel.ZIndex                 = 11

	local tooltipPadding       = Instance.new("UIPadding", tooltip)
	tooltipPadding.PaddingLeft  = UDim.new(0, 12)
	tooltipPadding.PaddingRight = UDim.new(0, 12)

	local TWEEN_IN  = TweenInfo.new(0.3, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
	local TWEEN_OUT = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	local POS_VISIBLE = UDim2.new(0.365, 0, 0.881, 0)
	local POS_HIDDEN  = UDim2.new(0.362, 0, 1.2,   0)

	local tooltipHideThread

	local function showTooltip(badgeName)
		tooltipLabel.Text = badgeName
		if tooltipHideThread then
			task.cancel(tooltipHideThread)
			tooltipHideThread = nil
		end
		TweenService:Create(tooltip, TWEEN_IN, { Position = POS_VISIBLE }):Play()
	end

	local function hideTooltip(delay)
		if tooltipHideThread then task.cancel(tooltipHideThread) end
		tooltipHideThread = task.delay(delay or 0, function()
			TweenService:Create(tooltip, TWEEN_OUT, { Position = POS_HIDDEN }):Play()
			tooltipHideThread = nil
		end)
	end

	for _, child in ipairs(badgesContainer:GetChildren()) do
		if child:IsA("ImageButton") and child.Name ~= "BasicBadge" then
			child:Destroy()
		end
	end
	templateBadge.Visible = false

	local hasBadges = false
	if data.Badges and data.BadgeData and #data.Badges > 0 then
		hasBadges = true
		for _, bId in ipairs(data.Badges) do
			local bInfo = data.BadgeData[tostring(bId)]
			if bInfo then
				local nb   = templateBadge:Clone()
				nb.Name    = bInfo.Name
				nb.Image   = bInfo.Image
				nb.Visible = true
				nb.Parent  = badgesContainer

				nb.MouseEnter:Connect(function()
					showTooltip(bInfo.Name)
				end)
				nb.MouseLeave:Connect(function()
					hideTooltip(0.5)
				end)
				nb.MouseButton1Click:Connect(function()
					if tooltip.Position == POS_VISIBLE and tooltipLabel.Text == bInfo.Name then
						hideTooltip(0)
					else
						showTooltip(bInfo.Name)
						hideTooltip(3)
					end
				end)
			end
		end
	end
	badgesContainer.Visible = hasBadges

	if Background:FindFirstChild("Game") then
		Background.Game:Destroy()
	end

	if GameFrameTemplate
		and data.GameListName and data.GameListName ~= ""
		and data.GameListID   and data.GameListID   ~= ""
	then
		local newGame = GameFrameTemplate:Clone()
		newGame.Name  = "Game"

		newGame.AGameName.Text         = data.GameListName
		newGame.BGameImage.Image       = "rbxassetid://" .. (string.match(tostring(data.GameListID), "%d+") or "0")
		newGame.BackgroundColor3       = finalTheme
		newGame.BackgroundTransparency = Dish.BackgroundTransparency
		newGame.AGameName.TextColor3   = textColor

		local joinBtn = newGame:FindFirstChild("JoinButton")
		if joinBtn then
			local joinLabel = joinBtn:FindFirstChild("Label")
			if joinLabel then joinLabel.TextColor3 = textColor end
			joinBtn.MouseButton1Click:Connect(function()
				local placeId = tonumber(data.GameListID)
				if placeId then TeleportService:Teleport(placeId) end
			end)
		end

		newGame.Parent  = Background
		newGame.Visible = true
	end

	if Background:FindFirstChild("RblxProfile") then
		Background.RblxProfile:Destroy()
	end

	local ownerId = data.OwnerId or data.UserId

	if RblxProfileTemplate and data.ShowRblxProfile and ownerId then
		local newRblx = RblxProfileTemplate:Clone()
		newRblx.Name  = "RblxProfile"

		newRblx.BackgroundColor3       = finalTheme
		newRblx.BackgroundTransparency = Dish.BackgroundTransparency

		local usernameLbl = newRblx:FindFirstChild("RBLXUsername")
		local joinDateLbl = newRblx:FindFirstChild("RBLXJoindate")
		local followerLbl = newRblx:FindFirstChild("RBLXFollowercount")
		local friendLbl   = newRblx:FindFirstChild("RBLXFriendcount")
		local avatarImg   = newRblx:FindFirstChild("RBLXAvatar")

		for _, lbl in ipairs({ usernameLbl, joinDateLbl, followerLbl, friendLbl }) do
			if lbl then
				lbl.TextColor3 = textColor
				lbl.Text       = "Loading..."
			end
		end

		if avatarImg then
			avatarImg.Image = "rbxthumb://type=Avatar&id=" .. tostring(ownerId) .. "&w=420&h=420"
		end

		newRblx.Parent  = Background
		newRblx.Visible = true

		task.spawn(function()
			local info = GetRobloxUserInfo:InvokeServer(ownerId)
			if not info then return end
			if usernameLbl then usernameLbl.Text = "@" .. (info.Username or "unknown") end
			if followerLbl then followerLbl.Text = tostring(info.FollowerCount or 0) .. " Followers" end
			if friendLbl   then friendLbl.Text   = tostring(info.FriendCount   or 0) .. " Friends"   end
			if joinDateLbl then joinDateLbl.Text  = "Joined: " .. (info.JoinDate or "Unknown") end
		end)
	end

	if Background:FindFirstChild("ZZPronouns") then
		Background.ZZPronouns:Destroy()
	end

	if PronounsTemplate and data.PronounsEnabled and data.Pronouns and data.Pronouns ~= "" then
		local newPronouns = PronounsTemplate:Clone()
		newPronouns.Name  = "ZZPronouns"

		newPronouns.BackgroundColor3       = finalTheme
		newPronouns.BackgroundTransparency = Dish.BackgroundTransparency

		local pronounsLbl = newPronouns:FindFirstChild("Pronouns")
			or newPronouns:FindFirstChildWhichIsA("TextLabel")
		if pronounsLbl then
			pronounsLbl:FindFirstChild("Text").Text     = data.Pronouns
			pronounsLbl:FindFirstChild("Text").TextColor3 = textColor
		end

		local headerLbl = newPronouns:FindFirstChild("LAbel")
		if headerLbl then
			headerLbl.TextColor3 = textColor
		end

		newPronouns.Parent  = Background
		newPronouns.Visible = true
	end

	if Background:FindFirstChild("ZDSomething") then
		Background.ZDSomething:Destroy()
	end

	if ExtraBioTemplate and data.ExtraBioEnabled and data.ExtraBio and data.ExtraBio ~= "" then
		local newExtra = ExtraBioTemplate:Clone()
		newExtra.Name  = "ZDSomething"

		newExtra.BackgroundColor3       = finalTheme
		newExtra.BackgroundTransparency = Dish.BackgroundTransparency

		local extraBioLbl = newExtra:FindFirstChild("Bio")
			or newExtra:FindFirstChildWhichIsA("TextLabel")
		if extraBioLbl then
			extraBioLbl.Text       = data.ExtraBio
			extraBioLbl.TextColor3 = textColor
		end

		local additionalLbl = newExtra:FindFirstChild("Additional")
		if additionalLbl then
			additionalLbl.TextColor3 = textColor
		end

		newExtra.Parent  = Background
		newExtra.Visible = true
	end
	
	local l1 = linksContainer:WaitForChild("Link1")
	local l2 = linksContainer:WaitForChild("Link2")

	local function setupLink(btn, lName, lID)
		btn.Visible = (lName ~= "" and lID ~= "")
		local label = btn:FindFirstChild("Label")
		if label then
			label.Text       = lName
			label.TextColor3 = textColor
		end

		local existing = btn:FindFirstChild("ClickConnection")
		if existing then existing:Destroy() end

		if btn.Visible then
			local sentinel = Instance.new("BoolValue", btn)
			sentinel.Name  = "ClickConnection"

			btn.MouseButton1Click:Connect(function()
				if linkClickStates[btn] then
					local placeId = tonumber(lID)
					if placeId then TeleportService:Teleport(placeId) end
				else
					linkClickStates[btn] = true
					showNotice("Join " .. lName .. "?", 3)
					task.delay(3, function()
						linkClickStates[btn] = false
					end)
				end
			end)
		end
	end

	local hasLinks = (data.Link1Name and data.Link1Name ~= "" and data.Link1ID and data.Link1ID ~= "")
		or (data.Link2Name and data.Link2Name ~= "" and data.Link2ID and data.Link2ID ~= "")
	linksContainer.Visible = hasLinks

	setupLink(l1, data.Link1Name or "", data.Link1ID or "")
	setupLink(l2, data.Link2Name or "", data.Link2ID or "")

	Menu.Visible            = false
	BiolinkTemplate.Visible = true
end

ShareLinkInput.FocusLost:Connect(function()
	local data = GetOwnProfile:InvokeServer()
	if data then
		ShareLinkInput.Text = BASE_URL .. (data.LinkName or "")
	end
end)

ShareLinkInput:GetPropertyChangedSignal("Text"):Connect(function()
	local data = GetOwnProfile:InvokeServer()
	if data then
		local correctLink = BASE_URL .. (data.LinkName or "")
		if ShareLinkInput.Text ~= correctLink and not ShareLinkInput:IsFocused() then
			ShareLinkInput.Text = correctLink
		end
	end
end)


SearchBtn.MouseButton1Click:Connect(function()
	local query = string.match(SearchBox.Text, "^%s*(.-)%s*$")
	if query == "" then return end
	local success, data = SearchProfile:InvokeServer(query)
	if success then
		openBiolink(data)
	else
		SearchBox.Text = "Not found"
		task.delay(1.5, function() SearchBox.Text = "" end)
	end
end)

CreateBtn.MouseButton1Click:Connect(function()
	Menu.Visible     = false
	Register.Visible = true
end)

ViewYourBtn.MouseButton1Click:Connect(function()
	local data = GetOwnProfile:InvokeServer()
	if data then openBiolink(data) end
end)

EditYourBtn.MouseButton1Click:Connect(function()
	local data = GetOwnProfile:InvokeServer()
	if not data then return end

	DisplayInput.Text      = data.DisplayName  or ""
	BioInput.Text          = data.Bio          or ""
	PFPInput.Text          = string.match(tostring(data.PFP or ""), "%d+") or ""
	ColorInput.Text        = data.BGColor      or "#ffffff"
	BGPicInput.Text        = data.BGPic        or ""
	ThemeInput.Text        = data.ProfileTheme or "#0d0d0d"
	TranspInput.Text       = tostring(data.FrameTransp or 0)
	GameListNameInput.Text = data.GameListName or ""
	GameListIDInput.Text   = data.GameListID   or ""
	L1NameInput.Text       = data.Link1Name    or ""
	L1IDInput.Text         = data.Link1ID      or ""
	L2NameInput.Text       = data.Link2Name    or ""
	L2IDInput.Text         = data.Link2ID      or ""
	PronounsInput.Text     = data.Pronouns     or ""
	ExtraBioInput.Text     = data.ExtraBio     or ""

	setProfileToggle(data.ShowRblxProfile   == true)
	setTypewriterToggle(data.TypewriterEnabled == true)
	setActivityToggle(data.ShowActivity      == true)
	setPronounsToggle(data.PronounsEnabled   == true)
	setExtraBioToggle(data.ExtraBioEnabled   == true)

	ShareLinkInput.Text = BASE_URL .. (data.LinkName or "")

	Menu.Visible = false
	Edit.Visible = true
end)

Register:WaitForChild("Create").MouseButton1Click:Connect(function()
	local requested    = Register:WaitForChild("Name").Text
	local success, msg = RegisterName:InvokeServer(requested)
	if success then
		Register.Visible = false
		checkBiolinkStatus()
		refreshFeatured()
		Menu.Visible = true
	else
		showNotice(msg, 2)
	end
end)

Edit:WaitForChild("ExitButton").MouseButton1Click:Connect(function()
	Edit.Visible = false
	Menu.Visible = true
end)

local SaveBtn = Edit:WaitForChild("Save")
SaveBtn.MouseButton1Click:Connect(function()
	if isOnCooldown then return end
	isOnCooldown = true
	SaveBtn.Text = "Saving..."

	local payload = {
		DisplayName        = DisplayInput.Text,
		Bio                = BioInput.Text,
		PFP                = PFPInput.Text,
		BGColor            = ColorInput.Text,
		BGPic              = BGPicInput.Text,
		ProfileTheme       = ThemeInput.Text,
		FrameTransp        = TranspInput.Text,
		GameListName       = GameListNameInput.Text,
		GameListID         = GameListIDInput.Text,
		Link1Name          = L1NameInput.Text,
		Link1ID            = L1IDInput.Text,
		Link2Name          = L2NameInput.Text,
		Link2ID            = L2IDInput.Text,
		ShowRblxProfile    = showRblxProfileEnabled,
		TypewriterEnabled  = typewriterEnabled,
		ShowActivity       = showActivityEnabled,
		PronounsEnabled    = pronounsEnabled,
		Pronouns           = PronounsInput.Text,
		ExtraBioEnabled    = extraBioEnabled,
		ExtraBio           = ExtraBioInput.Text,
	}

	local success, msg = SaveProfile:InvokeServer(payload)

	if success then
		SaveBtn.Text = "Saved!"
		task.wait(1.5)
	else
		SaveBtn.Text = msg or "Error"
		task.wait(2)
	end

	SaveBtn.Text = "Save"
	isOnCooldown = false
end)

BiolinkTemplate.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then
		BiolinkTemplate.Visible = false
		Menu.Visible            = true
		refreshFeatured()
	end
end)

checkBiolinkStatus()
refreshFeatured()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotesFolder = ReplicatedStorage:WaitForChild("BioLinkRemotes")
local OpenProfileFromLink = remotesFolder:WaitForChild("OpenProfileFromLink")
local SearchProfile = remotesFolder:WaitForChild("SearchProfile")

local function autoLoadProfile(targetName)
	print("Deep link detected! Loading profile for: " .. targetName)

	local success, profileData = SearchProfile:InvokeServer(targetName)

	if success and profileData then
		print("Successfully fetched data for " .. targetName)

		openBiolink(profileData) 

	else
		warn("Failed to load profile from link: " .. tostring(profileData))
	end
end

OpenProfileFromLink.OnClientEvent:Connect(function(launchUserName)
	autoLoadProfile(launchUserName)
end)
