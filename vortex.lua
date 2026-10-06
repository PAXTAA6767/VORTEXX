local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIGURAÇÕES
--------------------------------------------------

local ESP = true
local PLAYERS = true
local BOXES = true
local NAMES = true
local DISTANCE = true
local TRACERS = false

local ESPData = {}

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VitexxTestPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- PAINEL
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 760, 0, 500)
Main.Position = UDim2.new(0.5, -380, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--------------------------------------------------
-- BARRA SUPERIOR
--------------------------------------------------

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "☾  Chaos"
Title.TextColor3 = Color3.fromRGB(225, 225, 225)
Title.TextSize = 15
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

--------------------------------------------------
-- FECHAR
--------------------------------------------------

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -48, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.TextSize = 25
Close.Font = Enum.Font.Gotham
Close.Parent = TopBar

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--------------------------------------------------
-- ABA
--------------------------------------------------

local Tab = Instance.new("Frame")
Tab.Size = UDim2.new(0, 155, 0, 35)
Tab.Position = UDim2.new(0, 165, 0, 5)
Tab.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
Tab.BorderSizePixel = 0
Tab.Parent = TopBar

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 7)
TabCorner.Parent = Tab

local TabText = Instance.new("TextLabel")
TabText.Size = UDim2.new(1, -35, 1, 0)
TabText.Position = UDim2.new(0, 10, 0, 0)
TabText.BackgroundTransparency = 1
TabText.Text = "👁  Visuals"
TabText.TextColor3 = Color3.fromRGB(220, 220, 220)
TabText.TextSize = 14
TabText.Font = Enum.Font.Gotham
TabText.TextXAlignment = Enum.TextXAlignment.Left
TabText.Parent = Tab

--------------------------------------------------
-- ENDEREÇO
--------------------------------------------------

local Address = Instance.new("TextLabel")
Address.Size = UDim2.new(1, -30, 0, 34)
Address.Position = UDim2.new(0, 15, 0, 55)
Address.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Address.BorderSizePixel = 0
Address.Text = "  🔍   Test Environment / Visuals"
Address.TextColor3 = Color3.fromRGB(145, 145, 150)
Address.TextSize = 14
Address.Font = Enum.Font.Gotham
Address.TextXAlignment = Enum.TextXAlignment.Left
Address.Parent = Main

local AddressCorner = Instance.new("UICorner")
AddressCorner.CornerRadius = UDim.new(0, 7)
AddressCorner.Parent = Address

--------------------------------------------------
-- ÁREA DAS OPÇÕES
--------------------------------------------------

local Options = Instance.new("Frame")
Options.Size = UDim2.new(1, -30, 0, 350)
Options.Position = UDim2.new(0, 15, 0, 100)
Options.BackgroundColor3 = Color3.fromRGB(39, 39, 44)
Options.BorderSizePixel = 0
Options.Parent = Main

local OptionsCorner = Instance.new("UICorner")
OptionsCorner.CornerRadius = UDim.new(0, 10)
OptionsCorner.Parent = Options

--------------------------------------------------
-- TOGGLE
--------------------------------------------------

local function CreateOption(text, y, default, callback)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -30, 0, 55)
	Button.Position = UDim2.new(0, 15, 0, y)
	Button.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = Options

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -75, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(225, 225, 225)
	Label.TextSize = 19
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	local Check = Instance.new("Frame")
	Check.Size = UDim2.new(0, 24, 0, 24)
	Check.Position = UDim2.new(1, -45, 0.5, -12)
	Check.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
	Check.BorderSizePixel = 2
	Check.BorderColor3 = Color3.fromRGB(135, 135, 140)
	Check.Parent = Button

	local CheckCorner = Instance.new("UICorner")
	CheckCorner.CornerRadius = UDim.new(0, 3)
	CheckCorner.Parent = Check

	local Mark = Instance.new("TextLabel")
	Mark.Size = UDim2.fromScale(1, 1)
	Mark.BackgroundTransparency = 1
	Mark.Text = "✓"
	Mark.TextColor3 = Color3.new(1, 1, 1)
	Mark.TextSize = 17
	Mark.Font = Enum.Font.GothamBold
	Mark.Visible = false
	Mark.Parent = Check

	local enabled = default

	local function Update()

		if enabled then
			Check.BackgroundColor3 = Color3.fromRGB(65, 135, 195)
			Check.BorderColor3 = Color3.fromRGB(85, 155, 215)
			Mark.Visible = true
		else
			Check.BackgroundColor3 = Color3.fromRGB(42, 42, 46)
			Check.BorderColor3 = Color3.fromRGB(135, 135, 140)
			Mark.Visible = false
		end

		callback(enabled)
	end

	Button.MouseButton1Click:Connect(function()
		enabled = not enabled
		Update()
	end)

	Update()
end

--------------------------------------------------
-- OPÇÕES
--------------------------------------------------

CreateOption("Enable Esp", 15, true, function(value)
	ESP = value
end)

CreateOption("Enable Players", 80, true, function(value)
	PLAYERS = value
end)

CreateOption("Enable Boxes", 145, true, function(value)
	BOXES = value
end)

CreateOption("Enable Names", 210, true, function(value)
	NAMES = value
end)

CreateOption("Enable Distance", 275, true, function(value)
	DISTANCE = value
end)

--------------------------------------------------
-- COR DO TIME
--------------------------------------------------

local function GetTeamColor(player)

	if player.Team then
		return player.Team.TeamColor.Color
	end

	return Color3.fromRGB(255, 255, 255)
end

--------------------------------------------------
-- CRIAR ESP
--------------------------------------------------

local function CreateESP(player)

	if player == LocalPlayer then
		return
	end

	if ESPData[player] then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "TeamESP"
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerInfo"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextStrokeTransparency = 0
	text.TextSize = 14
	text.Font = Enum.Font.GothamBold
	text.Parent = billboard

	ESPData[player] = {
		Highlight = highlight,
		Billboard = billboard,
		Text = text
	}
end

--------------------------------------------------
-- REMOVER ESP
--------------------------------------------------

local function RemoveESP(player)

	if ESPData[player] then

		ESPData[player].Highlight:Destroy()
		ESPData[player].Billboard:Destroy()

		ESPData[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--------------------------------------------------
-- ATUALIZAÇÃO
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	for player, data in pairs(ESPData) do

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if not character or not root or not ESP or not PLAYERS then

			data.Highlight.Enabled = false
			data.Billboard.Enabled = false

			continue
		end

		--------------------------------------------------
		-- COR DO TIME
		--------------------------------------------------

		local teamColor = GetTeamColor(player)

		data.Highlight.OutlineColor = teamColor
		data.Text.TextColor3 = teamColor

		--------------------------------------------------
		-- BOX
		--------------------------------------------------

		data.Highlight.Adornee = character
		data.Highlight.Enabled = BOXES

		--------------------------------------------------
		-- NOME / DISTÂNCIA
		--------------------------------------------------

		local myCharacter = LocalPlayer.Character
		local myRoot = myCharacter
			and myCharacter:FindFirstChild("HumanoidRootPart")

		if myRoot then

			local distance = math.floor(
				(myRoot.Position - root.Position).Magnitude
			)

			local text = ""

			if NAMES then
				text = player.DisplayName
			end

			if DISTANCE then

				if text ~= "" then
					text = text .. "\n"
				end

				text = text .. distance .. " studs"
			end

			data.Text.Text = text
			data.Billboard.Parent = root
			data.Billboard.Enabled = NAMES or DISTANCE
		end
	end
end)

--------------------------------------------------
-- TECLA K
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.K then
		Main.Visible = not Main.Visible
	end
end)

--------------------------------------------------
-- ARRASTAR PAINEL
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end

		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)
