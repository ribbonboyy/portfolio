-- This is a less important, and less big script but it is fully public though
-- It is a simple uniform system... yeah

local Players = game:GetService("Players")

local GROUP_ID = 87377824
local jollyolme = 3026380893

local VIP_SHIRT = "rbxassetid://102150897318563"
local RANK_253_SHIRT = "rbxassetid://111913447932553"
local RANK_200_SHIRT = "rbxassetid://129170915621491"
local HIGH_RANK_PANTS = "rbxassetid://97579904739927"
local RANK_10_SHIRT = "rbxassetid://94117148734849"
local JSC_PANTS = "rbxassetid://75578171304563"
local RANK_8_SHIRT = "rbxassetid://118324134035785"
local SMBA_PANTS = "rbxassetid://107951034343886"

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local shirt = character:WaitForChild("Shirt", 5) or Instance.new("Shirt", character)
		local pants = character:WaitForChild("Pants", 5) or Instance.new("Pants", character)

		local rank = player:GetRankInGroup(GROUP_ID)

		if player.UserId == jollyolme then
			shirt.ShirtTemplate = VIP_SHIRT
			pants.PantsTemplate = HIGH_RANK_PANTS

		elseif rank == 253 then
			shirt.ShirtTemplate = RANK_253_SHIRT
			pants.PantsTemplate = HIGH_RANK_PANTS
		
		elseif rank >= 10 then
			shirt.ShirtTemplate = RANK_10_SHIRT
			pants.PantsTemplate = JSC_PANTS

		elseif rank >= 200 then
			shirt.ShirtTemplate = RANK_200_SHIRT
			pants.PantsTemplate = HIGH_RANK_PANTS

		elseif rank >= 8 then
			shirt.ShirtTemplate = RANK_8_SHIRT
			pants.PantsTemplate = SMBA_PANTS
		end
	end)
end)
