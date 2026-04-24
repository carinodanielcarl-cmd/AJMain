-- AJGODZX FIXED (Enhanced v2.0)
-- Accurate detection with improved communication

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

-- ═══════════════════════════════════
-- THEME & SETTINGS
-- ═══════════════════════════════════
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
    MinValue = 0 -- Minimum value to show
}

local CONFIG_FILE = "AJGODZX_Settings.json"
local SHARED_URL = "https://api.npoint.io/3b590339f6bef0db0dfd"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1496851695848657009/OCOh6ewiAsYMsSwvC0T-chTbt_hVvm64jAt919t5rXlhE4FGyssoAA5adTTb_TR_dQHr"

-- Load saved settings
pcall(function()
    if isfile and readfile then
        if isfile(CONFIG_FILE) then
            local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(saved) == "table" then
                for k, v in pairs(saved) do userSettings[k] = v end
            end
        end
    end
end)

-- Auto-save settings
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

-- [[ UTILITIES ]] --
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

-- Improved webhook sending
local function sendWebhook(data)
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    
    local colorValue = data.value >= 100000000 and 0xFF4B4B or 
                      (data.value >= 50000000 and 0xFFA500 or 0x00C8FF)
    
    local payload = {
        ["embeds"] = {{
            ["title"] = "🎯 Brainrot Detected!",
            ["description"] = string.format("**%s** was found in a server!", data.name),
            ["color"] = colorValue,
            ["fields"] = {
                {["name"] = "📦 Item", ["value"] = "```" .. (data.name or "Unknown") .. "```", ["inline"] = true},
                {["name"] = "💰 Value", ["value"] = "```" .. formatNumber(data.value or 0) .. " 💎```", ["inline"] = true},
                {["name"] = "✨ Mutation", ["value"] = "```" .. (data.mutation or "Normal") .. "```", ["inline"] = true},
                {["name"] = "👥 Players", ["value"] = "```" .. (data.players or "0/0") .. "```", ["inline"] = true},
                {["name"] = "🎮 Server ID", ["value"] = "```" .. string.sub((data.job_id or ""), 1, 20) .. "...```", ["inline"] = false},
                {["name"] = "🚀 Join Command", ["value"] = "```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(" .. (data.place_id or 0) .. ", '" .. (data.job_id or "") .. "')\n```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "AJGODZX v2.0 • Found at " .. os.date("%H:%M:%S")},
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    pcall(function()
        local requestFunc = syn and syn.request or request or http_request
        if requestFunc then
            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        elseif HttpService and HttpService.PostAsync then
            HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(payload))
        end
    end)
end

-- [[ GUI CONSTRUCTION ]] --
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
Title.Text = "✨ AJGODZX PREMIUM v2.0"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = T.White
Title.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel", Header)
StatsLabel.Size = UDim2.new(1, -60, 0, 15)
StatsLabel.Position = UDim2.new(0, 20, 0, 30)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "Monitoring for brainrots..."
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 10
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

-- Controls Frame
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
AutoJoinBtn.TextSize = 12
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
SoundBtn.TextSize = 12
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

-- [[ LOG ENTRY CREATION ]] --
local function addLogEntry(data)
    -- Filter by minimum value
    if userSettings.MinValue > 0 and (data.value or 0) < userSettings.MinValue then
        return
    end
    
    local card = Instance.new("Frame", Content)
    card.Size = UDim2.new(1, 0, 0, 80)
    card.BackgroundColor3 = T.BgCard
    card.LayoutOrder = -os.time()
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    -- Color accent based on value
    local accentColor = getColorForValue(data.value or 0)
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0, 5, 1, 0)
    accent.BackgroundColor3 = accentColor
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
    
    -- Item name
    local nameLabel = Instance.new("TextLabel", card)
    nameLabel.Size = UDim2.new(1, -120, 0, 22)
    nameLabel.Position = UDim2.new(0, 15, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.name or "Unknown"
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = T.White
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Details
    local detailsLabel = Instance.new("TextLabel", card)
    detailsLabel.Size = UDim2.new(1, -120, 0, 16)
    detailsLabel.Position = UDim2.new(0, 15, 0, 32)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = string.format("%s • %s", formatNumber(data.value or 0), data.mutation or "Normal")
    detailsLabel.Font = Enum.Font.GothamMedium
    detailsLabel.TextSize = 11
    detailsLabel.TextColor3 = T.TextDim
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Left    
    -- Time
    local timeLabel = Instance.new("TextLabel", card)
    timeLabel.Size = UDim2.new(1, -120, 0, 14)
    timeLabel.Position = UDim2.new(0, 15, 0, 50)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.TextSize = 10
    timeLabel.TextColor3 = T.TextDim
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Update time
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
    
    -- Server info
    local serverLabel = Instance.new("TextLabel", card)
    serverLabel.Size = UDim2.new(1, -120, 0, 12)
    serverLabel.Position = UDim2.new(0, 15, 0, 64)
    serverLabel.BackgroundTransparency = 1
    serverLabel.Text = "👥 " .. (data.players or "0/0")
    serverLabel.Font = Enum.Font.GothamMedium
    serverLabel.TextSize = 9
    serverLabel.TextColor3 = T.TextDim
    serverLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Join button
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
    
    -- Copy button
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
    
    -- Animate entry
    card.BackgroundTransparency = 1
    card:TweenPosition(UDim2.new(1, 50, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.1)
    card:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    card.BackgroundTransparency = 0
    
    -- Send webhook and play sound
    sendWebhook(data)
    playNotifSound()
    
    -- Update status
    StatusText.Text = string.format("Found: %s • %s", data.name, formatNumber(data.value))
    task.wait(3)
    if StatusText.Text ~= "Connected • Monitoring..." then
        StatusText.Text = "Connected • Monitoring..."
    end
end

-- [[ DATA SYNC LOOP ]] --
local processedIds = {}
local lastSyncTime = 0

task.spawn(function()
    while _G.AJRunning do
        pcall(function()
            local response = game:HttpGet(SHARED_URL .. "?t=" .. tick())
            local data = HttpService:JSONDecode(response)
            
            if data and data.findings then
                -- Process newest findings first
                for _, finding in ipairs(data.findings) do
                    if not processedIds[finding.id] then
                        processedIds[finding.id] = true
                        addLogEntry(finding)
                        
                        -- Auto-join if enabled
                        if userSettings.AutoJoin then
                            task.wait(0.5) -- Small delay before auto-join
                            local targetPlace = finding.place_id or 109983668079237
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(targetPlace, finding.job_id, lp)
                            end)
                            break -- Stop after first auto-join
                        end
                    end
                end
            end
            
            -- Clean old IDs periodically
            if tick() - lastSyncTime > 300 then -- Every 5 minutes
                local newProcessed = {}
                for id, _ in pairs(processedIds) do
                    -- Keep only last 100 IDs
                    if #newProcessed < 100 then
                        newProcessed[id] = true
                    end
                end
                processedIds = newProcessed
                lastSyncTime = tick()
            end
        end)
        
        task.wait(1.5) -- Faster polling
    end
end)

print("✅ AJGODZX FIXED v2.0 LOADED!")
