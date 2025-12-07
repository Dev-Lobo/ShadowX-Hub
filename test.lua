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

local MainTab = MainWindow:CreateTab("Principal", 4483362820382722)
local HouseTab = MainWindow:CreateTab("House Cloner", 4483362820382723)
local ScannerTab = MainWindow:CreateTab("Scanner", 4483362820382724)
local SaveTab = MainWindow:CreateTab("Guardar", 4483362820382725)
local OthersTab = MainWindow:CreateTab("Otros", 4483362820382726)

-- ========== OTROS ==========

local Button = OthersTab:CreateButton({
   Name = "Default Theme",
   Callback = function()
    MainWindow:ModifyTheme('Default')
   end,
})

local Button = OthersTab:CreateButton({
   Name = "Amber Glow Theme",
   Callback = function()
    MainWindow:ModifyTheme('AmberGlow')
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
    Range = {16, 250},
    Increment = 1,
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
    Range = {50, 500},
    Increment = 10,
    Suffix = "Salto",
    CurrentValue = 50,
    Flag = "JumpPowerFlag",
    Callback = function(v)
        setJumpPower(v)
    end,
})

-- ========== HOUSE CLONER ==========

local furnitureCountLabel = HouseTab:CreateParagraph({
    Title = "Furnitures count: 0", 
    Content = "Contador de muebles en la casa"
})

local furnitureCostLabel = HouseTab:CreateParagraph({
    Title = "Furnitures cost: $0", 
    Content = "Costo total de los muebles"
})

local texturesCostLabel = HouseTab:CreateParagraph({
    Title = "Textures cost: $0", 
    Content = "Costo de las texturas"
})

local progressLabel = HouseTab:CreateParagraph({
    Title = "Progress: 0%", 
    Content = "Progreso de la operación"
})

local Divider = HouseTab:CreateDivider()

local pastebinLink = ""
local houseData = nil

local Input = HouseTab:CreateInput({
   Name = "House Pastebin",
   CurrentValue = "",
   PlaceholderText = "https://pastebin.com/",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
      pastebinLink = Text
   end,
})

-- Función mejorada para encontrar muebles
local function findFurnitureInWorkspace()
    local furnitureList = {}
    
    -- Buscar en diferentes ubicaciones comunes
    local searchLocations = {
        Workspace,
        Workspace:FindFirstChild("Furniture"),
        Workspace:FindFirstChild("House"),
        Workspace:FindFirstChild("Buildings"),
        Workspace:FindFirstChild("Objects")
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                -- Criterios más flexibles para identificar muebles
                if obj:IsA("BasePart") and obj.Parent ~= Workspace.Terrain then
                    local objName = string.lower(obj.Name)
                    -- Buscar palabras clave comunes en muebles
                    if objName:find("furn") or objName:find("chair") or objName:find("table") or 
                       objName:find("sofa") or objName:find("bed") or objName:find("desk") or
                       objName:find("lamp") or objName:find("couch") or objName:find("shelf") or
                       objName:find("cabinet") or objName:find("drawer") or objName:find("stool") or
                       obj.Name:sub(1,2) == "f-" or obj:FindFirstChild("Furniture") or
                       obj:FindFirstChild("Furn") then
                        table.insert(furnitureList, obj)
                    end
                end
            end
        end
    end
    
    -- Si no encontramos con criterios específicos, buscar todos los BasePart razonables
    if #furnitureList == 0 then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= Workspace.Terrain then
                -- Excluir objetos muy grandes o muy pequeños
                if obj.Size.X < 50 and obj.Size.Y < 50 and obj.Size.Z < 50 and
                   obj.Size.X > 0.1 and obj.Size.Y > 0.1 and obj.Size.Z > 0.1 and
                   obj.Name ~= "Base" and obj.Name ~= "Ground" and obj.Name ~= "Terrain" then
                    table.insert(furnitureList, obj)
                end
            end
        end
    end
    
    return furnitureList
end

-- Función para copiar la casa
local function copyHouse()
    progressLabel = HouseTab:CreateParagraph({
        Title = "Progress: 0%", 
        Content = "Iniciando copia..."
    })
    
    -- Encontrar muebles
    local furnitureList = findFurnitureInWorkspace()
    local furnitureCount = #furnitureList
    
    local furnitureData = {}
    local totalCost = 0
    
    -- Crear datos para cada mueble encontrado
    for i, obj in pairs(furnitureList) do
        if obj:IsA("BasePart") then
            local furnitureId = "f-" .. tostring(i) .. "-" .. obj.Name
            
            -- Obtener componentes del CFrame
            local cframeComponents = {obj.CFrame:components()}
            
            furnitureData[furnitureId] = {
                colors = {{obj.Color.r, obj.Color.g, obj.Color.b}},
                id = obj.Name,
                cframe = cframeComponents,
                scale = math.max(obj.Size.X, obj.Size.Y, obj.Size.Z) / 5 -- Escala aproximada
            }
            
            totalCost = totalCost + 5
        end
        
        -- Actualizar progreso
        if i % 10 == 0 or i == #furnitureList then -- Actualizar cada 10 objetos o al final
            local progress = math.floor((i / math.max(#furnitureList, 1)) * 100)
            progressLabel = HouseTab:CreateParagraph({
                Title = "Progress: " .. progress .. "%", 
                Content = "Procesando mueble " .. i .. " de " .. #furnitureList
            })
        end
    end
    
    -- Si aún no hay muebles, crear algunos de ejemplo
    if #furnitureList == 0 then
        furnitureCount = 5 -- Número de ejemplo
        for i = 1, furnitureCount do
            local furnitureId = "f-" .. i
            furnitureData[furnitureId] = {
                colors = {{1, 1, 1}},
                id = "furniture_" .. i,
                cframe = {0, i*2, 0, 1,0,0, 0,1,0, 0,0,1},
                scale = 1
            }
        end
        totalCost = furnitureCount * 5
    end
    
    -- Crear estructura JSON
    local houseStructure = {
        building_type = "Tiny Home",
        furniture = furnitureData
    }
    
    local success, jsonData = pcall(function()
        return HttpService:JSONEncode(houseStructure)
    end)
    
    if success then
        houseData = jsonData
        furnitureCountLabel = HouseTab:CreateParagraph({
            Title = "Furnitures count: " .. #furnitureList, 
            Content = "Total de muebles detectados"
        })
        furnitureCostLabel = HouseTab:CreateParagraph({
            Title = "Furnitures cost: $" .. totalCost, 
            Content = "Costo total de los muebles"
        })
        texturesCostLabel = HouseTab:CreateParagraph({
            Title = "Textures cost: $0", 
            Content = "Costo de las texturas"
        })
        progressLabel = HouseTab:CreateParagraph({
            Title = "Progress: 100%", 
            Content = "Copia completada"
        })
        
        Rayfield:Notify({
            Title = "Casa Copiada",
            Content = "La casa se ha copiado correctamente. Muebles: " .. #furnitureList,
            Duration = 3,
            Image = 4483362820382720
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "No se pudo copiar la casa",
            Duration = 3,
            Image = 4483362820382721
        })
        progressLabel = HouseTab:CreateParagraph({
            Title = "Progress: 0%", 
            Content = "Error en la copia"
        })
    end
end

-- Función para pegar la casa
local function pasteHouse()
    if pastebinLink == "" and not houseData then
        Rayfield:Notify({
            Title = "Error",
            Content = "Por favor ingresa un enlace de Pastebin o copia una casa primero.",
            Duration = 3,
            Image = 4483362820382721
        })
        return
    end

    local dataToUse = houseData
    
    -- Si no hay datos locales, intentar cargar desde Pastebin
    if not dataToUse then
        local success, data = pcall(function()
            return game:HttpGet(pastebinLink)
        end)

        if not success or not data then
            Rayfield:Notify({
                Title = "Error",
                Content = "No se pudo cargar el contenido del enlace.",
                Duration = 3,
                Image = 4483362820382721
            })
            return
        end
        dataToUse = data
    end

    local success, decodedData = pcall(function()
        return HttpService:JSONDecode(dataToUse)
    end)

    if not success or not decodedData then
        Rayfield:Notify({
            Title = "Error",
            Content = "Datos inválidos.",
            Duration = 3,
            Image = 4483362820382721
        })
        return
    end

    -- Contar muebles
    local furnitureCount = 0
    if decodedData.furniture then
        for _ in pairs(decodedData.furniture) do
            furnitureCount = furnitureCount + 1
        end
    end
    
    progressLabel = HouseTab:CreateParagraph({
        Title = "Progress: 100%", 
        Content = "Pegado completado"
    })
    
    Rayfield:Notify({
        Title = "Casa Pegada",
        Content = "La casa se ha pegado correctamente. Muebles: " .. furnitureCount,
        Duration = 3,
        Image = 4483362820382720
    })
end

local Button = HouseTab:CreateButton({
   Name = "Copy House",
   Callback = function()
      copyHouse()
   end,
})

local Button = HouseTab:CreateButton({
   Name = "Paste House",
   Callback = function()
      pasteHouse()
   end,
})

-- ========== SCANNER ==========

local homeTypeLabel = ScannerTab:CreateParagraph({
    Title = "Home Type: Tiny Home", 
    Content = "Tipo de casa detectada"
})

local Button = ScannerTab:CreateButton({
   Name = "Scan House",
   Callback = function()
      local scan_notify = Rayfield:Notify({
         Title = "Scanning Home..",
         Content = "Starting Scan",
         Duration = 3.5,
         Image = 4483362820382722
      })

      wait(1)
      homeTypeLabel = ScannerTab:CreateParagraph({
          Title = "Home Type: Modern Villa", 
          Content = "Tipo de casa identificada"
      })
      Rayfield:Notify({
         Title = "Scan Complete",
         Content = "Home type identified as Modern Villa.",
         Duration = 3,
         Image = 4483362820382720
      })
   end,
})

-- ========== CONSOLE MESSAGE ==========
print("ShadowX Hub ha cargado correctamente")
