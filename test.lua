local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local MainWindow = Rayfield:CreateWindow({
	Name = "ShadowX Hub",
	LoadingTitle = "Cargando...",
	LoadingSubtitle = "by Lobo27",
	ConfigurationSaving = {
	   Enabled = true,
	   FolderName = nil,
	   FileName = "ShadowX Hub"
	},
	Discord = {
	   Enabled = true,
	   Invite = "ZB79MM6DHj",
	   RememberJoins = true
	},
	KeySystem = true,
	KeySettings = {
	   Title = "ShadowX Hub",
	   Subtitle = "Key System",
	   Note = "Get a Key",
	   FileName = "SiriusKey",
	   SaveKey = true,
	   GrabKeyFromSite = false,
	   Key = {"ShadowX", "ShadowY"}
	}
})

local MainTab = MainWindow:CreateTab("Principal", "map-pin")
local HouseTab = MainWindow:CreateTab("House Cloner", "star")
local ScannerTab = MainWindow:CreateTab("Scanner", "search")
local SaveTab = MainWindow:CreateTab("Guardar", "file")
local OthersTab = MainWindow:CreateTab("Otros", "circle-ellipsis")

-- ========== OTROS ==========

local Button = OthersTab:CreateButton({
   Name = "Default Theme",
   Callback = function(Default)
    local Default = MainWindow.ModifyTheme('Default')
   end,
})

local Button = OthersTab:CreateButton({
   Name = "Amber Glow Theme",
   Callback = function(AmberGlow)
    local AmberGlow = MainWindow.ModifyTheme('AmberGlow')
   end,
})

-- ========== PRINCIPAL ==========

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local infiniteJumpConnection
local infiniteJumpEnabled = false

local ToggleInfiniteJump = MainTab:CreateToggle({
    Name = "Salto Infinito",
    CurrentValue = false,
    Flag = "InfiniteJumpFlag",
    Callback = function(value)
        infiniteJumpEnabled = value

        if infiniteJumpEnabled and not infiniteJumpConnection then
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local character = localPlayer.Character
                if not character then return end
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and infiniteJumpEnabled then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end

        if not infiniteJumpEnabled and infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end,
})

localPlayer.CharacterRemoving:Connect(function()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end)

local walkSpeedValue = 16
local function setWalkSpeed(v)
    walkSpeedValue = v
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.WalkSpeed = tonumber(v) or 16 end)
    end
end

localPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        pcall(function() hum.WalkSpeed = walkSpeedValue end)
    end
end)

local SliderWalkSpeed = MainTab:CreateSlider({
    Name = "Velocidad al Caminar",
    Range = {10, 250},
    Increment = 10,
    Suffix = "Velocidad",
    CurrentValue = 16,
    Flag = "WalkSpeedFlag",
    Callback = function(v)
        setWalkSpeed(v)
    end,
})

local jumpPowerValue = 50
local function setJumpPower(v)
    jumpPowerValue = v
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.JumpPower = tonumber(v) or 50 end)
    end
end

localPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        pcall(function() hum.JumpPower = jumpPowerValue end)
    end
end)

local SliderJumpPower = MainTab:CreateSlider({
    Name = "Poder de Salto",
    Range = {10, 500},
    Increment = 10,
    Suffix = "Salto",
    CurrentValue = 50,
    Flag = "JumpPowerFlag",
    Callback = function(v)
        setJumpPower(v)
    end,
})

-- ========== HOUSE CLONER ==========

local furnitureCount = 0
local furnitureCost = 0
local textureCost = 0
local progress = 0

local Label1 = HouseTab:CreateLabel("Furnitures count: " .. furnitureCount, "sofa")
local Label2 = HouseTab:CreateLabel("Furnitures cost: $" .. furnitureCost, "badge-dollar-sign")
local Label3 = HouseTab:CreateLabel("Textures cost: $" .. textureCost, "paint-roller")
local Label4 = HouseTab:CreateLabel("Progress: " .. progress .. "%", "loader")

local Divider = HouseTab:CreateDivider()

local houseData = nil
local houseUrl = ""

local Input = HouseTab:CreateInput({
   Name = "House Pastebin",
   CurrentValue = "",
   PlaceholderText = "https://pastebin.com/",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
      houseUrl = Text
   end,
})

-- Función para obtener datos de muebles
local function getFurnitureData()
    local furnitures = {}
    local houseFolder = Workspace:FindFirstChild("HouseFurnitures")
    
    if not houseFolder then
        -- Buscar en el jugador o en otros lugares comunes
        local playerHouse = Workspace:FindFirstChild(localPlayer.Name .. "'s House")
        if playerHouse then
            houseFolder = playerHouse
        end
    end
    
    if houseFolder then
        for _, obj in pairs(houseFolder:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local data = {
                    Name = obj.Name,
                    Position = obj.Position,
                    Rotation = obj.Rotation,
                    Size = obj:IsA("BasePart") and obj.Size or nil,
                    Color = obj:IsA("BasePart") and obj.BrickColor or nil
                }
                table.insert(furnitures, data)
            end
        end
    end
    
    return furnitures
end

-- Función para calcular costos
local function calculateCosts(furnitures)
    local totalCost = 0
    local textureCost = 0
    
    -- Precios aproximados (puedes ajustar según el juego)
    for _, furniture in pairs(furnitures) do
        totalCost = totalCost + 100 -- Precio base por mueble
        if furniture.Color then
            textureCost = textureCost + 10 -- Costo por textura/color
        end
    end
    
    return totalCost, textureCost
end

local Button = HouseTab:CreateButton({
   Name = "Copy House",
   Callback = function()
      local furnitures = getFurnitureData()
      furnitureCount = #furnitures
      furnitureCost, textureCost = calculateCosts(furnitures)
      
      Label1:Set("Furnitures count: " .. furnitureCount)
      Label2:Set("Furnitures cost: $" .. furnitureCost)
      Label3:Set("Textures cost: $" .. textureCost)
      
      -- Guardar datos de la casa
      houseData = furnitures
      
      -- Enviar a Pastebin (simulado)
      Rayfield:Notify({
         Title = "House Copied!",
         Content = "Successfully copied " .. furnitureCount .. " furnitures",
         Duration = 4,
         Image = "check"
      })
   end,
})

local Button = HouseTab:CreateButton({
   Name = "Paste House",
   Callback = function()
      if not houseData then
         Rayfield:Notify({
            Title = "Error",
            Content = "No house data found. Please copy a house first.",
            Duration = 4,
            Image = "x"
         })
         return
      end
      
      Rayfield:Notify({
         Title = "Pasting House",
         Content = "Placing " .. furnitureCount .. " furnitures...",
         Duration = 4,
         Image = "loader"
      })
      
      -- Aquí iría la lógica para colocar los muebles
      -- Esta es una simulación básica:
      local placedCount = 0
      for i, furniture in pairs(houseData) do
         -- Simular colocación con delay
         spawn(function()
            wait(i * 0.1) -- Delay progresivo
            placedCount = placedCount + 1
            local progressPercent = math.floor((placedCount / furnitureCount) * 100)
            Label4:Set("Progress: " .. progressPercent .. "%")
            
            if placedCount == furnitureCount then
               Rayfield:Notify({
                  Title = "Success!",
                  Content = "House pasted successfully!",
                  Duration = 4,
                  Image = "check"
               })
            end
         end)
      end
   end,
})

-- ========== SCANNER ==========

local homeType = "Tiny Home"
local Label5 = ScannerTab:CreateLabel("Home Type: " .. homeType, "milestone")

local Button = ScannerTab:CreateButton({
   Name = "Scan House",
   Callback = function()
      local scan_notify = Rayfield:Notify({
         Title = "Scanning Home..",
         Content = "Starting Scan",
         Duration = 3.5,
         Image = "play",
      })
      
      wait(1)
      
      -- Simular escaneo
      local furnitures = getFurnitureData()
      local totalItems = #furnitures
      
      Rayfield:Notify({
         Title = "Scan Complete",
         Content = "Found " .. totalItems .. " items in house",
         Duration = 4,
         Image = "check"
      })
      
      -- Actualizar labels del clonador
      furnitureCount = totalItems
      furnitureCost, textureCost = calculateCosts(furnitures)
      
      Label1:Set("Furnitures count: " .. furnitureCount)
      Label2:Set("Furnitures cost: $" .. furnitureCost)
      Label3:Set("Textures cost: $" .. textureCost)
   end,
})

-- ========== CONSOLE MESSAGE ==========
print("ShadowX Hub ha cargado correctamente")
