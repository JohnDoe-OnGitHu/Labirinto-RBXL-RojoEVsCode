local EncodingService = game:GetService("EncodingService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local gong = SoundService:WaitForChild("WrongTurn")
gong.Looped = true
gong.Volume = 0
gong:Play()

local DISTANCIA_MAXIMA = 30
local VOLUME_MAXIMO = 0.8

-- ──────────── LOOP PROXIMIDADE ———————————————————
RunService.Heartbeat:Connect(function()
	local personagem = player.Character
	local hrp = personagem and personagem:FindFirstChild("HumanoidRootPart")

	if not hrp then
		gong.Volume = 0
		return
	end

	local menorDistancia = DISTANCIA_MAXIMA
	local encontrouEsfera = false

	local pastaLabirinto = workspace:FindFirstChild("Labirinto")

	if pastaLabirinto then
		for _, objeto in pairs(pastaLabirinto:GetChildren()) do
			if objeto.Name:sub(1, 6) == "Esfera" then
				local distancia = (hrp.Position - objeto.Position).Magnitude
				if distancia < menorDistancia then
					menorDistancia = distancia
					encontrouEsfera = true
				end
			end
		end
	end

	-- ———————— CAUCULO DO VOLUME UAUASIDJDSAJDASJKDASKJHDJKSDSAHDIWSHDU\ASWNDVUSYWAFVGDCUSWoFOLes8wfvdcg hnEYDGC8TDSEI87W —————————————————————————————————————————————————————————————————————————————————————————————————————————————

	if encontrouEsfera then
		local intensidadeBase = 1 - (menorDistancia / DISTANCIA_MAXIMA)
		local intensidadeQuadrada = math.pow(intensidadeBase, 2)
		gong.Volume = math.clamp(intensidadeQuadrada * VOLUME_MAXIMO, 0, VOLUME_MAXIMO)
	else
		gong.Volume = 0
	end
end)
