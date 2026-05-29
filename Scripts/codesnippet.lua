-- I do not want to leak any source code and I also don't want to write any so I will just provide the entire frontend side of my Ro-Link game but with some parts deleted
-- Ro-Links a biolink (and the first of its kind on roblox) game. Link: https://www.roblox.com/games/71121446584935/Ro-Link

-- To put the way Ro-Link works in a _VERY_ simple way: The player can click between pages, and on these pages interact with the system.
-- (main) Menu (front) page: They can see featured pages, search for pages (using an on-platform username), register (and if already registered view their Ro-Link or edit it)
-- Edit: They can edit the page here, when saved, all data gets saved to datastores (those are handled on the server side)
-- Profiles (BiolinkTemplate), each time a profile is called to be loaded, the BiolinkTemplate (if you wanna see how it looks before runtime open file biolinktemplate) gets the loaded data
-- projected on it before opening.
-- The Register page allows the player to register, the only thing needed is an on-platform username, which can only be unique (no duplicate usernames).

-- The data is all called using the datastores which might introduce scaling issues but opzimizing and sacraficing a few milliseconds to load in waves and not instantly fixed those issues for me.

-- Special features:
-- The bioLINK side of Ro-Link: Ro-Link offers you a link, when the game is launched with your unique link, YOUR profile will open upon the game loading, you can see it on the dashboard.
"https://www.roblox.com/games/start?launchData=Mink&placeId=71121446584935" -- My link.

-- Custom backgrounds, profile pictures, bios and moderation, Ro-Link has a somewhat strong (but custom and not so strict) moderation and custom profile pictures which makes expressing yourself easy
-- and a lot more.

-- finally, here is the snippet: (the first 100 or so lines are just references, logic is more below)

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

-- [redacted 13 lines]

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

-- [redacted 20 lines]
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

-- [redacted 10 lines]

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

-- [redacted 40 lines]

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

-- [redacted 6 lines]

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

-- [redacted 28 lines]

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

-- [redacted 138 lines]


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
	print("link" .. targetName)

	local success, profileData = SearchProfile:InvokeServer(targetName)

	if success and profileData then
		print("data " .. targetName)

		openBiolink(profileData) 

	else
		warn("failed data " .. tostring(profileData))
	end
end

OpenProfileFromLink.OnClientEvent:Connect(function(launchUserName)
	autoLoadProfile(launchUserName)
end)
