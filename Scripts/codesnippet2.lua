-- This one is a simpler (yet I think important because it shows my skill to work with cameras and the way the player interacts with the world) script that does, however, do a lot for the player
-- It is a camera dampening system (which I made quickly, it has some bugs) 
-- This one I'll leave as is, because I reckon it will be easier that way and because it isn't important source code. I made it for a silly game I never published. 
-- CREDIT ME if you'll end up using this.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local SMOOTHNESS = 0.15 -- the higher the more close to the default roblox camera it is, 0.15 is perfect in my opinion
local SENSITIVITY = 0.6  -- i dont need to add a comment for this one i hope
local MIN_Y = -80       -- min. look up angle (pointing the camera down)
local MAX_Y = 80        -- max. look up angle (pointing the camera up from the feet)

local targetX, targetY = 0, 0
local currentX, currentY = 0, 0

camera.CameraType = Enum.CameraType.Custom

UserInputService.InputChanged:Connect(function(input, processed)
	if processed then return end

	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		targetX = targetX - (input.Delta.X * SENSITIVITY)
		targetY = targetY - (input.Delta.Y * SENSITIVITY)

		targetY = math.clamp(targetY, MIN_Y, MAX_Y)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart

	local alpha = math.clamp(dt * (1 / SMOOTHNESS), 0, 1)
	currentX = math.rad(math.deg(currentX) + (targetX - math.deg(currentX)) * alpha)
	currentY = math.rad(math.deg(currentY) + (targetY - math.deg(currentY)) * alpha)

	local cameraRotation = CFrame.Angles(0, currentX, 0) * CFrame.Angles(currentY, 0, 0)

	local targetCFrame = CFrame.new(rootPart.Position) * cameraRotation * CFrame.new(0, 2, 10)

	camera.CFrame = targetCFrame
end)
