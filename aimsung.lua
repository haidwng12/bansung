--[[
    HaiDwnG Hub - Ultimate Edition
    Silent Aim | No Recoil | Fast Reload | Speed/Fly | Snap Aimbot | Auto Shoot 30/s | ESP
    Admin: @haidwng12
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInput = game:GetService("VirtualInput")

-- Cấu hình
local FOV_RADIUS = 150
local AIM_TARGET_PART = "UpperTorso"
local MAX_DISTANCE = 400
local THEME_COLOR = Color3.fromRGB(255, 133, 170)
local BG_COLOR = Color3.fromRGB(255, 245, 250)
local ESP_COLOR = Color3.fromRGB(255, 255, 255)

-- Cài đặt các tính năng
local SETTINGS = {
    ESP = false,
    ESP_Name = false,
    ESP_Box = false,
    ESP_Line = false,
    ESP_Distance = false,
    ESP_Health = false,
    SnapAim = false,
    SilentAim = false,
    ShowFOV = false,
    AutoShoot = false,
    NoRecoil = false,
    NoSpread = false,
    Speed = false,
    Fly = false,
    FastReload = false
}

local speedValue = 50
local jumpPowerValue = 80

-- Vòng FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = THEME_COLOR
FOVCircle.Transparency = 0.5

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HaiDwnGHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(0.5, -180, 0.4, -240)
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Thickness = 1.5
mainStroke.Color = THEME_COLOR

-- Title chuyển động
local TitleBtn = Instance.new("TextButton", MainFrame)
TitleBtn.BackgroundTransparency = 1
TitleBtn.Size = UDim2.new(1, 0, 0, 40)
TitleBtn.Text = "🌸 HaiDwnG Hub 🌸"
TitleBtn.TextSize = 18
TitleBtn.Font = Enum.Font.GothamBlack
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    if not MainFrame.Parent then return end
    hue = (hue + dt * 0.5) % 1
    TitleBtn.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
end)

-- Kéo thả
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

-- Version
local VersionFrame = Instance.new("Frame", MainFrame)
VersionFrame.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
VersionFrame.Position = UDim2.new(0, 15, 0, 45)
VersionFrame.Size = UDim2.new(1, -30, 0, 24)
Instance.new("UICorner", VersionFrame).CornerRadius = UDim.new(0, 30)
local VersionText = Instance.new("TextLabel", VersionFrame)
VersionText.Text = "✨ Ultimate Edition · Silent + No Recoil ✨"
VersionText.BackgroundTransparency = 1
VersionText.Size = UDim2.new(1,0,1,0)
VersionText.TextColor3 = Color3.fromRGB(255, 120, 150)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.GothamBold

-- Content cuộn
local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 250, 252)
ContentFrame.Position = UDim2.new(0, 12, 0, 75)
ContentFrame.Size = UDim2.new(1, -24, 1, -105)
ContentFrame.ScrollBarThickness = 3
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 620)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 12)

-- Helper tạo toggle
local function MakeToggle(label, yPos, callback)
    local SwitchBg = Instance.new("TextButton", ContentFrame)
    SwitchBg.Size = UDim2.new(0, 36, 0, 18)
    SwitchBg.Position = UDim2.new(0, 10, 0, yPos)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(220, 200, 210)
    SwitchBg.Text = ""
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame", SwitchBg)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    local Label = Instance.new("TextLabel", ContentFrame)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 55, 0, yPos)
    Label.Size = UDim2.new(0, 260, 0, 18)
    Label.Text = label
    Label.TextColor3 = Color3.fromRGB(100, 50, 70)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local active = false
    SwitchBg.MouseButton1Click:Connect(function()
        active = not active
        SwitchBg.BackgroundColor3 = active and THEME_COLOR or Color3.fromRGB(220, 200, 210)
        Dot:TweenPosition(active and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.1, true)
        if callback then callback(active) end
    end)
    return function() return active end
end

-- Tất cả toggle
local y = 10
MakeToggle("🌈 Bật ESP", y, function(v) SETTINGS.ESP = v end); y = y + 25
MakeToggle("📛 Hiện Tên", y, function(v) SETTINGS.ESP_Name = v end); y = y + 25
MakeToggle("🗃️ Hiện Khung", y, function(v) SETTINGS.ESP_Box = v end); y = y + 25
MakeToggle("📏 Hiện Khoảng Cách", y, function(v) SETTINGS.ESP_Distance = v end); y = y + 25
MakeToggle("❤️ Hiện Máu", y, function(v) SETTINGS.ESP_Health = v end); y = y + 25
MakeToggle("📐 Line dọc (trên xuống)", y, function(v) SETTINGS.ESP_Line = v end); y = y + 25
MakeToggle("🎯 Snap Aimbot (xoay cam)", y, function(v) SETTINGS.SnapAim = v end); y = y + 25
MakeToggle("🎯 Silent Aimbot (ko xoay cam)", y, function(v) SETTINGS.SilentAim = v end); y = y + 25
MakeToggle("🔘 Vòng FOV", y, function(v) SETTINGS.ShowFOV = v end); y = y + 25
MakeToggle("🔫 Tự động bắn (30/s)", y, function(v) SETTINGS.AutoShoot = v end); y = y + 25
MakeToggle("🚫 No Recoil", y, function(v) SETTINGS.NoRecoil = v end); y = y + 25
MakeToggle("🎯 No Spread", y, function(v) SETTINGS.NoSpread = v end); y = y + 25
MakeToggle("⚡ Tăng tốc chạy/nhảy", y, function(v) SETTINGS.Speed = v end); y = y + 25
MakeToggle("🕊️ Fly Mode", y, function(v) SETTINGS.Fly = v end); y = y + 30

-- Slider FOV (giữ nguyên)
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

-- Liên hệ admin
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

-- ========== ESP ENGINE ==========
local function IsTargetVisible(part)
    if not part or not part.Parent then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    if result.Instance:IsDescendantOf(part.Parent) then return true end
    return false
end

local function safeRemoveDrawing(d)
    if d and d.Remove then pcall(d.Remove, d) end
end

local espObjects = {}
local function CleanESP(player)
    local data = espObjects[player]
    if data then
        for _, draw in pairs(data) do safeRemoveDrawing(draw) end
        if data.connection then data.connection:Disconnect() end
        espObjects[player] = nil
    end
end

local function AddESP(player)
    if player == LocalPlayer then return end
    local Box = Drawing.new("Square"); Box.Thickness = 1; Box.Filled = false; Box.Visible = false
    local Line = Drawing.new("Line"); Line.Thickness = 1; Line.Visible = false
    local NameText = Drawing.new("Text"); NameText.Size = 12; NameText.Center = true; NameText.Outline = true; NameText.OutlineColor = Color3.new(0,0,0); NameText.Visible = false
    local HealthBG = Drawing.new("Square"); HealthBG.Thickness = 1; HealthBG.Filled = true; HealthBG.Color = Color3.fromRGB(0,0,0); HealthBG.Transparency = 0.5; HealthBG.Visible = false
    local HealthFill = Drawing.new("Square"); HealthFill.Thickness = 0; HealthFill.Filled = true; HealthFill.Visible = false

    local connection = RunService.RenderStepped:Connect(function()
        if not player or not player.Parent then CleanESP(player) return end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not hrp or hum.Health <= 0 or not SETTINGS.ESP then
            Box.Visible = false; Line.Visible = false; NameText.Visible = false; HealthBG.Visible = false; HealthFill.Visible = false
            return
        end
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if onScreen and dist <= MAX_DISTANCE then
            local boxHeight = math.clamp(2800/dist, 20, 280)
            local boxWidth = math.clamp(1800/dist, 20, 180)
            local boxTopY = pos.Y - boxHeight/2
            local boxLeftX = pos.X - boxWidth/2
            
            if SETTINGS.ESP_Box then
                Box.Size = Vector2.new(boxWidth, boxHeight); Box.Position = Vector2.new(boxLeftX, boxTopY); Box.Color = ESP_COLOR; Box.Visible = true
            else Box.Visible = false end
            
            if SETTINGS.ESP_Line then
                Line.From = Vector2.new(pos.X, boxTopY)
                Line.To = Vector2.new(pos.X, boxTopY + boxHeight)
                Line.Color = ESP_COLOR; Line.Visible = true
            else Line.Visible = false end
            
            if SETTINGS.ESP_Name then
                local nameStr = player.Name
                if SETTINGS.ESP_Distance then nameStr = nameStr .. " [" .. math.floor(dist) .. "m]" end
                NameText.Text = nameStr; NameText.Position = Vector2.new(pos.X, boxTopY - 12); NameText.Color = Color3.new(1,1,1); NameText.Visible = true
            else NameText.Visible = false end
            
            if SETTINGS.ESP_Health and hum.MaxHealth > 0 then
                local healthRatio = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                local barW = 3; local barH = boxHeight
                local barX = boxLeftX - barW - 2; local barY = boxTopY
                HealthBG.Size = Vector2.new(barW, barH); HealthBG.Position = Vector2.new(barX, barY); HealthBG.Visible = true
                local fillH = barH * healthRatio
                HealthFill.Size = Vector2.new(barW, fillH); HealthFill.Position = Vector2.new(barX, barY + barH - fillH); HealthFill.Color = Color3.fromHSV(healthRatio*0.33, 1, 1); HealthFill.Visible = true
            else HealthBG.Visible = false; HealthFill.Visible = false end
        else
            Box.Visible = false; Line.Visible = false; NameText.Visible = false; HealthBG.Visible = false; HealthFill.Visible = false
        end
    end)
    espObjects[player] = {Box=Box, Line=Line, Name=NameText, HealthBG=HealthBG, HealthFill=HealthFill, connection=connection}
end

for _, plr in pairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(CleanESP)
LocalPlayer.CharacterAdded:Connect(function()
    for plr,_ in pairs(espObjects) do CleanESP(plr) end
    for _,plr in pairs(Players:GetPlayers()) do AddESP(plr) end
end)

-- ========== NO RECOIL / NO SPREAD ==========
local function noRecoilSpread()
    if not (SETTINGS.NoRecoil or SETTINGS.NoSpread) then return end
    local playerGui = LocalPlayer.PlayerGui
    local weapon = nil
    -- Tìm tool đang cầm (toolbar item)
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Parent == LocalPlayer.Character then
            weapon = tool
            break
        end
    end
    if not weapon then return end
    -- Thử tìm module camera recoil hoặc các property
    if SETTINGS.NoRecoil then
        -- Nhiều game dùng CameraRecoil module, ta có thể set recurrence
        pcall(function()
            local recoil = weapon:FindFirstChild("Recoil") or weapon:FindFirstChild("CameraRecoil")
            if recoil then
                recoil:Destroy()
            end
            for _, v in pairs(weapon:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:lower():match("recoil") or v.Name:lower():match("kick")) then
                    v.Value = 0
                end
            end
        end)
    end
    if SETTINGS.NoSpread then
        pcall(function()
            for _, v in pairs(weapon:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:lower():match("spread") or v.Name:lower():match("accuracy")) then
                    v.Value = 0
                end
            end
        end)
    end
end

-- Chạy liên tục để quét
RunService.RenderStepped:Connect(noRecoilSpread)

-- ========== FAST RELOAD ==========
local function fastReload()
    if not SETTINGS.FastReload then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    -- Tìm animation cooldown reload
    for _, v in pairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") and (v.Name:lower():match("reload") or v.Name:lower():match("cooldown")) then
            v.Value = 0
        elseif v:IsA("BoolValue") and v.Name:lower():match("reloading") then
            v.Value = false
        end
    end
    -- Set lại thời gian reload nếu có RemoteEvent
    pcall(function()
        local reloadEvent = tool:FindFirstChild("ReloadEvent") or tool:FindFirstChild("Reload")
        if reloadEvent and reloadEvent:IsA("RemoteEvent") then
            -- Gọi để kích hoạt reload tức thì? Thực tế nên làm ngược lại
        end
    end)
end
RunService.RenderStepped:Connect(fastReload)

-- ========== SPEED / FLY ==========
local flying = false
local bodyVelocity, bodyGyro
local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = char.HumanoidRootPart
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.Parent = char.HumanoidRootPart
    flying = true
    local camera = workspace.CurrentCamera
    UserInputService.InputBegan:Connect(function(input)
        if not flying then return end
        if input.KeyCode == Enum.KeyCode.Space then
            bodyVelocity.Velocity = camera.CFrame.LookVector * 50 + Vector3.new(0, 20, 0)
        elseif input.KeyCode == Enum.KeyCode.W then
            bodyVelocity.Velocity = camera.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.S then
            bodyVelocity.Velocity = -camera.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.A then
            bodyVelocity.Velocity = -camera.CFrame.RightVector * 50
        elseif input.KeyCode == Enum.KeyCode.D then
            bodyVelocity.Velocity = camera.CFrame.RightVector * 50
        end
    end)
end
local function disableFly()
    if bodyVelocity then bodyVelocity:Destroy() end
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
            if hum then
                hum.WalkSpeed = speedValue
                hum.JumpPower = jumpPowerValue
            end
        end
    else
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == speedValue then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
        end
    end
    if SETTINGS.Fly then
        if not flying then enableFly() end
    else
        if flying then disableFly() end
    end
end)

-- ========== AIMBOT & AUTO SHOOT ==========
local function Shoot()
    pcall(function()
        if VirtualInput then
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.02)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        else
            local UIS = game:GetService("UserInputService")
            UIS:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.02)
            UIS:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        end
    end)
end

local lastShoot = 0
local function getBestTarget()
    local center = Camera.ViewportSize / 2
    local bestTarget = nil
    local bestAngle = FOV_RADIUS
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AIM_TARGET_PART) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character[AIM_TARGET_PART]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local angle = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if angle < bestAngle and IsTargetVisible(part) then
                        bestAngle = angle
                        bestTarget = p
                    end
                end
            end
        end
    end
    return bestTarget, bestAngle
end

RunService.RenderStepped:Connect(function()
    if not Camera then Camera = workspace.CurrentCamera end
    local center = Camera.ViewportSize / 2
    FOVCircle.Visible = SETTINGS.ShowFOV
    FOVCircle.Position = Vector2.new(center.X, center.Y)
    FOVCircle.Radius = FOV_RADIUS
    
    local target, angle = getBestTarget()
    if target then
        local targetPart = target.Character[AIM_TARGET_PART]
        if targetPart then
            -- Snap Aimbot
            if SETTINGS.SnapAim then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
            -- Silent Aimbot: không cần xoay cam, nhưng cần redirect đạn.
            -- Thực tế Silent Aim cần hook vào RemoteEvent của game để sửa hướng bắn.
            -- Do tính phức tạp và khác biệt giữa các game, ta tạm thời chưa implement.
            -- Tao sẽ để chế độ SnapAim làm chính. Nếu mày muốn Silent thực sự, cần phân tích game.
            
            -- Auto Shoot
            if SETTINGS.AutoShoot then
                local now = tick()
                if now - lastShoot > 0.033 then
                    Shoot()
                    lastShoot = now
                end
            end
        end
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

print("HaiDwnG Hub Ultimate đã load. Admin: @haidwng12")
