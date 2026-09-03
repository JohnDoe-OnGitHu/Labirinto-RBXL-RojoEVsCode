local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DadosLoja = require(ReplicatedStorage:WaitForChild("DadosLoja"))
local DadosLabirinto = require(ReplicatedStorage:WaitForChild("DadosLabirinto"))

local eventoCompra = ReplicatedStorage:FindFirstChild("EventoCompra") or Instance.new("RemoteEvent", ReplicatedStorage)
local eventoColetar = ReplicatedStorage:WaitForChild("EventoColetarItem")

local function entregarItens(player, nomeItem, imagem, quantidade)
	for i = 1, quantidade do
		eventoColetar:FireClient(player, nomeItem, imagem)
	end
	print("📦 mercadoblox!! O jogador " .. player.Name .. " comprou " .. quantidade .. "x " .. nomeItem)
end
eventoCompra.OnServerEvent:Connect(function(player, nomeItem, quantidade, metodo)
	quantidade = math.max(1, math.floor(quantidade or 1))
	local itemInfo = nil
	for _, item in ipairs(DadosLoja.Itens) do
		if item.Nome == nomeItem then
			itemInfo = item
			break
		end
	end

	if not itemInfo then
		return
	end

    -- Tipo de Pagamento: Esfera

    if metodo == "Esfera" then
       local precoTotalEsferas = (itemInfo.PrecoEsferas or 0) * quantidade
       local status = DadosLabirinto.statusJogadores[player.UserId]
       
       if status and status.esferasColetadas >= precoTotalEsferas then
        DadosLabirinto.coletarEsfera(player.UserId, -precoTotalEsferas)
        entregarItens(player, itemInfo.Nome, itemInfo.Imagem, quantidade)
       else
        warn("O jogador " .. player.Name .. " não tem esferas suficientes para comprar " .. quantidade .. "x " .. nomeItem)
       end
       
        -- Tipo de Pagamento: Robux

       elseif metodo == "Robux" then
        if itemInfo.ProductId and itemInfo.Product > 0 then
            MarketplaceService:PromptProductPurchase(player, itemInfo.ProductID)
        else
            warn("O item " .. nomeItem .. " não tem um ProductId válido para compra com Robux.")
        end
    end
end)


