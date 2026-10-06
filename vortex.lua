local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local OldVortexGui = PlayerGui:FindFirstChild("VortexPanel")
if OldVortexGui then
	OldVortexGui:Destroy()
end

--------------------------------------------------
-- CONFIGURAÇÕES
--------------------------------------------------

local Settings = {
	-- Jogador
	WalkSpeedBoost = 0,
	NoWait = false,
	FollowPlayer = false,
	Aimbot = false,
	AimbotDistance = 100,
	GuidedAim = false,
	GuidedAimDistance = 100,

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
local getRoleAndColor


--------------------------------------------------
-- WALK SPEED - JOGADOR
-- 0 = NORMAL | 1-200 = ACRÉSCIMO SOBRE A VELOCIDADE BASE
--------------------------------------------------
-- SEGUIR PLAYER - JOGADOR
--------------------------------------------------

local FollowTarget = nil

local function setFollowTarget(targetPlayer)
	if targetPlayer == Player then
		return
	end
	FollowTarget = targetPlayer
	Settings.FollowPlayer = targetPlayer ~= nil
end

local function stopFollowing()
	FollowTarget = nil
	Settings.FollowPlayer = false
end

RunService.Heartbeat:Connect(function()
	local target = FollowTarget
	if not Settings.FollowPlayer or not target or target.Parent ~= Players then
		return
	end

	local character = Player.Character
	local targetCharacter = target.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

	if not humanoid or not root or not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
		return
	end

	-- Segue como TP, ficando bem perto e atrás do jogador selecionado.
	-- Offset local: 3 studs atrás do alvo.
	local followOffset = CFrame.new(0, 0, 3)
	local desiredCFrame = targetRoot.CFrame * followOffset

	-- Move o personagem inteiro para acompanhar imediatamente o alvo.
	character:PivotTo(desiredCFrame)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if FollowTarget == leavingPlayer then
		stopFollowing()
	end
end)

--------------------------------------------------
-- NO WAIT - PROXIMITY PROMPTS
--------------------------------------------------

local OriginalPromptDurations = {}

local function applyNoWaitToPrompt(prompt)
	if not prompt:IsA("ProximityPrompt") then
		return
	end

	if OriginalPromptDurations[prompt] == nil then
		OriginalPromptDurations[prompt] = prompt.HoldDuration
	end

	if Settings.NoWait then
		prompt.HoldDuration = 0
	else
		prompt.HoldDuration = OriginalPromptDurations[prompt]
	end
end

local function refreshNoWait()
	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("ProximityPrompt") then
			applyNoWaitToPrompt(object)
		end
	end
end

workspace.DescendantAdded:Connect(function(object)
	if object:IsA("ProximityPrompt") then
		task.defer(function()
			if object.Parent then
				applyNoWaitToPrompt(object)
			end
		end)
	end
end)

workspace.DescendantRemoving:Connect(function(object)
	if object:IsA("ProximityPrompt") then
		OriginalPromptDurations[object] = nil
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
Main.Size = UDim2.new(0, 620, 0, 400)
Main.Position = UDim2.new(0.5, -310, 0.5, -200)
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
Moon.Text = "👾"
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

local ClosingMenu = false

Close.MouseButton1Click:Connect(function()
	if ClosingMenu then
		return
	end

	ClosingMenu = true
	Main.Visible = false

	task.delay(0.15, function()
		ClosingMenu = false
	end)
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

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Size = UDim2.new(0, 20, 0, 20)
SearchIcon.Position = UDim2.new(0, 12, 0.5, -10)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://6031154871"
SearchIcon.ImageColor3 = Color3.fromRGB(71, 142, 190)
SearchIcon.ScaleType = Enum.ScaleType.Fit
SearchIcon.Parent = Address

local AddressText = Instance.new("TextLabel")
AddressText.Size = UDim2.new(1, -48, 1, 0)
AddressText.Position = UDim2.new(0, 42, 0, 0)
AddressText.BackgroundTransparency = 1
AddressText.Text = "https://github.com/vtx/vortex/home"
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

-- Degradê especial usado apenas pelo tema Galaxia
local GalaxyGradient = Instance.new("UIGradient")
GalaxyGradient.Name = "GalaxyGradient"
GalaxyGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 8, 85)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(125, 25, 210)),
	ColorSequenceKeypoint.new(0.52, Color3.fromRGB(220, 45, 190)),
	ColorSequenceKeypoint.new(0.76, Color3.fromRGB(55, 75, 235)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
})
GalaxyGradient.Rotation = 18
GalaxyGradient.Enabled = false
GalaxyGradient.Parent = Content

local GalaxyMainGradient = GalaxyGradient:Clone()
GalaxyMainGradient.Name = "GalaxyMainGradient"
GalaxyMainGradient.Rotation = 25
GalaxyMainGradient.Parent = Main

local GalaxyTopGradient = GalaxyGradient:Clone()
GalaxyTopGradient.Name = "GalaxyTopGradient"
GalaxyTopGradient.Rotation = 0
GalaxyTopGradient.Parent = Top

local GalaxyAddressGradient = GalaxyGradient:Clone()
GalaxyAddressGradient.Name = "GalaxyAddressGradient"
GalaxyAddressGradient.Rotation = 0
GalaxyAddressGradient.Parent = Address

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

-- Crédito no canto inferior direito
local Credit = Instance.new("TextLabel")
Credit.Name = "Credit"
Credit.Size = UDim2.new(0, 180, 0, 18)
Credit.Position = UDim2.new(1, -190, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "Feito Por Vitexx"
Credit.TextColor3 = Color3.fromRGB(105, 85, 255) -- atualizado pelo ApplyTheme
Credit.TextSize = 12
Credit.Font = Enum.Font.Gotham
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.Parent = Main

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
	Button.Size = UDim2.new(0, 68, 0, 68)
	Button.Position = UDim2.new(0.5, x, 0, 184)
	Button.BackgroundColor3 = GetTheme().Top
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	if useAvatar then
		local Avatar = Instance.new("ImageLabel")
		Avatar.Size = UDim2.new(0, 40, 0, 40)
		Avatar.Position = UDim2.new(0.5, -20, 0.5, -20)
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
		Icon.Size = UDim2.new(0, 28, 0, 28)
		Icon.Position = UDim2.new(0.5, -14, 0.5, -14)
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

		local theme = GetTheme()
		Button.BackgroundColor3 = theme.Accent:Lerp(theme.Top, 0.65)
	end)

	Button.MouseLeave:Connect(function()
		Tip.Visible = false
		Button.BackgroundColor3 = GetTheme().Top
	end)

	Button.Activated:Connect(callback)

	return Button
end


--------------------------------------------------
-- TEMAS DA INTERFACE
--------------------------------------------------

local Themes = {
	Dark = {
		Accent = Color3.fromRGB(105, 85, 255),
		Main = Color3.fromRGB(10, 10, 14),
		Top = Color3.fromRGB(22, 22, 29),
		Address = Color3.fromRGB(27, 27, 36),
		Content = Color3.fromRGB(16, 16, 22),
	},
	AzulInsano = {
		Accent = Color3.fromRGB(0, 170, 255),
		Main = Color3.fromRGB(5, 12, 24),
		Top = Color3.fromRGB(8, 28, 52),
		Address = Color3.fromRGB(10, 38, 70),
		Content = Color3.fromRGB(6, 20, 38),
	},
	Inferno = {
		Accent = Color3.fromRGB(255, 35, 35),
		Main = Color3.fromRGB(22, 7, 7),
		Top = Color3.fromRGB(48, 12, 12),
		Address = Color3.fromRGB(68, 16, 16),
		Content = Color3.fromRGB(32, 9, 9),
	},
	Galaxia = {
		Accent = Color3.fromRGB(170, 90, 255),
		Main = Color3.fromRGB(16, 10, 30),
		Top = Color3.fromRGB(34, 20, 58),
		Address = Color3.fromRGB(45, 26, 72),
		Content = Color3.fromRGB(23, 14, 40),
	},
	Cyberpunk = {
		Accent = Color3.fromRGB(255, 40, 170),
		Main = Color3.fromRGB(16, 16, 20),
		Top = Color3.fromRGB(32, 24, 40),
		Address = Color3.fromRGB(28, 44, 46),
		Content = Color3.fromRGB(20, 18, 27),
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
	SearchIcon.ImageColor3 = theme.Accent
	Credit.TextColor3 = theme.Accent

	-- O tema Galaxia usa um degradê real no fundo da área principal.
	local galaxyEnabled = themeName == "Galaxia"
	GalaxyGradient.Enabled = galaxyEnabled
	GalaxyMainGradient.Enabled = galaxyEnabled
	GalaxyTopGradient.Enabled = galaxyEnabled
	GalaxyAddressGradient.Enabled = galaxyEnabled

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

	-- Área rolável da aba Jogador.
	local PlayerScroll = Instance.new("ScrollingFrame")
	PlayerScroll.Name = "PlayerScroll"
	PlayerScroll.Size = UDim2.new(1, -12, 1, -64)
	PlayerScroll.Position = UDim2.new(0, 6, 0, 64)
	PlayerScroll.BackgroundTransparency = 1
	PlayerScroll.BorderSizePixel = 0
	PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 390)
	PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	PlayerScroll.ScrollBarThickness = 4
	PlayerScroll.ScrollBarImageColor3 = GetTheme().Accent
	PlayerScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	PlayerScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	PlayerScroll.Parent = Content

	local WalkCard = Instance.new("Frame")
	WalkCard.Size = UDim2.new(1, -32, 0, 58)
	WalkCard.Position = UDim2.new(0, 16, 0, 18)
	WalkCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	WalkCard.BorderSizePixel = 0
	WalkCard.Parent = PlayerScroll

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
	WalkInput.PlaceholderText = "0 - 200"
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
	Pencil.Text = "👟"
	Pencil.TextColor3 = Color3.fromRGB(190, 190, 198)
	Pencil.TextSize = 22
	Pencil.Font = Enum.Font.Gotham
	Pencil.Parent = WalkCard

	local Hint = Instance.new("TextLabel")
	Hint.Size = UDim2.new(1, -32, 0, 22)
	Hint.Position = UDim2.new(0, 16, 0, 81)
	Hint.BackgroundTransparency = 1
	Hint.Text = "0 = normal  •  1-200 = aumento sobre a velocidade base"
	Hint.TextColor3 = Color3.fromRGB(125, 125, 132)
	Hint.TextSize = 12
	Hint.Font = Enum.Font.Gotham
	Hint.TextXAlignment = Enum.TextXAlignment.Left
	Hint.Parent = PlayerScroll

	CreateOption(PlayerScroll, "No Wait", 118, Settings.NoWait, function(value)
		Settings.NoWait = value
		refreshNoWait()
	end)

	-- SEGUIR PLAYER: lista os jogadores que estão no servidor.
	local FollowCard = Instance.new("Frame")
	FollowCard.Name = "FollowPlayerCard"
	FollowCard.Size = UDim2.new(1, -32, 0, 76)
	FollowCard.Position = UDim2.new(0, 16, 0, 212)
	FollowCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	FollowCard.BorderSizePixel = 0
	FollowCard.Parent = PlayerScroll

	local FollowCorner = Instance.new("UICorner")
	FollowCorner.CornerRadius = UDim.new(0, 7)
	FollowCorner.Parent = FollowCard

	local FollowLabel = Instance.new("TextLabel")
	FollowLabel.Size = UDim2.new(0, 155, 1, 0)
	FollowLabel.Position = UDim2.new(0, 16, 0, 0)
	FollowLabel.BackgroundTransparency = 1
	FollowLabel.Text = "Seguir Player"
	FollowLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
	FollowLabel.TextSize = 17
	FollowLabel.Font = Enum.Font.Gotham
	FollowLabel.TextXAlignment = Enum.TextXAlignment.Left
	FollowLabel.Parent = FollowCard

	local PlayerSelect = Instance.new("TextButton")
	PlayerSelect.Size = UDim2.new(0, 245, 0, 36)
	PlayerSelect.Position = UDim2.new(1, -261, 0.5, -18)
	PlayerSelect.BackgroundColor3 = Color3.fromRGB(39, 39, 44)
	PlayerSelect.BorderSizePixel = 0
	PlayerSelect.Text = "Selecionar jogador"
	PlayerSelect.TextColor3 = Color3.fromRGB(220, 220, 225)
	PlayerSelect.TextSize = 13
	PlayerSelect.Font = Enum.Font.Gotham
	PlayerSelect.AutoButtonColor = false
	PlayerSelect.Parent = FollowCard

	local PlayerSelectCorner = Instance.new("UICorner")
	PlayerSelectCorner.CornerRadius = UDim.new(0, 7)
	PlayerSelectCorner.Parent = PlayerSelect

	local FollowList = Instance.new("ScrollingFrame")
	FollowList.Name = "FollowPlayerList"
	FollowList.Size = UDim2.new(0, 245, 0, 150)
	FollowList.Position = UDim2.new(1, -261, 1, 4)
	FollowList.BackgroundColor3 = Color3.fromRGB(31, 31, 36)
	FollowList.BorderSizePixel = 0
	FollowList.ScrollBarThickness = 3
	FollowList.ScrollBarImageColor3 = GetTheme().Accent
	FollowList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	FollowList.CanvasSize = UDim2.new()
	FollowList.Visible = false
	FollowList.ZIndex = 20
	FollowList.Parent = FollowCard

	local FollowListCorner = Instance.new("UICorner")
	FollowListCorner.CornerRadius = UDim.new(0, 7)
	FollowListCorner.Parent = FollowList

	local FollowLayout = Instance.new("UIListLayout")
	FollowLayout.Padding = UDim.new(0, 3)
	FollowLayout.Parent = FollowList

	local function refreshFollowPlayers()
		for _, child in ipairs(FollowList:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			if targetPlayer ~= Player then
				local Entry = Instance.new("TextButton")
				Entry.Size = UDim2.new(1, -6, 0, 34)
				Entry.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
				Entry.BorderSizePixel = 0
				Entry.Text = targetPlayer.DisplayName .. "  (@" .. targetPlayer.Name .. ")"
				Entry.TextColor3 = Color3.fromRGB(220, 220, 225)
				Entry.TextSize = 12
				Entry.Font = Enum.Font.Gotham
				Entry.ZIndex = 21
				Entry.Parent = FollowList

				local EntryCorner = Instance.new("UICorner")
				EntryCorner.CornerRadius = UDim.new(0, 5)
				EntryCorner.Parent = Entry

				Entry.Activated:Connect(function()
					setFollowTarget(targetPlayer)
					PlayerSelect.Text = "Seguindo: " .. targetPlayer.DisplayName
					FollowList.Visible = false
				end)
			end
		end

		local Stop = Instance.new("TextButton")
		Stop.Size = UDim2.new(1, -6, 0, 34)
		Stop.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
		Stop.BorderSizePixel = 0
		Stop.Text = "Parar de seguir"
		Stop.TextColor3 = Color3.fromRGB(220, 220, 225)
		Stop.TextSize = 12
		Stop.Font = Enum.Font.Gotham
		Stop.ZIndex = 21
		Stop.Parent = FollowList

		local StopCorner = Instance.new("UICorner")
		StopCorner.CornerRadius = UDim.new(0, 5)
		StopCorner.Parent = Stop

		Stop.Activated:Connect(function()
			stopFollowing()
			PlayerSelect.Text = "Selecionar jogador"
			FollowList.Visible = false
		end)
	end

	PlayerSelect.Activated:Connect(function()
		refreshFollowPlayers()
		FollowList.Visible = not FollowList.Visible
	end)

	local NoWaitHint = Instance.new("TextLabel")
	NoWaitHint.Size = UDim2.new(1, -32, 0, 22)
	NoWaitHint.Position = UDim2.new(0, 16, 0, 176)
	NoWaitHint.BackgroundTransparency = 1
	NoWaitHint.Text = "Remove o tempo de espera ao interagir com objetos."
	NoWaitHint.TextColor3 = Color3.fromRGB(125, 125, 132)
	NoWaitHint.TextSize = 12
	NoWaitHint.Font = Enum.Font.Gotham
	NoWaitHint.TextXAlignment = Enum.TextXAlignment.Left
	NoWaitHint.Parent = PlayerScroll

	CreateOption(PlayerScroll, "Aimbot", 324, Settings.Aimbot, function(value)
		Settings.Aimbot = value
	end)

	local AimbotHint = Instance.new("TextLabel")
	AimbotHint.Size = UDim2.new(1, -32, 0, 22)
	AimbotHint.Position = UDim2.new(0, 16, 0, 382)
	AimbotHint.BackgroundTransparency = 1
	AimbotHint.Text = "Mira na cabeça do inimigo mais próximo."
	AimbotHint.TextColor3 = Color3.fromRGB(125, 125, 132)
	AimbotHint.TextSize = 12
	AimbotHint.Font = Enum.Font.Gotham
	AimbotHint.TextXAlignment = Enum.TextXAlignment.Left
	AimbotHint.Parent = PlayerScroll

	local DistanceCard = Instance.new("Frame")
	DistanceCard.Size = UDim2.new(1, -32, 0, 58)
	DistanceCard.Position = UDim2.new(0, 16, 0, 418)
	DistanceCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	DistanceCard.BorderSizePixel = 0
	DistanceCard.Parent = PlayerScroll

	local DistanceCorner = Instance.new("UICorner")
	DistanceCorner.CornerRadius = UDim.new(0, 8)
	DistanceCorner.Parent = DistanceCard

	local DistanceLabel = Instance.new("TextLabel")
	DistanceLabel.Size = UDim2.new(1, -230, 1, 0)
	DistanceLabel.Position = UDim2.new(0, 16, 0, 0)
	DistanceLabel.BackgroundTransparency = 1
	DistanceLabel.Text = "Distância do Aimbot"
	DistanceLabel.TextColor3 = Color3.fromRGB(225, 225, 230)
	DistanceLabel.TextSize = 17
	DistanceLabel.Font = Enum.Font.Gotham
	DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	DistanceLabel.Parent = DistanceCard

	local DistanceInput = Instance.new("TextBox")
	DistanceInput.Size = UDim2.new(0, 142, 0, 34)
	DistanceInput.Position = UDim2.new(1, -158, 0.5, -17)
	DistanceInput.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
	DistanceInput.BorderSizePixel = 0
	DistanceInput.Text = tostring(Settings.AimbotDistance)
	DistanceInput.PlaceholderText = "1 - 200 m"
	DistanceInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 128)
	DistanceInput.TextColor3 = Color3.fromRGB(220, 220, 225)
	DistanceInput.TextSize = 14
	DistanceInput.Font = Enum.Font.Gotham
	DistanceInput.ClearTextOnFocus = false
	DistanceInput.Parent = DistanceCard

	local DistanceStroke = Instance.new("UIStroke")
	DistanceStroke.Thickness = 1.5
	DistanceStroke.Color = GetTheme().Accent
	DistanceStroke.Parent = DistanceInput

	local DistanceInputCorner = Instance.new("UICorner")
	DistanceInputCorner.CornerRadius = UDim.new(0, 8)
	DistanceInputCorner.Parent = DistanceInput

	local DistanceHint = Instance.new("TextLabel")
	DistanceHint.Size = UDim2.new(1, -32, 0, 22)
	DistanceHint.Position = UDim2.new(0, 16, 0, 481)
	DistanceHint.BackgroundTransparency = 1
	DistanceHint.Text = "Escolha de 1 a 200 metros."
	DistanceHint.TextColor3 = Color3.fromRGB(125, 125, 132)
	DistanceHint.TextSize = 12
	DistanceHint.Font = Enum.Font.Gotham
	DistanceHint.TextXAlignment = Enum.TextXAlignment.Left
	DistanceHint.Parent = PlayerScroll


	-- MIRA TELEGUIDADA - opção separada do Aimbot
	CreateOption(PlayerScroll, "Mira Teleguiada", 518, Settings.GuidedAim, function(value)
		Settings.GuidedAim = value
	end)

	local GuidedHint = Instance.new("TextLabel")
	GuidedHint.Size = UDim2.new(1, -32, 0, 22)
	GuidedHint.Position = UDim2.new(0, 16, 0, 576)
	GuidedHint.BackgroundTransparency = 1
	GuidedHint.Text = "Trava a mira em um inimigo e acompanha seus movimentos."
	GuidedHint.TextColor3 = Color3.fromRGB(125, 125, 132)
	GuidedHint.TextSize = 12
	GuidedHint.Font = Enum.Font.Gotham
	GuidedHint.TextXAlignment = Enum.TextXAlignment.Left
	GuidedHint.Parent = PlayerScroll

	local GuidedDistanceCard = Instance.new("Frame")
	GuidedDistanceCard.Size = UDim2.new(1, -32, 0, 58)
	GuidedDistanceCard.Position = UDim2.new(0, 16, 0, 612)
	GuidedDistanceCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	GuidedDistanceCard.BorderSizePixel = 0
	GuidedDistanceCard.Parent = PlayerScroll

	local GuidedDistanceCorner = Instance.new("UICorner")
	GuidedDistanceCorner.CornerRadius = UDim.new(0, 8)
	GuidedDistanceCorner.Parent = GuidedDistanceCard

	local GuidedDistanceLabel = Instance.new("TextLabel")
	GuidedDistanceLabel.Size = UDim2.new(1, -230, 1, 0)
	GuidedDistanceLabel.Position = UDim2.new(0, 16, 0, 0)
	GuidedDistanceLabel.BackgroundTransparency = 1
	GuidedDistanceLabel.Text = "Distância Mira Teleguiada"
	GuidedDistanceLabel.TextColor3 = Color3.fromRGB(225, 225, 230)
	GuidedDistanceLabel.TextSize = 17
	GuidedDistanceLabel.Font = Enum.Font.Gotham
	GuidedDistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	GuidedDistanceLabel.Parent = GuidedDistanceCard

	local GuidedDistanceInput = Instance.new("TextBox")
	GuidedDistanceInput.Size = UDim2.new(0, 142, 0, 34)
	GuidedDistanceInput.Position = UDim2.new(1, -158, 0.5, -17)
	GuidedDistanceInput.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
	GuidedDistanceInput.BorderSizePixel = 0
	GuidedDistanceInput.Text = tostring(Settings.GuidedAimDistance)
	GuidedDistanceInput.PlaceholderText = "1 - 500 m"
	GuidedDistanceInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 128)
	GuidedDistanceInput.TextColor3 = Color3.fromRGB(220, 220, 225)
	GuidedDistanceInput.TextSize = 14
	GuidedDistanceInput.Font = Enum.Font.Gotham
	GuidedDistanceInput.ClearTextOnFocus = false
	GuidedDistanceInput.Parent = GuidedDistanceCard

	local GuidedDistanceStroke = Instance.new("UIStroke")
	GuidedDistanceStroke.Thickness = 1.5
	GuidedDistanceStroke.Color = GetTheme().Accent
	GuidedDistanceStroke.Parent = GuidedDistanceInput

	local GuidedDistanceInputCorner = Instance.new("UICorner")
	GuidedDistanceInputCorner.CornerRadius = UDim.new(0, 8)
	GuidedDistanceInputCorner.Parent = GuidedDistanceInput

	local GuidedDistanceHint = Instance.new("TextLabel")
	GuidedDistanceHint.Size = UDim2.new(1, -32, 0, 22)
	GuidedDistanceHint.Position = UDim2.new(0, 16, 0, 675)
	GuidedDistanceHint.BackgroundTransparency = 1
	GuidedDistanceHint.Text = "Alcance independente: escolha de 1 a 500 metros."
	GuidedDistanceHint.TextColor3 = Color3.fromRGB(125, 125, 132)
	GuidedDistanceHint.TextSize = 12
	GuidedDistanceHint.Font = Enum.Font.Gotham
	GuidedDistanceHint.TextXAlignment = Enum.TextXAlignment.Left
	GuidedDistanceHint.Parent = PlayerScroll

	local function applyGuidedAimDistance()
		local raw = GuidedDistanceInput.Text:gsub("[^%d]", "")
		local value = tonumber(raw) or Settings.GuidedAimDistance
		value = math.clamp(math.floor(value + 0.5), 1, 500)
		Settings.GuidedAimDistance = value
		GuidedDistanceInput.Text = tostring(value)
	end

	GuidedDistanceInput.FocusLost:Connect(applyGuidedAimDistance)

	GuidedDistanceInput:GetPropertyChangedSignal("Text"):Connect(function()
		local clean = GuidedDistanceInput.Text:gsub("[^%d]", "")
		if clean ~= GuidedDistanceInput.Text then
			GuidedDistanceInput.Text = clean
			return
		end

		if clean ~= "" then
			local value = tonumber(clean)
			if value and value > 500 then
				GuidedDistanceInput.Text = "500"
			end
		end
	end)

	local BottomSpace = Instance.new("Frame")
	BottomSpace.Size = UDim2.new(1, 0, 0, 28)
	BottomSpace.Position = UDim2.new(0, 0, 0, 712)
	BottomSpace.BackgroundTransparency = 1
	BottomSpace.Parent = PlayerScroll

	local function applyAimbotDistance()
		local raw = DistanceInput.Text:gsub("[^%d]", "")
		local value = tonumber(raw) or Settings.AimbotDistance
		value = math.clamp(math.floor(value + 0.5), 1, 200)
		Settings.AimbotDistance = value
		DistanceInput.Text = tostring(value)
	end

	DistanceInput.FocusLost:Connect(applyAimbotDistance)

	DistanceInput:GetPropertyChangedSignal("Text"):Connect(function()
		local clean = DistanceInput.Text:gsub("[^%d]", "")
		if clean ~= DistanceInput.Text then
			DistanceInput.Text = clean
			return
		end

		if clean ~= "" then
			local value = tonumber(clean)
			if value and value > 200 then
				DistanceInput.Text = "200"
			end
		end
	end)

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
			if value and value > 200 then
				WalkInput.Text = "200"
			end
		end
	end)
end

function ShowVisualMenu()
	ClearContent()
	AddressText.Text = "Vortex / Visuals"

	-- Área rolável exclusiva da aba Visual.
	-- O cabeçalho fica parado e somente as opções rolam.
	local VisualScroll = Instance.new("ScrollingFrame")
	VisualScroll.Name = "VisualScroll"
	VisualScroll.Size = UDim2.new(1, -12, 1, -64)
	VisualScroll.Position = UDim2.new(0, 6, 0, 64)
	VisualScroll.BackgroundTransparency = 1
	VisualScroll.BorderSizePixel = 0
	VisualScroll.CanvasSize = UDim2.new(0, 0, 0, 390)
	VisualScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	VisualScroll.ScrollBarThickness = 4
	VisualScroll.ScrollBarImageColor3 = GetTheme().Accent
	VisualScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	VisualScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	VisualScroll.Parent = Content

	CreateBackButton(ShowMainMenu)
	CreateMenuTitle("Visual")

	CreateOption(VisualScroll, "Ativar ESP", 6, Settings.EnableESP, function(value)
		Settings.EnableESP = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(VisualScroll, "Ativar Box", 68, Settings.EnableBoxes, function(value)
		Settings.EnableBoxes = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(VisualScroll, "Ativar Nomes", 130, Settings.EnableNames, function(value)
		Settings.EnableNames = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(VisualScroll, "Ativar Distancia", 192, Settings.EnableDistance, function(value)
		Settings.EnableDistance = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	CreateOption(VisualScroll, "Ativar Traços", 254, Settings.EnableTracers, function(value)
		Settings.EnableTracers = value
		if refreshAllESP then task.defer(refreshAllESP) end
	end)

	-- Espaço inferior para que a última opção não fique colada no limite.
	local BottomSpace = Instance.new("Frame")
	BottomSpace.Size = UDim2.new(1, 0, 0, 18)
	BottomSpace.Position = UDim2.new(0, 0, 0, 316)
	BottomSpace.BackgroundTransparency = 1
	BottomSpace.Parent = VisualScroll
end

function ShowOthersMenu()
	ClearContent()
	AddressText.Text = "Vortex / Outros"
	CreateBackButton(ShowMainMenu)
	CreateMenuTitle("Outros")
end

function ShowConfigMenu()
	ClearContent()
	AddressText.Text = "Vortex/configuração"
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

	local themeNames = {"Dark", "AzulInsano", "Inferno", "Galaxia", "Cyberpunk"}

	for index, themeName in ipairs(themeNames) do
		local currentTheme = Themes[themeName]
		local x = 8 + (index - 1) * 113

		local Card = Instance.new("TextButton")
		Card.Size = UDim2.new(0, 103, 0, 96)
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
		AccentLine.Size = UDim2.new(0, 62, 0, 9)
		AccentLine.Position = UDim2.new(0, 8, 0, 8)
		AccentLine.BackgroundColor3 = currentTheme.Accent
		AccentLine.BorderSizePixel = 0
		AccentLine.Parent = Preview

		local AccentCorner = Instance.new("UICorner")
		AccentCorner.CornerRadius = UDim.new(1, 0)
		AccentCorner.Parent = AccentLine

		local WhiteLine = Instance.new("Frame")
		WhiteLine.Size = UDim2.new(0, 50, 0, 8)
		WhiteLine.Position = UDim2.new(0, 8, 0, 25)
		WhiteLine.BackgroundColor3 = Color3.fromRGB(235, 235, 238)
		WhiteLine.BorderSizePixel = 0
		WhiteLine.Parent = Preview

		local WhiteCorner = Instance.new("UICorner")
		WhiteCorner.CornerRadius = UDim.new(1, 0)
		WhiteCorner.Parent = WhiteLine

		local GrayLine = Instance.new("Frame")
		GrayLine.Size = UDim2.new(0, 41, 0, 8)
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


--------------------------------------------------
-- PERFIL
--------------------------------------------------

local SessionStartedAt = os.clock()

local function getCurrentTeamName()
	return Player.Team and Player.Team.Name or "Sem equipe"
end


local function getMoneyText()
	local leaderstats = Player:FindFirstChild("leaderstats")
	if not leaderstats then
		return "N/D"
	end

	for _, name in ipairs({"Money", "Cash", "Dinheiro", "Coins", "Moedas"}) do
		local value = leaderstats:FindFirstChild(name)
		if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
			local amount = math.floor(value.Value)
			local formatted = tostring(amount)
			repeat
				local changed
				formatted, changed = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
			until changed == 0
			return formatted
		end
	end

	return "N/D"
end

local function onOff(value)
	return value and "Ativado" or "Desativado"
end

function ShowProfileMenu()
	ClearContent()
	AddressText.Text = "Vortex / Perfil"
	CreateBackButton(ShowMainMenu)
	CreateMenuTitle("Perfil")

	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Name = "ProfileScroll"
	Scroll.Size = UDim2.new(1, -12, 1, -64)
	Scroll.Position = UDim2.new(0, 6, 0, 64)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.CanvasSize = UDim2.new(0, 0, 0, 530)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.ScrollBarThickness = 4
	Scroll.ScrollBarImageColor3 = GetTheme().Accent
	Scroll.Parent = Content

	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, -32, 0, 92)
	Header.Position = UDim2.new(0, 16, 0, 8)
	Header.BackgroundColor3 = GetTheme().Top
	Header.BorderSizePixel = 0
	Header.Parent = Scroll

	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 8)
	HeaderCorner.Parent = Header

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 64, 0, 64)
	Avatar.Position = UDim2.new(0, 14, 0.5, -32)
	Avatar.BackgroundColor3 = GetTheme().Content
	Avatar.BorderSizePixel = 0
	Avatar.ScaleType = Enum.ScaleType.Crop
	Avatar.Parent = Header

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
		if ok and Avatar.Parent then Avatar.Image = image end
	end)

	local Display = Instance.new("TextLabel")
	Display.Size = UDim2.new(1, -100, 0, 30)
	Display.Position = UDim2.new(0, 92, 0, 17)
	Display.BackgroundTransparency = 1
	Display.Text = Player.DisplayName
	Display.TextColor3 = GetTheme().Accent
	Display.TextSize = 20
	Display.Font = Enum.Font.GothamBold
	Display.TextXAlignment = Enum.TextXAlignment.Left
	Display.Parent = Header

	local Username = Instance.new("TextLabel")
	Username.Size = UDim2.new(1, -100, 0, 22)
	Username.Position = UDim2.new(0, 92, 0, 48)
	Username.BackgroundTransparency = 1
	Username.Text = "@" .. Player.Name
	Username.TextColor3 = Color3.fromRGB(220, 220, 225)
	Username.TextSize = 14
	Username.Font = Enum.Font.Gotham
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = Header

	local InfoCard = Instance.new("Frame")
	InfoCard.Size = UDim2.new(1, -32, 0, 180)
	InfoCard.Position = UDim2.new(0, 16, 0, 112)
	InfoCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	InfoCard.BorderSizePixel = 0
	InfoCard.Parent = Scroll

	local InfoCorner = Instance.new("UICorner")
	InfoCorner.CornerRadius = UDim.new(0, 8)
	InfoCorner.Parent = InfoCard

	local InfoTitle = Instance.new("TextLabel")
	InfoTitle.Size = UDim2.new(1, -24, 0, 30)
	InfoTitle.Position = UDim2.new(0, 12, 0, 8)
	InfoTitle.BackgroundTransparency = 1
	InfoTitle.Text = "Informações"
	InfoTitle.TextColor3 = GetTheme().Accent
	InfoTitle.TextSize = 16
	InfoTitle.Font = Enum.Font.GothamBold
	InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
	InfoTitle.Parent = InfoCard

	local Info = Instance.new("TextLabel")
	Info.Size = UDim2.new(1, -32, 1, -46)
	Info.Position = UDim2.new(0, 16, 0, 40)
	Info.BackgroundTransparency = 1
	Info.RichText = true
	Info.TextColor3 = Color3.fromRGB(215, 215, 220)
	Info.TextSize = 18
	Info.Font = Enum.Font.GothamMedium
	Info.TextXAlignment = Enum.TextXAlignment.Left
	Info.TextYAlignment = Enum.TextYAlignment.Top
	Info.Parent = InfoCard

	local VortexCard = Instance.new("Frame")
	VortexCard.Size = UDim2.new(1, -32, 0, 178)
	VortexCard.Position = UDim2.new(0, 16, 0, 304)
	VortexCard.BackgroundColor3 = Color3.fromRGB(47, 47, 53)
	VortexCard.BorderSizePixel = 0
	VortexCard.Parent = Scroll

	local VortexCorner = Instance.new("UICorner")
	VortexCorner.CornerRadius = UDim.new(0, 8)
	VortexCorner.Parent = VortexCard

	local VortexTitle = Instance.new("TextLabel")
	VortexTitle.Size = UDim2.new(1, -24, 0, 30)
	VortexTitle.Position = UDim2.new(0, 12, 0, 8)
	VortexTitle.BackgroundTransparency = 1
	VortexTitle.Text = "Vortex"
	VortexTitle.TextColor3 = GetTheme().Accent
	VortexTitle.TextSize = 16
	VortexTitle.Font = Enum.Font.GothamBold
	VortexTitle.TextXAlignment = Enum.TextXAlignment.Left
	VortexTitle.Parent = VortexCard

	local VortexInfo = Instance.new("TextLabel")
	VortexInfo.Size = UDim2.new(1, -24, 1, -46)
	VortexInfo.Position = UDim2.new(0, 12, 0, 40)
	VortexInfo.BackgroundTransparency = 1
	VortexInfo.TextColor3 = Color3.fromRGB(215, 215, 220)
	VortexInfo.TextSize = 18
	VortexInfo.Font = Enum.Font.GothamMedium
	VortexInfo.TextXAlignment = Enum.TextXAlignment.Left
	VortexInfo.TextYAlignment = Enum.TextYAlignment.Top
	VortexInfo.Parent = VortexCard

	local alive = true
	Scroll.AncestryChanged:Connect(function(_, parent)
		if not parent then alive = false end
	end)

	task.spawn(function()
		while alive and Scroll.Parent do
			local elapsed = math.max(0, math.floor(os.clock() - SessionStartedAt))
			local hours = math.floor(elapsed / 3600)
			local minutes = math.floor((elapsed % 3600) / 60)
			local seconds = elapsed % 60

			local pingText = "N/D"
			pcall(function()
				pingText = tostring(math.floor(Player:GetNetworkPing() * 1000 + 0.5)) .. " ms"
			end)

			local teamName = getCurrentTeamName()
			local teamText = teamName
			local lowerTeam = string.lower(teamName)

			-- Polícia = azul | Bandido/Robber = vermelho
			if lowerTeam:find("pol") then
				teamText = '<font color="rgb(0,170,255)">' .. teamName .. '</font>'
			elseif lowerTeam:find("band") or lowerTeam:find("rob") then
				teamText = '<font color="rgb(255,55,55)">' .. teamName .. '</font>'
			end

			Info.Text =
				"User ID: " .. tostring(Player.UserId) ..
				"\nEquipe: " .. teamText ..
				"\nSessão: " .. string.format("%02dh %02dm %02ds", hours, minutes, seconds) ..
				"\nDinheiro: " .. getMoneyText() ..
				"\nPing: " .. pingText

			VortexInfo.Text =
				"Status: Ativo" ..
				"\nVersão: v1.0" ..
				"\nAimbot: " .. onOff(Settings.Aimbot) ..
				"\nESP: " .. onOff(Settings.EnableESP) ..
				"\nDesenvolvido por Vitexx"

			task.wait(1)
		end
	end)
end

function ShowMainMenu()
	ClearContent()
	AddressText.Text = "https://github.com/vtx/vortex/home"

	--------------------------------------------------
	-- CARTÃO DE PERFIL
	--------------------------------------------------

	local Profile = Instance.new("Frame")
	Profile.Size = UDim2.new(1, -30, 0, 92)
	Profile.Position = UDim2.new(0, 15, 0, 15)
	Profile.BackgroundColor3 = GetTheme().Top
	Profile.BorderSizePixel = 0
	Profile.Parent = Content

	local ProfileCorner = Instance.new("UICorner")
	ProfileCorner.CornerRadius = UDim.new(0, 9)
	ProfileCorner.Parent = Profile

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 68, 0, 68)
	Avatar.Position = UDim2.new(0, 16, 0.5, -34)
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
	Welcome.Position = UDim2.new(0, 100, 0, 7)
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
	Welcome.TextSize = 19
	Welcome.Font = Enum.Font.Gotham
	Welcome.TextXAlignment = Enum.TextXAlignment.Left
	Welcome.Parent = Profile

	local Username = Instance.new("TextLabel")
	Username.Size = UDim2.new(0, 420, 0, 24)
	Username.Position = UDim2.new(0, 100, 0, 33)
	Username.BackgroundTransparency = 1
	Username.Text = "@" .. Player.Name
	Username.TextColor3 = GetTheme().Accent
	Username.TextSize = 14
	Username.Font = Enum.Font.Gotham
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = Profile

	local Clock = Instance.new("TextLabel")
	Clock.Size = UDim2.new(0, 160, 0, 26)
	Clock.Position = UDim2.new(0, 100, 0, 53)
	Clock.BackgroundTransparency = 1
	Clock.Text = os.date("%H:%M")
	Clock.TextColor3 = Color3.fromRGB(125, 125, 132)
	Clock.TextSize = 14
	Clock.Font = Enum.Font.Gotham
	Clock.TextXAlignment = Enum.TextXAlignment.Left
	Clock.Parent = Profile

	local IdButton = Instance.new("TextButton")
	IdButton.Size = UDim2.new(0, 36, 0, 36)
	IdButton.Position = UDim2.new(1, -88, 0.5, -18)
	IdButton.BackgroundTransparency = 1
	IdButton.Text = "▣"
	IdButton.TextColor3 = GetTheme().Accent
	IdButton.TextSize = 23
	IdButton.Font = Enum.Font.Gotham
	IdButton.AutoButtonColor = false
	IdButton.Parent = Profile

	local GearButton = Instance.new("TextButton")
	GearButton.Size = UDim2.new(0, 36, 0, 36)
	GearButton.Position = UDim2.new(1, -48, 0.5, -18)
	GearButton.BackgroundTransparency = 1
	GearButton.Text = "⚙"
	GearButton.TextColor3 = GetTheme().Accent
	GearButton.TextSize = 23
	GearButton.Font = Enum.Font.Gotham
	GearButton.AutoButtonColor = false
	GearButton.Parent = Profile
	GearButton.Activated:Connect(ShowConfigMenu)

	--------------------------------------------------
	-- QUATRO BOTÕES CENTRAIS
	--------------------------------------------------

	local HomeTheme = GetTheme()

	local PlayerButton = CreateHomeSquareButton(-147, "rbxassetid://6034287594", "Jogador", ShowPlayerMenu, false)
	local VisualButton = CreateHomeSquareButton(-73, "rbxassetid://6031075938", "Visual", ShowVisualMenu, false)
	local ConfigButton = CreateHomeSquareButton(1, "", "Outros", ShowOthersMenu, false)

	-- Losango pequeno e vazado; não altera o botão Perfil.
	local OutrosIcon = ConfigButton:FindFirstChildOfClass("ImageLabel")
	if OutrosIcon then
		OutrosIcon.Visible = false
	end

	local Diamond = Instance.new("Frame")
	Diamond.Name = "OutrosDiamond"
	Diamond.AnchorPoint = Vector2.new(0.5, 0.5)
	Diamond.Size = UDim2.fromOffset(15, 15)
	Diamond.Position = UDim2.fromScale(0.5, 0.5)
	Diamond.BackgroundTransparency = 1
	Diamond.BorderSizePixel = 0
	Diamond.Rotation = 45
	Diamond.Parent = ConfigButton

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 2
	Stroke.Color = GetTheme().Accent
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = Diamond

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 2)
	Corner.Parent = Diamond
	local ProfileButton = CreateHomeSquareButton(75, "", "Perfil", ShowProfileMenu, true)

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
getRoleAndColor = function(plr)
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

--------------------------------------------------
-- AIMBOT - INIMIGO MAIS PRÓXIMO / CABEÇA
--------------------------------------------------

local function isAimbotEnemy(localRole, targetRole)
	if localRole == "Polícia" then
		return targetRole == "Ladrão"
	elseif localRole == "Ladrão" then
		return targetRole == "Polícia"
	end

	return false
end

local function getClosestAimbotTarget()
	local localCharacter = Player.Character
	local localRoot = getRoot(localCharacter)
	if not localRoot then
		return nil
	end

	local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
	if not localHumanoid or localHumanoid.Health <= 0 then
		return nil
	end

	local localRole = getRoleAndColor(Player)
	if localRole ~= "Polícia" and localRole ~= "Ladrão" then
		return nil
	end

	local closestHead = nil
	local closestDistance = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= Player then
			local targetRole = getRoleAndColor(targetPlayer)

			if isAimbotEnemy(localRole, targetRole) then
				local character = targetPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local head = character and character:FindFirstChild("Head")
				local root = getRoot(character)

				if humanoid and humanoid.Health > 0 and head and root then
					local camera = workspace.CurrentCamera
					if camera then
						-- Só considera o alvo se a cabeça estiver dentro da tela.
						local viewportPoint, onScreen = camera:WorldToViewportPoint(head.Position)

						if onScreen and viewportPoint.Z > 0 then
							-- Raycast da câmera até a cabeça para impedir mira através de paredes.
							local rayParams = RaycastParams.new()
							rayParams.FilterType = Enum.RaycastFilterType.Exclude
							rayParams.FilterDescendantsInstances = {Player.Character}
							rayParams.IgnoreWater = true

							local origin = camera.CFrame.Position
							local direction = head.Position - origin
							local result = workspace:Raycast(origin, direction, rayParams)

							-- Visível somente quando o primeiro objeto atingido pertence ao alvo.
							local visible = result
								and result.Instance
								and result.Instance:IsDescendantOf(character)

							if visible then
								local distance = (root.Position - localRoot.Position).Magnitude

								-- Distância configurável: aproximação de 1 metro ≈ 3.57 studs.
								local maxDistance = Settings.AimbotDistance * 3.57
								if distance <= maxDistance and distance < closestDistance then
									closestDistance = distance
									closestHead = head
								end
							end
						end
					end
				end
			end
		end
	end

	return closestHead
end


--------------------------------------------------
-- MIRA TELEGUIDADA - LOCK-ON INDEPENDENTE
--------------------------------------------------

local GuidedAimTarget = nil

local function isValidGuidedTarget(targetPlayer)
	if not targetPlayer or targetPlayer == Player then
		return false
	end

	local localCharacter = Player.Character
	local localRoot = getRoot(localCharacter)
	local character = targetPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	local root = getRoot(character)

	if not localRoot or not humanoid or humanoid.Health <= 0 or not head or not root then
		return false
	end

	local localRole = getRoleAndColor(Player)
	local targetRole = getRoleAndColor(targetPlayer)
	if not isAimbotEnemy(localRole, targetRole) then
		return false
	end

	local maxDistance = Settings.GuidedAimDistance * 3.57
	if (root.Position - localRoot.Position).Magnitude > maxDistance then
		return false
	end

	-- A Mira Teleguiada só mantém/trava o alvo se houver visão direta.
	-- Se uma parede ou outro objeto estiver na frente, o lock é perdido.
	local camera = workspace.CurrentCamera
	if not camera then
		return false
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {Player.Character}
	rayParams.IgnoreWater = true

	local origin = camera.CFrame.Position
	local direction = head.Position - origin
	local result = workspace:Raycast(origin, direction, rayParams)

	return result ~= nil
		and result.Instance ~= nil
		and result.Instance:IsDescendantOf(character)
end

local function getClosestGuidedTarget()
	local localRoot = getRoot(Player.Character)
	if not localRoot then return nil end

	local bestPlayer = nil
	local bestDistance = math.huge
	local maxDistance = Settings.GuidedAimDistance * 3.57

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if isValidGuidedTarget(targetPlayer) then
			local root = getRoot(targetPlayer.Character)
			local distance = (root.Position - localRoot.Position).Magnitude
			if distance <= maxDistance and distance < bestDistance then
				bestDistance = distance
				bestPlayer = targetPlayer
			end
		end
	end

	return bestPlayer
end

RunService:BindToRenderStep("VortexGuidedAim", Enum.RenderPriority.Camera.Value + 1, function()
	if not Settings.GuidedAim then
		GuidedAimTarget = nil
		return
	end

	-- Mantém o mesmo jogador enquanto ele continuar válido:
	-- a mira fica realmente "grudada" nele em vez de trocar a cada frame.
	if not isValidGuidedTarget(GuidedAimTarget) then
		GuidedAimTarget = getClosestGuidedTarget()
	end

	if not GuidedAimTarget then
		return
	end

	local character = GuidedAimTarget.Character
	local head = character and character:FindFirstChild("Head")
	local camera = workspace.CurrentCamera

	if camera and head then
		camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
	end
end)

RunService.RenderStepped:Connect(function()
	if not Settings.Aimbot then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local targetHead = getClosestAimbotTarget()
	if not targetHead then
		return
	end

	camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
end)

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
