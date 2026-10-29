local PocaoVelocidade = {}

local VELOCIDADE_POCAO = 32
local DURACAO_POCAO = 30

local efeitosAtivos = {}

function PocaoVelocidade.Usar(player)
    if efeitosAtivos[player] then
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        return
    end

    local velOriginal = hum.WalkSpeed

    efeitosAtivos[player] = true
    hum.WalkSpeed = VELOCIDADE_POCAO

    print("GOTTA GO FAST! tuninuninu, o " .. player.Name .. " virou o sonic e a velocidade dele virou " .. VELOCIDADE_POCAO)

    task.delay(DURACAO_POCAO, function()
        if hum and hum.Parent == char then
            hum.WalkSpeed = velOriginal
        end
        efeitosAtivos[player] = nil

        print("o player parou de virar o sonic ):, a velocidade dele voltou para " .. velOriginal)
    end)
end

return PocaoVelocidade