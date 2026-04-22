-- AJGODZX JOINER (UI-Safe Version v2.0.1)
-- Automatically fetches pings from npoint cloud and allows joining.

-- [[ INITIALIZATION ]] --
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
print("--- AJGODZX: Starting UI Setup ---")

-- [[ SETTINGS ]] --
local AJGODZX_SETTINGS = {
    DATA_URL = "https://api.npoint.io/3b590339f6bef0db0dfd", 
    RETRY_DELAY = 1.5,
    THEME_ACCENT = Color3.fromRGB(0, 255, 200),
    AUTO_JOIN_DEFAULT = false,
}

local CUSTOM_URL = AJGODZX_SETTINGS.DATA_URL

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

-- Cleanup previous instance
pcall(function()
    if SafeParent:FindFirstChild(UI_NAME) then
        SafeParent[UI_NAME]:Destroy()
    end
end)

-- Moby-Style Theme
local T = {
    BgDark = Color3.fromRGB(5, 5, 5),
    BgMid = Color3.fromRGB(12, 12, 12),
    BgCard = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(8, 8, 8),
    Accent1 = Color3.fromRGB(0, 255, 200),
    White = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Off = Color3.fromRGB(30, 30, 30),
    Green = Color3.fromRGB(0, 255, 128),
    Red = Color3.fromRGB(255, 60, 70),
    Yellow = Color3.fromRGB(255, 220, 0),
    HighlightC = Color3.fromRGB(0, 255, 255),
    MidlightC = Color3.fromRGB(0, 150, 255),
    Orange = Color3.fromRGB(255, 120, 0),
}

local userSettings = {
    Midlights = true,
    Highlights = true,
    AutoJoin = false,
    AutoJoinRetries = 3,
    PlaySound = true,
    ToggleKey = "RightShift",
}

-- [[ GUI FOUNDATION ]] --
local Gui = Instance.new("ScreenGui")
Gui.Name = UI_NAME
Gui.Parent = SafeParent
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
print("--- AJGODZX: UI Parented to " .. SafeParent.Name .. " ---")

local Main = Instance.new("CanvasGroup")
Main.Size = UDim2.new(0, 600, 0, 360)
Main.Position = UDim2.new(0.5, -300, 0.5, -180)
Main.BackgroundColor3 = T.BgDark
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)

local Sidebar = Instance.new("Frame", Main)
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.Position = UDim2.new(0, 0, 0, 60)
Sidebar.Size = UDim2.new(0, 150, 1, -60)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 9)

local Content = Instance.new("ScrollingFrame", Main)
Content.Position = UDim2.new(0, 160, 0, 60)
Content.Size = UDim2.new(1, -170, 1, -70)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LogLayout = Instance.new("UIListLayout", Content)
LogLayout.Padding = UDim.new(0, 6)

local Header = Instance.new("TextLabel", Main)
Header.Position = UDim2.new(0, 15, 0, 15)
Header.Size = UDim2.new(0, 200, 0, 30)
Header.BackgroundTransparency = 1
Header.Font = Enum.Font.GothamBold
Header.Text = "AJGODZX JOINER"
Header.TextColor3 = T.Accent1
Header.TextSize = 22
Header.TextXAlignment = Enum.TextXAlignment.Left

local StatusIndicator = Instance.new("Frame", Main)
StatusIndicator.Size = UDim2.new(0, 10, 0, 10)
StatusIndicator.Position = UDim2.new(0, 180, 0, 25)
StatusIndicator.BackgroundColor3 = T.Red
Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel", Main)
StatusText.Position = UDim2.new(0, 195, 0, 20)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Connecting..."
StatusText.TextColor3 = T.TextDim
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- [[ NOTIF SYSTEM ]] --
local function showJoinStatus(msg, colorType)
    print("AJGODZX STATUS: " .. msg)
    -- Simple label at top of list for feedback
    local s = Instance.new("TextLabel", Content)
    s.Size = UDim2.new(1, 0, 0, 20)
    s.BackgroundTransparency = 1
    s.Text = msg
    s.TextColor3 = (colorType == "error") and T.Red or T.Green
    s.Font = Enum.Font.GothamBold
    s.TextSize = 10
    task.delay(3, function() s:Destroy() end)
end

-- [[ LOGIC ]] --
local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000) end
    if n >= 1000 then return string.format("%.1fK", n/1000) end
    return tostring(n)
end

local function addLogEntry(data)
    local LogItem = Instance.new("Frame", Content)
    LogItem.BackgroundColor3 = T.BgCard
    LogItem.Size = UDim2.new(1, -10, 0, 55)
    Instance.new("UICorner", LogItem).CornerRadius = UDim.new(0, 8)
    
    local isHL = data.tier == "Highlights"
    local bar = Instance.new("Frame", LogItem)
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = isHL and T.HighlightC or T.MidlightC
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local txt = Instance.new("TextLabel", LogItem)
    txt.Position = UDim2.new(0, 12, 0, 5)
    txt.Size = UDim2.new(1, -70, 1, -10)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamMedium
    txt.Text = "🏷️ " .. (data.name or "???") .. "\n💰 " .. formatNumber(data.value or 0) .. "/s | 👥 " .. (data.players or "?/?")
    txt.TextColor3 = T.White
    txt.TextSize = 10
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.RichText = true

    local JoinBtn = Instance.new("TextButton", LogItem)
    JoinBtn.Position = UDim2.new(1, -60, 0.5, -12)
    JoinBtn.Size = UDim2.new(0, 50, 0, 24)
    JoinBtn.BackgroundColor3 = T.Accent1
    JoinBtn.Text = "JOIN"
    JoinBtn.Font = Enum.Font.GothamBold
    JoinBtn.TextColor3 = T.White
    JoinBtn.TextSize = 10
    Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 6)

    JoinBtn.MouseButton1Click:Connect(function()
        if data.job_id then
            showJoinStatus("Joining " .. data.job_id, "success")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.job_id, lp)
        end
    end)
end

local seenIds = {}
local function handleData(findings)
    for _, d in ipairs(findings) do
        if not seenIds[d.id] then
            seenIds[d.id] = true
            addLogEntry(d)
        end
    end
end

task.spawn(function()
    while true do
        pcall(function()
            local raw = game:HttpGet(CUSTOM_URL .. "?t=" .. tick())
            local res = HttpService:JSONDecode(raw)
            local list = res.findings or res
            if type(list) == "table" and #list > 0 then
                StatusIndicator.BackgroundColor3 = T.Green
                StatusText.Text = "Online (" .. #list .. " finds)"
                handleData(list)
            else
                StatusText.Text = "No findings..."
            end
        end)
        task.wait(2)
    end
end)

print("--- AJGODZX: Initialization Complete! ---")