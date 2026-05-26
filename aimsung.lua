--[[
    HaiDwnG Hub - Ultimate Full
    - Silent Aim (hook remote) + Snap on Fire
    - Logo nhỏ toggle menu
    - Admin: @haidwng12
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
    ESP = false,
    ESP_Name = false,
    ESP_Box = false,
    ESP_Line = false,
    ESP_Distance = false,
    ESP_Health = false,
    SilentAim = false,      -- aim không xoay cam
    SnapOnFire = false,     -- xoay cam khi bắn
    AutoShoot = false,
    ShowFOV = false,
    NoRecoil = false,
    NoSpread = false,
    FastReload = false,
    Speed = false,
    Fly = false
}
local FOV_RADIUS = 150
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

-- ========== LOGO NHỎ (toggle menu) ==========
local Logo = Instance.new("TextButton")
Logo.Name = "HaiDwnG_Logo"
Logo.Parent = CoreGui
Logo.Size = UDim2.new(0, 45, 0, 45)
Logo.Position = UDim2.new(0, 15, 0, 100)
Logo.BackgroundColor3 = THEME_COLOR
Logo.BackgroundTransparency = 0.2
Logo.Text = "🌸"
Logo.TextColor3 = Color3.new(1,1,1)
Logo.TextSize = 28
Logo.Font = Enum.Font.GothamBold
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
local LogoStroke = Instance.new("UIStroke", Logo)
LogoStroke.Color = Color3.fromRGB(255,255,255)
LogoStroke.Thickness = 1

-- Kéo thả logo (không ảnh hưởng đến menu)
local logoDragging = false
local logoDragStart, logoStartPos
Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = true
        logoDragStart = input.Position
        logoStartPos = Logo.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then logoDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if logoDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - logoDragStart
        Logo.Position = UDim2.new(logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X, logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y)
    end
end)

-- ========== MENU CHÍNH ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HaiDwnGHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
local mainMenuVisible = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(0.5, -180, 0.4, -240)
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
local strokeMain = Instance.new("UIStroke", MainFrame)
strokeMain.Thickness = 1.5
strokeMain.Color = THEME_COLOR

-- Title chuyển động
local TitleBtn = Instance.new("TextButton", MainFrame)
TitleBtn.BackgroundTransparency = 1
TitleBtn.Size = UDim2.new(1, 0, 0, 40)
TitleBtn.Text = "🌸 HaiDwnG Hub Ultimate 🌸"
TitleBtn.TextSize = 18
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Nút thu gọn
local CollapseBtn = Instance.new("TextButton", MainFrame)
CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
CollapseBtn.Position = UDim2.new(1, -35, 0, 5)
CollapseBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 230)
CollapseBtn.Text = "−"
CollapseBtn.TextColor3 = Color3.fromRGB(255, 100, 130)
CollapseBtn.TextSize = 20
Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(1, 0)

local VersionFrame = Instance.new("Frame", MainFrame)
VersionFrame.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
VersionFrame.Position = UDim2.new(0, 15, 0, 45)
VersionFrame.Size = UDim2.new(1, -30, 0, 24)
Instance.new("UICorner", VersionFrame).CornerRadius = UDim.new(0, 30)
local VersionText = Instance.new("TextLabel", VersionFrame)
VersionText.Text = "✨ Silent Aim + Snap on Fire + Auto ✨"
VersionText.BackgroundTransparency = 1
VersionText.Size = UDim2.new(1,0,1,0)
VersionText.TextColor3 = Color3.fromRGB(255, 120, 150)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.GothamBold

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 250, 252)
ContentFrame.Position = UDim2.new(0, 12, 0, 75)
ContentFrame.Size = UDim2.new(1, -24, 1, -105)
ContentFrame.ScrollBarThickness = 3
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 620)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 12)

local function MakeToggle(label, yPos, callback)
    local bg = Instance.new("TextButton", ContentFrame)
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(0, 10, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(220, 200, 210)
    bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame", bg)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", ContentFrame)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 55, 0, yPos)
    lbl.Size = UDim2.new(0, 260, 0, 18)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(100, 50, 70)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    local active = false
    bg.MouseButton1Click:Connect(function()
        active = not active
        bg.BackgroundColor3 = active and THEME_COLOR or Color3.fromRGB(220, 200, 210)
        dot:TweenPosition(active and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.1, true)
        if callback then callback(active) end
    end)
end

local y = 10
MakeToggle("🌈 Bật ESP", y, function(v) SETTINGS.ESP = v end); y=y+25
MakeToggle("📛 Hiện Tên", y, function(v) SETTINGS.ESP_Name = v end); y=y+25
MakeToggle("🗃️ Hiện Khung", y, function(v) SETTINGS.ESP_Box = v end); y=y+25
MakeToggle("📏 Hiện Khoảng Cách", y, function(v) SETTINGS.ESP_Distance = v end); y=y+25
MakeToggle("❤️ Hiện Máu", y, function(v) SETTINGS.ESP_Health = v end); y=y+25
MakeToggle("📐 Line dọc (trên xuống)", y, function(v) SETTINGS.ESP_Line = v end); y=y+25
MakeToggle("🎯 Silent Aim (đạn tự bay)", y, function(v) SETTINGS.SilentAim = v end); y=y+25
MakeToggle("🎯 Snap khi bắn (xoay cam)", y, function(v) SETTINGS.SnapOnFire = v end); y=y+25
MakeToggle("🔫 Tự động bắn (30/s)", y, function(v) SETTINGS.AutoShoot = v end); y=y+25
MakeToggle("🔘 Vòng FOV", y, function(v) SETTINGS.ShowFOV = v end); y=y+25
MakeToggle("🚫 No Recoil", y, function(v) SETTINGS.NoRecoil = v end); y=y+25
MakeToggle("🎯 No Spread", y, function(v) SETTINGS.NoSpread = v end); y=y+25
MakeToggle("⚡ Tăng tốc chạy/nhảy", y, function(v) SETTINGS.Speed = v end); y=y+25
MakeToggle("🕊️ Fly Mode", y, function(v) SETTINGS.Fly = v end); y=y+30

-- FOV Slider
local FOVLabel = Instance.new("TextLabel", ContentFrame)
FOVLabel.Position = UDim2.new(0, 10, 0, y)
FOVLabel.Size = UDim2.new(0, 150, 0, 18)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. FOV_RADIUS
FOVLabel.TextColor3 = THEME_COLOR
FOVLabel.TextSize = 12
FOVLabel.Font = Enum.Font.GothamBold
y = y + 20

local SliderBg = Instance.new("Frame", ContentFrame)
SliderBg.BackgroundColor3 = Color3.fromRGB(220, 200, 210)
SliderBg.Position = UDim2.new(0, 10, 0, y)
SliderBg.Size = UDim2.new(1, -20, 0, 4)
local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.BackgroundColor3 = THEME_COLOR
SliderFill.Size = UDim2.new(FOV_RADIUS/500, 0, 1, 0)
local SliderBall = Instance.new("TextButton", SliderFill)
SliderBall.Size = UDim2.new(0, 12, 0, 12)
SliderBall.Position = UDim2.new(1, -6, 0.5, -6)
SliderBall.Text = ""
SliderBall.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SliderBall).CornerRadius = UDim.new(1, 0)

local function SetFOV(mouseX)
    local rel = math.clamp((mouseX - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    FOV_RADIUS = math.floor(rel * 400 + 50)
    SliderFill.Size = UDim2.new(rel, 0, 1, 0)
    FOVLabel.Text = "FOV: " .. FOV_RADIUS
    FOVCircle.Radius = FOV_RADIUS
end

local sliderMoving = false
SliderBall.MouseButton1Down:Connect(function()
    sliderMoving = true
    local moveCon, endCon
    moveCon = UserInputService.InputChanged:Connect(function(input)
        if sliderMoving and input.UserInputType == Enum.UserInputType.MouseMovement then
            SetFOV(input.Position.X)
        end
    end)
    endCon = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderMoving = false
            moveCon:Disconnect()
            endCon:Disconnect()
        end
    end)
end)
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SetFOV(input.Position.X)
    end
end)
y = y + 30

local ContactFrame = Instance.new("Frame", ContentFrame)
ContactFrame.Position = UDim2.new(0, 10, 0, y)
ContactFrame.Size = UDim2.new(1, -20, 0, 34)
ContactFrame.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
Instance.new("UICorner", ContactFrame).CornerRadius = UDim.new(0, 20)
local ContactLabel = Instance.new("TextLabel", ContactFrame)
ContactLabel.Text = "💌 Admin: @haidwng12 💌"
ContactLabel.Size = UDim2.new(1,0,1,0)
ContactLabel.BackgroundTransparency = 1
ContactLabel.TextColor3 = THEME_COLOR
ContactLabel.TextSize = 12
ContactLabel.Font = Enum.Font.GothamBold

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 60)

-- ========== TOGGLE MENU BẰNG LOGO ==========
Logo.MouseButton1Click:Connect(function()
    mainMenuVisible = not mainMenuVisible
    MainFrame.Visible = mainMenuVisible
    Logo.BackgroundTransparency = mainMenuVisible and 0.2 or 0.6
end)

-- ========== ESP ENGINE ==========
local function IsTargetVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local ray = workspace:Raycast(origin, direction, RaycastParams.new())
    return not ray or ray.Instance:IsDescendantOf(part.Parent)
end

local function safeRemoveDrawing(d)
    if d and d.Remove then pcall(d.Remove, d) end
end

local espObjects = {}
local function CleanESP(player)
    local data = espObjects[player]
    if data then
        for _, draw in pairs(data) do safeRemoveDrawing(draw) end
        if data.conn then data.conn:Disconnect() end
        espObjects[player] = nil
    end
end

local function AddESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false
    local line = Drawing.new("Line"); line.Thickness = 1
    local name = Drawing.new("Text"); name.Size = 12; name.Center = true; name.Outline = true
    local hbg = Drawing.new("Square"); hbg.Thickness = 1; hbg.Filled = true; hbg.Color = Color3.new(0,0,0); hbg.Transparency = 0.5
    local hfill = Drawing.new("Square"); hfill.Thickness = 0; hfill.Filled = true
    local conn = RunService.RenderStepped:Connect(function()
        if not player.Parent then CleanESP(player) return end
        local char = player.Character
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
                local txt = player.Name .. (SETTINGS.ESP_Distance and (" ["..math.floor(dist).."m]" or ""))
                name.Text = txt; name.Position = Vector2.new(pos.X, topY - 12); name.Color = Color3.new(1,1,1); name.Visible = true
            else name.Visible = false end
            if SETTINGS.ESP_Health then
                local ratio = math.clamp(hum.Health/hum.MaxHealth,0,1)
                local bw = 3; local bh = h
                local bx = leftX - bw - 2; local by = topY
                hbg.Size = Vector2.new(bw, bh); hbg.Position = Vector2.new(bx, by); hbg.Visible = true
                local fh = bh * ratio
                hfill.Size = Vector2.new(bw, fh); hfill.Position = Vector2.new(bx, by + bh - fh); hfill.Color = Color3.fromHSV(ratio*0.33,1,1); hfill.Visible = true
            else hbg.Visible = false; hfill.Visible = false end
        else
            box.Visible = false; line.Visible = false; name.Visible = false; hbg.Visible = false; hfill.Visible = false
        end
    end)
    espObjects[player] = {box,line,name,hbg,hfill,conn}
end

for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(CleanESP)

-- ========== WEAPON MODS ==========
local function applyWeaponMods()
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
RunService.RenderStepped:Connect(applyWeaponMods)

-- ========== SPEED / FLY ==========
local flying, bodyVel, bodyGyro = false
local function fly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not bodyVel then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(1e6,1e6,1e6)
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
    end
    bodyVel.Parent = hrp
    bodyGyro.Parent = hrp
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    local cam = workspace.CurrentCamera
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,20,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,20,0) end
    bodyVel.Velocity = move * 50
    bodyGyro.CFrame = cam.CFrame
end
local function disableFly()
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    flying = false
end
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
        if not flying then flying = true end
        fly()
    else
        if flying then disableFly(); flying = false end
    end
end)

-- ========== AIMBOT: GET TARGET ==========
local function getBestTarget(skipVisibility)
    local center = Camera.ViewportSize / 2
    local bestTarget, bestAngle = nil, FOV_RADIUS
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(AIM_TARGET_PART)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local angle = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if angle < bestAngle then
                        if skipVisibility or IsTargetVisible(part) then
                            bestAngle = angle
                            bestTarget = p
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Snap khi bắn
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and SETTINGS.SnapOnFire then
        local target = getBestTarget(true)
        if target and target.Character then
            local part = target.Character:FindFirstChild(AIM_TARGET_PART)
            if part then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        end
    end
end)

-- ========== SILENT AIM (HOOK REMOTE) ==========
local oldNamecall
local hooked = false
local function setupSilentAim()
    if not SETTINGS.SilentAim then return end
    if hooked then return end
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" then
            local args = {...}
            local target = getBestTarget(true)
            if target and target.Character then
                local targetPart = target.Character:FindFirstChild(AIM_TARGET_PART)
                if targetPart then
                    -- Chèn vị trí đích vào args nếu remote nhận tọa độ
                    for i, v in pairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = targetPart.Position
                            break
                        end
                    end
                end
            end
            return old(self, unpack(args))
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
    hooked = true
end

-- Gọi lại khi toggle silent aim
local silentAimEnabled = false
MakeToggle("🎯 Silent Aim (đạn tự bay)", y, function(v) 
    SETTINGS.SilentAim = v
    if v and not hooked then setupSilentAim() end
end) -- nhưng dòng này trùng, thực tế đã có toggle ở trên, không cần thêm. Tuy nhiên để đảm bảo hook, ta gọi setup khi bật.

-- Tự động setup khi script chạy (nếu silent aim được bật sau, ta vẫn gọi được nhờ toggle)
-- Thêm vào hàm toggle cũ? Không, tôi sẽ tạo một coroutine kiểm tra.
task.spawn(function()
    while true do
        if SETTINGS.SilentAim and not hooked then
            setupSilentAim()
        end
        task.wait(1)
    end
end)

-- ========== AUTO SHOOT ==========
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

-- Thu gọn menu
local collapsed = false
CollapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    CollapseBtn.Text = collapsed and "+" or "−"
    MainFrame:TweenSize(collapsed and UDim2.new(0, 360, 0, 40) or UDim2.new(0, 360, 0, 520), "Out", "Quad", 0.2, true)
    VersionFrame.Visible = not collapsed
    ContentFrame.Visible = not collapsed
end)

-- Khởi tạo visible
MainFrame.Visible = true
print("🌸 HaiDwnG Hub đã sẵn sàng. Click logo 🌸 để bật/tắt menu.")
