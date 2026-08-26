local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DadosLoja = require(ReplicatedStorage:WaitForChild("DadosLoja"))
local DadosLabirinto = require(ReplicatedStorage:WaitForChild("DadosLabirinto"))

local eventoCompra = ReplicatedStorage:FindFirstChild("EventoCompra") or
        Instance.new("RemoteEvent", ReplicatedStorage)
eventoCompra.Name = "EventoCompra"

eventoCompra.OnServerEvent:Connect(function(player, nomeItem)
    local itemInfo = nil
    for _, item in ipairs(DadosLoja.Itens) do
        if item.Nome == nomeItem then
            itemInfo = item
            break
        end
    end

    if not itemInfo then return end

    local status = DadosLabirinto.statusJogadores[player.UserId]
    if status and status.esferasColetadas >= itemInfo.PrecoEsferas then

        DadosLabirinto.coletarEsfera(player.UserId, -itemInfo.PrecoEsferas)

        local eventoColeta = ReplicatedStorage:WaitForChild("EventoColetarItem")
        eventoColeta:FireClient(player, itemInfo.Nome, itemInfo.Imagem)

        print("ganhamo dindin vamo boraaa o " .. player.Name .. " comprou o item " .. nomeItem)
    else
        warn("tava quase mas o " .. player.Name .. " não tem esferas suficientes para comprar o item " .. nomeItem)
    end
end)