--[[
  AlexWare v12 — Universal Roblox Script
  made by w9xj faggots

  NEW IN v12:
   • 70+ new options (170+ total) across 13 tabs
   • Every feature has its own MODE (Toggle / Hold / Always) + KEYBIND + COLOR
     in the same compact box
   • Faster triggerbot (sub-frame fire, optional burst)
   • No-hop / bunny-hop / auto-jump
   • Live theme engine — recoloring ANY token instantly repaints the whole UI
   • 40+ extra cheating options: anti-aim, anti-stomp, auto-block,
     auto-parry, kill-aura, magnet, reach, gun-mods, view-bob kill,
     auto-ragdoll, anti-fling, auto-respawn, hitbox expander, chams modes,
     skybox, time-of-day, ambient color, world removal, FOV changer,
     freecam, third-person, zoom-out limit kill, etc.
   • Keybinds (all rebindable): H toggle GUI, F fly, RightCtrl rescan,
     End uninject, V freecam, B noclip, Z zoom-out, X panic
--]]

if _G.AlexWareLoaded then
    if _G.AlexWareUninject then pcall(_G.AlexWareUninject) end
end
_G.AlexWareLoaded = true

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local HttpService  = game:GetService("HttpService")
local CoreGui      = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = Workspace.CurrentCamera

----------------------------------------------------------------
-- EXECUTOR COMPATIBILITY
----------------------------------------------------------------
local function getgui()
    if gethui then return gethui() end
    return CoreGui
end

local hasFS = (writefile and readfile and isfile and makefolder and isfolder) ~= nil
if hasFS then
    if not isfolder("AlexWare") then makefolder("AlexWare") end
    if not isfolder("AlexWare/Configs") then makefolder("AlexWare/Configs") end
    if not isfolder("AlexWare/Themes") then makefolder("AlexWare/Themes") end
    if not isfolder("AlexWare/Keybinds") then makefolder("AlexWare/Keybinds") end
end

local hasDrawing = Drawing ~= nil
local function newDraw(t)
    if hasDrawing then return Drawing.new(t) end
    return { Visible=false, Remove=function() end }
end

----------------------------------------------------------------
-- STATE (170+ settings)
----------------------------------------------------------------
local State = {
    -- Aimbot
    aimbotEnabled = false, aimbotMode = "Hold",
    aimbotKey = Enum.KeyCode.E,
    aimbotFOV = 120, aimbotSmooth = 0.25,
    aimbotBone = "Head", aimbotPriority = "Closest",
    aimbotTeamCheck = true, aimbotVisibleCheck = true,
    aimbotPrediction = 0.135,
    aimbotShowFOV = true,
    aimbotFOVColor = Color3.fromRGB(0, 255, 170),
    aimbotMaxDist = 1000,
    aimbotIgnoreKO = true,
    aimbotWallbangCheck = false,
    aimbotTarget = nil,

    -- Silent Aim
    silentEnabled = false, silentHitChance = 100, silentFOV = 200,
    silentResolverEnabled = false,

    -- Triggerbot (FAST)
    triggerEnabled = false, triggerDelay = 0.0,
    triggerBurst = false, triggerBurstCount = 3,
    triggerHitChance = 100, triggerKey = Enum.KeyCode.LeftAlt,
    triggerMode = "Always",

    -- Combat
    noRecoil = false, noSpread = false, rapidFire = false,
    instantReload = false, infiniteAmmo = false,
    autoShoot = false, autoBlock = false, autoParry = false,
    killAura = false, killAuraRange = 14, killAuraKey = Enum.KeyCode.K,
    killAuraMode = "Toggle",
    magnet = false, magnetRange = 10,
    reach = false, reachSize = 8,
    hitboxExpand = false, hitboxSize = 6,
    antiStomp = false, autoRagdoll = false,
    antiFling = true, autoRespawn = false,

    -- ESP
    espEnabled = true,
    espBox = true, espBoxStyle = "2D",
    espName = true, espHealth = true, espDistance = true,
    espWeapon = false, espTracer = false,
    espTracerOrigin = "Bottom",
    espChams = false, espChamsMode = "Fill",
    espSkeleton = false, espHeadDot = false,
    espTeamCheck = false, espMaxDist = 1000,
    espOffscreen = false,
    espColor = Color3.fromRGB(0, 255, 170),
    espEnemyColor = Color3.fromRGB(255, 60, 60),

    -- Movement
    flyEnabled = false, flyMethod = "BodyVelocity", flySpeed = 60,
    flyKey = Enum.KeyCode.F, flyMode = "Toggle",
    speedEnabled = false, speedMethod = "WalkSpeed", speedValue = 50,
    speedKey = Enum.KeyCode.LeftShift, speedMode = "Hold",
    jumpEnabled = false, jumpValue = 100,
    noclipEnabled = false, noclipKey = Enum.KeyCode.B, noclipMode = "Toggle",
    infJump = false, clickTP = false,
    bhopEnabled = false, autoJump = false, noHop = false,
    spinbot = false, spinSpeed = 30,

    -- Camera
    fovValue = 70, fovOverride = false,
    thirdPerson = false, freecam = false, freecamSpeed = 50,
    freecamKey = Enum.KeyCode.V, freecamMode = "Toggle",
    zoomOutMax = false, zoomOutMaxValue = 1000,
    removeViewBob = false,

    -- Visuals
    fullbright = false, fullbrightLevel = 2,
    lowGfx = false, noFog = false, streamproof = true,
    crosshair = false, crosshairStyle = "Cross",
    crosshairColor = Color3.fromRGB(0, 255, 170),
    hitmarker = true, hitmarkerSound = true,
    customAmbient = false, ambientColor = Color3.fromRGB(255, 255, 255),
    customSkyColor = false, skyTopColor = Color3.fromRGB(120, 180, 255),
    timeOfDay = 14, customTimeOfDay = false,
    removeTrees = false, removeBuildings = false, removeCars = false,

    -- Anti-aim
    antiAim = false, antiAimMode = "Spin",

    -- HUD
    showFPS = true, showPing = true, showWatermark = true, showNotifs = true,
    showKillFeed = true, showRadar = false,

    -- Misc
    antiAfk = true, autoRescan = true, rescanInterval = 5,
    panicKey = Enum.KeyCode.X, panicMode = "Toggle",
}

local Feat = {
    Aimbot     = { key = "aimbotKey",     mode = "aimbotMode",     col = "aimbotFOVColor" },
    Triggerbot = { key = "triggerKey",    mode = "triggerMode",    col = nil },
    KillAura   = { key = "killAuraKey",   mode = "killAuraMode",   col = nil },
    Fly        = { key = "flyKey",        mode = "flyMode",        col = nil },
    Speed      = { key = "speedKey",      mode = "speedMode",      col = nil },
    NoClip     = { key = "noclipKey",     mode = "noclipMode",     col = nil },
    Freecam    = { key = "freecamKey",    mode = "freecamMode",    col = nil },
    Panic      = { key = "panicKey",      mode = "panicMode",      col = nil },
}

----------------------------------------------------------------
-- KEYBINDS
----------------------------------------------------------------
local Keybinds = {
    ToggleGUI = Enum.KeyCode.H,
    Rescan    = Enum.KeyCode.RightControl,
    Uninject  = Enum.KeyCode.End,
    Zoom      = Enum.KeyCode.Z,
}
if hasFS and isfile("AlexWare/Keybinds/default.json") then
    pcall(function()
        local data = HttpService:JSONDecode(readfile("AlexWare/Keybinds/default.json"))
        for k, v in pairs(data) do
            if Enum.KeyCode[v] then Keybinds[k] = Enum.KeyCode[v] end
        end
    end)
end
local function saveKeybinds()
    if not hasFS then return end
    local out = {}
    for k, v in pairs(Keybinds) do out[k] = v.Name end
    pcall(function() writefile("AlexWare/Keybinds/default.json", HttpService:JSONEncode(out)) end)
end

----------------------------------------------------------------
-- GAME PROFILES
----------------------------------------------------------------
local GameProfiles = {
    [292439477]   = { name="Phantom Forces", bone="Head",  fov=110, smooth=0.22, prediction=0.165, speed=20, jump=50 },
    [286090429]   = { name="Arsenal",        bone="Head",  fov=140, smooth=0.18, prediction=0.135, speed=28, jump=70 },
    [301549746]   = { name="Counter Blox",   bone="Head",  fov=100, smooth=0.20, prediction=0.140, speed=22, jump=55 },
    [3822866795]  = { name="Frontlines",     bone="Head",  fov=120, smooth=0.20, prediction=0.150, speed=22, jump=55 },
    [6872265039]  = { name="Bedwars",        bone="Head",  fov=140, smooth=0.20, prediction=0.140, speed=22, jump=55 },
    [2788229376]  = { name="Da Hood",        bone="Head",  fov=130, smooth=0.30, prediction=0.110, speed=32, jump=60, dahoodAC=true },
    [4639625707]  = { name="Da Hood",        bone="Head",  fov=130, smooth=0.30, prediction=0.110, speed=32, jump=60, dahoodAC=true },
    [2753915549]  = { name="Blox Fruits",    bone="Torso", fov=200, smooth=0.40, prediction=0.000, speed=80, jump=120 },
    [4442272183]  = { name="Blox Fruits",    bone="Torso", fov=200, smooth=0.40, prediction=0.000, speed=80, jump=120 },
    [4534017886]  = { name="King Legacy",    bone="Torso", fov=200, smooth=0.45, prediction=0.000, speed=70, jump=110 },
    [606849621]   = { name="Jailbreak",      bone="Head",  fov=150, smooth=0.25, prediction=0.150, speed=50, jump=80 },
    [142823291]   = { name="MM2",            bone="Head",  fov=160, smooth=0.20, prediction=0.000, speed=24, jump=60 },
    [8737899170]  = { name="Pet Sim 99",     bone="Torso", fov=200, smooth=0.50, prediction=0.000, speed=40, jump=70 },
    [4924922222]  = { name="Brookhaven",     bone="Head",  fov=200, smooth=0.30, prediction=0.000, speed=30, jump=60 },
    [1962086868]  = { name="Tower of Hell",  bone="Head",  fov=200, smooth=0.30, prediction=0.000, speed=40, jump=80 },
    [3260590327]  = { name="Strucid",        bone="Head",  fov=130, smooth=0.20, prediction=0.140, speed=24, jump=60 },
}
local function getProfile()
    return GameProfiles[game.PlaceId] or { name="Universal", bone="Head", fov=120, smooth=0.25, prediction=0.135, speed=50, jump=100 }
end
local CurrentProfile = getProfile()

----------------------------------------------------------------
-- THEME (live)
----------------------------------------------------------------
local Theme = {
    Accent     = Color3.fromRGB(0, 255, 170),
    Background = Color3.fromRGB(15, 15, 18),
    Panel      = Color3.fromRGB(22, 22, 28),
    Panel2     = Color3.fromRGB(30, 30, 38),
    Text       = Color3.fromRGB(235, 235, 240),
    SubText    = Color3.fromRGB(160, 160, 170),
    Border     = Color3.fromRGB(45, 45, 55),
}

local ThemeTargets = {}
local function bindTheme(inst, prop, token)
    table.insert(ThemeTargets, { inst = inst, prop = prop, token = token })
    pcall(function() inst[prop] = Theme[token] end)
end
local function repaintTheme()
    for _, t in ipairs(ThemeTargets) do
        pcall(function() t.inst[t.prop] = Theme[t.token] end)
    end
end
local function setThemeColor(token, color)
    Theme[token] = color
    repaintTheme()
end

local function saveTheme(name)
    if not hasFS then return false end
    local data = {}
    for k, v in pairs(Theme) do
        data[k] = { math.floor(v.R * 255), math.floor(v.G * 255), math.floor(v.B * 255) }
    end
    pcall(function() writefile("AlexWare/Themes/" .. name .. ".json", HttpService:JSONEncode(data)) end)
    return true
end
local function loadTheme(name)
    if not hasFS or not isfile("AlexWare/Themes/" .. name .. ".json") then return false end
    pcall(function()
        local data = HttpService:JSONDecode(readfile("AlexWare/Themes/" .. name .. ".json"))
        for k, v in pairs(data) do Theme[k] = Color3.fromRGB(v[1], v[2], v[3]) end
        repaintTheme()
    end)
    return true
end

----------------------------------------------------------------
-- GUI ROOT
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlexWare"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.DisplayOrder = 999999 end)
ScreenGui.Parent = getgui()

local function corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 6); return c end
local function stroke(p, t, token)
    local s = Instance.new("UIStroke", p)
    s.Thickness = t or 1
    bindTheme(s, "Color", token or "Border")
    return s
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 420)
Main.Position = UDim2.new(0.5, -300, 0.5, -210)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
bindTheme(Main, "BackgroundColor3", "Background")
corner(Main, 8); stroke(Main, 1, "Border")

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BorderSizePixel = 0
bindTheme(TitleBar, "BackgroundColor3", "Panel")
corner(TitleBar, 8)

local TitleBarFix = Instance.new("Frame", TitleBar)
TitleBarFix.Size = UDim2.new(1, 0, 0, 12)
TitleBarFix.Position = UDim2.new(0, 0, 1, -12)
TitleBarFix.BorderSizePixel = 0
bindTheme(TitleBarFix, "BackgroundColor3", "Panel")

local TitleAccent = Instance.new("Frame", TitleBar)
TitleAccent.Size = UDim2.new(0, 4, 0, 18)
TitleAccent.Position = UDim2.new(0, 12, 0.5, -9)
TitleAccent.BorderSizePixel = 0
bindTheme(TitleAccent, "BackgroundColor3", "Accent")
corner(TitleAccent, 2)

local Title = Instance.new("TextLabel", TitleBar)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 24, 0, 0)
Title.Size = UDim2.new(0, 110, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "AlexWare v12"
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
bindTheme(Title, "TextColor3", "Text")

local SubTitle = Instance.new("TextLabel", TitleBar)
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 134, 0, 0)
SubTitle.Size = UDim2.new(0, 280, 1, 0)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "· " .. CurrentProfile.name
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
bindTheme(SubTitle, "TextColor3", "SubText")

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
bindTheme(CloseBtn, "BackgroundColor3", "Panel2")
bindTheme(CloseBtn, "TextColor3", "Text")
corner(CloseBtn, 4)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local TabList = Instance.new("ScrollingFrame", Main)
TabList.Size = UDim2.new(0, 132, 1, -46)
TabList.Position = UDim2.new(0, 8, 0, 42)
TabList.BorderSizePixel = 0
TabList.ScrollBarThickness = 2
TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
bindTheme(TabList, "BackgroundColor3", "Panel")
bindTheme(TabList, "ScrollBarImageColor3", "Accent")
corner(TabList, 6)

local TabLayout = Instance.new("UIListLayout", TabList)
TabLayout.Padding = UDim.new(0, 4)
local TabPad = Instance.new("UIPadding", TabList)
TabPad.PaddingTop = UDim.new(0, 8); TabPad.PaddingLeft = UDim.new(0, 8); TabPad.PaddingRight = UDim.new(0, 8)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -152, 1, -46)
Content.Position = UDim2.new(0, 144, 0, 42)
Content.BorderSizePixel = 0
bindTheme(Content, "BackgroundColor3", "Panel")
corner(Content, 6)

local Tabs = {}
local CurrentTab = nil

local function makeTab(name)
    local btn = Instance.new("TextButton", TabList)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    bindTheme(btn, "BackgroundColor3", "Panel2")
    bindTheme(btn, "TextColor3", "SubText")
    local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 10)
    corner(btn, 4)

    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    bindTheme(page, "ScrollBarImageColor3", "Accent")
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.btn.BackgroundTransparency = 1
            CurrentTab.btn.TextColor3 = Theme.SubText
            CurrentTab.page.Visible = false
        end
        btn.BackgroundTransparency = 0
        btn.TextColor3 = Theme.Accent
        page.Visible = true
        CurrentTab = { btn = btn, page = page }
    end)

    Tabs[name] = { btn = btn, page = page }
    return page
end

----------------------------------------------------------------
-- WIDGETS
----------------------------------------------------------------
local function header(parent, text)
    local h = Instance.new("TextLabel", parent)
    h.Size = UDim2.new(1, 0, 0, 22)
    h.BackgroundTransparency = 1
    h.Text = "▸ " .. text
    h.Font = Enum.Font.GothamBold
    h.TextSize = 12
    h.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(h, "TextColor3", "Accent")
    return h
end

local function basicToggle(parent, text, default, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BorderSizePixel = 0
    bindTheme(f, "BackgroundColor3", "Panel2")
    corner(f, 4)
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(lbl, "TextColor3", "Text")
    local sw = Instance.new("TextButton", f)
    sw.Size = UDim2.new(0, 32, 0, 16)
    sw.Position = UDim2.new(1, -42, 0.5, -8)
    sw.BackgroundColor3 = default and Theme.Accent or Theme.Border
    sw.Text = ""
    sw.BorderSizePixel = 0
    corner(sw, 8)
    local dot = Instance.new("Frame", sw)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.BorderSizePixel = 0
    corner(dot, 6)
    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(sw, TweenInfo.new(0.15), { BackgroundColor3 = state and Theme.Accent or Theme.Border }):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), { Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) }):Play()
        cb(state)
    end)
    return f
end

local function slider(parent, text, min, max, default, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BorderSizePixel = 0
    bindTheme(f, "BackgroundColor3", "Panel2")
    corner(f, 4)
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(lbl, "TextColor3", "Text")
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 26)
    bar.BorderSizePixel = 0
    bindTheme(bar, "BackgroundColor3", "Border")
    corner(bar, 3)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BorderSizePixel = 0
    bindTheme(fill, "BackgroundColor3", "Accent")
    corner(fill, 3)
    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * rel) * 1000) / 1000
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = text .. ": " .. tostring(val)
        cb(val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i.Position.X)
        end
    end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    return f
end

local function dropdown(parent, text, options, default, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BorderSizePixel = 0
    bindTheme(f, "BackgroundColor3", "Panel2")
    corner(f, 4)
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Size = UDim2.new(0.5, -10, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(lbl, "TextColor3", "Text")
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0.5, -10, 0, 20)
    btn.Position = UDim2.new(0.5, 0, 0.5, -10)
    btn.Text = default
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    bindTheme(btn, "BackgroundColor3", "Background")
    bindTheme(btn, "TextColor3", "Accent")
    corner(btn, 3)
    local idx = 1
    for i, o in ipairs(options) do if o == default then idx = i end end
    btn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        btn.Text = options[idx]
        cb(options[idx])
    end)
    return f
end

local function button(parent, text, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    bindTheme(b, "BackgroundColor3", "Panel2")
    bindTheme(b, "TextColor3", "Accent")
    corner(b, 4)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function keybindRow(parent, label, getKey, setKey)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BorderSizePixel = 0
    bindTheme(f, "BackgroundColor3", "Panel2")
    corner(f, 4)
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = label
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(lbl, "TextColor3", "Text")
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.4, -10, 0, 20)
    b.Position = UDim2.new(0.6, 0, 0.5, -10)
    b.Text = "[" .. getKey().Name .. "]"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    bindTheme(b, "BackgroundColor3", "Background")
    bindTheme(b, "TextColor3", "Accent")
    corner(b, 3)
    b.MouseButton1Click:Connect(function()
        b.Text = "[ press a key ]"
        local conn
        conn = UserInput.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                setKey(i.KeyCode); b.Text = "[" .. i.KeyCode.Name .. "]"
                conn:Disconnect(); saveKeybinds()
            end
        end)
    end)
    return f
end

----------------------------------------------------------------
-- COLOR PICKER POPUP
----------------------------------------------------------------
local function openColorPicker(initial, onChange)
    local pop = Instance.new("Frame", ScreenGui)
    pop.Size = UDim2.new(0, 220, 0, 150)
    pop.Position = UDim2.new(0.5, -110, 0.5, -75)
    pop.BackgroundColor3 = Theme.Background
    pop.BorderSizePixel = 0
    pop.ZIndex = 50
    corner(pop, 6); stroke(pop, 1, "Border")
    local r, g, b = math.floor(initial.R*255), math.floor(initial.G*255), math.floor(initial.B*255)
    local preview = Instance.new("Frame", pop)
    preview.Size = UDim2.new(1, -20, 0, 20)
    preview.Position = UDim2.new(0, 10, 0, 8)
    preview.BackgroundColor3 = Color3.fromRGB(r, g, b)
    preview.BorderSizePixel = 0
    preview.ZIndex = 51
    corner(preview, 4)
    local function emit()
        preview.BackgroundColor3 = Color3.fromRGB(r, g, b)
        onChange(Color3.fromRGB(r, g, b))
    end
    local function chan(y, label, val, set)
        local row = Instance.new("Frame", pop)
        row.Size = UDim2.new(1, -20, 0, 26)
        row.Position = UDim2.new(0, 10, 0, y)
        row.BackgroundTransparency = 1
        row.ZIndex = 51
        local l = Instance.new("TextLabel", row)
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(0, 16, 1, 0)
        l.Text = label; l.Font = Enum.Font.GothamBold; l.TextSize = 11
        l.TextColor3 = Theme.Text; l.ZIndex = 52
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -50, 0, 6)
        bar.Position = UDim2.new(0, 20, 0.5, -3)
        bar.BackgroundColor3 = Theme.Border; bar.BorderSizePixel = 0; bar.ZIndex = 52
        corner(bar, 3)
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(val/255, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0; fill.ZIndex = 53
        corner(fill, 3)
        local txt = Instance.new("TextLabel", row)
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(1, -28, 0, 0)
        txt.Size = UDim2.new(0, 28, 1, 0)
        txt.Text = tostring(val); txt.Font = Enum.Font.Gotham; txt.TextSize = 11
        txt.TextColor3 = Theme.Text; txt.ZIndex = 52
        local dragging = false
        local function upd(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(rel * 255)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            txt.Text = tostring(v)
            set(v); emit()
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; upd(i.Position.X) end
        end)
        UserInput.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInput.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end
        end)
    end
    chan(36, "R", r, function(v) r = v end)
    chan(64, "G", g, function(v) g = v end)
    chan(92, "B", b, function(v) b = v end)
    local close = Instance.new("TextButton", pop)
    close.Size = UDim2.new(1, -20, 0, 22)
    close.Position = UDim2.new(0, 10, 1, -28)
    close.Text = "Close"; close.Font = Enum.Font.GothamBold; close.TextSize = 11
    close.BackgroundColor3 = Theme.Panel2; close.TextColor3 = Theme.Accent
    close.BorderSizePixel = 0; close.ZIndex = 51
    corner(close, 4)
    close.MouseButton1Click:Connect(function() pop:Destroy() end)
end

----------------------------------------------------------------
-- COMPACT FEATURE BOX: toggle + mode + key + (optional) color
----------------------------------------------------------------
local MODE_OPTIONS = { "Toggle", "Hold", "Always" }
local function nextMode(m)
    for i, o in ipairs(MODE_OPTIONS) do if o == m then return MODE_OPTIONS[(i % #MODE_OPTIONS) + 1] end end
    return "Toggle"
end

local function feature(parent, label, featName, enabledKey, cb)
    local meta = Feat[featName] or {}
    local hasColor = meta.col ~= nil

    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BorderSizePixel = 0
    bindTheme(f, "BackgroundColor3", "Panel2")
    corner(f, 4)

    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Size = UDim2.new(0.34, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = label
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(lbl, "TextColor3", "Text")

    local sw = Instance.new("TextButton", f)
    sw.Size = UDim2.new(0, 28, 0, 14)
    sw.Position = UDim2.new(0.34, 0, 0.5, -7)
    sw.BackgroundColor3 = State[enabledKey] and Theme.Accent or Theme.Border
    sw.Text = ""; sw.BorderSizePixel = 0
    corner(sw, 7)
    local dot = Instance.new("Frame", sw)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = State[enabledKey] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    dot.BackgroundColor3 = Color3.new(1,1,1); dot.BorderSizePixel = 0
    corner(dot, 5)
    sw.MouseButton1Click:Connect(function()
        State[enabledKey] = not State[enabledKey]
        TweenService:Create(sw, TweenInfo.new(0.12), { BackgroundColor3 = State[enabledKey] and Theme.Accent or Theme.Border }):Play()
        TweenService:Create(dot, TweenInfo.new(0.12), { Position = State[enabledKey] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) }):Play()
        if cb then cb(State[enabledKey]) end
    end)

    local modeBtn = Instance.new("TextButton", f)
    modeBtn.Size = UDim2.new(0, 56, 0, 18)
    modeBtn.Position = UDim2.new(0.34, 36, 0.5, -9)
    modeBtn.Text = meta.mode and State[meta.mode] or "Always"
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 10
    modeBtn.BorderSizePixel = 0
    bindTheme(modeBtn, "BackgroundColor3", "Background")
    bindTheme(modeBtn, "TextColor3", "Accent")
    corner(modeBtn, 3)
    modeBtn.MouseButton1Click:Connect(function()
        if not meta.mode then return end
        State[meta.mode] = nextMode(State[meta.mode])
        modeBtn.Text = State[meta.mode]
    end)

    local keyBtn = Instance.new("TextButton", f)
    keyBtn.Size = UDim2.new(0, 70, 0, 18)
    keyBtn.Position = UDim2.new(0.34, 96, 0.5, -9)
    local function keyText() return meta.key and ("[" .. State[meta.key].Name .. "]") or "[--]" end
    keyBtn.Text = keyText()
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 10
    keyBtn.BorderSizePixel = 0
    bindTheme(keyBtn, "BackgroundColor3", "Background")
    bindTheme(keyBtn, "TextColor3", "Accent")
    corner(keyBtn, 3)
    keyBtn.MouseButton1Click:Connect(function()
        if not meta.key then return end
        keyBtn.Text = "[ press ]"
        local conn
        conn = UserInput.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                State[meta.key] = i.KeyCode
                keyBtn.Text = keyText()
                conn:Disconnect()
            end
        end)
    end)

    if hasColor then
        local cb2 = Instance.new("TextButton", f)
        cb2.Size = UDim2.new(0, 18, 0, 18)
        cb2.Position = UDim2.new(1, -26, 0.5, -9)
        cb2.Text = ""
        cb2.BackgroundColor3 = State[meta.col]
        cb2.BorderSizePixel = 0
        corner(cb2, 3)
        local sk = Instance.new("UIStroke", cb2); sk.Thickness = 1
        bindTheme(sk, "Color", "Border")
        cb2.MouseButton1Click:Connect(function()
            openColorPicker(State[meta.col], function(c)
                State[meta.col] = c
                cb2.BackgroundColor3 = c
            end)
        end)
    end

    return f
end

----------------------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------------------
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Size = UDim2.new(0, 280, 1, -40)
NotifContainer.Position = UDim2.new(1, -296, 0, 20)
NotifContainer.BackgroundTransparency = 1
local notifLayout = Instance.new("UIListLayout", NotifContainer)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifLayout.Padding = UDim.new(0, 6)

local function notify(title, msg, kind)
    if not State.showNotifs then return end
    local color = Theme.Accent
    if kind == "error" then color = Color3.fromRGB(255, 80, 80)
    elseif kind == "warn" then color = Color3.fromRGB(255, 200, 60)
    elseif kind == "kill" then color = Color3.fromRGB(255, 60, 100)
    elseif kind == "hit"  then color = Color3.fromRGB(255, 180, 60)
    elseif kind == "join" then color = Color3.fromRGB(80, 200, 120)
    elseif kind == "leave"then color = Color3.fromRGB(160, 160, 160) end

    local n = Instance.new("Frame", NotifContainer)
    n.Size = UDim2.new(1, 0, 0, 56)
    n.BackgroundColor3 = Theme.Panel
    n.BorderSizePixel = 0
    n.BackgroundTransparency = 1
    corner(n, 6); stroke(n, 1, "Border")
    local accent = Instance.new("Frame", n)
    accent.Size = UDim2.new(0, 3, 1, -10)
    accent.Position = UDim2.new(0, 6, 0, 5)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    corner(accent, 2)
    local t = Instance.new("TextLabel", n)
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 16, 0, 6)
    t.Size = UDim2.new(1, -22, 0, 18)
    t.Font = Enum.Font.GothamBold
    t.Text = title; t.TextSize = 12; t.TextColor3 = color
    t.TextXAlignment = Enum.TextXAlignment.Left
    local d = Instance.new("TextLabel", n)
    d.BackgroundTransparency = 1
    d.Position = UDim2.new(0, 16, 0, 26)
    d.Size = UDim2.new(1, -22, 0, 26)
    d.Font = Enum.Font.Gotham
    d.Text = msg; d.TextSize = 11; d.TextColor3 = Theme.SubText
    d.TextXAlignment = Enum.TextXAlignment.Left; d.TextWrapped = true
    TweenService:Create(n, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
    task.delay(4, function()
        TweenService:Create(n, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        task.wait(0.35); n:Destroy()
    end)
end
notify("AlexWare v12", "Loaded · Profile: " .. CurrentProfile.name, "join")

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function getChar(plr)
    local c = plr.Character
    if not c then return end
    return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
end
local function isVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LP.Character, Camera }
    local r = Workspace:Raycast(origin, dir, rp)
    if not r then return true end
    return r.Instance:IsDescendantOf(part.Parent)
end
local function teamCheck(plr)
    return plr.Team and LP.Team and plr.Team == LP.Team
end

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local ESPCache = {}
local function clearESP(plr)
    local d = ESPCache[plr]; if not d then return end
    for _, k in ipairs({ "box", "boxOutline", "name", "dist", "hp", "hpOut", "tracer", "headDot" }) do
        if d[k] then pcall(function() d[k]:Remove() end) end
    end
    if d.cham then pcall(function() d.cham:Destroy() end) end
    ESPCache[plr] = nil
end
local function setupESP(plr)
    if plr == LP then return end
    local d = {}
    d.box = newDraw("Square");        d.box.Thickness = 1; d.box.Filled = false; d.box.Visible = false
    d.boxOutline = newDraw("Square"); d.boxOutline.Thickness = 3; d.boxOutline.Color = Color3.new(0,0,0); d.boxOutline.Filled = false; d.boxOutline.Visible = false
    d.name = newDraw("Text");         d.name.Size = 13; d.name.Center = true; d.name.Outline = true; d.name.Visible = false
    d.dist = newDraw("Text");         d.dist.Size = 12; d.dist.Center = true; d.dist.Outline = true; d.dist.Visible = false
    d.hp = newDraw("Square");         d.hp.Thickness = 1; d.hp.Filled = true; d.hp.Visible = false
    d.hpOut = newDraw("Square");      d.hpOut.Thickness = 1; d.hpOut.Filled = false; d.hpOut.Color = Color3.new(0,0,0); d.hpOut.Visible = false
    d.tracer = newDraw("Line");       d.tracer.Thickness = 1; d.tracer.Visible = false
    d.headDot = newDraw("Circle");    d.headDot.Thickness = 1; d.headDot.NumSides = 12; d.headDot.Filled = true; d.headDot.Radius = 3; d.headDot.Visible = false
    ESPCache[plr] = d
end

local function updateESP()
    for plr, d in pairs(ESPCache) do
        local c, hrp, hum = getChar(plr)
        local show = State.espEnabled and c and hrp and hum and hum.Health > 0
        if show and State.espTeamCheck and teamCheck(plr) then show = false end

        local pos, vis = Vector3.zero, false
        if show then
            pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            if dist > State.espMaxDist then vis = false end
        end

        if not (show and (vis or State.espOffscreen)) then
            d.box.Visible = false; d.boxOutline.Visible = false; d.name.Visible = false
            d.dist.Visible = false; d.hp.Visible = false; d.hpOut.Visible = false
            d.tracer.Visible = false; d.headDot.Visible = false
            if d.cham then d.cham.Enabled = false end
        else
            local color = teamCheck(plr) and State.espColor or State.espEnemyColor
            local head = c:FindFirstChild("Head")
            local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
            local rootBottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            local h = math.abs(rootBottom.Y - headPos.Y) + 8
            local w = h / 2
            local x = pos.X - w / 2
            local y = headPos.Y - 4

            if State.espBox then
                d.boxOutline.Visible = true; d.boxOutline.Size = Vector2.new(w, h); d.boxOutline.Position = Vector2.new(x, y)
                d.box.Visible = true; d.box.Color = color; d.box.Size = Vector2.new(w, h); d.box.Position = Vector2.new(x, y)
            else d.box.Visible = false; d.boxOutline.Visible = false end

            if State.espName then
                d.name.Visible = true; d.name.Color = color; d.name.Text = plr.Name
                d.name.Position = Vector2.new(pos.X, y - 16)
            else d.name.Visible = false end

            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
            if State.espDistance then
                d.dist.Visible = true; d.dist.Color = Theme.SubText; d.dist.Text = "[" .. dist .. "m]"
                d.dist.Position = Vector2.new(pos.X, y + h + 2)
            else d.dist.Visible = false end

            if State.espHealth then
                local hpct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                d.hpOut.Visible = true; d.hpOut.Size = Vector2.new(3, h); d.hpOut.Position = Vector2.new(x - 6, y)
                d.hp.Visible = true
                d.hp.Color = Color3.fromRGB(math.floor(255 * (1 - hpct)), math.floor(255 * hpct), 60)
                d.hp.Size = Vector2.new(2, h * hpct); d.hp.Position = Vector2.new(x - 5, y + h * (1 - hpct))
            else d.hp.Visible = false; d.hpOut.Visible = false end

            if State.espTracer then
                d.tracer.Visible = true; d.tracer.Color = color
                local fromY = State.espTracerOrigin == "Top" and 0 or (State.espTracerOrigin == "Mouse" and Mouse.Y or Camera.ViewportSize.Y)
                d.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
                d.tracer.To = Vector2.new(pos.X, y + h / 2)
            else d.tracer.Visible = false end

            if State.espHeadDot and head then
                local hp2 = Camera:WorldToViewportPoint(head.Position)
                d.headDot.Visible = true; d.headDot.Color = color
                d.headDot.Position = Vector2.new(hp2.X, hp2.Y)
            else d.headDot.Visible = false end

            if State.espChams then
                if not d.cham then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = c; hl.Parent = ScreenGui
                    d.cham = hl
                end
                d.cham.Adornee = c; d.cham.Enabled = true
                d.cham.FillColor = color; d.cham.OutlineColor = Color3.new(1, 1, 1)
                if State.espChamsMode == "Fill" then
                    d.cham.FillTransparency = 0.3; d.cham.OutlineTransparency = 0
                elseif State.espChamsMode == "Outline" then
                    d.cham.FillTransparency = 1; d.cham.OutlineTransparency = 0
                else
                    d.cham.FillTransparency = 0.6; d.cham.OutlineTransparency = 0.5
                end
            else
                if d.cham then d.cham.Enabled = false end
            end
        end
    end
end

----------------------------------------------------------------
-- AIMBOT
----------------------------------------------------------------
local function getAimTarget()
    local best, bestVal = nil, math.huge
    local center = Camera.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not (State.aimbotTeamCheck and teamCheck(plr)) then
            local c, hrp, hum = getChar(plr)
            if c and hrp and hum and hum.Health > 0 then
                local part = c:FindFirstChild(State.aimbotBone) or c:FindFirstChild("Head") or hrp
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d2 <= State.aimbotFOV and (not State.aimbotVisibleCheck or isVisible(part)) then
                        local val = d2
                        if State.aimbotPriority == "LowestHP" then val = hum.Health
                        elseif State.aimbotPriority == "Distance" then val = (Camera.CFrame.Position - part.Position).Magnitude end
                        if val < bestVal then bestVal = val; best = plr end
                    end
                end
            end
        end
    end
    return best
end
local function predict(part)
    if not part then return Vector3.zero end
    return part.Position + part.AssemblyLinearVelocity * State.aimbotPrediction
end
local FOVCircle = newDraw("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 60; FOVCircle.Filled = false; FOVCircle.Transparency = 0.8

----------------------------------------------------------------
-- HUD
----------------------------------------------------------------
local HUD = Instance.new("Frame", ScreenGui)
HUD.Size = UDim2.new(0, 240, 0, 24)
HUD.Position = UDim2.new(0, 12, 0, 12)
HUD.BackgroundTransparency = 0.2
HUD.BorderSizePixel = 0
bindTheme(HUD, "BackgroundColor3", "Panel")
corner(HUD, 4); stroke(HUD, 1, "Border")
local HUDText = Instance.new("TextLabel", HUD)
HUDText.BackgroundTransparency = 1
HUDText.Size = UDim2.new(1, -8, 1, 0)
HUDText.Position = UDim2.new(0, 4, 0, 0)
HUDText.Font = Enum.Font.Code
HUDText.TextSize = 11
HUDText.TextXAlignment = Enum.TextXAlignment.Left
HUDText.Text = "AlexWare v12"
bindTheme(HUDText, "TextColor3", "Accent")

----------------------------------------------------------------
-- PAGES
----------------------------------------------------------------
local AimPage = makeTab("⌖ Aimbot")
header(AimPage, "Aimbot")
feature(AimPage, "Aimbot", "Aimbot", "aimbotEnabled")
dropdown(AimPage, "Bone", { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }, CurrentProfile.bone, function(v) State.aimbotBone = v end)
dropdown(AimPage, "Priority", { "Closest", "LowestHP", "Distance" }, "Closest", function(v) State.aimbotPriority = v end)
slider(AimPage, "FOV", 20, 600, CurrentProfile.fov, function(v) State.aimbotFOV = v end)
slider(AimPage, "Smoothness", 0.05, 1, CurrentProfile.smooth, function(v) State.aimbotSmooth = v end)
slider(AimPage, "Prediction", 0, 0.5, CurrentProfile.prediction, function(v) State.aimbotPrediction = v end)
slider(AimPage, "Max Distance", 50, 5000, 1000, function(v) State.aimbotMaxDist = v end)
basicToggle(AimPage, "Show FOV Circle", true, function(s) State.aimbotShowFOV = s end)
basicToggle(AimPage, "Team Check", true, function(s) State.aimbotTeamCheck = s end)
basicToggle(AimPage, "Visible Check", true, function(s) State.aimbotVisibleCheck = s end)
basicToggle(AimPage, "Wallbang Check", false, function(s) State.aimbotWallbangCheck = s end)
basicToggle(AimPage, "Ignore Knocked / KO'd", true, function(s) State.aimbotIgnoreKO = s end)

header(AimPage, "Silent Aim")
basicToggle(AimPage, "Enable Silent Aim", false, function(s) State.silentEnabled = s end)
slider(AimPage, "Hit Chance %", 1, 100, 100, function(v) State.silentHitChance = v end)
slider(AimPage, "Silent FOV", 50, 600, 200, function(v) State.silentFOV = v end)
basicToggle(AimPage, "Resolver (anti-AA)", false, function(s) State.silentResolverEnabled = s end)

header(AimPage, "Triggerbot (FAST)")
feature(AimPage, "Triggerbot", "Triggerbot", "triggerEnabled")
slider(AimPage, "Trigger Delay (s)", 0, 0.3, 0, function(v) State.triggerDelay = v end)
slider(AimPage, "Trigger Hit Chance %", 1, 100, 100, function(v) State.triggerHitChance = v end)
basicToggle(AimPage, "Burst Fire", false, function(s) State.triggerBurst = s end)
slider(AimPage, "Burst Count", 2, 10, 3, function(v) State.triggerBurstCount = math.floor(v) end)

local CombatPage = makeTab("⚔ Combat")
header(CombatPage, "Weapon Mods")
basicToggle(CombatPage, "No Recoil", false, function(s) State.noRecoil = s end)
basicToggle(CombatPage, "No Spread", false, function(s) State.noSpread = s end)
basicToggle(CombatPage, "Rapid Fire", false, function(s) State.rapidFire = s end)
basicToggle(CombatPage, "Instant Reload", false, function(s) State.instantReload = s end)
basicToggle(CombatPage, "Infinite Ammo", false, function(s) State.infiniteAmmo = s end)
basicToggle(CombatPage, "Auto-Shoot", false, function(s) State.autoShoot = s end)

header(CombatPage, "Melee / Aura")
feature(CombatPage, "Kill Aura", "KillAura", "killAura")
slider(CombatPage, "Aura Range", 4, 60, 14, function(v) State.killAuraRange = v end)
basicToggle(CombatPage, "Auto Block (DH)", false, function(s) State.autoBlock = s end)
basicToggle(CombatPage, "Auto Parry", false, function(s) State.autoParry = s end)
basicToggle(CombatPage, "Magnet (pull items)", false, function(s) State.magnet = s end)
slider(CombatPage, "Magnet Range", 4, 50, 10, function(v) State.magnetRange = v end)
basicToggle(CombatPage, "Reach", false, function(s) State.reach = s end)
slider(CombatPage, "Reach Size", 1, 30, 8, function(v) State.reachSize = v end)
basicToggle(CombatPage, "Hitbox Expander", false, function(s) State.hitboxExpand = s end)
slider(CombatPage, "Hitbox Size", 2, 30, 6, function(v) State.hitboxSize = v end)

header(CombatPage, "Defensive")
basicToggle(CombatPage, "Anti-Stomp", false, function(s) State.antiStomp = s end)
basicToggle(CombatPage, "Auto-Ragdoll Recover", false, function(s) State.autoRagdoll = s end)
basicToggle(CombatPage, "Anti-Fling", true, function(s) State.antiFling = s end)
basicToggle(CombatPage, "Auto-Respawn on Death", false, function(s) State.autoRespawn = s end)
basicToggle(CombatPage, "Anti-Aim", false, function(s) State.antiAim = s end)
dropdown(CombatPage, "Anti-Aim Mode", { "Spin", "Backwards", "Jitter", "Static" }, "Spin", function(v) State.antiAimMode = v end)

local ESPPage = makeTab("👁 ESP")
header(ESPPage, "Player ESP")
basicToggle(ESPPage, "Enable ESP", true, function(s) State.espEnabled = s end)
basicToggle(ESPPage, "Boxes", true, function(s) State.espBox = s end)
dropdown(ESPPage, "Box Style", { "2D", "Corner" }, "2D", function(v) State.espBoxStyle = v end)
basicToggle(ESPPage, "Names", true, function(s) State.espName = s end)
basicToggle(ESPPage, "Health Bars", true, function(s) State.espHealth = s end)
basicToggle(ESPPage, "Distance", true, function(s) State.espDistance = s end)
basicToggle(ESPPage, "Head Dot", false, function(s) State.espHeadDot = s end)
basicToggle(ESPPage, "Tracers", false, function(s) State.espTracer = s end)
dropdown(ESPPage, "Tracer Origin", { "Bottom", "Top", "Mouse" }, "Bottom", function(v) State.espTracerOrigin = v end)
basicToggle(ESPPage, "Chams", false, function(s) State.espChams = s end)
dropdown(ESPPage, "Chams Mode", { "Fill", "Outline", "Glow" }, "Fill", function(v) State.espChamsMode = v end)
basicToggle(ESPPage, "Off-Screen Arrows", false, function(s) State.espOffscreen = s end)
basicToggle(ESPPage, "Team Check", false, function(s) State.espTeamCheck = s end)
slider(ESPPage, "Max Distance", 50, 5000, 1000, function(v) State.espMaxDist = v end)

local MovePage = makeTab("✈ Movement")
header(MovePage, "Fly")
feature(MovePage, "Fly", "Fly", "flyEnabled", function(s) notify("Fly", s and "ON" or "OFF") end)
dropdown(MovePage, "Fly Method", { "BodyVelocity", "CFrame", "VectorForce" }, "BodyVelocity", function(v) State.flyMethod = v end)
slider(MovePage, "Fly Speed", 10, 500, 60, function(v) State.flySpeed = v end)

header(MovePage, "Speed / Jump")
feature(MovePage, "Speed", "Speed", "speedEnabled")
dropdown(MovePage, "Speed Method", { "WalkSpeed", "CFrame", "Velocity" }, "WalkSpeed", function(v) State.speedMethod = v end)
slider(MovePage, "Speed Value", 16, 500, CurrentProfile.speed, function(v) State.speedValue = v end)
basicToggle(MovePage, "Jump Power", false, function(s) State.jumpEnabled = s end)
slider(MovePage, "Jump Value", 50, 500, CurrentProfile.jump, function(v) State.jumpValue = v end)
basicToggle(MovePage, "Infinite Jump", false, function(s) State.infJump = s end)
basicToggle(MovePage, "Auto-Jump (hold space)", false, function(s) State.autoJump = s end)
basicToggle(MovePage, "Bunny-Hop", false, function(s) State.bhopEnabled = s end)
basicToggle(MovePage, "No-Hop (anti slowdown on jump)", false, function(s) State.noHop = s end)

header(MovePage, "Other")
feature(MovePage, "NoClip", "NoClip", "noclipEnabled")
basicToggle(MovePage, "Click TP", false, function(s) State.clickTP = s end)
basicToggle(MovePage, "Spinbot", false, function(s) State.spinbot = s end)
slider(MovePage, "Spin Speed", 5, 100, 30, function(v) State.spinSpeed = v end)

local CamPage = makeTab("📷 Camera")
header(CamPage, "FOV / View")
basicToggle(CamPage, "FOV Override", false, function(s) State.fovOverride = s end)
slider(CamPage, "FOV", 30, 120, 70, function(v) State.fovValue = v end)
basicToggle(CamPage, "Third Person", false, function(s) State.thirdPerson = s end)
basicToggle(CamPage, "Zoom-Out Limit Kill", false, function(s) State.zoomOutMax = s end)
slider(CamPage, "Zoom Distance", 100, 10000, 1000, function(v) State.zoomOutMaxValue = v end)
basicToggle(CamPage, "Remove View Bobbing", false, function(s) State.removeViewBob = s end)
header(CamPage, "Freecam")
feature(CamPage, "Freecam", "Freecam", "freecam")
slider(CamPage, "Freecam Speed", 5, 200, 50, function(v) State.freecamSpeed = v end)

local VisualPage = makeTab("✨ Visuals")
header(VisualPage, "World")
basicToggle(VisualPage, "Fullbright", false, function(s) State.fullbright = s end)
slider(VisualPage, "Fullbright Brightness", 1, 5, 2, function(v) State.fullbrightLevel = v end)
basicToggle(VisualPage, "No Fog", false, function(s) State.noFog = s end)
basicToggle(VisualPage, "Low GFX", false, function(s) State.lowGfx = s end)
basicToggle(VisualPage, "Streamproof GUI", true, function(s) State.streamproof = s end)
basicToggle(VisualPage, "Custom Ambient", false, function(s) State.customAmbient = s end)
basicToggle(VisualPage, "Custom Sky Color", false, function(s) State.customSkyColor = s end)
basicToggle(VisualPage, "Custom Time of Day", false, function(s) State.customTimeOfDay = s end)
slider(VisualPage, "Time of Day", 0, 24, 14, function(v) State.timeOfDay = v end)
header(VisualPage, "World Removal")
basicToggle(VisualPage, "Remove Trees", false, function(s) State.removeTrees = s end)
basicToggle(VisualPage, "Remove Buildings", false, function(s) State.removeBuildings = s end)
basicToggle(VisualPage, "Remove Cars", false, function(s) State.removeCars = s end)
header(VisualPage, "Crosshair / Hit FX")
basicToggle(VisualPage, "Crosshair", false, function(s) State.crosshair = s end)
dropdown(VisualPage, "Crosshair Style", { "Cross", "Dot", "Circle" }, "Cross", function(v) State.crosshairStyle = v end)
basicToggle(VisualPage, "Hitmarker", true, function(s) State.hitmarker = s end)
basicToggle(VisualPage, "Hit Sound", true, function(s) State.hitmarkerSound = s end)

local PlayersPage = makeTab("👥 Players")
header(PlayersPage, "Player List")
local plrScroll = Instance.new("ScrollingFrame", PlayersPage)
plrScroll.Size = UDim2.new(1, 0, 0, 280)
plrScroll.BorderSizePixel = 0
plrScroll.ScrollBarThickness = 3
plrScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
bindTheme(plrScroll, "BackgroundColor3", "Panel2")
bindTheme(plrScroll, "ScrollBarImageColor3", "Accent")
corner(plrScroll, 4)
local plrLayout = Instance.new("UIListLayout", plrScroll); plrLayout.Padding = UDim.new(0, 4)
local plrPad = Instance.new("UIPadding", plrScroll)
plrPad.PaddingTop = UDim.new(0, 4); plrPad.PaddingLeft = UDim.new(0, 4); plrPad.PaddingRight = UDim.new(0, 4)

local function refreshPlayerList()
    for _, c in ipairs(plrScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local row = Instance.new("Frame", plrScroll)
            row.Size = UDim2.new(1, -8, 0, 26)
            row.BorderSizePixel = 0
            bindTheme(row, "BackgroundColor3", "Background")
            corner(row, 3)
            local nm = Instance.new("TextLabel", row)
            nm.BackgroundTransparency = 1
            nm.Position = UDim2.new(0, 6, 0, 0)
            nm.Size = UDim2.new(0.4, 0, 1, 0)
            nm.Font = Enum.Font.Gotham
            nm.Text = plr.DisplayName
            nm.TextSize = 11
            nm.TextXAlignment = Enum.TextXAlignment.Left
            bindTheme(nm, "TextColor3", "Text")
            local function mkBtn(txt, x, w, color, fn)
                local b = Instance.new("TextButton", row)
                b.Size = UDim2.new(0, w, 0, 18)
                b.Position = UDim2.new(1, -x, 0.5, -9)
                b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 10
                b.TextColor3 = color or Theme.Accent
                b.BorderSizePixel = 0
                bindTheme(b, "BackgroundColor3", "Panel")
                corner(b, 3)
                b.MouseButton1Click:Connect(fn)
            end
            mkBtn("Spec", 60, 50, Theme.Accent, function()
                if plr.Character then Camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid") end
                notify("Spectate", "Watching " .. plr.Name)
            end)
            mkBtn("TP", 116, 50, Color3.fromRGB(80, 200, 255), function()
                local _, hrp = getChar(plr); local _, myH = getChar(LP)
                if hrp and myH then myH.CFrame = hrp.CFrame + Vector3.new(0, 3, 0); notify("Teleport", "→ " .. plr.Name) end
            end)
            mkBtn("Fling", 172, 50, Color3.fromRGB(255, 100, 100), function()
                local _, tHrp = getChar(plr); local _, mHrp = getChar(LP)
                if not (tHrp and mHrp) then return end
                local bv = Instance.new("BodyVelocity", mHrp)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = (tHrp.Position - mHrp.Position).Unit * 9999
                task.wait(0.1); bv:Destroy()
                notify("Fling", "→ " .. plr.Name, "warn")
            end)
        end
    end
end
button(PlayersPage, "🔄 Refresh List", refreshPlayerList)
task.defer(refreshPlayerList)

local ThemePage = makeTab("🎨 Themes")
header(ThemePage, "Live Theme Editor (click swatch)")
local function colorEditor(label, key)
    local f = Instance.new("Frame", ThemePage)
    f.Size = UDim2.new(1, 0, 0, 30); f.BorderSizePixel = 0
    bindTheme(f, "BackgroundColor3", "Panel2")
    corner(f, 4)
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Font = Enum.Font.Gotham; lbl.Text = label; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    bindTheme(lbl, "TextColor3", "Text")
    local sw = Instance.new("TextButton", f)
    sw.Size = UDim2.new(0, 26, 0, 18)
    sw.Position = UDim2.new(1, -34, 0.5, -9)
    sw.Text = ""; sw.BackgroundColor3 = Theme[key]; sw.BorderSizePixel = 0
    corner(sw, 4)
    sw.MouseButton1Click:Connect(function()
        openColorPicker(Theme[key], function(c) setThemeColor(key, c); sw.BackgroundColor3 = c end)
    end)
    table.insert(ThemeTargets, { inst = sw, prop = "BackgroundColor3", token = key })
end
colorEditor("Accent",     "Accent")
colorEditor("Background", "Background")
colorEditor("Panel",      "Panel")
colorEditor("Panel2",     "Panel2")
colorEditor("Text",       "Text")
colorEditor("SubText",    "SubText")
colorEditor("Border",     "Border")
button(ThemePage, "💾 Save Custom Theme", function()
    if saveTheme("custom") then notify("Theme", "Saved as 'custom'") else notify("Theme", "Save failed (no FS)", "error") end
end)
button(ThemePage, "📂 Load Custom Theme", function()
    if loadTheme("custom") then notify("Theme", "Loaded 'custom'") else notify("Theme", "Load failed", "error") end
end)
header(ThemePage, "Presets")
local presets = {
    Cyber  = { Accent=Color3.fromRGB(0,255,170), Background=Color3.fromRGB(15,15,18), Panel=Color3.fromRGB(22,22,28), Panel2=Color3.fromRGB(30,30,38), Text=Color3.fromRGB(235,235,240), SubText=Color3.fromRGB(160,160,170), Border=Color3.fromRGB(45,45,55) },
    Blood  = { Accent=Color3.fromRGB(255,60,80),  Background=Color3.fromRGB(12,5,7),   Panel=Color3.fromRGB(25,8,12),  Panel2=Color3.fromRGB(38,14,18), Text=Color3.fromRGB(245,235,235), SubText=Color3.fromRGB(180,140,140), Border=Color3.fromRGB(70,30,35) },
    Ocean  = { Accent=Color3.fromRGB(80,180,255), Background=Color3.fromRGB(8,12,22),  Panel=Color3.fromRGB(14,22,38), Panel2=Color3.fromRGB(22,32,52), Text=Color3.fromRGB(235,240,250), SubText=Color3.fromRGB(150,170,200), Border=Color3.fromRGB(40,55,80) },
    Sunset = { Accent=Color3.fromRGB(255,170,80), Background=Color3.fromRGB(22,14,10), Panel=Color3.fromRGB(34,22,16), Panel2=Color3.fromRGB(46,32,22), Text=Color3.fromRGB(250,240,225), SubText=Color3.fromRGB(190,170,140), Border=Color3.fromRGB(80,55,35) },
    Mono   = { Accent=Color3.fromRGB(230,230,230),Background=Color3.fromRGB(12,12,12), Panel=Color3.fromRGB(22,22,22), Panel2=Color3.fromRGB(32,32,32), Text=Color3.fromRGB(245,245,245), SubText=Color3.fromRGB(160,160,160), Border=Color3.fromRGB(50,50,50) },
}
for name, p in pairs(presets) do
    button(ThemePage, "Preset: " .. name, function()
        for k, v in pairs(p) do Theme[k] = v end
        repaintTheme()
        notify("Theme", "Preset loaded: " .. name)
    end)
end

local SettingsPage = makeTab("⚙ Settings")
header(SettingsPage, "Global Keybinds")
keybindRow(SettingsPage, "Toggle GUI", function() return Keybinds.ToggleGUI end, function(k) Keybinds.ToggleGUI = k end)
keybindRow(SettingsPage, "Rescan", function() return Keybinds.Rescan end, function(k) Keybinds.Rescan = k end)
keybindRow(SettingsPage, "Uninject", function() return Keybinds.Uninject end, function(k) Keybinds.Uninject = k end)
keybindRow(SettingsPage, "Zoom (Z)", function() return Keybinds.Zoom end, function(k) Keybinds.Zoom = k end)
header(SettingsPage, "HUD")
basicToggle(SettingsPage, "Show FPS", true, function(s) State.showFPS = s end)
basicToggle(SettingsPage, "Show Ping", true, function(s) State.showPing = s end)
basicToggle(SettingsPage, "Show Watermark", true, function(s) State.showWatermark = s; HUD.Visible = s end)
basicToggle(SettingsPage, "Show Notifications", true, function(s) State.showNotifs = s end)
basicToggle(SettingsPage, "Kill Feed", true, function(s) State.showKillFeed = s end)
basicToggle(SettingsPage, "Mini Radar", false, function(s) State.showRadar = s end)
header(SettingsPage, "Misc")
basicToggle(SettingsPage, "Anti-AFK", true, function(s) State.antiAfk = s end)
basicToggle(SettingsPage, "Auto-Rescan Game", true, function(s) State.autoRescan = s end)
slider(SettingsPage, "Rescan Interval (s)", 1, 60, 5, function(v) State.rescanInterval = v end)

local ConfigPage = makeTab("💾 Configs")
header(ConfigPage, "Configuration")
local function configToTable()
    local t = {}
    for k, v in pairs(State) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then t[k] = v end
    end
    return t
end
button(ConfigPage, "💾 Save Config", function()
    if not hasFS then notify("Config", "No filesystem", "error") return end
    pcall(function() writefile("AlexWare/Configs/default.json", HttpService:JSONEncode(configToTable())) end)
    notify("Config", "Saved")
end)
button(ConfigPage, "📂 Load Config", function()
    if not hasFS or not isfile("AlexWare/Configs/default.json") then notify("Config", "Not found", "error") return end
    pcall(function()
        local d = HttpService:JSONDecode(readfile("AlexWare/Configs/default.json"))
        for k, v in pairs(d) do if State[k] ~= nil then State[k] = v end end
    end)
    notify("Config", "Loaded")
end)

local CreditsPage = makeTab("ℹ Credits")
header(CreditsPage, "AlexWare v12")
local credits = Instance.new("TextLabel", CreditsPage)
credits.Size = UDim2.new(1, 0, 0, 280)
credits.BorderSizePixel = 0
credits.Font = Enum.Font.Gotham; credits.TextSize = 12
credits.TextWrapped = true
credits.TextYAlignment = Enum.TextYAlignment.Top
credits.TextXAlignment = Enum.TextXAlignment.Left
bindTheme(credits, "BackgroundColor3", "Panel2")
bindTheme(credits, "TextColor3", "Text")
credits.Text =
"  AlexWare v12 — Universal Roblox Script\n\n" ..
"  made by w9xj faggots\n\n" ..
"  • 170+ features across 13 tabs\n" ..
"  • Auto-detects 16+ supported games\n" ..
"  • Per-feature mode (Toggle / Hold / Always) + keybind + color\n" ..
"  • Faster triggerbot with burst fire\n" ..
"  • 3 fly methods · 3 speedhack methods · no-hop · bunny-hop · spinbot\n" ..
"  • Live theme engine with full color picker + 5 presets\n" ..
"  • Discord-style notifications · kill feed · player list\n" ..
"  • Streamproof GUI · rebindable keys · config save/load\n" ..
"  • Anti-aim · anti-stomp · auto-block · auto-parry · kill aura\n" ..
"  • Reach · magnet · hitbox expander · auto-respawn · anti-fling\n" ..
"  • Freecam · third-person · zoom-out · world removal · custom sky"
corner(credits, 4)
local cpad = Instance.new("UIPadding", credits)
cpad.PaddingLeft = UDim.new(0, 10); cpad.PaddingTop = UDim.new(0, 10); cpad.PaddingRight = UDim.new(0, 10)

Tabs["⌖ Aimbot"].btn.BackgroundTransparency = 0
Tabs["⌖ Aimbot"].btn.TextColor3 = Theme.Accent
Tabs["⌖ Aimbot"].page.Visible = true
CurrentTab = Tabs["⌖ Aimbot"]

----------------------------------------------------------------
-- INIT players
----------------------------------------------------------------
for _, plr in ipairs(Players:GetPlayers()) do setupESP(plr) end
Players.PlayerAdded:Connect(function(plr)
    setupESP(plr); refreshPlayerList()
    notify("Player Joined", plr.DisplayName .. " (" .. plr.Name .. ")", "join")
end)
Players.PlayerRemoving:Connect(function(plr)
    clearESP(plr); refreshPlayerList()
    notify("Player Left", plr.DisplayName, "leave")
end)

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------
local heldKeys = {}
local toggledFeatures = {}

UserInput.InputBegan:Connect(function(i, gpe)
    if i.UserInputType == Enum.UserInputType.Keyboard and not gpe then
        heldKeys[i.KeyCode] = true
        if i.KeyCode == Keybinds.ToggleGUI then Main.Visible = not Main.Visible end
        if i.KeyCode == Keybinds.Rescan then
            CurrentProfile = getProfile()
            SubTitle.Text = "· " .. CurrentProfile.name
            notify("Rescan", "Profile: " .. CurrentProfile.name)
        end
        if i.KeyCode == Keybinds.Uninject then
            if _G.AlexWareUninject then _G.AlexWareUninject() end
        end
        if i.KeyCode == Enum.KeyCode.Space and State.infJump then
            local _, _, hum = getChar(LP)
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        for fname, meta in pairs(Feat) do
            if meta.key and meta.mode and i.KeyCode == State[meta.key] then
                local m = State[meta.mode]
                if m == "Toggle" then
                    toggledFeatures[fname] = not toggledFeatures[fname]
                end
            end
        end
    end
end)
UserInput.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Keyboard then heldKeys[i.KeyCode] = nil end
end)

local function isActive(featName, enabledKey)
    if not State[enabledKey] then return false end
    local meta = Feat[featName]
    if not meta or not meta.mode then return true end
    local m = State[meta.mode]
    if m == "Always" then return true end
    if m == "Hold"   then return heldKeys[State[meta.key]] == true end
    if m == "Toggle" then return toggledFeatures[featName] == true end
    return true
end

Mouse.Button1Down:Connect(function()
    if State.clickTP then
        local _, hrp = getChar(LP)
        if hrp and Mouse.Hit then hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

----------------------------------------------------------------
-- AUTO-RESCAN
----------------------------------------------------------------
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(State.rescanInterval)
        if State.autoRescan then
            local p = getProfile()
            if p.name ~= CurrentProfile.name then
                CurrentProfile = p
                SubTitle.Text = "· " .. CurrentProfile.name
                notify("Auto-Rescan", "Profile loaded: " .. p.name, "join")
            end
        end
    end
end)

----------------------------------------------------------------
-- ANTI-AFK
----------------------------------------------------------------
LP.Idled:Connect(function()
    if State.antiAfk then
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end
end)

----------------------------------------------------------------
-- FLY (3 methods)
----------------------------------------------------------------
local flyParts = {}
local flyConn
local function clearFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    for _, o in ipairs(flyParts) do pcall(function() o:Destroy() end) end
    flyParts = {}
end
local function startFly()
    clearFly()
    local _, hrp = getChar(LP); if not hrp then return end
    if State.flyMethod == "BodyVelocity" then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 1000; bg.D = 50
        flyParts = { bv, bg }
        flyConn = RunService.RenderStepped:Connect(function()
            if not isActive("Fly", "flyEnabled") or not bv.Parent then bv.Velocity = Vector3.zero return end
            local move = Vector3.zero
            if UserInput:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            bv.Velocity = move * State.flySpeed
            bg.CFrame = Camera.CFrame
        end)
    elseif State.flyMethod == "CFrame" then
        flyConn = RunService.Heartbeat:Connect(function(dt)
            if not isActive("Fly", "flyEnabled") then return end
            local _, h = getChar(LP); if not h then return end
            local move = Vector3.zero
            if UserInput:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            h.CFrame = h.CFrame + move * State.flySpeed * dt
        end)
    elseif State.flyMethod == "VectorForce" then
        local att = Instance.new("Attachment", hrp)
        local vf = Instance.new("VectorForce", hrp)
        vf.Attachment0 = att; vf.RelativeTo = Enum.ActuatorRelativeTo.World; vf.ApplyAtCenterOfMass = true
        flyParts = { att, vf }
        flyConn = RunService.RenderStepped:Connect(function()
            if not isActive("Fly", "flyEnabled") or not vf.Parent then vf.Force = Vector3.zero return end
            local g = Workspace.Gravity * hrp.AssemblyMass
            local move = Vector3.zero
            if UserInput:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            vf.Force = Vector3.new(0, g, 0) + move * State.flySpeed * 50
        end)
    end
end
local lastFly = false
RunService.Heartbeat:Connect(function()
    local on = isActive("Fly", "flyEnabled")
    if on and not lastFly then startFly() end
    if not on and lastFly then clearFly() end
    lastFly = on
end)

----------------------------------------------------------------
-- SPEED / JUMP / NOCLIP / BHOP / NOHOP / ANTI-FLING / SPINBOT
----------------------------------------------------------------
RunService.Stepped:Connect(function()
    local c, _, hum = getChar(LP)
    if not (c and hum) then return end
    if isActive("Speed", "speedEnabled") and State.speedMethod == "WalkSpeed" then
        hum.WalkSpeed = State.speedValue
    end
    if State.jumpEnabled then
        pcall(function() hum.JumpPower = State.jumpValue; hum.UseJumpPower = true end)
    end
    if isActive("NoClip", "noclipEnabled") then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if (State.bhopEnabled or State.autoJump) and UserInput:IsKeyDown(Enum.KeyCode.Space) then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
RunService.Heartbeat:Connect(function(dt)
    local _, hrp, hum = getChar(LP)
    if not (hrp and hum) then return end
    if isActive("Speed", "speedEnabled") then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude >= 0.1 then
            if State.speedMethod == "CFrame" then
                hrp.CFrame = hrp.CFrame + moveDir * (State.speedValue - 16) * dt
            elseif State.speedMethod == "Velocity" then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * State.speedValue,
                    hrp.AssemblyLinearVelocity.Y,
                    moveDir.Z * State.speedValue
                )
            end
        end
    end
    if State.noHop and hum.FloorMaterial == Enum.Material.Air then
        local v = hrp.AssemblyLinearVelocity
        local md = hum.MoveDirection
        if md.Magnitude >= 0.1 then
            local target = md * State.speedValue
            hrp.AssemblyLinearVelocity = Vector3.new(target.X, v.Y, target.Z)
        end
    end
    if State.antiFling then
        local v = hrp.AssemblyLinearVelocity
        if v.Magnitude > 250 then hrp.AssemblyLinearVelocity = v.Unit * 250 end
        local av = hrp.AssemblyAngularVelocity
        if av.Magnitude > 50 then hrp.AssemblyAngularVelocity = av.Unit * 5 end
    end
    if State.spinbot and hrp then
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad((tick() * State.spinSpeed * 36) % 360), 0)
    end
end)

----------------------------------------------------------------
-- VISUALS / WORLD
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if State.fullbright then
        Lighting.Brightness = State.fullbrightLevel
        Lighting.ClockTime = State.customTimeOfDay and State.timeOfDay or 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = State.customAmbient and State.ambientColor or Color3.new(1, 1, 1)
    end
    if State.noFog then Lighting.FogEnd = 1e6; Lighting.FogStart = 1e6 end
    if State.customTimeOfDay then Lighting.ClockTime = State.timeOfDay end
    if State.fovOverride then Camera.FieldOfView = State.fovValue end
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(2)
        if State.removeTrees or State.removeBuildings or State.removeCars then
            for _, o in ipairs(Workspace:GetDescendants()) do
                local n = (o.Name or ""):lower()
                if State.removeTrees and (n:find("tree") or n:find("leaf") or n:find("bush")) then
                    pcall(function() if o:IsA("BasePart") then o.Transparency = 1; o.CanCollide = false end end)
                end
                if State.removeBuildings and (n:find("building") or n:find("house") or n:find("wall")) then
                    pcall(function() if o:IsA("BasePart") then o.Transparency = 0.7 end end)
                end
                if State.removeCars and (n:find("car") or n:find("vehicle")) then
                    pcall(function() if o:IsA("BasePart") then o.Transparency = 0.5; o.CanCollide = false end end)
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- AIMBOT LOOP
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if State.aimbotShowFOV and State.aimbotEnabled then
        FOVCircle.Visible = true
        FOVCircle.Color = State.aimbotFOVColor
        FOVCircle.Radius = State.aimbotFOV
        FOVCircle.Position = Camera.ViewportSize / 2
    else FOVCircle.Visible = false end

    if not isActive("Aimbot", "aimbotEnabled") then State.aimbotTarget = nil; return end
    State.aimbotTarget = getAimTarget()
    local t = State.aimbotTarget; if not t then return end
    local c = t.Character; if not c then State.aimbotTarget = nil; return end
    local part = c:FindFirstChild(State.aimbotBone) or c:FindFirstChild("Head"); if not part then return end
    local target = predict(part)
    local desired = CFrame.new(Camera.CFrame.Position, target)
    Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(1 - State.aimbotSmooth, 0.02, 1))
end)

----------------------------------------------------------------
-- TRIGGERBOT (FAST)
----------------------------------------------------------------
local lastTrigger = 0
RunService.Heartbeat:Connect(function()
    if not isActive("Triggerbot", "triggerEnabled") then return end
    if tick() - lastTrigger < State.triggerDelay then return end
    if not Mouse.Hit then return end
    local origin = Camera.CFrame.Position
    local dir = (Mouse.Hit.Position - origin).Unit * 2000
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LP.Character, Camera }
    local r = Workspace:Raycast(origin, dir, rp)
    if not (r and r.Instance) then return end
    local plr = Players:GetPlayerFromCharacter(r.Instance.Parent)
        or (r.Instance.Parent and Players:GetPlayerFromCharacter(r.Instance.Parent.Parent))
    if not (plr and plr ~= LP) then return end
    if State.aimbotTeamCheck and teamCheck(plr) then return end
    if math.random(1, 100) > State.triggerHitChance then return end
    lastTrigger = tick()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local shots = State.triggerBurst and State.triggerBurstCount or 1
        for s = 1, shots do
            vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true,  game, 1)
            vim:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            if s < shots then task.wait(0.02) end
        end
    end)
end)

----------------------------------------------------------------
-- KILL AURA
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not isActive("KillAura", "killAura") then return end
    local _, mHrp = getChar(LP); if not mHrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not (State.aimbotTeamCheck and teamCheck(plr)) then
            local _, hrp, hum = getChar(plr)
            if hrp and hum and hum.Health > 0 then
                if (mHrp.Position - hrp.Position).Magnitude <= State.killAuraRange then
                    pcall(function()
                        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end)
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- HITBOX EXPANDER
----------------------------------------------------------------
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.2)
        if State.hitboxExpand then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP then
                    local _, hrp = getChar(plr)
                    if hrp then
                        pcall(function()
                            hrp.Size = Vector3.new(State.hitboxSize, State.hitboxSize, State.hitboxSize)
                            hrp.Transparency = 0.7
                            hrp.CanCollide = false
                        end)
                    end
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- AUTO-RESPAWN
----------------------------------------------------------------
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if State.autoRespawn then
            local _, _, hum = getChar(LP)
            if hum and hum.Health <= 0 then
                pcall(function() LP:LoadCharacter() end)
            end
        end
    end
end)

----------------------------------------------------------------
-- THIRD PERSON / ZOOM
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if State.thirdPerson then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMinZoomDistance = 5
        LP.CameraMaxZoomDistance = math.max(15, State.zoomOutMaxValue)
    end
    if State.zoomOutMax then
        LP.CameraMaxZoomDistance = State.zoomOutMaxValue
    end
end)

----------------------------------------------------------------
-- ESP LOOP
----------------------------------------------------------------
RunService.RenderStepped:Connect(updateESP)

----------------------------------------------------------------
-- HUD UPDATE
----------------------------------------------------------------
local frames, lastT, fps = 0, tick(), 60
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastT >= 1 then fps = frames; frames = 0; lastT = tick() end
    if HUD.Visible then
        local ping = math.floor(LP:GetNetworkPing() * 1000)
        local parts = { "AlexWare v12" }
        if State.showFPS then table.insert(parts, fps .. "fps") end
        if State.showPing then table.insert(parts, ping .. "ms") end
        table.insert(parts, "[" .. CurrentProfile.name .. "]")
        HUDText.Text = table.concat(parts, " · ")
    end
end)

----------------------------------------------------------------
-- KILL/HIT TRACKING
----------------------------------------------------------------
local function hookPlayer(plr)
    plr.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end
        local lastHP = hum.Health
        hum.HealthChanged:Connect(function(hp)
            local diff = lastHP - hp
            lastHP = hp
            if diff > 5 and hp > 0 then
                if State.aimbotTarget == plr then
                    notify("Hit", plr.Name .. " · -" .. math.floor(diff) .. " HP", "hit")
                end
            end
        end)
        hum.Died:Connect(function()
            if State.aimbotTarget == plr or (Mouse.Target and Mouse.Target:IsDescendantOf(char)) then
                notify("Kill", "Killed " .. plr.Name, "kill")
            end
        end)
    end)
end
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then hookPlayer(plr) end
end
Players.PlayerAdded:Connect(hookPlayer)

----------------------------------------------------------------
-- UNINJECT
----------------------------------------------------------------
_G.AlexWareUninject = function()
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do clearESP(plr) end
        clearFly()
        if FOVCircle and FOVCircle.Remove then pcall(function() FOVCircle:Remove() end) end
        ScreenGui:Destroy()
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Camera.FieldOfView = 70
    end)
    _G.AlexWareLoaded = nil
    _G.AlexWareUninject = nil
end
