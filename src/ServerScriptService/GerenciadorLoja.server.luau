local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DadosLoja = require(ReplicatedStorage:WaitForChild("DadosLoja"))
local DadosLabirinto = require(ReplicatedStorage:WaitForChild("DadosLabirinto"))
local InventoryManager = require(game.ServerScriptService:WaitForChild("InventoryManager"))

local eventoCompra = Instance.new("RemoteEvent")
eventoCompra.Name = "EventoCompra"
eventoCompra.Parent = ReplicatedStorage

eventoCompra.OnServerEvent:Connect(function(player, nomeItem)
    local infoItem = nil
    for _, item in ipairs(DadosLoja.Itens) do
        if item.Nome == nomeItem then infoItem = item; break end
    end
    
    if not infoItem then return end

    -- Moedas

    local moedasAtuais = DadosLabirinto.statusJogadores[player.UserId].esferasColetadas
    if moedasAtuais < infoItem.Preco then
        eventoCompra:FireClient(player, "Erro", "ta pobre")
        return
    end

    -- ve os slots
    
    local inventarioAtual = InventoryManager.ObterInventario(player)
    local jaPossui = table.find(inventarioAtual, nomeItem)

    if not jaPossui and #inventarioAtual >= DadosLoja.MAX_SLOTS then
        eventoCompra:FireClient(player, "AvisoSlot", "seus bolsos ta cheio mermao")
        return
    end

    DadosLabirinto.coletarEsfera(player.UserId, -infoItem.Preco)
    InventoryManager.AdicionarItem(player, nomeItem)

    eventoCompra:FireClient(player, "Sucesso", "comprou o item " .. nomeItem)
end)