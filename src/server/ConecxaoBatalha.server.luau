local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GerenciadorArmas = require(game.ServerScriptService.GerenciadorArmas)
local eventoGolpe = ReplicatedStorage:WaitForChild("GolpeEspada")

-- Ouve oque o CLIENT pede pro SERVER.
eventoGolpe.OnServerEvent:Connect(function(jogador, perseguidorAlvo)
	GerenciadorArmas.registrarGolpe(jogador, perseguidorAlvo)
end)