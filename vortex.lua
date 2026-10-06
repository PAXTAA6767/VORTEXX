local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "Vortex"
gui.ResetOnSpawn = false
gui.Parent = playerGui

--------------------------------------------------
-- BOTÃO
--------------------------------------------------

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 55)
button.Position = UDim2.new(0, 20, 0, 100)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "ABRIR VORTEX"
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.Parent = gui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = button

--------------------------------------------------
-- PAINEL
--------------------------------------------------

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 400, 0, 280)
panel.Position = UDim2.new(0.5, -200, 0.5, -140)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 27)
panel.Visible = false
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

--------------------------------------------------
-- TÍTULO
--------------------------------------------------

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 50)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "◐  Vortex"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

--------------------------------------------------
-- FECHAR
--------------------------------------------------

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 45, 0, 45)
close.Position = UDim2.new(1, -50, 0, 2)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.fromRGB(180, 180, 180)
close.TextSize = 25
close.Parent = panel

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(21, 22, 24)
sidebar.BorderSizePixel = 0
sidebar.Parent = panel

--------------------------------------------------
-- BOTÕES DA SIDEBAR
--------------------------------------------------

local function sidebarButton(text, y)

	local b = Instance.new("TextButton")

	b.Size = UDim2.new(0, 88, 0, 38)
	b.Position = UDim2.new(0, 6, 0, y)

	b.BackgroundColor3 = Color3.fromRGB(38, 39, 42)
	b.TextColor3 = Color3.fromRGB(145, 145, 150)

	b.Text = text
	b.TextSize = 11
	b.Font = Enum.Font.Gotham

	b.Parent = sidebar

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = b

	b.MouseButton1Click:Connect(function()
		print("ABA:", text)
	end)
end

sidebarButton("⌂  Home", 10)
sidebarButton("◉  Visual", 54)
sidebarButton("♙  Player", 98)
sidebarButton("⚙  Misc", 142)

--------------------------------------------------
-- ABRIR
--------------------------------------------------

button.MouseButton1Click:Connect(function()

	button.Visible = false
	panel.Visible = true

end)

--------------------------------------------------
-- FECHAR
--------------------------------------------------

close.MouseButton1Click:Connect(function()

	panel.Visible = false
	button.Visible = true

end)

--------------------------------------------------
-- VORTEX VISUALS
-- COMPLEMENTO - NÃO ALTERA A BASE
--------------------------------------------------

local visualWindow = Instance.new("Frame")

visualWindow.Name = "VisualWindow"
visualWindow.Size = UDim2.new(0, 520, 0, 400)
visualWindow.Position = UDim2.new(0.5, -260, 0.5, -200)

visualWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
visualWindow.Visible = false
visualWindow.Parent = gui

local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 10)
windowCorner.Parent = visualWindow

--------------------------------------------------
-- TOPO
--------------------------------------------------

local header = Instance.new("Frame")

header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
header.BorderSizePixel = 0
header.Parent = visualWindow

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local headerTitle = Instance.new("TextLabel")

headerTitle.Size = UDim2.new(1, -60, 1, 0)
headerTitle.Position = UDim2.new(0, 18, 0, 0)

headerTitle.BackgroundTransparency = 1
headerTitle.Text = "◉  Visuals"
headerTitle.TextColor3 = Color3.fromRGB(235, 235, 235)

headerTitle.TextSize = 17
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left

headerTitle.Parent = header

--------------------------------------------------
-- FECHAR JANELA
--------------------------------------------------

local visualClose = Instance.new("TextButton")

visualClose.Size = UDim2.new(0, 42, 0, 42)
visualClose.Position = UDim2.new(1, -46, 0, 4)

visualClose.BackgroundTransparency = 1
visualClose.Text = "×"

visualClose.TextColor3 = Color3.fromRGB(200, 200, 200)
visualClose.TextSize = 25
visualClose.Font = Enum.Font.Gotham

visualClose.Parent = header

--------------------------------------------------
-- CONTEÚDO
--------------------------------------------------

local content = Instance.new("Frame")

content.Size = UDim2.new(1, -30, 1, -70)
content.Position = UDim2.new(0, 15, 0, 60)

content.BackgroundTransparency = 1
content.Parent = visualWindow

--------------------------------------------------
-- TÍTULO
--------------------------------------------------

local info = Instance.new("TextLabel")

info.Size = UDim2.new(1, 0, 0, 35)

info.BackgroundTransparency = 1
info.Text = "Visual Settings"

info.TextColor3 = Color3.fromRGB(210, 210, 215)
info.TextSize = 16
info.Font = Enum.Font.GothamBold

info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = content

--------------------------------------------------
-- CRIAR OPÇÃO
--------------------------------------------------

local function createOption(nome, posY)

	local option = Instance.new("TextButton")

	option.Size = UDim2.new(1, 0, 0, 50)
	option.Position = UDim2.new(0, 0, 0, posY)

	option.BackgroundColor3 = Color3.fromRGB(43, 43, 48)

	option.Text = ""
	option.AutoButtonColor = false

	option.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = option

	--------------------------------------------------
	-- NOME
	--------------------------------------------------

	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)

	label.BackgroundTransparency = 1

	label.Text = nome
	label.TextColor3 = Color3.fromRGB(225, 225, 225)

	label.TextSize = 14
	label.Font = Enum.Font.Gotham

	label.TextXAlignment = Enum.TextXAlignment.Left

	label.Active = false
	label.Parent = option

	--------------------------------------------------
	-- INDICADOR
	--------------------------------------------------

	local indicator = Instance.new("Frame")

	indicator.Size = UDim2.new(0, 22, 0, 22)
	indicator.Position = UDim2.new(1, -37, 0.5, -11)

	indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 44)

	indicator.BorderSizePixel = 1
	indicator.BorderColor3 = Color3.fromRGB(120, 120, 125)

	indicator.Active = false
	indicator.Parent = option

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 4)
	indicatorCorner.Parent = indicator

	--------------------------------------------------
	-- ESTADO
	--------------------------------------------------

	local ativo = false

	option.MouseButton1Click:Connect(function()

		ativo = not ativo

		if ativo then

			indicator.BackgroundColor3 =
				Color3.fromRGB(90, 160, 230)

			indicator.BorderColor3 =
				Color3.fromRGB(160, 205, 255)

			option.BackgroundColor3 =
				Color3.fromRGB(55, 58, 64)

			label.Text = nome .. "  [ON]"

		else

			indicator.BackgroundColor3 =
				Color3.fromRGB(40, 40, 44)

			indicator.BorderColor3 =
				Color3.fromRGB(120, 120, 125)

			option.BackgroundColor3 =
				Color3.fromRGB(43, 43, 48)

			label.Text = nome

		end

	end)

end

--------------------------------------------------
-- OPÇÕES VISUAIS
--------------------------------------------------

createOption("Enable ESP", 45)
createOption("Enable Players", 105)
createOption("Enable Boxes", 165)
createOption("Enable Names", 225)
createOption("Enable Distance", 285)

--------------------------------------------------
-- ENCONTRAR O BOTÃO VISUAL EXISTENTE
-- NÃO CRIA OUTRO BOTÃO
--------------------------------------------------

local existingVisualButton = nil

for _, objeto in ipairs(sidebar:GetChildren()) do

	if objeto:IsA("TextButton") then

		if objeto.Text:find("Visual") then

			existingVisualButton = objeto
			break

		end

	end

end

--------------------------------------------------
-- CLICAR NO VISUAL EXISTENTE
--------------------------------------------------

if existingVisualButton then

	existingVisualButton.MouseButton1Click:Connect(function()

		panel.Visible = false
		button.Visible = false

		visualWindow.Visible = true

	end)

end

--------------------------------------------------
-- FECHAR VISUALS
--------------------------------------------------

visualClose.MouseButton1Click:Connect(function()

	visualWindow.Visible = false

	panel.Visible = true
	button.Visible = false

end)

print("VORTEX VISUALS ADICIONADO")

print("VORTEX TESTE COM SIDEBAR CARREGADO")
