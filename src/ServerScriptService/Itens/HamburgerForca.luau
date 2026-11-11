local HamburgerForca = {}

local QUANTIDADE_GOLPE = 5

function HamburgerForca.Usar(player)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or hum.Health <= 0 then
        return
    end

    local forcaOriginal = player:GetAttribute("Forca") or 0

    player:SetAttribute("Forca", forcaOriginal + QUANTIDADE_GOLPE)

    print(player.Name .. " ganhou +100% de força por 30 segundos!")
end

return HamburgerForca