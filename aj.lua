-- AJGODZX FIXED (Enhanced v2.0 with Auto-Clean)
-- Accurate detection with improved communication
-- Auto-clears old logs (keeps only last 20)

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local UI_NAME = "AJGODZX_FIXED"
if CoreGui:FindFirstChild(UI_NAME) then CoreGui[UI_NAME]:Destroy() end

local lp = Players.LocalPlayer
_G.AJRunning = true

-- Configuration
local SHARED_URL = "https://api.npoint.io/3b590339f6bef0db0dfd"
local MAX_LOGS = 20 -- Auto-clean: keeps only last 20 logs

-- Theme
local T = {
    BgDark      = Color3.fromRGB(10, 10, 20),
    BgCard      = Color3.fromRGB(18, 18, 30),
    Accent1     = Color3.fromRGB(0, 200, 255),
    White       = Color3.fromRGB(240, 245, 255),
    TextDim     = Color3.fromRGB(150, 150, 180),
    Off         = Color3.fromRGB(30, 30, 45),
    Green       = Color3.fromRGB(45, 210, 110),
    Orange      = Color3.fromRGB(255, 165, 0),
    Red         = Color3.fromRGB(255, 75, 75),
    Purple      = Color3.fromRGB(175, 75, 255),
}

local userSettings = {
    AutoJoin = false,
    PlaySound = true,
    Whitelist = {},
    MinValue = 0
}

local CONFIG_FILE = "AJGODZX_Settings.json"

-- Load saved settings
pcall(function()
    if isfile and readfile and isfile(CONFIG_FILE) then
        local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(saved) == "table" then
            for k, v in pairs(saved) do userSettings[k] = v end
        end
    end
end)

-- Auto-save
task.spawn(function()
    while _G.AJRunning do
        task.wait(5)
        pcall(function()
            if writefile then
                writefile(CONFIG_FILE, HttpService:JSONEncode(userSettings))
            end
        end)
    end
end)

-- Sound
local NotifSound = Instance.new("Sound")
NotifSound.SoundId = "rbxassetid://4590662766"
NotifSound.Volume = 0.5
NotifSound.Parent = SoundService

local function playNotifSound()
    if userSettings.PlaySound then
        pcall(function() NotifSound:Play() end)
    end
end

local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 100000000 then
        return string.format("%.1fM", n / 1000000):gsub("%.0M", "M")
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000):gsub("%.0K", "K")
    end
    return tostring(n)
end

local function getColorForValue(value)
    if value >= 100000000 then
        return T.Purple
    elseif value >= 50000000 then
        return T.Orange
    else
        return T.Accent1
    end
end

-- [[ GUI ]] --
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = UI_NAME

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 380, 0, 500)
Main.Position = UDim2.new(0.5, -190, 0.5, -250)
Main.BackgroundColor3 = T.BgDark
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = T.BgCard
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ AJGODZX PREMIUM (Auto-Clean)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = T.White
Title.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel", Header)
StatsLabel.Size = UDim2.new(1, -60, 0, 15)
StatsLabel.Position = UDim2.new(0, 20, 0, 30)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "Monitoring for brainrots... (Keeps last " .. MAX_LOGS .. " logs)"
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 9
StatsLabel.TextColor3 = T.TextDim
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -17.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = T.Red
CloseBtn.TextSize = 16
CloseBtn.MouseButton1Click:Connect(function() 
    _G.AJRunning = false
    Gui:Destroy() 
end)

-- Controls
local Controls = Instance.new("Frame", Main)
Controls.Size = UDim2.new(1, -20, 0, 70)
Controls.Position = UDim2.new(0, 10, 0, 60)
Controls.BackgroundTransparency = 1

local AutoJoinBtn = Instance.new("TextButton", Controls)
AutoJoinBtn.Size = UDim2.new(0.48, 0, 0, 35)
AutoJoinBtn.Position = UDim2.new(0, 0, 0, 0)
AutoJoinBtn.BackgroundColor3 = userSettings.AutoJoin and T.Green or T.Off
AutoJoinBtn.Text = "🔁 AUTO JOIN: " .. (userSettings.AutoJoin and "ON" or "OFF")
AutoJoinBtn.Font = Enum.Font.GothamBold
AutoJoinBtn.TextSize = 11
AutoJoinBtn.TextColor3 = T.White
Instance.new("UICorner", AutoJoinBtn).CornerRadius = UDim.new(0, 6)

AutoJoinBtn.MouseButton1Click:Connect(function()
    userSettings.AutoJoin = not userSettings.AutoJoin
    AutoJoinBtn.Text = "🔁 AUTO JOIN: " .. (userSettings.AutoJoin and "ON" or "OFF")
    AutoJoinBtn.BackgroundColor3 = userSettings.AutoJoin and T.Green or T.Off
end)

local SoundBtn = Instance.new("TextButton", Controls)
SoundBtn.Size = UDim2.new(0.48, 0, 0, 35)
SoundBtn.Position = UDim2.new(0.52, 0, 0, 0)
SoundBtn.BackgroundColor3 = userSettings.PlaySound and T.Green or T.Off
SoundBtn.Text = "🔊 SOUND: " .. (userSettings.PlaySound and "ON" or "OFF")
SoundBtn.Font = Enum.Font.GothamBold
SoundBtn.TextSize = 11
SoundBtn.TextColor3 = T.White
Instance.new("UICorner", SoundBtn).CornerRadius = UDim.new(0, 6)

SoundBtn.MouseButton1Click:Connect(function()
    userSettings.PlaySound = not userSettings.PlaySound
    SoundBtn.Text = "🔊 SOUND: " .. (userSettings.PlaySound and "ON" or "OFF")
    SoundBtn.BackgroundColor3 = userSettings.PlaySound and T.Green or T.Off
end)

-- Log List
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -155)
Content.Position = UDim2.new(0, 10, 0, 140)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = T.Accent1

local CLayout = Instance.new("UIListLayout", Content)
CLayout.Padding = UDim.new(0, 10)
CLayout.SortOrder = Enum.SortOrder.LayoutOrder

CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, CLayout.AbsoluteContentSize.Y + 10)
end)

-- Status Bar
local StatusBar = Instance.new("Frame", Main)
StatusBar.Size = UDim2.new(1, 0, 0, 25)
StatusBar.Position = UDim2.new(0, 0, 1, -25)
StatusBar.BackgroundColor3 = T.BgCard
StatusBar.BorderSizePixel = 0
Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0, 5)

local StatusText = Instance.new("TextLabel", StatusBar)
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Connected • Monitoring..."
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 10
StatusText.TextColor3 = T.TextDim
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- [[ LOG ENTRY ]] --
local function addLogEntry(data)
    if userSettings.MinValue > 0 and (data.value or 0) < userSettings.MinValue then
        return
    end
    
    local card = Instance.new("Frame", Content)
    card.Size = UDim2.new(1, 0, 0, 80)
    card.BackgroundColor3 = T.BgCard
    card.LayoutOrder = -os.time()
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local accentColor = getColorForValue(data.value or 0)
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0, 5, 1, 0)
    accent.BackgroundColor3 = accentColor
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
    
    local nameLabel = Instance.new("TextLabel", card)
    nameLabel.Size = UDim2.new(1, -120, 0, 22)
    nameLabel.Position = UDim2.new(0, 15, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.name or "Unknown"
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = T.White
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local detailsLabel = Instance.new("TextLabel", card)
    detailsLabel.Size = UDim2.new(1, -120, 0, 16)
    detailsLabel.Position = UDim2.new(0, 15, 0, 32)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = string.format("%s • %s", formatNumber(data.value or 0), data.mutation or "Normal")
    detailsLabel.Font = Enum.Font.GothamMedium
    detailsLabel.TextSize = 11
    detailsLabel.TextColor3 = T.TextDim
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Left    
    
    local timeLabel = Instance.new("TextLabel", card)
    timeLabel.Size = UDim2.new(1, -120, 0, 14)
    timeLabel.Position = UDim2.new(0, 15, 0, 50)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.TextSize = 10
    timeLabel.TextColor3 = T.TextDim
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    task.spawn(function()
        while card.Parent and _G.AJRunning do
            local diff = os.time() - (data.timestamp or os.time())
            local timeStr = diff < 60 and (diff .. "s ago") or 
                           (diff < 3600 and (math.floor(diff/60) .. "m ago")) or
                           (math.floor(diff/3600) .. "h ago")
            timeLabel.Text = "🕐 " .. timeStr
            task.wait(1)
        end
    end)
    
    local serverLabel = Instance.new("TextLabel", card)
    serverLabel.Size = UDim2.new(1, -120, 0, 12)
    serverLabel.Position = UDim2.new(0, 15, 0, 64)
    serverLabel.BackgroundTransparency = 1
    serverLabel.Text = "👥 " .. (data.players or "0/0")
    serverLabel.Font = Enum.Font.GothamMedium
    serverLabel.TextSize = 9
    serverLabel.TextColor3 = T.TextDim
    serverLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local joinBtn = Instance.new("TextButton", card)
    joinBtn.Size = UDim2.new(0, 55, 0, 30)
    joinBtn.Position = UDim2.new(1, -120, 0.5, -15)
    joinBtn.BackgroundColor3 = T.Accent1
    joinBtn.Text = "🚀 JOIN"
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.TextSize = 10
    joinBtn.TextColor3 = T.White
    Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 5)
    
    joinBtn.MouseButton1Click:Connect(function()
        if not data.job_id then return end
        joinBtn.Text = "🎯 ..."
        joinBtn.BackgroundColor3 = T.Orange
        task.wait(0.5)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(data.place_id or 109983668079237, data.job_id, lp)
        end)
    end)
    
    local copyBtn = Instance.new("TextButton", card)
    copyBtn.Size = UDim2.new(0, 55, 0, 30)
    copyBtn.Position = UDim2.new(1, -60, 0.5, -15)
    copyBtn.BackgroundColor3 = T.Off
    copyBtn.Text = "📋 COPY"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 10
    copyBtn.TextColor3 = T.White
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)
    
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(data.job_id or "")
            copyBtn.Text = "✓ COPIED"
            task.wait(1)
            copyBtn.Text = "📋 COPY"
        end
    end)
    
    -- Animate
    card.BackgroundTransparency = 1
    card:TweenPosition(UDim2.new(1, 50, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.1)
    card:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    card.BackgroundTransparency = 0
    
    playNotifSound()
    StatusText.Text = string.format("Found: %s • %s", data.name, formatNumber(data.value))
    task.wait(3)
    if StatusText.Text ~= "Connected • Monitoring..." then
        StatusText.Text = "Connected • Monitoring..."
    end
end

-- [[ DATA SYNC LOOP with AUTO-CLEAN ]] --
local processedIds = {}
local lastCleanup = tick()

task.spawn(function()
    while _G.AJRunning do
        pcall(function()
            local response = game:HttpGet(SHARED_URL .. "?t=" .. tick())
            local data = HttpService:JSONDecode(response)
            
            if data and data.findings then
                -- AUTO-CLEAN: If more than MAX_LOGS, clean it
                if #data.findings > MAX_LOGS then
                    while #data.findings > MAX_LOGS do
                        table.remove(data.findings)
                    end
                    -- Post cleaned data back
                    local body = HttpService:JSONEncode(data)
                    local requestFunc = syn and syn.request or request or http_request
                    if requestFunc then
                        requestFunc({
                            Url = SHARED_URL,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = body
                        })
                    end
                end
                
                -- Process findings
                for i = #data.findings, 1, -1 do
                    local finding = data.findings[i]
                    if finding and finding.id and not processedIds[finding.id] then
                        processedIds[finding.id] = true
                        addLogEntry(finding)
                        
                        if userSettings.AutoJoin then
                            task.wait(0.3)
                            local targetPlace = finding.place_id or 109983668079237
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(targetPlace, finding.job_id, lp)
                            end)
                            break
                        end
                    end
                end
            end
            
            -- Cleanup old IDs every 5 minutes
            if tick() - lastCleanup > 300 then
                local newIds = {}
                local count = 0
                for id, _ in pairs(processedIds) do
                    if count < 100 then
                        newIds[id] = true
                        count = count + 1
                    end
                end
                processedIds = newIds
                lastCleanup = tick()
            end
        end)
        
        task.wait(1.5)
    end
end)

print("✅ AJGODZX with Auto-Clean Loaded! (Keeps last " .. MAX_LOGS .. " logs)")
