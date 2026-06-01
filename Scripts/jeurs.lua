-- As mentioned before, the JEURS game is not released so I am fine with showing most of the scripts.

-- Administrator Console LocalScript
-- This script handles the administration console where administrators can order / buy new executive orders
-- It is a computer-console "hacker" style and it is pretty cold

local rs = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local toggleEvent = rs:WaitForChild("ToggleConsole")
local orderEvent = rs:WaitForChild("ExecuteOrder")

local gui = Instance.new("ScreenGui")
gui.Name = "ExecutiveConsole"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0.6, 0, 0.6, 0)
bg.Position = UDim2.new(0.2, 0, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BorderSizePixel = 4
bg.BorderColor3 = Color3.fromRGB(0, 255, 0)

local log = Instance.new("TextLabel", bg)
log.Size = UDim2.new(0.9, 0, 0.7, 0)
log.Position = UDim2.new(0.05, 0, 0.05, 0)
log.BackgroundTransparency = 1
log.TextColor3 = Color3.fromRGB(0, 255, 0)
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.Font = Enum.Font.Code
log.TextScaled = true

local input = Instance.new("TextBox", bg)
input.Size = UDim2.new(0.9, 0, 0.15, 0)
input.Position = UDim2.new(0.05, 0, 0.8, 0)
input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Code
input.TextSize = 24
input.Text = ""
input.PlaceholderText = "> INPUT COMMAND..."

local stage = "MENU"
local pendingOrder = 0
local menuText = "> SYSTEM BOOT... OK\n> AUTHENTICATION... OK\n\nHELLO, WHAT ORDER WOULD YOU LIKE TO ORDER?\n- 1: ADMIN FUNDING [500 CR]\n- 2: AUTO CO2 WASHER [3500 CR]\n\nTYPE NUMBER OR 'E' TO EXIT."

toggleEvent.OnClientEvent:Connect(function(state)
	gui.Enabled = state
	if state then
		log.Text = menuText
		stage = "MENU"
		input.Text = ""
		task.wait(0.1)
		input:CaptureFocus()
	end
end)

input.FocusLost:Connect(function(enter)
	if not enter then return end
	local text = input.Text:lower():gsub("%s+", "")
	input.Text = ""

	if text == "e" then
		gui.Enabled = false
		return
	end

	if stage == "MENU" then
		if text == "1" or text == "2" then
			pendingOrder = tonumber(text)
			log.Text = "> CONFIRM ORDER NO. " .. text .. "? (Y/N)"
			stage = "CONFIRM"
		end
	elseif stage == "CONFIRM" then
		if text == "y" then
			orderEvent:FireServer(pendingOrder)
			log.Text = "> COMMAND SENT. PROCESSING..."
			task.wait(1.5)
			log.Text = menuText
			stage = "MENU"
		else
			log.Text = menuText
			stage = "MENU"
		end
	end

	task.wait(0.1)
	if gui.Enabled then
		input:CaptureFocus()
	end
end)

-- ill add later im going to a raid
