-- ShadowX Hub para Adopt Me - Versión corregida
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
    KeySystem = false -- Desactivado para pruebas
})

local MainTab = MainWindow:CreateTab("Principal", "map-pin")
local HouseTab = MainWindow:CreateTab("House Cloner", "star")
local ScannerTab = MainWindow:CreateTab("Scanner", "search")
local SaveTab = MainWindow:CreateTab("Guardar", "file")
local OthersTab = MainWindow:CreateTab("Otros", "circle-ellipsis")

-- ========== SERVICIOS ==========
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- ========== VARIABLES GLOBALES ==========
local infiniteJumpConnection
local infiniteJumpEnabled = false
local furnitureCount = 0
local furnitureCost = 0
local textureCost = 0
local progress = 0
local houseData = nil
local houseUrl = ""
local walkSpeedValue = 16
local jumpPowerValue = 50

-- ========== ETIQUETAS ==========
local Label1 = HouseTab:CreateLabel("Furnitures count: " .. furnitureCount, "sofa")
local Label2 = HouseTab:CreateLabel("Furnitures cost: $" .. furnitureCost, "badge-dollar-sign")
local Label3 = HouseTab:CreateLabel("Textures cost: $" .. textureCost, "paint-roller")
local Label4 = HouseTab:CreateLabel("Progress: " .. progress .. "%", "loader")
local Label5 = ScannerTab:CreateLabel("Home Type: Unknown", "milestone")

-- ========== OTROS ==========
local Button = OthersTab:CreateButton({
    Name = "Default Theme",
    Callback = function()
        MainWindow.ModifyTheme('Default')
    end,
})

local Button = OthersTab:CreateButton({
    Name = "Amber Glow Theme",
    Callback = function()
        MainWindow.ModifyTheme('AmberGlow')
    end,
})

-- ========== PRINCIPAL ==========
-- Funciones de movimiento
local function setWalkSpeed(v)
    walkSpeedValue = v
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.WalkSpeed = tonumber(v) or 16 end)
    end
end

local function setJumpPower(v)
    jumpPowerValue = v
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.JumpPower = tonumber(v) or 50 end)
    end
end

-- Conexiones de personaje
localPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        pcall(function() 
            hum.WalkSpeed = walkSpeedValue
            hum.JumpPower = jumpPowerValue
        end)
    end
end)

localPlayer.CharacterRemoving:Connect(function()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end)

-- Controles
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
-- Base de datos de precios de muebles
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

-- Funciones auxiliares
local function getCFrame(obj)
    if obj:IsA("BasePart") then
        return obj.CFrame
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.CFrame
        else
            local firstPart = obj:FindFirstChildWhichIsA("BasePart")
            if firstPart then
                return firstPart.CFrame
            else
                local totalPos = Vector3.new(0, 0, 0)
                local count = 0
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        totalPos = totalPos + part.Position
                        count = count + 1
                    end
                end
                if count > 0 then
                    return CFrame.new(totalPos / count)
                else
                    return CFrame.new(0, 0, 0)
                end
            end
        end
    end
    return CFrame.new(0, 0, 0)
end

local function cframeToArray(cf)
    local pos = cf.Position
    local x, y, z = pos.X, pos.Y, pos.Z
    
    local rightVector = cf.XVector
    local upVector = cf.YVector
    local backVector = cf.ZVector
    
    return {
        x, y, z,
        rightVector.X, rightVector.Y, rightVector.Z,
        upVector.X, upVector.Y, upVector.Z,
        backVector.X, backVector.Y, backVector.Z
    }
end

local function getBuildingType()
    local playerHouse = Workspace:FindFirstChild(localPlayer.Name .. "'s House")
    if playerHouse then
        local houseName = playerHouse.Name:lower()
        if houseName:find("mansion") then
            return "Mansion"
        elseif houseName:find("large") or houseName:find("big") then
            return "Large Home"
        else
            return "Tiny Home"
        end
    end
    return "Tiny Home"
end

local function isValidFurniture(obj)
    if not obj then return false end
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return false end
    
    local bodyParts = {
        "HumanoidRootPart", "Torso", "Head", "Left Arm", "Right Arm", 
        "Left Leg", "Right Leg", "UpperTorso", "LowerTorso", "LeftHand", 
        "RightHand", "LeftFoot", "RightFoot"
    }
    
    for _, bodyPart in pairs(bodyParts) do
        if obj.Name == bodyPart then return false end
    end
    
    if obj:IsA("Seat") or obj:IsA("VehicleSeat") or obj:IsA("SpawnLocation") then 
        return false 
    end
    
    if obj:IsA("BasePart") then
        if obj.Anchored == false then return false end
        
        local excludedNames = {
            "ground", "floor", "wall", "roof", "ceiling", "baseplate",
            "terrain", "map", "world", "boundary", "sky", "water", "lava"
        }
        
        local objName = obj.Name:lower()
        for _, excluded in pairs(excludedNames) do
            if objName:find(excluded) then
                return false
            end
        end
        
        if obj.Size.X > 100 or obj.Size.Y > 100 or obj.Size.Z > 100 then
            return false
        end
        
        if obj.Size.X < 0.05 and obj.Size.Y < 0.05 and obj.Size.Z < 0.05 then
            return false
        end
    elseif obj:IsA("Model") then
        local hasParts = false
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                hasParts = true
                break
            end
        end
        if not hasParts then return false end
        
        local excludedNames = {
            "ground", "floor", "wall", "roof", "ceiling", "baseplate",
            "terrain", "map", "world", "boundary", "sky", "water", "lava"
        }
        
        local objName = obj.Name:lower()
        for _, excluded in pairs(excludedNames) do
            if objName:find(excluded) then
                return false
            end
        end
    end
    
    return true
end

local function getFurnitureId(obj)
    if not obj then return "unknown" end
    
    local originalName = obj.Name
    local name = originalName:lower()
    
    local nameMapping = {
        ["brick"] = "brick",
        ["disk"] = "medium_disk",
        ["mound"] = "plainmound_v1",
        ["trashcan"] = "fancytrashcan",
        ["torus"] = "torus_v3_plain",
        ["beam"] = "beam_v1_plain",
        ["sofa"] = "sofa",
        ["couch"] = "sofa",
        ["table"] = "table",
        ["chair"] = "chair",
        ["bed"] = "bed",
        ["lamp"] = "lamp",
        ["light"] = "lamp",
        ["plant"] = "plant",
        ["flower"] = "plant",
        ["tree"] = "plant",
        ["picture"] = "picture",
        ["painting"] = "picture",
        ["photo"] = "picture",
        ["rug"] = "rug",
        ["carpet"] = "rug",
        ["tv"] = "tv",
        ["television"] = "tv",
        ["screen"] = "tv",
        ["kitchen"] = "kitchen",
        ["stove"] = "kitchen",
        ["fridge"] = "kitchen",
        ["bathroom"] = "bathroom",
        ["toilet"] = "bathroom",
        ["sink"] = "bathroom"
    }
    
    for key, value in pairs(nameMapping) do
        if name:find(key) then
            return value
        end
    end
    
    return originalName:lower()
end

local function getFurnitureColors(obj)
    local colors = {}
    
    if obj:IsA("BasePart") then
        local colorValue = obj.Color or (obj.BrickColor and obj.BrickColor.Color)
        if colorValue then
            table.insert(colors, {colorValue.R, colorValue.G, colorValue.B})
        else
            table.insert(colors, {1, 1, 1})
        end
    elseif obj:IsA("Model") then
        local foundColor = false
        for _, part in pairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                local colorValue = part.Color or (part.BrickColor and part.BrickColor.Color)
                if colorValue then
                    table.insert(colors, {colorValue.R, colorValue.G, colorValue.B})
                    foundColor = true
                    break
                end
            end
        end
        if not foundColor then
            table.insert(colors, {1, 1, 1})
        end
    end
    
    return colors
end

local function getFurnitureScale(obj)
    if obj:IsA("BasePart") then
        local avgSize = (obj.Size.X + obj.Size.Y + obj.Size.Z) / 3
        return math.max(0.01, avgSize / 3)
    elseif obj:IsA("Model") then
        local size = obj:GetExtents(true).Size
        local avgSize = (size.X + size.Y + size.Z) / 3
        return math.max(0.01, avgSize / 3)
    end
    return 1
end

-- Función principal para escanear muebles
local function scanHouseFurniture()
    local furnitureData = {}
    local buildingType = getBuildingType()
    
    local searchLocations = {}
    
    local playerHouse = Workspace:FindFirstChild(localPlayer.Name .. "'s House")
    if playerHouse then
        table.insert(searchLocations, playerHouse)
    end
    
    local commonLocations = {
        "HouseFurnitures", "Furniture", "PlayerHouses", "Buildings", "Interior"
    }
    
    for _, locationName in pairs(commonLocations) do
        local location = Workspace:FindFirstChild(locationName)
        if location then
            table.insert(searchLocations, location)
        end
    end
    
    table.insert(searchLocations, Workspace)
    
    local furnitureCount = 0
    local totalCost = 0
    local textureCostTotal = 0
    local scannedObjects = {}
    
    print("Iniciando escaneo de muebles...")
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetChildren()) do
                if isValidFurniture(obj) and not scannedObjects[obj] then
                    scannedObjects[obj] = true
                    
                    local isEnvironment = false
                    local objName = obj.Name:lower()
                    
                    local environmentNames = {
                        "baseplate", "ground", "floor", "wall", "roof", "sky", 
                        "terrain", "water", "lava", "boundary", "map", "world"
                    }
                    
                    for _, envName in pairs(environmentNames) do
                        if objName:find(envName) then
                            isEnvironment = true
                            break
                        end
                    end
                    
                    if not isEnvironment then
                        furnitureCount = furnitureCount + 1
                        
                        local furnitureId = getFurnitureId(obj)
                        local colors = getFurnitureColors(obj)
                        local objCFrame = getCFrame(obj)
                        local cframeArray = cframeToArray(objCFrame)
                        local scale = getFurnitureScale(obj)
                        
                        local uniqueId = "f-" .. tostring(tick()):gsub("%.", ""):sub(-4)
                        
                        local price = furniturePrices[furnitureId] or furniturePrices["default"]
                        totalCost = totalCost + price
                        
                        if colors and #colors > 0 then
                            textureCostTotal = textureCostTotal + (#colors * 10)
                        end
                        
                        furnitureData[uniqueId] = {
                            colors = colors,
                            id = furnitureId,
                            cframe = cframeArray,
                            scale = math.max(0.01, scale)
                        }
                        
                        print("Mueble encontrado:", furnitureId, "Tipo:", obj.ClassName)
                    end
                end
            end
        end
    end
    
    print("Escaneo completado. Muebles encontrados:", furnitureCount)
    
    local houseDataFormatted = {
        building_type = buildingType,
        furniture = furnitureData
    }
    
    return houseDataFormatted, furnitureCount, totalCost, textureCostTotal
end

-- Función para crear muebles en Adopt Me
local function createFurnitureInAdoptMe(furnitureId, cframeData)
    -- Buscar el contenedor de muebles en Adopt Me
    local furnitureContainers = {
        workspace:FindFirstChild("HouseFurnitures"),
        workspace:FindFirstChild("Furniture"),
        ReplicatedStorage:FindFirstChild("HouseFurnitures"),
        ReplicatedStorage:FindFirstChild("Furniture")
    }
    
    local furnitureModel = nil
    
    -- Buscar el mueble en los contenedores
    for _, container in pairs(furnitureContainers) do
        if container then
            furnitureModel = container:FindFirstChild(furnitureId)
            if furnitureModel then break end
        end
    end
    
    -- Si no se encuentra, buscar por nombres similares
    if not furnitureModel then
        for _, container in pairs(furnitureContainers) do
            if container then
                for _, item in pairs(container:GetChildren()) do
                    if item.Name:lower():find(furnitureId:lower()) then
                        furnitureModel = item
                        break
                    end
                end
                if furnitureModel then break end
            end
        end
    end
    
    if furnitureModel then
        local newFurniture = furnitureModel:Clone()
        newFurniture.Parent = workspace
        
        -- Aplicar posición y rotación
        if cframeData and #cframeData >= 12 then
            local cf = CFrame.new(
                cframeData[1], cframeData[2], cframeData[3],
                cframeData[4], cframeData[5], cframeData[6],
                cframeData[7], cframeData[8], cframeData[9],
                cframeData[10], cframeData[11], cframeData[12]
            )
            newFurniture:PivotTo(cf)
        end
        
        return newFurniture
    end
    
    return nil
end

-- Botones de House Cloner
local Button = HouseTab:CreateButton({
    Name = "Copy House",
    Callback = function()
        Rayfield:Notify({
            Title = "Scanning House",
            Content = "Please wait...",
            Duration = 2,
            Image = "loader"
        })
        
        wait(0.5)
        
        local success, result = pcall(function()
            return scanHouseFurniture()
        end)
        
        if success then
            local houseDataFormatted, count, cost, texCost = result[1], result[2], result[3], result[4]
            
            if count > 0 and count < 1000 then
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
                
                print("House Data JSON:")
                local jsonData = HttpService:JSONEncode(houseDataFormatted)
                print(jsonData)
                
                pcall(function()
                    if setclipboard then
                        setclipboard(jsonData)
                        print("Data copied to clipboard!")
                    end
                end)
            elseif count >= 1000 then
                Rayfield:Notify({
                    Title = "Too Many Items",
                    Content = "Found " .. count .. " items. This seems incorrect.",
                    Duration = 4,
                    Image = "x"
                })
            else
                Rayfield:Notify({
                    Title = "No Furnitures Found",
                    Content = "Could not find any furniture in the house",
                    Duration = 4,
                    Image = "x"
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Scan failed: " .. tostring(result),
                Duration = 4,
                Image = "x"
            })
            print("Error en escaneo:", result)
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
            Duration = 2,
            Image = "loader"
        })
        
        local totalFurniture = 0
        for _ in pairs(houseData.furniture) do
            totalFurniture = totalFurniture + 1
        end
        
        print("Iniciando colocación de", totalFurniture, "muebles")
        
        local placedCount = 0
        local startTime = tick()
        
        for furnitureId, furniture in pairs(houseData.furniture) do
            placedCount = placedCount + 1
            
            print("Colocando:", furniture.id)
            
            -- Crear el mueble en el mundo
            local success, result = pcall(function()
                return createFurnitureInAdoptMe(furniture.id, furniture.cframe)
            end)
            
            if not success then
                print("Error creando mueble:", furniture.id, result)
            end
            
            if placedCount % 10 == 0 or placedCount == totalFurniture then
                local progressPercent = math.floor((placedCount / totalFurniture) * 100)
                Label4:Set("Progress: " .. progressPercent .. "%")
                RunService.Heartbeat:Wait()
            end
            
            if placedCount == totalFurniture then
                local endTime = tick()
                local timeTaken = string.format("%.2f", endTime - startTime)
                
                Rayfield:Notify({
                    Title = "Success!",
                    Content = "House pasted successfully! (" .. placedCount .. " items in " .. timeTaken .. "s)",
                    Duration = 4,
                    Image = "check"
                })
                print("Colocación completada en", timeTaken, "segundos")
            end
        end
    end,
})

-- ========== SCANNER ==========
local Button = ScannerTab:CreateButton({
    Name = "Scan House",
    Callback = function()
        local scan_notify = Rayfield:Notify({
            Title = "Scanning Home..",
            Content = "Starting Scan",
            Duration = 1,
            Image = "play",
        })
        
        wait(0.5)
        
        local success, result = pcall(function()
            return scanHouseFurniture()
        end)
        
        if success then
            local houseDataFormatted, count, cost, texCost = result[1], result[2], result[3], result[4]
            local homeType = houseDataFormatted.building_type
            
            Label5:Set("Home Type: " .. homeType)
            
            if count > 0 and count < 1000 then
                furnitureCount = count
                furnitureCost = cost
                textureCost = texCost
                
                Label1:Set("Furnitures count: " .. furnitureCount)
                Label2:Set("Furnitures cost: $" .. furnitureCost)
                Label3:Set("Textures cost: $" .. textureCost)
                
                Rayfield:Notify({
                    Title = "Scan Complete",
                    Content = "Found " .. count .. " items in house (" .. homeType .. ")",
                    Duration = 3,
                    Image = "check"
                })
                
                print("Formatted House Data:")
                local jsonData = HttpService:JSONEncode(houseDataFormatted)
                print(jsonData)
            elseif count >= 1000 then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Too many items found (" .. count .. "). Scan failed.",
                    Duration = 4,
                    Image = "x"
                })
            else
                Rayfield:Notify({
                    Title = "No Items Found",
                    Content = "Could not find any items in the house",
                    Duration = 4,
                    Image = "x"
                })
            end
        else
            Rayfield:Notify({
                Title = "Scan Error",
                Content = "Failed to scan: " .. tostring(result),
                Duration = 4,
                Image = "x"
            })
            print("Error en escaneo:", result)
        end
    end,
})

-- ========== INPUT PARA PASTEBIN ==========
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

-- ========== CONSOLE MESSAGE ==========
print("ShadowX Hub ha cargado correctamente")
print("Script actualizado para Adopt Me")
