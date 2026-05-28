--[[
    HAI DWNG - ARSENAL ULTIMATE (FIXED: silent aim, magic bullet, auto say, + one-tap)
    Dành cho Delta / Arceus X / Hydrogen
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInput = game:GetService("VirtualInput")

-- CẤU HÌNH
local SETTINGS = {
    ESP = false, ESP_Name = true, ESP_Box = true, ESP_Line = false,
    ESP_Distance = false, ESP_Health = true,
    SilentAim = false, MagicBullet = false, AimLock = false,
    AutoTap = false, AutoKnife = false, KillAll = false, AutoFarm = false,
    HitboxExpand = false, Noclip = false,
    NoRecoil = false, NoSpread = false, FastReload = false,
    Speed = false, Fly = false,
    TeamCheck = true, ShowFOV = false,
    AimPart = "Head", FOV = 450,
    Spin = false, AutoSay = false, InfAmmo = false,
    OneTapKill = false   -- Thêm one-tap kill all (chạm màn hình là giết hết)
}
local MIN_FOV, MAX_FOV = 30, 450
local MAX_DISTANCE = 500
local knifeRange = 20
local hitboxExpandValue = 18
local THEME_COLOR = Color3.fromRGB(255, 80, 120)
local BG_COLOR = Color3.fromRGB(15, 15, 25)
local ACCENT_COLOR = Color3.fromRGB(0, 255, 200)

-- Vòng FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = SETTINGS.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = ACCENT_COLOR
FOVCircle.Transparency = 0.6

local spinSpeed = 360
local lastSpinTime = tick()

-- Logo
local Logo = Instance.new("TextButton")
Logo.Name = "HaiDwnG_Logo"
Logo.Parent = CoreGui
Logo.Size = UDim2.new(0, 35, 0, 35)
Logo.Position = UDim2.new(0, 10, 0, 10)
Logo.BackgroundColor3 = THEME_COLOR
Logo.BackgroundTransparency = 0.3
Logo.Text = "🌀"
Logo.TextColor3 = Color3.new(1,1,1)
Logo.TextSize = 20
Logo.Font = Enum.Font.GothamBold
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
local strokeLogo = Instance.new("UIStroke", Logo)
strokeLogo.Color = ACCENT_COLOR
strokeLogo.Thickness = 1.5
Logo.Parent = CoreGui

local logoDragging = false
local logoDragStart, logoStartPos
Logo.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        logoDragging = true
        logoDragStart = i.Position
        logoStartPos = Logo.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then logoDragging = false end end)
    end
end)
UserInputService.TouchMoved:Connect(function(pos)
    if logoDragging then
        local delta = pos - logoDragStart
        Logo.Position = UDim2.new(logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X, logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y)
    end
end)

-- GUI menu
local gui = Instance.new("ScreenGui")
gui.Name = "HaiDwnG"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 450)
main.Position = UDim2.new(0.5, -130, 0.4, -225)
main.BackgroundColor3 = BG_COLOR
main.BackgroundTransparency = 0.15
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local strokeMain = Instance.new("UIStroke", main)
strokeMain.Color = THEME_COLOR
strokeMain.Thickness = 2
main.Parent = gui

local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, 36)
title.Text = "🌀 HAI DWNG | FIXED 🌀"
title.TextColor3 = ACCENT_COLOR
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = main

local collapse = Instance.new("TextButton")
collapse.Size = UDim2.new(0, 26, 0, 26)
collapse.Position = UDim2.new(1, -30, 0, 5)
collapse.BackgroundColor3 = Color3.fromRGB(30,30,40)
collapse.Text = "−"
collapse.TextColor3 = ACCENT_COLOR
collapse.TextSize = 16
Instance.new("UICorner", collapse).CornerRadius = UDim.new(1, 0)
collapse.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -46)
scroll.Position = UDim2.new(0, 6, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = THEME_COLOR
scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
scroll.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 1000)
content.BackgroundTransparency = 1
content.Parent = scroll

local function addToggle(text, y, callback, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = default and THEME_COLOR or Color3.fromRGB(35,35,45)
    btn.Text = text .. (default and " ✅" or " ❌")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Parent = content
    local active = default
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and THEME_COLOR or Color3.fromRGB(35,35,45)
        btn.Text = text .. (active and " ✅" or " ❌")
        callback(active)
    end)
end

local y = 4
addToggle("👁️ ESP", y, function(v) SETTINGS.ESP = v end); y=y+30
addToggle("  🏷️ Tên", y, function(v) SETTINGS.ESP_Name = v end, true); y=y+30
addToggle("  📦 Box", y, function(v) SETTINGS.ESP_Box = v end, true); y=y+30
addToggle("  📏 KC", y, function(v) SETTINGS.ESP_Distance = v end); y=y+30
addToggle("  ❤️ Máu", y, function(v) SETTINGS.ESP_Health = v end, true); y=y+30
addToggle("  〰️ Line", y, function(v) SETTINGS.ESP_Line = v end); y=y+30
addToggle("🎯 Aim: Head/Body", y, function(v) SETTINGS.AimPart = v and "Head" or "Body" end, true); y=y+30
addToggle("🔮 Silent Aim (visible)", y, function(v) SETTINGS.SilentAim = v end); y=y+30
addToggle("✨ Magic Bullet (xuyên)", y, function(v) SETTINGS.MagicBullet = v end); y=y+30
addToggle("🎯 Aimbot (visible)", y, function(v) SETTINGS.AimLock = v end); y=y+30
addToggle("⚡ Auto Tap", y, function(v) SETTINGS.AutoTap = v end); y=y+30
addToggle("🔪 Auto Knife", y, function(v) SETTINGS.AutoKnife = v end); y=y+30
addToggle("💀 Kill All", y, function(v) SETTINGS.KillAll = v end); y=y+30
addToggle("⚙️ Auto Farm", y, function(v) SETTINGS.AutoFarm = v end); y=y+30
addToggle("🌀 Spin 360°", y, function(v) SETTINGS.Spin = v end); y=y+30
addToggle("💬 Auto Say", y, function(v) SETTINGS.AutoSay = v end); y=y+30
addToggle("♾️ Infinite Ammo", y, function(v) SETTINGS.InfAmmo = v end); y=y+30
addToggle("📦 Hitbox Expand", y, function(v) SETTINGS.HitboxExpand = v end); y=y+30
addToggle("🌀 Noclip", y, function(v) SETTINGS.Noclip = v end); y=y+30
addToggle("🚫 Team Check", y, function(v) SETTINGS.TeamCheck = v end, true); y=y+30
addToggle("💥 No Recoil", y, function(v) SETTINGS.NoRecoil = v end); y=y+30
addToggle("🎯 No Spread", y, function(v) SETTINGS.NoSpread = v end); y=y+30
addToggle("⚡ Fast Reload", y, function(v) SETTINGS.FastReload = v end); y=y+30
addToggle("🏃 Speed/Jump", y, function(v) SETTINGS.Speed = v end); y=y+30
addToggle("🦅 Fly", y, function(v) SETTINGS.Fly = v end); y=y+30
addToggle("🌀 Vòng FOV", y, function(v) SETTINGS.ShowFOV = v end); y=y+30
addToggle("🔫 ONE-TAP KILL (chạm màn)", y, function(v) SETTINGS.OneTapKill = v end); y=y+35

-- Slider FOV
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -12, 0, 20)
fovLabel.Position = UDim2.new(0, 6, 0, y)
fovLabel.Text = "🎯 FOV: " .. SETTINGS.FOV
fovLabel.TextColor3 = ACCENT_COLOR
fovLabel.BackgroundTransparency = 1
fovLabel.TextSize = 10
fovLabel.Font = Enum.Font.GothamBold
fovLabel.Parent = content
y = y + 20

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -12, 0, 5)
sliderBg.Position = UDim2.new(0, 6, 0, y)
sliderBg.BackgroundColor3 = Color3.fromRGB(50,50,60)
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)
sliderBg.Parent = content

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((SETTINGS.FOV - MIN_FOV) / (MAX_FOV - MIN_FOV), 0, 1, 0)
sliderFill.BackgroundColor3 = THEME_COLOR
sliderFill.Parent = sliderBg

local sliderBall = Instance.new("TextButton")
sliderBall.Size = UDim2.new(0, 14, 0, 14)
sliderBall.Position = UDim2.new(1, -7, 0.5, -7)
sliderBall.BackgroundColor3 = ACCENT_COLOR
Instance.new("UICorner", sliderBall).CornerRadius = UDim.new(1,0)
sliderBall.Text = ""
sliderBall.Parent = sliderFill

local function updateFOV(val)
    SETTINGS.FOV = math.clamp(val, MIN_FOV, MAX_FOV)
    fovLabel.Text = "🎯 FOV: " .. math.floor(SETTINGS.FOV)
    sliderFill.Size = UDim2.new((SETTINGS.FOV - MIN_FOV) / (MAX_FOV - MIN_FOV), 0, 1, 0)
    FOVCircle.Radius = SETTINGS.FOV
end

local draggingFOV = false
sliderBall.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then draggingFOV = true end end)
UserInputService.TouchMoved:Connect(function(pos)
    if draggingFOV then
        local rel = (pos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
        updateFOV(MIN_FOV + math.clamp(rel,0,1) * (MAX_FOV - MIN_FOV))
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then draggingFOV = false end end)
sliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        local rel = (i.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
        updateFOV(MIN_FOV + math.clamp(rel,0,1) * (MAX_FOV - MIN_FOV))
    end
end)
y = y + 24

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -12, 0, 20)
credit.Position = UDim2.new(0, 6, 0, y)
credit.Text = "🌀 @haidwng12 | Delta Ready | One-tap: chạm màn 🌀"
credit.TextColor3 = THEME_COLOR
credit.BackgroundTransparency = 1
credit.TextSize = 9
credit.Font = Enum.Font.GothamBold
credit.Parent = content
scroll.CanvasSize = UDim2.new(0, 0, 0, y + 30)

-- Kéo thả menu
local dragStart, startPos, draggingMenu = nil, nil, false
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true
        dragStart = i.Position
        startPos = main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then draggingMenu = false end end)
    end
end)
UserInputService.TouchMoved:Connect(function(pos)
    if draggingMenu then
        local delta = pos - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local collapsed = false
collapse.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    collapse.Text = collapsed and "+" or "−"
    main:TweenSize(collapsed and UDim2.new(0, 260, 0, 36) or UDim2.new(0, 260, 0, 450), "Out", "Quad", 0.2, true)
    scroll.Visible = not collapsed
end)

Logo.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    Logo.BackgroundTransparency = main.Visible and 0.3 or 0.7
end)

-- ========== LOGIC CHÍNH ==========
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
    local nearest, bestDist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            local part = getTargetPart(p)
            if part then
                local d = (part.Position - camPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function getVisibleTargetInFOV()
    local center = Camera.ViewportSize / 2
    local bestTarget, bestAngle = nil, SETTINGS.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            local part = getTargetPart(p)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local angle = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if angle < bestAngle and isVisible(part) then
                        bestAngle = angle
                        bestTarget = p
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Hook FireServer (silent aim + magic bullet FIX)
local hooked = false
local function hookSilentMagic()
    if hooked then return end
    local mt = getrawmetatable(game)
    if not mt then return end
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and (SETTINGS.SilentAim or SETTINGS.MagicBullet) then
            local target = nil
            if SETTINGS.MagicBullet then
                target = getAnyEnemy()
            elseif SETTINGS.SilentAim then
                target = getVisibleTargetInFOV()
            end
            local part = target and getTargetPart(target)
            if part then
                local args = {...}
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = part.Position
                        break
                    end
                end
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
    hooked = true
end
task.spawn(function() while true do if (SETTINGS.SilentAim or SETTINGS.MagicBullet) and not hooked then hookSilentMagic() end task.wait(2) end end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if SETTINGS.AimLock then
        local target = getVisibleTargetInFOV()
        local part = target and getTargetPart(target)
        if part then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end
end)

-- Auto Tap & Super Fast Shoot (không có super fast nhưng giữ tap shoot)
local lastTap = 0
local function tapShoot()
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
        local hasTarget = false
        if SETTINGS.MagicBullet then
            hasTarget = getAnyEnemy() ~= nil
        elseif SETTINGS.SilentAim then
            hasTarget = getVisibleTargetInFOV() ~= nil
        else
            hasTarget = getAnyEnemy() ~= nil
        end
        if hasTarget and tick() - lastTap > 0.01 then
            tapShoot()
            lastTap = tick()
        end
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
                tapShoot()
                lastKnife = tick()
            end
        end
    end
end)

-- Tele & Kill (cho KillAll và AutoFarm)
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
    for _ = 1, 3 do
        tapShoot()
        task.wait(0.005)
    end
end

-- ONE-TAP KILL ALL (chạm màn hình nếu bật)
local function killAllEnemies()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                teleAndKill(p)
                task.wait(0.05)
            end
        end
    end
end

UserInputService.TouchStarted:Connect(function(input)
    if SETTINGS.OneTapKill then
        killAllEnemies()
    end
end)

-- Auto KillAll & Auto Farm (chạy nếu bật)
task.spawn(function()
    while true do
        if SETTINGS.KillAll then
            local target = getAnyEnemy()
            if target then teleAndKill(target) end
            task.wait(0.05)
        end
        if SETTINGS.AutoFarm then
            local target = getAnyEnemy()
            if target then teleAndKill(target) end
            task.wait(0.03)
        end
        task.wait(0.02)
    end
end)

-- Hitbox Expander
local expanded = {}
RunService.RenderStepped:Connect(function()
    if not SETTINGS.HitboxExpand then
        for part, oldSize in pairs(expanded) do
            pcall(function() part.Size = oldSize end)
        end
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

-- Spin
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

-- AUTO SAY FIX (quét remote chat)
local function sendChat(msg)
    pcall(function()
        local chatService = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatService then
            local sayRequest = chatService:FindFirstChild("SayMessageRequest")
            if sayRequest then sayRequest:FireServer(msg, "All") return end
        end
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():match("say") or v.Name:lower():match("chat") or v.Name:lower():match("message")) then
                v:FireServer(msg, "All")
                return
            end
        end
    end)
end

local lastSay = 0
local function onEnemyDied()
    if SETTINGS.AutoSay and tick() - lastSay > 1 then
        sendChat("@haidwng12 telegram script")
        lastSay = tick()
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid").Died:Connect(onEnemyDied)
        end)
        if p.Character then
            p.Character:WaitForChild("Humanoid").Died:Connect(onEnemyDied)
        end
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(onEnemyDied)
    end)
end)

-- Infinite Ammo
RunService.RenderStepped:Connect(function()
    if not SETTINGS.InfAmmo then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") and (v.Name:lower():match("ammo") or v.Name:lower():match("bullet")) then
                v.Value = 999
            end
        end
    end
end)

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
        if flying and bv and bg and LocalPlayer.Character then
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
    local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false; box.Color = THEME_COLOR
    local line = Drawing.new("Line"); line.Thickness = 1; line.Color = ACCENT_COLOR
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

print("✅ Script hoàn chỉnh đã chạy. Bật ONE-TAP KILL (chạm màn) để giết all bằng tele. Silent aim, magic bullet đã fix.")
