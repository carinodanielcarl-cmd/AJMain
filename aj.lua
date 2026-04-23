-- AJGODZX JOINER (Premium Polished v2.0.2)
-- Automatically fetches pings from npoint cloud and allows joining.
-- SAFE VISIBILITY: Automatically finds the best folder to show the UI.

-- [[ BOOT PROTECTION ]] --
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local lp = game.Players.LocalPlayer

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local UI_NAME = "AJGODZX_GUI"

-- [[ SETTINGS ]] --
local AJGODZX_SETTINGS = {
    DATA_URL = "https://api.npoint.io/3b590339f6bef0db0dfd", 
    RETRY_DELAY = 2,
    THEME_ACCENT = Color3.fromRGB(0, 255, 200),
}

-- [[ UI PARENTING ]] --
local function GetSafeParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        if CoreGui then return CoreGui end
        return lp:WaitForChild("PlayerGui")
    end)
    return success and parent or lp:WaitForChild("PlayerGui")
end

local SafeParent = GetSafeParent()

-- Cleanup
pcall(function()
    if SafeParent:FindFirstChild(UI_NAME) then SafeParent[UI_NAME]:Destroy() end
end)

-- [[ THEME ]] --
local T = {
    BgDark = Color3.fromRGB(5, 5, 5),
    BgMid = Color3.fromRGB(12, 12, 12),
    BgCard = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(8, 8, 8),
    Accent1 = Color3.fromRGB(0, 255, 200),
    White = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Off = Color3.fromRGB(35, 35, 35),
    Green = Color3.fromRGB(0, 255, 128),
    Red = Color3.fromRGB(255, 60, 70),
    Orange = Color3.fromRGB(255, 120, 0),
    HighlightC = Color3.fromRGB(0, 255, 255),
    MidlightC = Color3.fromRGB(0, 150, 255),
}

local userSettings = {
    AutoJoin = false,
    PlaySound = true,
    AutoJoinRetries = 3,
}

-- [[ UI FOUNDATION ]] --
local Gui = Instance.new("ScreenGui")
Gui.Name = UI_NAME
Gui.Parent = SafeParent
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("CanvasGroup", Gui)
Main.Size = UDim2.new(0, 606, 0, 365)
Main.Position = UDim2.new(0.5, -303, 0.5, -182)
Main.BackgroundColor3 = T.BgDark
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)

local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = 1.0

-- Draggable
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [[ SIDEBAR ]] --
local Sidebar = Instance.new("Frame", Main)
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.Position = UDim2.new(0, 0, 0, 65)
Sidebar.Size = UDim2.new(0, 155, 1, -65)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 9)

local function createFilterBtn(text, yPos, filterKey)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 135, 0, 35)
    btn.BackgroundColor3 = T.BgCard
    btn.Text = "  " .. text
    btn.TextColor3 = T.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = (filterKey == "all") and T.Accent1 or T.Off
    return btn
end

createFilterBtn("📋 All Logs", 10, "all")
createFilterBtn("🏆 Highlights", 50, "hl")
createFilterBtn("⭐ Midlights", 90, "ml")

local AutoJoinBtn = Instance.new("TextButton", Sidebar)
AutoJoinBtn.Position = UDim2.new(0, 10, 0, 180)
AutoJoinBtn.Size = UDim2.new(0, 135, 0, 38)
AutoJoinBtn.BackgroundColor3 = T.BgCard
AutoJoinBtn.Text = "⚡ AUTO JOIN OFF"
AutoJoinBtn.TextColor3 = T.White
AutoJoinBtn.Font = Enum.Font.GothamBold
AutoJoinBtn.TextSize = 11
Instance.new("UICorner", AutoJoinBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", AutoJoinBtn).Color = T.Red

AutoJoinBtn.MouseButton1Click:Connect(function()
    userSettings.AutoJoin = not userSettings.AutoJoin
    AutoJoinBtn.Text = userSettings.AutoJoin and "✅ AUTO JOIN ON" or "⚡ AUTO JOIN OFF"
    AutoJoinBtn.BackgroundColor3 = userSettings.AutoJoin and T.Green or T.BgCard
end)

-- [[ HEADER ]] --
local Header = Instance.new("TextLabel", Main)
Header.Position = UDim2.new(0, 20, 0, 15)
Header.Size = UDim2.new(0, 200, 0, 30)
Header.BackgroundTransparency = 1
Header.Font = Enum.Font.GothamBold
Header.Text = "AJGODZX"
Header.TextColor3 = T.Accent1
Header.TextSize = 24
Header.TextXAlignment = Enum.TextXAlignment.Left

local StatusIndicator = Instance.new("Frame", Main)
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.Position = UDim2.new(0, 20, 0, 48)
StatusIndicator.BackgroundColor3 = T.Red
Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel", Main)
StatusText.Position = UDim2.new(0, 35, 0, 42)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Connecting to phone bot..."
StatusText.TextColor3 = T.TextDim
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- [[ CONTENT AREA ]] --
local Content = Instance.new("ScrollingFrame", Main)
Content.Position = UDim2.new(0, 165, 0, 65)
Content.Size = UDim2.new(1, -175, 1, -75)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LogLayout = Instance.new("UIListLayout", Content)
LogLayout.Padding = UDim.new(0, 8)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [[ JOIN SYSTEM (Multi-Method + Queue) ]] --
local currentlyJoining = false
local joinQueue = {}
local lastJoinedId = nil

local function showJoinStatus(text, statusType)
    if statusType == "success" then
        StatusIndicator.BackgroundColor3 = T.Green
    elseif statusType == "error" then
        StatusIndicator.BackgroundColor3 = T.Red
    elseif statusType == "loading" then
        StatusIndicator.BackgroundColor3 = T.Orange
    elseif statusType == "warning" then
        StatusIndicator.BackgroundColor3 = T.Orange
    end
    StatusText.Text = text
    print("[AJGODZX] " .. text)
end

local function joinServer(jobId, placeId, showStatus)
    if not jobId or jobId == "" then
        if showStatus then showJoinStatus("❌ Invalid Server ID!", "error") end
        return false
    end
    
    if lastJoinedId == jobId then
        if showStatus then showJoinStatus("⚠️ Already attempted this server!", "warning") end
        return false
    end
    
    local pid = placeId or game.PlaceId
    if showStatus then showJoinStatus("🔄 Joining server...", "loading") end
    
    -- Method 1: TeleportToPlaceInstance (most common for public servers)
    local s1, e1 = pcall(function()
        TeleportService:TeleportToPlaceInstance(pid, jobId, lp)
    end)
    if s1 then
        if showStatus then showJoinStatus("✅ Teleporting (Method 1)...", "success") end
        lastJoinedId = jobId
        return true
    end
    
    -- Method 2: TeleportToPrivateServer
    local s2, e2 = pcall(function()
        TeleportService:TeleportToPrivateServer(pid, jobId, {lp})
    end)
    if s2 then
        if showStatus then showJoinStatus("✅ Teleporting (Method 2)...", "success") end
        lastJoinedId = jobId
        return true
    end
    
    -- Method 3: TeleportOptions
    local s3, e3 = pcall(function()
        local options = Instance.new("TeleportOptions")
        options.ServerInstanceId = jobId
        TeleportService:TeleportAsync(pid, {lp}, options)
    end)
    if s3 then
        if showStatus then showJoinStatus("✅ Teleporting (Method 3)...", "success") end
        lastJoinedId = jobId
        return true
    end
    
    -- All methods failed
    local errMsg = tostring(e1) .. " | " .. tostring(e2) .. " | " .. tostring(e3)
    if showStatus then showJoinStatus("❌ All join methods failed!", "error") end
    warn("[AJGODZX] Join failed for " .. jobId .. ": " .. errMsg)
    return false
end

local function processQueue()
    if currentlyJoining then return end
    if #joinQueue == 0 then return end
    
    local next = table.remove(joinQueue, 1)
    if next then
        currentlyJoining = true
        task.spawn(function()
            local attempts = userSettings.AutoJoinRetries or 3
            for i = 1, attempts do
                if joinServer(next.jobId, next.placeId, i == 1) then
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

local function queueJoin(jobId, placeId, showStatus)
    if not jobId or jobId == "" then return end
    if lastJoinedId == jobId then
        if showStatus then showJoinStatus("⚠️ Already attempted this server!", "warning") end
        return
    end
    if #joinQueue > 10 then table.remove(joinQueue, 1) end
    table.insert(joinQueue, {jobId = jobId, placeId = placeId})
    if showStatus then showJoinStatus("📋 Server queued...", "loading") end
    processQueue()
end

-- [[ LOG LOGIC ]] --
local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000) end
    if n >= 1000 then return string.format("%.1fK", n/1000) end
    return tostring(n)
end

local function addLogEntry(data)
    local LogItem = Instance.new("Frame", Content)
    LogItem.BackgroundColor3 = T.BgCard
    LogItem.Size = UDim2.new(1, -10, 0, 45)
    Instance.new("UICorner", LogItem).CornerRadius = UDim.new(0, 8)
    
    local bar = Instance.new("Frame", LogItem)
    bar.Size = UDim2.new(0, 4, 0.7, 0)
    bar.Position = UDim2.new(0, 0, 0.15, 0)
    bar.BackgroundColor3 = (data.tier == "Highlights") and T.HighlightC or T.MidlightC
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local Left = Instance.new("Frame", LogItem)
    Left.BackgroundTransparency = 1
    Left.Size = UDim2.new(0.65, 0, 1, 0)
    Left.Position = UDim2.new(0, 12, 0, 0)

    local Name = Instance.new("TextLabel", Left)
    Name.Size = UDim2.new(1, 0, 1, 0)
    Name.Position = UDim2.new(0, 0, 0, 0)
    Name.BackgroundTransparency = 1
    Name.Font = Enum.Font.GothamBold
    Name.Text = (data.name or "Unknown")
    Name.TextColor3 = T.White
    Name.TextSize = 13
    Name.TextXAlignment = Enum.TextXAlignment.Left

    local Right = Instance.new("Frame", LogItem)
    Right.BackgroundTransparency = 1
    Right.Size = UDim2.new(0.35, 0, 1, 0)
    Right.Position = UDim2.new(0.65, 0, 0, 0)

    local JoinBtn = Instance.new("TextButton", Right)
    JoinBtn.Size = UDim2.new(0, 55, 0, 26)
    JoinBtn.Position = UDim2.new(0.5, -60, 0.5, -13)
    JoinBtn.BackgroundColor3 = T.Accent1
    JoinBtn.Text = "JOIN"
    JoinBtn.Font = Enum.Font.GothamBold
    JoinBtn.TextColor3 = T.White
    JoinBtn.TextSize = 10
    Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 6)

    local CopyBtn = Instance.new("TextButton", Right)
    CopyBtn.Size = UDim2.new(0, 50, 0, 26)
    CopyBtn.Position = UDim2.new(0.5, 5, 0.5, -13)
    CopyBtn.BackgroundColor3 = T.Orange
    CopyBtn.Text = "COPY"
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextColor3 = T.White
    CopyBtn.TextSize = 9
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

    JoinBtn.MouseButton1Click:Connect(function()
        if data.job_id then
            JoinBtn.Text = "..."
            JoinBtn.BackgroundColor3 = T.Orange
            task.spawn(function()
                queueJoin(data.job_id, data.place_id, true)
                task.wait(2)
                JoinBtn.Text = "JOIN"
                JoinBtn.BackgroundColor3 = T.Accent1
            end)
        else
            showJoinStatus("❌ No Job ID!", "error")
        end
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        if data.job_id and setclipboard then
            setclipboard(data.job_id)
            CopyBtn.Text = "✓"
            CopyBtn.BackgroundColor3 = T.Green
            task.delay(1.5, function()
                CopyBtn.Text = "COPY"
                CopyBtn.BackgroundColor3 = T.Orange
            end)
        end
    end)
end

-- [[ DATA SYNC ]] --
local seenIds = {}
local isFirstRun = true

local function handleData(list)
    local newFindings = {}
    for _, d in ipairs(list) do
        local logId = d.id or (d.job_id and d.job_id .. "_" .. (d.name or "unknown"))
        if logId and not seenIds[logId] then
            seenIds[logId] = true
            table.insert(newFindings, d)
        end
    end
    
    -- Skip the first batch (past logs)
    if isFirstRun then
        isFirstRun = false
        StatusText.Text = "Ready (skipped " .. #newFindings .. " old logs)"
        return
    end
    
    -- Only show findings from the last 20 seconds
    for _, d in ipairs(newFindings) do
        local ts = d.timestamp or 0
        if ts > (os.time() - 20) then
            addLogEntry(d)
            if userSettings.AutoJoin and d.job_id then
                queueJoin(d.job_id, d.place_id, false)
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(function()
            local reqUrl = AJGODZX_SETTINGS.DATA_URL .. "?t=" .. tostring(tick())
            local response
            
            -- Multi-executor HTTP support
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
                local list = res.findings or res
                if type(list) == "table" then
                    StatusIndicator.BackgroundColor3 = T.Green
                    if not isFirstRun then
                        StatusText.Text = "Live (" .. #list .. " total finds)"
                    end
                    handleData(list)
                end
            end
        end)
        task.wait(AJGODZX_SETTINGS.RETRY_DELAY)
    end
end)

print("✅ AJGODZX PREMIUM LOADED!")