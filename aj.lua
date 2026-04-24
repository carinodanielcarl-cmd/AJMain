--[[
    AJGODZX AUTO JOINER - FULLY WORKING
    Copy this entire script and paste into your executor
--]]

-- FIXED: Using PlayerGui instead of CoreGui for better compatibility
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local lp = Players.LocalPlayer

-- Configuration
local SHARED_URL = "https://api.npoint.io/3b590339f6bef0db0dfd"
local MAX_LOGS = 20
_G.AJRunning = true

-- Create GUI (FIXED for all executors)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AJGODZX_JOINER"
screenGui.ResetOnSpawn = false

-- Try different parents for compatibility
local success, err = pcall(function()
    screenGui.Parent = lp:WaitForChild("PlayerGui")
end)
if not success then
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
end

-- Colors
local colors = {
    bg = Color3.fromRGB(15, 15, 25),
    card = Color3.fromRGB(22, 22, 35),
    accent = Color3.fromRGB(0, 200, 255),
    green = Color3.fromRGB(45, 210, 110),
    red = Color3.fromRGB(255, 75, 75),
    orange = Color3.fromRGB(255, 165, 0),
    white = Color3.fromRGB(240, 245, 255),
    gray = Color3.fromRGB(150, 150, 170)
}

-- Main Window
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 400, 0, 520)
main.Position = UDim2.new(0.5, -200, 0.5, -260)
main.BackgroundColor3 = colors.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = colors.card
header.BorderSizePixel = 0
local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎯 AJGODZX AUTO JOINER"
title.TextColor3 = colors.white
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local statusBadge = Instance.new("TextLabel", header)
statusBadge.Size = UDim2.new(0, 80, 0, 22)
statusBadge.Position = UDim2.new(1, -95, 0.5, -11)
statusBadge.BackgroundColor3 = colors.green
statusBadge.Text = "ACTIVE"
statusBadge.TextColor3 = colors.white
statusBadge.TextSize = 11
statusBadge.Font = Enum.Font.GothamBold
local badgeCorner = Instance.new("UICorner", statusBadge)
badgeCorner.CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0.5, -17.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = colors.red
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    _G.AJRunning = false
    screenGui:Destroy()
end)

-- Controls Panel
local controls = Instance.new("Frame", main)
controls.Size = UDim2.new(1, -20, 0, 70)
controls.Position = UDim2.new(0, 10, 0, 65)
controls.BackgroundTransparency = 1

-- Auto Join Button
local autoJoinBtn = Instance.new("TextButton", controls)
autoJoinBtn.Size = UDim2.new(0.48, 0, 0, 32)
autoJoinBtn.Position = UDim2.new(0, 0, 0, 0)
autoJoinBtn.BackgroundColor3 = colors.green
autoJoinBtn.Text = "🔁 AUTO JOIN: ON"
autoJoinBtn.TextColor3 = colors.white
autoJoinBtn.TextSize = 12
autoJoinBtn.Font = Enum.Font.GothamBold
local ajCorner = Instance.new("UICorner", autoJoinBtn)
ajCorner.CornerRadius = UDim.new(0, 6)

local autoJoinEnabled = true
autoJoinBtn.MouseButton1Click:Connect(function()
    autoJoinEnabled = not autoJoinEnabled
    autoJoinBtn.Text = autoJoinEnabled and "🔁 AUTO JOIN: ON" or "🔁 AUTO JOIN: OFF"
    autoJoinBtn.BackgroundColor3 = autoJoinEnabled and colors.green or colors.gray
end)

-- Sound Button
local soundBtn = Instance.new("TextButton", controls)
soundBtn.Size = UDim2.new(0.48, 0, 0, 32)
soundBtn.Position = UDim2.new(0.52, 0, 0, 0)
soundBtn.BackgroundColor3 = colors.green
soundBtn.Text = "🔊 SOUND: ON"
soundBtn.TextColor3 = colors.white
soundBtn.TextSize = 12
soundBtn.Font = Enum.Font.GothamBold
local soundCorner = Instance.new("UICorner", soundBtn)
soundCorner.CornerRadius = UDim.new(0, 6)

local soundEnabled = true
soundBtn.MouseButton1Click:Connect(function()
    soundEnabled = not soundEnabled
    soundBtn.Text = soundEnabled and "🔊 SOUND: ON" or "🔊 SOUND: OFF"
    soundBtn.BackgroundColor3 = soundEnabled and colors.green or colors.gray
end)

-- Stats Label
local statsLabel = Instance.new("TextLabel", controls)
statsLabel.Size = UDim2.new(1, 0, 0, 20)
statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "📊 Found: 0 | Pending: 0"
statsLabel.TextColor3 = colors.gray
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.GothamMedium

-- Log List Container
local logContainer = Instance.new("ScrollingFrame", main)
logContainer.Size = UDim2.new(1, -20, 1, -165)
logContainer.Position = UDim2.new(0, 10, 0, 145)
logContainer.BackgroundTransparency = 1
logContainer.BorderSizePixel = 0
logContainer.ScrollBarThickness = 4
logContainer.ScrollBarImageColor3 = colors.accent

local logLayout = Instance.new("UIListLayout", logContainer)
logLayout.Padding = UDim.new(0, 8)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder

logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    logContainer.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 10)
end)

-- Status Bar
local statusBar = Instance.new("Frame", main)
statusBar.Size = UDim2.new(1, 0, 0, 28)
statusBar.Position = UDim2.new(0, 0, 1, -28)
statusBar.BackgroundColor3 = colors.card
local statusCorner = Instance.new("UICorner", statusBar)
statusCorner.CornerRadius = UDim.new(0, 8)

local statusText = Instance.new("TextLabel", statusBar)
statusText.Size = UDim2.new(1, -15, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "✅ Connected | Monitoring for brainrots..."
statusText.TextColor3 = colors.gray
statusText.TextSize = 11
statusText.Font = Enum.Font.GothamMedium
statusText.TextXAlignment = Enum.TextXAlignment.Left

-- Sound for notifications
local notifySound = Instance.new("Sound")
notifySound.SoundId = "rbxassetid://4590662766"
notifySound.Volume = 0.5
notifySound.Parent = SoundService

local function playSound()
    if soundEnabled then
        pcall(function() notifySound:Play() end)
    end
end

local function formatValue(value)
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end
    return tostring(value)
end

-- Add log entry to UI
local processedIds = {}
local foundCount = 0

local function addLogEntry(data)
    if not data or not data.name then return end
    
    -- Create log card
    local card = Instance.new("Frame", logContainer)
    card.Size = UDim2.new(1, 0, 0, 75)
    card.BackgroundColor3 = colors.card
    card.LayoutOrder = -os.time()
    local cardCorner = Instance.new("UICorner", card)
    cardCorner.CornerRadius = UDim.new(0, 8)
    
    -- Color accent based on value
    local accentColor = (data.value or 0) >= 100000000 and colors.red or (data.value or 0) >= 50000000 and colors.orange or colors.accent
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = accentColor
    local accentCorner = Instance.new("UICorner", accent)
    accentCorner.CornerRadius = UDim.new(1, 0)
    
    -- Item name
    local nameLabel = Instance.new("TextLabel", card)
    nameLabel.Size = UDim2.new(1, -110, 0, 22)
    nameLabel.Position = UDim2.new(0, 12, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.name
    nameLabel.TextColor3 = colors.white
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Details (value + mutation)
    local detailsLabel = Instance.new("TextLabel", card)
    detailsLabel.Size = UDim2.new(1, -110, 0, 16)
    detailsLabel.Position = UDim2.new(0, 12, 0, 30)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = formatValue(data.value or 0) .. " • " .. (data.mutation or "Normal")
    detailsLabel.TextColor3 = colors.gray
    detailsLabel.TextSize = 11
    detailsLabel.Font = Enum.Font.GothamMedium
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Server info
    local serverLabel = Instance.new("TextLabel", card)
    serverLabel.Size = UDim2.new(1, -110, 0, 14)
    serverLabel.Position = UDim2.new(0, 12, 0, 48)
    serverLabel.BackgroundTransparency = 1
    serverLabel.Text = "👥 " .. (data.players or "?") .. " players"
    serverLabel.TextColor3 = colors.gray
    serverLabel.TextSize = 10
    serverLabel.Font = Enum.Font.GothamMedium
    serverLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Time ago
    local timeLabel = Instance.new("TextLabel", card)
    timeLabel.Size = UDim2.new(1, -110, 0, 12)
    timeLabel.Position = UDim2.new(0, 12, 0, 60)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = colors.gray
    timeLabel.TextSize = 9
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Update time every second
    local startTime = os.time()
    task.spawn(function()
        while card.Parent do
            local diff = os.time() - startTime
            local timeStr = diff < 60 and (diff .. "s ago") or (math.floor(diff/60) .. "m ago")
            timeLabel.Text = "🕐 " .. timeStr
            task.wait(1)
        end
    end)
    
    -- Join button
    local joinBtn = Instance.new("TextButton", card)
    joinBtn.Size = UDim2.new(0, 55, 0, 28)
    joinBtn.Position = UDim2.new(1, -115, 0.5, -14)
    joinBtn.BackgroundColor3 = colors.accent
    joinBtn.Text = "JOIN"
    joinBtn.TextColor3 = colors.white
    joinBtn.TextSize = 11
    joinBtn.Font = Enum.Font.GothamBold
    local joinCorner = Instance.new("UICorner", joinBtn)
    joinCorner.CornerRadius = UDim.new(0, 6)
    
    joinBtn.MouseButton1Click:Connect(function()
        if data.job_id then
            joinBtn.Text = "..."
            pcall(function()
                TeleportService:TeleportToPlaceInstance(data.place_id or 109983668079237, data.job_id, lp)
            end)
        end
    end)
    
    -- Copy ID button
    local copyBtn = Instance.new("TextButton", card)
    copyBtn.Size = UDim2.new(0, 50, 0, 28)
    copyBtn.Position = UDim2.new(1, -58, 0.5, -14)
    copyBtn.BackgroundColor3 = colors.orange
    copyBtn.Text = "COPY"
    copyBtn.TextColor3 = colors.white
    copyBtn.TextSize = 10
    copyBtn.Font = Enum.Font.GothamBold
    local copyCorner = Instance.new("UICorner", copyBtn)
    copyCorner.CornerRadius = UDim.new(0, 6)
    
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard and data.job_id then
            setclipboard(data.job_id)
            copyBtn.Text = "✓"
            task.wait(1)
            copyBtn.Text = "COPY"
        end
    end)
    
    -- Animation
    card.BackgroundTransparency = 1
    task.wait(0.05)
    card.BackgroundTransparency = 0
    
    foundCount = foundCount + 1
    statsLabel.Text = "📊 Found: " .. foundCount .. " | Pending: 0"
    
    playSound()
end

-- Main polling loop
task.spawn(function()
    while _G.AJRunning do
        pcall(function()
            -- Fetch data from shared URL
            local response = game:HttpGet(SHARED_URL .. "?cache=" .. tick())
            local data = HttpService:JSONDecode(response)
            
            if data and data.findings then
                -- Update stats
                statsLabel.Text = "📊 Found: " .. foundCount .. " | Queue: " .. #data.findings
                
                -- Process new findings (newest first)
                for i = #data.findings, 1, -1 do
                    local finding = data.findings[i]
                    if finding and finding.id and not processedIds[finding.id] then
                        processedIds[finding.id] = true
                        addLogEntry(finding)
                        
                        -- Auto join if enabled
                        if autoJoinEnabled then
                            task.wait(0.5)
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(
                                    finding.place_id or 109983668079237, 
                                    finding.job_id, 
                                    lp
                                )
                            end)
                            break -- Only join the first new finding
                        end
                    end
                end
                
                -- Update status text
                if #data.findings > 0 then
                    local latest = data.findings[1]
                    if latest then
                        statusText.Text = "🎯 Latest: " .. latest.name .. " | Value: " .. formatValue(latest.value or 0)
                    end
                else
                    statusText.Text = "✅ Connected | No finds yet..."
                end
            end
        end)
        task.wait(2) -- Poll every 2 seconds
    end
end)

-- Cleanup old processed IDs every 10 minutes
task.spawn(function()
    while _G.AJRunning do
        task.wait(600) -- 10 minutes
        local newIds = {}
        local count = 0
        for id, _ in pairs(processedIds) do
            if count < 200 then
                newIds[id] = true
                count = count + 1
            end
        end
        processedIds = newIds
    end
end)

-- Success message
print("✅ AJGODZX AUTO JOINER LOADED SUCCESSFULLY!")
print("📡 Connected to: " .. SHARED_URL)
print("🎯 Monitoring for brainrots...")

-- Keep script alive
while _G.AJRunning do
    task.wait(1)
end
