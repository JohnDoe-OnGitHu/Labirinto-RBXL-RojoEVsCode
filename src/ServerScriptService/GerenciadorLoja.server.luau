local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DadosLoja = require(ReplicatedStorage:WaitForChild("DadosLoja"))
local DadosLabirinto = require(ReplicatedStorage:WaitForChild("DadosLabirinto"))

local eventoCompra = ReplicatedStorage:FindFirstChild("EventoCompra") or Instance.new("RemoteEvent", ReplicatedStorage)
eventoCompra.Name = "EventoCompra"

local eventoColeta = ReplicatedStorage:WaitForChild("EventoColetarItem")

eventoCompra.OnServerEvent:Connect(function(player, nomeItem, quantidade, metodo)
    quantidade = math.max(1, math.floor(quantidade or 1))

    local itemInfo = nil
    for _, item in ipairs(DadosLoja.Itens) do
        if item.Nome == nomeItem then itemInfo = item; break end
    end
    
    if not itemInfo then return end

    -- Tipo de Pagamento: Esfera

    local precoTotal = (itemInfo.PrecoEsferas or 0) * quantidade
    local status = DadosLabirinto.statusJogadores[player.UserId]

    if status and status.esferasColetadas >= precoTotal then
        DadosLabirinto.coletarEsfera(player.UserId, -precoTotal)

        for i = 1, quantidade do
            eventoColeta:FireClient(player, itemInfo.Name, itemInfo.Imagem)
        end
    else
        warn("sem dindin")
    end
end)