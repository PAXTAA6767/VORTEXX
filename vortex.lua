local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIGURAÇÕES
--------------------------------------------------

local Settings = {
	-- Jogador
	WalkSpeedBoost = 0,

	-- Interface
	ToggleKey = Enum.KeyCode.K,
	Theme = "Dark",

	-- Visual
	EnableESP = false,
	EnableBoxes = false,
	EnableNames = false,
	EnableDistance = false,
	EnableTracers = false,

}

-- Será definido na parte do ESP; permite que os toggles atualizem imediatamente.
local refreshAllESP
local GetTheme


--------------------------------------------------
-- WALK SPEED - JOGADOR
-- 0 = NORMAL | 1-100 = VELOCIDADE DEFINIDA
--------------------------------------------------

local NormalWalkSpeed = 16
local CurrentHumanoid = nil

local function getHumanoid()
	local character = Player.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function captureHumanoid()
	local humanoid = getHumanoid()
	if not humanoid then
		return nil
	end

	if CurrentHumanoid ~= humanoid then
		CurrentHumanoid = humanoid

		-- Ao trocar de personagem, captura a velocidade normal dele.
		NormalWalkSpeed = humanoid.WalkSpeed
	end

	return humanoid
end

local function applyWalkSpeed()
	local humanoid = captureHumanoid()
	if not humanoid then
		return
	end

	if Settings.WalkSpeedBoost == 0 then
		if humanoid.WalkSpeed ~= NormalWalkSpeed then
			humanoid.WalkSpeed = NormalWalkSpeed
		end
	else
		-- Mesmo princípio do código desofuscado:
		-- humanoid.WalkSpeed = CONFIG.speed
		if humanoid.WalkSpeed ~= Settings.WalkSpeedBoost then
			humanoid.WalkSpeed = Settings.WalkSpeedBoost
		end
	end
end

local function setWalkSpeedBoost(value)
	value = tonumber(value) or 0
	value = math.clamp(math.floor(value + 0.5), 0, 100)

	local humanoid = captureHumanoid()

	-- Antes de sair do 0, guarda o valor normal atual.
	if humanoid and Settings.WalkSpeedBoost == 0 and value > 0 then
		NormalWalkSpeed = humanoid.WalkSpeed
	end

	Settings.WalkSpeedBoost = value
	applyWalkSpeed()

	return value
end

Player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then
		return
	end

	task.wait(0.15)
	CurrentHumanoid = humanoid
	NormalWalkSpeed = humanoid.WalkSpeed
	applyWalkSpeed()
end)

-- Reaplica a velocidade e, se necessário, reforça o movimento horizontal.
-- Isso ajuda em jogos que possuem outro controlador alterando o WalkSpeed.
RunService.Heartbeat:Connect(function()
	if Settings.WalkSpeedBoost <= 0 then
		return
	end

	applyWalkSpeed()

	local character = Player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return
	end

	local direction = humanoid.MoveDirection

	if direction.Magnitude > 0 then
		local currentY = root.AssemblyLinearVelocity.Y
		local horizontal = direction.Unit * Settings.WalkSpeedBoost

		root.AssemblyLinearVelocity = Vector3.new(
			horizontal.X,
			currentY,
			horizontal.Z
		)
	end
end)

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "VortexPanel"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.Parent = PlayerGui

--------------------------------------------------
-- JANELA PRINCIPAL - VISUAL ESTILO MERCURY/CHAOS
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 700, 0, 460)
Main.Position = UDim2.new(0.5, -350, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 7)
MainCorner.Parent = Main

--------------------------------------------------
-- ABA SUPERIOR
--------------------------------------------------

local Top = Instance.new("Frame")
Top.Name = "Top"
Top.Size = UDim2.new(0, 150, 0, 32)
Top.Position = UDim2.new(0, 5, 0, 4)
Top.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 7)
TopCorner.Parent = Top

local Moon = Instance.new("TextLabel")
Moon.Size = UDim2.new(0, 28, 1, 0)
Moon.Position = UDim2.new(0, 8, 0, 0)
Moon.BackgroundTransparency = 1
Moon.Text = "☾"
Moon.TextColor3 = Color3.fromRGB(225, 225, 230)
Moon.TextSize = 24
Moon.Font = Enum.Font.Gotham
Moon.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 38, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Vortex"
Title.TextColor3 = Color3.fromRGB(220, 220, 225)
Title.TextSize = 16
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Size = UDim2.new(0, 32, 0, 32)
Close.Position = UDim2.new(1, -43, 0, 4)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 225)
Close.TextSize = 26
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Main

Close.Activated:Connect(function()
	Main.Visible = false
end)

--------------------------------------------------
-- BARRA DE ENDEREÇO
--------------------------------------------------

local Address = Instance.new("Frame")
Address.Name = "Address"
Address.Size = UDim2.new(1, -12, 0, 32)
Address.Position = UDim2.new(0, 6, 0, 40)
Address.BackgroundColor3 = Color3.fromRGB(45, 45, 51)
Address.BorderSizePixel = 0
Address.Parent = Main

local AddressCorner = Instance.new("UICorner")
AddressCorner.CornerRadius = UDim.new(0, 7)
AddressCorner.Parent = Address

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 35, 1, 0)
SearchIcon.Position = UDim2.new(0, 7, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "⌕"
SearchIcon.TextColor3 = Color3.fromRGB(71, 142, 190)
SearchIcon.TextSize = 23
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.Parent = Address

local AddressText = Instance.new("TextLabel")
AddressText.Size = UDim2.new(1, -48, 1, 0)
AddressText.Position = UDim2.new(0, 42, 0, 0)
AddressText.BackgroundTransparency = 1
AddressText.Text = "https://github.com/PAXTAA6767/VORTEXX/home"
AddressText.TextColor3 = Color3.fromRGB(145, 145, 150)
AddressText.TextSize = 16
AddressText.Font = Enum.Font.Gotham
AddressText.TextXAlignment = Enum.TextXAlignment.Left
AddressText.TextTruncate = Enum.TextTruncate.AtEnd
AddressText.Parent = Address

--------------------------------------------------
-- ÁREA PRINCIPAL
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -12, 1, -94)
Content.Position = UDim2.new(0, 6, 0, 77)
Content.BackgroundColor3 = Color3.fromRGB(37, 37, 42)
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Main

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = Content

--------------------------------------------------
-- STATUS INFERIOR
--------------------------------------------------

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -12, 0, 18)
Status.Position = UDim2.new(0, 6, 1, -20)
Status.BackgroundTransparency = 1
Status.RichText = true
Status.Text = '<font color="rgb(70,145,200)">Status</font><font color="rgb(110,110,118)"> | Idle</font>'
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.fromRGB(120, 120, 125)
Status.Parent = Main

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function ClearContent()
	for _, object in ipairs(Content:GetChildren()) do
		if not object:IsA("UICorner") then
			object:Destroy()
		end
	end
end

local function CreateBackButton(callback)
	local Back = Instance.new("TextButton")
	Back.Size = UDim2.new(0, 112, 0, 38)
	Back.Position = UDim2.new(0, 16, 0, 16)
	Back.BackgroundColor3 = Color3.fromRGB(48, 48, 54)
	Back.BorderSizePixel = 0
	Back.Text = "←  Voltar"
	Back.TextColor3 = Color3.fromRGB(220, 220, 225)
	Back.TextSize = 14
	Back.Font = Enum.Font.Gotham
	Back.AutoButtonColor = false
	Back.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Back

	Back.Activated:Connect(callback)
	return Back
end

local function CreateOption(parent, text, y, value, callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -32, 0, 54)
	Button.Position = UDim2.new(0, 16, 0, y)
	Button.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Button

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -78, 1, 0)
	Label.Position = UDim2.new(0, 16, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(220, 220, 225)
	Label.TextSize = 17
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	local Check = Instance.new("Frame")
	Check.Size = UDim2.new(0, 24, 0, 24)
	Check.Position = UDim2.new(1, -42, 0.5, -12)
	Check.BackgroundColor3 = Color3.fromRGB(39, 39, 44)
	Check.BorderSizePixel = 1
	Check.BorderColor3 = Color3.fromRGB(115, 115, 122)
	Check.Parent = Button

	local CheckCorner = Instance.new("UICorner")
	CheckCorner.CornerRadius = UDim.new(0, 4)
	CheckCorner.Parent = Check

	local Mark = Instance.new("TextLabel")
	Mark.Size = UDim2.fromScale(1, 1)
	Mark.BackgroundTransparency = 1
	Mark.Text = "✓"
	Mark.TextColor3 = Color3.fromRGB(240, 240, 245)
	Mark.TextSize = 16
	Mark.Font = Enum.Font.GothamBold
	Mark.Parent = Check

	local Enabled = value

	local function Update(fireCallback)
		if Enabled then
			Check.BackgroundColor3 = GetTheme().Accent
			Check.BorderColor3 = GetTheme().Accent
			Mark.Visible = true
		else
			Check.BackgroundColor3 = Color3.fromRGB(39, 39, 44)
			Check.BorderColor3 = Color3.fromRGB(115, 115, 122)
			Mark.Visible = false
		end

		if fireCallback then
			callback(Enabled)
		end
	end

	Button.Activated:Connect(function()
		Enabled = not Enabled
		Update(true)

		if refreshAllESP then
			task.defer(refreshAllESP)
		end
	end)

	Update(false)
	return Button
end

local function CreateMenuTitle(titleText)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -160, 0, 42)
	Label.Position = UDim2.new(0, 145, 0, 14)
	Label.BackgroundTransparency = 1
	Label.Text = titleText
	Label.TextColor3 = GetTheme().Accent
	Label.TextSize = 21
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Content
end

local function CreateHomeSquareButton(x, imageId, tooltip, callback, useAvatar)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 82, 0, 82)
	Button.Position = UDim2.new(0.5, x, 0, 195)
	Button.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	if useAvatar then
		local Avatar = Instance.new("ImageLabel")
		Avatar.Size = UDim2.new(0, 48, 0, 48)
		Avatar.Position = UDim2.new(0.5, -24, 0.5, -24)
		Avatar.BackgroundTransparency = 1
		Avatar.BorderSizePixel = 0
		Avatar.ScaleType = Enum.ScaleType.Crop
		Avatar.Parent = Button

		local AvatarCorner = Instance.new("UICorner")
		AvatarCorner.CornerRadius = UDim.new(1, 0)
		AvatarCorner.Parent = Avatar

		task.spawn(function()
			local ok, image = pcall(function()
				return Players:GetUserThumbnailAsync(
					Player.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size150x150
				)
			end)

			if ok and Avatar.Parent then
				Avatar.Image = image
			end
		end)
	else
		local Icon = Instance.new("ImageLabel")
		Icon.Size = UDim2.new(0, 34, 0, 34)
		Icon.Position = UDim2.new(0.5, -17, 0.5, -17)
		Icon.BackgroundTransparency = 1
		Icon.Image = imageId
		Icon.ImageColor3 = Color3.fromRGB(225, 225, 230)
		Icon.ScaleType = Enum.ScaleType.Fit
		Icon.Parent = Button
	end

	local Tip = Instance.new("TextLabel")
	Tip.Size = UDim2.new(0, 120, 0, 22)
	Tip.Position = UDim2.new(0.5, -60, 1, 4)
	Tip.BackgroundTransparency = 1
	Tip.Text = tooltip
	Tip.TextColor3 = Color3.fromRGB(145, 145, 152)
	Tip.TextSize = 12
	Tip.Font = Enum.Font.Gotham
	Tip.Visible = false
	Tip.Parent = Button

	Button.MouseEnter:Connect(function()
		Tip.Visible = true
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
	end)

	Button.MouseLeave:Connect(function()
		Tip.Visible = false
		Button.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
	end)

	Button.Activated:Connect(callback)

	return Button
end


--------------------------------------------------
-- TEMAS DA INTERFACE
--------------------------------------------------

local Themes = {
	Serika = {
		Accent = Color3.fromRGB(225, 179, 0),
		Main = Color3.fromRGB(25, 25, 29),
		Top = Color3.fromRGB(47, 47, 53),
		Address = Color3.fromRGB(45, 45, 51),
		Content = Color3.fromRGB(37, 37, 42),
	},
	Rust = {
		Accent = Color3.fromRGB(224, 88, 28),
		Main = Color3.fromRGB(28, 27, 29),
		Top = Color3.fromRGB(49, 47, 48),
		Address = Color3.fromRGB(47, 44, 45),
		Content = Color3.fromRGB(39, 37, 38),
	},
	Aqua = {
		Accent = Color3.fromRGB(55, 156, 148),
		Main = Color3.fromRGB(24, 28, 29),
		Top = Color3.fromRGB(44, 50, 51),
		Address = Color3.fromRGB(42, 48, 49),
		Content = Color3.fromRGB(35, 40, 41),
	},
	Legacy = {
		Accent = Color3.fromRGB(130, 110, 160),
		Main = Color3.fromRGB(26, 25, 31),
		Top = Color3.fromRGB(48, 45, 55),
		Address = Color3.fromRGB(45, 42, 51),
		Content = Color3.fromRGB(38, 36, 44),
	},
	Dark = {
		Accent = Color3.fromRGB(70, 145, 200),
		Main = Color3.fromRGB(25, 25, 29),
		Top = Color3.fromRGB(47, 47, 53),
		Address = Color3.fromRGB(45, 45, 51),
		Content = Color3.fromRGB(37, 37, 42),
	},
}

GetTheme = function()
	return Themes[Settings.Theme] or Themes.Dark
end

local function AccentRichText(textValue)
	local accent = GetTheme().Accent
	return '<font color="rgb('
		.. math.floor(accent.R * 255) .. ','
		.. math.floor(accent.G * 255) .. ','
		.. math.floor(accent.B * 255)
		.. ')">' .. textValue .. '</font>'
end

local function ApplyTheme(themeName)
	if not Themes[themeName] then
		return
	end

	Settings.Theme = themeName
	local theme = Themes[themeName]

	Main.BackgroundColor3 = theme.Main
	Top.BackgroundColor3 = theme.Top
	Address.BackgroundColor3 = theme.Address
	Content.BackgroundColor3 = theme.Content
	SearchIcon.TextColor3 = theme.Accent

	Status.Text = '<font color="rgb('
		.. math.floor(theme.Accent.R * 255) .. ','
		.. math.floor(theme.Accent.G * 255) .. ','
		.. math.floor(theme.Accent.B * 255)
		.. ')">Status</font><font color="rgb(110,110,118)"> | Tema: '
		.. themeName
		.. '</font>'
end

--------------------------------------------------
-- TELAS
--------------------------------------------------

function ShowPlayerMenu()
	ClearContent()
	AddressText.Text = "Vortex / Player"
	CreateBackButton(ShowMainMenu)
	CreateMenuTitle("Jogador")

	local WalkCard = Instance.new("Frame")
	WalkCard.Size = UDim2.new(1, -32, 0, 58)
	WalkCard.Position = UDim2.new(0, 16, 0, 82)
	WalkCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	WalkCard.BorderSizePixel = 0
	WalkCard.Parent = Content

	local WalkCorner = Instance.new("UICorner")
	WalkCorner.CornerRadius = UDim.new(0, 8)
	WalkCorner.Parent = WalkCard

	local WalkLabel = Instance.new("TextLabel")
	WalkLabel.Size = UDim2.new(1, -230, 1, 0)
	WalkLabel.Position = UDim2.new(0, 16, 0, 0)
	WalkLabel.BackgroundTransparency = 1
	WalkLabel.Text = "Velocidade"
	WalkLabel.TextColor3 = Color3.fromRGB(225, 225, 230)
	WalkLabel.TextSize = 18
	WalkLabel.Font = Enum.Font.Gotham
	WalkLabel.TextXAlignment = Enum.TextXAlignment.Left
	WalkLabel.Parent = WalkCard

	local WalkInput = Instance.new("TextBox")
	WalkInput.Size = UDim2.new(0, 142, 0, 34)
	WalkInput.Position = UDim2.new(1, -205, 0.5, -17)
	WalkInput.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
	WalkInput.BorderSizePixel = 0
	WalkInput.Text = tostring(Settings.WalkSpeedBoost)
	WalkInput.PlaceholderText = "0 - 100"
	WalkInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 128)
	WalkInput.TextColor3 = Color3.fromRGB(220, 220, 225)
	WalkInput.TextSize = 14
	WalkInput.Font = Enum.Font.Gotham
	WalkInput.ClearTextOnFocus = false
	WalkInput.Parent = WalkCard

	local InputStroke = Instance.new("UIStroke")
	InputStroke.Thickness = 1.5
	InputStroke.Color = GetTheme().Accent
	InputStroke.Parent = WalkInput

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 8)
	InputCorner.Parent = WalkInput

	local Pencil = Instance.new("TextLabel")
	Pencil.Size = UDim2.new(0, 40, 1, 0)
	Pencil.Position = UDim2.new(1, -50, 0, 0)
	Pencil.BackgroundTransparency = 1
	Pencil.Text = "✎"
	Pencil.TextColor3 = Color3.fromRGB(190, 190, 198)
	Pencil.TextSize = 22
	Pencil.Font = Enum.Font.Gotham
	Pencil.Parent = WalkCard

	local Hint = Instance.new("TextLabel")
	Hint.Size = UDim2.new(1, -32, 0, 22)
	Hint.Position = UDim2.new(0, 16, 0, 145)
	Hint.BackgroundTransparency = 1
	Hint.Text = "0 = normal  •  1-100 = velocidade do movimento"
	Hint.TextColor3 = Color3.fromRGB(125, 125, 132)
	Hint.TextSize = 12
	Hint.Font = Enum.Font.Gotham
	Hint.TextXAlignment = Enum.TextXAlignment.Left
	Hint.Parent = Content

	local function applyInput()
		local raw = WalkInput.Text:gsub("[^%d]", "")
		local value = tonumber(raw) or 0
		value = setWalkSpeedBoost(value)
		WalkInput.Text = tostring(value)
	end

	WalkInput.FocusLost:Connect(function()
		applyInput()
	end)

	WalkInput:GetPropertyChangedSignal("Text"):Connect(function()
		local clean = WalkInput.Text:gsub("[^%d]", "")

		if clean ~= WalkInput.Text then
			WalkInput.Text = clean
			return
		end

		if clean ~= "" then
			local value = tonumber(clean)
			if value and value > 100 then
				WalkInput.Text = "100"
			end
		end
	end)
end

function ShowVisualMenu()
	ClearContent()
	AddressText.Text = "Vortex / Visuals"
	CreateBackButton(ShowMainMenu)
	CreateMenuTitle("Visual")

	CreateOption(Content, "Ativar ESP", 70, Settings.EnableESP, function(value)
		Settings.EnableESP = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(Content, "Ativar Box", 132, Settings.EnableBoxes, function(value)
		Settings.EnableBoxes = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(Content, "Ativar Nomes", 194, Settings.EnableNames, function(value)
		Settings.EnableNames = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(Content, "Ativar Distancia", 256, Settings.EnableDistance, function(value)
		Settings.EnableDistance = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(Content, "Ativar Traços", 318, Settings.EnableTracers, function(value)
		Settings.EnableTracers = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)
end

function ShowConfigMenu()
	ClearContent()
	AddressText.Text = "https://github.com/PAXTAA6767/VORTEXX/configuracao"
	CreateBackButton(ShowMainMenu)
	CreateMenuTitle("Configuração")

	local theme = GetTheme()

	--------------------------------------------------
	-- TEMAS
	--------------------------------------------------

	local ThemeContainer = Instance.new("Frame")
	ThemeContainer.Size = UDim2.new(1, -32, 0, 116)
	ThemeContainer.Position = UDim2.new(0, 16, 0, 64)
	ThemeContainer.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	ThemeContainer.BorderSizePixel = 0
	ThemeContainer.Parent = Content

	local ThemeContainerCorner = Instance.new("UICorner")
	ThemeContainerCorner.CornerRadius = UDim.new(0, 8)
	ThemeContainerCorner.Parent = ThemeContainer

	local themeNames = {"Serika", "Rust", "Aqua", "Legacy", "Dark"}

	for index, themeName in ipairs(themeNames) do
		local currentTheme = Themes[themeName]
		local x = 10 + (index - 1) * 124

		local Card = Instance.new("TextButton")
		Card.Size = UDim2.new(0, 112, 0, 96)
		Card.Position = UDim2.new(0, x, 0, 8)
		Card.BackgroundColor3 = Color3.fromRGB(29, 29, 33)
		Card.BorderSizePixel = 0
		Card.Text = ""
		Card.AutoButtonColor = false
		Card.Parent = ThemeContainer

		local CardCorner = Instance.new("UICorner")
		CardCorner.CornerRadius = UDim.new(0, 7)
		CardCorner.Parent = Card

		local CardStroke = Instance.new("UIStroke")
		CardStroke.Thickness = 1.4
		CardStroke.Color = Settings.Theme == themeName
			and currentTheme.Accent
			or Color3.fromRGB(105, 105, 112)
		CardStroke.Parent = Card

		local Preview = Instance.new("Frame")
		Preview.Size = UDim2.new(1, -14, 0, 56)
		Preview.Position = UDim2.new(0, 7, 0, 7)
		Preview.BackgroundColor3 = Color3.fromRGB(77, 77, 82)
		Preview.BorderSizePixel = 0
		Preview.Parent = Card

		local PreviewCorner = Instance.new("UICorner")
		PreviewCorner.CornerRadius = UDim.new(0, 5)
		PreviewCorner.Parent = Preview

		local AccentLine = Instance.new("Frame")
		AccentLine.Size = UDim2.new(0, 70, 0, 9)
		AccentLine.Position = UDim2.new(0, 8, 0, 8)
		AccentLine.BackgroundColor3 = currentTheme.Accent
		AccentLine.BorderSizePixel = 0
		AccentLine.Parent = Preview

		local AccentCorner = Instance.new("UICorner")
		AccentCorner.CornerRadius = UDim.new(1, 0)
		AccentCorner.Parent = AccentLine

		local WhiteLine = Instance.new("Frame")
		WhiteLine.Size = UDim2.new(0, 56, 0, 8)
		WhiteLine.Position = UDim2.new(0, 8, 0, 25)
		WhiteLine.BackgroundColor3 = Color3.fromRGB(235, 235, 238)
		WhiteLine.BorderSizePixel = 0
		WhiteLine.Parent = Preview

		local WhiteCorner = Instance.new("UICorner")
		WhiteCorner.CornerRadius = UDim.new(1, 0)
		WhiteCorner.Parent = WhiteLine

		local GrayLine = Instance.new("Frame")
		GrayLine.Size = UDim2.new(0, 46, 0, 8)
		GrayLine.Position = UDim2.new(0, 8, 0, 42)
		GrayLine.BackgroundColor3 = Color3.fromRGB(170, 170, 175)
		GrayLine.BorderSizePixel = 0
		GrayLine.Parent = Preview

		local GrayCorner = Instance.new("UICorner")
		GrayCorner.CornerRadius = UDim.new(1, 0)
		GrayCorner.Parent = GrayLine

		local Name = Instance.new("TextLabel")
		Name.Size = UDim2.new(1, 0, 0, 25)
		Name.Position = UDim2.new(0, 0, 1, -25)
		Name.BackgroundTransparency = 1
		Name.Text = themeName
		Name.TextColor3 = Color3.fromRGB(220, 220, 225)
		Name.TextSize = 13
		Name.Font = Enum.Font.Gotham
		Name.Parent = Card

		Card.Activated:Connect(function()
			ApplyTheme(themeName)
			ShowConfigMenu()
		end)
	end

	--------------------------------------------------
	-- TECLA DE ALTERNÂNCIA
	--------------------------------------------------

	local ToggleCard = Instance.new("Frame")
	ToggleCard.Size = UDim2.new(1, -32, 0, 66)
	ToggleCard.Position = UDim2.new(0, 16, 0, 192)
	ToggleCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	ToggleCard.BorderSizePixel = 0
	ToggleCard.Parent = Content

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 8)
	ToggleCorner.Parent = ToggleCard

	local ToggleTitle = Instance.new("TextLabel")
	ToggleTitle.Size = UDim2.new(0, 330, 0, 28)
	ToggleTitle.Position = UDim2.new(0, 16, 0, 6)
	ToggleTitle.BackgroundTransparency = 1
	ToggleTitle.Text = "Tecla de Alternância"
	ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
	ToggleTitle.TextSize = 17
	ToggleTitle.Font = Enum.Font.Gotham
	ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
	ToggleTitle.Parent = ToggleCard

	local ToggleSub = Instance.new("TextLabel")
	ToggleSub.Size = UDim2.new(0, 390, 0, 22)
	ToggleSub.Position = UDim2.new(0, 16, 0, 34)
	ToggleSub.BackgroundTransparency = 1
	ToggleSub.Text = "Tecla para mostrar ou esconder a interface."
	ToggleSub.TextColor3 = Color3.fromRGB(150, 150, 157)
	ToggleSub.TextSize = 13
	ToggleSub.Font = Enum.Font.Gotham
	ToggleSub.TextXAlignment = Enum.TextXAlignment.Left
	ToggleSub.Parent = ToggleCard

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 124, 0, 32)
	ToggleButton.Position = UDim2.new(1, -140, 0.5, -16)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Text = Settings.ToggleKey.Name
	ToggleButton.TextColor3 = Color3.fromRGB(205, 205, 210)
	ToggleButton.TextSize = 13
	ToggleButton.Font = Enum.Font.Gotham
	ToggleButton.Parent = ToggleCard

	local ToggleButtonCorner = Instance.new("UICorner")
	ToggleButtonCorner.CornerRadius = UDim.new(0, 8)
	ToggleButtonCorner.Parent = ToggleButton

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Thickness = 1.4
	ToggleStroke.Color = theme.Accent
	ToggleStroke.Parent = ToggleButton

	ToggleButton.Activated:Connect(function()
		ToggleButton.Text = "Pressione uma tecla..."

		local connection
		connection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end

			if input.UserInputType == Enum.UserInputType.Keyboard then
				Settings.ToggleKey = input.KeyCode
				ToggleButton.Text = input.KeyCode.Name

				if connection then
					connection:Disconnect()
				end
			end
		end)
	end)

end

function ShowMainMenu()
	ClearContent()
	AddressText.Text = "https://github.com/PAXTAA6767/VORTEXX/home"

	--------------------------------------------------
	-- CARTÃO DE PERFIL
	--------------------------------------------------

	local Profile = Instance.new("Frame")
	Profile.Size = UDim2.new(1, -30, 0, 112)
	Profile.Position = UDim2.new(0, 15, 0, 15)
	Profile.BackgroundColor3 = GetTheme().Top
	Profile.BorderSizePixel = 0
	Profile.Parent = Content

	local ProfileCorner = Instance.new("UICorner")
	ProfileCorner.CornerRadius = UDim.new(0, 9)
	ProfileCorner.Parent = Profile

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 84, 0, 84)
	Avatar.Position = UDim2.new(0, 16, 0.5, -42)
	Avatar.BackgroundColor3 = GetTheme().Content
	Avatar.BorderSizePixel = 0
	Avatar.Image = ""
	Avatar.ScaleType = Enum.ScaleType.Crop
	Avatar.Parent = Profile

	local AvatarCorner = Instance.new("UICorner")
	AvatarCorner.CornerRadius = UDim.new(1, 0)
	AvatarCorner.Parent = Avatar

	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(
				Player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)
		if ok and Avatar.Parent then
			Avatar.Image = image
		end
	end)

	local Welcome = Instance.new("TextLabel")
	Welcome.Size = UDim2.new(0, 500, 0, 42)
	Welcome.Position = UDim2.new(0, 118, 0, 10)
	Welcome.BackgroundTransparency = 1
	Welcome.RichText = true
	do
		local accent = GetTheme().Accent
		Welcome.Text = 'Bem Vindo,  <font color="rgb('
			.. math.floor(accent.R * 255) .. ','
			.. math.floor(accent.G * 255) .. ','
			.. math.floor(accent.B * 255)
			.. ')"><b>' .. Player.DisplayName .. '</b></font>'
	end
	Welcome.TextColor3 = GetTheme().Accent
	Welcome.TextSize = 23
	Welcome.Font = Enum.Font.Gotham
	Welcome.TextXAlignment = Enum.TextXAlignment.Left
	Welcome.Parent = Profile

	local Username = Instance.new("TextLabel")
	Username.Size = UDim2.new(0, 420, 0, 24)
	Username.Position = UDim2.new(0, 118, 0, 39)
	Username.BackgroundTransparency = 1
	Username.Text = "@" .. Player.Name
	Username.TextColor3 = GetTheme().Accent
	Username.TextSize = 18
	Username.Font = Enum.Font.Gotham
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = Profile

	local Clock = Instance.new("TextLabel")
	Clock.Size = UDim2.new(0, 160, 0, 26)
	Clock.Position = UDim2.new(0, 118, 0, 61)
	Clock.BackgroundTransparency = 1
	Clock.Text = os.date("%H:%M")
	Clock.TextColor3 = Color3.fromRGB(125, 125, 132)
	Clock.TextSize = 17
	Clock.Font = Enum.Font.Gotham
	Clock.TextXAlignment = Enum.TextXAlignment.Left
	Clock.Parent = Profile

	local IdButton = Instance.new("TextButton")
	IdButton.Size = UDim2.new(0, 42, 0, 42)
	IdButton.Position = UDim2.new(1, -100, 0.5, -21)
	IdButton.BackgroundTransparency = 1
	IdButton.Text = "▣"
	IdButton.TextColor3 = GetTheme().Accent
	IdButton.TextSize = 27
	IdButton.Font = Enum.Font.Gotham
	IdButton.AutoButtonColor = false
	IdButton.Parent = Profile

	local GearButton = Instance.new("TextButton")
	GearButton.Size = UDim2.new(0, 42, 0, 42)
	GearButton.Position = UDim2.new(1, -54, 0.5, -21)
	GearButton.BackgroundTransparency = 1
	GearButton.Text = "⚙"
	GearButton.TextColor3 = GetTheme().Accent
	GearButton.TextSize = 27
	GearButton.Font = Enum.Font.Gotham
	GearButton.AutoButtonColor = false
	GearButton.Parent = Profile
	GearButton.Activated:Connect(ShowConfigMenu)

	--------------------------------------------------
	-- QUATRO BOTÕES CENTRAIS
	--------------------------------------------------

	local HomeTheme = GetTheme()

	local PlayerButton = CreateHomeSquareButton(-180, "rbxassetid://6034287594", "Jogador", ShowPlayerMenu, false)
	local VisualButton = CreateHomeSquareButton(-88, "rbxassetid://6031075938", "Visual", ShowVisualMenu, false)
	local ConfigButton = CreateHomeSquareButton(4, "rbxassetid://6031280882", "Configuração", ShowConfigMenu, false)
	local ProfileButton = CreateHomeSquareButton(96, "", "Perfil", function()
		Status.Text = '<font color="rgb(70,145,200)">Status</font><font color="rgb(110,110,118)"> | Perfil</font>'
	end, true)

	for _, button in ipairs({PlayerButton, VisualButton, ConfigButton, ProfileButton}) do
		if button then
			button.BackgroundColor3 = HomeTheme.Top

			local icon = button:FindFirstChildOfClass("ImageLabel")
			if icon and button ~= ProfileButton then
				icon.ImageColor3 = HomeTheme.Accent
			end
		end
	end
end

ApplyTheme(Settings.Theme)

--------------------------------------------------
-- ABRIR/FECHAR COM TECLA CONFIGURÁVEL
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Settings.ToggleKey then
		Main.Visible = not Main.Visible

		if Main.Visible then
			ShowMainMenu()
			Status.Text = '<font color="rgb(70,145,200)">Status</font><font color="rgb(110,110,118)"> | Idle</font>'
		end
	end
end)


--------------------------------------------------
-- VORTEX ESP - PARA O SEU PRÓPRIO JOGO
--------------------------------------------------

local ESP = {}

local function destroyESP(plr)
	local data = ESP[plr]
	if not data then return end

	if data.Highlight then data.Highlight:Destroy() end
	if data.Billboard then data.Billboard:Destroy() end
	if data.Tracer then data.Tracer:Destroy() end
	if data.TracerAttachment then data.TracerAttachment:Destroy() end

	if data.Humanoid and data.OriginalDisplayDistanceType then
		pcall(function()
			data.Humanoid.DisplayDistanceType = data.OriginalDisplayDistanceType
		end)
	end

	ESP[plr] = nil
end

local function getRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function darkTeamColor(color)
	-- Mantém a mesma tonalidade da equipe, mas sem aparência luminosa.
	return Color3.new(
		math.clamp(color.R * 0.58, 0, 1),
		math.clamp(color.G * 0.58, 0, 1),
		math.clamp(color.B * 0.58, 0, 1)
	)
end

local function destroyTracer(data)
	if not data then return end

	if data.Tracer then
		data.Tracer:Destroy()
		data.Tracer = nil
	end

	if data.TracerAttachment then
		data.TracerAttachment:Destroy()
		data.TracerAttachment = nil
	end
end

local function removeLocalTracerOrigin()
	local localRoot = getRoot(Player.Character)
	if not localRoot then return end

	local origin = localRoot:FindFirstChild("VortexTracerOrigin")
	if origin then
		origin:Destroy()
	end
end

-- Identifica o papel pela equipe.
-- Prisioneiro = laranja | Polícia = azul | Ladrão = vermelho
local function getRoleAndColor(plr)
	local team = plr.Team
	local teamName = team and string.lower(team.Name or "") or ""

	--------------------------------------------------
	-- 1) NOME DA EQUIPE
	--------------------------------------------------

	-- PRISIONEIRO = LARANJA
	if string.find(teamName, "prisioneiro", 1, true)
		or string.find(teamName, "prisoner", 1, true)
		or string.find(teamName, "prison", 1, true)
		or string.find(teamName, "prision", 1, true)
		or string.find(teamName, "preso", 1, true) then
		return "Prisioneiro", Color3.fromRGB(255, 170, 0)
	end

	-- POLÍCIA = AZUL
	if string.find(teamName, "policia", 1, true)
		or string.find(teamName, "police", 1, true)
		or string.find(teamName, "polícia", 1, true)
		or string.find(teamName, "cop", 1, true)
		or string.find(teamName, "sheriff", 1, true)
		or string.find(teamName, "officer", 1, true)
		or string.find(teamName, "guarda", 1, true) then
		return "Polícia", Color3.fromRGB(70, 145, 255)
	end

	-- LADRÃO = VERMELHO
	if string.find(teamName, "ladrao", 1, true)
		or string.find(teamName, "ladrão", 1, true)
		or string.find(teamName, "criminal", 1, true)
		or string.find(teamName, "criminoso", 1, true)
		or string.find(teamName, "thief", 1, true)
		or string.find(teamName, "robber", 1, true)
		or string.find(teamName, "bandido", 1, true)
		or string.find(teamName, "gangster", 1, true) then
		return "Ladrão", Color3.fromRGB(255, 70, 70)
	end

	--------------------------------------------------
	-- 2) COR REAL DA TEAM / PLAYER
	--------------------------------------------------

	local brickColor = (team and team.TeamColor) or plr.TeamColor

	if brickColor then
		local colorName = string.lower(brickColor.Name or "")
		local color = brickColor.Color
		local h, sat, val = Color3.toHSV(color)

		-- Laranja: cobre Orange / Bright orange / Deep orange etc.
		if string.find(colorName, "orange", 1, true)
			or (h >= 0.045 and h <= 0.13 and sat >= 0.55 and val >= 0.5) then
			return "Prisioneiro", Color3.fromRGB(255, 170, 0)
		end

		-- Azul
		if string.find(colorName, "blue", 1, true)
			or (h >= 0.50 and h <= 0.75 and sat >= 0.45 and val >= 0.4) then
			return "Polícia", Color3.fromRGB(70, 145, 255)
		end

		-- Vermelho
		if string.find(colorName, "red", 1, true)
			or h >= 0.96 or h <= 0.035 then
			return "Ladrão", Color3.fromRGB(255, 70, 70)
		end
	end

	-- Sem equipe reconhecida: não mostra ESP branco/OUTRO.
	return nil, nil
end
local function getTeamColor(plr)
	local _, color = getRoleAndColor(plr)
	return color
end

local function updateESP(plr)
	local existingData = ESP[plr]
	if existingData and not Settings.EnableNames and not Settings.EnableDistance then
		if existingData.Billboard then
			existingData.Billboard:Destroy()
			existingData.Billboard = nil
			existingData.Label = nil
		end
	end

	if plr == Player then
		destroyESP(plr)
		return
	end

	if not Settings.EnableESP then
		destroyESP(plr)
		return
	end

	local character = plr.Character
	local root = getRoot(character)

	if not character or not root then
		destroyESP(plr)
		return
	end

	local role, teamColor = getRoleAndColor(plr)

	-- Só exibe jogadores identificados como Polícia, Ladrão ou Prisioneiro.
	if not role or not teamColor then
		destroyESP(plr)
		return
	end

	local data = ESP[plr]

	if not data or data.Character ~= character then
		destroyESP(plr)
		data = {Character = character}
		ESP[plr] = data

		-- Oculta o nome padrão do Roblox para que Enable Names controle
		-- sozinho se o nome aparece ou não.
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			data.Humanoid = humanoid
			data.OriginalDisplayDistanceType = humanoid.DisplayDistanceType
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end

	if data.Humanoid then
		data.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	-- Caixa/contorno
	if Settings.EnableBoxes then
		if not data.Highlight then
			local highlight = Instance.new("Highlight")
			highlight.Name = "VortexESP"
			highlight.Adornee = character
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillTransparency = 0.82
			highlight.OutlineTransparency = 0
			local teamColor = getTeamColor(plr)
			highlight.FillColor = teamColor
			highlight.OutlineColor = teamColor:Lerp(Color3.new(1, 1, 1), 0.35)
			highlight.Parent = character
			data.Highlight = highlight
		end
	elseif data.Highlight then
		data.Highlight:Destroy()
		data.Highlight = nil
	end

	-- Cor da equipe sempre atualizada.
	role, teamColor = getRoleAndColor(plr)

	if data.Highlight then
		data.Highlight.FillColor = teamColor
		data.Highlight.OutlineColor = teamColor:Lerp(Color3.new(1, 1, 1), 0.35)
	end

	-- Nome e distância
	if Settings.EnableNames or Settings.EnableDistance then
		if not data.Billboard then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "VortexInfo"
			billboard.Adornee = root
			billboard.Size = UDim2.fromOffset(220, 40)
			billboard.StudsOffset = Vector3.new(0, 3.7, 0)
			billboard.AlwaysOnTop = true
			billboard.Parent = root
			data.Billboard = billboard

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.TextColor3 = getTeamColor(plr)
			label.TextStrokeTransparency = 0
			label.TextSize = 12
			label.Font = Enum.Font.GothamBold
			label.Parent = billboard
			data.Label = label
		end

		local parts = {}

		if Settings.EnableNames then
			table.insert(parts, plr.Name)
		end

		if Settings.EnableDistance then
			local localCharacter = Player.Character
			local localRoot = getRoot(localCharacter)
			if localRoot then
				local distance = (localRoot.Position - root.Position).Magnitude
				table.insert(parts, string.format("[%dm]", math.floor(distance + 0.5)))
			end
		end

		data.Label.Text = table.concat(parts, " ")
		data.Label.TextColor3 = teamColor
	elseif data.Billboard then
		data.Billboard:Destroy()
		data.Billboard = nil
		data.Label = nil
	end

	-- Tracer: mesma cor da equipe, porém mais escura e sem emissão.
	local tracerColor = darkTeamColor(teamColor)

	if Settings.EnableTracers then
		local localRoot = getRoot(Player.Character)

		-- Se o jogador local morreu/respawnou, o Beam antigo fica preso no root antigo.
		-- Nesse caso, removemos e recriamos automaticamente.
		if data.Tracer and (
			not data.Tracer.Parent
				or not data.Tracer.Attachment0
				or data.Tracer.Attachment0.Parent ~= localRoot
				or not data.Tracer.Attachment1
				or data.Tracer.Attachment1.Parent ~= root
			) then
			destroyTracer(data)
		end

		if localRoot then
			local fromAttachment = localRoot:FindFirstChild("VortexTracerOrigin")

			if not fromAttachment then
				fromAttachment = Instance.new("Attachment")
				fromAttachment.Name = "VortexTracerOrigin"
				fromAttachment.Parent = localRoot
			end

			if not data.Tracer then
				local attachment = Instance.new("Attachment")
				attachment.Name = "VortexTracerAttachment"
				attachment.Parent = root

				local beam = Instance.new("Beam")
				beam.Name = "VortexTracer"
				beam.Attachment0 = fromAttachment
				beam.Attachment1 = attachment
				beam.FaceCamera = true
				beam.Width0 = 0.085
				beam.Width1 = 0.085
				beam.Color = ColorSequence.new(tracerColor)
				beam.Transparency = NumberSequence.new(0)
				beam.LightEmission = 0
				beam.LightInfluence = 1
				beam.Parent = localRoot

				data.Tracer = beam
				data.TracerAttachment = attachment
			else
				data.Tracer.Color = ColorSequence.new(tracerColor)
				data.Tracer.Transparency = NumberSequence.new(0)
				data.Tracer.LightEmission = 0
				data.Tracer.LightInfluence = 1
			end
		else
			destroyTracer(data)
		end
	else
		destroyTracer(data)
	end
end

refreshAllESP = function()
	for _, plr in ipairs(Players:GetPlayers()) do
		updateESP(plr)
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 5)
		task.wait(0.15)
		destroyESP(plr)
		updateESP(plr)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	destroyESP(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= Player then
		plr.CharacterAdded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart", 5)
			task.wait(0.15)
			destroyESP(plr)
			updateESP(plr)
		end)
	end
end

-- Quando o jogador local respawna, recria as linhas usando o novo personagem.
Player.CharacterAdded:Connect(function(character)
	character:WaitForChild("HumanoidRootPart", 5)
	task.wait(0.2)

	for _, plr in ipairs(Players:GetPlayers()) do
		destroyTracer(ESP[plr])
	end

	removeLocalTracerOrigin()
	refreshAllESP()
end)

-- Reaplica configurações do ESP, cores de equipe, distância e novos personagens.
task.spawn(function()
	while task.wait(0.25) do
		refreshAllESP()
	end
end)

refreshAllESP()

--------------------------------------------------
-- ARRASTAR PAINEL
--------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end

		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

		local Delta = input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)
