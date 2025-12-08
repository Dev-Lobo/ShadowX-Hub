-- Cargar Rayfield Interface Suite
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
local Rayfield = library

-- Crear ventana principal
local Window = Rayfield:CreateWindow({
    Name = "Adopt Me House Manager",
    LoadingTitle = "Cargando Interfaz...",
    LoadingSubtitle = "Sistema de gestión de casas",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AdoptMeHouseManager",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Crear pestaña principal
local MainTab = Window:CreateTab("Gestor de Casas", 4483362458)

-- Sección para copiar casa
MainTab:CreateSection("Copiar Casa")

-- Variables para almacenar datos simulados
local CopiedHouseData = {
    FurnitureCount = 0,
    TotalValue = 0,
    FurnitureList = {}
}

-- Botón para copiar casa (simulado)
MainTab:CreateButton({
    Name = "Copiar Casa Actual",
    Callback = function()
        -- Esto es simulado - no interactúa con el juego real
        Rayfield:Notify({
            Title = "Casa Copiada",
            Content = "Datos de la casa han sido copiados",
            Duration = 3,
            Image = 4483362458,
        })
        
        -- Simular datos de ejemplo
        CopiedHouseData.FurnitureCount = math.random(10, 50)
        CopiedHouseData.TotalValue = math.random(1000, 50000)
        CopiedHouseData.FurnitureList = {"Cama", "Sofá", "Mesa", "Silla", "Lámpara"}
        
        -- Actualizar la interfaz con los nuevos datos
        if StatsLabel then
            StatsLabel:Set("Muebles: " .. CopiedHouseData.FurnitureCount .. " | Valor: $" .. CopiedHouseData.TotalValue)
        end
    end,
})

-- Sección para pegar casa
MainTab:CreateSection("Pegar Casa")

-- Botón para pegar casa (simulado)
MainTab:CreateButton({
    Name = "Pegar Casa Copiada",
    Callback = function()
        if CopiedHouseData.FurnitureCount == 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "No hay datos de casa copiada",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        -- Simular pegado de casa
        Rayfield:Notify({
            Title = "Casa Pegada",
            Content = "Se pegaron " .. CopiedHouseData.FurnitureCount .. " muebles por valor total de $" .. CopiedHouseData.TotalValue,
            Duration = 5,
            Image = 4483362458,
        })
    end,
})

-- Sección de estadísticas
MainTab:CreateSection("Estadísticas de la Casa")

-- Label para mostrar estadísticas
local StatsLabel = MainTab:CreateLabel("Muebles: 0 | Valor: $0")

-- Botón para actualizar estadísticas
MainTab:CreateButton({
    Name = "Actualizar Estadísticas",
    Callback = function()
        -- Simular actualización de estadísticas
        Rayfield:Notify({
            Title = "Estadísticas Actualizadas",
            Content = "Los datos han sido recalculados",
            Duration = 2,
            Image = 4483362458,
        })
        
        StatsLabel:Set("Muebles: " .. CopiedHouseData.FurnitureCount .. " | Valor: $" .. CopiedHouseData.TotalValue)
    end,
})

-- Sección de herramientas adicionales
MainTab:CreateSection("Herramientas")

-- Toggle para modo avanzado (ejemplo)
MainTab:CreateToggle({
    Name = "Modo Avanzado",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Modo Avanzado Activado",
                Content = "Funciones adicionales disponibles",
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "Modo Avanzado Desactivado",
                Content = "Funciones básicas activas",
                Duration = 2,
            })
        end
    end,
})

-- Input para nombre personalizado
MainTab:CreateInput({
    Name = "Nombre de la Casa",
    PlaceholderText = "Ingresa un nombre para la casa",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text ~= "" then
            Rayfield:Notify({
                Title = "Nombre Guardado",
                Content = "Casa renombrada a: " .. Text,
                Duration = 3,
            })
        end
    end,
})

-- Divider
MainTab:CreateDivider()

-- Sección de información
MainTab:CreateSection("Información")

-- Label informativa
MainTab:CreateLabel("Esta interfaz es una demostración de Rayfield\nNo interactúa con el juego real")

-- Notificación inicial
Rayfield:Notify({
    Title = "Adopt Me House Manager",
    Content = "Interfaz cargada correctamente",
    Duration = 5,
    Image = 4483362458,
})

print("Interfaz de gestión de casas cargada exitosamente")
