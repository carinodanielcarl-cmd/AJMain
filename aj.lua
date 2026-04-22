local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local UI_NAME = "AJGODZX_GUI"

-- [[ SETTINGS ]] --
local AJGODZX_SETTINGS = {
    -- EXAMPLES:
    -- JSONBin: "https://api.jsonbin.io/v3/b/YOUR_BIN_ID/latest"
    -- GitHub:  "https://raw.githubusercontent.com/user/repo/main/findings.json"
    DATA_URL = "https://api.npoint.io/3b590339f6bef0db0dfd", 
    RETRY_DELAY = 2,
    THEME_ACCENT = Color3.fromRGB(0, 255, 200),
    AUTO_JOIN_DEFAULT = false,
}

local CUSTOM_URL = AJGODZX_SETTINGS.DATA_URL

-- Cleanup previous instance
if CoreGui:FindFirstChild(UI_NAME) then
    CoreGui[UI_NAME]:Destroy()
end
if SoundService:FindFirstChild("AJGODZXNotifSound") then
    SoundService.AJGODZXNotifSound:Destroy()
end

local lp = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local TARGET_SCALE = isMobile and 0.8 or 1.0
local HIDE_SCALE = TARGET_SCALE - 0.15

-- GUI Creation
local Gui = Instance.new("ScreenGui")
Gui.Name = UI_NAME
Gui.Parent = CoreGui
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Moby-Style Theme
local T = {
    BgDark = Color3.fromRGB(5, 5, 5),
    BgMid = Color3.fromRGB(12, 12, 12),
    BgCard = Color3.fromRGB(20, 20, 20),
    BgCardHover = Color3.fromRGB(28, 28, 28),
    Sidebar = Color3.fromRGB(8, 8, 8),
    Accent1 = Color3.fromRGB(0, 255, 200), -- Sleek Cyan
    Accent2 = Color3.fromRGB(0, 200, 255), -- Deep Cyan
    White = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Off = Color3.fromRGB(30, 30, 30),
    Green = Color3.fromRGB(0, 255, 128),
    GreenDim = Color3.fromRGB(0, 50, 30),
    Red = Color3.fromRGB(255, 60, 70),
    Yellow = Color3.fromRGB(255, 220, 0),
    HighlightC = Color3.fromRGB(0, 255, 255),
    MidlightC = Color3.fromRGB(0, 150, 255),
    Orange = Color3.fromRGB(255, 120, 0),
}

-- User Settings
local userSettings = {
    Midlights = true,
    Highlights = true,
    AutoJoin = false,
    AutoJoinRetries = 3,
    PlaySound = true,
    ToggleKey = "RightShift",
    UseWhitelist = false,
    Whitelist = {}
}

-- Auto Save Config
local CONFIG_FILE = "AJGODZX_Config.json"
pcall(function()
    if isfile and readfile and isfile(CONFIG_FILE) then
        local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(saved) == "table" then
            for k, v in pairs(saved) do
                if k == "Whitelist" and type(v) == "table" then
                    for wk, wv in pairs(v) do
                        userSettings.Whitelist[wk] = wv
                    end
                else
                    userSettings[k] = v
                end
            end
        end
    end
end)

task.spawn(function()
    local lastSave = HttpService:JSONEncode(userSettings)
    while _G.AJGODZXRunning ~= false do
        task.wait(3)
        pcall(function()
            local current = HttpService:JSONEncode(userSettings)
            if current ~= lastSave then
                if writefile then
                    writefile(CONFIG_FILE, current)
                end
                lastSave = current
            end
        end)
    end
end)

-- Complete Brainrot List
local allBrainrots = {
    "Los Nooo My Hotspotsitos", "Serafinna Medusella", "La Grande Combinassion",
    "La Easter Grande", "Rang Ring Bus", "Guest 666", "Los Mi Gatitos",
    "Los Chicleteiras", "Noo My Eggs", "67", "Donkeyturbo Express",
    "Mariachi Corazoni", "Los Burritos", "Los 25", "Tacorillo Crocodillo",
    "Swag Soda", "Noo my Heart", "Chimnino", "Los Combinasionas",
    "Chicleteira Noelteira", "Fishino Clownino", "Baskito", "Tacorita Bicicleta",
    "Los Sweethearts", "Spinny Hammy", "Nuclearo Dinosauro", "Las Sis",
    "DJ Panda", "Chicleteira Cupideira", "La Karkerkar Combinasion",
    "Chillin Chili", "Chipso and Queso", "Money Money Reindeer",
    "Money Money Puggy", "Churrito Bunnito", "Celularcini Viciosini",
    "Los Planitos", "Los Mobilis", "Los 67", "Mieteteira Bicicleteira",
    "Tuff Toucan", "La Spooky Grande", "Los Spooky Combinasionas",
    "Cigno Fulgoro", "Los Candies", "Los Hotspositos", "Los Jolly Combinasionas",
    "Los Cupids", "Los Puggies", "W or L", "Tralalalaledon", "La Extinct Grande Combinasion",
    "Tralaledon", "La Jolly Grande", "Los Primos", "Bacuru and Egguru",
    "Eviledon", "Los Tacoritas", "Lovin Rose", "Tang Tang Kelentang",
    "Ketupat Kepat", "Los Bros", "Tictac Sahur", "La Romantic Grande",
    "Gingerat Gerat", "Orcaledon", "La Lucky Grande", "Ketchuru and Masturu",
    "Jolly Jolly Sahur", "Garama and Madundung", "Rosetti Tualetti",
    "Nacho Spyder", "Hopilikalika Hopilikalako", "Festive 67", "Sammyni Fattini",
    "Love Love Bear", "La Ginger Sekolah", "Spooky and Pumpky", "Boppin Bunny",
    "Lavadorito Spinito", "La Food Combinasion", "Los Spaghettis", "La Casa Boo",
    "Fragrama and Chocrama", "Los Sekolahs", "Foxini Lanternini", "La Secret Combinasion",
    "Los Amigos", "Reinito Sleighito", "Ketupat Bros", "Burguro and Fryuro",
    "Cooki and Milki", "Capitano Moby", "Rosey and Teddy", "Popcuru and Fizzuru",
    "Hydra Bunny", "Celestial Pegasus", "Cerberus", "La Supreme Combinasion",
    "Dragon Cannelloni", "Dragon Gingerini", "Headless Horseman", "Hydra Dragon Cannelloni",
    "Griffin", "Skibidi Toilet", "Meowl", "Strawberry Elephant", "La Vacca Saturno Saturnita",
    "Pandanini Frostini", "Bisonte Giuppitere", "Blackhole Goat", "Jackorilla",
    "Agarrini Ia Palini", "Chachechi", "Karkerkar Kurkur", "Los Tortus", "Los Matteos",
    "Sammyni Spyderini", "Trenostruzzo Turbo 4000", "Chimpanzini Spiderini",
    "Boatito Auratito", "Fragola La La La", "Dul Dul Dul", "La Vacca Prese Presente",
    "Frankentteo", "Los Trios", "Karker Sahur", "Torrtuginni Dragonfrutini (Lucky Block)",
    "Los Tralaleritos", "Zombie Tralala", "La Cucaracha", "Vulturino Skeletono",
    "Guerriro Digitale", "Extinct Tralalero", "Yess My Examine", "Extinct Matteo",
    "Las Tralaleritas", "Rocco Disco", "Reindeer Tralala", "Las Vaquitas Saturnitas",
    "Pumpkin Spyderini", "Job Job Job Sahur", "Los Karkeritos", "Graipuss Medussi",
    "Santteo", "Fishboard", "Buntteo", "La Vacca Jacko Linterino", "Triplito Tralaleritos",
    "Trickolino", "Paradiso Axolottino", "GOAT", "Giftini Spyderini", "Los Spyderinis",
    "Love Love Love Sahur", "Perrito Burrito", "1x1x1x1", "Los Cucarachas",
    "Easter Easter Sahur", "Please My Present", "Cuadramat and Pakrahmatmamat",
    "Los Jobcitos", "Nooo My Hotspot", "Pot Hotspot (Lucky Block)", "Noo My Examine",
    "Telemorte", "La Sahur Combinasion", "List List List Sahur", "Bunny Bunny Bunny Sahur",
    "To To To Sahur", "Pirulitoita Bicicletaire", "25", "Santa Hotspot", "Horegini Boom",
    "Quesadilla Crocodila", "Pot Pumpkin", "Naughty Naughty", "Cupid Cupid Sahur",
    "Ho Ho Ho Sahur", "Mi Gatito", "Chicleteira Bicicleteira", "Eid Eid Eid Sahur",
    "Cupid Hotspot", "Spaghetti Tualetti (Lucky Block)", "Esok Sekolah (Lucky Block)",
    "Quesadillo Vampiro", "Brunito Marsito", "Chill Puppy", "Burrito Bandito",
    "Chicleteirina Bicicleteirina", "Granny", "Los Bunitos", "Los Quesadillas",
    "Bunito Bunito Spinito", "Noo My Candy"
}

-- Removed Discord Tag Logic as requested

-- Notification Sound
local NotifSound = Instance.new("Sound")
NotifSound.Name = "AJGODZXNotifSound"
NotifSound.SoundId = "rbxassetid://4590662766"
NotifSound.Volume = 0.7
NotifSound.Parent = SoundService

local function playNotifSound()
    if userSettings.PlaySound then
        NotifSound:Play()
    end
end

local function playClick()
    pcall(function()
        local click = Instance.new("Sound")
        click.SoundId = "rbxassetid://4590662766"
        click.Volume = 0.2
        click.Parent = Gui
        click:Play()
        task.delay(0.5, function() click:Destroy() end)
    end)
end

local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1000000 then
        local formatted = string.format("%.1fM", n / 1000000)
        return formatted:gsub("%.0M", "M")
    elseif n >= 1000 then
        local formatted = string.format("%.1fK", n / 1000)
        return formatted:gsub("%.0K", "K")
    else
        return tostring(n)
    end
end

-- ========== JOIN STATUS POPUP ==========
local function showJoinStatus(message, statusType)
    -- Create status popup
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 300, 0, 60)
    popup.Position = UDim2.new(0.5, -150, 0.7, 0)
    popup.BackgroundColor3 = T.BgMid
    popup.BackgroundTransparency = 0.1
    popup.Parent = Gui
    popup.ZIndex = 20
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)
    
    -- Set color based on status
    local statusColor = T.Accent1
    local icon = "🔄"
    if statusType == "success" then
        statusColor = T.Green
        icon = "✅"
    elseif statusType == "error" then
        statusColor = T.Red
        icon = "❌"
    elseif statusType == "warning" then
        statusColor = T.Yellow
        icon = "⚠️"
    elseif statusType == "loading" then
        statusColor = T.Accent1
        icon = "🔄"
    end
    
    local stroke = Instance.new("UIStroke", popup)
    stroke.Color = statusColor
    stroke.Thickness = 2
    
    local iconLabel = Instance.new("TextLabel", popup)
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 5, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = statusColor
    iconLabel.TextSize = 24
    iconLabel.Font = Enum.Font.GothamBold
    
    local msgLabel = Instance.new("TextLabel", popup)
    msgLabel.Size = UDim2.new(1, -50, 1, 0)
    msgLabel.Position = UDim2.new(0, 50, 0, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = T.White
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.GothamSemibold
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animate in
    popup.BackgroundTransparency = 1
    stroke.Transparency = 1
    iconLabel.TextTransparency = 1
    msgLabel.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(iconLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(msgLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Auto destroy after 3 seconds
    task.delay(3, function()
        if popup and popup.Parent then
            TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(msgLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.delay(0.3, function() popup:Destroy() end)
        end
    end)
    
    return popup
end

-- ========== FLAG BUTTON ==========
local FlagButton = Instance.new("TextButton")
FlagButton.Name = "FlagButton"
FlagButton.Size = UDim2.new(0, 50, 0, 50)
FlagButton.Position = UDim2.new(0, 15, 0.5, -25)
FlagButton.BackgroundColor3 = T.BgCard
FlagButton.BackgroundTransparency = 0.1
FlagButton.Text = "AJ"
FlagButton.Font = Enum.Font.GothamBlack
FlagButton.TextSize = 28
FlagButton.TextColor3 = T.White
FlagButton.Parent = Gui
FlagButton.ZIndex = 10

local FlagCorner = Instance.new("UICorner", FlagButton)
FlagCorner.CornerRadius = UDim.new(1, 0)
local FlagStroke = Instance.new("UIStroke", FlagButton)
FlagStroke.Color = T.Accent1
FlagStroke.Thickness = 2

local FlagGlow = Instance.new("Frame", FlagButton)
FlagGlow.Size = UDim2.new(1.2, 0, 1.2, 0)
FlagGlow.Position = UDim2.new(-0.1, 0, -0.1, 0)
FlagGlow.BackgroundColor3 = T.Accent1
FlagGlow.BackgroundTransparency = 0.8
FlagGlow.ZIndex = 0
local GlowCorner = Instance.new("UICorner", FlagGlow)
GlowCorner.CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while _G.AJGODZXRunning do
        TweenService:Create(FlagGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(1.3, 0, 1.3, 0),
            Position = UDim2.new(-0.15, 0, -0.15, 0)
        }):Play()
        task.wait(1)
        TweenService:Create(FlagGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 0.85,
            Size = UDim2.new(1.2, 0, 1.2, 0),
            Position = UDim2.new(-0.1, 0, -0.1, 0)
        }):Play()
        task.wait(1)
    end
end)

-- MAIN FRAME
local Main = Instance.new("CanvasGroup")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 606, 0, 365)
Main.Position = UDim2.new(0.5, -303, 0.5, -182)
Main.BackgroundColor3 = T.BgDark
Main.BorderSizePixel = 0
Main.GroupTransparency = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 9)
local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = TARGET_SCALE

-- DRAG SYSTEM
local dragging = false
local dragStart = nil
local startPos = nil
local dragInput = nil

local function updateDrag(input)
    if not dragging or not dragStart or not startPos then return end
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        TweenService:Create(MainScale, TweenInfo.new(0.15), {Scale = TARGET_SCALE * 0.98}):Play()
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput then updateDrag(input) end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        TweenService:Create(MainScale, TweenInfo.new(0.2), {Scale = TARGET_SCALE}):Play()
    end
end)

-- HEADER
local TitleLabel = Instance.new("TextLabel", Main)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.Size = UDim2.new(0, 200, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "AJGODZX"

-- Title Pulse Animation
task.spawn(function()
    while _G.AJGODZXRunning do
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = T.Accent1}):Play()
        task.wait(1.5)
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = T.White}):Play()
        task.wait(1.5)
    end
end)
TitleLabel.TextColor3 = T.White
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local SubLabel = Instance.new("TextLabel", Main)
SubLabel.BackgroundTransparency = 1
SubLabel.Position = UDim2.new(0, 15, 0, 35)
SubLabel.Size = UDim2.new(0, 150, 0, 20)
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.Text = "Private Server Joiner"
SubLabel.TextColor3 = T.TextDim
SubLabel.TextSize = 14
SubLabel.TextXAlignment = Enum.TextXAlignment.Left

-- CONNECTION STATUS
local StatusIndicator = Instance.new("Frame", Main)
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.Position = UDim2.new(0, 165, 0, 42)
StatusIndicator.BackgroundColor3 = T.Red
Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel", Main)
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 178, 0, 36)
StatusText.Size = UDim2.new(0, 100, 0, 20)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Disconnected"
StatusText.TextColor3 = T.TextDim
StatusText.TextSize = 11
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- TOP CONTROLS
local TopControls = Instance.new("Frame", Main)
TopControls.BackgroundColor3 = T.BgMid
TopControls.AnchorPoint = Vector2.new(1, 0)
TopControls.Position = UDim2.new(1, -15, 0, 10)
TopControls.Size = UDim2.new(0, 64, 0, 30)
Instance.new("UICorner", TopControls).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", TopControls).Color = T.Off

local TopLayout = Instance.new("UIListLayout", TopControls)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.Padding = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton", TopControls)
MinBtn.BackgroundTransparency = 1
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Text = "−"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = T.White
MinBtn.TextSize = 18

local CloseBtn = Instance.new("TextButton", TopControls)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
CloseBtn.TextSize = 14

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.Position = UDim2.new(0, 0, 0, 65)
Sidebar.Size = UDim2.new(0, 155, 1, -65)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 9)

-- SIDEBAR BUTTONS
local sidebarButtons = {}
local currentFilter = "all"

local function createSidebarBtn(text, yPos, filterKey)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 135, 0, 32)
    btn.BackgroundColor3 = (filterKey == "all") and T.Accent1 or T.BgCard
    btn.Text = text
    btn.TextColor3 = T.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local padding = Instance.new("UIPadding", btn)
    padding.PaddingLeft = UDim.new(0, 14)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = (filterKey == "all") and T.Accent1 or T.Off
    
    sidebarButtons[filterKey] = {btn = btn, stroke = stroke}
    
    btn.MouseButton1Click:Connect(function()
        playClick()
        currentFilter = filterKey
        for k, v in pairs(sidebarButtons) do
            local isActive = (k == filterKey)
            TweenService:Create(v.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = isActive and T.Accent1 or T.BgCard
            }):Play()
            TweenService:Create(v.stroke, TweenInfo.new(0.15), {
                Color = isActive and T.Accent1 or T.Off
            }):Play()
        end
        applyFilter()
    end)
end

createSidebarBtn("📋 All Logs", 10, "all")
createSidebarBtn("🏆 100m+", 48, "100m")
createSidebarBtn("⭐ 50m+", 86, "50m")
createSidebarBtn("💎 10m+", 124, "10m")

-- Auto Join Button
local AutoJoinBtn = Instance.new("TextButton", Sidebar)
AutoJoinBtn.Position = UDim2.new(0, 10, 0, 180)
AutoJoinBtn.Size = UDim2.new(0, 135, 0, 38)
AutoJoinBtn.BackgroundColor3 = userSettings.AutoJoin and T.Green or T.BgCard
AutoJoinBtn.Text = userSettings.AutoJoin and "✅ AUTO JOIN ON" or "⚡ AUTO JOIN OFF"
AutoJoinBtn.TextColor3 = T.White
AutoJoinBtn.Font = Enum.Font.GothamBold
AutoJoinBtn.TextSize = 11
Instance.new("UICorner", AutoJoinBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", AutoJoinBtn).Color = T.Off

AutoJoinBtn.MouseButton1Click:Connect(function()
    playClick()
    userSettings.AutoJoin = not userSettings.AutoJoin
    AutoJoinBtn.Text = userSettings.AutoJoin and "✅ AUTO JOIN ON" or "⚡ AUTO JOIN OFF"
    TweenService:Create(AutoJoinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = userSettings.AutoJoin and T.Green or T.BgCard
    }):Play()
end)

-- CONTENT AREA
local ContentArea = Instance.new("Frame", Main)
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 165, 0, 65)
ContentArea.Size = UDim2.new(1, -175, 1, -75)

-- LOGS SCROLLING FRAME
local LogScroll = Instance.new("ScrollingFrame", ContentArea)
LogScroll.Active = true
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.Size = UDim2.new(1, 0, 1, 0)
LogScroll.ScrollBarThickness = 2
LogScroll.ScrollBarImageColor3 = T.Off
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LogLayout = Instance.new("UIListLayout", LogScroll)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 6)

local LogEntries = {}
local RenderedIDs = {}
local hlCount, mlCount = 0, 0

local function applyFilter()
    for _, entry in ipairs(LogEntries) do
        local val = entry.NumericValue
        if currentFilter == "all" then
            entry.UI.Visible = true
        elseif currentFilter == "100m" then
            entry.UI.Visible = (val >= 100000000)
        elseif currentFilter == "50m" then
            entry.UI.Visible = (val >= 50000000 and val < 100000000)
        elseif currentFilter == "10m" then
            entry.UI.Visible = (val >= 10000000 and val < 50000000)
        else
            entry.UI.Visible = false
        end
    end
end

-- ========== JOINING SYSTEM WITH STATUS FEEDBACK ==========
local currentlyJoining = false
local joinQueue = {}
local lastJoinedId = nil

local function joinPrivateServer(jobId, showStatus)
    if not jobId or jobId == "" then 
        if showStatus then showJoinStatus("❌ Invalid Server ID!", "error") end
        return false 
    end
    
    if lastJoinedId == jobId then 
        if showStatus then showJoinStatus("⚠️ Already attempted this server!", "warning") end
        return false 
    end
    
    if showStatus then
        showJoinStatus("🔄 Attempting to join server...", "loading")
    end
    
    local success = false
    local errorMsg = ""
    
    -- Method 1: TeleportToPrivateServer
    local success1, err1 = pcall(function()
        TeleportService:TeleportToPrivateServer(game.PlaceId, jobId, {lp})
    end)
    
    if success1 then
        success = true
        if showStatus then showJoinStatus("✅ Teleporting to server...", "success") end
        lastJoinedId = jobId
        return true
    else
        errorMsg = err1 or "Unknown error"
    end
    
    -- Method 2: TeleportOptions
    local success2, err2 = pcall(function()
        local options = Instance.new("TeleportOptions")
        options.ReservedServerAccessCode = jobId
        TeleportService:Teleport(game.PlaceId, lp, options)
    end)
    
    if success2 then
        success = true
        if showStatus then showJoinStatus("✅ Teleporting to server...", "success") end
        lastJoinedId = jobId
        return true
    else
        errorMsg = err2 or "Unknown error"
    end
    
    -- Method 3: TeleportToPlaceInstance
    local success3, err3 = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, lp)
    end)
    
    if success3 then
        success = true
        if showStatus then showJoinStatus("✅ Teleporting to server...", "success") end
        lastJoinedId = jobId
        return true
    else
        errorMsg = err3 or "Unknown error"
    end
    
    -- If all methods failed
    if showStatus then
        if string.find(errorMsg:lower(), "full") or string.find(errorMsg:lower(), "capacity") then
            showJoinStatus("❌ Server is FULL! Cannot join.", "error")
        elseif string.find(errorMsg:lower(), "private") then
            showJoinStatus("❌ Invalid private server code.", "error")
        else
            showJoinStatus("❌ Failed to join server. Server may be full or invalid.", "error")
        end
    end
    
    return false
end

local function processQueue()
    if currentlyJoining then return end
    if #joinQueue == 0 then return end
    
    local nextJob = table.remove(joinQueue, 1)
    if nextJob then
        currentlyJoining = true
        
        task.spawn(function()
            local attempts = tonumber(userSettings.AutoJoinRetries) or 3
            for i = 1, attempts do
                if not _G.AEZYRunning then break end
                if joinPrivateServer(nextJob, i == 1) then
                    break
                end
                if i < attempts then
                    showJoinStatus("🔄 Retry " .. i .. "/" .. attempts .. "...", "loading")
                    task.wait(1.5)
                end
            end
            currentlyJoining = false
            task.wait(0.5)
            processQueue()
        end)
    end
end

local function queueJoin(jobId, showStatus)
    if not jobId or jobId == "" then return end
    if lastJoinedId == jobId then 
        if showStatus then showJoinStatus("⚠️ Already attempted this server recently!", "warning") end
        return 
    end
    
    if #joinQueue > 10 then
        table.remove(joinQueue, 1)
    end
    
    table.insert(joinQueue, jobId)
    if showStatus then
        showJoinStatus("📋 Server added to queue...", "loading")
    end
    processQueue()
end

-- CREATE LOG ENTRY
local function addLogEntry(data)
    local isHL = data.tier == "Highlights"
    local order
    if isHL then
        hlCount = hlCount + 1
        order = -200000 - hlCount
    else
        mlCount = mlCount + 1
        order = -100000 - mlCount
    end
    
    if RenderedIDs[data.id] then return end
    RenderedIDs[data.id] = true
    
    local LogItem = Instance.new("Frame", LogScroll)
    LogItem.BackgroundColor3 = T.BgCard
    LogItem.Size = UDim2.new(1, -10, 0, 52)
    LogItem.LayoutOrder = order
    Instance.new("UICorner", LogItem).CornerRadius = UDim.new(0, 8)
    
    local tierBar = Instance.new("Frame", LogItem)
    tierBar.Size = UDim2.new(0, 3, 0.7, 0)
    tierBar.Position = UDim2.new(0, 0, 0.15, 0)
    tierBar.BackgroundColor3 = isHL and T.HighlightC or T.MidlightC
    Instance.new("UICorner", tierBar).CornerRadius = UDim.new(1, 0)
    
    local Left = Instance.new("Frame", LogItem)
    Left.BackgroundTransparency = 1
    Left.Size = UDim2.new(0.6, 0, 1, 0)
    Left.Position = UDim2.new(0, 12, 0, 0)
    
    local NameLabel = Instance.new("TextLabel", Left)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 0, 0, 4)
    NameLabel.Size = UDim2.new(1, -10, 0, 16)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = "🏷️ " .. (data.name or "Unknown")
    NameLabel.TextColor3 = isHL and Color3.fromRGB(255, 200, 200) or T.White
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel", Left)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0, 0, 0, 20)
    ValueLabel.Size = UDim2.new(1, -10, 0, 12)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.Text = "💰 " .. (formatNumber(data.value or 0) .. "/s")
    ValueLabel.TextColor3 = isHL and T.HighlightC or T.MidlightC
    ValueLabel.TextSize = 10
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left

    local PlayersLabel = Instance.new("TextLabel", Left)
    PlayersLabel.BackgroundTransparency = 1
    PlayersLabel.Position = UDim2.new(0, 0, 0, 32)
    PlayersLabel.Size = UDim2.new(1, -10, 0, 12)
    PlayersLabel.Font = Enum.Font.Gotham
    PlayersLabel.Text = "👥 Players: " .. (data.players or "??/??")
    PlayersLabel.TextColor3 = T.TextDim
    PlayersLabel.TextSize = 9
    PlayersLabel.TextXAlignment = Enum.TextXAlignment.Left

    local JobLabel = Instance.new("TextLabel", Left)
    JobLabel.BackgroundTransparency = 1
    JobLabel.Position = UDim2.new(0, 0, 0, 44)
    JobLabel.Size = UDim2.new(1, -10, 0, 12)
    JobLabel.Font = Enum.Font.Gotham
    JobLabel.Text = "🆔 Job ID: " .. (data.job_id and data.job_id:sub(1,12).."..." or "N/A")
    JobLabel.TextColor3 = T.TextDim
    JobLabel.TextSize = 8
    JobLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Right = Instance.new("Frame", LogItem)
    Right.BackgroundTransparency = 1
    Right.Size = UDim2.new(0.4, 0, 1, 0)
    Right.Position = UDim2.new(0.6, 0, 0, 0)
    
    local JoinBtn = Instance.new("TextButton", Right)
    JoinBtn.BackgroundColor3 = T.Accent1
    JoinBtn.Position = UDim2.new(0, 5, 0.5, -14)
    JoinBtn.Size = UDim2.new(0, 55, 0, 28)
    JoinBtn.Font = Enum.Font.GothamBold
    JoinBtn.Text = "JOIN"
    JoinBtn.TextColor3 = T.White
    JoinBtn.TextSize = 11
    Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 6)
    
    local CopyBtn = Instance.new("TextButton", Right)
    CopyBtn.BackgroundColor3 = T.Orange
    CopyBtn.Position = UDim2.new(0, 65, 0.5, -14)
    CopyBtn.Size = UDim2.new(0, 50, 0, 28)
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.Text = "COPY"
    CopyBtn.TextColor3 = T.White
    CopyBtn.TextSize = 10
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)
    
    table.insert(LogEntries, {UI = LogItem, NumericValue = data.value or 0})
    applyFilter()
    
    -- JOIN button with status feedback
    JoinBtn.MouseButton1Click:Connect(function()
        if data.job_id then
            playClick()
            -- Disable button temporarily
            JoinBtn.Text = "..."
            JoinBtn.BackgroundColor3 = T.Yellow
            
            task.spawn(function()
                queueJoin(data.job_id, true)
                task.wait(2)
                JoinBtn.Text = "JOIN"
                JoinBtn.BackgroundColor3 = T.Accent1
            end)
        else
            showJoinStatus("❌ No Job ID found for this server!", "error")
        end
    end)
    
    -- COPY button
    CopyBtn.MouseButton1Click:Connect(function()
        if data.job_id then
            playClick()
            pcall(function()
                if setclipboard then
                    setclipboard(data.job_id)
                    CopyBtn.Text = "✓"
                    CopyBtn.BackgroundColor3 = T.Green
                    showJoinStatus("✅ Job ID copied to clipboard!", "success")
                    task.delay(1.5, function()
                        CopyBtn.Text = "COPY"
                        CopyBtn.BackgroundColor3 = T.Orange
                    end)
                end
            end)
        end
    end)
end

-- NOTIFICATIONS
local NotifContainer = Instance.new("Frame", Gui)
NotifContainer.Name = "NotifContainer"
NotifContainer.BackgroundTransparency = 1
NotifContainer.Size = UDim2.new(0, 280, 1, -40)
NotifContainer.Position = UDim2.new(1, -295, 0, 20)

local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)

local function pushNotification(data)
    if not userSettings[data.tier] then return end
    playNotifSound()
    
    local isHL = data.tier == "Highlights"
    local notif = Instance.new("Frame", NotifContainer)
    notif.BackgroundColor3 = T.BgMid
    notif.Size = UDim2.new(1, 0, 0, 55)
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = isHL and T.HighlightC or T.MidlightC
    stroke.Thickness = 1
    
    local title = Instance.new("TextLabel", notif)
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Size = UDim2.new(1, -80, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.Text = data.name or "Unknown"
    title.TextColor3 = T.White
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    
    local valueText = Instance.new("TextLabel", notif)
    valueText.BackgroundTransparency = 1
    valueText.Position = UDim2.new(0, 15, 0, 28)
    valueText.Size = UDim2.new(1, -80, 0, 14)
    valueText.Font = Enum.Font.Gotham
    valueText.Text = formatNumber(data.value or 0) .. " · " .. (data.tier or "")
    valueText.TextColor3 = T.TextDim
    valueText.TextSize = 10
    valueText.TextXAlignment = Enum.TextXAlignment.Left
    
    local joinNotif = Instance.new("TextButton", notif)
    joinNotif.BackgroundColor3 = T.Accent1
    joinNotif.Position = UDim2.new(1, -65, 0.5, -12)
    joinNotif.Size = UDim2.new(0, 55, 0, 24)
    joinNotif.Font = Enum.Font.GothamBold
    joinNotif.Text = "JOIN"
    joinNotif.TextColor3 = T.White
    joinNotif.TextSize = 10
    Instance.new("UICorner", joinNotif).CornerRadius = UDim.new(0, 6)
    
    joinNotif.MouseButton1Click:Connect(function()
        if data.job_id then
            queueJoin(data.job_id, true)
        end
        notif:Destroy()
    end)
    
    notif.BackgroundTransparency = 0.1
    TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    
    task.delay(4, function()
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.delay(0.3, function() notif:Destroy() end)
        end
    end)
end

-- FLAG BUTTON TOGGLE
local uiVisible = true

FlagButton.MouseButton1Click:Connect(function()
    playClick()
    uiVisible = not uiVisible
    
    if uiVisible then
        Main.Visible = true
        TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = TARGET_SCALE}):Play()
        TweenService:Create(Main, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
    else
        local hideScale = TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = HIDE_SCALE})
        local hideFade = TweenService:Create(Main, TweenInfo.new(0.3), {GroupTransparency = 1})
        hideScale:Play()
        hideFade:Play()
        hideScale.Completed:Connect(function()
            Main.Visible = false
        end)
    end
end)

-- CLOSE & MIN
MinBtn.MouseButton1Click:Connect(function()
    playClick()
    uiVisible = false
    Main.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    playClick()
    _G.AJGODZXRunning = false
    local closeScale = TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = HIDE_SCALE})
    local closeFade = TweenService:Create(Main, TweenInfo.new(0.3), {GroupTransparency = 1})
    closeScale:Play()
    closeFade:Play()
    closeScale.Completed:Wait()
    Gui:Destroy()
    if SoundService:FindFirstChild("AJGODZXNotifSound") then
        SoundService.AJGODZXNotifSound:Destroy()
    end
end)

-- KEYBOARD TOGGLE
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode.Name == userSettings.ToggleKey then
        uiVisible = not uiVisible
        if uiVisible then
            Main.Visible = true
            TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = TARGET_SCALE}):Play()
            TweenService:Create(Main, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
        else
            local hideScale = TweenService:Create(MainScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = HIDE_SCALE})
            local hideFade = TweenService:Create(Main, TweenInfo.new(0.3), {GroupTransparency = 1})
            hideScale:Play()
            hideFade:Play()
            hideScale.Completed:Connect(function()
                Main.Visible = false
            end)
        end
    end
end)

-- DATA FETCHING
_G.AJGODZXRunning = true
local URL = CUSTOM_URL
local seenIds = {}
local isFirstRun = true

local function handleData(findings)
    local newFindings = {}
    for _, d in ipairs(findings) do
        if not seenIds[d.id] then
            seenIds[d.id] = true
            table.insert(newFindings, d)
        end
    end
    
    table.sort(newFindings, function(a, b) return a.id < b.id end)
    
    if isFirstRun then
        isFirstRun = false
        return
    end
    
    for _, d in ipairs(newFindings) do
        addLogEntry(d)
        pushNotification(d)
        
        if userSettings.AutoJoin and d.job_id then
            local passesWhitelist = true
            if userSettings.UseWhitelist then
                if not d.base_name or not userSettings.Whitelist[d.base_name] then
                    passesWhitelist = false
                end
            end
            if passesWhitelist then
                queueJoin(d.job_id, false) -- No status for auto-join to avoid spam
            end
        end
    end
end

task.spawn(function()
    while _G.AJGODZXRunning do
        pcall(function()
            local reqUrl = URL .. "?t=" .. tostring(tick())
            local response
            
            if syn and syn.request then
                response = syn.request({Url = reqUrl, Method = "GET"})
            elseif request then
                response = request({Url = reqUrl, Method = "GET"})
            elseif http_request then
                response = http_request({Url = reqUrl, Method = "GET"})
            else
                response = {Body = game:HttpGet(reqUrl, true)}
            end
            
            if response and response.Body then
                local res = HttpService:JSONDecode(response.Body)
                -- Handle both direct array and {findings: []} wrapper from cloud
                local list = res.findings or res
                if type(list) == "table" and #list > 0 then
                    StatusIndicator.BackgroundColor3 = T.Green
                    StatusText.Text = "Connected"
                    handleData(list)
                else
                    StatusIndicator.BackgroundColor3 = T.Yellow
                    StatusText.Text = "No Findings"
                end
            else
                StatusIndicator.BackgroundColor3 = T.Red
                StatusText.Text = "Error"
            end
        end)
        task.wait(AJGODZX_SETTINGS.RETRY_DELAY)
    end
end)

print("========================================")
print("✅ AJGODZX LOADED!")
print("📋 Join status popup is active!")
print("========================================")