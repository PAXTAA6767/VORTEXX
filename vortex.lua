local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIGURAÇÕES
--------------------------------------------------

local Settings = {
	-- Jogador
	EnablePlayers = true,
	EnableSelf = false,

	-- Visual
	EnableESP = true,
	EnableBoxes = true,
	EnableNames = true,
	EnableDistance = true,
	EnableTracers = false,

}

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "VortexPanel"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

--------------------------------------------------
-- JANELA PRINCIPAL
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 760, 0, 500)
Main.Position = UDim2.new(0.5, -380, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--------------------------------------------------
-- TOPO
--------------------------------------------------

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 45)
Top.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "☾  Vortex"
Title.TextColor3 = Color3.fromRGB(225,225,225)
Title.TextSize = 15
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -48, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220,220,220)
Close.TextSize = 25
Close.Font = Enum.Font.Gotham
Close.Parent = Top

Close.Activated:Connect(function()
	Main.Visible = false
end)

--------------------------------------------------
-- BARRA
--------------------------------------------------

local Address = Instance.new("TextLabel")
Address.Size = UDim2.new(1, -30, 0, 34)
Address.Position = UDim2.new(0, 15, 0, 55)
Address.BackgroundColor3 = Color3.fromRGB(45,45,50)
Address.BorderSizePixel = 0
Address.Text = "  🔍   Test Environment"
Address.TextColor3 = Color3.fromRGB(145,145,150)
Address.TextSize = 14
Address.Font = Enum.Font.Gotham
Address.TextXAlignment = Enum.TextXAlignment.Left
Address.Parent = Main

local AddressCorner = Instance.new("UICorner")
AddressCorner.CornerRadius = UDim.new(0,7)
AddressCorner.Parent = Address

--------------------------------------------------
-- CONTAINER
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -30, 1, -105)
Content.Position = UDim2.new(0,15,0,100)
Content.BackgroundColor3 = Color3.fromRGB(39,39,44)
Content.BorderSizePixel = 0
Content.Parent = Main

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0,10)
ContentCorner.Parent = Content

--------------------------------------------------
-- FUNÇÃO PARA LIMPAR CONTEÚDO
--------------------------------------------------

local function ClearContent()
	for _, object in ipairs(Content:GetChildren()) do
		object:Destroy()
	end
end

--------------------------------------------------
-- BOTÃO DE OPÇÃO
--------------------------------------------------

local function CreateOption(parent, text, y, value, callback)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -30, 0, 55)
	Button.Position = UDim2.new(0,15,0,y)
	Button.BackgroundColor3 = Color3.fromRGB(48,48,53)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button

	--------------------------------------------------
	-- TEXTO
	--------------------------------------------------

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1,-75,1,0)
	Label.Position = UDim2.new(0,15,0,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(225,225,225)
	Label.TextSize = 19
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	--------------------------------------------------
	-- CHECKBOX
	--------------------------------------------------

	local Check = Instance.new("Frame")
	Check.Size = UDim2.new(0,24,0,24)
	Check.Position = UDim2.new(1,-45,0.5,-12)
	Check.BackgroundColor3 = Color3.fromRGB(42,42,46)
	Check.BorderSizePixel = 2
	Check.BorderColor3 = Color3.fromRGB(135,135,140)
	Check.Parent = Button

	local CheckCorner = Instance.new("UICorner")
	CheckCorner.CornerRadius = UDim.new(0,3)
	CheckCorner.Parent = Check

	local Mark = Instance.new("TextLabel")
	Mark.Size = UDim2.fromScale(1,1)
	Mark.BackgroundTransparency = 1
	Mark.Text = "✓"
	Mark.TextColor3 = Color3.new(1,1,1)
	Mark.TextSize = 17
	Mark.Font = Enum.Font.GothamBold
	Mark.Visible = false
	Mark.Parent = Check

	local Enabled = value

	local function Update()

		if Enabled then
			Check.BackgroundColor3 = Color3.fromRGB(65,135,195)
			Check.BorderColor3 = Color3.fromRGB(85,155,215)
			Mark.Visible = true
		else
			Check.BackgroundColor3 = Color3.fromRGB(42,42,46)
			Check.BorderColor3 = Color3.fromRGB(135,135,140)
			Mark.Visible = false
		end

		callback(Enabled)
	end

	Button.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		Update()
	end)

	Update()
end

--------------------------------------------------
-- BOTÃO VOLTAR
--------------------------------------------------

local function CreateBackButton(callback)

	local Back = Instance.new("TextButton")
	Back.Size = UDim2.new(0,110,0,40)
	Back.Position = UDim2.new(0,15,0,15)
	Back.BackgroundColor3 = Color3.fromRGB(48,48,53)
	Back.BorderSizePixel = 0
	Back.Text = "←  Voltar"
	Back.TextColor3 = Color3.fromRGB(220,220,220)
	Back.TextSize = 15
	Back.Font = Enum.Font.Gotham
	Back.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,7)
	Corner.Parent = Back

	Back.Activated:Connect(callback)
end

--------------------------------------------------
-- MENU PRINCIPAL
--------------------------------------------------

local function ShowMainMenu()

	ClearContent()

	Address.Text = "  🔍   Test Environment"

	local Info = Instance.new("TextLabel")
	Info.Size = UDim2.new(1,-30,0,40)
	Info.Position = UDim2.new(0,15,0,15)
	Info.BackgroundTransparency = 1
	Info.Text = "Selecione uma categoria"
	Info.TextColor3 = Color3.fromRGB(170,170,175)
	Info.TextSize = 18
	Info.Font = Enum.Font.Gotham
	Info.TextXAlignment = Enum.TextXAlignment.Left
	Info.Parent = Content

	--------------------------------------------------
	-- JOGADOR
	--------------------------------------------------

	local PlayerButton = Instance.new("TextButton")
	PlayerButton.Size = UDim2.new(1,-30,0,80)
	PlayerButton.Position = UDim2.new(0,15,0,70)
	PlayerButton.BackgroundColor3 = Color3.fromRGB(48,48,53)
	PlayerButton.BorderSizePixel = 0
	PlayerButton.Text = "👤   Jogador"
	PlayerButton.TextColor3 = Color3.fromRGB(225,225,225)
	PlayerButton.TextSize = 20
	PlayerButton.Font = Enum.Font.Gotham
	PlayerButton.TextXAlignment = Enum.TextXAlignment.Left
	PlayerButton.Parent = Content

	local P = Instance.new("UICorner")
	P.CornerRadius = UDim.new(0,8)
	P.Parent = PlayerButton

	PlayerButton.Activated:Connect(function()
		ShowPlayerMenu()
	end)

	--------------------------------------------------
	-- VISUAL
	--------------------------------------------------

	local VisualButton = PlayerButton:Clone()
	VisualButton.Position = UDim2.new(0,15,0,165)
	VisualButton.Text = "👁   Visual"
	VisualButton.Parent = Content

	VisualButton.Activated:Connect(function()
		ShowVisualMenu()
	end)

	--------------------------------------------------
	-- CONFIGURAÇÃO
	--------------------------------------------------

	local ConfigButton = PlayerButton:Clone()
	ConfigButton.Position = UDim2.new(0,15,0,260)
	ConfigButton.Text = "⚙   Configuração"
	ConfigButton.Parent = Content

	ConfigButton.Activated:Connect(function()
		ShowConfigMenu()
	end)
end

--------------------------------------------------
-- MENU JOGADOR
--------------------------------------------------

function ShowPlayerMenu()

	ClearContent()

	Address.Text = "  🔍   Test Environment / Player"

	CreateBackButton(ShowMainMenu)

	CreateOption(
		Content,
		"Enable Players",
		70,
		Settings.EnablePlayers,
		function(value)
			Settings.EnablePlayers = value
		end
	)

	CreateOption(
		Content,
		"Enable Self",
		135,
		Settings.EnableSelf,
		function(value)
			Settings.EnableSelf = value
		end
	)
end

--------------------------------------------------
-- MENU VISUAL
--------------------------------------------------

function ShowVisualMenu()

	ClearContent()

	Address.Text = "  🔍   Test Environment / Visuals"

	CreateBackButton(ShowMainMenu)

	CreateOption(
		Content,
		"Enable ESP",
		70,
		Settings.EnableESP,
		function(value)
			Settings.EnableESP = value
		end
	)

	CreateOption(
		Content,
		"Enable Boxes",
		135,
		Settings.EnableBoxes,
		function(value)
			Settings.EnableBoxes = value
		end
	)

	CreateOption(
		Content,
		"Enable Names",
		200,
		Settings.EnableNames,
		function(value)
			Settings.EnableNames = value
		end
	)

	CreateOption(
		Content,
		"Enable Distance",
		265,
		Settings.EnableDistance,
		function(value)
			Settings.EnableDistance = value
		end
	)

	CreateOption(
		Content,
		"Enable Tracers",
		330,
		Settings.EnableTracers,
		function(value)
			Settings.EnableTracers = value
		end
	)
end

--------------------------------------------------
-- MENU CONFIGURAÇÃO
--------------------------------------------------

function ShowConfigMenu()

	ClearContent()

	Address.Text = "  🔍   Test Environment / Settings"

	CreateBackButton(ShowMainMenu)

	local Info = Instance.new("TextLabel")
	Info.Size = UDim2.new(1,-30,0,70)
	Info.Position = UDim2.new(0,15,0,75)
	Info.BackgroundColor3 = Color3.fromRGB(48,48,53)
	Info.BorderSizePixel = 0
	Info.Text = "Team Colors: automático\nAs cores são definidas pela equipe de cada jogador."
	Info.TextColor3 = Color3.fromRGB(220,220,225)
	Info.TextSize = 15
	Info.Font = Enum.Font.Gotham
	Info.TextWrapped = true
	Info.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Info
end

--------------------------------------------------
-- ABRIR MENU PRINCIPAL COM K
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        Main.Visible = not Main.Visible
        if Main.Visible then
            ShowMainMenu()
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

    ESP[plr] = nil
end

local function getRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Cor automática baseada na equipe do jogador.
local function getTeamColor(plr)
    if plr.Team then
        return plr.Team.TeamColor.Color
    end

    return plr.TeamColor.Color
end

local function updateESP(plr)
    if plr == Player then
        if not Settings.EnableSelf then
            destroyESP(plr)
        end
        return
    end

    if not Settings.EnableESP or not Settings.EnablePlayers then
        destroyESP(plr)
        return
    end

    local character = plr.Character
    local root = getRoot(character)

    if not character or not root then
        destroyESP(plr)
        return
    end

    local data = ESP[plr]

    if not data or data.Character ~= character then
        destroyESP(plr)
        data = {Character = character}
        ESP[plr] = data
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
    local teamColor = getTeamColor(plr)

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
            label.TextSize = 14
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

    -- Tracer visual simples para o seu próprio jogo
    if Settings.EnableTracers then
        if not data.Tracer then
            local attachment = Instance.new("Attachment")
            attachment.Name = "VortexTracerAttachment"
            attachment.Parent = root

            local localCharacter = Player.Character
            local localRoot = getRoot(localCharacter)

            if localRoot then
                local fromAttachment = localRoot:FindFirstChild("VortexTracerOrigin")
                if not fromAttachment then
                    fromAttachment = Instance.new("Attachment")
                    fromAttachment.Name = "VortexTracerOrigin"
                    fromAttachment.Parent = localRoot
                end

                local beam = Instance.new("Beam")
                beam.Name = "VortexTracer"
                beam.Attachment0 = fromAttachment
                beam.Attachment1 = attachment
                beam.FaceCamera = true
                beam.Width0 = 0.06
                beam.Width1 = 0.06
                local teamColor = getTeamColor(plr)
                beam.Color = ColorSequence.new(teamColor)
                beam.Transparency = NumberSequence.new(0.15)
                beam.LightEmission = 1
                beam.Parent = localRoot
                data.Tracer = beam
                data.TracerAttachment = attachment
            else
                attachment:Destroy()
            end
        end
    elseif data.Tracer or data.TracerAttachment then
        if data.Tracer then data.Tracer:Destroy() end
        if data.TracerAttachment then data.TracerAttachment:Destroy() end
        data.Tracer = nil
        data.TracerAttachment = nil
    end

    if data.Tracer then
        data.Tracer.Color = ColorSequence.new(teamColor)
    end
end

local function refreshAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        updateESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.4)
        updateESP(plr)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    destroyESP(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Player then
        plr.CharacterAdded:Connect(function()
            task.wait(0.4)
            updateESP(plr)
        end)
    end
end

-- Reaplica configurações dos botões, cores de equipe, distância e novos personagens.
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
