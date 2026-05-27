--[[
    HAI DWNG - ARSENAL ULTIMATE (FIX CHỮ ĐÈ, FULL CHỨC NĂNG)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInput = game:GetService("VirtualInput")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CẤU HÌNH
local SETTINGS = {
    ESP = false, ESP_Name = true, ESP_Box = true, ESP_Line = false,
    ESP_Distance = false, ESP_Health = true,
    SilentAim = false, MagicBullet = false, AimLock = false,
    AutoTap = false, AutoKnife = false, KillAll = false, AutoFarm = false,
    Spin = false, AutoSay = false, InfAmmo = false,
    HitboxExpand = false, Noclip = false,
    NoRecoil = false, NoSpread = false, FastReload = false,
    Speed = false, Fly = false,
    TeamCheck = true, ShowFOV = false,
    AimPart = "Head", FOV = 450
}
local MIN_FOV, MAX_FOV = 30, 450
local MAX_DISTANCE = 500
local knifeRange = 20
local hitboxExpandValue = 18
local spinSpeed = 360
local lastSpinTime = tick()
local lastSayTime = 0

-- Màu
local THEME = Color3.fromRGB(255, 80, 120)
local BG = Color3.fromRGB(15, 15, 25)
local ACCENT = Color3.fromRGB(0, 255, 200)

-- Vòng FOV (Drawing)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = SETTINGS.FOV
FOVCircle.Visible = false
FOVCircle.Color = ACCENT
FOVCircle.Transparency = 0.6

-- ========== TẠO GUI VỚI UIListLayout ==========
local gui = Instance.new("ScreenGui")
gui.Name = "HaiDwnG_Ultimate"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 340, 0, 520)
menu.Position = UDim2.new(0.5, -170, 0.5, -260)
menu.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
menu.BackgroundTransparency = 0.35
menu.BorderSizePixel = 0
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 28)
local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = THEME
menuStroke.Thickness = 1.5
menu.Parent = gui

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
header.BackgroundTransparency = 0.9
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 28)
header.Parent = menu

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.Text = "🌀 HAI DWNG | ULTIMATE"
title.TextColor3 = THEME
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = header

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -40, 0, 9)
collapseBtn.Text = "−"
collapseBtn.TextColor3 = ACCENT
collapseBtn.TextSize = 20
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 60)
Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(1, 0)
collapseBtn.Parent = header

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -68)
scroll.Position = UDim2.new(0, 10, 0, 56)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = THEME
scroll.Parent = menu

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.BackgroundTransparency = 1
content.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

-- Hàm tạo section
local function createSection(titleText)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    section.BackgroundTransparency = 0.6
    section.BorderSizePixel = 0
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 20)
    section.Parent = content

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Color3.fromRGB(255, 176, 192)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = section

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.Padding = UDim.new(0, 8)
    innerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Parent = section

    return section, innerLayout
end

-- Toggle
local function addToggle(section, label, emoji, callback, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = section

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Text = emoji .. " " .. label
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -60, 0, 3)
    btn.BackgroundColor3 = default and THEME or Color3.fromRGB(58, 58, 78)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.Parent = frame

    local active = default
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and THEME or Color3.fromRGB(58, 58, 78)
        btn.Text = active and "ON" or "OFF"
        callback(active)
    end)
end

-- Slider
local function addSlider(section, label, minVal, maxVal, getVal, setVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = section

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Text = label .. ": " .. tostring(getVal())
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextSize = 11
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 4)
    slider.Position = UDim2.new(0, 0, 0, 24)
    slider.BackgroundColor3 = Color3.fromRGB(58, 58, 78)
    Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getVal() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = THEME
    fill.Parent = slider

    local ball = Instance.new("TextButton")
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = UDim2.new(1, -7, 0.5, -7)
    ball.BackgroundColor3 = ACCENT
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)
    ball.Text = ""
    ball.Parent = fill

    local dragging = false
    local function update(pos)
        local rel = (pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
        local newVal = minVal + math.clamp(rel, 0, 1) * (maxVal - minVal)
        setVal(newVal)
        fill.Size = UDim2.new((newVal - minVal) / (maxVal - minVal), 0, 1, 0)
        lbl.Text = label .. ": " .. math.floor(newVal)
    end
    ball.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position)
        end
    end)
    UserInputService.TouchMoved:Connect(function(pos)
        if dragging then update(pos) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    slider.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then update(i.Position) end
    end)
end

-- Tạo các section (đã rút gọn để tránh quá dài, nhưng đủ)
local espSec, _ = createSection("👁️ ESP VISUALS")
addToggle(espSec, "Master ESP", "🔘", function(v) SETTINGS.ESP = v end, false)
addToggle(espSec, "Name", "🏷️", function(v) SETTINGS.ESP_Name = v end, true)
addToggle(espSec, "Box", "📦", function(v) SETTINGS.ESP_Box = v end, true)
addToggle(espSec, "Health", "❤️", function(v) SETTINGS.ESP_Health = v end, true)
addToggle(espSec, "Line dọc", "〰️", function(v) SETTINGS.ESP_Line = v end, false)

local aimSec, _ = createSection("🎯 AIMBOT / SILENT")
addToggle(aimSec, "Silent Aim (visible)", "🔮", function(v) SETTINGS.SilentAim = v end, false)
addToggle(aimSec, "Magic Bullet", "✨", function(v) SETTINGS.MagicBullet = v end, false)
addToggle(aimSec, "Aimbot (lock)", "🎯", function(v) SETTINGS.AimLock = v end, false)
addToggle(aimSec, "Auto Tap", "⚡", function(v) SETTINGS.AutoTap = v end, false)
addToggle(aimSec, "Auto Knife", "🔪", function(v) SETTINGS.AutoKnife = v end, false)

local farmSec, _ = createSection("⚙️ AUTO FARM / KILL")
addToggle(farmSec, "Kill All (once)", "💀", function(v) SETTINGS.KillAll = v end, false)
addToggle(farmSec, "Auto Farm (treo máy)", "⚙️", function(v) SETTINGS.AutoFarm = v end, false)
addToggle(farmSec, "Spin 360°", "🌀", function(v) SETTINGS.Spin = v end, false)
addToggle(farmSec, "Auto Say (@haidwng12)", "💬", function(v) SETTINGS.AutoSay = v end, false)
addToggle(farmSec, "Infinite Ammo", "♾️", function(v) SETTINGS.InfAmmo = v end, false)

local moveSec, _ = createSection("🦅 MOVEMENT & OTHER")
addToggle(moveSec, "Speed/Jump", "🏃", function(v) SETTINGS.Speed = v end, false)
addToggle(moveSec, "Fly", "🦅", function(v) SETTINGS.Fly = v end, false)
addToggle(moveSec, "Noclip", "🌀", function(v) SETTINGS.Noclip = v end, false)
addToggle(moveSec, "Hitbox Expand", "📦", function(v) SETTINGS.HitboxExpand = v end, false)
addToggle(moveSec, "Team Check", "🚫", function(v) SETTINGS.TeamCheck = v end, true)

local fovSec, _ = createSection("🎯 FOV SETTINGS")
addSlider(fovSec, "FOV Radius", MIN_FOV, MAX_FOV, function() return SETTINGS.FOV end, function(v) SETTINGS.FOV = v; FOVCircle.Radius = v end)
addToggle(fovSec, "Show FOV Circle", "🌀", function(v) SETTINGS.ShowFOV = v end, false)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 30)
credit.Text = "🔥 @haidwng12 | TELEGRAM SCRIPT 🔥"
credit.TextColor3 = THEME
credit.BackgroundTransparency = 1
credit.TextSize = 11
credit.Font = Enum.Font.GothamBold
credit.Parent = content

-- Cập nhật kích thước content
local function updateCanvas()
    task.wait(0.1)
    local totalHeight = 0
    for _, child in pairs(content:GetChildren()) do
        if child:IsA("Frame") and child ~= layout then
            totalHeight = totalHeight + child.AbsoluteSize.Y + 12
        end
    end
    credit.Position = UDim2.new(0, 10, 0, totalHeight)
    content.Size = UDim2.new(1, 0, 0, totalHeight + 40)
    scroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 50)
end
task.spawn(updateCanvas)

-- Kéo thả menu
local dragStart, startPos, dragMenu = nil, nil, false
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        dragMenu = true
        dragStart = i.Position
        startPos = menu.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragMenu = false end end)
    end
end)
UserInputService.TouchMoved:Connect(function(pos)
    if dragMenu then
        local delta = pos - dragStart
        menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Thu gọn
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    collapseBtn.Text = collapsed and "+" or "−"
    menu:TweenSize(collapsed and UDim2.new(0, 340, 0, 60) or UDim2.new(0, 340, 0, 520), "Out", "Quad", 0.2, true)
    scroll.Visible = not collapsed
end)

-- ========== LOGIC GAME (giữ nguyên từ bản trước) ==========
local function isEnemy(p)
    if not SETTINGS.TeamCheck then return true end
    return p.Team ~= LocalPlayer.Team
end

local function isVisible(part)
    if not part then return false end
    local ray = RaycastParams.new()
    ray.FilterDescendantsInstances = {LocalPlayer.Character}
    ray.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), ray)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function getTargetPart(target)
    if not target or not target.Character then return nil end
    if SETTINGS.AimPart == "Head" then
        return target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart")
    else
        return target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Head")
    end
end

local function getAnyEnemy()
    local nearest, best = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            local part = getTargetPart(p)
            if part then
                local d = (part.Position - camPos).Magnitude
                if d < best then
                    best = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function getVisibleTargetInFOV()
    local center = Camera.ViewportSize / 2
    local best, bestAng = nil, SETTINGS.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            local part = getTargetPart(p)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local ang = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if ang < bestAng and isVisible(part) then
                        bestAng = ang
                        best = p
                    end
                end
            end
        end
    end
    return best
end

local function getTargetPos()
    if SETTINGS.MagicBullet then
        local t = getAnyEnemy()
        local p = t and getTargetPart(t)
        return p and p.Position
    elseif SETTINGS.SilentAim then
        local t = getVisibleTargetInFOV()
        local p = t and getTargetPart(t)
        if p and isVisible(p) then return p.Position end
    end
    return nil
end

-- Hook FireServer
if not getgenv().ArsenalHook then
    local old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and (SETTINGS.SilentAim or SETTINGS.MagicBullet) then
            local pos = getTargetPos()
            if pos then
                local args = {...}
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = pos
                        break
                    end
                end
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end))
    getgenv().ArsenalHook = true
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if SETTINGS.AimLock then
        local t = getVisibleTargetInFOV()
        local p = t and getTargetPart(t)
        if p then Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Position) end
    end
end)

-- Auto Tap + shoot
local lastTap = 0
local function shoot()
    pcall(function()
        if VirtualInput then
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.005)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        else
            UserInputService:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.005)
            UserInputService:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if SETTINGS.AutoTap then
        local has = false
        if SETTINGS.MagicBullet then has = getAnyEnemy() ~= nil
        elseif SETTINGS.SilentAim then has = getVisibleTargetInFOV() ~= nil
        else has = getAnyEnemy() ~= nil end
        if has and tick() - lastTap > 0.01 then shoot(); lastTap = tick() end
    end
end)

-- Auto Knife
local lastKnife = 0
RunService.RenderStepped:Connect(function()
    if not SETTINGS.AutoKnife then return end
    if tick() - lastKnife < 0.5 then return end
    local nearest = getAnyEnemy()
    if nearest and nearest.Character then
        local tHrp = nearest.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tHrp and myHrp and (tHrp.Position - myHrp.Position).Magnitude < knifeRange then
            local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
            if knife and knife:IsA("Tool") then
                LocalPlayer.Character.Humanoid:EquipTool(knife)
                task.wait(0.05)
                shoot()
                lastKnife = tick()
            end
        end
    end
end)

-- Tele + kill (nhìn xuống)
local function teleAndKill(target)
    if not target or not target.Character then return end
    local aimPart = getTargetPart(target)
    if not aimPart then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local telePos = aimPart.Position + Vector3.new(0, 2.5, 0)
    myHrp.CFrame = CFrame.new(telePos, aimPart.Position)
    Camera.CFrame = CFrame.new(telePos, aimPart.Position)
    task.wait(0.02)
    for _ = 1, 3 do shoot(); task.wait(0.005) end
end

task.spawn(function()
    while true do
        if SETTINGS.KillAll then
            local t = getAnyEnemy()
            if t then teleAndKill(t) end
            task.wait(0.05)
        end
        if SETTINGS.AutoFarm then
            local t = getAnyEnemy()
            if t then teleAndKill(t) end
            task.wait(0.03)
        end
        task.wait(0.02)
    end
end)

-- Hitbox Expander
local expanded = {}
RunService.RenderStepped:Connect(function()
    if not SETTINGS.HitboxExpand then
        for part, old in pairs(expanded) do pcall(function() part.Size = old end) end
        expanded = {}
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            for _, part in pairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") and not expanded[part] then
                    expanded[part] = part.Size
                    part.Size = part.Size + Vector3.new(hitboxExpandValue, hitboxExpandValue, hitboxExpandValue)
                end
            end
        end
    end
end)

-- Noclip
RunService.RenderStepped:Connect(function()
    if SETTINGS.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    elseif LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
        end
    end
end)

-- Weapon Mods
local function applyMods()
    if not (SETTINGS.NoRecoil or SETTINGS.NoSpread or SETTINGS.FastReload) then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") then
                local n = v.Name:lower()
                if SETTINGS.NoRecoil and (n:match("recoil") or n:match("kick")) then v.Value = 0 end
                if SETTINGS.NoSpread and (n:match("spread") or n:match("accuracy")) then v.Value = 0 end
                if SETTINGS.FastReload and (n:match("reload") or n:match("cooldown")) then v.Value = 0 end
            end
        end
        if SETTINGS.FastReload then
            pcall(function() local ev = tool:FindFirstChild("ReloadEvent") or tool:FindFirstChild("Reload"); if ev and ev:IsA("RemoteEvent") then ev:FireServer() end end)
        end
    end
end
RunService.RenderStepped:Connect(applyMods)

-- Speed & Fly
local flying = false
local bv, bg
RunService.RenderStepped:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if SETTINGS.Speed then
            hum.WalkSpeed = 50
            hum.JumpPower = 80
        else
            if hum.WalkSpeed == 50 then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        end
    end
    if SETTINGS.Fly then
        if not flying then
            flying = true
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Parent = hrp
                bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e6,1e6,1e6); bg.Parent = hrp
                if hum then hum.PlatformStand = true end
            end
        end
        if flying and bv and bg then
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,20,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,20,0) end
            bv.Velocity = move * 50
            bg.CFrame = Camera.CFrame
        end
    else
        if flying then
            if bv then bv:Destroy() end; if bg then bg:Destroy() end
            local hum2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum2 then hum2.PlatformStand = false end
            flying = false
        end
    end
end)

-- Spin 360
RunService.RenderStepped:Connect(function(dt)
    if SETTINGS.Spin and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local now = tick()
            local delta = math.min(now - lastSpinTime, 0.1)
            lastSpinTime = now
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed * delta), 0)
        end
    else
        lastSpinTime = tick()
    end
end)

-- Auto Say
local function sendChat(msg)
    pcall(function()
        local sayRequest = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest")
        if sayRequest then sayRequest:FireServer(msg, "All") end
    end)
end
local function onEnemyDied()
    if SETTINGS.AutoSay and tick() - lastSayTime > 1 then
        sendChat("@haidwng12 telegram script")
        lastSayTime = tick()
    end
end
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char) char:WaitForChild("Humanoid").Died:Connect(onEnemyDied) end)
        if p.Character then p.Character:WaitForChild("Humanoid").Died:Connect(onEnemyDied) end
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char) char:WaitForChild("Humanoid").Died:Connect(onEnemyDied) end)
end)

-- Infinite Ammo
local function infiniteAmmo()
    if not SETTINGS.InfAmmo then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") and (v.Name:lower():match("ammo") or v.Name:lower():match("bullet")) then
                v.Value = 999
            end
        end
    end
end
RunService.RenderStepped:Connect(infiniteAmmo)

-- FOV Circle
RunService.RenderStepped:Connect(function()
    if SETTINGS.ShowFOV and Camera then
        local center = Camera.ViewportSize / 2
        FOVCircle.Position = Vector2.new(center.X, center.Y)
        FOVCircle.Radius = SETTINGS.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- ESP (Drawing)
local function safeRemove(d) if d and d.Remove then pcall(d.Remove, d) end end
local espData = {}
local function AddESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false; box.Color = THEME
    local line = Drawing.new("Line"); line.Thickness = 1; line.Color = ACCENT
    local name = Drawing.new("Text"); name.Size = 8; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)
    local hbg = Drawing.new("Square"); hbg.Thickness = 1; hbg.Filled = true; hbg.Color = Color3.new(0,0,0); hbg.Transparency = 0.5
    local hfill = Drawing.new("Square"); hfill.Thickness = 0; hfill.Filled = true
    local conn = RunService.RenderStepped:Connect(function()
        if not isEnemy(plr) or not SETTINGS.ESP then
            box.Visible = false; line.Visible = false; name.Visible = false; hbg.Visible = false; hfill.Visible = false
            return
        end
        if not plr.Parent then
            if espData[plr] then for _, d in pairs(espData[plr]) do safeRemove(d) end espData[plr]=nil end
            return
        end
        local char, hum, hrp = plr.Character, plr.Character and plr.Character:FindFirstChildOfClass("Humanoid"), plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not char or not hum or hum.Health<=0 then
            box.Visible=false; line.Visible=false; name.Visible=false; hbg.Visible=false; hfill.Visible=false
            return
        end
        local pos, on = Camera:WorldToViewportPoint(hrp.Position)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if on and dist <= MAX_DISTANCE then
            local h = math.clamp(2800/dist, 20, 180)
            local w = math.clamp(1800/dist, 20, 100)
            local topY = pos.Y - h/2
            local leftX = pos.X - w/2
            if SETTINGS.ESP_Box then
                box.Size = Vector2.new(w, h); box.Position = Vector2.new(leftX, topY); box.Visible = true
            else box.Visible = false end
            if SETTINGS.ESP_Line then
                line.From = Vector2.new(pos.X, topY); line.To = Vector2.new(pos.X, topY+h); line.Visible = true
            else line.Visible = false end
            if SETTINGS.ESP_Name then
                local txt = plr.Name .. (SETTINGS.ESP_Distance and (" ["..math.floor(dist).."m]" or ""))
                name.Text = txt; name.Position = Vector2.new(pos.X, topY-8); name.Visible = true
            else name.Visible = false end
            if SETTINGS.ESP_Health then
                local ratio = hum.Health/hum.MaxHealth
                local bw = 2; local bh = h
                local bx = leftX - bw - 2; local by = topY
                hbg.Size = Vector2.new(bw, bh); hbg.Position = Vector2.new(bx, by); hbg.Visible = true
                hfill.Size = Vector2.new(bw, bh*ratio); hfill.Position = Vector2.new(bx, by+bh-(bh*ratio)); hfill.Color = Color3.fromHSV(ratio*0.33,1,1); hfill.Visible = true
            else hbg.Visible=false; hfill.Visible=false end
        else
            box.Visible=false; line.Visible=false; name.Visible=false; hbg.Visible=false; hfill.Visible=false
        end
    end)
    espData[plr] = {box, line, name, hbg, hfill, conn}
end
for _, p in pairs(espData) do for _, d in pairs(p) do safeRemove(d) end end
espData = {}
for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(function(p) if espData[p] then for _, d in pairs(espData[p]) do safeRemove(d) end espData[p]=nil end end)

print("✅ Giao diện đã sửa không bị đè chữ. Bật Auto Farm + Team Check để treo máy. Spin, Auto Say, Inf Ammo đã sẵn sàng.")
