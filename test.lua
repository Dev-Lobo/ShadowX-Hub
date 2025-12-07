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

-- Base de datos de precios de muebles (puedes expandirla)
local furniturePrices = {
    ["brick"] = 50,
    ["medium_disk"] = 75,
    ["plainmound_v1"] = 100,
    ["fancytrashcan"] = 150,
    ["torus_v3_plain"] = 80,
    ["beam_v1_plain"] = 120,
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

-- Función para convertir CFrame a array
local function cframeToArray(cf)
    local pos = cf.Position
    local x, y, z = pos.X, pos.Y, pos.Z
    local _, _, _, m03, m10, m11, m12, m13, m20, m21, m22, m23 = cf:components()
    return {x, y, z, m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23}
end

-- Función para obtener el tipo de casa
local function getBuildingType()
    local house = Workspace:FindFirstChild("HouseFurnitures") or Workspace:FindFirstChild(localPlayer.Name .. "'s House")
    if house then
        -- Determinar tipo basado en tamaño o nombre
        local size = house:GetExtents(true).Size
        if size.Magnitude > 100 then
            return "Mansion"
        elseif size.Magnitude > 50 then
            return "Large Home"
        else
            return "Tiny Home"
        end
    end
    return "Tiny Home"
end

-- Función para escanear muebles y convertir al formato específico
local function scanHouseFurniture()
    local furnitureData = {}
    local buildingType = getBuildingType()
    
    -- Buscar muebles en ubicaciones comunes
    local searchLocations = {
        Workspace:FindFirstChild("HouseFurnitures"),
        Workspace:FindFirstChild(localPlayer.Name .. "'s House"),
        Workspace:FindFirstChild("Furniture"),
        Workspace
    }
    
    local furnitureCount = 0
    local totalCost = 0
    local textureCostTotal = 0
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name ~= "HumanoidRootPart" and not obj:IsA("Seat") then
                    -- Verificar si es un mueble válido
                    if obj:IsA("BasePart") and obj.Anchored == true then
                        furnitureCount = furnitureCount + 1
                        
                        local furnitureId = obj.Name:lower():gsub(" ", "_")
                        local colors = {}
                        
                        -- Obtener colores
                        if obj:IsA("BasePart") and obj:FindFirstChild("Color") then
                            local color = obj.Color
                            table.insert(colors, {color.R, color.G, color.B})
                            textureCostTotal = textureCostTotal + 10
                        elseif obj:IsA("BasePart") then
                            local brickColor = obj.BrickColor
                            if brickColor then
                                local color3 = brickColor.Color
                                table.insert(colors, {color3.R, color3.G, color3.B})
                                textureCostTotal = textureCostTotal + 10
                            end
                        end
                        
                        -- Crear ID único
                        local uniqueId = "f-" .. math.random(100, 9999)
                        
                        -- Obtener CFrame y convertir a array
                        local cframeArray = cframeToArray(obj.CFrame)
                        
                        -- Calcular escala
                        local scale = obj:IsA("BasePart") and (obj.Size.X + obj.Size.Y + obj.Size.Z) / 3 or 1
                        scale = math.max(0.01, scale / 10) -- Normalizar
                        
                        -- Obtener precio
                        local price = furniturePrices[furnitureId] or furniturePrices["default"]
                        totalCost = totalCost + price
                        
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
         print(HttpService:JSONEncode(houseDataFormatted))
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
         Content = "Placing " .. furnitureCount .. " furnitures...",
         Duration = 4,
         Image = "loader"
      })
      
      -- Aquí iría la lógica para colocar los muebles usando el formato
      -- Esta es una simulación que muestra cómo se usaría el formato:
      
      local placedCount = 0
      for furnitureId, furniture in pairs(houseData.furniture) do
         spawn(function()
            wait(placedCount * 0.05)
            placedCount = placedCount + 1
            local progressPercent = math.floor((placedCount / furnitureCount) * 100)
            Label4:Set("Progress: " .. progressPercent .. "%")
            
            -- Aquí se colocaría el mueble usando:
            -- furniture.id (nombre del mueble)
            -- furniture.cframe (posición y rotación)
            -- furniture.colors (colores)
            -- furniture.scale (escala)
            
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

local homeType = "Unknown"
local Label5 = ScannerTab:CreateLabel("Home Type: " .. homeType, "milestone")

local Button = ScannerTab:CreateButton({
   Name = "Scan House",
   Callback = function()
      local scan_notify = Rayfield:Notify({
         Title = "Scanning Home..",
         Content = "Starting Scan",
         Duration = 2,
         Image = "play",
      })
      
      wait(1)
      
      local houseDataFormatted, count, cost, texCost = scanHouseFurniture()
      homeType = houseDataFormatted.building_type
      
      Label5:Set("Home Type: " .. homeType)
      
      if count > 0 then
         furnitureCount = count
         furnitureCost = cost
         textureCost = texCost
         
         Label1:Set("Furnitures count: " .. furnitureCount)
         Label2:Set("Furnitures cost: $" .. furnitureCost)
         Label3:Set("Textures cost: $" .. textureCost)
         
         Rayfield:Notify({
            Title = "Scan Complete",
            Content = "Found " .. count .. " items in house (" .. homeType .. ")",
            Duration = 4,
            Image = "check"
         })
         
         -- Mostrar datos formateados
         print("Formatted House Data:")
         local jsonData = HttpService:JSONEncode(houseDataFormatted)
         print(jsonData)
      else
         Rayfield:Notify({
            Title = "No Items Found",
            Content = "Could not find any items in the house",
            Duration = 4,
            Image = "x"
         })
      end
   end,
})

-- ========== CONSOLE MESSAGE ==========
print("ShadowX Hub ha cargado correctamente")
print("Para ver los datos escaneados, revisa la consola de Roblox Studio")
