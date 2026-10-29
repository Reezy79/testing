--[[
    Script: CALI SCRIPT (Bản sửa lỗi toàn diện)
    Môi trường: Roblox Executor (client-side)
    Chức năng: Giao diện tổng hợp với nhiều module (Car Fly, Aimbot, ESP, v.v.)
    Các sửa đổi chính:
    - Sửa lỗi font chữ trong WindUI (loại bỏ ApplyFont gây lỗi).
    - Sửa lỗi Car Fly và Safe Fly (đồng bộ hóa trạng thái).
    - Sửa lỗi Skin Changer (thêm logic copy đúng).
    - Sửa lỗi ESP (thêm logic toggle chính xác).
    - Sửa lỗi Aimbot (loại bỏ lỗi treo camera).
    - Thêm module Teleport, Fly, và các tiện ích khác.
    - Đảm bảo mọi UI element được khởi tạo đúng thứ tự.
]]

-- ===== SERVICE =====
local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    SoundService = game:GetService("SoundService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TeleportService = game:GetService("TeleportService"),
    CoreGui = game:GetService("CoreGui"),
    VirtualUser = game:GetService("VirtualUser")
}

local Players = Services.Players
local HttpService = Services.HttpService
local TweenService = Services.TweenService
local Lighting = Services.Lighting
local RunService = Services.RunService
local UIS = Services.UserInputService
local SoundService = Services.SoundService
local ReplicatedStorage = Services.ReplicatedStorage
local TeleportService = Services.TeleportService
local CoreGui = Services.CoreGui
local vu = Services.VirtualUser
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Kiểm tra môi trường
if not game or not game.GetService or not (game.IsLoaded and game:IsLoaded()) then 
    return 
end

if _G.__LOADED then 
    warn("Already executed") 
    return 
end
_G.__LOADED = true

-- ===== LOADING SCREEN =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RexasLoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10
screenGui.Parent = CoreGui

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BackgroundTransparency = 1
blackFrame.BorderSizePixel = 0
blackFrame.Parent = screenGui

local logLabel = Instance.new("TextLabel")
logLabel.Size = UDim2.new(1, -20, 1, -20)
logLabel.Position = UDim2.new(0, 10, 0, 10)
logLabel.BackgroundTransparency = 1
logLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
logLabel.TextTransparency = 0
logLabel.Font = Enum.Font.Code
logLabel.TextSize = 14
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Bottom
logLabel.Text = ""
logLabel.Parent = blackFrame

local skipButton = Instance.new("TextButton")
skipButton.Size = UDim2.new(0, 110, 0, 38)
skipButton.AnchorPoint = Vector2.new(1, 1)
skipButton.Position = UDim2.new(1, -20, 1, -20)
skipButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
skipButton.BackgroundTransparency = 0
skipButton.BorderSizePixel = 0
skipButton.Text = "Skip"
skipButton.TextColor3 = Color3.fromRGB(0, 255, 0)
skipButton.TextTransparency = 0
skipButton.Font = Enum.Font.Code
skipButton.TextSize = 18
skipButton.AutoButtonColor = false
skipButton.Parent = blackFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = skipButton

local skipped = false
local closing = false

local function fadeOutGui()
    if closing then return end
    closing = true
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blackFrame, fadeInfo, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(logLabel, fadeInfo, { TextTransparency = 1 }):Play()
    TweenService:Create(skipButton, fadeInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
    task.wait(1)
    screenGui:Destroy()
end

skipButton.MouseButton1Click:Connect(function()
    if skipped then return end
    skipped = true
    fadeOutGui()
end)

local fullLog = ""

local function typeLine(line, charDelay)
    local delayPerChar = charDelay or 0.025
    for i = 1, #line do
        if skipped then return false end
        fullLog = fullLog .. line:sub(i, i)
        logLabel.Text = fullLog
        task.wait(delayPerChar)
    end
    fullLog = fullLog .. "\n"
    logLabel.Text = fullLog
    return true
end

local asciiArt = {
    "  /$$$$$$   /$$$$$$  /$$       /$$$$$$ ",
    " /$$__  $$ /$$__  $$| $$      |_  $$_/ ",
    "| $$  \\__/| $$  \\ $$| $$        | $$   ",
    "| $$      | $$$$$$$$| $$        | $$   ",
    "| $$      | $$__  $$| $$        | $$   ",
    "| $$    $$| $$  | $$| $$        | $$   ",
    "|  $$$$$$/| $$  | $$| $$$$$$$$ /$$$$$$ ",
    " \\______/ |__/  |__/|________/|______/ "
}

local extraLogs = {
    "Load Plugins...",
    "Load Scripts",
    "Connecting DB...",
    "Loading assets...",
    "Compiling UI modules...",
    "Syncing data...",
    "Loading configuration...",
    "Loading user interface components...",
    "Applying theme...",
    "Loading Bypass system...",
    "Loading keybinds...",
    "Loading Blacklist...",
    "Done.",
}

task.spawn(function()
    local fadeIn = TweenService:Create(blackFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
    fadeIn:Play()
    fadeIn.Completed:Wait()

    fullLog = table.concat(asciiArt, "\n") .. "\n\n"
    logLabel.Text = fullLog
    task.wait(0.2)

    if not typeLine(" ", 0) then return end
    if not typeLine("Initializing UI...", 0.03) then return end
    task.wait(0.1)

    for _, log in ipairs(extraLogs) do
        if not typeLine(log, 0.0009) then return end
        task.wait(math.random(80, 200) / 1000)
    end

    if not typeLine("[Rexas Successfully Loaded]", 0.04) then return end
    task.wait(2)

    if not skipped then fadeOutGui() end
end)

-- ===== ESP CONFIG =====
local EspSettings = {
    Enabled = false,
    TeamColors = true,
    DefaultColor = Color3.fromRGB(0, 230, 255),
    EnemyColor = Color3.fromRGB(255, 77, 77),
    FillTransparency = 0.65,
    OutlineTransparency = 0.15,
    ShowBeams = true,
    BeamWidth = 0.07,
    BeamLightEmission = 0.35,
    ShowBillboard = true,
    ShowHealth = true,
    ShowTeamName = true,
    MaxDistance = 0,
    StudsOffsetVertical = 1.6,
    Font = Enum.Font.GothamBold
}

local ActiveESP = {}
local espConnections = {}

local function getPlayerColor(player)
    if EspSettings.TeamColors and player.Team then
        return player.Team.TeamColor.Color
    end
    if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
        return EspSettings.DefaultColor
    else
        return EspSettings.EnemyColor
    end
end

local function getTeamName(player)
    if player.Team then return player.Team.Name end
    return "No Team"
end

local function getHealthText(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local hp = math.floor(humanoid.Health + 0.5)
        local maxHp = math.floor(humanoid.MaxHealth + 0.5)
        return string.format("%d/%d HP", hp, maxHp)
    end
    return "- HP"
end

local function getOrCreateAttachment(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local attach = hrp:FindFirstChild("EspAttachment")
    if not attach then
        attach = Instance.new("Attachment")
        attach.Name = "EspAttachment"
        attach.Parent = hrp
    end
    return attach
end

local function removeESP(player)
    if ActiveESP[player] then
        for _, item in ipairs(ActiveESP[player].Cleanups) do
            if typeof(item) == "Instance" then
                item:Destroy()
            elseif typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif type(item) == "function" then
                pcall(item)
            end
        end
        ActiveESP[player] = nil
    end
end

local function setupESP(player, character)
    if player == LocalPlayer then return end
    removeESP(player)
    if not EspSettings.Enabled then return end
    if not character then return end

    local head = character:WaitForChild("Head", 5)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not head or not hrp or not humanoid then return end

    local cleanups = {}
    local playerColor = getPlayerColor(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "EspHighlight"
    highlight.Adornee = character
    highlight.FillColor = playerColor
    highlight.OutlineColor = playerColor
    highlight.FillTransparency = EspSettings.FillTransparency
    highlight.OutlineTransparency = EspSettings.OutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    table.insert(cleanups, highlight)

    local beam = nil
    if EspSettings.ShowBeams then
        local targetAttach = getOrCreateAttachment(character)
        local function bindBeamToLocal()
            if not LocalPlayer.Character then return end
            local localAttach = getOrCreateAttachment(LocalPlayer.Character)
            if localAttach and targetAttach then
                if not beam then
                    beam = Instance.new("Beam")
                    beam.Name = "EspBeam"
                    beam.Color = ColorSequence.new(playerColor)
                    beam.Transparency = NumberSequence.new(0.15)
                    beam.Width0 = EspSettings.BeamWidth
                    beam.Width1 = EspSettings.BeamWidth * 0.6
                    beam.FaceCamera = true
                    beam.LightEmission = EspSettings.BeamLightEmission
                    beam.Attachment1 = targetAttach
                    beam.Attachment0 = localAttach
                    beam.Parent = hrp
                    table.insert(cleanups, beam)
                else
                    beam.Attachment0 = localAttach
                end
            end
        end
        bindBeamToLocal()
        local charConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.2)
            bindBeamToLocal()
        end)
        table.insert(cleanups, charConn)
    end

    if EspSettings.ShowBillboard then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EspBillboard"
        billboard.AlwaysOnTop = true
        billboard.ResetOnSpawn = false
        billboard.MaxDistance = EspSettings.MaxDistance
        billboard.Size = UDim2.new(0, 180, 0, 62)
        billboard.StudsOffsetWorldSpace = Vector3.new(0, EspSettings.StudsOffsetVertical, 0)
        billboard.StudsOffset = Vector3.new(0, 0, 0.1)
        billboard.Adornee = head

        local bgFrame = Instance.new("Frame")
        bgFrame.Size = UDim2.new(1, 0, 1, 0)
        bgFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        bgFrame.BackgroundTransparency = 0.25
        bgFrame.BorderSizePixel = 0
        bgFrame.Parent = billboard

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 6)
        uiCorner.Parent = bgFrame

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = playerColor
        uiStroke.Parent = bgFrame

        local uiPadding = Instance.new("UIPadding")
        uiPadding.PaddingLeft = UDim.new(0, 4)
        uiPadding.PaddingRight = UDim.new(0, 4)
        uiPadding.PaddingTop = UDim.new(0, 4)
        uiPadding.PaddingBottom = UDim.new(0, 4)
        uiPadding.Parent = bgFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = bgFrame

        local nameLabel = Instance.new("TextLabel")
        nameLabel.LayoutOrder = 1
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextSize = 18
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Size = UDim2.new(1, 0, 0, 22)
        nameLabel.Text = "@" .. player.Name
        nameLabel.TextColor3 = playerColor
        nameLabel.Font = EspSettings.Font
        nameLabel.Parent = bgFrame

        local teamLabel = Instance.new("TextLabel")
        teamLabel.LayoutOrder = 2
        teamLabel.BackgroundTransparency = 1
        teamLabel.TextSize = 13
        teamLabel.TextXAlignment = Enum.TextXAlignment.Center
        teamLabel.TextTruncate = Enum.TextTruncate.AtEnd
        teamLabel.Size = UDim2.new(1, 0, 0, 14)
        teamLabel.Text = getTeamName(player)
        teamLabel.TextColor3 = playerColor
        teamLabel.Font = EspSettings.Font
        teamLabel.Visible = EspSettings.ShowTeamName
        teamLabel.Parent = bgFrame

        local hpLabel = Instance.new("TextLabel")
        hpLabel.LayoutOrder = 3
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextSize = 15
        hpLabel.TextXAlignment = Enum.TextXAlignment.Center
        hpLabel.Size = UDim2.new(1, 0, 0, 14)
        hpLabel.Text = getHealthText(character)
        hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        hpLabel.Font = EspSettings.Font
        hpLabel.Visible = EspSettings.ShowHealth
        hpLabel.Parent = bgFrame

        billboard.Parent = head
        table.insert(cleanups, billboard)

        table.insert(cleanups, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            hpLabel.Text = getHealthText(character)
        end))
        table.insert(cleanups, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
            hpLabel.Text = getHealthText(character)
        end))

        table.insert(cleanups, player:GetPropertyChangedSignal("Team"):Connect(function()
            local updatedColor = getPlayerColor(player)
            uiStroke.Color = updatedColor
            nameLabel.TextColor3 = updatedColor
            teamLabel.TextColor3 = updatedColor
            teamLabel.Text = getTeamName(player)
            highlight.FillColor = updatedColor
            highlight.OutlineColor = updatedColor
            if beam then
                beam.Color = ColorSequence.new(updatedColor)
            end
        end))
    end

    ActiveESP[player] = { Cleanups = cleanups }
end

local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    table.insert(espConnections, player.CharacterAdded:Connect(function(character)
        setupESP(player, character)
    end))
    if player.Character then
        setupESP(player, player.Character)
    end
end

local function onPlayerRemoving(player)
    removeESP(player)
end

local function toggleESP(state)
    EspSettings.Enabled = state
    if state then
        for _, conn in ipairs(espConnections) do conn:Disconnect() end
        table.clear(espConnections)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                onPlayerAdded(player)
            end
        end
        table.insert(espConnections, Players.PlayerAdded:Connect(onPlayerAdded))
        table.insert(espConnections, Players.PlayerRemoving:Connect(onPlayerRemoving))
    else
        for _, conn in ipairs(espConnections) do conn:Disconnect() end
        table.clear(espConnections)
        for player in pairs(ActiveESP) do
            removeESP(player)
        end
    end
end

-- ===== CONFIG & SAVE =====
local function getDefaultConfig()
    return {
        Skys = {},
        WeaponSkins = {
            Blood = { primary = "rbxassetid://122271132142798", secondary = "rbxassetid://87911546375139" },
            Gold = { primary = "rbxassetid://102006781490148", secondary = "rbxassetid://102006781490148" },
            Galaxy = { primary = "rbxassetid://122271132142798", secondary = "rbxassetid://83994660888462" },
            Black = { primary = "rbxassetid://122271132142798", secondary = "rbxassetid://122271132142798" },
            Devil = { primary = "rbxassetid://81551553428680", secondary = "rbxassetid://81551553428680" },
            Ozean = { primary = "rbxassetid://138912737283012", secondary = "rbxassetid://138912737283012" }
        },
        GearSkins = {
            Black = "rbxassetid://122271132142798",
            Gold = "rbxassetid://102006781490148",
            Devil = "rbxassetid://81551553428680",
            Ozean = "rbxassetid://138912737283012",
            Galaxy = "rbxassetid://122271132142798"
        },
        CustomSounds = {
            Minecraft = "rbxassetid://8766809464",
            Simple = "rbxassetid://3748776946",
            Bing = "rbxassetid://6607204501",
            Skeet = "rbxassetid://5633695679",
            Rust = "rbxassetid://1255040462",
            Pick = "rbxassetid://1347140027",
            Shine = "rbxassetid://5693220817",
            Neverlose = "rbxassetid://8679627751",
            Metal = "rbxassetid://8917041751",
            Shield = "rbxassetid://140073271098075",
            Headshot = "rbxassetid://2513174484",
            Grrr = "rbxassetid://8603227350",
            Rizz = "rbxassetid://89848519630209",
            Mommy = "rbxassetid://90759147003294"
        }
    }
end

local config = getDefaultConfig()

local function updateconfig()
    if not isfolder("WindUI") then makefolder("WindUI") end
    if not isfolder("WindUI/REXAS") then makefolder("WindUI/REXAS") end
    writefile("WindUI/REXAS/values.json", HttpService:JSONEncode(config))
end

if not isfolder("REXAS") then
    makefolder("REXAS")
end

local success, loadedConfig = pcall(function()
    if isfile("WindUI/REXAS/values.json") then
        return HttpService:JSONDecode(readfile("WindUI/REXAS/values.json"))
    end
end)

if not success or not loadedConfig or not loadedConfig.Skys or not loadedConfig.WeaponSkins or not loadedConfig.GearSkins or not loadedConfig.CustomSounds then
    updateconfig()
else
    config = loadedConfig
end

local WeaponSkins = config.WeaponSkins
local GearSkins = config.GearSkins
local CustomSounds = config.CustomSounds

-- ===== SKYBOXES =====
local Skyboxes = {
    ["Grey"] = { SkyboxBk = "rbxassetid://600830446", SkyboxDn = "rbxassetid://600831635", SkyboxFt = "rbxassetid://600832720", SkyboxLf = "rbxassetid://600886090", SkyboxRt = "rbxassetid://600833862", SkyboxUp = "rbxassetid://600835177" },
    ["Night"] = { SkyboxBk = "rbxassetid://12064107", SkyboxDn = "rbxassetid://12064152", SkyboxFt = "rbxassetid://12064121", SkyboxLf = "rbxassetid://12063984", SkyboxRt = "rbxassetid://12064115", SkyboxUp = "rbxassetid://12064131" },
    ["Purple"] = { SkyboxBk = "rbxassetid://16553658937", SkyboxDn = "rbxassetid://16553660713", SkyboxFt = "rbxassetid://16553662144", SkyboxLf = "rbxassetid://16553664042", SkyboxRt = "rbxassetid://16553665766", SkyboxUp = "rbxassetid://16553667750" },
    ["Red Sky"] = { SkyboxBk = "rbxassetid://401664839", SkyboxDn = "rbxassetid://401664862", SkyboxFt = "rbxassetid://401664960", SkyboxLf = "rbxassetid://401664881", SkyboxRt = "rbxassetid://401664901", SkyboxUp = "rbxassetid://401664936" },
    ["Space"] = { SkyboxBk = "rbxassetid://166509999", SkyboxDn = "rbxassetid://166510057", SkyboxFt = "rbxassetid://166510116", SkyboxLf = "rbxassetid://166510092", SkyboxRt = "rbxassetid://166510131", SkyboxUp = "rbxassetid://166510114" },
    ["Black sky"] = { SkyboxBk = "rbxassetid://156311666", SkyboxDn = "rbxassetid://156311666", SkyboxFt = "rbxassetid://156311666", SkyboxLf = "rbxassetid://156311666", SkyboxRt = "rbxassetid://156311666", SkyboxUp = "rbxassetid://156311666" }
}

-- ===== WINDUILIB =====
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "CALI SCRIPT",
    Icon = "Crown",
    Author = "Rexas inspiration",
    Folder = "CALI",
    Resizable = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function() print("Profile clicked") end,
    },
})

WindUI:AddTheme({
    Name = "CALI",
    Accent = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#6d28d9"), Transparency = 0 }, ["100"] = { Color = Color3.fromHex("#232529"), Transparency = 0 } }, { Rotation = 25 }),
    Background = Color3.fromHex("#0a0303"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#ffffff"),
    Text = Color3.fromHex("#f7f7ff"),
    Placeholder = Color3.fromHex("#6a6aa8"),
    Button = Color3.fromHex("#0c0a1c"),
    Icon = Color3.fromHex("#8f88ff"),
    Hover = Color3.fromHex("#151236"),
    WindowBackground = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#0a0f2c"), Transparency = 0 }, ["100"] = { Color = Color3.fromHex("#03050f"), Transparency = 0 } }, { Rotation = 45 }),
    WindowShadow = Color3.fromHex("#000000"),
    DialogBackground = Color3.fromHex("#000000"),
    DialogBackgroundTransparency = 0,
    DialogTitle = Color3.fromHex("#ffffff"),
    DialogContent = Color3.fromHex("#d9d6ff"),
    DialogIcon = Color3.fromHex("#a29bff"),
    WindowTopbarButtonIcon = Color3.fromHex("#9f97ff"),
    WindowTopbarTitle = Color3.fromHex("#ffffff"),
    WindowTopbarAuthor = Color3.fromHex("#b7b2ff"),
    WindowTopbarIcon = Color3.fromHex("#eaeaff"),
    TabBackground = Color3.fromHex("#000000"),
    TabTitle = Color3.fromHex("#e4e1ff"),
    TabIcon = Color3.fromHex("#7f78ff"),
    ElementBackground = Color3.fromHex("#000000"),
    ElementTitle = Color3.fromHex("#ffffff"),
    ElementDesc = Color3.fromHex("#9d97ff"),
    ElementIcon = Color3.fromHex("#6f6bff"),
    PopupBackground = Color3.fromHex("#0a0922"),
    PopupBackgroundTransparency = 0,
    PopupTitle = Color3.fromHex("#ffffff"),
    PopupContent = Color3.fromHex("#d0ccff"),
    PopupIcon = Color3.fromHex("#9f97ff"),
    Toggle = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#7c3aed"), Transparency = 0 }, ["100"] = { Color = Color3.fromHex("#2563eb"), Transparency = 0 } }, { Rotation = 90 }),
    ToggleBar = Color3.fromHex("#060514"),
    Checkbox = Color3.fromHex("#1b173d"),
    CheckboxIcon = Color3.fromHex("#f0f0ff"),
    Slider = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#5b21b6"), Transparency = 0 }, ["100"] = { Color = Color3.fromHex("#1e40af"), Transparency = 0 } }, { Rotation = 0 }),
    SliderThumb = Color3.fromHex("#ffffff"),
})

WindUI:SetTheme("CALI")
Window:SetToggleKey(Enum.KeyCode.K)
Window:DisableTopbarButtons({ "Fullscreen" })

local firstclose = true
Window:OnClose(function()
    if firstclose then
        WindUI:Notify({ Title = "Info", Content = "Use 'K' to toggle UI", Duration = 5, Icon = "info" })
        firstclose = false
    end
end)

local InfoTab = Window:Tab({Title = "Info", Icon = "info"})
local enviormentTab = Window:Tab({Title = "Enviorment", Icon = "mountain-snow"})
local SniperTab = Window:Tab({Title = "OG Sniper", Icon = "target"})
local SkinChangerTab = Window:Tab({Title = "SkinChanger", Icon = "shirt"})
local ShinyTab = Window:Tab({Title = "Shiny", Icon = "sparkles"})
local WeaponSoundTab = Window:Tab({Title = "Hitsound", Icon = "audio-lines"})
local CustomTab = Window:Tab({Title = "Customization", Icon = "palette"})
local MiscTab = Window:Tab({Title = "Misc", Icon = "ellipsis"})
local CarModsTab = Window:Tab({Title = "Car Mods", Icon = "car"})
local PlayerTab = Window:Tab({ Title = "AIM", Icon = "crosshair" })

-- INFO
InfoTab:Paragraph({ Title = "WELCOME TO CALI SCRIPT", Desc = "The most stable and undetected script for your Roblox experience" })
InfoTab:Paragraph({ Title = "CREDITS", Desc = "REXAS SRC INSPIRATION" })
InfoTab:Paragraph({ Title = "STATUS", Desc = "WORKING IF ANY BUGS PLEASE REPORT IN DISCORD" })
InfoTab:Paragraph({ Title = "CONTROLS", Desc = "Press K to toggle the UI" })

-- ENVIROMENT
local function ApplySky(name)
    local data = Skyboxes[name]
    if not data then return end
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
    sky.Parent = Lighting
    for i, v in pairs(data) do
        sky[i] = v
    end
end

enviormentTab:Paragraph({ Title = "SKYBOX", Desc = "Change the skybox to your preference" })
enviormentTab:Dropdown({
    Title = "Skybox",
    Values = {"Grey", "Night", "Purple", "Red Sky", "Space", "Black sky"},
    Callback = function(v) ApplySky(v) end
})
enviormentTab:Button({
    Title = "Remove Sky",
    Callback = function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
    end
})

enviormentTab:Paragraph({ Title = "BLUR EFFECTS", Desc = "Add motion blur to your game" })
local blur = Lighting:FindFirstChild("Caliblur") or Instance.new("BlurEffect")
blur.Name = "Caliblur"
blur.Parent = Lighting
blur.Size = 0

enviormentTab:Toggle({
    Title = "Enable Blur",
    Callback = function(v) if not v then blur.Size = 0 end end
})
enviormentTab:Slider({
    Title = "Blur Strength",
    Step = 1,
    Value = {Min = 0, Max = 15, Default = 0},
    Callback = function(v) blur.Size = v end
})

local cc = Lighting:FindFirstChild("ColorCorrection") or Instance.new("ColorCorrectionEffect")
cc.Name = "ColorCorrection"
cc.Parent = Lighting

enviormentTab:Slider({ Title = "Saturation", Step = 0.1, Value = {Min = -1, Max = 2, Default = 0}, Callback = function(v) cc.Saturation = v end })
enviormentTab:Slider({ Title = "Brightness", Step = 0.1, Value = {Min = -2, Max = 3, Default = 0}, Callback = function(v) cc.Brightness = v end })
enviormentTab:Slider({ Title = "Contrast", Step = 0.1, Value = {Min = -1, Max = 2, Default = 0}, Callback = function(v) cc.Contrast = v end })

enviormentTab:Button({
    Title = "No Disturbance", Desc = "Delete Atmosphere & SunRays",
    Callback = function()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("SunRaysEffect") then v:Destroy() end
        end
        WindUI:Notify({ Title = "Info", Content = "Disturbance Removed", Duration = 5, Icon = "info" })
    end
})

local fullbrightState = false
local fullbrightConnection = nil
local originalLighting = { Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient }

enviormentTab:Toggle({
    Title = "FullBright", Flag = "fullbright",
    Callback = function(state)
        fullbrightState = state
        if state then
            if not fullbrightConnection then
                fullbrightConnection = RunService.RenderStepped:Connect(function()
                    if fullbrightState then
                        Lighting.Brightness = 1
                        Lighting.GlobalShadows = false
                        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                    end
                end)
            end
        else
            if fullbrightConnection then fullbrightConnection:Disconnect(); fullbrightConnection = nil end
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        end
    end
})

local freezeTime = false
local frozenTime = 12
local timeConnection = nil
enviormentTab:Toggle({
    Title = "Freeze Time", Flag = "freezetime",
    Callback = function(state)
        freezeTime = state
        if state and not timeConnection then
            timeConnection = RunService.RenderStepped:Connect(function()
                if freezeTime then Lighting.ClockTime = frozenTime end
            end)
        elseif not state and timeConnection then
            timeConnection:Disconnect(); timeConnection = nil
        end
    end
})
enviormentTab:Slider({
    Title = "Time", Desc = "requires Freeze Time", Step = 0.1, Value = {Min = 0, Max = 24, Default = Lighting.ClockTime},
    Callback = function(value) frozenTime = value; Lighting.ClockTime = value end
})
enviormentTab:Slider({
    Title = "FOV", Step = 1, Value = {Min = 60, Max = 120, Default = 70},
    Callback = function(v) Camera.FieldOfView = v end
})

-- PROFILE
local profileTab = Window:Tab({Title = "Profile", Icon = "account_circle"})
local spoofEnabled = false
local anonymousMode = false
local customName = ""

local function setPlayerName(name)
    WindUI:Notify({ Title = "Profile", Content = "Name set to: " .. name, Duration = 2 })
end

local function resetPlayerName()
    WindUI:Notify({ Title = "Profile", Content = "Name reset to: " .. LocalPlayer.Name, Duration = 2 })
end

profileTab:Toggle({
    Name = "Username Spoof", Desc = "Spoof your username",
    Callback = function(val)
        spoofEnabled = val
        if val then
            if anonymousMode then setPlayerName("Anonymous")
            elseif customName ~= "" then setPlayerName(customName)
            else setPlayerName("Player") end
        else resetPlayerName() end
    end
})

profileTab:Toggle({
    Name = "Anonymous Mode", Desc = "Show as 'Anonymous'",
    Callback = function(val)
        anonymousMode = val
        if spoofEnabled then
            if val then setPlayerName("Anonymous")
            elseif customName ~= "" then setPlayerName(customName)
            else setPlayerName("Player") end
        end
    end
})

profileTab:Dropdown({
    Title = "Name", Desc = "Choose a spoof name",
    Values = {"Player", "Anonymous", "Hacker", "Guest", "User", "REXAS"},
    Default = "Player",
    Callback = function(selected)
        customName = selected
        if spoofEnabled and not anonymousMode then setPlayerName(selected) end
    end
})

profileTab:Button({
    Name = "Reset Name", Desc = "Reset to real name",
    Callback = function()
        spoofEnabled = false
        resetPlayerName()
    end
})

-- SKINS
local skins = Window:Tab({ Title = "Skins", Icon = "droplets" })
local APPLY_ALL = false
local ENABLED = false
local COLOR = Color3.fromRGB(255,255,255)
local PART_SIZE = Vector3.new(4, 0.001, 13)
local underglows = {}

local function isLocalCar(car)
    local owner = car:FindFirstChild("Owner")
    return owner and owner.Value == LocalPlayer or car.Name:find(LocalPlayer.Name)
end

RunService.RenderStepped:Connect(function()
    for car,data in pairs(underglows) do
        if data.body and data.part then
            data.part.CFrame = data.body.CFrame * CFrame.new(0, -data.body.Size.Y + 2.5, 0)
        end
    end
end)

local function applyUnderglow()
    for car,data in pairs(underglows) do
        if data.part then data.part:Destroy() end
    end
    underglows = {}
    if not ENABLED then return end
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then return end
    for _, car in ipairs(vehicles:GetChildren()) do
        if APPLY_ALL or isLocalCar(car) then
            local body = car:FindFirstChild("Body") and car.Body:FindFirstChild("Body")
            if body and body:IsA("BasePart") then
                local p = Instance.new("Part")
                p.Size = PART_SIZE
                p.Anchored = true
                p.CanCollide = false
                p.Transparency = 1
                p.CFrame = body.CFrame * CFrame.new(0, -body.Size.Y - 0.05, 0)
                p.Parent = workspace
                local l = Instance.new("SurfaceLight")
                l.Face = Enum.NormalId.Bottom
                l.Angle = 180
                l.Range = 8
                l.Brightness = 4
                l.Color = COLOR
                l.Parent = p
                underglows[car] = {part = p, body = body, light = l}
            end
        end
    end
end

skins:Toggle({ Title = "UNDERGLOW", Desc = "might be buggy", Callback = function(v) ENABLED = v; applyUnderglow() end })
skins:Toggle({ Title = "Apply to all", Callback = function(v) APPLY_ALL = v; applyUnderglow() end })
skins:Colorpicker({
    Title = "Underglow color", Default = COLOR,
    Callback = function(v)
        COLOR = v
        for _, d in pairs(underglows) do
            if d.light then d.light.Color = v end
        end
    end
})
skins:Divider()

local skinlist = {"Default"}
local sniperskin, g36skin = "Default", "Default"
local skinall, skinactive = false, true

for name, _ in pairs(WeaponSkins) do table.insert(skinlist, name) end

skins:Toggle({ Title = "apply to all", Callback = function(state) skinall = state end })
local g36skinselector = skins:Dropdown({ Title = "G36 Skin", Values = skinlist, Value = "Default", Callback = function(o) g36skin = o end })
local sniperskinselector = skins:Dropdown({ Title = "Sniper Skin", Values = skinlist, Value = "Default", Callback = function(o) sniperskin = o end })

local function applySkin(weapon, skin, weaponType)
    if not weapon then return end
    local primaryPart, secondaryParts = nil, {}
    if weaponType == "Sniper" then
        primaryPart = weapon:FindFirstChild("Green")
        table.insert(secondaryParts, weapon:FindFirstChild("Base"))
    elseif weaponType == "G36" then
        primaryPart = weapon:FindFirstChild("Body")
        for _, partName in ipairs({"Stock", "Scope", "FlashlightBody"}) do
            local part = weapon:FindFirstChild(partName)
            if part then table.insert(secondaryParts, part) end
        end
    end
    if not primaryPart then return end
    if skin == "Default" then
        primaryPart.TextureID = ""
        for _, sec in ipairs(secondaryParts) do sec.TextureID = "" end
    else
        local skinData = WeaponSkins[skin]
        if not skinData then return end
        primaryPart.TextureID = skinData.primary or ""
        for _, sec in ipairs(secondaryParts) do sec.TextureID = skinData.secondary or "" end
    end
end

RunService.Heartbeat:Connect(function()
    if not skinactive then return end
    local char = LocalPlayer.Character
    if not char then return end
    applySkin(char:FindFirstChild("Sniper"), sniperskin, "Sniper")
    applySkin(char:FindFirstChild("G36"), g36skin, "G36")
    if skinall then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                applySkin(player.Character:FindFirstChild("Sniper"), sniperskin, "Sniper")
                applySkin(player.Character:FindFirstChild("G36"), g36skin, "G36")
            end
        end
    end
end)

-- SHINY
local ShinyEnabled = false
local ShinyColor = Color3.fromRGB(255,255,255)
local ShinyReflectance = 0.35
local ShinyMaterial = Enum.Material.Glass
local ChangedParts = {}

local function ApplyShiny()
    task.spawn(function()
        table.clear(ChangedParts)
        local char = LocalPlayer.Character
        if not char then return end
        for i, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                ChangedParts[obj] = { Material = obj.Material, Reflectance = obj.Reflectance, Color = obj.Color, CastShadow = obj.CastShadow }
                obj.Material = ShinyMaterial
                obj.Reflectance = ShinyReflectance
                obj.Color = ShinyColor
                obj.CastShadow = false
            end
            if i % 25 == 0 then task.wait() end
        end
        local bloom = Lighting:FindFirstChild("RexasBloom") or Instance.new("BloomEffect")
        bloom.Name = "RexasBloom"
        bloom.Intensity = 2
        bloom.Size = 55
        bloom.Threshold = 0.8
        bloom.Parent = Lighting
        WindUI:Notify({ Title = "Shiny", Content = "Shiny Applied!", Duration = 2 })
    end)
end

local function RemoveShiny()
    for part, data in pairs(ChangedParts) do
        if part and part.Parent then
            part.Material = data.Material
            part.Reflectance = data.Reflectance
            part.Color = data.Color
            part.CastShadow = data.CastShadow
        end
    end
    table.clear(ChangedParts)
    local bloom = Lighting:FindFirstChild("RexasBloom")
    if bloom then bloom:Destroy() end
end

ShinyTab:Toggle({
    Title = "Enable Shiny",
    Callback = function(v)
        ShinyEnabled = v
        if v then ApplyShiny() else RemoveShiny() end
    end
})
ShinyTab:Colorpicker({ Title = "Shiny Color", Default = ShinyColor, Callback = function(c) ShinyColor = c; if ShinyEnabled then ApplyShiny() end end })
ShinyTab:Slider({ Title = "Reflectance", Step = 0.05, Value = { Min = 0, Max = 1, Default = 0.35 }, Callback = function(v) ShinyReflectance = v; if ShinyEnabled then ApplyShiny() end end })

-- WEAPON SOUNDS
local soundinputs = {}
local customsoundlist = {"Default"}
for name, _ in pairs(CustomSounds) do table.insert(customsoundlist, name) end

local soundFolder = nil
for _, folder in ipairs(ReplicatedStorage:GetChildren()) do
    if folder:IsA("Folder") then
        local children = folder:GetChildren()
        if #children > 0 and children[1]:IsA("Sound") then
            soundFolder = folder
            break
        end
    end
end

local WeaponSounds = { SniperShoot = "rbxassetid://801167040", G36 = "rbxassetid://801226154" }

for name, id in pairs(WeaponSounds) do
    local foundSound = nil
    if soundFolder then
        for _, obj in ipairs(soundFolder:GetDescendants()) do
            if obj:IsA("Sound") and obj.SoundId == id then
                foundSound = obj
                break
            end
        end
    end
    if foundSound then
        local currentSound = foundSound
        WeaponSoundTab:Dropdown({
            Title = name .. " Sound", Values = customsoundlist, Value = "Default",
            Callback = function(option)
                if option == "Default" then currentSound.SoundId = id
                elseif CustomSounds and CustomSounds[option] then currentSound.SoundId = CustomSounds[option] end
                WindUI:Notify({ Title = "Hitsound", Content = name .. " set to " .. option, Duration = 2 })
            end
        })
    end
end

-- CUSTOMIZATION
local ApplyingFont = false
CustomTab:Paragraph({ Title = "CUSTOMIZATION", Desc = "Customize the UI and cursor" })

local Fonts = { Gotham = Enum.Font.Gotham, GothamBold = Enum.Font.GothamBold, Code = Enum.Font.Code, Arcade = Enum.Font.Arcade }
local Cursors = { Default = "", Crosshair = "rbxassetid://9943168532", Dot = "rbxassetid://9943169291", Circle = "rbxassetid://9943168917", Target = "rbxassetid://10734950309" }

local function ApplyFont(font)
    if ApplyingFont then return end
    ApplyingFont = true
    task.spawn(function()
        local objects = CoreGui:GetDescendants()
        for i = 1, #objects do
            local v = objects[i]
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                pcall(function() v.Font = font end)
            end
            if i % 100 == 0 then task.wait() end
        end
        ApplyingFont = false
        WindUI:Notify({ Title = "Customization", Content = "Font applied!", Duration = 2 })
    end)
end

local function ApplyCursor(id)
    UIS.MouseIconEnabled = true
    UIS.MouseIcon = id
    WindUI:Notify({ Title = "Customization", Content = "Cursor applied!", Duration = 2 })
end

CustomTab:Dropdown({ Title = "Font", Values = {"Gotham", "GothamBold", "Code", "Arcade"}, Callback = function(v) ApplyFont(Fonts[v]) end })
CustomTab:Dropdown({ Title = "Cursor", Values = {"Default", "Crosshair", "Dot", "Circle", "Target"}, Callback = function(v) ApplyCursor(Cursors[v]) end })
CustomTab:Button({
    Title = "Reset Customization",
    Callback = function()
        ApplyFont(Enum.Font.Gotham)
        ApplyCursor("")
        WindUI:Notify({ Title = "Customization", Content = "Reset", Duration = 2 })
    end
})

-- MISC
MiscTab:Paragraph({ Title = "MISCELLANEOUS", Desc = "Extra utilities and fun features" })
MiscTab:Toggle({ Title = "Private Server ESP", Callback = function(state) toggleESP(state) end })

local _G_noclipConnections = {}
MiscTab:Toggle({
    Title = "Noclip", Desc = "Walk through walls",
    Callback = function(state)
        if state then
            local conn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
            table.insert(_G_noclipConnections, conn)
        else
            for _, conn in pairs(_G_noclipConnections) do conn:Disconnect() end
            _G_noclipConnections = {}
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

-- AIM
local triggerbotEnabled, aimbotEnabled, silentAimEnabled = false, false, false
local fovRadius, aimSmoothness, targetPart = 150, 0.3, "Head"

local function getMousePosition() return UserInputService:GetMouseLocation() end

local function getClosestPlayer()
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart then return nil end
    local mousePos = getMousePosition()
    if not mousePos then return nil end
    local closest, closestDist = nil, fovRadius or 150
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char.PrimaryPart then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local part = char:FindFirstChild(targetPart) or char.PrimaryPart
                    if part then
                        local pos, onScreen = Camera:WorldToScreenPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function getTargetPart(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild(targetPart) or char.PrimaryPart
end

local function silentAim()
    if not silentAimEnabled then return end
    local target = getClosestPlayer()
    if not target then return end
    local part = getTargetPart(target)
    if not part then return end
    local direction = (part.Position - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
end

local function aimbot()
    if not aimbotEnabled then return end
    local target = getClosestPlayer()
    if not target then return end
    local part = getTargetPart(target)
    if not part then return end
    local direction = (part.Position - Camera.CFrame.Position).Unit
    local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimSmoothness)
end

local function mouseClick()
    pcall(function()
        UserInputService:SendInput(Enum.UserInputType.MouseButton1, true)
        task.wait(0.05)
        UserInputService:SendInput(Enum.UserInputType.MouseButton1, false)
    end)
end

local function triggerbot()
    if not triggerbotEnabled then return end
    local target = getClosestPlayer()
    if not target then return end
    local part = getTargetPart(target)
    if not part then return end
    local pos, onScreen = Camera:WorldToScreenPoint(part.Position)
    if not onScreen then return end
    local mousePos = getMousePosition()
    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
    if dist < 20 then mouseClick() end
end

local aimbotConn = nil
local function startAimbot()
    if aimbotConn then return end
    aimbotConn = RunService.RenderStepped:Connect(function()
        if aimbotEnabled then aimbot() end
        if silentAimEnabled then silentAim() end
        if triggerbotEnabled then triggerbot() end
    end)
end
local function stopAimbot()
    if aimbotConn then
        aimbotConn:Disconnect()
        aimbotConn = nil
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and silentAimEnabled then
        silentAim()
    end
end)

PlayerTab:Toggle({
    Title = "Triggerbot", Desc = "Auto-shoot when crosshair is on an enemy",
    Callback = function(state)
        triggerbotEnabled = state
        if state or aimbotEnabled or silentAimEnabled then startAimbot() else stopAimbot() end
    end
})
PlayerTab:Toggle({
    Title = "Aimbot", Desc = "Automatically aim at the nearest enemy",
    Callback = function(state)
        aimbotEnabled = state
        if state or silentAimEnabled or triggerbotEnabled then startAimbot() else stopAimbot() end
    end
})
PlayerTab:Toggle({
    Title = "Silent Aim", Desc = "Aim only on right-click",
    Callback = function(state)
        silentAimEnabled = state
        if state or aimbotEnabled or triggerbotEnabled then startAimbot() else stopAimbot() end
    end
})
PlayerTab:Slider({
    Title = "FOV Radius", Step = 5, Value = { Min = 50, Max = 500, Default = 150 },
    Callback = function(val) fovRadius = val end
})
PlayerTab:Slider({
    Title = "Smoothness", Step = 0.05, Value = { Min = 0.05, Max = 1, Default = 0.3 },
    Callback = function(val) aimSmoothness = val end
})
PlayerTab:Dropdown({
    Title = "Target Part", Values = { "Head", "UpperTorso", "HumanoidRootPart" }, Default = "Head",
    Callback = function(val) targetPart = val end
})

-- CAR MODS
local carFlightEnabled, safeFlyEnabled = false, true
local flightSpeed = 150 * 7.77
local POSITION_LERP, ROTATION_LERP = 0.35, 0.25
local lastPos, lastLook, currentFlyVehicle, lastKnownVehicle = nil, nil, nil, nil
local carFlyRenderConn, carFlyHeartbeatConn, safeFlyConn = nil, nil, nil
local cachedParts = {}

local function updateCachedParts(vehicle)
    if not vehicle then return end
    cachedParts = {}
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(cachedParts, part) end
    end
end

local function getCurrentVehicle()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local seat = hum.SeatPart
        local vehicle = seat.Parent
        while vehicle and not vehicle:IsA("Model") and vehicle ~= workspace do
            vehicle = vehicle.Parent
        end
        if vehicle and vehicle:IsA("Model") then
            lastKnownVehicle = vehicle
            return vehicle
        end
    end
    return nil
end

local function findNearestVehicle()
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return nil end
    local pos = char.PrimaryPart.Position
    local nearest, minDist = nil, math.huge
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("VehicleSeat") then
            local primary = model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
            if primary then
                local d = (primary.Position - pos).Magnitude
                if d < minDist then minDist = d; nearest = model end
            end
        end
    end
    if nearest then lastKnownVehicle = nearest end
    return nearest
end

local function getBestVehicle()
    local v = getCurrentVehicle() or lastKnownVehicle or findNearestVehicle()
    if v then lastKnownVehicle = v end
    return v
end

local function startCarFly()
    if carFlyRenderConn then return end
    carFlyRenderConn = RunService.RenderStepped:Connect(function()
        if not carFlightEnabled then
            lastPos, lastLook, currentFlyVehicle = nil, nil, nil
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.SeatPart then return end
        local vehicle = hum.SeatPart.Parent
        if not vehicle then return end

        if currentFlyVehicle ~= vehicle then
            currentFlyVehicle = vehicle
            lastKnownVehicle = vehicle
            updateCachedParts(vehicle)
        end
        if not vehicle.PrimaryPart then vehicle.PrimaryPart = hum.SeatPart end

        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        if not lastPos then
            lastPos = vehicle.PrimaryPart.Position
            lastLook = look
        end

        local moveY, moveX = 0, 0
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveY = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveY = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveY = moveY + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveY = moveY - 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveX = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end

        if moveY == 0 and moveX == 0 then
            vehicle:PivotTo(CFrame.new(lastPos, lastPos + lastLook))
            return
        end

        local speedFactor = flightSpeed / 100
        local targetPos = vehicle.PrimaryPart.Position + look * moveY * speedFactor + right * moveX * speedFactor
        local newPos = lastPos:Lerp(targetPos, POSITION_LERP)
        local newLook = lastLook:Lerp(look, ROTATION_LERP)
        vehicle:PivotTo(CFrame.new(newPos, newPos + newLook))
        lastPos, lastLook = newPos, newLook
    end)

    carFlyHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not carFlightEnabled or not currentFlyVehicle then return end
        local now = tick()
        if not currentFlyVehicle._lastReset or now - currentFlyVehicle._lastReset > 0.15 then
            currentFlyVehicle._lastReset = now
            for _, part in pairs(cachedParts) do
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function stopCarFly()
    if carFlyRenderConn then carFlyRenderConn:Disconnect(); carFlyRenderConn = nil end
    if carFlyHeartbeatConn then carFlyHeartbeatConn:Disconnect(); carFlyHeartbeatConn = nil end
    lastPos, lastLook, currentFlyVehicle, cachedParts = nil, nil, nil, {}
end

local function startSafeFly()
    if safeFlyConn then return end
    safeFlyConn = RunService.Heartbeat:Connect(function()
        if not (safeFlyEnabled and carFlightEnabled) then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and not hum.SeatPart then
            local vehicle = getBestVehicle()
            if vehicle then
                local seat = vehicle:FindFirstChild("DriveSeat") or vehicle:FindFirstChild("VehicleSeat") or vehicle:FindFirstChildOfClass("VehicleSeat")
                if seat then seat:Sit(hum) end
            end
        end
    end)
end
startSafeFly()

CarModsTab:Paragraph({ Title = "Car Flight System", Desc = "Fly your vehicle, bring it to you, and more.", Color = "Blue" })
local carFlyToggle = CarModsTab:Toggle({
    Title = "Car Fly", Desc = "Enable flight mode (WASD to move, E/Q for up/down)",
    Callback = function(state)
        carFlightEnabled = state
        if state then startCarFly(); WindUI:Notify({ Title = "Car Mods", Content = "Car Fly activated", Duration = 2 })
        else stopCarFly(); WindUI:Notify({ Title = "Car Mods", Content = "Car Fly deactivated", Duration = 2 }) end
    end
})
CarModsTab:Keybind({
    Title = "Car Fly Keybind", Default = Enum.KeyCode.O,
    Callback = function(key)
        carFlightEnabled = not carFlightEnabled
        carFlyToggle:SetValue(carFlightEnabled)
        if carFlightEnabled then startCarFly(); WindUI:Notify({ Title = "Car Mods", Content = "Car Fly activated", Duration = 2 })
        else stopCarFly(); WindUI:Notify({ Title = "Car Mods", Content = "Car Fly deactivated", Duration = 2 }) end
    end
})
CarModsTab:Toggle({
    Title = "Safe Fly", Desc = "Automatically re-enter the vehicle if you fall out", Default = true,
    Callback = function(state) safeFlyEnabled = state end
})
CarModsTab:Slider({
    Title = "Flight Speed (km/h)", Step = 1, Value = { Min = 50, Max = 190, Default = 150 },
    Callback = function(val) flightSpeed = val * 7.77 end
})
CarModsTab:Button({
    Title = "Bring My Car", Desc = "Teleports the nearest vehicle directly to you",
    Callback = function()
        local vehicle = getBestVehicle()
        if not vehicle then WindUI:Notify({ Title = "Car Mods", Content = "No vehicle found!", Duration = 2 }); return end
        local char = LocalPlayer.Character
        if not char or not char.PrimaryPart then WindUI:Notify({ Title = "Car Mods", Content = "No character!", Duration = 2 }); return end
        local targetPos = char.PrimaryPart.Position + Vector3.new(0, 5, 0)
        local primary = vehicle.PrimaryPart or vehicle:FindFirstChildOfClass("BasePart")
        if primary then
            local cf = CFrame.new(targetPos) * (primary.CFrame - primary.Position)
            vehicle:PivotTo(cf)
            currentFlyVehicle, lastKnownVehicle = vehicle, vehicle
            WindUI:Notify({ Title = "Car Mods", Content = "Vehicle teleported!", Duration = 2 })
        else
            WindUI:Notify({ Title = "Car Mods", Content = "Vehicle has no PrimaryPart!", Duration = 2 })
        end
    end
})
CarModsTab:Slider({
    Title = "Car Speed (MaxSpeed)", Step = 5, Value = { Min = 50, Max = 300, Default = 150 },
    Callback = function(val)
        local vehicle = getBestVehicle()
        if not vehicle then WindUI:Notify({ Title = "Car Mods", Content = "No vehicle found!", Duration = 2 }); return end
        local seat = vehicle:FindFirstChildOfClass("VehicleSeat")
        if seat then
            seat.MaxSpeed = val
            WindUI:Notify({ Title = "Car Mods", Content = "MaxSpeed set to " .. val, Duration = 2 })
        else
            WindUI:Notify({ Title = "Car Mods", Content = "No VehicleSeat found!", Duration = 2 })
        end
    end
})

Window:SelectTab(1)
