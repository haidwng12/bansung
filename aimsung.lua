--[[
    The King Cheat OFC - Fixed & Enhanced by H4T0Ki
    Bản fix: raycast an toàn, smooth aimbot thực, ESP chuẩn, tự hủy drawing, ko crash.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình mặc định
local THEME_COLOR = Color3.fromRGB(0, 255, 170)
local BG_COLOR = Color3.fromRGB(15, 20, 28)
local ESP_COLOR = Color3.fromRGB(255, 255, 255)

local FOV_RADIUS = 100
local AIM_SMOOTH = 5          -- smooth thực tế (càng lớn càng chậm)
local AIM_TARGET_PART = "UpperTorso"
local ESP_SETTINGS = {
    Enabled = false,
    Name = false,
    Box = false,
    Line = false,
    Distance = false,
    Health = false,
    AimAssist = false,
    ShowFOV = false
}

local MAX_DISTANCE = 400

-- Vòng tròn FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = THEME_COLOR
FOVCircle.Transparency = 0.6

-- Hàm an toàn xóa drawing
local function safeRemoveDrawing(d)
    if d and d.Remove then pcall(d.Remove, d) end
end

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheKingCheat_Fixed"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -175)
MainFrame.Size = UDim2.new(0, 280, 0, 350)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Thickness = 1
mainStroke.Color = THEME_COLOR
mainStroke.Transparency = 0.5

-- Thanh tiêu đề kéo thả
local TitleBtn = Instance.new("TextButton", MainFrame)
TitleBtn.BackgroundTransparency = 1
TitleBtn.Size = UDim2.new(1, 0, 0, 30)
TitleBtn.Text = "▼  THE KING CHEAT OFC"
TitleBtn.TextColor3 = Color3.new(1,1,1)
TitleBtn.TextSize = 13
TitleBtn.Font = Enum.Font.GothamBlack

local dragging = false
local dragStart, startPos
TitleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Version
local VersionFrame = Instance.new("Frame", MainFrame)
VersionFrame.BackgroundColor3 = Color3.fromRGB(10, 30, 30)
VersionFrame.Position = UDim2.new(0, 10, 0, 32)
VersionFrame.Size = UDim2.new(1, -20, 0, 18)
Instance.new("UICorner", VersionFrame).CornerRadius = UDim.new(0, 6)
local verStroke = Instance.new("UIStroke", VersionFrame)
verStroke.Color = THEME_COLOR
local VersionText = Instance.new("TextLabel", VersionFrame)
VersionText.Text = "VanNghiaa-V1"
VersionText.BackgroundTransparency = 1
VersionText.Size = UDim2.new(1,0,1,0)
VersionText.TextColor3 = THEME_COLOR
VersionText.TextSize = 10
VersionText.Font = Enum.Font.GothamBold

-- Nội dung cuộn
local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(18, 23, 30)
ContentFrame.Position = UDim2.new(0, 10, 0, 56)
ContentFrame.Size = UDim2.new(1, -20, 1, -66)
ContentFrame.ScrollBarThickness = 2
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 6)
local contentStroke = Instance.new("UIStroke", ContentFrame)
contentStroke.Color = THEME_COLOR

-- Ngôn ngữ
local CurrentLang = "VN"
local UI_Elements = {}
local function UpdateLanguage()
    for obj, trans in pairs(UI_Elements) do
        if obj and obj.Parent then
            obj.Text = trans[CurrentLang]
        end
    end
end

local function MakeSection(vn, en, yPos, color)
    local lbl = Instance.new("TextLabel", ContentFrame)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.Size = UDim2.new(0, 100, 0, 15)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    UI_Elements[lbl] = {VN = vn, EN = en}
    local line = Instance.new("Frame", ContentFrame)
    line.Position = UDim2.new(0, 10, 0, yPos + 16)
    line.Size = UDim2.new(1, -20, 0, 1)
    line.BackgroundColor3 = THEME_COLOR
    line.BackgroundTransparency = 0.8
end

local function MakeToggle(vn, en, yPos, callback)
    local SwitchBg = Instance.new("TextButton", ContentFrame)
    SwitchBg.Size = UDim2.new(0, 30, 0, 15)
    SwitchBg.Position = UDim2.new(0, 10, 0, yPos)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 60, 70)
    SwitchBg.Text = ""
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame", SwitchBg)
    Dot.Size = UDim2.new(0, 9, 0, 9)
    Dot.Position = UDim2.new(0, 3, 0.5, -4.5)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    local Label = Instance.new("TextLabel", ContentFrame)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 50, 0, yPos)
    Label.Size = UDim2.new(0, 180, 0, 15)
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    UI_Elements[Label] = {VN = vn, EN = en}
    local active = false
    SwitchBg.MouseButton1Click:Connect(function()
        active = not active
        SwitchBg.BackgroundColor3 = active and THEME_COLOR or Color3.fromRGB(50, 60, 70)
        Dot:TweenPosition(active and UDim2.new(1, -12, 0.5, -4.5) or UDim2.new(0, 3, 0.5, -4.5), "Out", "Quad", 0.1, true)
        if callback then callback(active) end
    end)
end

-- Ngôn ngữ dropdown
MakeSection("NGÔN NGỮ", "LANGUAGE", 10, THEME_COLOR)
local LangBtn = Instance.new("TextButton", ContentFrame)
LangBtn.Size = UDim2.new(1, -20, 0, 22)
LangBtn.Position = UDim2.new(0, 10, 0, 30)
LangBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
LangBtn.Text = "Tiếng Việt  ▼"
LangBtn.TextColor3 = Color3.new(1,1,1)
LangBtn.TextSize = 10
Instance.new("UICorner", LangBtn)
local LangDrop = Instance.new("Frame", ContentFrame)
LangDrop.Size = UDim2.new(1, -20, 0, 40)
LangDrop.Position = UDim2.new(0, 10, 0, 52)
LangDrop.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
LangDrop.Visible = false
LangDrop.ZIndex = 10
Instance.new("UICorner", LangDrop)
local lVN = Instance.new("TextButton", LangDrop)
lVN.Size = UDim2.new(1,0,0,20)
lVN.Position = UDim2.new(0,0,0,0)
lVN.Text = "Tiếng Việt"
lVN.BackgroundTransparency = 1
lVN.TextColor3 = Color3.new(1,1,1)
lVN.ZIndex = 11
local lEN = Instance.new("TextButton", LangDrop)
lEN.Size = UDim2.new(1,0,0,20)
lEN.Position = UDim2.new(0,0,0,20)
lEN.Text = "English"
lEN.BackgroundTransparency = 1
lEN.TextColor3 = Color3.new(1,1,1)
lEN.ZIndex = 11
LangBtn.MouseButton1Click:Connect(function() LangDrop.Visible = not LangDrop.Visible end)
lVN.MouseButton1Click:Connect(function()
    CurrentLang = "VN"
    LangBtn.Text = "Tiếng Việt  ▼"
    LangDrop.Visible = false
    UpdateLanguage()
end)
lEN.MouseButton1Click:Connect(function()
    CurrentLang = "EN"
    LangBtn.Text = "English  ▼"
    LangDrop.Visible = false
    UpdateLanguage()
end)

-- AIMBOT MENU
MakeSection("AIMBOT-MENU", "AIMBOT-MENU", 80, Color3.fromRGB(255, 180, 50))
MakeToggle("Aimbot", "Aim Assist", 100, function(v) ESP_SETTINGS.AimAssist = v end)
MakeToggle("FOV", "Show Draw Fov", 120, function(v) ESP_SETTINGS.ShowFOV = v end)

local FOVLabel = Instance.new("TextLabel", ContentFrame)
FOVLabel.Text = "FOV: 100"
FOVLabel.Position = UDim2.new(0, 10, 0, 140)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = THEME_COLOR
FOVLabel.TextSize = 10
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBg = Instance.new("Frame", ContentFrame)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 50, 60)
SliderBg.Position = UDim2.new(0, 10, 0, 155)
SliderBg.Size = UDim2.new(1, -20, 0, 3)
local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.BackgroundColor3 = THEME_COLOR
SliderFill.Size = UDim2.new(0.2, 0, 1, 0)
local SliderBall = Instance.new("TextButton", SliderFill)
SliderBall.Size = UDim2.new(0, 10, 0, 10)
SliderBall.Position = UDim2.new(1, -5, 0.5, -5)
SliderBall.Text = ""
SliderBall.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SliderBall).CornerRadius = UDim.new(1, 0)

local function SetFOVFromMouse(mouseX)
    local rel = math.clamp((mouseX - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(rel, 0, 1, 0)
    FOV_RADIUS = math.floor(rel * 500)
    FOVLabel.Text = "FOV: " .. FOV_RADIUS
    FOVCircle.Radius = FOV_RADIUS
end

local sliderMoving = false
SliderBall.MouseButton1Down:Connect(function()
    sliderMoving = true
    ContentFrame.ScrollingEnabled = false
    local moveCon, endCon
    moveCon = UserInputService.InputChanged:Connect(function(input)
        if sliderMoving and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            SetFOVFromMouse(input.Position.X)
        end
    end)
    endCon = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderMoving = false
            ContentFrame.ScrollingEnabled = true
            moveCon:Disconnect()
            endCon:Disconnect()
        end
    end)
end)
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SetFOVFromMouse(input.Position.X)
    end
end)

-- ESP MENU
MakeSection("ESP-MENU", "ESP-MENU", 190, Color3.fromRGB(255, 50, 255))
MakeToggle("TẤT ESP", "Enable ESP", 210, function(v) ESP_SETTINGS.Enabled = v end)
MakeToggle("Hiện Tên", "ESP Name", 230, function(v) ESP_SETTINGS.Name = v end)
MakeToggle("Hiện Khoảng Cách", "ESP Distance", 250, function(v) ESP_SETTINGS.Distance = v end)
MakeToggle("Hiện Đường Kẻ", "ESP Line", 270, function(v) ESP_SETTINGS.Line = v end)
MakeToggle("Hiện Khung", "ESP Box", 290, function(v) ESP_SETTINGS.Box = v end)
MakeToggle("Hiện Máu", "ESP Health", 310, function(v) ESP_SETTINGS.Health = v end)

MakeSection("MÀU ESP", "ESP COLORS", 340, THEME_COLOR)

local ColorPickerFrame = Instance.new("Frame", ContentFrame)
ColorPickerFrame.Position = UDim2.new(0, 10, 0, 360)
ColorPickerFrame.Size = UDim2.new(1, -20, 0, 70)
ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
Instance.new("UICorner", ColorPickerFrame)

local COLORS = {
    Color3.new(1,1,1), Color3.fromRGB(255,0,0), Color3.fromRGB(255,165,0),
    Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,255,255),
    Color3.fromRGB(0,0,255), Color3.fromRGB(128,0,128), Color3.fromRGB(255,192,203),
    Color3.fromRGB(165,42,42), Color3.fromRGB(192,192,192), Color3.fromRGB(0,100,0),
    Color3.fromRGB(75,0,130), Color3.fromRGB(255,69,0), Color3.fromRGB(210,105,30),
    Color3.fromRGB(173,216,230), Color3.fromRGB(255,20,147), Color3.fromRGB(128,128,0),
    Color3.fromRGB(255,228,196), Color3.fromRGB(0,0,0)
}

local activeColorBtn = nil
local function SetESPColor(color)
    ESP_COLOR = color
end

local function CreateColorButton(idx, color)
    local btn = Instance.new("TextButton", ColorPickerFrame)
    local cols = 10
    local size = 20
    local spacing = 4
    local row = math.floor((idx-1)/cols)
    local col = (idx-1)%cols
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = UDim2.new(0, 5 + col*(size+spacing), 0, 5 + row*(size+spacing))
    btn.BackgroundColor3 = color
    btn.Text = ""
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    if idx == 1 then
        btn.BorderSizePixel = 2
        btn.BorderColor3 = THEME_COLOR
        activeColorBtn = btn
    end
    btn.MouseButton1Click:Connect(function()
        if activeColorBtn then
            activeColorBtn.BorderSizePixel = 1
            activeColorBtn.BorderColor3 = Color3.new(0,0,0)
        end
        btn.BorderSizePixel = 2
        btn.BorderColor3 = THEME_COLOR
        activeColorBtn = btn
        SetESPColor(color)
    end)
end
for i, col in ipairs(COLORS) do CreateColorButton(i, col) end
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 460)

-- ========== ESP & AIMBOT ENGINE ==========
-- Hàm raycast an toàn
local function IsTargetVisible(part)
    if not part or not part.Parent then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local rayParams = RaycastParams.new()
    local ignoreList = {LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")}
    rayParams.FilterDescendantsInstances = ignoreList
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    local hit = result.Instance
    local targetChar = part.Parent
    if hit:IsDescendantOf(targetChar) then return true end
    return false
end

-- ESP Data
local espObjects = {}
local function CleanESP(player)
    local data = espObjects[player]
    if data then
        for _, draw in pairs(data) do
            safeRemoveDrawing(draw)
        end
        if data.connection then data.connection:Disconnect() end
        espObjects[player] = nil
    end
end

local function AddESP(player)
    if player == LocalPlayer then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 1; Box.Filled = false; Box.Visible = false
    local Line = Drawing.new("Line")
    Line.Thickness = 1; Line.Visible = false
    local NameText = Drawing.new("Text")
    NameText.Size = 13; NameText.Center = true; NameText.Outline = true; NameText.OutlineColor = Color3.new(0,0,0); NameText.Visible = false
    local HealthBG = Drawing.new("Square")
    HealthBG.Thickness = 1; HealthBG.Filled = true; HealthBG.Color = Color3.fromRGB(0,0,0); HealthBG.Transparency = 0.5; HealthBG.Visible = false
    local HealthFill = Drawing.new("Square")
    HealthFill.Thickness = 0; HealthFill.Filled = true; HealthFill.Visible = false

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not player or not player.Parent then
            CleanESP(player)
            return
        end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not humanoid or not hrp or humanoid.Health <= 0 or not ESP_SETTINGS.Enabled then
            Box.Visible = false; Line.Visible = false; NameText.Visible = false; HealthBG.Visible = false; HealthFill.Visible = false
            return
        end
        local head = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or hrp
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if onScreen and dist <= MAX_DISTANCE then
            local boxHeight = math.clamp(3000/dist, 20, 300)
            local boxWidth = math.clamp(2000/dist, 20, 200)
            local boxTopY = pos.Y - boxHeight/2
            local boxLeftX = pos.X - boxWidth/2
            if ESP_SETTINGS.Box then
                Box.Size = Vector2.new(boxWidth, boxHeight)
                Box.Position = Vector2.new(boxLeftX, boxTopY)
                Box.Color = ESP_COLOR
                Box.Visible = true
            else Box.Visible = false end

            if ESP_SETTINGS.Line then
                Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                Line.To = Vector2.new(pos.X, pos.Y + boxHeight/2)
                Line.Color = ESP_COLOR
                Line.Visible = true
            else Line.Visible = false end

            if ESP_SETTINGS.Name then
                local nameStr = player.Name
                if ESP_SETTINGS.Distance then nameStr = nameStr .. " [" .. math.floor(dist) .. "m]" end
                NameText.Text = nameStr
                NameText.Position = Vector2.new(pos.X, boxTopY - 15)
                NameText.Color = Color3.new(1,1,1)
                NameText.Visible = true
            else NameText.Visible = false end

            if ESP_SETTINGS.Health and humanoid.MaxHealth > 0 then
                local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barWidth = 4
                local barHeight = boxHeight
                local barLeftX = boxLeftX - barWidth - 2
                local barTopY = boxTopY
                HealthBG.Size = Vector2.new(barWidth, barHeight)
                HealthBG.Position = Vector2.new(barLeftX, barTopY)
                HealthBG.Visible = true
                local fillHeight = barHeight * healthRatio
                HealthFill.Size = Vector2.new(barWidth, fillHeight)
                HealthFill.Position = Vector2.new(barLeftX, barTopY + barHeight - fillHeight)
                HealthFill.Color = Color3.fromHSV(healthRatio * 0.33, 1, 1)
                HealthFill.Visible = true
            else
                HealthBG.Visible = false; HealthFill.Visible = false
            end
        else
            Box.Visible = false; Line.Visible = false; NameText.Visible = false
            HealthBG.Visible = false; HealthFill.Visible = false
        end
    end)
    espObjects[player] = {
        Box = Box, Line = Line, Name = NameText,
        HealthBG = HealthBG, HealthFill = HealthFill,
        connection = connection
    }
end

for _, plr in pairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(CleanESP)

-- Xóa toàn bộ khi script bị hủy (reset)
LocalPlayer.CharacterAdded:Connect(function()
    for plr, _ in pairs(espObjects) do CleanESP(plr) end
    for _, plr in pairs(Players:GetPlayers()) do AddESP(plr) end
end)

-- Xóa FOV circle khi script chết
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        safeRemoveDrawing(FOVCircle)
    end
end)

-- ========== AIMBOT với SMOOTH THẬT ==========
local lastAimTarget = nil
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
            local targetPos = targetPart.Position
            local newCF = CFrame.new(Camera.CFrame.Position, targetPos)
            -- Smooth thực tế: alpha = 1 / smooth
            local alpha = math.clamp(1 / AIM_SMOOTH, 0, 1)
            Camera.CFrame = Camera.CFrame:Lerp(newCF, alpha)
        end
    end
end)

-- Thu gọn menu
local collapsed = false
TitleBtn.MouseButton1Click:Connect(function()
    if dragging then return end
    collapsed = not collapsed
    TitleBtn.Text = collapsed and "▶  THE KING CHEAT OFC" or "▼  THE KING CHEAT OFC"
    MainFrame:TweenSize(collapsed and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 350), "Out", "Quad", 0.2, true)
    VersionFrame.Visible = not collapsed
    ContentFrame.Visible = not collapsed
end)

UpdateLanguage()
