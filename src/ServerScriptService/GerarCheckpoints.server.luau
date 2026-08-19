local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dados = require(ReplicatedStorage:WaitForChild("DadosLabirinto"))
while Dados.grid == nil do
	task.wait(0.1)
end

local function obterOuCriarRemote(nome, tipo)
	local existente = ReplicatedStorage:FindFirstChild(nome)
	if existente then return existente end
	local novo = Instance.new(tipo)
	novo.Name = nome
	novo.Parent = ReplicatedStorage
	return novo
end

local remoteCriar = obterOuCriarRemote("CriarCheckpoints", "RemoteEvent")
local remoteAtivado = obterOuCriarRemote("CheckpointAtivado", "RemoteEvent")
local remoteReativar = obterOuCriarRemote("ReativarCheckpoint", "RemoteEvent")

local TOTAL_CHECKPOINTS = 8
local DISTANCIA_MINIMA = 25

local function sortearCheckpoints(userId)
	local celulas = Dados.obterCelulasAbertas()
	local posicoes = {}
	local resultados = {}

	if Dados.spawnsJogadores[userId] then
		table.insert(posicoes, Dados.spawnsJogadores[userId])
	end

	for i = #celulas, 2, -1 do
		local j = math.random(1, i)
		celulas[i], celulas[j] = celulas[j], celulas[i]
	end

	for _, celula in ipairs(celulas) do
		if #resultados >= TOTAL_CHECKPOINTS then break end

		if Dados.posicaoEhValida(celula.posicao, posicoes, DISTANCIA_MINIMA) then
			table.insert(posicoes, celula.posicao)
			table.insert(resultados, {
				posicoes = celula.posicao,
				ativado = false,
			})
		end
	end

	return resultados
end

local function configurarJogador(jogador)
	local userId = jogador.UserId

	local tentativas = 0
	while not Dados.spawnsJogadores[userId] and tentativas < 50 do
		task.wait(0.1)
		tentativas += 1
	end

	if not Dados.checkpointsJogadores[userId] then
		Dados.checkpointsJogadores[userId] = sortearCheckpoints(userId)
		Dados.inicializarStatusJogador(userId)

		print("[GerarCheckpoints] " .. jogador.Name ..
			" recebeu " .. #Dados.checkpointsJogadores[userId] ..
			" checkpoints."
		)
	end

	local personagem = jogador.Character or jogador.CharacterAdded:Wait()
	personagem:WaitForChild("HumanoidRootPart")

	remoteCriar:FireClient(jogador, Dados.checkpointsJogadores[userId])
end

local function observarStatusJogador(jogador)
	while jogador.Parent do
		task.wait(5)

		local userId = jogador.UserId
		local status = Dados.statusJogadores[userId]
		local checkpoints = Dados.checkpointsJogadores[userId]
		local personagens = jogador.Character

		if status and checkpoints and status.mudouStatus and personagens then
			local hrp = personagens:FindFirstChild("HumanoidRootPart")
			if hrp then
				local indice = Dados.reativarCheckpointProximo(userId, hrp.Position)

				if indice then
					remoteReativar:FireClient(jogador, indice)
					print("[GerarCheckpoints] Checkpoint " .. indice .. " reativado para " .. jogador.Name)
				end
			end
		end
	end
end

remoteAtivado.OnServerEvent:Connect(function(jogador, indice)
	local userId = jogador.UserId
	local checkpoints = Dados.checkpointsJogadores[userId]

	if not checkpoints then return end
	if not checkpoints[indice] then return end

	if not checkpoints[indice].ativado then
		Dados.ativarCheckpoint(userId, indice)
		print("[GerarCheckpoints] " .. jogador.Name .. " ativou checkpoint " .. indice .. " em " .. tostring(checkpoints[indice].posicoes))
	end
end)

Players.PlayerAdded:Connect(function(jogador)
	configurarJogador(jogador)
	task.spawn(observarStatusJogador, jogador)
	jogador.CharacterAdded:Connect(function()
		task.wait(0.6)
		if Dados.checkpointsJogadores[jogador.UserId] then
			remoteCriar:FireClient(
				jogador,
				Dados.checkpointsJogadores[jogador.UserId]
			)
		end
	end)
end)

for _, jogador in ipairs(Players:GetPlayers()) do
	task.spawn(configurarJogador, jogador)
	task.spawn(observarStatusJogador, jogador)
end