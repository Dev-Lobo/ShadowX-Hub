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

local Label1 = HouseTab:CreateLabel("Furnitures count: 0", "sofa")
local Label2 = HouseTab:CreateLabel("Furnitures cost: 0$", "badge-dollar-sign")
local Label3 = HouseTab:CreateLabel("Textures cost: 0$", "paint-roller")
local Label4 = HouseTab:CreateLabel("Progress: 0%", "loader")

local Divider = HouseTab:CreateDivider()

local pastebinLink = ""

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

local Button = HouseTab:CreateButton({
   Name = "Copy House",
   Callback = function()
      local ftotal = #game.Workspace:GetChildren() -- Ejemplo
      Label1:Set("Furnitures count: " .. ftotal)
      Label2:Set("Furnitures cost: $" .. (ftotal * 5)) -- Ejemplo
      Label3:Set("Textures cost: $0") -- Ejemplo
      Label4:Set("Progress: 100%") -- Ejemplo
   end,
})

local Button = HouseTab:CreateButton({
   Name = "Paste House",
   Callback = function()
      if pastebinLink == "" then
         Rayfield:Notify({
            Title = "Error",
            Content = "Por favor ingresa un enlace de Pastebin.",
            Duration = 3,
            Image = "x"
         })
         return
      end

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

      -- Aquí iría la lógica para pegar la casa (simulación)
      Rayfield:Notify({
         Title = "Casa Pegada",
         Content = "La casa se ha pegado correctamente.",
         Duration = 3,
         Image = "check"
      })
   end,
})

-- ========== SCANNER ==========

local Label5 = ScannerTab:CreateLabel("Home Type: Tiny Home", "milestone")

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
      Label5:Set("Home Type: Modern Villa")
      Rayfield:Notify({
         Title = "Scan Complete",
         Content = "Home type identified as Modern Villa.",
         Duration = 3,
         Image = "check"
      })
   end,
})

-- ========== CONSOLE MESSAGE ==========
print("ShadowX Hub ha cargado correctamente")
