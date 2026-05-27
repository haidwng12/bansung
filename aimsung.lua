--[[
    HAI DWNG - AUTO FARM TREO MÁY (Tự tele, tự bắn, không cần làm gì)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInput = game:GetService("VirtualInput")

-- CÀI ĐẶT
local Settings = {
    ESP = false,
    AutoFarm = false,   -- Bật cái này là auto tele + bắn (treo máy)
    AutoTap = false,    -- Chỉ tự bắn khi có địch (không tele)
    TeamCheck = true,
    ShowFOV = false,
    FOV = 450
}
local THEME = Color3.fromRGB(255, 80, 120)
local ACCENT = Color3.fromRGB(0, 255, 200)
local BG = Color3.fromRGB(20, 20, 30)

-- Vòng FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = Settings.FOV
FOVCircle.Visible = false
FOVCircle.Color = ACCENT

-- ========== MENU ==========
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 200, 0, 280)
main.Position = UDim2.new(0.5, -100, 0.5, -140)
main.BackgroundColor3 = BG
main.BackgroundTransparency = 0.1
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME
main.Parent = gui

local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "⚡ AUTO FARM ⚡"
title.TextColor3 = ACCENT
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -10, 1, -40)
content.Position = UDim2.new(0, 5, 0, 35)
content.BackgroundTransparency = 1
content.Parent = main

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, 0, 0, 30)
espBtn.Position = UDim2.new(0, 0, 0, 5)
espBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
espBtn.Text = "👁️ ESP: OFF"
espBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 5)
espBtn.Parent = content

local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(1, 0, 0, 30)
farmBtn.Position = UDim2.new(0, 0, 0, 40)
farmBtn.BackgroundColor3 = Color3.fromRGB(80,200,80)
farmBtn.Text = "⚙️ AUTO FARM: ON"
farmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0, 5)
farmBtn.Parent = content

local tapBtn = Instance.new("TextButton")
tapBtn.Size = UDim2.new(1, 0, 0, 30)
tapBtn.Position = UDim2.new(0, 0, 0, 75)
tapBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
tapBtn.Text = "🔫 AUTO TAP: OFF"
tapBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", tapBtn).CornerRadius = UDim.new(0, 5)
tapBtn.Parent = content

local teamBtn = Instance.new("TextButton")
teamBtn.Size = UDim2.new(1, 0, 0, 30)
teamBtn.Position = UDim2.new(0, 0, 0, 110)
teamBtn.BackgroundColor3 = Color3.fromRGB(80,200,80)
teamBtn.Text = "🚫 TEAM CHECK: ON"
teamBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", teamBtn).CornerRadius = UDim.new(0, 5)
teamBtn.Parent = content

local fovBtn = Instance.new("TextButton")
fovBtn.Size = UDim2.new(1, 0, 0, 30)
fovBtn.Position = UDim2.new(0, 0, 0, 145)
fovBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
fovBtn.Text = "🌀 FOV CIRCLE: OFF"
fovBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fovBtn).CornerRadius = UDim.new(0, 5)
fovBtn.Parent = content

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 15)
fovLabel.Position = UDim2.new(0, 0, 0, 180)
fovLabel.Text = "FOV: 450"
fovLabel.TextColor3 = ACCENT
fovLabel.BackgroundTransparency = 1
fovLabel.TextSize = 9
fovLabel.Parent = content

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, 0, 0, 4)
sliderBg.Position = UDim2.new(0, 0, 0, 198)
sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,70)
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)
sliderBg.Parent = content

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((Settings.FOV - 30) / 420, 0, 1, 0)
sliderFill.BackgroundColor3 = THEME
sliderFill.Parent = sliderBg

local sliderBall = Instance.new("TextButton")
sliderBall.Size = UDim2.new(0, 12, 0, 12)
sliderBall.Position = UDim2.new(1, -6, 0.5, -6)
sliderBall.BackgroundColor3 = ACCENT
Instance.new("UICorner", sliderBall).CornerRadius = UDim.new(1,0)
sliderBall.Parent = sliderFill

local function setFOV(val)
    Settings.FOV = math.clamp(val, 30, 450)
    fovLabel.Text = "FOV: " .. math.floor(Settings.FOV)
    sliderFill.Size = UDim2.new((Settings.FOV - 30) / 420, 0, 1, 0)
    FOVCircle.Radius = Settings.FOV
end

local dragging = false
sliderBall.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
UserInputService.TouchMoved:Connect(function(pos)
    if dragging then
        local rel = (pos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
        setFOV(30 + math.clamp(rel,0,1) * 420)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

espBtn.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    espBtn.BackgroundColor3 = Settings.ESP and Color3.fromRGB(80,200,80) or Color3.fromRGB(40,40,50)
    espBtn.Text = "👁️ ESP: " .. (Settings.ESP and "ON" or "OFF")
end)

farmBtn.MouseButton1Click:Connect(function()
    Settings.AutoFarm = not Settings.AutoFarm
    farmBtn.BackgroundColor3 = Settings.AutoFarm and Color3.fromRGB(80,200,80) or Color3.fromRGB(40,40,50)
    farmBtn.Text = "⚙️ AUTO FARM: " .. (Settings.AutoFarm and "ON" or "OFF")
end)

tapBtn.MouseButton1Click:Connect(function()
    Settings.AutoTap = not Settings.AutoTap
    tapBtn.BackgroundColor3 = Settings.AutoTap and Color3.fromRGB(80,200,80) or Color3.fromRGB(40,40,50)
    tapBtn.Text = "🔫 AUTO TAP: " .. (Settings.AutoTap and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    teamBtn.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(80,200,80) or Color3.fromRGB(40,40,50)
    teamBtn.Text = "🚫 TEAM CHECK: " .. (Settings.TeamCheck and "ON" or "OFF")
end)

fovBtn.MouseButton1Click:Connect(function()
    Settings.ShowFOV = not Settings.ShowFOV
    fovBtn.BackgroundColor3 = Settings.ShowFOV and Color3.fromRGB(80,200,80) or Color3.fromRGB(40,40,50)
    fovBtn.Text = "🌀 FOV CIRCLE: " .. (Settings.ShowFOV and "ON" or "OFF")
end)

-- Kéo thả menu
local dragStart, startPos, dragMenu = nil, nil, false
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        dragMenu = true
        dragStart = i.Position
        startPos = main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragMenu = false end end)
    end
end)
UserInputService.TouchMoved:Connect(function(pos)
    if dragMenu then
        local delta = pos - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== LOGIC ==========
local function isEnemy(p)
    if not Settings.TeamCheck then return true end
    return p.Team ~= LocalPlayer.Team
end

local function getTargetPart(target)
    if not target or not target.Character then return nil end
    return target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart")
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

-- Hàm bắn (dùng VirtualInput và UserInputService dự phòng)
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

-- Auto Tap (chỉ bắn, không tele)
local lastTap = 0
RunService.RenderStepped:Connect(function()
    if Settings.AutoTap and not Settings.AutoFarm then
        if getAnyEnemy() and tick() - lastTap > 0.02 then
            shoot()
            lastTap = tick()
        end
    end
end)

-- Auto Farm (tele + bắn liên tục)
local function autoFarmCycle()
    local target = getAnyEnemy()
    if target and target.Character then
        local aimPart = getTargetPart(target)
        if aimPart and LocalPlayer.Character then
            local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                -- Tele lên đầu địch
                local telePos = aimPart.Position + Vector3.new(0, 2.5, 0)
                myHrp.CFrame = CFrame.new(telePos, aimPart.Position)
                task.wait(0.03)
                -- Bắn 3 phát
                for i = 1, 3 do
                    shoot()
                    task.wait(0.01)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if Settings.AutoFarm then
            autoFarmCycle()
        end
        task.wait(0.05)
    end
end)

-- ========== ESP ==========
local espDrawings = {}
local function refreshESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    if not espDrawings[p] then
                        local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false; box.Color = THEME
                        local name = Drawing.new("Text"); name.Size = 9; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)
                        espDrawings[p] = {box, name}
                    end
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local h = math.clamp(2800/dist, 30, 150)
                    local w = math.clamp(1800/dist, 30, 90)
                    local top = pos.Y - h/2
                    local left = pos.X - w/2
                    espDrawings[p][1].Size = Vector2.new(w, h)
                    espDrawings[p][1].Position = Vector2.new(left, top)
                    espDrawings[p][1].Visible = true
                    espDrawings[p][2].Text = p.Name
                    espDrawings[p][2].Position = Vector2.new(pos.X, top - 8)
                    espDrawings[p][2].Visible = true
                else
                    if espDrawings[p] then
                        espDrawings[p][1].Visible = false
                        espDrawings[p][2].Visible = false
                    end
                end
            else
                if espDrawings[p] then
                    if espDrawings[p][1] then espDrawings[p][1].Visible = false end
                    if espDrawings[p][2] then espDrawings[p][2].Visible = false end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.ESP then
        refreshESP()
    else
        for _, d in pairs(espDrawings) do
            if d[1] then d[1].Visible = false end
            if d[2] then d[2].Visible = false end
        end
    end
    if Settings.ShowFOV and Camera then
        local center = Camera.ViewportSize / 2
        FOVCircle.Position = Vector2.new(center.X, center.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

print("✅ Auto Farm đã sẵn sàng. Bật AUTO FARM, Team Check (ON), vào game, để đấy nó tự tele + bắn liên tục.")
