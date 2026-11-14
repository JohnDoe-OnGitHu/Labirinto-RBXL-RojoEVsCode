-- ============================================================
-- LocalScript: ControleEspada
-- TIPO: LocalScript
-- LOCAL: StarterPlayerScripts
--
-- O QUE FAZ:
-- Detecta o clique na espada ou a tecla F e solicita o golpe ao servidor.
-- ============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local eventoArma = ReplicatedStorage:WaitForChild("AtualizarBatalha")
local eventoGolpe = ReplicatedStorage:WaitForChild("GolpeEspada")

local estaArmado = false
local podeClicar = true
local COOLDOWN_GOLPE = 0.5
local ferramentasConectadas = setmetatable({}, { __mode = "k" })

eventoArma.OnClientEvent:Connect(function(tipo, valor)
	if tipo == "armado" then
		estaArmado = valor
	end
end)

local function solicitarGolpe()
	if not estaArmado or not podeClicar then return end

	local personagem = player.Character
	local humanoide = personagem and personagem:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 then return end

	podeClicar = false
	eventoGolpe:FireServer()
	task.delay(COOLDOWN_GOLPE, function()
		podeClicar = true
	end)
end

local function conectarFerramenta(instancia)
	if instancia:IsA("Tool") and instancia.Name == "Espada" and not ferramentasConectadas[instancia] then
		ferramentasConectadas[instancia] = true
		instancia.Activated:Connect(solicitarGolpe)
	end
end

local function configurarPersonagem(personagem)
	personagem.ChildAdded:Connect(conectarFerramenta)
	for _, instancia in ipairs(personagem:GetChildren()) do
		conectarFerramenta(instancia)
	end
end

player.CharacterAdded:Connect(configurarPersonagem)
if player.Character then
	configurarPersonagem(player.Character)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
		solicitarGolpe()
	end
end)