local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIGURAÇÕES
--------------------------------------------------

local Settings = {
	-- Visual
	EnableESP = true,
	EnableBoxes = true,
	EnableNames = true,
	EnableDistance = true,
	EnableTracers = false,

}

-- Será definido na parte do ESP; permite que os toggles atualizem imediatamente.
local refreshAllESP

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
