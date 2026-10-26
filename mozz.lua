--[[ MOZZ v45 — Delta Android (Fixed TP Tool) ]]

if not getgenv then return warn("Delta executor required") end
if getgenv().MozzLoaded then pcall(function() getgenv().MozzGUI:Destroy() end) end
getgenv().MozzLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Cfg = {
    NoClip=false, Fly=false,
    Speed=16, Jump=50, FlySpeed=80,
    Theme="Purple", FollowTarget=nil, SpectateTarget=nil,
    
    -- ESP Settings
    ESP_Enabled=false, ESP_Color=Color3.fromRGB(255, 60, 60),
    ESP_Name=true, ESP_Dist=true, ESP_HP=true,
    ESP_Chams=false, ESP_Rainbow=false,

    -- Aimbot Settings
    Aim_Enabled=false, Aim_FOV=150, Aim_Visible=true, Aim_Smooth=0.25,
    Aim_DrawFOV=false
}

local Themes = {
    Dark    = {bg=Color3.fromRGB(0,0,0),       panel=Color3.fromRGB(20,20,25),    text=Color3.fromRGB(220,220,230), accent=Color3.fromRGB(150,100,255), outline=Color3.fromRGB(90,90,100),   tabs=Color3.fromRGB(35,35,40),   title=Color3.fromRGB(255,255,255), closebtn=Color3.fromRGB(40,40,45),   closetext=Color3.fromRGB(220,220,230), tab_active=Color3.fromRGB(80,80,85),   toggle_bg=Color3.fromRGB(80,80,85),   toggle_text=Color3.fromRGB(255,255,255)},
    Rainbow = {bg=Color3.fromRGB(20,20,25),    panel=Color3.fromRGB(35,35,45),    text=Color3.fromRGB(255,255,255), accent=Color3.fromRGB(255,80,180),  outline=Color3.fromRGB(100,100,120), tabs=Color3.fromRGB(50,50,65),   title=Color3.fromRGB(255,255,255), closebtn=Color3.fromRGB(255,80,180), closetext=Color3.fromRGB(255,255,255), tab_active=Color3.fromRGB(255,80,180), toggle_bg=Color3.fromRGB(255,80,180), toggle_text=Color3.fromRGB(255,255,255)},
    Light   = {bg=Color3.fromRGB(255,255,255), panel=Color3.fromRGB(240,240,245), text=Color3.fromRGB(0,0,0),        accent=Color3.fromRGB(80,80,200),  outline=Color3.fromRGB(150,150,165), tabs=Color3.fromRGB(210,210,220), title=Color3.fromRGB(0,0,0),       closebtn=Color3.fromRGB(210,210,220), closetext=Color3.fromRGB(0,0,0),      tab_active=Color3.fromRGB(180,180,185), toggle_bg=Color3.fromRGB(255,255,255), toggle_text=Color3.fromRGB(0,0,0)},
    Blue    = {bg=Color3.fromRGB(12,20,35),    panel=Color3.fromRGB(20,40,70),    text=Color3.fromRGB(200,225,255), accent=Color3.fromRGB(60,150,255),  outline=Color3.fromRGB(50,90,140),   tabs=Color3.fromRGB(30,55,90),   title=Color3.fromRGB(200,225,255), closebtn=Color3.fromRGB(60,150,255), closetext=Color3.fromRGB(255,255,255), tab_active=Color3.fromRGB(60,150,255), toggle_bg=Color3.fromRGB(60,150,255), toggle_text=Color3.fromRGB(255,255,255)},
    Purple  = {bg=Color3.fromRGB(25,15,35),    panel=Color3.fromRGB(45,25,65),    text=Color3.fromRGB(240,220,255), accent=Color3.fromRGB(180,90,255),  outline=Color3.fromRGB(100,60,130),  tabs=Color3.fromRGB(60,35,85),   title=Color3.fromRGB(240,220,255), closebtn=Color3.fromRGB(180,90,255), closetext=Color3.fromRGB(255,255,255), tab_active=Color3.fromRGB(180,90,255), toggle_bg=Color3.fromRGB(180,90,255), toggle_text=Color3.fromRGB(255,255,255)},
    Red     = {bg=Color3.fromRGB(30,10,10),    panel=Color3.fromRGB(55,18,18),    text=Color3.fromRGB(255,210,210), accent=Color3.fromRGB(255,60,60),   outline=Color3.fromRGB(130,50,50),   tabs=Color3.fromRGB(75,25,25),   title=Color3.fromRGB(255,210,210), closebtn=Color3.fromRGB(255,60,60),  closetext=Color3.fromRGB(255,255,255), tab_active=Color3.fromRGB(255,60,60), toggle_bg=Color3.fromRGB(255,60,60), toggle_text=Color3.fromRGB(255,255,255)},
}

getgenv().MozzRoles = {}
local function tag(obj, role) getgenv().MozzRoles[obj] = role return obj end

-- ==== FORWARD DECLARATIONS (Чтобы избежать ошибок вызова nil) ====
function teleportTo(plr)
    if not plr or not plr.Character then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and tRoot then myRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,3) end
end
function rebuildPlayerList() end
function startFly() end
function stopFly() end
function applySpeed() end
function applyJump() end
-- ================================================================

pcall(function() if CoreGui:FindFirstChild("MozzGUI") then CoreGui.MozzGUI:Destroy() end end)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozzGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui
getgenv().MozzGUI = ScreenGui

local T = Themes[Cfg.Theme]

-- ==== FOV CIRCLE ====
local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.Size = UDim2.new(0, Cfg.Aim_FOV * 2, 0, Cfg.Aim_FOV * 2)
FovCircle.Position = UDim2.new(0.5, -Cfg.Aim_FOV, 0.5, -Cfg.Aim_FOV)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke", FovCircle)
fovStroke.Thickness = 1.5
fovStroke.Color = T.accent
fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tag(fovStroke, "outlineaccent")

-- ==== ПЛАВАЮЩИЕ КНОПКИ ====
local function createDraggable(btn)
    local tDragging = false, tMoved = false, tStart, tPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = true; tMoved = false; tStart = input.Position; tPos = btn.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if tDragging and not tMoved then
                if btn.Name == "Toggle" then Main.Visible = not Main.Visible end
                if btn.Name == "AimBtn" then
                    Cfg.Aim_Enabled = not Cfg.Aim_Enabled
                    btn.BackgroundColor3 = Cfg.Aim_Enabled and Themes[Cfg.Theme].accent or Color3.fromRGB(80,80,90)
                    btn.Text = Cfg.Aim_Enabled and "AIM ON" or "AIM OFF"
                end
            end
            tDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then tMoved = true end
            if tMoved then btn.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset + delta.X, tPos.Y.Scale, tPos.Y.Offset + delta.Y) end
        end
    end)
end

local Toggle = Instance.new("TextButton")
Toggle.Name = "Toggle"
Toggle.Size = UDim2.new(0,52,0,52)
Toggle.Position = UDim2.new(0,14,0.5,-26)
Toggle.BackgroundColor3 = T.toggle_bg
Toggle.TextColor3 = T.toggle_text
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 13
Toggle.Text = "mozz"
Toggle.BorderSizePixel = 0
Toggle.Parent = ScreenGui
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,10)
tag(Toggle, "togglebtn")
local tst = Instance.new("UIStroke", Toggle); tst.Thickness = 1.5; tst.Color = T.outline; tst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(tst, "outline")
createDraggable(Toggle)

local AimBtn = Instance.new("TextButton")
AimBtn.Name = "AimBtn"
AimBtn.Size = UDim2.new(0,52,0,52)
AimBtn.Position = UDim2.new(0,14,0.5,40)
AimBtn.BackgroundColor3 = Color3.fromRGB(80,80,90)
AimBtn.TextColor3 = Color3.new(1,1,1)
AimBtn.Font = Enum.Font.GothamBold
AimBtn.TextSize = 12
AimBtn.Text = "AIM OFF"
AimBtn.BorderSizePixel = 0
AimBtn.Parent = ScreenGui
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0,10)
tag(AimBtn, "togglebtn")
local ast = Instance.new("UIStroke", AimBtn); ast.Thickness = 1.5; ast.Color = T.outline; ast.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(ast, "outline")
createDraggable(AimBtn)

-- ==== МЕНЮ ====
local Main = Instance.new("Frame")
Main.Name = "MozzMain"
Main.Size = UDim2.new(0,270,0,360)
Main.Position = UDim2.new(0.5,-135,0.5,-180)
Main.BackgroundColor3 = T.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
getgenv().MozzMain = Main
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)
tag(Main, "bg")
local stroke = Instance.new("UIStroke", Main); stroke.Color = T.accent; stroke.Thickness = 1.5; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(stroke, "outlineaccent")

local dragging, dragInput, dragStart, startPos
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,38)
Header.BackgroundColor3 = T.panel
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,10)
tag(Header, "panel")
local hst = Instance.new("UIStroke", Header); hst.Thickness = 1.5; hst.Color = T.outline; hst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(hst, "outline")

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1,-50,1,0); Title.Position = UDim2.new(0,12,0,0); Title.BackgroundTransparency = 1; Title.Text = "mozz"; Title.TextColor3 = T.title; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Header; tag(Title, "title")

local Close = Instance.new("TextButton"); Close.Size = UDim2.new(0,26,0,26); Close.Position = UDim2.new(1,-34,0,6); Close.BackgroundColor3 = T.closebtn; Close.TextColor3 = T.closetext; Close.Font = Enum.Font.GothamBold; Close.TextSize = 15; Close.Text = "×"; Close.BorderSizePixel = 0; Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(1,0)
tag(Close, "closebtn")

local TabBar = Instance.new("Frame"); TabBar.Size = UDim2.new(1,-16,0,28); TabBar.Position = UDim2.new(0,8,0,44); TabBar.BackgroundTransparency = 1; TabBar.Parent = Main
local TabLayout = Instance.new("UIListLayout", TabBar); TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0,5)

local Pages = {}
local function makeTab(name, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,0,1,0); btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = T.tabs; btn.TextColor3 = T.text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.Text = " "..name.." "; btn.BorderSizePixel = 0; btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local bst = Instance.new("UIStroke", btn); bst.Thickness = 1.5; bst.Color = T.outline; bst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(bst, "outline")

    local page = Instance.new("ScrollingFrame")
    page.Name = pageName; page.Size = UDim2.new(1,-16,1,-82); page.Position = UDim2.new(0,8,0,78)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0,0,0,0); page.Visible = false; page.Parent = Main
    local lay = Instance.new("UIListLayout", page); lay.Padding = UDim.new(0,5); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Pages[pageName] = {btn=btn, page=page}
    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(Pages) do
            v.page.Visible = (k == pageName)
            local vst = v.btn:FindFirstChildOfClass("UIStroke")
            if k == pageName then
                v.btn.BackgroundColor3 = Themes[Cfg.Theme].tab_active
                v.btn.TextColor3 = (Cfg.Theme == "Light") and Color3.new(0,0,0) or Color3.new(1,1,1)
                if vst then vst.Color = Themes[Cfg.Theme].outline end
            else
                v.btn.BackgroundColor3 = Themes[Cfg.Theme].tabs
                v.btn.TextColor3 = Themes[Cfg.Theme].text
                if vst then vst.Color = Themes[Cfg.Theme].outline end
            end
        end
    end)
    return page
end

local function section(parent, name)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,-20,0,16); l.BackgroundTransparency = 1; l.Text = name
    l.TextColor3 = T.accent; l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = parent; tag(l, "accenttext")
end

local function toggle(parent, text, key, cb)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,-20,0,24); row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6); tag(row, "panel")
    local st = Instance.new("UIStroke", row); st.Thickness = 1.5; st.Color = T.outline; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(st, "outline")

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-55,1,0); lbl.Position = UDim2.new(0,10,0,0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = T.text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row; tag(lbl, "text")

    local isGrey = (Cfg.Theme == "Dark" or Cfg.Theme == "Light")
    local sw = Instance.new("TextButton"); sw.Size = UDim2.new(0,36,0,18); sw.Position = UDim2.new(1,-46,0.5,-9); sw.BackgroundColor3 = Cfg[key] and (isGrey and Color3.fromRGB(120,120,125) or T.accent) or Color3.fromRGB(70,70,80); sw.Text = ""; sw.BorderSizePixel = 0; sw.Parent = row
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
    tag(sw, Cfg[key] and "switch_on" or "switch_off")
    local sst = Instance.new("UIStroke", sw); sst.Thickness = 1.5; sst.Color = T.outline; sst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(sst, "outline")

    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,12,0,12); knob.Position = Cfg[key] and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6); knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0; knob.Parent = sw
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local kst = Instance.new("UIStroke", knob); kst.Thickness = 1.5; kst.Color = Color3.fromRGB(130,130,140); kst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    sw.MouseButton1Click:Connect(function()
        Cfg[key] = not Cfg[key]
        tag(sw, Cfg[key] and "switch_on" or "switch_off")
        local greyCheck = (Cfg.Theme == "Dark" or Cfg.Theme == "Light")
        sw.BackgroundColor3 = Cfg[key] and (greyCheck and Color3.fromRGB(120,120,125) or Themes[Cfg.Theme].accent) or Color3.fromRGB(70,70,80)
        TweenService:Create(knob, TweenInfo.new(0.15), { Position = Cfg[key] and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6) }):Play()
        if cb then cb(Cfg[key]) end
    end)
end

local function input(parent, text, key, cb)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,-20,0,24); row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6); tag(row, "panel")
    local st = Instance.new("UIStroke", row); st.Thickness = 1.5; st.Color = T.outline; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(st, "outline")

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.55,0,1,0); lbl.Position = UDim2.new(0,10,0,0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = T.text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row; tag(lbl, "text")

    local box = Instance.new("TextBox"); box.Size = UDim2.new(0,56,0,18); box.Position = UDim2.new(1,-66,0.5,-9); box.BackgroundColor3 = T.bg; box.TextColor3 = T.text; box.Font = Enum.Font.Gotham; box.TextSize = 11; box.Text = tostring(Cfg[key]); box.ClearTextOnFocus = false; box.BorderSizePixel = 0; box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,5); tag(box, "inputbg")
    local bst = Instance.new("UIStroke", box); bst.Thickness = 1.5; bst.Color = T.outline; bst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(bst, "outline")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then Cfg[key] = n; box.Text = tostring(n); if cb then cb(n) end
        else box.Text = tostring(Cfg[key]) end
    end)
end

local function colorBtn(parent, text, key)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,-20,0,24); row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6); tag(row, "panel")
    local st = Instance.new("UIStroke", row); st.Thickness = 1.5; st.Color = T.outline; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(st, "outline")

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.55,0,1,0); lbl.Position = UDim2.new(0,10,0,0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = T.text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row; tag(lbl, "text")

    local box = Instance.new("TextButton"); box.Size = UDim2.new(0,56,0,18); box.Position = UDim2.new(1,-66,0.5,-9); box.BackgroundColor3 = Cfg[key]; box.Text = ""; box.BorderSizePixel = 0; box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
    local bst = Instance.new("UIStroke", box); bst.Thickness = 1.5; bst.Color = T.outline; bst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(bst, "outline")

    box.MouseButton1Click:Connect(function()
        local colors = {Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 255, 60), Color3.fromRGB(60, 60, 255), Color3.fromRGB(255, 255, 60), Color3.fromRGB(255, 60, 255)}
        local current = Cfg[key]
        local nextColor = colors[1]
        for i, c in ipairs(colors) do if current == c then nextColor = colors[(i % #colors) + 1]; break end end
        Cfg[key] = nextColor
        box.BackgroundColor3 = nextColor
    end)
end

local function button(parent, text, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1,-20,0,24); b.BackgroundColor3 = T.panel; b.TextColor3 = T.text; b.Font = Enum.Font.GothamSemibold; b.TextSize = 11; b.Text = text; b.BorderSizePixel = 0; b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); tag(b, "panel")
    local st = Instance.new("UIStroke", b); st.Thickness = 1.5; st.Color = T.outline; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(st, "outline")
    b.MouseButton1Click:Connect(cb)
    return b
end

local listFrame
local function applyTheme(name)
    Cfg.Theme = name
    local T2 = Themes[name]; if not T2 then return end
    for obj, role in pairs(getgenv().MozzRoles) do
        if obj and obj.Parent then
            if role == "bg" then obj.BackgroundColor3 = T2.bg
            elseif role == "panel" then obj.BackgroundColor3 = T2.panel; if obj:IsA("TextButton") or obj:IsA("TextLabel") then obj.TextColor3 = T2.text end
            elseif role == "text" then obj.TextColor3 = T2.text
            elseif role == "accent" then obj.BackgroundColor3 = T2.accent; if obj:IsA("TextButton") then obj.TextColor3 = Color3.new(1,1,1) end
            elseif role == "accenttext" then obj.TextColor3 = (name == "Light") and Color3.new(0,0,0) or T2.accent
            elseif role == "inputbg" then obj.BackgroundColor3 = T2.bg; obj.TextColor3 = T2.text
            elseif role == "switch_on" then
                if name == "Dark" or name == "Light" then obj.BackgroundColor3 = Color3.fromRGB(120,120,125) else obj.BackgroundColor3 = T2.accent end
            elseif role == "switch_off" then obj.BackgroundColor3 = Color3.fromRGB(70,70,80)
            elseif role == "outline" then obj.Color = T2.outline
            elseif role == "outlineaccent" then obj.Color = T2.accent
            elseif role == "title" then obj.TextColor3 = T2.title
            elseif role == "closebtn" then obj.BackgroundColor3 = T2.closebtn; if obj:IsA("TextButton") then obj.TextColor3 = T2.closetext end
            elseif role == "togglebtn" then obj.BackgroundColor3 = T2.toggle_bg; if obj:IsA("TextButton") then obj.TextColor3 = T2.toggle_text end
            end
        end
    end
    for pageName, v in pairs(Pages) do
        local isActive = v.page.Visible
        local bst = v.btn:FindFirstChildOfClass("UIStroke")
        if isActive then v.btn.BackgroundColor3 = T2.tab_active; v.btn.TextColor3 = (name == "Light") and Color3.new(0,0,0) or Color3.new(1,1,1); if bst then bst.Color = T2.outline end
        else v.btn.BackgroundColor3 = T2.tabs; v.btn.TextColor3 = T2.text; if bst then bst.Color = T2.outline end end
    end
    if listFrame then
        for _, row in ipairs(listFrame:GetChildren()) do
            if row:IsA("Frame") then
                for _, c in ipairs(row:GetChildren()) do
                    if c:IsA("TextButton") then
                        if c.Text == "Follow" then c.BackgroundColor3 = Cfg.FollowTarget and T2.accent or T2.tabs; c.TextColor3 = Cfg.FollowTarget and Color3.new(1,1,1) or T2.text
                        elseif c.Text == "Watch" then c.BackgroundColor3 = Cfg.SpectateTarget and T2.accent or T2.tabs; c.TextColor3 = Cfg.SpectateTarget and Color3.new(1,1,1) or T2.text
                        elseif c.Text == "TP" then c.BackgroundColor3 = T2.tabs; c.TextColor3 = T2.text end
                    end
                end
            end
        end
    end
    AimBtn.BackgroundColor3 = Cfg.Aim_Enabled and T2.accent or Color3.fromRGB(80,80,90)
    fovStroke.Color = T2.accent
end

local function themeRow(parent)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,-20,0,0); row.AutomaticSize = Enum.AutomaticSize.Y; row.BackgroundTransparency = 1; row.Parent = parent
    local lay = Instance.new("UIListLayout", row); lay.FillDirection = Enum.FillDirection.Horizontal; lay.Wraps = true; lay.Padding = UDim.new(0,4)
    for _, tn in ipairs({"Dark","Rainbow","Light","Blue","Purple","Red"}) do
        local tdata = Themes[tn]
        local tb = Instance.new("TextButton"); tb.Size = UDim2.new(0,0,0,24); tb.AutomaticSize = Enum.AutomaticSize.X; tb.BackgroundColor3 = tdata.bg; tb.TextColor3 = tdata.accent; tb.Font = Enum.Font.GothamBold; tb.TextSize = 10; tb.Text = " "..tn.." "; tb.BorderSizePixel = 0; tb.Parent = row
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0,5)
        local tst = Instance.new("UIStroke", tb); tst.Thickness = 1.5; tst.Color = tdata.accent; tst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        tb.MouseButton1Click:Connect(function() applyTheme(tn) end)
    end
end

-- ==== TP TOOL LOGIC ====
local function createTPTool()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("TP_TOOL") then backpack.TP_TOOL:Destroy() end
    
    local tool = Instance.new("Tool")
    tool.Name = "TP_TOOL"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
    
    tool.Parent = backpack
end

-- ==== PAGE: MOVE ====
local movePage = makeTab("Move", "MovementPage")
section(movePage, "Movement")
toggle(movePage, "NoClip", "NoClip")
toggle(movePage, "Fly", "Fly", function(on) if on then startFly() else stopFly() end end)
input(movePage, "Speed", "Speed", function() applySpeed() end)
input(movePage, "Jump", "Jump", function() applyJump() end)
input(movePage, "FlySpeed", "FlySpeed")
section(movePage, "Utility")
button(movePage, "Get TP Tool", function() createTPTool() end)

-- ==== PAGE: PLAYERS ====
local playersPage = makeTab("Players", "PlayersPage")
local topSpacer = Instance.new("Frame"); topSpacer.Size = UDim2.new(1,0,0,10); topSpacer.BackgroundTransparency = 1; topSpacer.Parent = playersPage
section(playersPage, "Online")
listFrame = Instance.new("Frame"); listFrame.Size = UDim2.new(1,0,0,0); listFrame.BackgroundTransparency = 1; listFrame.AutomaticSize = Enum.AutomaticSize.Y; listFrame.Parent = playersPage
local llay = Instance.new("UIListLayout", listFrame); llay.Padding = UDim.new(0,3); llay.HorizontalAlignment = Enum.HorizontalAlignment.Center
local bottomSpacer = Instance.new("Frame"); bottomSpacer.Size = UDim2.new(1,0,0,25); bottomSpacer.BackgroundTransparency = 1; bottomSpacer.Parent = playersPage

-- ==== PAGE: ESP ====
local espPage = makeTab("ESP", "EspPage")
section(espPage, "ESP Settings")
toggle(espPage, "Enable ESP", "ESP_Enabled")
toggle(espPage, "Chams (Outline)", "ESP_Chams")
toggle(espPage, "Show Name", "ESP_Name")
toggle(espPage, "Show Distance", "ESP_Dist")
toggle(espPage, "Show Health", "ESP_HP")
toggle(espPage, "Rainbow Color", "ESP_Rainbow")
colorBtn(espPage, "ESP Color", "ESP_Color")

-- ==== PAGE: AIMBOT ====
local aimPage = makeTab("Aimbot", "AimbotPage")
section(aimPage, "Aimbot Settings")
toggle(aimPage, "Enable Aimbot", "Aim_Enabled", function(on)
    AimBtn.BackgroundColor3 = on and Themes[Cfg.Theme].accent or Color3.fromRGB(80,80,90)
    AimBtn.Text = on and "AIM ON" or "AIM OFF"
end)
toggle(aimPage, "Draw FOV", "Aim_DrawFOV")
toggle(aimPage, "Visible Check", "Aim_Visible")
input(aimPage, "FOV Radius", "Aim_FOV", function(val)
    FovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
    FovCircle.Position = UDim2.new(0.5, -val, 0.5, -val)
end)
input(aimPage, "Smoothness", "Aim_Smooth")

-- ==== PAGE: SETTINGS ====
local settingsPage = makeTab("Settings", "SettingsPage")
section(settingsPage, "Theme")
themeRow(settingsPage)
section(settingsPage, "Utility")
button(settingsPage, "Reset Character", function() local c = LocalPlayer.Character; if c then c:BreakJoints() end end)
button(settingsPage, "Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)

-- ==== LOGIC ====
RunService.Stepped:Connect(function()
    if Cfg.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- ESP Logic
local ESPCache = {}
local function makeESP(plr)
    if plr == LocalPlayer then return end
    local function build()
        local char = plr.Character
        if not char then return end
        if ESPCache[plr] and ESPCache[plr].Billboard then ESPCache[plr].Billboard:Destroy() end
        if ESPCache[plr] and ESPCache[plr].Chams then ESPCache[plr].Chams:Destroy() end

        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end

        local bill = Instance.new("BillboardGui"); bill.Name = "MozzESPBG"; bill.Adornee = head; bill.Size = UDim2.new(0,160,0,32); bill.StudsOffset = Vector3.new(0,2.5,0); bill.AlwaysOnTop = true; bill.Parent = char

        local nameLbl = Instance.new("TextLabel"); nameLbl.Name = "NameLbl"; nameLbl.Size = UDim2.new(1,0,0,16); nameLbl.BackgroundTransparency = 1; nameLbl.Text = plr.Name; nameLbl.TextColor3 = Cfg.ESP_Color; nameLbl.TextStrokeTransparency = 0; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 12; nameLbl.Parent = bill; nameLbl.Visible = Cfg.ESP_Name

        local infoLbl = Instance.new("TextLabel"); infoLbl.Name = "InfoLbl"; infoLbl.Size = UDim2.new(1,0,0,13); infoLbl.Position = UDim2.new(0,0,0,15); infoLbl.BackgroundTransparency = 1; infoLbl.TextColor3 = Cfg.ESP_Color; infoLbl.TextStrokeTransparency = 0; infoLbl.Font = Enum.Font.Gotham; infoLbl.TextSize = 10; infoLbl.Text = ""; infoLbl.Parent = bill; infoLbl.Visible = (Cfg.ESP_Dist or Cfg.ESP_HP)

        local chams = nil
        if Cfg.ESP_Chams then
            chams = Instance.new("Highlight")
            chams.Name = "MozzChams"
            chams.Adornee = char
            chams.FillColor = Cfg.ESP_Color
            chams.FillTransparency = 0.5
            chams.OutlineColor = Cfg.ESP_Color
            chams.OutlineTransparency = 0
            chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            chams.Parent = char
        end

        ESPCache[plr] = {Billboard = bill, Chams = chams}
    end
    build()
    plr.CharacterAdded:Connect(function() ESPCache[plr] = nil; task.wait(1); if Cfg.ESP_Enabled then build() end end)
end

local function clearESP()
    for _, v in pairs(ESPCache) do 
        if v.Billboard then pcall(function() v.Billboard:Destroy() end) end
        if v.Chams then pcall(function() v.Chams:Destroy() end) end
    end 
    ESPCache = {} 
end

local hue = 0
RunService.RenderStepped:Connect(function(dt)
    if not Cfg.ESP_Enabled then
        if next(ESPCache) then clearESP() end
        return
    end
    
    hue = (hue + dt * 0.15) % 1
    local espColor = Cfg.ESP_Rainbow and Color3.fromHSV(hue, 1, 1) or Cfg.ESP_Color

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not ESPCache[p] then makeESP(p) end
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for plr, data in pairs(ESPCache) do
        if data.Billboard and data.Billboard.Parent and myRoot then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                local hp = math.floor(hum.Health); local maxHp = math.floor(hum.MaxHealth)
                local nameLbl = data.Billboard:FindFirstChild("NameLbl")
                local infoLbl = data.Billboard:FindFirstChild("InfoLbl")
                if nameLbl then nameLbl.TextColor3 = espColor; nameLbl.Text = plr.Name; nameLbl.Visible = Cfg.ESP_Name end
                if infoLbl then
                    local txt = ""
                    if Cfg.ESP_Dist and Cfg.ESP_HP then txt = ("%d studs | %d/%d HP"):format(dist, hp, maxHp)
                    elseif Cfg.ESP_Dist then txt = ("%d studs"):format(dist)
                    elseif Cfg.ESP_HP then txt = ("%d/%d HP"):format(hp, maxHp) end
                    infoLbl.Text = txt; infoLbl.TextColor3 = espColor; infoLbl.Visible = (Cfg.ESP_Dist or Cfg.ESP_HP)
                end
            end
        end
        if data.Chams and data.Chams.Parent then
            data.Chams.FillColor = espColor
            data.Chams.OutlineColor = espColor
        end
    end
end)

-- Aimbot Logic
local aimTarget = nil
local mouse = LocalPlayer:GetMouse()
RunService.RenderStepped:Connect(function(dt)
    if Cfg.Aim_DrawFOV and Cfg.Aim_Enabled then FovCircle.Visible = true else FovCircle.Visible = false end

    if not Cfg.Aim_Enabled then aimTarget = nil; return end

    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local bestTarget = nil
    local shortestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local screenPoint, onScreen = cam:WorldToViewportPoint(targetRoot.Position)
                local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude

                if onScreen and dist <= Cfg.Aim_FOV then
                    local isVisible = true
                    if Cfg.Aim_Visible then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {cam, myChar, plr.Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local ray = workspace:Raycast(cam.CFrame.Position, (targetRoot.Position - cam.CFrame.Position).Unit * 500, rayParams)
                        if ray then isVisible = false end
                    end

                    if isVisible and dist < shortestDist then
                        shortestDist = dist
                        bestTarget = targetRoot
                    end
                end
            end
        end
    end

    aimTarget = bestTarget

    if aimTarget then
        local targetPos = aimTarget.Position
        local smoothFactor = math.clamp(1 - Cfg.Aim_Smooth, 0.01, 1)
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), smoothFactor)
    end
end)

function rebuildPlayerList()
    for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local row = Instance.new("Frame"); row.Size = UDim2.new(1,-20,0,26); row.BackgroundColor3 = Themes[Cfg.Theme].panel; row.BorderSizePixel = 0; row.Parent = listFrame
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,6); tag(row, "panel")
            local rst = Instance.new("UIStroke", row); rst.Thickness = 1.5; rst.Color = Themes[Cfg.Theme].outline; rst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(rst, "outline")

            local nLbl = Instance.new("TextLabel"); nLbl.Size = UDim2.new(1,-130,1,0); nLbl.Position = UDim2.new(0,8,0,0); nLbl.BackgroundTransparency = 1; nLbl.Text = plr.Name; nLbl.TextColor3 = Themes[Cfg.Theme].text; nLbl.Font = Enum.Font.GothamSemibold; nLbl.TextSize = 10; nLbl.TextXAlignment = Enum.TextXAlignment.Left; nLbl.TextTruncate = Enum.TextTruncate.AtEnd; nLbl.Parent = row; tag(nLbl, "text")

            local sp = Instance.new("TextButton"); sp.Size = UDim2.new(0,40,0,16); sp.Position = UDim2.new(1,-124,0.5,-8); sp.BackgroundColor3 = (Cfg.SpectateTarget == plr) and Themes[Cfg.Theme].accent or Themes[Cfg.Theme].tabs; sp.TextColor3 = (Cfg.SpectateTarget == plr) and Color3.new(1,1,1) or Themes[Cfg.Theme].text; sp.Font = Enum.Font.GothamBold; sp.TextSize = 8; sp.Text = "Watch"; sp.BorderSizePixel = 0; sp.Parent = row
            Instance.new("UICorner", sp).CornerRadius = UDim.new(0,4)
            local sst = Instance.new("UIStroke", sp); sst.Thickness = 1.5; sst.Color = Themes[Cfg.Theme].outline; sst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(sst, "outline")
            sp.MouseButton1Click:Connect(function()
                if Cfg.SpectateTarget == plr then
                    Cfg.SpectateTarget = nil; local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); Camera.CameraSubject = myHum; Camera.CameraType = Enum.CameraType.Custom
                else
                    Cfg.SpectateTarget = plr; if plr.Character then local tHum = plr.Character:FindFirstChildOfClass("Humanoid"); if tHum then Camera.CameraSubject = tHum; Camera.CameraType = Enum.CameraType.Custom end end
                end
                rebuildPlayerList()
            end)

            local tp = Instance.new("TextButton"); tp.Size = UDim2.new(0,28,0,16); tp.Position = UDim2.new(1,-80,0.5,-8); tp.BackgroundColor3 = Themes[Cfg.Theme].tabs; tp.TextColor3 = Themes[Cfg.Theme].text; tp.Font = Enum.Font.GothamBold; tp.TextSize = 8; tp.Text = "TP"; tp.BorderSizePixel = 0; tp.Parent = row
            Instance.new("UICorner", tp).CornerRadius = UDim.new(0,4); tag(tp, "panel")
            local tst = Instance.new("UIStroke", tp); tst.Thickness = 1.5; tst.Color = Themes[Cfg.Theme].outline; tst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(tst, "outline")
            tp.MouseButton1Click:Connect(function() teleportTo(plr) end)

            local fl = Instance.new("TextButton"); fl.Size = UDim2.new(0,40,0,16); fl.Position = UDim2.new(1,-48,0.5,-8); fl.BackgroundColor3 = (Cfg.FollowTarget == plr) and Themes[Cfg.Theme].accent or Themes[Cfg.Theme].tabs; fl.TextColor3 = (Cfg.FollowTarget == plr) and Color3.new(1,1,1) or Themes[Cfg.Theme].text; fl.Font = Enum.Font.GothamBold; fl.TextSize = 8; fl.Text = "Follow"; fl.BorderSizePixel = 0; fl.Parent = row
            Instance.new("UICorner", fl).CornerRadius = UDim.new(0,4)
            local fst = Instance.new("UIStroke", fl); fst.Thickness = 1.5; fst.Color = Themes[Cfg.Theme].outline; fst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tag(fst, "outline")
            fl.MouseButton1Click:Connect(function()
                if Cfg.FollowTarget == plr then Cfg.FollowTarget = nil else Cfg.FollowTarget = plr end
                rebuildPlayerList()
            end)
        end
    end
end

rebuildPlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.5) rebuildPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1) rebuildPlayerList() end)

-- Fly Logic
local flyConn, flyPos, flyVel, flyActive = nil, Vector3.zero, Vector3.zero, false
local function getMoveVector() local ok, pm = pcall(function() return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")) end); if not ok or not pm then return nil end; local ok2, controls = pcall(function() return pm:GetControls() end); if not ok2 or not controls then return nil end; local ok3, mv = pcall(function() return controls:GetMoveVector() end); if not ok3 then return nil end; return mv end
local hasControlModule = getMoveVector() ~= nil
local function readStick() if hasControlModule then local mv = getMoveVector(); if mv then return mv, true end end; local char = LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); return hum and hum.MoveDirection or Vector3.zero, false end

function startFly()
    local char = LocalPlayer.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid"); if not hrp or not hum then return end
    hum.PlatformStand = true; flyPos = hrp.Position; flyVel = Vector3.zero; flyActive = true
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not Cfg.Fly or not flyActive or not hrp.Parent then
            if hum then hum.PlatformStand = false end; if flyConn then flyConn:Disconnect(); flyConn = nil end; flyActive = false; return
        end
        local camCF = Camera.CFrame; local camLook = camCF.LookVector; local camRight = camCF.RightVector
        local desired = Vector3.zero; local stick, fromControl = readStick()
        if fromControl then
            if stick.Magnitude > 0.05 then desired = camRight * stick.X + camLook * (-stick.Z); if desired.Magnitude > 0 then desired = desired.Unit * math.clamp(stick.Magnitude, 0, 1) end end
        else if stick.Magnitude > 0.05 then desired = stick end end
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then desired += camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then desired -= camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then desired -= camRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then desired += camRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonL2) then desired += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonR2) then desired -= Vector3.yAxis end
        local targetVel = desired.Magnitude > 0 and desired.Unit * Cfg.FlySpeed * math.min(desired.Magnitude, 1) or Vector3.zero
        flyVel = flyVel:Lerp(targetVel, math.clamp(dt * 12, 0, 1)); if flyVel.Magnitude < 0.5 then flyVel = Vector3.zero end
        flyPos += flyVel * dt
        hrp.CFrame = CFrame.new(flyPos) * camCF.Rotation; hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end
function stopFly() Cfg.Fly = false; flyActive = false end

RunService.Heartbeat:Connect(function()
    if Cfg.FollowTarget then
        local tChar = Cfg.FollowTarget.Character; local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid"); local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tChar or not tHum or not tRoot or tHum.Health <= 0 then Cfg.FollowTarget = nil; rebuildPlayerList()
        else local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if myRoot then myRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,3) end end
    end
    if Cfg.SpectateTarget then
        local tChar = Cfg.SpectateTarget.Character; local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if not tChar or not tHum or tHum.Health <= 0 then Cfg.SpectateTarget = nil; local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); Camera.CameraSubject = myHum; Camera.CameraType = Enum.CameraType.Custom; rebuildPlayerList()
        else if Camera.CameraSubject ~= tHum then Camera.CameraSubject = tHum; Camera.CameraType = Enum.CameraType.Custom end end
    end
end)

function applySpeed() local c = LocalPlayer.Character; if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = Cfg.Speed end end end
function applyJump() local c = LocalPlayer.Character; if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.UseJumpPower = true; h.JumpPower = Cfg.Jump end end end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); applySpeed(); applyJump() end)

Toggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Rainbow Cycle
task.spawn(function()
    while getgenv().MozzLoaded do
        if Cfg.Theme == "Rainbow" then
            local t = tick()
            local function hsv(offset, sat, val) return Color3.fromHSV((t * 0.4 + offset) % 1, sat or 0.85, val or 1) end
            for obj, role in pairs(getgenv().MozzRoles) do
                if obj and obj.Parent then
                    if role == "bg" then obj.BackgroundColor3 = hsv(0.0, 0.75, 0.18)
                    elseif role == "panel" then obj.BackgroundColor3 = hsv(0.15, 0.7, 0.28); if obj:IsA("TextButton") or obj:IsA("TextLabel") then obj.TextColor3 = hsv(0.7, 0.9, 1) end
                    elseif role == "text" then obj.TextColor3 = hsv(0.7, 0.9, 1)
                    elseif role == "accent" then obj.BackgroundColor3 = hsv(0.5, 0.9, 1); if obj:IsA("TextButton") then obj.TextColor3 = hsv(0.7, 0.9, 1) end
                    elseif role == "accenttext" then obj.TextColor3 = hsv(0.7, 0.9, 1)
                    elseif role == "inputbg" then obj.BackgroundColor3 = hsv(0.3, 0.75, 0.22); obj.TextColor3 = hsv(0.7, 0.9, 1)
                    elseif role == "switch_on" then obj.BackgroundColor3 = hsv(0.5, 0.9, 1)
                    elseif role == "switch_off" then obj.BackgroundColor3 = hsv(0.15, 0.5, 0.35)
                    elseif role == "outline" then obj.Color = hsv(0.5, 0.7, 0.7)
                    elseif role == "outlineaccent" then obj.Color = hsv(0.5, 0.9, 1)
                    elseif role == "title" then obj.TextColor3 = hsv(0.7, 0.9, 1)
                    elseif role == "closebtn" then obj.BackgroundColor3 = hsv(0.5, 0.9, 1); if obj:IsA("TextButton") then obj.TextColor3 = hsv(0.7, 0.9, 1) end
                    elseif role == "togglebtn" then obj.BackgroundColor3 = hsv(0.5, 0.9, 1); if obj:IsA("TextButton") then obj.TextColor3 = hsv(0.7, 0.9, 1) end
                    end
                end
            end
            for _, v in pairs(Pages) do
                local isActive = v.page.Visible
                local bst = v.btn:FindFirstChildOfClass("UIStroke")
                if isActive then v.btn.BackgroundColor3 = hsv(0.5, 0.9, 1); v.btn.TextColor3 = hsv(0.7, 0.9, 1); if bst then bst.Color = hsv(0.5, 0.9, 1) end
                else v.btn.BackgroundColor3 = hsv(0.15, 0.7, 0.28); v.btn.TextColor3 = hsv(0.7, 0.9, 1); if bst then bst.Color = hsv(0.15, 0.7, 0.28) end end
            end
            if listFrame then
                for _, row in ipairs(listFrame:GetChildren()) do
                    if row:IsA("Frame") then
                        for _, c in ipairs(row:GetChildren()) do
                            if c:IsA("TextButton") then
                                if c.Text == "Follow" then c.BackgroundColor3 = Cfg.FollowTarget and hsv(0.5, 0.9, 1) or hsv(0.15, 0.7, 0.28); c.TextColor3 = Cfg.FollowTarget and Color3.new(1,1,1) or hsv(0.7, 0.9, 1)
                                elseif c.Text == "Watch" then c.BackgroundColor3 = Cfg.SpectateTarget and hsv(0.5, 0.9, 1) or hsv(0.15, 0.7, 0.28); c.TextColor3 = Cfg.SpectateTarget and Color3.new(1,1,1) or hsv(0.7, 0.9, 1)
                                elseif c.Text == "TP" then c.BackgroundColor3 = hsv(0.15, 0.7, 0.28); c.TextColor3 = hsv(0.7, 0.9, 1) end
                            end
                        end
                    end
                end
            end
            AimBtn.BackgroundColor3 = Cfg.Aim_Enabled and hsv(0.5, 0.9, 1) or hsv(0.15, 0.7, 0.28)
        end
        task.wait(0.05)
    end
end)

applyTheme("Purple")
Pages["MovementPage"].btn.BackgroundColor3 = T.tab_active
Pages["MovementPage"].btn.TextColor3 = Color3.new(1,1,1)
local firstBst = Pages["MovementPage"].btn:FindFirstChildOfClass("UIStroke")
if firstBst then firstBst.Color = T.tab_active end
Pages["MovementPage"].page.Visible = true
