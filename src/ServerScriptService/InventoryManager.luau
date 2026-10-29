local InventoryManager = {}
local inventarios = {}

function InventoryManager.Criar(player)
    inventarios[player] = {}
end

function InventoryManager.Adicionar(player, itemNome, quantidade)
    quantidade = quantidade or 1
    local inv = inventarios[player]
    if not inv then return end
    inv[itemNome] = (inv[itemNome] or 0) + quantidade
    return inv[itemNome]
end

function InventoryManager.Remover(player, itemNome, quantidade)
    quantidade = quantidade or 1
    local inv = inventarios[player]
    if not inv or not inv[itemNome] then return false end
    inv[itemNome] = inv[itemNome] - quantidade
    if inv[itemNome] <= 0 then inv[itemNome] = nil end
    return true
end

function InventoryManager.Pegar(player)
    return inventarios[player] or {}
end

function InventoryManager.Limpar(player)
    inventarios[player] = nil
end

return InventoryManager