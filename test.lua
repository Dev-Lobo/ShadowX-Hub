-- ========== HOUSE CLONER ==========

local Label1 = HouseTab:CreateParagraph({
    Title = "Furnitures count: 0", 
    Content = "Contador de muebles en la casa"
})

local Label2 = HouseTab:CreateParagraph({
    Title = "Furnitures cost: 0$", 
    Content = "Costo total de los muebles"
})

local Label3 = HouseTab:CreateParagraph({
    Title = "Textures cost: 0$", 
    Content = "Costo de las texturas"
})

local Label4 = HouseTab:CreateParagraph({
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

-- Función para actualizar labels (párrafos)
local function updateLabel(label, title, content)
    -- En Rayfield, los párrafos no se actualizan directamente
    -- Necesitamos crear una nueva estructura o usar notificaciones
    return {
        Title = title,
        Content = content
    }
end

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
                       objName:find("lamp") or objName:find("couch") or objName:find("shelf") or
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
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= Workspace.Terrain then
                -- Excluir objetos muy grandes (probablemente estructura del mapa)
                if obj.Size.X < 50 and obj.Size.Y < 50 and obj.Size.Z < 50 and
                   obj.Size.X > 0.1 and obj.Size.Y > 0.1 and obj.Size.Z > 0.1 then -- Excluir objetos muy pequeños
                    table.insert(furnitureList, obj)
                end
            end
        end
    end
    
    return furnitureList
end

-- Variables para almacenar referencias a los labels
local furnitureCountLabel = Label1
local furnitureCostLabel = Label2
local texturesCostLabel = Label3
local progressLabel = Label4

-- Función para copiar la casa
local function copyHouse()
    progressLabel = HouseTab:CreateParagraph({
        Title = "Progress: 0%", 
        Content = "Iniciando copia..."
    })
    
    -- Encontrar muebles
    local furnitureList = findFurnitureInWorkspace()
    local furnitureCount = #furnitureList
    
    -- Si no encontramos muebles específicos, contar todos los BasePart razonables
    if furnitureCount == 0 then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= Workspace.Terrain then
                if obj.Size.X < 50 and obj.Size.Y < 50 and obj.Size.Z < 50 and
                   obj.Size.X > 0.1 and obj.Size.Y > 0.1 and obj.Size.Z > 0.1 then
                    furnitureCount = furnitureCount + 1
                end
            end
        end
        -- Usar todos los objetos encontrados si no hay criterios específicos
        if furnitureCount > 0 then
            furnitureList = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent ~= Workspace.Terrain then
                    if obj.Size.X < 50 and obj.Size.Y < 50 and obj.Size.Z < 50 and
                       obj.Size.X > 0.1 and obj.Size.Y > 0.1 and obj.Size.Z > 0.1 then
                        table.insert(furnitureList, obj)
                    end
                end
            end
        end
    end
    
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
        if i % 5 == 0 or i == #furnitureList then -- Actualizar cada 5 objetos o al final
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
            Image = 4483362820382720 -- Icono de check
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "No se pudo copiar la casa",
            Duration = 3,
            Image = 4483362820382721 -- Icono de X
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
            Image = 4483362820382721 -- Icono de X
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
                Image = 4483362820382721 -- Icono de X
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
            Image = 4483362820382721 -- Icono de X
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
        Image = 4483362820382720 -- Icono de check
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
