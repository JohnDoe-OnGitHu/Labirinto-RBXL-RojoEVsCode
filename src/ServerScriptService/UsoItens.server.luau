local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pastaItens = script.Parent:WaitForChild("Itens")

local PocaoVelocidade = require(pastaItens:WaitForChild("PocaoVelocidade"))

local eventoUsar = ReplicatedStorage:FindFirstChild("EventoUsarItem")

if not eventoUsar then
    eventoUsar = Instance.new("RemoteEvent")
    eventoUsar.Name = "EventoUsarItem"
    eventoUsar.Parent = ReplicatedStorage
end

local itens = {
    ["Poção de Velocidade"] = PocaoVelocidade,
}

eventoUsar.OnServerEvent:Connect(function(player, nomeItem)
    if typeof(nomeItem) ~= "string" then
        return
    end

    local item = itens[nomeItem]

    if not item then
        warn("Perdido. O item '" .. nomeItem .. "' não foi encontrado. se tiver alguma evidencia de onde ele esta. por favor ligue 99-MED-AROBUX")
        return
    end
    
end)