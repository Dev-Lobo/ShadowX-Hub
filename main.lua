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



local Toggle = MainTab:CreateToggle({
	Name = "Salto Infinito",
	CurrentValue = false,
	Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(InfiniteJumpEnabled)
        local InfiniteJumpEnabled = true
        game:GetService("UserInputService").JumpRequest:connect(function()
            if InfiniteJumpEnabled then
                game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
            end
        end)
	end,
})



local Slider = MainTab:CreateSlider({
	Name = "Velocidad al Caminar",
	Range = {10, 250},
	Increment = 10,
	Suffix = "Velocidad",
	CurrentValue = 10,
	Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(v)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
	end,
})



local Slider = MainTab:CreateSlider({
	Name = "Poder de Salto",
	Range = {10, 500},
	Increment = 10,
	Suffix = "Salto",
	CurrentValue = 10,
	Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(v)
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
	end,
})




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
