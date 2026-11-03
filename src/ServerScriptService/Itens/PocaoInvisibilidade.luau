local PocaoInvisibilidade = {}

local DURACAO_POCAO = 20

local efeitosAtivos = {}

function PocaoInvisibilidade.Usar(player)
    if efeitosAtivos[player] then
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then
        return
    end

    efeitosAtivos[player] = true
    local originalTransparency = {}

    for _, object in ipairs(char:GetDescendants()) do
        if object:IsA("BasePart") then
            originalTransparency[object] = object.Transparency
            object.Transparency = 1
        elseif object:IsA("Decal") then
            originalTransparency[object] = object.Transparency
            object.Transparency = 1
        end
    end

    print(player.Name .. " ficou invisível! dunada vei. duneida vei")

    task.delay(DURACAO_POCAO, function()
            for object, transparency in pairs(originalTransparency) do
                if object.Parent then
                    object.Transparency = transparency
            end
        end
        efeitosAtivos[player] = nil

        print(player.Name .. " apareceu dunada vei. duneida vei")
    end)
end

return PocaoInvisibilidade