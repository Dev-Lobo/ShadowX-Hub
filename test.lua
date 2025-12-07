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
local HttpService = game:GetService("HttpService")
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

-- Base de datos de precios de muebles (valores aproximados)
local furniturePrices = {
    ["brick"] = 50,
    ["medium_disk"] = 75,
    ["plainmound_v1"] = 100,
    ["fancytrashcan"] = 150,
    ["torus_v3_plain"] = 80,
    ["beam_v1_plain"] = 120,
    ["sofa"] = 200,
    ["table"] = 150,
    ["chair"] = 100,
    ["bed"] = 250,
    ["lamp"] = 80,
    ["plant"] = 60,
    ["picture"] = 70,
    ["rug"] = 120,
    ["tv"] = 300,
    ["kitchen"] = 400,
    ["bathroom"] = 180,
    ["default"] = 50
}

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

-- Función para convertir CFrame a array (formato específico de Adopt Me)
local function cframeToArray(cf)
    local pos = cf.Position
    local x, y, z = pos.X, pos.Y, pos.Z
    
    -- Extraer componentes de la matriz de transformación
    local _, _, _, m03, m10, m11, m12, m13, m20, m21, m22, m23 = cf:components()
    local m00, m01, m02 = cf.XVector.X, cf.XVector.Y, cf.XVector.Z
    local m10, m11, m12 = cf.YVector.X, cf.YVector.Y, cf.YVector.Z  
    local m20, m21, m22 = cf.ZVector.X, cf.ZVector.Y, cf.ZVector.Z
    
    return {x, y, z, m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23}
end

-- Función para obtener el tipo de casa
local function getBuildingType()
    -- Buscar la casa del jugador
    local playerHouse = Workspace:FindFirstChild(localPlayer.Name .. "'s House")
    if playerHouse then
        -- Determinar tipo basado en el nombre o estructura
        local houseName = playerHouse.Name:lower()
        if houseName:find("mansion") then
            return "Mansion"
        elseif houseName:find("large") or houseName:find("big") then
            return "Large Home"
        else
            return "Tiny Home"
        end
    end
    
    -- Buscar estructura de casa en el workspace
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name == "HouseFurnitures" or child.Name:find("House") then
            local size = child:GetExtents(true).Size
            if size and size.Magnitude > 100 then
                return "Mansion"
            elseif size and size.Magnitude > 50 then
                return "Large Home"
            else
                return "Tiny Home"
            end
        end
    end
    
    return "Tiny Home"
end

-- Función para identificar si un objeto es un mueble válido
local function isValidFurniture(obj)
    if not obj then return false end
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return false end
    if obj.Name == "HumanoidRootPart" or obj.Name == "Torso" or obj.Name == "Head" then return false end
    if obj:IsA("Seat") then return false end
    
    -- Para BasePart, verificar que esté anclado (muebles típicamente anclados)
    if obj:IsA("BasePart") then
        if obj.Anchored == false then return false end
        -- Excluir partes del entorno como suelo, paredes, etc.
        if obj.Name:lower():find("ground") or obj.Name:lower():find("floor") or 
           obj.Name:lower():find("wall") or obj.Name:lower():find("roof") then
            return false
        end
    end
    
    return true
end

-- Función para obtener el ID del mueble
local function getFurnitureId(obj)
    if not obj then return "unknown" end
    
    local name = obj.Name:lower()
    
    -- Limpiar nombre de prefijos/sufijos comunes
    name = name:gsub("furniture_", ""):gsub("_furniture", "")
    name = name:gsub("item_", ""):gsub("_item", "")
    name = name:gsub("%d+", "") -- Remover números
    
    -- Normalizar nombres comunes
    if name:find("sofa") or name:find("couch") then return "sofa" end
    if name:find("table") then return "table" end
    if name:find("chair") then return "chair" end
    if name:find("bed") then return "bed" end
    if name:find("lamp") then return "lamp" end
    if name:find("plant") then return "plant" end
    if name:find("picture") or name:find("painting") then return "picture" end
    if name:find("rug") or name:find("carpet") then return "rug" end
    if name:find("tv") or name:find("television") then return "tv" end
    if name:find("brick") then return "brick" end
    if name:find("disk") then return "medium_disk" end
    if name:find("mound") then return "plainmound_v1" end
    if name:find("trash") then return "fancytrashcan" end
    if name:find("torus") then return "torus_v3_plain" end
    if name:find("beam") then return "beam_v1_plain" end
    
    -- Si no se reconoce, usar el nombre limpio
    if name == "" then name = "unknown" end
    return name
end

-- Función para obtener colores del mueble
local function getFurnitureColors(obj)
    local colors = {}
    
    if obj:IsA("BasePart") then
        -- Obtener color principal
        local colorValue = nil
        if obj:FindFirstChild("Color") then
            colorValue = obj.Color
        elseif obj:FindFirstChild("BrickColor") then
            colorValue = obj.BrickColor.Color
        else
            colorValue = obj.Color or obj.BrickColor and obj.BrickColor.Color
        end
        
        if colorValue then
            table.insert(colors, {colorValue.R, colorValue.G, colorValue.B})
        else
            -- Color por defecto blanco
            table.insert(colors, {1, 1, 1})
        end
    elseif obj:IsA("Model") then
        -- Para modelos, obtener colores de las partes principales
        for _, part in pairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                local colorValue = part.Color or (part.BrickColor and part.BrickColor.Color)
                if colorValue then
                    table.insert(colors, {colorValue.R, colorValue.G, colorValue.B})
                    break -- Solo el color principal
                end
            end
        end
        
        -- Si no se encontró color, usar blanco
        if #colors == 0 then
            table.insert(colors, {1, 1, 1})
        end
    end
    
    return colors
end

-- Función para calcular escala
local function getFurnitureScale(obj)
    if obj:IsA("BasePart") then
        local avgSize = (obj.Size.X + obj.Size.Y + obj.Size.Z) / 3
        return math.max(0.01, avgSize / 10) -- Normalizar a rango razonable
    elseif obj:IsA("Model") then
        local size = obj:GetExtents(true).Size
        local avgSize = (size.X + size.Y + size.Z) / 3
        return math.max(0.01, avgSize / 10)
    end
    return 1
end

-- Función principal para escanear muebles y convertir al formato específico
local function scanHouseFurniture()
    local furnitureData = {}
    local buildingType = getBuildingType()
    
    -- Buscar muebles en ubicaciones específicas de Adopt Me
    local searchLocations = {
        Workspace:FindFirstChild(localPlayer.Name .. "'s House"),
        Workspace:FindFirstChild("HouseFurnitures"),
        Workspace:FindFirstChild("Furniture"),
        Workspace:FindFirstChild("PlayerHouses"),
    }
    
    -- Añadir también búsqueda directa en el workspace
    table.insert(searchLocations, Workspace)
    
    local furnitureCount = 0
    local totalCost = 0
    local textureCostTotal = 0
    local scannedObjects = {} -- Para evitar duplicados
    
    for _, location in pairs(searchLocations) do
        if location then
            -- Buscar muebles directamente en esta ubicación
            for _, obj in pairs(location:GetChildren()) do
                if isValidFurniture(obj) and not scannedObjects[obj] then
                    scannedObjects[obj] = true
                    
                    furnitureCount = furnitureCount + 1
                    
                    local furnitureId = getFurnitureId(obj)
                    local colors = getFurnitureColors(obj)
                    local cframeArray = cframeToArray(obj.CFrame)
                    local scale = getFurnitureScale(obj)
                    
                    -- Crear ID único para cada mueble
                    local uniqueId = "f-" .. math.random(100, 9999)
                    
                    -- Calcular costos
                    local price = furniturePrices[furnitureId] or furniturePrices["default"]
                    totalCost = totalCost + price
                    
                    if colors and #colors > 0 then
                        textureCostTotal = textureCostTotal + (#colors * 10)
                    end
                    
                    furnitureData[uniqueId] = {
                        colors = colors,
                        id = furnitureId,
                        cframe = cframeArray,
                        scale = scale
                    }
                end
            end
            
            -- Buscar también en descendientes (para modelos complejos)
            for _, obj in pairs(location:GetDescendants()) do
                if isValidFurniture(obj) and not scannedObjects[obj] and obj.Parent ~= location then
                    -- Solo incluir si es un mueble independiente (no parte de otro modelo)
                    if obj.Parent and (obj.Parent:IsA("Folder") or obj.Parent:IsA("Model") and obj.Parent.Name:find("Furniture")) then
                        scannedObjects[obj] = true
                        
                        furnitureCount = furnitureCount + 1
                        
                        local furnitureId = getFurnitureId(obj)
                        local colors = getFurnitureColors(obj)
                        local cframeArray = cframeToArray(obj.CFrame)
                        local scale = getFurnitureScale(obj)
                        
                        local uniqueId = "f-" .. math.random(100, 9999)
                        
                        local price = furniturePrices[furnitureId] or furniturePrices["default"]
                        totalCost = totalCost + price
                        
                        if colors and #colors > 0 then
                            textureCostTotal = textureCostTotal + (#colors * 10)
                        end
                        
                        furnitureData[uniqueId] = {
                            colors = colors,
                            id = furnitureId,
                            cframe = cframeArray,
                            scale = scale
                        }
                    end
                end
            end
        end
    end
    
    local houseDataFormatted = {
        building_type = buildingType,
        furniture = furnitureData
    }
    
    return houseDataFormatted, furnitureCount, totalCost, textureCostTotal
end

-- Función para calcular costos totales
local function calculateTotalCost(furnitureData)
    local furnitureCost = 0
    local textureCost = 0
    
    for _, furniture in pairs(furnitureData.furniture) do
        local price = furniturePrices[furniture.id] or furniturePrices["default"]
        furnitureCost = furnitureCost + price
        
        if furniture.colors and #furniture.colors > 0 then
            textureCost = textureCost + (#furniture.colors * 10)
        end
    end
    
    return furnitureCost, textureCost
end

local Button = HouseTab:CreateButton({
   Name = "Copy House",
   Callback = function()
      Rayfield:Notify({
         Title = "Scanning House",
         Content = "Please wait...",
         Duration = 2,
         Image = "loader"
      })
      
      wait(1)
      
      local houseDataFormatted, count, cost, texCost = scanHouseFurniture()
      
      if count > 0 then
         furnitureCount = count
         furnitureCost = cost
         textureCost = texCost
         houseData = houseDataFormatted
         
         Label1:Set("Furnitures count: " .. furnitureCount)
         Label2:Set("Furnitures cost: $" .. furnitureCost)
         Label3:Set("Textures cost: $" .. textureCost)
         
         Rayfield:Notify({
            Title = "House Copied!",
            Content = "Successfully copied " .. furnitureCount .. " furnitures",
            Duration = 4,
            Image = "check"
         })
         
         -- Mostrar datos en consola para debug
         print("House Data JSON:")
         local jsonData = HttpService:JSONEncode(houseDataFormatted)
         print(jsonData)
         
         -- Guardar en clipboard si es posible
         pcall(function()
            if setclipboard then
                setclipboard(jsonData)
                print("Data copied to clipboard!")
            end
         end)
      else
         Rayfield:Notify({
            Title = "No Furnitures Found",
            Content = "Could not find any furniture in the house",
            Duration = 4,
            Image = "x"
         })
      end
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
         Content = "Preparing to place " .. furnitureCount .. " furnitures...",
         Duration = 4,
         Image = "loader"
      })
      
      -- Simular colocación de muebles (en un ejecutor real, aquí iría la lógica de colocación)
      local placedCount = 0
      local totalFurniture = 0
      for _ in pairs(houseData.furniture) do
         totalFurniture = totalFurniture + 1
      end
      
      for furnitureId, furniture in pairs(houseData.furniture) do
         spawn(function()
            wait(placedCount * 0.1) -- Delay para simulación
            placedCount = placedCount + 1
            local progressPercent = math.floor((placedCount / totalFurniture) * 100)
            Label4:Set("Progress: " .. progressPercent .. "%")
            
            -- Aquí se colocaría el mueble usando:
            -- furniture.id (nombre del mueble)
            -- furniture.cframe (posición y rotación en formato array)
            -- furniture.colors (colores)
            -- furniture.scale (escala)
            
            print("Placing furniture:", furniture.id)
            print("Position:", furniture.cframe[1], furniture.cframe[2], furniture.cframe[3])
            print("Scale:", furniture.scale)
            
            if placedCount == totalFurniture then*
