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
