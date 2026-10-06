local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- A Interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUDEsferas"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.18, 0.14)
frame.Position = UDim2.fromScale(0.01, 0.01)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Arredonda o fundo
local canto = Instance.new("UICorner")
canto.CornerRadius = UDim.new(0.15, 0)
canto.Parent = frame

-- Layout
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0.05, 0)
layout.Parent = frame

-- Titulo
local labelTitulo = Instance.new("TextLabel")
labelTitulo.Size = UDim2.fromScale(1, 0.3)
labelTitulo.BackgroundTransparency = 1
labelTitulo.TextColor3 = Color3.fromHex("#ff4d4d")
labelTitulo.TextScaled = true
labelTitulo.Font = Enum.Font.GothamBold
labelTitulo.Text = "🔴Esferas"
labelTitulo.Parent = frame

-- Global
local labelGlobal = Instance.new("TextLabel")
labelGlobal.Size = UDim2.fromScale(1, 0.3)
labelGlobal.BackgroundTransparency = 1
labelGlobal.TextColor3 = Color3.fromHex("#ffffff")
labelGlobal.TextScaled = true
labelGlobal.Font = Enum.Font.GothamBold
labelGlobal.Text = "👤 ? / ?"
labelGlobal.Parent = frame

-- ── Escuta o evento do servidor ──────────────────────────────
-- OnClientEvent dispara toda vez que o servidor chamar FireAllClients
-- Os parâmetros chegam na mesma ordem que foram enviados
-- ── Escuta o evento do servidor ──────────────────────────────

local eventoHUD = ReplicatedStorage:WaitForChild("AtualizarEsferas")

eventoHUD.OnClientEvent:Connect(function(esferasNoMapa, minhasColetadas)
	if esferasNoMapa then
		labelGlobal.Text = "👤 " .. minhasColetadas .. " / " .. esferasNoMapa
	end
end)