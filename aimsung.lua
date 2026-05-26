--[[
    HaiDwnG Hub - Aim Lock 100% (liên tục bám) + FOV 450 Touch
    Chức năng: ESP, Silent Aim, Snap khi bắn, Auto Shoot, No Recoil, No Spread, Fast Reload, Speed, Fly
    Logo bên trái, menu thu nhỏ, FOV slider dùng tay.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInput = game:GetService("VirtualInput")

-- Cấu hình
local SETTINGS = {
    ESP = false, ESP_Name = false, ESP_Box = false, ESP_Line = false,
    ESP_Distance = false, ESP_Health = false,
    SilentAim = false, SnapOnFire = false, AimLock = false,
    AutoShoot = false, ShowFOV = false,
    NoRecoil = false, NoSpread = false, FastReload = false,
    Speed = false, Fly = false
}
local FOV_RADIUS = 200
local MIN_FOV = 50
local MAX_FOV = 450
local AIM_TARGET_PART = "UpperTorso"
local MAX_DISTANCE = 400
local THEME_COLOR = Color3.fromRGB(255, 133, 170)
local BG_COLOR = Color3.fromRGB(255, 245, 250)
local ESP_COLOR = Color3.fromRGB(255, 255, 255)

-- Vòng FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = THEME_COLOR
FOVCircle.Transparency = 0.5

-- Logo bên trái
local Logo = Instance.new("TextButton")
Logo.Name = "HaiDwnG_Logo"
Logo.Parent = CoreGui
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0, 5, 0, 5)
Logo.BackgroundColor3 = THEME_COLOR
Logo.BackgroundTransparency = 0.3
Logo.Text = "🌸"
Logo.TextColor3 = Color3.new(1,1,1)
Logo.TextSize = 24
Logo.Font = Enum.Font.GothamBold
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
local LogoStroke = Instance.new("UIStroke", Logo)
LogoStroke.Color = Color3.fromRGB(255,255,255)
LogoStroke.Thickness = 1

-- Kéo thả logo
local logoDragging = false
local logoDragStart, logoStartPos
Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        logoDragging = true
        logoDragStart = input.Position
        logoStartPos = Logo.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then logoDragging = false end
        end)
    end
end)
local function onLogoMove(input)
    if logoDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - logoDragStart
        Logo.Position = UDim2.new(logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X, logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y)
    end
end
UserInputService.InputChanged:Connect(onLogoMove)
UserInputService.TouchMoved:Connect(onLogoMove)

-- Menu chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HaiDwnGHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
local menuVisible = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -175)
MainFrame.Size = UDim2.new(0, 280, 0, 350)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local strokeMain = Instance.new("UIStroke", MainFrame)
strokeMain.Thickness = 1.5
strokeMain.Color = THEME_COLOR

-- Title chuyển động
local TitleBtn = Instance.new("TextButton", MainFrame)
TitleBtn.BackgroundTransparency = 1
TitleBtn.Size = UDim2.new(1, 0, 0, 35)
TitleBtn.Text = "🌸 HaiDwnG Hub (Lock 100%)"
TitleBtn.TextSize = 12
TitleBtn.Font = Enum.Font.GothamBlack
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    if not MainFrame.Parent then return end
    hue = (hue + dt * 0.5) % 1
    TitleBtn.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
end)

-- Kéo thả menu
local dragging = false
local dragStart, startPos
TitleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
local function onMenuMove(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end
UserInputService.InputChanged:Connect(onMenuMove)
UserInputService.TouchMoved:Connect(onMenuMove)

-- Nút thu gọn
local CollapseBtn = Instance.new("TextButton", MainFrame)
CollapseBtn.Size = UDim2.new(0, 25, 0, 25)
CollapseBtn.Position = UDim2.new(1, -30, 0, 5)
CollapseBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 230)
CollapseBtn.Text = "−"
CollapseBtn.TextColor3 = Color3.fromRGB(255, 100, 130)
CollapseBtn.TextSize = 16
Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(1, 0)

local VersionFrame = Instance.new("Frame", MainFrame)
VersionFrame.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
VersionFrame.Position = UDim2.new(0, 10, 0, 40)
VersionFrame.Size = UDim2.new(1, -20, 0, 18)
Instance.new("UICorner", VersionFrame).CornerRadius = UDim.new(0, 20)
local VersionText = Instance.new("TextLabel", VersionFrame)
VersionText.Text = "✨ Lock 100% | FOV 450 ✨"
VersionText.BackgroundTransparency = 1
VersionText.Size = UDim2.new(1,0,1,0)
VersionText.TextColor3 = Color3.fromRGB(255, 120, 150)
VersionText.TextSize = 9
VersionText.Font = Enum.Font.GothamBold

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 250, 252)
ContentFrame.Position = UDim2.new(0, 8, 0, 62)
ContentFrame.Size = UDim2.new(1, -16, 1, -80)
ContentFrame.ScrollBarThickness = 2
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 580)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 10)

-- Hàm tạo toggle
local function MakeToggle(label, yPos, callback)
    local bg = Instance.new("TextButton", ContentFrame)
    bg.Size = UDim2.new(0, 30, 0, 15)
    bg.Position = UDim2.new(0, 8, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(220, 200, 210)
    bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame", bg)
    dot.Size = UDim2.new(0, 11, 0, 11)
    dot.Position = UDim2.new(0, 2, 0.5, -5.5)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", ContentFrame)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 45, 0, yPos)
    lbl.Size = UDim2.new(0, 210, 0, 15)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(80, 40, 55)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamMedium
    local active = false
    bg.MouseButton1Click:Connect(function()
        active = not active
        bg.BackgroundColor3 = active and THEME_COLOR or Color3.fromRGB(220, 200, 210)
        dot:TweenPosition(active and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5), "Out", "Quad", 0.1, true)
        if callback then callback(active) end
    end)
end

local y = 5
MakeToggle("ESP", y, function(v) SETTINGS.ESP = v end); y=y+20
MakeToggle("Tên", y, function(v) SETTINGS.ESP_Name = v end); y=y+20
MakeToggle("Khung", y, function(v) SETTINGS.ESP_Box = v end); y=y+20
MakeToggle("Khoảng cách", y, function(v) SETTINGS.ESP_Distance = v end); y=y+20
MakeToggle("Máu", y, function(v) SETTINGS.ESP_Health = v end); y=y+20
MakeToggle("Line dọc", y, function(v) SETTINGS.ESP_Line = v end); y=y+20
MakeToggle("Silent Aim", y, function(v) SETTINGS.SilentAim = v end); y=y+20
MakeToggle("Snap khi bắn", y, function(v) SETTINGS.SnapOnFire = v end); y=y+20
MakeToggle("🔒 Aim Lock 100% (bám cứng)", y, function(v) SETTINGS.AimLock = v end); y=y+20
MakeToggle("Auto Shoot (30/s)", y, function(v) SETTINGS.AutoShoot = v end); y=y+20
MakeToggle("Vòng FOV", y, function(v) SETTINGS.ShowFOV = v end); y=y+20
MakeToggle("No Recoil", y, function(v) SETTINGS.NoRecoil = v end); y=y+20
MakeToggle("No Spread", y, function(v) SETTINGS.NoSpread = v end); y=y+20
MakeToggle("Speed/Jump", y, function(v) SETTINGS.Speed = v end); y=y+20
MakeToggle("Fly Mode", y, function(v) SETTINGS.Fly = v end); y=y+25

-- Slider FOV dùng touch
local FOVLabel = Instance.new("TextLabel", ContentFrame)
FOVLabel.Position = UDim2.new(0, 8, 0, y)
FOVLabel.Size = UDim2.new(0, 100, 0, 15)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. FOV_RADIUS
FOVLabel.TextColor3 = THEME_COLOR
FOVLabel.TextSize = 10
FOVLabel.Font = Enum.Font.GothamBold
y = y + 15

local SliderBg = Instance.new("Frame", ContentFrame)
SliderBg.BackgroundColor3 = Color3.fromRGB(220, 200, 210)
SliderBg.Position = UDim2.new(0, 8, 0, y)
SliderBg.Size = UDim2.new(1, -16, 0, 4)
local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.BackgroundColor3 = THEME_COLOR
SliderFill.Size = UDim2.new((FOV_RADIUS - MIN_FOV) / (MAX_FOV - MIN_FOV), 0, 1, 0)
local SliderBall = Instance.new("TextButton", SliderFill)
SliderBall.Size = UDim2.new(0, 12, 0, 12)
SliderBall.Position = UDim2.new(1, -6, 0.5, -6)
SliderBall.Text = ""
SliderBall.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SliderBall).CornerRadius = UDim.new(1, 0)

local function updateFOV(value)
    FOV_RADIUS = math.clamp(value, MIN_FOV, MAX_FOV)
    FOVLabel.Text = "FOV: " .. FOV_RADIUS
    local percent = (FOV_RADIUS - MIN_FOV) / (MAX_FOV - MIN_FOV)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    FOVCircle.Radius = FOV_RADIUS
end

local function setFOVfromPos(inputPos)
    local trackPos = SliderBg.AbsolutePosition
    local trackSize = SliderBg.AbsoluteSize
    local rel = (inputPos.X - trackPos.X) / trackSize.X
    rel = math.clamp(rel, 0, 1)
    local newVal = MIN_FOV + rel * (MAX_FOV - MIN_FOV)
    updateFOV(newVal)
end

local sliderActive = false
SliderBall.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderActive = true
        setFOVfromPos(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setFOVfromPos(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderActive = false
    end
end)
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        setFOVfromPos(input.Position)
    end
end)

y = y + 20

local ContactFrame = Instance.new("Frame", ContentFrame)
ContactFrame.Position = UDim2.new(0, 8, 0, y)
ContactFrame.Size = UDim2.new(1, -16, 0, 28)
ContactFrame.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
Instance.new("UICorner", ContactFrame).CornerRadius = UDim.new(0, 15)
local ContactLabel = Instance.new("TextLabel", ContactFrame)
ContactLabel.Text = "Admin: @haidwng12"
ContactLabel.Size = UDim2.new(1,0,1,0)
ContactLabel.BackgroundTransparency = 1
ContactLabel.TextColor3 = THEME_COLOR
ContactLabel.TextSize = 9
ContactLabel.Font = Enum.Font.GothamBold
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 40)

-- Toggle menu khi click logo
Logo.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
    Logo.BackgroundTransparency = menuVisible and 0.3 or 0.7
end)

-- ======================== ESP ========================
local function safeRemove(d)
    if d and d.Remove then pcall(d.Remove, d) end
end
local espData = {}
local function AddESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false
    local line = Drawing.new("Line"); line.Thickness = 1
    local name = Drawing.new("Text"); name.Size = 10; name.Center = true; name.Outline = true
    local hbg = Drawing.new("Square"); hbg.Thickness = 1; hbg.Filled = true; hbg.Color = Color3.new(0,0,0); hbg.Transparency = 0.5
    local hfill = Drawing.new("Square"); hfill.Thickness = 0; hfill.Filled = true
    local conn = RunService.RenderStepped:Connect(function()
        if not plr.Parent then
            if espData[plr] then
                for _, d in pairs(espData[plr]) do safeRemove(d) end
                espData[plr] = nil
            end
            return
        end
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not SETTINGS.ESP or not char or not hum or hum.Health <= 0 then
            box.Visible = false; line.Visible = false; name.Visible = false; hbg.Visible = false; hfill.Visible = false
            return
        end
        local pos, on = Camera:WorldToViewportPoint(hrp.Position)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if on and dist <= MAX_DISTANCE then
            local h = math.clamp(2800/dist, 20, 280)
            local w = math.clamp(1800/dist, 20, 180)
            local topY = pos.Y - h/2
            local leftX = pos.X - w/2
            if SETTINGS.ESP_Box then
                box.Size = Vector2.new(w, h); box.Position = Vector2.new(leftX, topY); box.Color = ESP_COLOR; box.Visible = true
            else box.Visible = false end
            if SETTINGS.ESP_Line then
                line.From = Vector2.new(pos.X, topY); line.To = Vector2.new(pos.X, topY + h); line.Color = ESP_COLOR; line.Visible = true
            else line.Visible = false end
            if SETTINGS.ESP_Name then
                local txt = plr.Name .. (SETTINGS.ESP_Distance and (" ["..math.floor(dist).."m]" or ""))
                name.Text = txt; name.Position = Vector2.new(pos.X, topY - 10); name.Color = Color3.new(1,1,1); name.Visible = true
            else name.Visible = false end
            if SETTINGS.ESP_Health then
                local ratio = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                local bw = 2; local bh = h
                local bx = leftX - bw - 2; local by = topY
                hbg.Size = Vector2.new(bw, bh); hbg.Position = Vector2.new(bx, by); hbg.Visible = true
                local fh = bh * ratio
                hfill.Size = Vector2.new(bw, fh); hfill.Position = Vector2.new(bx, by + bh - fh); hfill.Color = Color3.fromHSV(ratio*0.33,1,1); hfill.Visible = true
            else hbg.Visible = false; hfill.Visible = false end
        else
            box.Visible = false; line.Visible = false; name.Visible = false; hbg.Visible = false; hfill.Visible = false
        end
    end)
    espData[plr] = {box, line, name, hbg, hfill, conn}
end
for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(function(p)
    if espData[p] then
        for _, d in pairs(espData[p]) do safeRemove(d) end
        espData[p] = nil
    end
end)

-- ======================== WEAPON MODS ========================
local function applyMods()
    if not (SETTINGS.NoRecoil or SETTINGS.NoSpread or SETTINGS.FastReload) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
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
            pcall(function()
                local ev = tool:FindFirstChild("ReloadEvent") or tool:FindFirstChild("Reload")
                if ev and ev:IsA("RemoteEvent") then ev:FireServer() end
            end)
        end
    end
end
RunService.RenderStepped:Connect(applyMods)

-- ======================== SPEED / FLY ========================
local flying = false
local bv, bg
RunService.RenderStepped:Connect(function()
    if SETTINGS.Speed then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 50; hum.JumpPower = 80 end
        end
    else
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == 50 then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        end
    end
    if SETTINGS.Fly then
        if not flying then
            flying = true
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
                bv.Parent = char.HumanoidRootPart
                bg.Parent = char.HumanoidRootPart
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end
        end
        local char = LocalPlayer.Character
        if char and char.HumanoidRootPart and bv then
            local cam = workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,20,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,20,0) end
            bv.Velocity = move * 50
            bg.CFrame = cam.CFrame
        end
    else
        if flying then
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
            flying = false
        end
    end
end)

-- ======================== AIM HELPERS ========================
local function IsTargetVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local ray = workspace:Raycast(origin, dir, RaycastParams.new())
    return not ray or ray.Instance:IsDescendantOf(part.Parent)
end

local function getBestTarget(skipVis)
    local center = Camera.ViewportSize / 2
    local best, bestAng = nil, FOV_RADIUS
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(AIM_TARGET_PART)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local ang = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if ang < bestAng and (skipVis or IsTargetVisible(part)) then
                        bestAng = ang
                        best = p
                    end
                end
            end
        end
    end
    return best
end

-- ======================== AIM LOCK 100% (CHẶT) ========================
-- Chạy liên tục, bám cứng vào mục tiêu gần nhất trong FOV, bỏ qua tầm nhìn.
RunService.RenderStepped:Connect(function()
    if SETTINGS.AimLock then
        local target = getBestTarget(true) -- true = bỏ qua visibility, vẫn bám cả sau lưng
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(AIM_TARGET_PART)
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
end)

-- ======================== SNAP ON FIRE ========================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and SETTINGS.SnapOnFire then
        local t = getBestTarget(true)
        if t and t.Character then
            local part = t.Character:FindFirstChild(AIM_TARGET_PART)
            if part then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        end
    end
end)

-- ======================== SILENT AIM HOOK ========================
local hooked = false
local function hookSilent()
    if hooked then return end
    local mt = getrawmetatable(game)
    if not mt then return end
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and SETTINGS.SilentAim then
            local target = getBestTarget(true)
            if target and target.Character then
                local targetPart = target.Character:FindFirstChild(AIM_TARGET_PART)
                if targetPart then
                    local args = {...}
                    for i, v in pairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = targetPart.Position
                            break
                        end
                    end
                    return old(self, unpack(args))
                end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
    hooked = true
end
task.spawn(function()
    while true do
        if SETTINGS.SilentAim and not hooked then
            hookSilent()
        end
        task.wait(1)
    end
end)

-- ======================== AUTO SHOOT ========================
local lastShoot = 0
local function Shoot()
    pcall(function()
        if VirtualInput then
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.02)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        else
            UserInputService:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.02)
            UserInputService:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        end
    end)
end
RunService.RenderStepped:Connect(function()
    if SETTINGS.AutoShoot then
        local now = tick()
        if now - lastShoot > 0.033 then
            Shoot()
            lastShoot = now
        end
    end
    if SETTINGS.ShowFOV and Camera then
        local center = Camera.ViewportSize / 2
        FOVCircle.Visible = true
        FOVCircle.Position = Vector2.new(center.X, center.Y)
        FOVCircle.Radius = FOV_RADIUS
    else
        FOVCircle.Visible = false
    end
end)

-- ======================== THU GỌN MENU ========================
local collapsed = false
CollapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    CollapseBtn.Text = collapsed and "+" or "−"
    MainFrame:TweenSize(collapsed and UDim2.new(0, 280, 0, 35) or UDim2.new(0, 280, 0, 350), "Out", "Quad", 0.2, true)
    VersionFrame.Visible = not collapsed
    ContentFrame.Visible = not collapsed
end)

MainFrame.Visible = true
print("✅ Đã load: Aim Lock 100% | FOV 450 touch | Logo bên trái")
