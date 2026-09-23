-- ============================================================
-- SCRIPT: LojaInterface
-- LOCAL: StarterPlayerScripts.UI.LojaInterface.client.luau
-- O QUE FAZ: Cria e gerencia a interface da loja moderna.
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Módulos e Eventos
local DadosLoja = require(ReplicatedStorage:WaitForChild("DadosLoja"))
local eventoCompra = ReplicatedStorage:WaitForChild("EventoCompra")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── CONFIGURAÇÕES VISUAIS ───────────────────────────────────
local COR_AZUL_NEON = Color3.fromRGB(0, 51, 255)
local COR_ROBUX = Color3.fromRGB(255, 166, 0)
local COR_ESFERA = Color3.fromRGB(169, 20, 0)
local COR_FUNDO = Color3.fromRGB(0, 0, 0)
local TRANSPARENCIA_FUNDO = 0.4

-- ── CRIAÇÃO DA ESTRUTURA BASE ───────────────────────────────
-- ── ESTRUTURA BASE ──────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LojaGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "JanelaLoja"
mainFrame.Size = UDim2.fromScale(0.65, 0.7)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = COR_FUNDO
mainFrame.BackgroundTransparency = TRANSPARENCIA_FUNDO
mainFrame.Visible = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0.02, 0)
local borda = Instance.new("UIStroke", mainFrame)
borda.Color = COR_AZUL_NEON
borda.Thickness = 2

local titulo = Instance.new("TextLabel")
titulo.Text = "✦ MERCADO DO LABIRINTO ✦"
titulo.Size = UDim2.new(1, 0, 0.1, 0)
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.BackgroundTransparency = 1
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 24
titulo.Parent = mainFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.95, 0, 0.85, 0)
scroll.Position = UDim2.new(0.025, 0, 0.12, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = COR_AZUL_NEON
scroll.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 190, 0, 240) -- Altura reduzida pois botões estão na mesma linha
gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.Parent = scroll

local tooltip = Instance.new("TextLabel")
tooltip.Size = UDim2.new(0, 220, 0, 60)
tooltip.BackgroundColor3 = Color3.new(0, 0, 0)
tooltip.BackgroundTransparency = 0.2
tooltip.TextColor3 = Color3.new(1, 1, 1)
tooltip.TextWrapped = true
tooltip.Font = Enum.Font.Gotham
tooltip.TextSize = 14
tooltip.Visible = false
tooltip.ZIndex = 10
tooltip.Parent = screenGui
Instance.new("UICorner", tooltip)
Instance.new("UIStroke", tooltip).Color = COR_AZUL_NEON

-- ── FUNÇÃO: CRIAR CARD DE ITEM ─────────────────────────────
local function criarCardItem(itemInfo)
	local card = Instance.new("Frame")
	card.Name = itemInfo.Nome
	card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	card.BackgroundTransparency = 0.3
	card.Parent = scroll
	Instance.new("UICorner", card)
	
	-- Imagem do Item
	local img = Instance.new("ImageLabel")
	img.Name = "Icone"
	img.Size = UDim2.fromScale(0.6, 0.45)
	img.Position = UDim2.fromScale(0.2, 0.05)
	img.Image = itemInfo.Imagem or "rbxassetid://0"
	img.BackgroundTransparency = 1
	img.Parent = card

	-- Nome
	local nome = Instance.new("TextLabel")
	nome.Text = itemInfo.Nome:upper()
	nome.Size = UDim2.new(1, 0, 0.15, 0)
	nome.Position = UDim2.fromScale(0, 0.5)
	nome.TextColor3 = Color3.new(1, 1, 1)
	nome.Font = Enum.Font.GothamBold
	nome.TextScaled = true
	nome.BackgroundTransparency = 1
	nome.Parent = card

	-- Seletor de Quantidade (Mais fino)
	local qtd = 1
	local seletorFrame = Instance.new("Frame")
	seletorFrame.Size = UDim2.new(0.8, 0, 0.1, 0)
	seletorFrame.Position = UDim2.fromScale(0.1, 0.6)
	seletorFrame.BackgroundTransparency = 0.8
	seletorFrame.BackgroundColor3 = Color3.new(1,1,1)
	seletorFrame.Parent = card
	
	local lblQtd = Instance.new("TextLabel")
	lblQtd.Text = "Qtd: 1"
	lblQtd.Size = UDim2.fromScale(0.6, 1)
	lblQtd.Position = UDim2.fromScale(0.2, 0)
	lblQtd.TextColor3 = Color3.new(1,1,1)
	lblQtd.TextSize = 15
	lblQtd.BackgroundTransparency = 1
	lblQtd.Font = Enum.Font.GothamBold
	lblQtd.Parent = seletorFrame

	local btnMais = Instance.new("TextButton")
	btnMais.Text = "+"
	btnMais.Size = UDim2.fromScale(0.2, 1)
	btnMais.Position = UDim2.fromScale(0.8, 0)
	btnMais.TextColor3 = Color3.new(1,1,1)
	btnMais.BackgroundTransparency = 0.5
	btnMais.Parent = seletorFrame

	local btnMenos = Instance.new("TextButton")
	btnMenos.Text = "-"
	btnMenos.Size = UDim2.fromScale(0.2, 1)
	btnMenos.Position = UDim2.fromScale(0, 0)
	btnMenos.TextColor3 = Color3.new(1,1,1)
	btnMenos.BackgroundTransparency = 0.5
	btnMenos.Parent = seletorFrame

	-- Botão Comprar (Esferas)
	local btnComprar = Instance.new("TextButton")
	-- Se itemInfo.PrecoEsferas não existir, ele usa 0
    btnComprar.Text = "🛒 " .. (itemInfo.PrecoEsferas or 0) .. " Esferas"
	btnComprar.Size = UDim2.new(0.9, 0, 0.15, 0)
	btnComprar.Position = UDim2.fromScale(0.05, 0.82)
	btnComprar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	btnComprar.TextColor3 = Color3.new(1, 1, 1)
	btnComprar.Font = Enum.Font.GothamBold
	btnComprar.Parent = card
	Instance.new("UICorner", btnComprar)

	-- ── CONTAINER DOS BOTÕES (LADO A LADO) ──
	local botoesFrame = Instance.new("Frame")
	botoesFrame.Size = UDim2.new(0.9, 0, 0.18, 0)
	botoesFrame.Position = UDim2.fromScale(0.05, 0.75)
	botoesFrame.BackgroundTransparency = 1
	botoesFrame.Parent = card

	-- Botão de Esfera
	local btnEsfera = Instance.new("TextButton")
	btnEsfera.Text = "" -- Deixamos o texto do botão vazio para controlar os elementos dentro dele
	btnEsfera.Size = UDim2.new(0.48, 0, 1, 0)
	btnEsfera.Position = UDim2.fromScale(0, 0)
	btnEsfera.BackgroundColor3 = COR_ESFERA
	btnEsfera.Parent = botoesFrame
	Instance.new("UICorner", btnEsfera)
	
	-- 🟢 ÍCONE DA ESFERA (Controla o tamanho do emoji)
	local iconeEsfera = Instance.new("TextLabel")
	iconeEsfera.Text = "🔴"
	iconeEsfera.Size = UDim2.fromScale(0.3, 0.6) -- 30% da largura do botão, 60% da altura
	iconeEsfera.Position = UDim2.fromScale(0.05, 0.2) -- Margemzinha da esquerda e topo
	iconeEsfera.BackgroundTransparency = 1
	iconeEsfera.TextScaled = true -- Deixa o emoji proporcional ao tamanho que você definiu na Size acima
	iconeEsfera.Parent = btnEsfera

	-- 🟢 TEXTO DO PREÇO DA ESFERA (Controla o tamanho do texto do preço)
	local textoEsfera = Instance.new("TextLabel")
	textoEsfera.Text = tostring(itemInfo.PrecoEsferas or 0)
	textoEsfera.Size = UDim2.fromScale(0.6, 0.6) -- Ocupa 60% da largura do botão
	textoEsfera.Position = UDim2.fromScale(0.35, 0.2) -- Começa logo após o ícone
	textoEsfera.BackgroundTransparency = 1
	textoEsfera.TextColor3 = Color3.new(1, 1, 1)
	textoEsfera.Font = Enum.Font.GothamBold
	textoEsfera.TextScaled = true -- Ajusta o texto perfeitamente dentro do tamanho acima
	textoEsfera.TextXAlignment = Enum.TextXAlignment.Left -- Alinha o preço à esquerda, perto do ícone
	textoEsfera.Parent = btnEsfera

	-- Botão de Robux
	local btnRobux = Instance.new("TextButton")
	btnRobux.Text = "" -- Deixamos vazio também
	btnRobux.Size = UDim2.new(0.48, 0, 1, 0)
	btnRobux.Position = UDim2.fromScale(0.52, 0)
	btnRobux.BackgroundColor3 = COR_ROBUX
	btnRobux.Parent = botoesFrame
	Instance.new("UICorner", btnRobux)

	-- 🟢 ÍCONE DO ROBUX
	local iconeRobux = Instance.new("TextLabel")
	iconeRobux.Text = ""
	iconeRobux.Size = UDim2.fromScale(0.3, 0.6) -- Mesmo tamanho do ícone de esfera
	iconeRobux.Position = UDim2.fromScale(0.05, 0.2)
	iconeRobux.BackgroundTransparency = 1
	iconeRobux.TextScaled = true
	iconeRobux.Parent = btnRobux

	-- 🟢 TEXTO DO PREÇO DO ROBUX
	local textoRobux = Instance.new("TextLabel")
	textoRobux.Text = tostring(itemInfo.PrecoRobux or 0)
	textoRobux.Size = UDim2.fromScale(0.6, 0.6)
	textoRobux.Position = UDim2.fromScale(0.35, 0.2)
	textoRobux.BackgroundTransparency = 1
	textoRobux.TextColor3 = Color3.new(1, 1, 1)
	textoRobux.Font = Enum.Font.GothamBold
	textoRobux.TextScaled = true
	textoRobux.TextXAlignment = Enum.TextXAlignment.Left
	textoRobux.Parent = btnRobux

    -- LOGICA DO ATUALIZAÇÃO
	local function atualizarPrecos()
		lblQtd.Text = "Qtd: " .. qtd
		textoEsfera.Text = tostring((itemInfo.PrecoEsferas or 0) * qtd)
		textoRobux.Text = tostring((itemInfo.PrecoRobux or 0) * qtd)
	end

    btnMais.MouseButton1Click:Connect(function()
        qtd = math.max(qtd + 1, 99)
        atualizarPrecos()
    end)

    btnMenos.MouseButton1Click:Connect(function()
        qtd = math.max(qtd - 1, 1)
        atualizarPrecos()
    end)

	btnEsfera.MouseButton1Click:Connect(function()
		eventoCompra:FireServer(itemInfo.Nome, qtd, "Esfera")
	end)

	btnRobux.MouseButton1Click:Connect(function()
		eventoCompra:FireServer(itemInfo.Nome, qtd, "Robux")
	end)

    card.MouseEnter:Connect(function()
        tooltip.Text = itemInfo.Descricao
        tooltip.Visible = true
    end)
	card.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)
end

for _, item in ipairs(DadosLoja.Itens) do
    criarCardItem(item)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        mainFrame.Visible = not mainFrame.Visible
        tooltip.Visible = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        tooltip.Position = UDim2.new(0, input.Position.X + 20, 0, input.Position.Y + 20)
    end
end)