
--====================================================
-- ORANGE ADMIN V11
-- 7 THEMES | COMMANDS | SEARCHABLE HELP | SETTINGS
-- Client-side effects only
--====================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("OrangeAdminV11")
if old then old:Destroy() end

local themes = {
    Orange = {
        bg=Color3.fromRGB(27,18,16),
        panel=Color3.fromRGB(48,29,24),
        accent=Color3.fromRGB(255,112,25),
        second=Color3.fromRGB(190,35,35),
        text=Color3.fromRGB(255,245,230)
    },
    Legacy = {
        bg=Color3.fromRGB(35,35,35),
        panel=Color3.fromRGB(60,60,60),
        accent=Color3.fromRGB(155,155,155),
        second=Color3.fromRGB(95,95,95),
        text=Color3.fromRGB(255,255,255)
    },
    Blue = {
        bg=Color3.fromRGB(12,22,45),
        panel=Color3.fromRGB(24,45,80),
        accent=Color3.fromRGB(35,130,255),
        second=Color3.fromRGB(15,75,170),
        text=Color3.fromRGB(235,245,255)
    },
    Purple = {
        bg=Color3.fromRGB(30,15,45),
        panel=Color3.fromRGB(55,30,85),
        accent=Color3.fromRGB(165,80,255),
        second=Color3.fromRGB(100,40,180),
        text=Color3.fromRGB(250,235,255)
    },
    Yellow = {
        bg=Color3.fromRGB(40,33,10),
        panel=Color3.fromRGB(75,60,20),
        accent=Color3.fromRGB(255,205,30),
        second=Color3.fromRGB(190,135,0),
        text=Color3.fromRGB(255,250,220)
    },
    Green = {
        bg=Color3.fromRGB(10,35,22),
        panel=Color3.fromRGB(20,65,40),
        accent=Color3.fromRGB(35,210,105),
        second=Color3.fromRGB(15,125,65),
        text=Color3.fromRGB(225,255,235)
    },
    Rainbow = {
        bg=Color3.fromRGB(25,20,35),
        panel=Color3.fromRGB(45,35,65),
        accent=Color3.fromRGB(255,80,160),
        second=Color3.fromRGB(100,80,255),
        text=Color3.fromRGB(255,255,255)
    }
}

local selectedTheme = "Orange"
local theme = themes[selectedTheme]

local settings = {
    autoLoad = false,
    openOnLaunch = true
}

local function loadSettings()
    if type(readfile) ~= "function"
    or type(isfile) ~= "function" then return end

    pcall(function()
        if isfile("OrangeAdminV11.json") then
            local data = HttpService:JSONDecode(
                readfile("OrangeAdminV11.json")
            )
            if themes[data.theme] then
                selectedTheme = data.theme
                theme = themes[selectedTheme]
            end
            settings.autoLoad = data.autoLoad == true
            settings.openOnLaunch = data.openOnLaunch ~= false
        end
    end)
end

local function saveSettings()
    if type(writefile) ~= "function" then return end
    pcall(function()
        writefile("OrangeAdminV11.json", HttpService:JSONEncode({
            theme=selectedTheme,
            autoLoad=settings.autoLoad,
            openOnLaunch=settings.openOnLaunch
        }))
    end)
end

loadSettings()

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    new("UICorner", {CornerRadius=UDim.new(0,radius or 8)}, obj)
end

local function outline(obj, color, thickness)
    local s = obj:FindFirstChildOfClass("UIStroke")
    if not s then
        s = new("UIStroke", {}, obj)
    end
    s.Color = color
    s.Thickness = thickness or 1.5
end

local gui = new("ScreenGui", {
    Name="OrangeAdminV11",
    ResetOnSpawn=false,
    DisplayOrder=100,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling
}, playerGui)

local function label(parent, text, pos, size, fontSize)
    return new("TextLabel", {
        Position=pos,
        Size=size,
        BackgroundTransparency=1,
        Text=text,
        TextColor3=theme.text,
        TextSize=fontSize or 14,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    }, parent)
end

local function button(parent, text, pos, size)
    local b = new("TextButton", {
        Position=pos,
        Size=size,
        BackgroundColor3=theme.panel,
        Text=text,
        TextColor3=theme.text,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        AutoButtonColor=true
    }, parent)
    round(b)
    outline(b, theme.accent)
    return b
end

local function textbox(parent, placeholder, pos, size)
    local t = new("TextBox", {
        Position=pos,
        Size=size,
        BackgroundColor3=theme.panel,
        TextColor3=theme.text,
        PlaceholderColor3=theme.accent,
        PlaceholderText=placeholder,
        Text="",
        TextSize=14,
        Font=Enum.Font.Code,
        ClearTextOnFocus=false
    }, parent)
    round(t)
    outline(t, theme.accent)
    return t
end

local function makeWindow(name, title, size, position)
    local frame = new("Frame", {
        Name=name,
        Size=size,
        Position=position,
        BackgroundColor3=theme.bg,
        BorderSizePixel=0
    }, gui)
    round(frame, 12)
    outline(frame, theme.accent, 2)

    local top = new("Frame", {
        Name="TopBar",
        Size=UDim2.new(1,0,0,46),
        BackgroundColor3=theme.accent,
        BorderSizePixel=0
    }, frame)
    round(top, 12)

    label(top, title,
        UDim2.fromOffset(14,0),
        UDim2.new(1,-65,1,0), 17)

    local close = button(top, "X",
        UDim2.new(1,-42,0,7),
        UDim2.fromOffset(32,32))

    close.MouseButton1Click:Connect(function()
        frame.Visible=false
    end)

    local dragging=false
    local dragStart
    local startPos

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging=true
            dragStart=input.Position
            startPos=frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d=input.Position-dragStart
            frame.Position=UDim2.new(
                startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging=false
        end
    end)

    return frame
end

-- MAIN WINDOW

local main = makeWindow(
    "Main","ORANGE ADMIN V11",
    UDim2.fromOffset(420,390),
    UDim2.new(0.5,-210,0.5,-195)
)

local commandBox = textbox(
    main,"Type a command...",
    UDim2.fromOffset(14,60),
    UDim2.new(1,-28,0,42)
)

local status = label(
    main,"V11 READY",
    UDim2.fromOffset(15,108),
    UDim2.new(1,-30,0,28),13
)
status.TextColor3=theme.accent

local runButton = button(
    main,"RUN COMMAND",
    UDim2.fromOffset(14,143),
    UDim2.new(1,-28,0,38)
)

local helpButton = button(
    main,"HELP",
    UDim2.fromOffset(14,190),
    UDim2.new(0.48,-7,0,36)
)

local settingsButton = button(
    main,"SETTINGS",
    UDim2.new(0.52,0,0,190),
    UDim2.new(0.48,-7,0,36)
)

label(main,"QUICK COMMANDS",
    UDim2.fromOffset(14,238),
    UDim2.new(1,-28,0,20),12)

local quickNames = {
    ";fly",";noclip",";speed 50",
    ";jump 100",";fullbright",";resetfx"
}

for i,cmd in ipairs(quickNames) do
    local col=(i-1)%3
    local row=math.floor((i-1)/3)
    local b=button(main,cmd,
        UDim2.fromOffset(14+col*130,265+row*42),
        UDim2.fromOffset(122,34))
    b.MouseButton1Click:Connect(function()
        commandBox.Text=cmd
    end)
end

-- HELP WINDOW

local help = makeWindow(
    "Help","COMMAND CENTER",
    UDim2.fromOffset(350,440),
    UDim2.new(0.5,220,0.5,-220)
)
help.Visible=false

local search = textbox(
    help,"Search commands...",
    UDim2.fromOffset(12,57),
    UDim2.new(1,-24,0,36)
)

local scroll = new("ScrollingFrame", {
    Position=UDim2.fromOffset(12,103),
    Size=UDim2.new(1,-24,1,-115),
    BackgroundColor3=theme.panel,
    BorderSizePixel=0,
    ScrollBarThickness=5,
    CanvasSize=UDim2.new()
}, help)
round(scroll)

local layout = new("UIListLayout", {
    Padding=UDim.new(0,5),
    SortOrder=Enum.SortOrder.LayoutOrder
}, scroll)

-- SETTINGS WINDOW

local settingsWindow = makeWindow(
    "Settings","SETTINGS",
    UDim2.fromOffset(350,430),
    UDim2.new(0.5,-175,0.5,-215)
)
settingsWindow.Visible=false

label(settingsWindow,"CHOOSE YOUR THEME",
    UDim2.fromOffset(14,58),
    UDim2.new(1,-28,0,25),14)

local themeNames={"Orange","Legacy","Blue","Purple","Yellow","Green","Rainbow"}

local applyTheme

for i,name in ipairs(themeNames) do
    local col=(i-1)%2
    local row=math.floor((i-1)/2)
    local b=button(settingsWindow,name,
        UDim2.fromOffset(14+col*160,92+row*43),
        UDim2.fromOffset(150,35))
    b.MouseButton1Click:Connect(function()
        selectedTheme=name
        theme=themes[name]
        saveSettings()
        applyTheme()
        status.Text="Theme changed to "..name
    end)
end

local autoButton = button(
    settingsWindow,"AUTO LOAD: OFF",
    UDim2.fromOffset(14,260),
    UDim2.new(1,-28,0,38)
)

local openButton = button(
    settingsWindow,"OPEN GUI ON LAUNCH: ON",
    UDim2.fromOffset(14,307),
    UDim2.new(1,-28,0,38)
)

local settingsInfo = label(
    settingsWindow,
    "Auto-load needs executor file support and an auto-execute folder.",
    UDim2.fromOffset(14,355),
    UDim2.new(1,-28,0,48),11
)
settingsInfo.TextWrapped=true

autoButton.MouseButton1Click:Connect(function()
    settings.autoLoad=not settings.autoLoad
    autoButton.Text="AUTO LOAD: "..(settings.autoLoad and "ON" or "OFF")
    saveSettings()
end)

openButton.MouseButton1Click:Connect(function()
    settings.openOnLaunch=not settings.openOnLaunch
    openButton.Text="OPEN GUI ON LAUNCH: "..(settings.openOnLaunch and "ON" or "OFF")
    saveSettings()
end)

-- THEME APPLICATION

applyTheme=function()
    for _,obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("Frame") then
            if obj.Name=="TopBar" then
                obj.BackgroundColor3=theme.accent
            elseif obj.Name=="Main" or obj.Name=="Help"
            or obj.Name=="Settings" then
                obj.BackgroundColor3=theme.bg
            elseif obj.Name=="ScrollingFrame" then
                obj.BackgroundColor3=theme.panel
            end
        elseif obj:IsA("TextButton") then
            obj.BackgroundColor3=theme.panel
            obj.TextColor3=theme.text
            outline(obj,theme.accent)
        elseif obj:IsA("TextBox") then
            obj.BackgroundColor3=theme.panel
            obj.TextColor3=theme.text
            obj.PlaceholderColor3=theme.accent
            outline(obj,theme.accent)
        elseif obj:IsA("TextLabel") then
            obj.TextColor3=theme.text
        elseif obj:IsA("UIStroke") then
            obj.Color=theme.accent
        end
    end
    status.TextColor3=theme.accent
end

-- COMMAND DATABASE

local commandList = {
    {"fly","Toggle flying"},
    {"unfly","Stop flying"},
    {"flyspeed","Set flying speed"},
    {"speed","Set walking speed"},
    {"ws","Walking speed alias"},
    {"walkspeed","Walking speed alias"},
    {"normal","Restore movement"},
    {"jump","Set jump power"},
    {"normaljump","Restore jump power"},
    {"hipheight","Set hip height"},
    {"noclip","Toggle local noclip"},
    {"clip","Restore collisions"},
    {"sit","Sit down"},
    {"unsit","Stand up"},
    {"freeze","Anchor your character"},
    {"unfreeze","Unanchor your character"},
    {"autorotate","Enable autorotation"},
    {"noautorotate","Disable autorotation"},
    {"explode","Local visual explosion"},
    {"fire","Add fire"},
    {"unfire","Remove fire"},
    {"smoke","Add smoke"},
    {"nosmoke","Remove smoke"},
    {"sparkles","Add sparkles"},
    {"unsparkles","Remove sparkles"},
    {"glow","Add highlight"},
    {"unglow","Remove highlight"},
    {"ghost","Translucent character"},
    {"unghost","Remove ghost effect"},
    {"invisible","Hide your character locally"},
    {"visible","Show your character"},
    {"rainbow","Rainbow body colors"},
    {"unrainbow","Stop rainbow colors"},
    {"confetti","Local confetti effect"},
    {"rocket","Launch yourself upwards"},
    {"bighead","Enlarge your head"},
    {"normalhead","Restore head size"},
    {"headless","Hide your head locally"},
    {"spin","Spin your character"},
    {"unspin","Stop spinning"},
    {"fov","Set camera FOV"},
    {"normalfov","Restore camera FOV"},
    {"zoom","Zoom camera"},
    {"unzoom","Restore zoom"},
    {"firstperson","First person camera"},
    {"thirdperson","Third person camera"},
    {"camerareset","Reset camera"},
    {"camoffset","Reset camera offset"},
    {"day","Daytime lighting"},
    {"night","Nighttime lighting"},
    {"fullbright","Bright lighting"},
    {"normalbright","Restore brightness"},
    {"fog","Enable fog"},
    {"nofog","Remove fog"},
    {"dark","Dark lighting"},
    {"brightness","Set brightness"},
    {"clock","Set clock time"},
    {"shadows","Enable shadows"},
    {"noshadows","Disable shadows"},
    {"health","Show health"},
    {"maxhealth","Restore health"},
    {"info","Show player info"},
    {"dance","Dance emote"},
    {"wave","Wave emote"},
    {"point","Point emote"},
    {"laugh","Laugh emote"},
    {"stopdance","Stop animations"},
    {"clear","Clear local effects"},
    {"hidegui","Hide GUI"},
    {"showgui","Show GUI"},
    {"resetfx","Reset local effects"},
    {"resetlighting","Reset lighting"},
    {"rejoin","Try to rejoin server"},
    {"help","Open help"},
    {"cmds","Open help"},
    {"reset","Reset character"}
}

local function refreshHelp()
    for _,v in ipairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local count=0
    local q=string.lower(search.Text)

    for _,item in ipairs(commandList) do
        if string.find(item[1].." "..item[2],q,1,true) then
            count+=1
            local b=button(scroll,
                ";"..item[1].."    |    "..item[2],
                UDim2.new(),UDim2.new(1,-8,0,38))
            b.LayoutOrder=count
            b.TextXAlignment=Enum.TextXAlignment.Left
            b.MouseButton1Click:Connect(function()
                commandBox.Text=";"..item[1]
                status.Text="Selected ;"..item[1]
            end)
        end
    end

    scroll.CanvasSize=UDim2.fromOffset(0,count*43)
end

search:GetPropertyChangedSignal("Text"):Connect(refreshHelp)
refreshHelp()

-- CHARACTER STATE

local function getCharacter()
    local char=player.Character
    if not char then return end
    return char,char:FindFirstChildOfClass("Humanoid"),
        char:FindFirstChild("HumanoidRootPart")
end

local function getHead()
    local char=player.Character
    return char and char:FindFirstChild("Head")
end

local savedSpeed=16
local savedJump=50
local savedHip=0
local savedFov=70
local savedClock=Lighting.ClockTime
local savedBrightness=Lighting.Brightness
local savedFogStart=Lighting.FogStart
local savedFogEnd=Lighting.FogEnd

local flying=false
local flySpeed=80
local noclip=false
local spinning=false
local rainbow=false
local flyConnection
local clipConnection
local spinConnection
local rainbowConnection
local bodyVelocity
local bodyGyro

local function stopFly()
    flying=false
    if flyConnection then flyConnection:Disconnect() flyConnection=nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity=nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro=nil end
end

local function startFly()
    local char,hum,root=getCharacter()
    if not root or not hum then return end
    if flying then stopFly() return end

    flying=true
    bodyVelocity=Instance.new("BodyVelocity")
    bodyVelocity.MaxForce=Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Velocity=Vector3.zero
    bodyVelocity.Parent=root

    bodyGyro=Instance.new("BodyGyro")
    bodyGyro.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bodyGyro.P=1e4
    bodyGyro.Parent=root

    flyConnection=RunService.RenderStepped:Connect(function()
        if not root.Parent then stopFly() return end
        local cam=workspace.CurrentCamera
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.yAxis end
        bodyVelocity.Velocity=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
        bodyGyro.CFrame=cam.CFrame
    end)
end

local function setNoclip(on)
    noclip=on
    if clipConnection then clipConnection:Disconnect() clipConnection=nil end
    if on then
        clipConnection=RunService.Stepped:Connect(function()
            local char=player.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end
        end)
    else
        local char=player.Character
        if char then
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end
    end
end

local function effect(name, class, parent)
    local char=player.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v.Name==name then v:Destroy() end
    end
    local obj=Instance.new(class)
    obj.Name=name
    obj.Parent=parent or char:FindFirstChild("HumanoidRootPart") or char
    return obj
end

local function removeEffect(name)
    local char=player.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v.Name==name then v:Destroy() end
    end
end

local function transparency(value)
    local char=player.Character
    if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
            p.LocalTransparencyModifier=value
        end
    end
end

local function stopSpin()
    spinning=false
    if spinConnection then spinConnection:Disconnect() spinConnection=nil end
end

local function setRainbow(on)
    rainbow=on
    if rainbowConnection then
        rainbowConnection:Disconnect()
        rainbowConnection=nil
    end
    if on then
        local hue=0
        rainbowConnection=RunService.RenderStepped:Connect(function(dt)
            hue=(hue+dt*0.35)%1
            local char=player.Character
            if char then
                for _,p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                        p.Color=Color3.fromHSV(hue,1,1)
                    end
                end
            end
        end)
    end
end

local function resetLighting()
    Lighting.ClockTime=savedClock
    Lighting.Brightness=savedBrightness
    Lighting.FogStart=savedFogStart
    Lighting.FogEnd=savedFogEnd
    Lighting.GlobalShadows=true
    workspace.CurrentCamera.FieldOfView=savedFov
end

-- COMMAND ENGINE

local function execute(raw)
    local args=string.split(string.lower(raw)," ")
    local cmd=(args[1] or ""):gsub("^;","")
    local amount=tonumber(args[2])
    local char,hum,root=getCharacter()
    local head=getHead()

    if cmd=="" then return end

    if cmd=="help" or cmd=="cmds" then
        help.Visible=true

    elseif cmd=="fly" then
        startFly()
        status.Text=flying and "Flying: WASD + Space + Ctrl" or "Fly stopped"

    elseif cmd=="unfly" then
        stopFly()
        status.Text="Fly stopped"

    elseif cmd=="flyspeed" then
        flySpeed=math.clamp(amount or 80,5,250)
        status.Text="Fly speed: "..flySpeed

    elseif cmd=="speed" or cmd=="ws" or cmd=="walkspeed" then
        if hum then hum.WalkSpeed=math.clamp(amount or 50,0,250) end

    elseif cmd=="normal" then
        if hum then
            hum.WalkSpeed=savedSpeed
            hum.UseJumpPower=true
            hum.JumpPower=savedJump
            hum.HipHeight=savedHip
        end

    elseif cmd=="jump" then
        if hum then
            hum.UseJumpPower=true
            hum.JumpPower=math.clamp(amount or 100,0,250)
        end

    elseif cmd=="normaljump" then
        if hum then hum.UseJumpPower=true hum.JumpPower=savedJump end

    elseif cmd=="hipheight" then
        if hum then hum.HipHeight=math.clamp(amount or 5,0,30) end

    elseif cmd=="noclip" then
        setNoclip(not noclip)
        status.Text="Noclip: "..tostring(noclip)

    elseif cmd=="clip" then
        setNoclip(false)

    elseif cmd=="sit" and hum then
        hum.Sit=true

    elseif cmd=="unsit" and hum then
        hum.Sit=false

    elseif cmd=="freeze" and root then
        root.Anchored=true

    elseif cmd=="unfreeze" and root then
        root.Anchored=false

    elseif cmd=="autorotate" and hum then
        hum.AutoRotate=true

    elseif cmd=="noautorotate" and hum then
        hum.AutoRotate=false

    elseif cmd=="explode" and root then
        local e=Instance.new("Explosion")
        e.Position=root.Position
        e.BlastRadius=0
        e.BlastPressure=0
        e.Parent=workspace

    elseif cmd=="fire" and root then
        local f=effect("OAdminFire","Fire",root)
        f.Color=theme.accent
        f.SecondaryColor=theme.second

    elseif cmd=="unfire" then
        removeEffect("OAdminFire")

    elseif cmd=="smoke" and root then
        local s=effect("OAdminSmoke","Smoke",root)
        s.Opacity=0.5

    elseif cmd=="nosmoke" then
        removeEffect("OAdminSmoke")

    elseif cmd=="sparkles" and root then
        effect("OAdminSparkles","Sparkles",root)

    elseif cmd=="unsparkles" then
        removeEffect("OAdminSparkles")

    elseif cmd=="glow" and char then
        local h=effect("OAdminGlow","Highlight",char)
        h.FillColor=theme.accent
        h.OutlineColor=theme.second

    elseif cmd=="unglow" then
        removeEffect("OAdminGlow")

    elseif cmd=="ghost" then
        transparency(0.5)

    elseif cmd=="unghost" or cmd=="visible" then
        transparency(0)

    elseif cmd=="invisible" then
        transparency(1)

    elseif cmd=="rainbow" then
        setRainbow(not rainbow)

    elseif cmd=="unrainbow" then
        setRainbow(false)

    elseif cmd=="confetti" and root then
        local p=effect("OAdminConfetti","ParticleEmitter",root)
        p.Rate=60
        p.Lifetime=NumberRange.new(1,2)
        p.Speed=NumberRange.new(5,12)
        p.SpreadAngle=Vector2.new(180,180)

    elseif cmd=="rocket" and root then
        root.AssemblyLinearVelocity=Vector3.new(0,120,0)

    elseif cmd=="bighead" and head then
        if not head:GetAttribute("OAdminSize") then
            head:SetAttribute("OAdminSize",head.Size)
        end
        head.Size=head:GetAttribute("OAdminSize")*1.8

    elseif cmd=="normalhead" and head then
        local size=head:GetAttribute("OAdminSize")
        if size then head.Size=size end

    elseif cmd=="headless" and head then
        head.LocalTransparencyModifier=1

    elseif cmd=="spin" and root then
        if spinning then return end
        spinning=true
        spinConnection=RunService.Heartbeat:Connect(function(dt)
            if root.Parent then
                root.CFrame=root.CFrame*CFrame.Angles(0,dt*8,0)
            end
        end)

    elseif cmd=="unspin" then
        stopSpin()

    elseif cmd=="fov" then
        workspace.CurrentCamera.FieldOfView=math.clamp(amount or 100,40,120)

    elseif cmd=="normalfov" or cmd=="unzoom" then
        workspace.CurrentCamera.FieldOfView=savedFov

    elseif cmd=="zoom" then
        workspace.CurrentCamera.FieldOfView=35

    elseif cmd=="firstperson" then
        player.CameraMode=Enum.CameraMode.LockFirstPerson

    elseif cmd=="thirdperson" then
        player.CameraMode=Enum.CameraMode.Classic

    elseif cmd=="camerareset" or cmd=="camoffset" then
        if hum then hum.CameraOffset=Vector3.zero end
        workspace.CurrentCamera.FieldOfView=savedFov

    elseif cmd=="day" then
        Lighting.ClockTime=14

    elseif cmd=="night" then
        Lighting.ClockTime=0

    elseif cmd=="fullbright" then
        Lighting.Brightness=3
        Lighting.ClockTime=14
        Lighting.FogEnd=100000
        Lighting.GlobalShadows=false

    elseif cmd=="normalbright" or cmd=="resetlighting" then
        resetLighting()

    elseif cmd=="fog" then
        Lighting.FogStart=0
        Lighting.FogEnd=100

    elseif cmd=="nofog" then
        Lighting.FogEnd=100000

    elseif cmd=="dark" then
        Lighting.Brightness=0

    elseif cmd=="brightness" then
        Lighting.Brightness=math.clamp(amount or 2,0,10)

    elseif cmd=="clock" then
        Lighting.ClockTime=math.clamp(amount or 12,0,24)

    elseif cmd=="shadows" then
        Lighting.GlobalShadows=true

    elseif cmd=="noshadows" then
        Lighting.GlobalShadows=false

    elseif cmd=="health" and hum then
        status.Text="Health: "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
        return

    elseif cmd=="maxhealth" and hum then
        hum.Health=hum.MaxHealth

    elseif cmd=="info" then
        status.Text=player.Name.." | "..player.DisplayName.." | "..player.UserId
        return

    elseif (cmd=="dance" or cmd=="wave" or cmd=="point" or cmd=="laugh") and hum then
        pcall(function() hum:PlayEmote(cmd) end)

    elseif cmd=="stopdance" and hum then
        for _,track in ipairs(hum:GetPlayingAnimationTracks()) do
            track:Stop()
        end

    elseif cmd=="clear" or cmd=="resetfx" then
        removeEffect("OAdminFire")
        removeEffect("OAdminSmoke")
        removeEffect("OAdminSparkles")
        removeEffect("OAdminGlow")
        removeEffect("OAdminConfetti")
        transparency(0)
        setRainbow(false)
        stopSpin()

    elseif cmd=="hidegui" then
        main.Visible=false
        help.Visible=false
        settingsWindow.Visible=false

    elseif cmd=="showgui" then
        main.Visible=true

    elseif cmd=="reset" then
        if hum then hum.Health=0 end

    elseif cmd=="rejoin" then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player)
        end)

    else
        status.Text="Unknown command. Try ;help"
        return
    end

    if cmd~="health" and cmd~="info" then
        status.Text="Executed: ;"..cmd
    end
end

-- BUTTON CONNECTIONS

runButton.MouseButton1Click:Connect(function()
    execute(commandBox.Text)
end)

commandBox.FocusLost:Connect(function(enter)
    if enter then execute(commandBox.Text) end
end)

helpButton.MouseButton1Click:Connect(function()
    help.Visible=not help.Visible
end)

settingsButton.MouseButton1Click:Connect(function()
    settingsWindow.Visible=not settingsWindow.Visible
end)

UIS.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.P then
        main.Visible=not main.Visible
        if not main.Visible then
            help.Visible=false
            settingsWindow.Visible=false
        end
    end
end)

-- RAINBOW THEME ANIMATION

local hue=0
RunService.RenderStepped:Connect(function(dt)
    if selectedTheme=="Rainbow" then
        hue=(hue+dt*0.2)%1
        local color=Color3.fromHSV(hue,0.85,1)
        for _,obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("UIStroke") then
                obj.Color=color
            elseif obj:IsA("Frame") and obj.Name=="TopBar" then
                obj.BackgroundColor3=color
            end
        end
    end
end)

-- CHARACTER RESPAWN CLEANUP

player.CharacterAdded:Connect(function()
    stopFly()
    stopSpin()
    noclip=false
    rainbow=false
end)

applyTheme()
autoButton.Text="AUTO LOAD: "..(settings.autoLoad and "ON" or "OFF")
openButton.Text="OPEN GUI ON LAUNCH: "..(settings.openOnLaunch and "ON" or "OFF")
main.Visible=settings.openOnLaunch

print("ORANGE ADMIN V2 LOADED")
