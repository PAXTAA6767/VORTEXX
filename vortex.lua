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
	Fly = false,
	FlySpeed = 0,
	FollowPlayer = false,
	NoWait = false,
	GodMode = false,
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
-- OLHAR PLAYER - OUTROS
--------------------------------------------------

local FollowTarget = nil
local FollowPauseUntil = 0

local function setFollowTarget(targetPlayer)
	if targetPlayer == Player then
		return
	end
	FollowTarget = targetPlayer
	Settings.FollowPlayer = targetPlayer ~= nil
end

local function stopFollowing()
	-- Guarda a posição atual antes de desligar o acompanhamento.
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	FollowTarget = nil
	Settings.FollowPlayer = false
	FollowPauseUntil = 0

	-- Cancela qualquer MoveTo antigo que ainda possa estar ativo.
	if humanoid and root then
		humanoid:Move(Vector3.zero, false)
		humanoid:MoveTo(root.Position)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

-- Dá uma pequena janela para interações/combate sem o TP reposicionar
-- o personagem a cada frame.
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not Settings.FollowPlayer then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.E
		or input.KeyCode == Enum.KeyCode.F then
		FollowPauseUntil = os.clock() + 0.45
	end
end)


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

	-- Durante uma interação, deixa o personagem parado por alguns instantes.
	if os.clock() < FollowPauseUntil then
		return
	end

	-- Mantém você perto, mas sem ficar exatamente dentro do outro personagem.
	-- 2.5 studs atrás costuma deixar as interações mais estáveis.
	local followOffset = CFrame.new(0, 0, 2.5)
	local desiredCFrame = targetRoot.CFrame * followOffset

	character:PivotTo(desiredCFrame)
	root.AssemblyLinearVelocity = Vector3.zero
