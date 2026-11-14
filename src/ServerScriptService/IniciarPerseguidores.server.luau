local GerenciadorArmas = require(game.ServerScriptService.GerenciadorArmas)

local Gerenciador = require(game.ServerScriptService.GerenciadorPerseguidores)
task.wait(5) -- espera o labirinto gerar
GerenciadorArmas.spawnar()
print("[ MODO BETA ] As armas foram ativadas. Os perseguidores foram desativados.")
Gerenciador.iniciar()