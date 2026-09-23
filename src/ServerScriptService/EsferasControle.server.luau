local workspace = game.Workspace
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dados = require(game.ReplicatedStorage:WaitForChild("DadosLabirinto"))

local eventoHUD = ReplicatedStorage:WaitForChild("AtualizarEsferas")


local contadorEsferas = 0

local ESFERA_POR_JOGADOR = 5
local ALTURA_FLUTUACAO = 4
local VELOCIDADE_FLUTUAR = 0.8
local AMPLITUDE_FLUTUAR = 0.9
local PERCENTUAL_DEVOLUCAO = 0.5
local CELULA = Dados.CELULA

local TEMPO_RESPAWN_MIN = 45
local TEMPO_RESPAWN_MAX = 90
local DISTANCIA_MINIMA_SPAWN = 12

local contadorEsferas = 0

local grid, offsetX, offsetZ, yChao

repeat
	task.wait(0.1)
	
	grid = Dados.grid
	offsetX = Dados.offsetX
	offsetZ = Dados.offsetZ
	yChao = Dados.yChao
until grid ~= nil and offsetX ~= nil and offsetZ ~= nil and yChao ~= nil

local celulasAbertas = Dados.obterCelulasAbertas()

for i = #celulasAbertas, 2, -1 do
	local j = math.random(i)
	celulasAbertas[i], celulasAbertas[j] = celulasAbertas[j], celulasAbertas[i]
end

local function distanciaCelulas(a, b)
	return math.abs(a.l - b.l) + math.abs(a.c - b.c)
end

local posicoesEscolhidas = {}
local tentativaDistancia = 12
local quantidadeInicial = #Players:GetPlayers() * ESFERA_POR_JOGADOR

while #posicoesEscolhidas < quantidadeInicial and tentativaDistancia >= 2 do
	for _, celula in ipairs(celulasAbertas) do
		if #posicoesEscolhidas >= quantidadeInicial then break end
		
		local jaEscolhida = false
		
		for _, escolhida in ipairs(posicoesEscolhidas) do
			if escolhida.l == celula.l and escolhida.c == celula.c then
				jaEscolhida = true
				break
			end
		end
		
		if not jaEscolhida then
			local podeUsar = true
			
			for _, escolhida in ipairs(posicoesEscolhidas) do
				if distanciaCelulas(celula, escolhida) < tentativaDistancia then
					podeUsar = false
					break
				end
			end
			
			if podeUsar then
				table.insert(posicoesEscolhidas, celula)
			end
		end
	end
	
	tentativaDistancia -= 1
end

print("[Esferas] foi criadas pelo ar que criou o ar que fez o ar que criou o ar que fez o ar que criou o ar que fez o ar que criou o ar que fez o ar em " .. #posicoesEscolhidas .. " belza?")

local pasta = workspace:WaitForChild("Labirinto")

local esferasAtivas = {}
local esferasTocadas = {}
local esferasRestantes = 0
local TOTAL_ESFERAS_REAL = 0

local aoTocar
local agendarRespawn
local criarEsferaEmLinhaColuna

agendarRespawn = function()
	local tempoEspera = math.random(TEMPO_RESPAWN_MIN, TEMPO_RESPAWN_MAX)
	
	task.delay(tempoEspera, function()
		local celulas = Dados.obterCelulasAbertas()

		for i = #celulas, 2, -1 do
			local j = math.random(i)
			celulas[i], celulas[j] = celulas[j], celulas[i]
		end

		local posOcupadas = {}
		for _, dados in ipairs(esferasAtivas) do
			if dados.parte and dados.parte.Parent then
				table.insert(posOcupadas, dados.parte.Position)
			end
		end

		for _, celula in ipairs(celulas) do
			local x = (celula.c - 1 + 0.5) * CELULA + offsetX
			local z = -(celula.l - 1) * CELULA + offsetZ
			local posVector = Vector3.new(x, yChao + ALTURA_FLUTUACAO, z)
			
			local distanciaValida = true
			for _, posAtiva in ipairs(posOcupadas) do
				if (posVector - posAtiva).Magnitude < (DISTANCIA_MINIMA_SPAWN) then
					distanciaValida = false
					break
				end
			end
			
			if distanciaValida then
				local novaEsfera = criarEsferaEmLinhaColuna(celula.l, celula.c, tick())
				if novaEsfera then
					esferasRestantes += 1

					for _, jogador in ipairs(Players:GetPlayer()) do
						local status = Dados.statusJogadores[jogador.UserId]
						local minhasColetadas = status and status.esferasColetadas or 0
						eventoHUD:FireClient(jogador, esferasRestantes, minhasColetadas)
					end
					break
				end
			end
		end
	end)
end
aoTocar = function(esfera, outraParte, valor, ehEspecial)
	valor = valor or 1
	if esferasTocadas[esfera] then return end

	local personagem = outraParte.Parent
	if not personagem then return end

	local jogador = Players:GetPlayerFromCharacter(personagem)
	if not jogador then
		return
	end

	Dados.coletarEsfera(jogador.UserId, valor)

	esferasTocadas[esfera] = true
	esferasRestantes -= 1

	for i, dados in ipairs(esferasAtivas) do
		if dados.parte == esfera then
			table.remove(esferasAtivas, i)
			break
		end
	end
	local somColeta = Instance.new("Sound")
	somColeta.SoundId = "rbxassetid://139158676154751"
	somColeta.Parent = esfera
	somColeta:Play()
	game:GetService("Debris"):AddItem(somColeta, 2)
	esfera:Destroy()

	for _, jogadorAtual in ipairs(Players:GetPlayers()) do
		local status = Dados.statusJogadores[jogadorAtual.UserId]
		local minhasColetadas = status and status.esferasColetadas or 0
		eventoHUD:FireClient(jogadorAtual, esferasNoMapa, minhasColetadas)
	end

	if not ehEspecial then
		agendarRespawn()
	end
end

criarEsferaEmLinhaColuna = function(linha, coluna, indice)
	local x = (coluna - 1 + 0.5) * CELULA + offsetX
	local z = -(linha - 1) * CELULA + offsetZ
	local y = yChao + ALTURA_FLUTUACAO
	
	local posicaoAlvo = Vector3.new(x, y, z)
	
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = {workspace:WaitForChild("Labirinto")}
	params.FilterType = Enum.RaycastFilterType.Include
	
	local partesNaParede = workspace:GetPartBoundsInBox(CFrame.new(posicaoAlvo), Vector3.new(2, 2, 2), params)
	
	if #partesNaParede == 0 then
		
		local esfera = Instance.new("Part")
		esfera.Name         = "Esfera_" .. indice
		esfera.Shape        = Enum.PartType.Ball
		esfera.Size         = Vector3.new(1.5, 1.5, 1.5)
		esfera.Position     = Vector3.new(x, y, z)
		esfera.Anchored     = true
		esfera.CanCollide   = false
		esfera.Material     = Enum.Material.Neon
		esfera.BrickColor   = BrickColor.new("Hot pink")
		esfera.CastShadow   = false
		esfera.Parent       = pasta
		
		local luz = Instance.new("PointLight")
		luz.Color = Color3.fromRGB(255, 0, 251)
		luz.Brightness = 6
		luz.Range = 14
		luz.Parent = esfera
				
		local entrada = {
			parte = esfera,
			baseY = y,
			offset = math.random() * math.pi * 2,
			valor = 1
		}
		
		table.insert(esferasAtivas, entrada)
		esferaNoMapa += 1

		esfera.Touched:Connect(function(outraParte)
			aoTocar(esfera, outraParte, 1, false)
		end)
	else
		warn("[Esferas] Posição foi tirada na colsião da parede no ", linha, coluna)
	end
	
end



local function criarEsferaEspecial()
	local celulas = Dados.obterCelulasAbertas()
	
	for i = #celulas, 2, -1 do
		local j = math.random(1, i)
		celulas[i], celulas[j] = celulas[j], celulas[i]
	end
	
	local posOcupadas = {}
	for _, dados in ipairs(esferasAtivas) do
		table.insert(posOcupadas, dados.parte.Position)
	end
	
	for _, cel in ipairs(celulas) do
		if Dados.posicaoEhValida(cel.posicao, posOcupadas, 15) then
			local esfera = Instance.new("Part")
			esfera.Name         = "EsferaEspecial_" .. contadorEsferas
			esfera.Shape        = Enum.PartType.Ball
			esfera.Size         = Vector3.new(1.5, 1.5, 1.5)
			esfera.Position     = cel.posicao + Vector3.new(0, 4, 0)
			esfera.Anchored     = true
			esfera.CanCollide   = false
			esfera.Material     = Enum.Material.Neon
			esfera.Color   		= Color3.fromRGB(255, 153, 250)
			esfera.Parent       = pasta

			local luz = Instance.new("PointLight")
			luz.Color = Color3.fromRGB(255, 153, 250)
			luz.Brightness = 10
			luz.Range = 14
			luz.Parent = esfera
			
			local entrada = {
				parte = esfera,
				baseY = cel.posicao.Y,
				offset = math.random() * math.pi * 2,
				especial = true,
				valor = 2
			}
			table.insert(esferasAtivas, entrada)
			esferaNoMapa += 1

			esfera.Touched:Connect(function(outraParte)
				aoTocar(esfera, outraParte, 2)
			end)
			return
		end
	end
end

local function devolverEsferas(jogador)
	local status = Dados.statusJogadores[jogador.UserId]
	if not status then return end

	local coletadas = status.esferasColetadas
	if coletadas <= 0 then return end

	local quantidade = math.max(1, math.floor(coletadas * PERCENTUAL_DEVOLUCAO))

	status.esferasColetadas = 0
	status.mudouStatus = true

	for i = 1, quantidade do
		criarEsferaEspecial()
	end

	esferaNoMapa = #esferaAtivas

	for _, jogadorAtual in ipairs(Players:GetPlayers()) do
		local statusAtual = Dados.statusJogadores[jogadorAtual.UserId]
		local minhasColetadas = statusAtual and statusAtual.esferasColetadas or 0
		eventoHUD:FireClient(jogadorAtual, esferasNoMapa, minhasColetadas)
	end
end

Players.PlayerAdded:Connect(function(jogador)
	task.delay(1, function()
		criarEsferaParaNovoJogador()

		local status = Dados.statusJogadores[jogador.UserId]
		local minhasColetadas = status and status.esferasColetadas or 0
		
		for _, jogadorAtual in ipairs(Players:GetPlayers()) do
			local statusAtual = Dados.statusJogadores[jogadorAtual.UserId]
			local coletadas = statusAtual and statusAtual.esferasColetadas or 0
			eventoHUD:FireClient(jogadorAtual, esferasNoMapa, minhasColetadas)
		end
	end)

	jogador.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			devolverEsferas(jogador)
		end)
	end)
end)

for i, pos in ipairs(posicoesEscolhidas) do
	criarEsferaEmLinhaColuna(pos.l, pos.c, i)
end

esferasNoMapa = #esferasAtivas

for _, jogador in ipairs(esferasAtivas) do
	local status = Dados.statusJogadores[jogador.UserId]
	local minhasColetadas = status and status.esferasColetadas or 0
	eventoHUD:FireClient(jogador, esferasNoMapa, minhasColetadas)
end

RunService.Heartbeat:Connect(function()
	local t = tick()
	
	for _, dados in ipairs(esferasAtivas) do
		if dados.parte and dados.par then
			local novoY = dados.baseY + math.sin(t + VELOCIDADE_FLUTUAR + dados.offset) * AMPLITUDE_FLUTUAR
			
			dados.parte.Position = Vector3.new(
				dados.parte.Position.X,
				novoY,
				dados.parte.Position.Z
			)
		end
	end
end) 