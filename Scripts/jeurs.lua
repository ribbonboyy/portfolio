-- As mentioned before, the JEURS game is not released so I am fine with showing most of the scripts.

-- Administrator Console LocalScript
-- This script handles the administration console where administrators can order / buy new executive orders
-- It is a computer-console styled system
-- Most of the system is handled here on this LocalScript, using a custom UI that the script creates. It uses TextBoxes for user input and TextLabels for the system output.
-- I think that it's pretty cool but idk 

local rs = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local toggleEvent = rs:WaitForChild("toggleconsole")
local orderEvent = rs:WaitForChild("executeorder")

local gui = Instance.new("ScreenGui")
gui.Name = "executiveconsole"
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
input.PlaceholderText = "> Input command"

local stage = "MENU"
local pendingOrder = 0
local menuText = "> Waiting for system... Loaded\n> Authenticaion... Loaded\n\nHello Administrator, What executive order are we signing today?\n- 1: Administration Funding [500 CR]\n- 2: Auto CO2 Filter [3500 CR]\n\nPlease type a number coresponding to an EO or E to close.."

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
			log.Text = "> Confirm the executive order Number " .. text .. "? (Y/N)"
			stage = "CONFIRM"
		end
	elseif stage == "CONFIRM" then
		if text == "y" then
			orderEvent:FireServer(pendingOrder)
			log.Text = "> Command sent Procesing..."
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

-- Lockdown administration button
-- This script is inside of a button only the administrators can enable that locks down the plant, it uses ProximityPrompts for ease of use. It also features a gliding (sine) animation.
-- See the locked administration building during a lockdown in the Assets folder as "lockdown.png"
local rs = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local stats = rs:WaitForChild("StationStats")

local deskEvent = rs:FindFirstChild("deskevent") 

local isLockedDown = false

deskEvent.OnServerEvent:Connect(function(player, actionType)

	if actionType == "togglelockdown" then
		isLockedDown = not isLockedDown

		for _, model in pairs(workspace:GetDescendants()) do
			if model:IsA("Model") and model.Name == "Lockdown" then

				local doorL = model:FindFirstChild("LockDownDoorL")
				local doorR = model:FindFirstChild("LockDownDoorR")

				local lTarget = isLockedDown and model:FindFirstChild("LeftPos") or model:FindFirstChild("LeftPosDef")
				local rTarget = isLockedDown and model:FindFirstChild("RightPos") or model:FindFirstChild("RightPosDef")

				local tInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

				if doorL and lTarget then
					TweenService:Create(doorL, tInfo, {CFrame = lTarget.CFrame}):Play()
				end
				
				if doorR and rTarget then
					TweenService:Create(doorR, tInfo, {CFrame = rTarget.CFrame}):Play()
				end
			end
		end
	end

end)

-- Smaller Scripts/Snippets
-- The GUI animation handling script, nothing to comment on
local TweenService = game:GetService("TweenService")
local screenGui = script.Parent

local buttonsFrame = screenGui:WaitForChild("Buttons")
local triggerButton = buttonsFrame:WaitForChild("Play")
local centerPlayFrame = screenGui:WaitForChild("Play") 

local tInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

triggerButton.MouseButton1Click:Connect(function()
	local buttonsGoal = UDim2.new(-0.7, 0, buttonsFrame.Position.Y.Scale, 0)
	TweenService:Create(buttonsFrame, tInfo, {Position = buttonsGoal}):Play()

	for _, child in pairs(screenGui:GetChildren()) do
		if child.Name == "MenuText" then
			local textGoal = UDim2.new(-0.7, 0, child.Position.Y.Scale, 0)
			TweenService:Create(child, tInfo, {Position = textGoal}):Play()
		end
	end

	centerPlayFrame.Visible = true
	local targetPos = UDim2.new(0.124, 0, 0.105, 0)
	TweenService:Create(centerPlayFrame, tInfo, {Position = targetPos}):Play()
end)

-- The team switch script
-- This script uses the container (frame) name as a means to switch a person to a team. 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local gui = script.Parent
local deployEvent = ReplicatedStorage:WaitForChild("DeployRequest")

local playFrame = gui:WaitForChild("Play")
local scrollingFrame = playFrame:WaitForChild("ScrollingFrame")

local function setupButtons()
	for _, container in pairs(scrollingFrame:GetChildren()) do
		if container:IsA("Frame") then
			local btn = container:FindFirstChildWhichIsA("ImageButton") or container:FindFirstChildWhichIsA("TextButton")

			if btn then
				btn.MouseButton1Click:Connect(function()
					deployEvent:FireServer(container.Name)
					gui.Enabled = false
				end)
			end
		end
	end
end

setupButtons()
