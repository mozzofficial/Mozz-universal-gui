--[[ MOZZ UNIVERSAL — Move, Players, ESP, Aimbot ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Cfg = {
    NoClip=false, Fly=false, Speed=16, Jump=50, FlySpeed=80,
    ESP=false, ESP_Color=Color3.fromRGB(255, 50, 50), ESP_Rainbow=false, Chams=false, ESP_Name=true, ESP_Dist=true, ESP_HP=true,
    Aim=false, Aim_FOV=150, Aim_Visible=true, Aim_Smooth=0.25, Draw_FOV=false
}

local Colors = {
    Bg = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(25, 25, 30),
    Text = Color3.fromRGB(230, 230, 240),
    SubText = Color3.fromRGB(150, 150, 160),
    Accent = Color3.fromRGB(0, 170, 255),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    ToggleOn = Color3.fromRGB(80, 200, 80)
}

pcall(function() if CoreGui:FindFirstChild("MozzClean") then CoreGui.MozzClean:Destroy() end end)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozzClean"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ================= Кнопка меню (M) =================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -60)
ToggleBtn.BackgroundColor3 = Colors.Accent
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 18
ToggleBtn.Text = "M"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

-- ================= Кнопка Аима (AIM) =================
local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(0, 50, 0, 50)
AimBtn.Position = UDim2.new(0, 15, 0.5, 0)
AimBtn.BackgroundColor3 = Colors.Panel
AimBtn.TextColor3 = Colors.Text
AimBtn.Font = Enum.Font.GothamBold
AimBtn.TextSize = 14
AimBtn.Text = "AIM"
AimBtn.BorderSizePixel = 0
AimBtn.Parent = ScreenGui
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 12)

-- Основное меню
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 320)
Main.Position = UDim2.new(0.5, -130, 0.5, -160)
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- ================= Драг-хелпер =================
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Логика кнопки меню
local mDragging, mMoved, mStart, mPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = true; mMoved = false; mStart = input.Position; mPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if mDragging and not mMoved then Main.Visible = not Main.Visible end
        mDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if mDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - mStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then mMoved = true end
        if mMoved then ToggleBtn.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + delta.X, mPos.Y.Scale, mPos.Y.Offset + delta.Y) end
    end
end)

-- Логика кнопки AIM
local aDragging, aMoved, aStart, aPos
AimBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        aDragging = true; aMoved = false; aStart = input.Position; aPos = AimBtn.Position
    end
end)
AimBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if aDragging and not aMoved then
            Cfg.Aim = not Cfg.Aim
            AimBtn.BackgroundColor3 = Cfg.Aim and Colors.ToggleOn or Colors.Panel
        end
        aDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if aDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - aStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then aMoved = true end
        if aMoved then AimBtn.Position = UDim2.new(aPos.X.Scale, aPos.X.Offset + delta.X, aPos.Y.Scale, aPos.Y.Offset + delta.Y) end
    end
end)

-- Хедер для перетаскивания меню
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Colors.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
MakeDraggable(Main, Header)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "MOZZ"
Title.TextColor3 = Colors.Text
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.Parent = Header

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, -10, 0, 30)
TabsFrame.Position = UDim2.new(0, 5, 0, 35)
TabsFrame.BackgroundColor3 = Colors.Panel
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = Main
Instance.new("UICorner", TabsFrame).CornerRadius = UDim.new(0, 6)

local Pages = {}
local function MakeTab(name, xScale, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(width, 0, 1, 0)
    btn.Position = UDim2.new(xScale, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Colors.SubText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.Parent = TabsFrame
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -70)
    page.Position = UDim2.new(0, 0, 0, 70)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.Visible = false
    page.Parent = Main
    
    -- Фикс невидимых элементов в скролле
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    page.CanvasSize = UDim2.new(0, 0, 0, 0)

    Pages[name] = {btn=btn, page=page}
    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(Pages) do
            v.page.Visible = (k == name)
            v.btn.TextColor3 = (k == name) and Colors.Accent or Colors.SubText
        end
    end)
    return page
end

local pageMove = MakeTab("Move", 0, 0.25)
local pagePlayers = MakeTab("Players", 0.25, 0.25)
local pageESP = MakeTab("ESP", 0.5, 0.25)
local pageAim = MakeTab("Aim", 0.75, 0.25)

local function CreateToggle(parent, text, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    btn.BackgroundColor3 = Colors.Panel
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 16, 0, 16)
    ind.Position = UDim2.new(1, -25, 0.5, -8)
    ind.BackgroundColor3 = Cfg[key] and Colors.Accent or Colors.ToggleOff
    ind.BorderSizePixel = 0
    ind.Parent = btn
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        Cfg[key] = not Cfg[key]
        ind.BackgroundColor3 = Cfg[key] and Colors.Accent or Colors.ToggleOff
        if callback then callback(Cfg[key]) end
    end)
end

local function CreateInput(parent, text, key)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 60, 0, 24)
    box.Position = UDim2.new(1, -70, 0.5, -12)
    box.BackgroundColor3 = Colors.Bg
    box.TextColor3 = Colors.Accent
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.Text = tostring(Cfg[key])
    box.BorderSizePixel = 0
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text:match("[-%d%.]+"))
        if num then Cfg[key] = num end
        box.Text = tostring(Cfg[key])
    end)
end

-- FOV Circle
local FovCircle = Instance.new("Frame")
FovCircle.Size = UDim2.new(0, Cfg.Aim_FOV * 2, 0, Cfg.Aim_FOV * 2)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke", FovCircle)
fovStroke.Thickness = 2
fovStroke.Color = Colors.Accent
fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Move Tab
CreateToggle(pageMove, "NoClip", "NoClip")
CreateToggle(pageMove, "Fly", "Fly", function(on) if on then startFly() else stopFly() end end)
CreateInput(pageMove, "Speed", "Speed")
CreateInput(pageMove, "Jump", "Jump")
CreateInput(pageMove, "FlySpeed", "FlySpeed")

-- ESP Tab
CreateToggle(pageESP, "Enable ESP", "ESP")
CreateToggle(pageESP, "Chams (Outline)", "Chams")
CreateToggle(pageESP, "Show Name", "ESP_Name")
CreateToggle(pageESP, "Show Distance", "ESP_Dist")
CreateToggle(pageESP, "Show HP", "ESP_HP")
CreateToggle(pageESP, "Rainbow Color", "ESP_Rainbow")

-- Aim Tab
CreateToggle(pageAim, "Enable Aimbot", "Aim", function(on)
    AimBtn.BackgroundColor3 = on and Colors.ToggleOn or Colors.Panel
end)
CreateToggle(pageAim, "Draw FOV", "Draw_FOV", function(on) FovCircle.Visible = on end)
CreateToggle(pageAim, "Visible Check", "Aim_Visible")
CreateInput(pageAim, "FOV Radius", "Aim_FOV")
CreateInput(pageAim, "Smoothness", "Aim_Smooth")

-- ================= Players Tab =================
local SpectateTarget = nil
local function UpdatePlayerList()
    for _, v in ipairs(pagePlayers:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    local playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr)
        end
    end

    table.sort(playerList, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)

    for i, plr in ipairs(playerList) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 32)
        row.Position = UDim2.new(0, 5, 0, (i - 1) * 35)
        row.BackgroundColor3 = Colors.Panel
        row.BorderSizePixel = 0
        row.Parent = pagePlayers
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
        nameLbl.Position = UDim2.new(0, 10, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = plr.Name
        nameLbl.TextColor3 = Colors.Text
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 13
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.Parent = row

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 45, 0, 24)
        tpBtn.Position = UDim2.new(1, -110, 0.5, -12)
        tpBtn.BackgroundColor3 = Colors.Accent
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 11
        tpBtn.Text = "TP"
        tpBtn.BorderSizePixel = 0
        tpBtn.Parent = row
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
        
        tpBtn.MouseButton1Click:Connect(function()
            if plr.Character and LocalPlayer.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and myRoot then
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1)
                end
            end
        end)

        local spBtn = Instance.new("TextButton")
        spBtn.Size = UDim2.new(0, 55, 0, 24)
        spBtn.Position = UDim2.new(1, -60, 0.5, -12)
        spBtn.BackgroundColor3 = SpectateTarget == plr and Colors.ToggleOn or Colors.Bg
        spBtn.TextColor3 = Colors.Text
        spBtn.Font = Enum.Font.GothamBold
        spBtn.TextSize = 11
        spBtn.Text = "Watch"
        spBtn.BorderSizePixel = 0
        spBtn.Parent = row
        Instance.new("UICorner", spBtn).CornerRadius = UDim.new(0, 4)
        
        spBtn.MouseButton1Click:Connect(function()
            if SpectateTarget == plr then
                SpectateTarget = nil
                Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                spBtn.BackgroundColor3 = Colors.Bg
            else
                SpectateTarget = plr
                if plr.Character then
                    local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if tHum then Camera.CameraSubject = tHum end
                end
                UpdatePlayerList()
            end
        end)
    end

    -- Отступ снизу (25 пикселей), чтобы последний элемент не прилипал
    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, 0, 0, 25)
    spacer.BackgroundTransparency = 1
    spacer.Position = UDim2.new(0, 0, 0, #playerList * 35)
    spacer.Parent = pagePlayers
end

UpdatePlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.5) UpdatePlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1) UpdatePlayerList() end)

-- Возврат камеры при смерти/выходе цели
RunService.RenderStepped:Connect(function()
    if SpectateTarget then
        if not SpectateTarget.Character or not SpectateTarget.Character:FindFirstChildOfClass("Humanoid") then
            SpectateTarget = nil
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            UpdatePlayerList()
        end
    end
end)

-- ================= Логика =================
RunService.Stepped:Connect(function()
    if Cfg.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- Fly
local flyConn, flyPos = nil, Vector3.zero
local function getStick()
    local pm = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
    if pm then
        local ok, controls = pcall(function() return require(pm):GetControls() end)
        if ok and controls then return controls:GetMoveVector() end
    end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end

function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    flyPos = hrp.Position
    if flyConn then flyConn:Disconnect() end
    
    flyConn = RunService.Heartbeat:Connect(function(dt) 
        if not Cfg.Fly or not hrp.Parent then 
            if hum then hum.PlatformStand = false end
            flyConn:Disconnect() 
            return 
        end
        local cam = workspace.CurrentCamera
        local move = getStick()
        local dir = Vector3.zero
        
        if move.Magnitude > 0.05 then
            dir = (cam.CFrame.RightVector * move.X) + (cam.CFrame.LookVector * -move.Z)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
        
        if dir.Magnitude > 0 then flyPos += dir.Unit * Cfg.FlySpeed * dt end
        
        hrp.CFrame = CFrame.new(flyPos) * cam.CFrame.Rotation
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end
function stopFly()
    Cfg.Fly = false
    if flyConn then flyConn:Disconnect() end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- Speed / Jump
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if not Cfg.Fly then hum.WalkSpeed = Cfg.Speed end
            hum.UseJumpPower = true
            hum.JumpPower = Cfg.Jump
        end
    end
end)

-- ESP & Aimbot
local ESPCache = {}
local hue = 0

RunService.RenderStepped:Connect(function(dt)
    -- Визуальный круг FOV
    if Cfg.Draw_FOV then
        FovCircle.Size = UDim2.new(0, Cfg.Aim_FOV * 2, 0, Cfg.Aim_FOV * 2)
        FovCircle.Position = UDim2.new(0.5, -Cfg.Aim_FOV, 0.42, -Cfg.Aim_FOV) 
    end

    -- ESP (Мгновенное обновление)
    if not Cfg.ESP then
        for p, data in pairs(ESPCache) do 
            if data.Billboard then data.Billboard:Destroy() end
            if data.Chams then data.Chams:Destroy() end
        end
        ESPCache = {}
    else
        hue = (hue + dt * 0.5) % 1
        local color = Cfg.ESP_Rainbow and Color3.fromHSV(hue, 1, 1) or Cfg.ESP_Color
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                
                if head and hum then
                    if not ESPCache[plr] or not ESPCache[plr].Billboard.Parent then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "MozzBill"
                        bill.Adornee = head
                        bill.Size = UDim2.new(0, 200, 0, 50)
                        bill.StudsOffset = Vector3.new(0, 2, 0)
                        bill.AlwaysOnTop = true
                        bill.Parent = head
                        
                        local name = Instance.new("TextLabel")
                        name.Name = "N"
                        name.Size = UDim2.new(1, 0, 0, 20)
                        name.BackgroundTransparency = 1
                        name.Font = Enum.Font.GothamBold
                        name.TextSize = 14
                        name.TextStrokeTransparency = 0
                        name.Parent = bill
                        
                        local info = Instance.new("TextLabel")
                        info.Name = "I"
                        info.Size = UDim2.new(1, 0, 0, 15)
                        info.Position = UDim2.new(0, 0, 0, 20)
                        info.BackgroundTransparency = 1
                        info.Font = Enum.Font.Gotham
                        info.TextSize = 12
                        info.TextStrokeTransparency = 0
                        info.Parent = bill
                        
                        ESPCache[plr] = {Billboard = bill, Chams = nil}
                    end
                    
                    local data = ESPCache[plr]
                    local bill = data.Billboard
                    
                    local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude) or 0)
                    bill.N.Text = Cfg.ESP_Name and plr.Name or ""
                    bill.N.TextColor3 = color
                    
                    local txt = ""
                    if Cfg.ESP_Dist and Cfg.ESP_HP then txt = dist .. "m | " .. math.floor(hum.Health) .. " HP"
                    elseif Cfg.ESP_Dist then txt = dist .. "m"
                    elseif Cfg.ESP_HP then txt = math.floor(hum.Health) .. " HP" end
                    bill.I.Text = txt
                    bill.I.TextColor3 = color
                    
                    if Cfg.Chams then
                        if not data.Chams or not data.Chams.Parent or data.Chams.Adornee ~= plr.Character then
                            if data.Chams then data.Chams:Destroy() end
                            local hl = Instance.new("Highlight")
                            hl.Adornee = plr.Character
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = plr.Character
                            data.Chams = hl
                        end
                        data.Chams.FillColor = color
                        data.Chams.OutlineColor = color
                    elseif data.Chams then
                        data.Chams:Destroy()
                        data.Chams = nil
                    end
                end
            end
        end
    end

    -- Aimbot (3D FOV)
    if Cfg.Aim then
        local cam = workspace.CurrentCamera
        local myChar = LocalPlayer.Character
        local myHead = myChar and myChar:FindFirstChild("Head")
        if myHead then
            local best, bestDist = nil, math.huge
            local fovAngle = math.rad(Cfg.Aim_FOV / 2)
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local tHead = plr.Character:FindFirstChild("Head")
                    local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if tHead and tHum and tHum.Health > 0 then
                        local dirToTarget = (tHead.Position - cam.CFrame.Position)
                        local dist3D = dirToTarget.Magnitude
                        
                        if dist3D > 0 then
                            local angle = math.acos(math.clamp(cam.CFrame.LookVector:Dot(dirToTarget.Unit), -1, 1))
                            
                            if angle <= fovAngle and dist3D < bestDist then
                                local visible = true
                                if Cfg.Aim_Visible then
                                    local rp = RaycastParams.new()
                                    rp.FilterDescendantsInstances = {cam, myChar, plr.Character}
                                    rp.FilterType = Enum.RaycastFilterType.Exclude
                                    local ray = workspace:Raycast(cam.CFrame.Position, dirToTarget.Unit * dist3D, rp)
                                    if ray and ray.Distance < dist3D then visible = false end
                                end
                                if visible then best, bestDist = tHead, dist3D end
                            end
                        end
                    end
                end
            end
            
            if best then
                local smooth = math.clamp(1 - Cfg.Aim_Smooth, 0.01, 1)
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, best.Position), smooth)
            end
        end
    end
end)
