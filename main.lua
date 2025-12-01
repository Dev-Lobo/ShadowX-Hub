local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local MainWindow = Rayfield:CreateWindow({
	Name = "ShadowX Hub",
	LoadingTitle = "Cargando...",
	LoadingSubtitle = "by Lobo27",
	ConfigurationSaving = {
	   Enabled = true,
	   FolderName = nil, -- Create a custom folder for your hub/game
	   FileName = "ShadowX Hub"
	},
	Discord = {
	   Enabled = true,
	   Invite = "ZB79MM6DHj", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD.
	   RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	},
	KeySystem = true, -- Set this to true to use our key system
	KeySettings = {
	   Title = "ShadowX Hub",
	   Subtitle = "Key System",
	   Note = "Get a Key",
	   FileName = "SiriusKey",
	   SaveKey = true,
	   GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
	   Key = {"ShadowX", "ShadowY"}
	}
})


local MainTab = MainWindow:CreateTab("Principal", "map-pin") -- Title, Image
local HouseTab = MainWindow:CreateTab("House Cloner", "star") -- Title, Image
local ScannerTab = MainWindow:CreateTab("Scanner", "search") -- Title, Image
local SaveTab = MainWindow:CreateTab("Guardar", "file") -- Title, Image
local OthersTab = MainWindow:CreateTab("Otros", "circle-ellipsis") -- Title, Image


-- ========== OTROS ==========

local Button = OthersTab:CreateButton({
   Name = "Default Theme",
   Callback = function(Default)
    local Default = MainWindow.ModifyTheme('Default')
   -- The function that takes place when the button is pressed
   end,
})
local Button = OthersTab:CreateButton({
   Name = "Amber Glow Theme",
   Callback = function(AmberGlow)
    local AmberGlow = MainWindow.ModifyTheme('AmberGlow')
   -- The function that takes place when the button is pressed
   end,
})



-- ========== PRINCIPAL ==========

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

local walkSpeedValue = 10
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
    CurrentValue = 10,
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

local Label1 = HouseTab:CreateLabel("Furnitures count: 0", "sofa")
local Label2 = HouseTab:CreateLabel("Furnitures cost: 0$", "badge-dollar-sign")
local Label3 = HouseTab:CreateLabel("Textures cost: 0$", "paint-roller")
local Label4 = HouseTab:CreateLabel("Progress: 0%", "loader")

local Divider = HouseTab:CreateDivider()

local Input = HouseTab:CreateInput({
   Name = "House Pastebin",
   CurrentValue = "",
   PlaceholderText = "https://pastebin.com/",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
   -- The function that takes place when the input is changed
   -- The variable (Text) is a string for the value in the text box
   end,
})

local Button = HouseTab:CreateButton({
   Name = "Copy House",
   Callback = function(UpdateLabel1)
    local ftotal = 10
    local UpdateLabel1 = Label1:Set("Furnitures count: " .. ftotal)
   -- The function that takes place when the button is pressed
   end,
})

local Button = HouseTab:CreateButton({
   Name = "Paste House",
   Callback = function()
   -- The function that takes place when the button is pressed
   end,
})


-- ========== SCANNER ==========

local Label5 = ScannerTab:CreateLabel("Home Type: Tiny Home", "milestone")
local Button = ScannerTab:CreateButton({
   Name = "Scan House",
   Callback = function(scan_notify)
	local scan_notify = Rayfield:Notify({
       Title = "Scanning Home..",
       Content = "Starting Scan",
       Duration = 3.5,
       Image = "play",
    })
   end,
})







-- ========== CONSOLE MESSAGE ==========
print("ShadowX Hub ha cargado correctamente")
