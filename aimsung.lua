--[[
    HaiDwnG Hub - Snap Aimbot + Smooth ESP
    - Aimbot: lia tức thời (0 delay)
    - ESP: line dọc từ trên xuống dưới (đỉnh đầu -> chân)
    - Auto shoot: bắn liên tục khi có mục tiêu
    - FOV circle, màu hồng cute
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInput = game:GetService("VirtualInput") -- dùng để mô phỏng bắn

-- Cấu hình
local FOV_RADIUS = 150
local AIM_TARGET_PART = "UpperTorso"
local MAX_DISTANCE = 400
local THEME_COLOR = Color3.fromRGB(255, 133, 170)
local BG_COLOR = Color3.fromRGB(255, 245, 250)
local ESP_COLOR = Color3.fromRGB(255, 255, 255)

local ESP_SETTINGS = {
    Enabled = false,
    Name = false,
    Box = false,
    Line = false,
    Distance = false,
    Health = false,
    AimAssist = false,
    ShowFOV = false,
    AutoShoot = false
}

-- Vòng tròn FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = THEME_COLOR
FOVCircle.Transparency = 0.5

-- Hàm xóa drawing an toàn
local function safeRemoveDrawing(d)
    if d and d.Remove then pcall(d.Remove, d) end
end

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HaiDwnGHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -200)
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Thickness = 1.5
mainStroke.Color = THEME_COLOR

-- Title chuyển động màu
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

-- Version
local VersionFrame = Instance.new("Frame", MainFrame)
VersionFrame.BackgroundColor3 = Color3.fromRGB(255, 230, 240)
VersionFrame.Position = UDim2.new(0, 15, 0, 45)
VersionFrame.Size = UDim2.new(1, -30, 0, 24)
Instance.new("UICorner", VersionFrame).CornerRadius = UDim.new(0, 30)
local VersionText = Instance.new("TextLabel", VersionFrame)
VersionText.Text = "✨ hai dwng · snap aim + auto ✨"
VersionText.BackgroundTransparency = 1
VersionText.Size = UDim2.new(1,0,1,0)
VersionText.TextColor3 = Color3.fromRGB(255, 120, 150)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.GothamBold

-- Content cuộn
local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 250, 252)
ContentFrame.Position = UDim2.new(0, 12, 0, 75)
ContentFrame.Size = UDim2.new(1, -24, 1, -95)
ContentFrame.ScrollBarThickness = 3
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 12)

-- Hàm tạo toggle
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
    Label.Size = UDim2.new(0, 200, 0, 18)
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
end

-- Các toggle
MakeToggle("🌈 Bật ESP", 10, function(v) ESP_SETTINGS.Enabled = v end)
MakeToggle("📛 Hiện Tên", 35, function(v) ESP_SETTINGS.Name = v end)
MakeToggle("🗃️ Hiện Khung", 60, function(v) ESP_SETTINGS.Box = v end)
MakeToggle("📏 Hiện Khoảng Cách", 85, function(v) ESP_SETTINGS.Distance = v end)
MakeToggle("❤️ Hiện Máu", 110, function(v) ESP_SETTINGS.Health = v end)
MakeToggle("📐 Line dọc (trên xuống)", 135, function(v) ESP_SETTINGS.Line = v end)
MakeToggle("🎯 Aimbot (snap)", 160, function(v) ESP_SETTINGS.AimAssist = v end)
MakeToggle("🔘 Vòng FOV", 185, function(v) ESP_SETTINGS.ShowFOV = v end)
MakeToggle("🔫 Tự động bắn", 210, function(v) ESP_SETTINGS.AutoShoot = v end)

-- Slider FOV
local FOVLabel = Instance.new("TextLabel", ContentFrame)
FOVLabel.Position = UDim2.new(0, 10, 0, 240)
FOVLabel.Size = UDim2.new(0, 150, 0, 18)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. FOV_RADIUS
FOVLabel.TextColor3 = THEME_COLOR
FOVLabel.TextSize = 12
FOVLabel.Font = Enum.Font.GothamBold

local SliderBg = Instance.new("Frame", ContentFrame)
SliderBg.BackgroundColor3 = Color3.fromRGB(220, 200, 210)
SliderBg.Position = UDim2.new(0, 10, 0, 260)
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

-- Liên hệ admin
local ContactFrame = Instance.new("Frame", ContentFrame)
ContactFrame.Position = UDim2.new(0, 10, 0, 300)
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

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 350)

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
        if not char or not hum or not hrp or hum.Health <= 0 or not ESP_SETTINGS.Enabled then
            Box.Visible = false; Line.Visible = false; NameText.Visible = false; HealthBG.Visible = false; HealthFill.Visible = false
            return
        end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or hrp
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if onScreen and dist <= MAX_DISTANCE then
            local boxHeight = math.clamp(2800/dist, 20, 280)
            local boxWidth = math.clamp(1800/dist, 20, 180)
            local boxTopY = pos.Y - boxHeight/2
            local boxLeftX = pos.X - boxWidth/2
            
            if ESP_SETTINGS.Box then
                Box.Size = Vector2.new(boxWidth, boxHeight); Box.Position = Vector2.new(boxLeftX, boxTopY); Box.Color = ESP_COLOR; Box.Visible = true
            else Box.Visible = false end
            
            -- LINE DỌC TỪ TRÊN XUỐNG (đỉnh box -> đáy box)
            if ESP_SETTINGS.Line then
                Line.From = Vector2.new(pos.X, boxTopY)
                Line.To = Vector2.new(pos.X, boxTopY + boxHeight)
                Line.Color = ESP_COLOR; Line.Visible = true
            else Line.Visible = false end
            
            if ESP_SETTINGS.Name then
                local nameStr = player.Name
                if ESP_SETTINGS.Distance then nameStr = nameStr .. " [" .. math.floor(dist) .. "m]" end
                NameText.Text = nameStr; NameText.Position = Vector2.new(pos.X, boxTopY - 12); NameText.Color = Color3.new(1,1,1); NameText.Visible = true
            else NameText.Visible = false end
            
            if ESP_SETTINGS.Health and hum.MaxHealth > 0 then
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

-- ========== AIMBOT SNAP + AUTO SHOOT ==========
local function Shoot()
    pcall(function()
        if VirtualInput then
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, Vector2.new(0,0))
            task.wait(0.03)
            VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, Vector2.new(0,0))
        else
            -- fallback cho executor không hỗ trợ VirtualInput
            local UIS = game:GetService("UserInputService")
            UIS:SetKeyDown(Enum.KeyCode.MouseButton1)
            task.wait(0.03)
            UIS:SetKeyUp(Enum.KeyCode.MouseButton1)
        end
    end)
end

local lastShoot = 0
RunService.RenderStepped:Connect(function()
    if not Camera then Camera = workspace.CurrentCamera end
    local center = Camera.ViewportSize / 2
    FOVCircle.Visible = ESP_SETTINGS.ShowFOV
    FOVCircle.Position = Vector2.new(center.X, center.Y)
    FOVCircle.Radius = FOV_RADIUS
    
    if not ESP_SETTINGS.AimAssist then return end
    
    local bestTarget = nil
    local bestAngle = FOV_RADIUS
    local origin = Camera.CFrame.Position
    
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
    
    if bestTarget and bestTarget.Character then
        local targetPart = bestTarget.Character[AIM_TARGET_PART]
        if targetPart then
            -- Aimbot SNAP CỰC NHANH: set CFrame trực tiếp không lerp
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            
            -- Tự động bắn
            if ESP_SETTINGS.AutoShoot then
                local now = tick()
                if now - lastShoot > 0.08 then  -- bắn nhanh (khoảng 12 phát/giây)
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
    MainFrame:TweenSize(collapsed and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 420), "Out", "Quad", 0.2, true)
    VersionFrame.Visible = not collapsed
    ContentFrame.Visible = not collapsed
end)
