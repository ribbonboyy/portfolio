-- This is a script from the aforementioned NS game.
-- This is the client-side GUI handler script.
-- It features a lot of important and cool features, including a dish assamble mode and more stuff that make the game feel alive
-- I hope this also shows my script skills more, I tried to redact only the least important things.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player: Player = Players.LocalPlayer

local openMenuEvent: RemoteEvent = ReplicatedStorage:WaitForChild("OpenOrderingMenu", 10) :: RemoteEvent
local confirmOrderEvent: RemoteEvent = ReplicatedStorage:WaitForChild("ConfirmOrder", 10) :: RemoteEvent
local orderPlacedEvent: RemoteEvent = ReplicatedStorage:WaitForChild("OrderPlaced", 10) :: RemoteEvent

local FoodsModule = require(ReplicatedStorage:WaitForChild("Foods")) :: {[string]: {[string]: {Description: string, Model: string}}}
local CategoriesModule = require(ReplicatedStorage:WaitForChild("Categories")) :: {string}

local ModelsFolder: Folder = ReplicatedStorage:WaitForChild("Foods"):WaitForChild("Models")

local gui: ScreenGui = script.Parent :: ScreenGui
local MainFrame: Frame = gui:WaitForChild("MainFrame") :: Frame

local FoodCategoryFrame: Frame = MainFrame:WaitForChild("FoodCategory") :: Frame
local FcTemplate: Frame = FoodCategoryFrame:WaitForChild("FcTemplate") :: Frame

local SpecificFoodFrame: Frame = MainFrame:WaitForChild("SpecificFood") :: Frame
local SpTemplate: Frame = SpecificFoodFrame:WaitForChild("SpTemplate") :: Frame

local ShoppingCartFrame: Frame = MainFrame:WaitForChild("ShoppingCart") :: Frame
local ScTemplate: Frame = ShoppingCartFrame:WaitForChild("ScTemplate") :: Frame

local ConfirmButton: TextButton = MainFrame:WaitForChild("ConfirmORder") :: TextButton
local CloseButton: TextButton = MainFrame:WaitForChild("CloseButton") :: TextButton

FcTemplate.Visible = false
SpTemplate.Visible = false
ScTemplate.Visible = false
MainFrame.Visible = false

type OrderItem = {
	Name: string,
	Description: string,
	Category: string,
	Model: string,
}

local playerOrder: {OrderItem} = {}

local function clearClones(parent: Frame, template: Frame): ()
	for _, child in ipairs(parent:GetChildren()) do
		if child == template then continue end
		if child:IsA("UIListLayout") then continue end
		if child:IsA("UICorner") then continue end
		if child:IsA("UIPadding") then continue end
		if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
			child:Destroy()
		end
	end
end

local function safeFind<T>(parent: Instance, name: string): T?
	local child = parent:FindFirstChild(name)
	return child :: T?
end

local function buildCamera(viewport: ViewportFrame, model: Model): Camera
	for _, c in ipairs(viewport:GetChildren()) do
		if c:IsA("Camera") then c:Destroy() end
	end

-- 19 lines redacted 

local function loadModelIntoViewport(viewport: ViewportFrame, modelName: string): ()
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") then
			child:Destroy()
		end
	end

	if modelName == nil or modelName == "" then return end

	local source: Model? = ModelsFolder:FindFirstChild(modelName) :: Model?

	local cloned: Model = source:Clone()

	if cloned.PrimaryPart then
		cloned:PivotTo(CFrame.new(0, 0, 0))
	end

	cloned.Parent = viewport
	buildCamera(viewport, cloned)
end

-- 29 lines redacted 

local function attachViewportHover(viewport: ViewportFrame): ()
	local camera: Camera? = viewport.CurrentCamera
	if not camera then return end

	local baseCFrame: CFrame = camera.CFrame
	local moveConnection: RBXScriptConnection

	local function connect(): ()
		moveConnection = viewport.MouseMoved:Connect(function(x: number, y: number)
			local relativeX: number = (x - viewport.AbsolutePosition.X) / viewport.AbsoluteSize.X
			local relativeY: number = (y - viewport.AbsolutePosition.Y) / viewport.AbsoluteSize.Y
			local tiltX: number = (relativeX - 0.5) * 20
			local tiltY: number = (relativeY - 0.5) * 10
			camera.CFrame = baseCFrame * CFrame.Angles(math.rad(-tiltY), math.rad(-tiltX), 0)
		end)
	end

	viewport.MouseLeave:Connect(function()
		if moveConnection then moveConnection:Disconnect() end
		camera.CFrame = baseCFrame
	end)

	viewport.MouseEnter:Connect(function()
		baseCFrame = camera.CFrame
		connect()
	end)

	connect()
end

local function loadSpecificFoods(categoryName: string): ()
	clearClones(SpecificFoodFrame, SpTemplate)

	local categoryFoods: {[string]: {Description: string, Model: string}}? = FoodsModule[categoryName]
	if not categoryFoods then return end

	for foodName: string, foodData in pairs(categoryFoods) do
		local clone: Frame = SpTemplate:Clone() :: Frame
		clone.Name = "SpEntry_" .. foodName
		clone.Visible = true

		local nameLabel: TextLabel? = safeFind(clone, "Name")
		local descLabel: TextLabel? = safeFind(clone, "Description")
		local modelViewport: ViewportFrame? = safeFind(clone, "Model")
		local selectBtn: TextButton? = safeFind(clone, "Select")

		if nameLabel then (nameLabel :: TextLabel).Text = foodName end
		if descLabel then (descLabel :: TextLabel).Text = foodData.Description or "" end
		if modelViewport then
			loadModelIntoViewport(modelViewport :: ViewportFrame, foodData.Model)
			attachViewportHover(modelViewport :: ViewportFrame)
		end

		if selectBtn then
			local capturedFood: string = foodName
			local capturedData: {Description: string, Model: string} = foodData
			local capturedCategory: string = categoryName

			;(selectBtn :: TextButton).MouseButton1Click:Connect(function()
				table.insert(playerOrder, {
					Name = capturedFood,
					Description = capturedData.Description or "",
					Category = capturedCategory,
					Model = capturedData.Model or "",
				})  
				refreshShoppingCart()
			end)
		end

		clone.Parent = SpecificFoodFrame
	end
end

-- 36 lines redacted 

local function closeMenu(): ()
	MainFrame.Visible = false
	playerOrder = {}
	refreshShoppingCart()
end

CloseButton.MouseButton1Click:Connect(closeMenu)

ConfirmButton.MouseButton1Click:Connect(function()
	if #playerOrder == 0 then return end
	confirmOrderEvent:FireServer(playerOrder)
	closeMenu()
end)

openMenuEvent.OnClientEvent:Connect(function()
	local isNowVisible: boolean = not MainFrame.Visible
	MainFrame.Visible = isNowVisible

	if isNowVisible then
		loadCategories()
		refreshShoppingCart()
	end
end)

-- coded by wez for the ns. dont steal
