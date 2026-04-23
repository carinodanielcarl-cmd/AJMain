-- AJGODZX PREMIUM V2 (Unified Scanner & Joiner System)
-- Optimized for high-speed brainrot sniping with accurate identification

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local UI_NAME = "AJGODZX_GUI"
if CoreGui:FindFirstChild(UI_NAME) then CoreGui[UI_NAME]:Destroy() end
if SoundService:FindFirstChild("AJNotifSound") then SoundService.AJNotifSound:Destroy() end

local lp = Players.LocalPlayer
local STEAL_BRAINROT_PLACE_ID = 109983668079237
_G.AJRunning = true

-- ═══════════════════════════════════
-- THEME & SETTINGS
-- ═══════════════════════════════════
local T = {
    BgDark      = Color3.fromRGB(8, 12, 21),
    BgMid       = Color3.fromRGB(12, 18, 32),
    BgCard      = Color3.fromRGB(16, 24, 42),
    BgCardHover = Color3.fromRGB(22, 32, 56),
    Sidebar     = Color3.fromRGB(6, 10, 18),
    Accent1     = Color3.fromRGB(60, 130, 246),
    Accent2     = Color3.fromRGB(99, 179, 255),
    White       = Color3.fromRGB(240, 245, 255),
    TextDim     = Color3.fromRGB(120, 140, 175),
    Off         = Color3.fromRGB(30, 36, 52),
    Green       = Color3.fromRGB(45, 210, 110),
    Red         = Color3.fromRGB(220, 60, 70),
    HighlightC  = Color3.fromRGB(255, 75, 75),
    MidlightC   = Color3.fromRGB(80, 175, 255),
    Orange      = Color3.fromRGB(255, 165, 0)
}

local userSettings = {
    AutoJoin = false,
    AutoJoinRetries = 3,
    PlaySound = true,
    ToggleKey = "RightShift",
    UseWhitelist = false,
    Whitelist = {},
    HighlightsOnly = false
}

local CONFIG_FILE = "AJGODZX_Config.json"
local SHARED_URL = "https://api.npoint.io/3b590339f6bef0db0dfd"

-- [[ PERSISTENCE ]] --
pcall(function()
    if isfile and readfile and isfile(CONFIG_FILE) then
        local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(saved) == "table" then
            for k, v in pairs(saved) do
                if k == "Whitelist" and type(v) == "table" then
                    for wk, wv in pairs(v) do userSettings.Whitelist[wk] = wv end
                else
                    userSettings[k] = v
                end
            end
        end
    end
end)

task.spawn(function()
    local lastSave = HttpService:JSONEncode(userSettings)
    while _G.AJRunning do
        task.wait(3)
        pcall(function()
            local current = HttpService:JSONEncode(userSettings)
            if current ~= lastSave then
                if writefile then writefile(CONFIG_FILE, current) end
                lastSave = current
            end
        end)
    end
end)

-- [[ BRAINROT LIST ]] --
local allBrainrots = {
    "Los Nooo My Hotspotsitos", "Serafinna Medusella", "La Grande Combinassion", "La Easter Grande", "Rang Ring Bus", "Guest 666",
    "Los Mi Gatitos", "Los Chicleteiras", "Noo My Eggs", "67", "Donkeyturbo Express", "Mariachi Corazoni", "Los Burritos",
    "Los 25", "Tacorillo Crocodillo", "Swag Soda", "Noo my Heart", "Chimnino", "Los Combinasionas", "Chicleteira Noelteira",
    "Fishino Clownino", "Baskito", "Tacorita Bicicleta", "Los Sweethearts", "Spinny Hammy", "Nuclearo Dinosauro", "Las Sis",
    "DJ Panda", "Chicleteira Cupideira", "La Karkerkar Combinasion", "Chillin Chili", "Chipso and Queso", "Money Money Reindeer",
    "Money Money Puggy", "Churrito Bunnito", "Celularcini Viciosini", "Los Planitos", "Los Mobilis", "Los 67",
    "Mieteteira Bicicleteira", "Tuff Toucan", "La Spooky Grande", "Los Spooky Combinasionas", "Cigno Fulgoro", "Los Candies",
    "Los Hotspositos", "Los Jolly Combinasionas", "Los Cupids", "Los Puggies", "W or L", "Tralalalaledon",
    "La Extinct Grande Combinasion", "Tralaledon", "La Jolly Grande", "Los Primos", "Bacuru and Egguru", "Eviledon",
    "Los Tacoritas", "Lovin Rose", "Tang Tang Kelentang", "Ketupat Kepat", "Los Bros", "Tictac Sahur", "La Romantic Grande",
    "Gingerat Gerat", "Orcaledon", "La Lucky Grande", "Ketchuru and Masturu", "Jolly Jolly Sahur", "Garama and Madundung",
    "Rosetti Tualetti", "Nacho Spyder", "Hopilikalika Hopilikalako", "Festive 67", "Sammyni Fattini", "Love Love Bear",
    "La Ginger Sekolah", "Spooky and Pumpky", "Boppin Bunny", "Lavadorito Spinito", "La Food Combinasion", "Los Spaghettis",
    "La Casa Boo", "Fragrama and Chocrama", "Los Sekolahs", "Foxini Lanternini", "La Secret Combinasion", "Los Amigos",
    "Reinito Sleighito", "Ketupat Bros", "Burguro and Fryuro", "Cooki and Milki", "Capitano Moby", "Rosey and Teddy",
    "Popcuru and Fizzuru", "Hydra Bunny", "Celestial Pegasus", "Cerberus", "La Supreme Combinasion", "Dragon Cannelloni",
    "Dragon Gingerini", "Headless Horseman", "Hydra Dragon Cannelloni", "Griffin", "Skibidi Toilet", "Meowl",
    "Strawberry Elephant", "La Vacca Saturno Saturnita", "Pandanini Frostini", "Bisonte Giuppitere", "Blackhole Goat",
    "Jackorilla", "Agarrini Ia Palini", "Chachechi", "Karkerkar Kurkur", "Los Tortus", "Los Matteos", "Sammyni Spyderini",
    "Trenostruzzo Turbo 4000", "Chimpanzini Spiderini", "Boatito Auratito", "Fragola La La La", "Dul Dul Dul",
    "La Vacca Prese Presente", "Frankentteo", "Los Trios", "Karker Sahur", "Torrtuginni Dragonfrutini (Lucky Block)",
    "Los Tralaleritos", "Zombie Tralala", "La Cucaracha", "Vulturino Skeletono", "Guerriro Digitale", "Extinct Tralalero",
    "Yess My Examine", "Extinct Matteo", "Las Tralaleritas", "Rocco Disco", "Reindeer Tralala", "Las Vaquitas Saturnitas",
    "Pumpkin Spyderini", "Job Job Job Sahur", "Los Karkeritos", "Graipuss Medussi", "Santteo", "Fishboard", "Buntteo",
    "La Vacca Jacko Linterino", "Triplito Tralaleritos", "Trickolino", "Paradiso Axolottino", "GOAT", "Giftini Spyderini",
    "Los Spyderinis", "Love Love Love Sahur", "Perrito Burrito", "1x1x1x1", "Los Cucarachas", "Easter Easter Sahur",
    "Please My Present", "Cuadramat and Pakrahmatmamat", "Los Jobcitos", "Nooo My Hotspot", "Pot Hotspot (Lucky Block)",
    "Noo My Examine", "Telemorte", "La Sahur Combinasion", "List List List Sahur", "Bunny Bunny Bunny Sahur", "To To To Sahur",
    "Pirulitoita Bicicletaire", "25", "Santa Hotspot", "Horegini Boom", "Quesadilla Crocodila", "Pot Pumpkin", "Naughty Naughty",
    "Cupid Cupid Sahur", "Ho Ho Ho Sahur", "Mi Gatito", "Chicleteira Bicicleteira", "Eid Eid Eid Sahur", "Cupid Hotspot",
    "Spaghetti Tualetti (Lucky Block)", "Esok Sekolah (Lucky Block)", "Quesadillo Vampiro", "Brunito Marsito", "Chill Puppy",
    "Burrito Bandito", "Chicleteirina Bicicleteirina", "Granny", "Los Bunitos", "Los Quesadillas", "Bunito Bunito Spinito",
    "Noo My Candy"
}

-- [[ UTILS ]] --
local NotifSound = Instance.new("Sound")
NotifSound.Name = "AJNotifSound"
NotifSound.SoundId = "rbxassetid://4590662766"
NotifSound.Volume = 1
NotifSound.Parent = SoundService

local function playNotifSound()
    if userSettings.PlaySound then NotifSound:Play() end
end

local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1000000 then
        return (string.format("%.1fM", n / 1000000)):gsub("%.0M", "M")
    elseif n >= 1000 then
        return (string.format("%.1fK", n / 1000)):gsub("%.0K", "K")
    end
    return tostring(n)
end

-- [[ GUI CONSTRUCTION ]] --
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = UI_NAME

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 580, 0, 380)
Main.Position = UDim2.new(0.5, -290, 1.5, 0)
Main.BackgroundColor3 = T.BgDark
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2
MainStroke.Color = T.Accent1
MainStroke.Transparency = 0.1

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 155, 1, 0)
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 45)
Logo.Position = UDim2.new(0, 0, 0, 8)
Logo.BackgroundTransparency = 1
Logo.Text = "AJGODZX"
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 24
Logo.TextColor3 = T.Accent2

local LogoSub = Instance.new("TextLabel", Sidebar)
LogoSub.Size = UDim2.new(1, 0, 0, 14)
LogoSub.Position = UDim2.new(0, 0, 0, 42)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "P R E M I U M"
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextSize = 9
LogoSub.TextColor3 = T.TextDim

-- Tab Pages
local LogsPage = Instance.new("Frame", Main)
LogsPage.Size = UDim2.new(1, -155, 1, 0)
LogsPage.Position = UDim2.new(0, 155, 0, 0)
LogsPage.BackgroundTransparency = 1

local SettingsPage = Instance.new("Frame", Main)
SettingsPage.Size = UDim2.new(1, -155, 1, 0)
SettingsPage.Position = UDim2.new(0, 155, 0, 0)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false

local WhitelistPage = Instance.new("Frame", Main)
WhitelistPage.Size = UDim2.new(1, -155, 1, 0)
WhitelistPage.Position = UDim2.new(0, 155, 0, 0)
WhitelistPage.BackgroundTransparency = 1
WhitelistPage.Visible = false

-- [[ TAB SYSTEM ]] --
local activeTab = "logs"
local tabButtons = {}

local function makeTabBtn(icon, text, yPos, key)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = T.BgCard
    btn.BackgroundTransparency = key == "logs" and 0 or 1
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -15, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = icon .. "  " .. text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = key == "logs" and T.White or T.TextDim
    
    tabButtons[key] = {btn = btn, lbl = lbl}
    return btn
end

local tLogs = makeTabBtn("📋", "Logs", 90, "logs")
local tSettings = makeTabBtn("⚙️", "Settings", 132, "settings")
local tWhitelist = makeTabBtn("🛡️", "Whitelist", 174, "whitelist")

local function switchTab(toKey)
    activeTab = toKey
    LogsPage.Visible = toKey == "logs"
    SettingsPage.Visible = toKey == "settings"
    WhitelistPage.Visible = toKey == "whitelist"
    for k, v in pairs(tabButtons) do
        local act = k == toKey
        TweenService:Create(v.btn, TweenInfo.new(0.2), {BackgroundTransparency = act and 0 or 1}):Play()
        v.lbl.TextColor3 = act and T.White or T.TextDim
    end
end

tLogs.MouseButton1Click:Connect(function() switchTab("logs") end)
tSettings.MouseButton1Click:Connect(function() switchTab("settings") end)
tWhitelist.MouseButton1Click:Connect(function() switchTab("whitelist") end)

-- [[ LOGS CONTENT ]] --
local TopBar = Instance.new("Frame", LogsPage)
TopBar.Size = UDim2.new(1, 0, 0, 55)
TopBar.BackgroundTransparency = 1

local ajPanel = Instance.new("Frame", TopBar)
ajPanel.Size = UDim2.new(1, -30, 0, 36)
ajPanel.Position = UDim2.new(0, 15, 0, 10)
ajPanel.BackgroundColor3 = T.BgCard
Instance.new("UICorner", ajPanel).CornerRadius = UDim.new(0, 8)

local ajLbl = Instance.new("TextLabel", ajPanel)
ajLbl.Size = UDim2.new(0, 150, 1, 0)
ajLbl.Position = UDim2.new(0, 12, 0, 0)
ajLbl.BackgroundTransparency = 1
ajLbl.Text = "AutoJoin Highest Value"
ajLbl.Font = Enum.Font.GothamBold
ajLbl.TextXAlignment = Enum.TextXAlignment.Left
ajLbl.TextSize = 12
ajLbl.TextColor3 = T.White

local ajTrack = Instance.new("TextButton", ajPanel)
ajTrack.Size = UDim2.new(0, 42, 0, 22)
ajTrack.Position = UDim2.new(1, -56, 0.5, -11)
ajTrack.BackgroundColor3 = userSettings.AutoJoin and T.Accent1 or T.Off
ajTrack.Text = ""
Instance.new("UICorner", ajTrack).CornerRadius = UDim.new(1, 0)

local ajDot = Instance.new("Frame", ajTrack)
ajDot.Size = UDim2.new(0, 16, 0, 16)
ajDot.Position = userSettings.AutoJoin and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
ajDot.BackgroundColor3 = T.White
Instance.new("UICorner", ajDot).CornerRadius = UDim.new(1, 0)

ajTrack.MouseButton1Click:Connect(function()
    userSettings.AutoJoin = not userSettings.AutoJoin
    local on = userSettings.AutoJoin
    TweenService:Create(ajDot, TweenInfo.new(0.15), {Position = on and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
    TweenService:Create(ajTrack, TweenInfo.new(0.15), {BackgroundColor3 = on and T.Accent1 or T.Off}):Play()
end)

local Content = Instance.new("ScrollingFrame", LogsPage)
Content.Size = UDim2.new(1, 0, 1, -55)
Content.Position = UDim2.new(0, 0, 0, 52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = T.Off

local CLayout = Instance.new("UIListLayout", Content)
CLayout.Padding = UDim.new(0, 6)
CLayout.SortOrder = Enum.SortOrder.LayoutOrder

Instance.new("UIPadding", Content).PaddingLeft = UDim.new(0, 15)
Instance.new("UIPadding", Content).PaddingRight = UDim.new(0, 15)

CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, CLayout.AbsoluteContentSize.Y + 10)
end)

-- [[ LOG ENTRY ]] --
local lastLogId = nil
local function addLogEntry(data)
    if data.id == lastLogId then return end
    lastLogId = data.id
    
    local isHL = data.tier == "Highlights"
    local card = Instance.new("Frame", Content)
    card.Size = UDim2.new(1, 0, 0, 55)
    card.BackgroundColor3 = T.BgCard
    card.LayoutOrder = -os.time()
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 0, 0.2, 0)
    bar.BackgroundColor3 = isHL and T.HighlightC or T.MidlightC
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local nameL = Instance.new("TextLabel", card)
    nameL.Size = UDim2.new(1, -135, 0, 20)
    nameL.Position = UDim2.new(0, 12, 0, 8)
    nameL.BackgroundTransparency = 1
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Text = data.name or "Unknown"
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 13
    nameL.TextColor3 = T.White
    
    local valL = Instance.new("TextLabel", card)
    valL.Size = UDim2.new(1, -135, 0, 14)
    valL.Position = UDim2.new(0, 12, 0, 28)
    valL.BackgroundTransparency = 1
    valL.TextXAlignment = Enum.TextXAlignment.Left
    valL.Text = formatNumber(data.value or 0) .. "  •  " .. (data.mutation or "Normal") .. "  •  " .. (data.players or "0/0")
    valL.Font = Enum.Font.Gotham
    valL.TextSize = 10
    valL.TextColor3 = isHL and T.HighlightC or T.MidlightC

    local jBtn = Instance.new("TextButton", card)
    jBtn.Size = UDim2.new(0, 55, 0, 28)
    jBtn.Position = UDim2.new(1, -65, 0.5, -14)
    jBtn.BackgroundColor3 = T.Accent1
    jBtn.Text = "JOIN"
    jBtn.Font = Enum.Font.GothamBold
    jBtn.TextSize = 11
    jBtn.TextColor3 = T.White
    Instance.new("UICorner", jBtn).CornerRadius = UDim.new(0, 6)

    jBtn.MouseButton1Click:Connect(function()
        TeleportService:TeleportToPlaceInstance(STEAL_BRAINROT_PLACE_ID, data.job_id, lp)
    end)
    
    playNotifSound()
end

-- [[ DATA SYNC ]] --
task.spawn(function()
    local seenIds = {}
    while _G.AJRunning do
        pcall(function()
            local res = game:HttpGet(SHARED_URL .. "?t=" .. tick())
            local data = HttpService:JSONDecode(res)
            if data and data.findings then
                for _, finding in ipairs(data.findings) do
                    if not seenIds[finding.id] then
                        seenIds[finding.id] = true
                        
                        -- Whitelist filter
                        local allowed = true
                        if userSettings.UseWhitelist then
                            allowed = userSettings.Whitelist[finding.base_name] or false
                        end
                        
                        if allowed then
                            addLogEntry(finding)
                            if userSettings.AutoJoin then
                                TeleportService:TeleportToPlaceInstance(STEAL_BRAINROT_PLACE_ID, finding.job_id, lp)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(2)
    end
end)

-- Intro Animation
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -290, 0.5, -190)}):Play()

-- [[ SETTINGS PAGE GENERATION ]] --
local function makeToggle(parent, text, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -30, 0, 42)
    f.Position = UDim2.new(0, 15, 0, 0)
    f.BackgroundColor3 = T.BgCard
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    Instance.new("UIListLayout", parent).Padding = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextColor3 = T.White
    
    local track = Instance.new("TextButton", f)
    track.Size = UDim2.new(0, 42, 0, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = userSettings[key] and T.Accent1 or T.Off
    track.Text = ""
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", track)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = userSettings[key] and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
    dot.BackgroundColor3 = T.White
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    track.MouseButton1Click:Connect(function()
        userSettings[key] = not userSettings[key]
        local on = userSettings[key]
        TweenService:Create(dot, TweenInfo.new(0.15), {Position = on and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
        TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = on and T.Accent1 or T.Off}):Play()
    end)
end

local SScroll = Instance.new("ScrollingFrame", SettingsPage)
SScroll.Size = UDim2.new(1, 0, 1, 0)
SScroll.BackgroundTransparency = 1
SScroll.BorderSizePixel = 0
Instance.new("UIPadding", SScroll).PaddingTop = UDim.new(0, 15)

makeToggle(SScroll, "Play Notification Sound", "PlaySound")
makeToggle(SScroll, "Highlights Only Mode", "HighlightsOnly")
makeToggle(SScroll, "Use Whitelist Filter", "UseWhitelist")

-- [[ WHITELIST PAGE GENERATION ]] --
local WLScroll = Instance.new("ScrollingFrame", WhitelistPage)
WLScroll.Size = UDim2.new(1, 0, 1, 0)
WLScroll.BackgroundTransparency = 1
WLScroll.BorderSizePixel = 0
Instance.new("UIListLayout", WLScroll).Padding = UDim.new(0, 5)
Instance.new("UIPadding", WLScroll).PaddingTop = UDim.new(0, 15)
Instance.new("UIPadding", WLScroll).PaddingLeft = UDim.new(0, 15)

for _, v in ipairs(allBrainrots) do
    local f = Instance.new("Frame", WLScroll)
    f.Size = UDim2.new(1, -30, 0, 34)
    f.BackgroundColor3 = T.BgCard
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = v
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextColor3 = T.White
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 45, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = userSettings.Whitelist[v] and T.Accent1 or T.Off
    btn.Text = userSettings.Whitelist[v] and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = T.White
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        userSettings.Whitelist[v] = not userSettings.Whitelist[v]
        btn.BackgroundColor3 = userSettings.Whitelist[v] and T.Accent1 or T.Off
        btn.Text = userSettings.Whitelist[v] and "ON" or "OFF"
    end)
end

print("✅ AJGODZX PREMIUM LOADED!")
