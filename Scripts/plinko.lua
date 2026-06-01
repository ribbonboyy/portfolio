-- This is my plinko system, I setup and use(d) it in most of my social games, inspired by flex your weather. 
-- I created this system when I was very new to scripting so it might be shitty at times (mainly the runtime script UI creation logic) but it is still a very cool system and I still use and am proud of.
-- It uses physics to make the balls decide what reward a player gets, making it more or less not riggable because the player can easily control where the ball hits. 
-- A "Cash" leaderstat is needed for it to work but I hope that's obvious

-- PlinkoCl
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plinkoButton = workspace:WaitForChild("plinko_button", 10)
local buttonPart = plinkoButton:WaitForChild("plinko_button_part", 10)
local gui = buttonPart:WaitForChild("plinko_gui", 10)
local buyButton = gui:WaitForChild("plinko_buy", 10)

local BuyEvent = ReplicatedStorage:WaitForChild("buyplinko", 10)

local connection
connection = buyButton.MouseButton1Click:Connect(function()
	buyButton.Active = false

	local success = pcall(function()
		BuyEvent:FireServer()
	end)

	task.wait(0.5)
	if buyButton and buyButton.Parent then
		buyButton.Active = true
	end
end)

if gui then
	gui.AncestryChanged:Connect(function()
		if not gui.Parent and connection then
			connection:Disconnect()
		end
	end)
end

-- PlinkoNotif
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local BuyEvent = ReplicatedStorage:WaitForChild("buyplinko")
local NotifyEvent = ReplicatedStorage:WaitForChild("shownotification")
local plinkoButton = workspace:WaitForChild("plinko_button")
local buttonPart = plinkoButton:WaitForChild("plinko_button_part")
local surfaceGui = buttonPart:WaitForChild("plinko_gui")
local button = surfaceGui:WaitForChild("plinko_buy")

button.MouseButton1Click:Connect(function()
	BuyEvent:FireServer()
end)

local function createnotifGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "notificationgui"
	gui.ResetOnSpawn = false
	gui.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Name = "notifyframe"
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5) 
	frame.Position = UDim2.new(0.5, 0, 0.8, 0)
	frame.Size = UDim2.new(0, 0, 0, 0) 
	frame.ClipsDescendants = true
	frame.Visible = false
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local text = Instance.new("TextLabel")
	text.Name = "notifytext"
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextSize = 14
	text.Font = Enum.Font.RobotoMono 
	text.Parent = frame

	return frame, text
end

local frame, textLabel = createnotifGui()

notifyevent.OnClientEvent:Connect(function(message, color)
	textLabel.Text = message:upper()
	textLabel.TextColor3 = color or Color3.new(1, 1, 1)

	frame.Visible = true

	local openTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 250, 0, 40) 
	})

	openTween:Play()
	task.wait(2.5)

	local closeTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0)
	})

	closeTween:Play()
	closeTween.Completed:Wait()
	frame.Visible = false
end)

-- Plinko (the server-side script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local BuyEvent = ReplicatedStorage:WaitForChild("buyplinko")
local NotifyEvent = ReplicatedStorage:WaitForChild("shownotification")

local BallTemplate = ReplicatedStorage:WaitForChild("Ball")
local BallSpawn = workspace:WaitForChild("Ball_spawn")
local PlinkoResults = workspace:WaitForChild("plinko_results")

local COOLDOWN_TIME = 0.5
local cooldowns = {} 

local rewardMap = {
	Amazing = 8,
	Good = 7,
	Meh = 6,
	Mid = 4,
	Bad = 3,
}

local BALL_COST = 5
local MAX_BALL_LIFETIME = 30 

BuyEvent.OnServerEvent:Connect(function(player)
	if cooldowns[player.UserId] and tick() - cooldowns[player.UserId] < COOLDOWN_TIME then
		return
	end

	if not player or not player.Parent then return end

	local stats = player:FindFirstChild("leaderstats")
	local cash = stats and stats:FindFirstChild("Cash")

	if cash.Value < BALL_COST then
		NotifyEvent:FireClient(player, "Not enough Cash!", Color3.new(1, 0.3, 0.3))
		return
	end

	cooldowns[player.UserId] = tick()

	cash.Value = math.max(0, cash.Value - BALL_COST)
	local ball = BallTemplate:Clone()

	ball.CFrame = BallSpawn.CFrame
	ball.Parent = workspace

	Debris:AddItem(ball, MAX_BALL_LIFETIME)

	local rewarded = false
	local connection

	connection = ball.Touched:Connect(function(hit)
		if rewarded or not player.Parent then 
			if connection then connection:Disconnect() end
			return 
		end

		local reward = rewardMap[hit.Name]
		if reward then
			rewarded = true
			if connection then connection:Disconnect() end

			local total = reward

			if cash and cash.Parent then
				cash.Value = cash.Value + total
				pcall(function()
					NotifyEvent:FireClient(player, "+" .. total .. " Cash!", Color3.fromRGB(80, 255, 80))
				end)
			end

			task.delay(1, function()
				if ball and ball.Parent then ball:Destroy() end
			end)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	cooldowns[player.UserId] = nil
end)
