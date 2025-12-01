-- ShadowX Hub (versión corregida)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local MainWindow = Rayfield:CreateWindow({
    Name = "ShadowX Hub",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "by Lobo27",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "ShadowXHubConfigs",
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

-- Tabs
local MainTab = MainWindow:CreateTab("Principal", "map-pin")
local HouseTab = MainWindow:CreateTab("House Cloner", "star")
local ScannerTab = MainWindow:CreateTab("Scanner", "search")
local SaveTab = MainWindow:CreateTab("Guardar", "file")
local OthersTab = MainWindow:CreateTab("Otros", "circle-ellipsis")

-- ========== Otros: Default Theme (usa MainWindow:ModifyTheme si está disponible) ==========
local ButtonDefaultTheme = OthersTab:CreateButton({
   Name = "Default Theme",
   Callback = function()
       local ok, err = pcall(function()
           if MainWindow and MainWindow.ModifyTheme then
               -- Intenta establecer un tema por nombre. Cambia "Default" por el identificador real si es necesario.
               MainWindow:ModifyTheme("Default")
           else
               error("ModifyTheme no disponible en MainWindow")
           end
       end)
       if not ok then
           warn("No se pudo aplicar el tema por defecto:", err)
       end
   end,
})

-- ========== PRINCIPAL: Salto Infinito (toggle seguro, evita fugas) ==========
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local infiniteJumpConnection -- almacenará la conexión
local infiniteJumpEnabled = false

local ToggleInfiniteJump = MainTab:CreateToggle({
    Name = "Salto Infinito",
    CurrentValue = false,
    Flag = "InfiniteJumpFlag",
    Callback = function(value)
        -- value viene del toggle
        infiniteJumpEnabled = value

        -- Si se activa y no hay conexión, conéctala
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

        -- Si se desactiva y existe conexión, desconéctala
        if not infiniteJumpEnabled and infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end,
})

-- Limpieza si el personaje muere/respawnea (no estrictamente necesario aquí, pero seguro)
localPlayer.CharacterRemoving:Connect(function()
    if infiniteJumpConnection then
        -- conexión a JumpRequest sigue funcionando todavía, pero al desconectar evitamos comportamientos raros
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end)

-- ========== PRINCIPAL: WalkSpeed Slider (flag único, manejo de respawn) ==========
local walkSpeedValue = 10
local function setWalkSpeed(v)
    walkSpeedValue = v
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        -- protección ante valores inválidos
        pcall(function() hum.WalkSpeed = tonumber(v) or 16 end)
    end
end

-- Si respawnea, reaplicar valor del slider
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
    CurrentValue = 10,
    Flag = "WalkSpeedFlag",
    Callback = function(v)
        setWalkSpeed(v)
    end,
})

-- ========== PRINCIPAL: JumpPower Slider (flag único, manejo de respawn) ==========
local jumpPowerValue = 50
local function setJumpPower(v)
    jumpPowerValue = v
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.JumpPower = tonumber(v) or hum.JumpPower end)
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
local LabelFurnCount = HouseTab:CreateLabel("Furnitures count: 0", "sofa")
local LabelFurnCost = HouseTab:CreateLabel("Furnitures cost: 0$", "badge-dollar-sign")
local LabelTexturesCost = HouseTab:CreateLabel("Textures cost: 0$", "paint-roller")
local LabelProgress = HouseTab:CreateLabel("Progress: 0%", "loader")
HouseTab:CreateDivider()

local PastebinInput = HouseTab:CreateInput({
   Name = "House Pastebin",
   CurrentValue = "",
   PlaceholderText = "https://pastebin.com/raw/ID  (opcional)",
   RemoveTextAfterFocusLost = false,
   Flag = "HousePastebinInput",
   Callback = function(text)
       -- no hacemos nada automático aquí, el usuario puede pegar la URL
   end,
})

-- Estructura para mantener la "casa copiada"
local copiedHouseData = {
    furnitures = {}, -- lista de objetos {className, properties...}
    totalCost = 0,
    texturesCost = 0
}

-- Helper: leer modelo "House" en workspace y construir datos simples
local function scanHouseModel()
    local houseModel = workspace:FindFirstChild("House")
    if not houseModel then
        return nil, "No se encontró 'workspace.House'. Crea un modelo llamado 'House' o adapta el script."
    end

    local furnitures = {}
    local totalCost = 0
    local texturesCost = 0
    local totalParts = 0
    local processed = 0

    -- Recorremos descendientes y tratamos de representar items; esto es genérico
    for _, obj in ipairs(houseModel:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
            totalParts = totalParts + 1
        end
    end

    -- Si no hay nada
    if totalParts == 0 then
        return nil, "El modelo 'House' no contiene partes reconocibles."
    end

    for _, obj in ipairs(houseModel:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
            processed = processed + 1
            -- Guardamos una representación mínima: clase, name, CFrame, Size, BrickColor, Material
            local entry = {
                ClassName = obj.ClassName,
                Name = obj.Name,
                CFrame = obj:IsA("BasePart") and obj.CFrame or (obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.CFrame or nil)),
                Size = obj:IsA("BasePart") and obj.Size or nil,
                BrickColor = obj:IsA("BasePart") and tostring(obj.BrickColor) or nil,
                Material = obj:IsA("BasePart") and tostring(obj.Material) or nil,
            }
            -- Estimación de "coste" arbitraria: por tamaño
            local costEstimate = 1
            if entry.Size then
                costEstimate = math.max(1, math.floor((entry.Size.X * entry.Size.Y * entry.Size.Z) / 100))
            end
            totalCost = totalCost + costEstimate
            -- texturas: si tiene MeshId o Decal, lo contamos
            local hasTexture = false
            if obj:FindFirstChildOfClass("Decal") or obj:IsA("MeshPart") and obj.MeshId and obj.MeshId ~= "" then
                hasTexture = true
                texturesCost = texturesCost + math.max(1, math.floor(costEstimate * 0.2))
            end
            entry.EstimatedCost = costEstimate
            entry.HasTexture = hasTexture
            table.insert(furnitures, entry)

            -- actualizar progreso (solo para labels)
            local prog = math.floor((processed / totalParts) * 100)
            LabelProgress:Set("Progress: " .. tostring(prog) .. "%")
        end
    end

    return {
        furnitures = furnitures,
        totalCost = totalCost,
        texturesCost = texturesCost
    }
end

-- Copy House: escanea workspace.House y guarda en copiedHouseData
local ButtonCopyHouse = HouseTab:CreateButton({
   Name = "Copy House",
   Callback = function()
       local ok, resultOrErr = pcall(scanHouseModel)
       if not ok then
           warn("Error escaneando la casa:", resultOrErr)
           LabelProgress:Set("Progress: 0%")
           return
       end
       if not resultOrErr then
           -- resultOrErr nil significa que la función devolvió nil y un mensaje
           LabelProgress:Set("Progress: 0%")
           LabelFurnCount:Set("Furnitures count: 0")
           LabelFurnCost:Set("Furnitures cost: 0$")
           LabelTexturesCost:Set("Textures cost: 0$")
           warn("No se pudo copiar la casa: revisa workspace.House")
           return
       end

       copiedHouseData = resultOrErr
       LabelFurnCount:Set("Furnitures count: " .. tostring(#copiedHouseData.furnitures))
       LabelFurnCost:Set("Furnitures cost: " .. tostring(copiedHouseData.totalCost) .. "$")
       LabelTexturesCost:Set("Textures cost: " .. tostring(copiedHouseData.texturesCost) .. "$")
       LabelProgress:Set("Progress: 100%")
   end,
})

-- Helper: crear clones simples en workspace a partir de copiedHouseData
local function pasteHouseToWorkspace()
    if not copiedHouseData or not copiedHouseData.furnitures or #copiedHouseData.furnitures == 0 then
        return false, "No hay datos de casa copiados. Usa 'Copy House' primero."
    end

    -- Limpia ClonedHouse previo si existe
    if workspace:FindFirstChild("ClonedHouse") then
        workspace.ClonedHouse:Destroy()
    end

    local cloneFolder = Instance.new("Folder")
    cloneFolder.Name = "ClonedHouse"
    cloneFolder.Parent = workspace

    local total = #copiedHouseData.furnitures
    local processed = 0

    for _, entry in ipairs(copiedHouseData.furnitures) do
        local success, err = pcall(function()
            -- Creamos un Part representativo
            local part = Instance.new("Part")
            part.Name = entry.Name or "FurniturePart"
            part.Anchored = true
            part.CanCollide = true
            if entry.Size then
                part.Size = entry.Size
            else
                part.Size = Vector3.new(2,2,2)
            end
            if entry.CFrame then
                part.CFrame = entry.CFrame + Vector3.new(5,0,0) -- offset para que no colisione con la original (opcional)
            else
                part.Position = Vector3.new(0, 5 + processed, 0)
            end
            if entry.BrickColor then
                -- BrickColor fue guardado como string; intentamos aplicar
                pcall(function() part.BrickColor = BrickColor.new(entry.BrickColor) end)
            end
            if entry.Material then
                pcall(function() part.Material = Enum.Material[entry.Material] end)
            end
            part.Parent = cloneFolder

            -- Si la entrada tenía textura, colocamos un decal de ejemplo (sin URL)
            if entry.HasTexture then
                local decal = Instance.new("Decal")
                decal.Name = "ClonedTexture"
                decal.Parent = part
                -- No ponemos Texture porque no tenemos una URL; si quieres, el usuario puede pegar una URL en el input y se podría mapear aquí.
            end
        end)
        processed = processed + 1
        LabelProgress:Set("Progress: " .. tostring(math.floor((processed / total) * 100)) .. "%")
        if not success then
            warn("Error al crear parte clonada:", err)
        end
    end

    return true
end

local ButtonPasteHouse = HouseTab:CreateButton({
   Name = "Paste House",
   Callback = function()
       local ok, err = pcall(pasteHouseToWorkspace)
       if not ok then
           warn("Paste House falló:", err)
           return
       end
       if err == false then
           -- ya manejado, no debería pasar
       end
   end,
})

-- ========== Otros ajustes: evitar redeclaración de variables "Button" repetidas ==========
-- (en este script ya uso nombres descriptivos: ButtonDefaultTheme, ButtonCopyHouse, ButtonPasteHouse, etc.)

-- ========== FIN del Script ==========
print("ShadowX Hub cargado (versión corregida).")
