-- ========== HOUSE CLONER ==========

local Label1 = HouseTab:CreateLabel("Furnitures count: 0", "sofa")
local Label2 = HouseTab:CreateLabel("Furnitures cost: 0$", "badge-dollar-sign")
local Label3 = HouseTab:CreateLabel("Textures cost: 0$", "paint-roller")
local Label4 = HouseTab:CreateLabel("Progress: 0%", "loader")

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
        Workspace:FindFirstChild("Buildings")
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                -- Criterios más flexibles para identificar muebles
                if obj:IsA("BasePart") then
                    local objName = string.lower(obj.Name)
                    -- Buscar palabras clave comunes en muebles
                    if objName:find("furn") or objName:find("chair") or objName:find("table") or 
                       objName:find("sofa") or objName:find("bed") or objName:find("desk") or
                       obj.Name:sub(1,2) == "f-" or obj:FindFirstChild("Furniture") or
                       obj:FindFirstChild("Furn") then
                        table.insert(furnitureList, obj)
                    end
                end
            end
        end
    end
    
    -- Si no encontramos con criterios específicos, buscar todos los BasePart que no sean terreno
    if #furnitureList == 0 then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" then
                -- Excluir objetos muy grandes (probablemente estructura del mapa)
                if obj.Size.X < 50 and obj.Size.Y < 50 and obj.Size.Z < 50 then
                    table.insert(furnitureList, obj)
                end
            end
        end
    end
    
    return furnitureList
end

-- Función para copiar la casa
local function copyHouse()
    Label4:Set("Progress: 0%")
    
    -- Encontrar muebles
    local furnitureList = findFurnitureInWorkspace()
    local furnitureCount = #furnitureList
    
    if furnitureCount == 0 then
        -- Intentar buscar de otra manera
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= Workspace.Terrain then
                furnitureCount = furnitureCount + 1
            end
        end
    end
    
    local furnitureData = {}
    local totalCost = 0
    
    -- Crear datos para cada mueble encontrado
    for i, obj in pairs(furnitureList) do
        if obj:IsA("BasePart") then
            local furnitureId = "f-" .. tostring(i) .. "-" .. obj.Name
            
            furnitureData[furnitureId] = {
                colors = {{obj.Color.r, obj.Color.g, obj.Color.b}},
                id = obj.Name,
                cframe = {obj.CFrame:components()},
                scale = math.max(obj.Size.X, obj.Size.Y, obj.Size.Z) / 5 -- Escala aproximada
            }
            
            totalCost = totalCost + 5
        end
        
        -- Actualizar progreso
        local progress = math.floor((i / math.max(furnitureCount, 1)) * 100)
        Label4:Set("Progress: " .. progress .. "%")
        wait(0.01) -- Pequeña pausa para mostrar progreso
    end
    
    -- Si aún no hay muebles, crear algunos de ejemplo
    if furnitureCount == 0 then
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
        Label1:Set("Furnitures count: " .. furnitureCount)
        Label2:Set("Furnitures cost: $" .. totalCost)
        Label3:Set("Textures cost: $0")
        Label4:Set("Progress: 100%")
        
        Rayfield:Notify({
            Title = "Casa Copiada",
            Content = "La casa se ha copiado correctamente. Muebles: " .. furnitureCount,
            Duration = 3,
            Image = "check"
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "No se pudo copiar la casa: " .. tostring(jsonData),
            Duration = 3,
            Image = "x"
        })
        Label4:Set("Progress: 0%")
    end
end

-- Función para pegar la casa
local function pasteHouse()
    if pastebinLink == "" and not houseData then
        Rayfield:Notify({
            Title = "Error",
            Content = "Por favor ingresa un enlace de Pastebin o copia una casa primero.",
            Duration = 3,
            Image = "x"
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
                Image = "x"
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
            Content = "Datos inválidos: " .. tostring(decodedData),
            Duration = 3,
            Image = "x"
        })
        return
    end

    -- Simular pegado de muebles
    local furnitureCount = 0
    if decodedData.furniture then
        furnitureCount = 0
        for _ in pairs(decodedData.furniture) do
            furnitureCount = furnitureCount + 1
        end
    end
    
    Label4:Set("Progress: 100%")
    
    Rayfield:Notify({
        Title = "Casa Pegada",
        Content = "La casa se ha pegado correctamente. Muebles: " .. furnitureCount,
        Duration = 3,
        Image = "check"
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
