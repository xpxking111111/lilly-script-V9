-- ═══════════════════════════════════════════════════════════════
--   ✦  l i l l y   v 9
--   Owner: A_Trojanvirus
--   Fixed RMB aimbot · Real in-game chat · Scroll wheels
-- ═══════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService     = game:GetService("SoundService")
local StarterGui       = game:GetService("StarterGui")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local LocalPlayer      = Players.LocalPlayer
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera

-- ── Owner ──────────────────────────────────────────────────────
local OWNER_NAME = "A_Trojanvirus"

-- ── Webhook: pings your Discord when someone opens the script ──
task.spawn(function()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local WEBHOOK = "https://discord.com/api/webhooks/1476671663494926531/vM3ewpFQOpDXtNkm24JQvUYDEW_o0Ki32XL1dAriVqIeEiuVQ8OE5AKkhe_ftK-AMXLw"
        local payload = HttpService:JSONEncode({
            embeds = {{
                title = "✦  lilly v9 opened",
                color = 7864319,
                fields = {
                    { name = "👤 Username", value = Players.LocalPlayer.Name, inline = true },
                    { name = "🎮 Game",     value = game.Name ~= "" and game.Name or "Unknown", inline = true },
                },
                footer = { text = "lilly hub  •  discord.gg/8fq9bZ6c2A" },
            }}
        })
        -- executors use request() not HttpService (HttpService is blocked client-side)
        local fn = request or (syn and syn.request) or (http and http.request) or http_request
        if fn then
            fn({
                Url     = WEBHOOK,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = payload,
            })
        end
    end)
end)

-- ── Character ──────────────────────────────────────────────────
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(c)
    character = c
    task.wait(0.15)
    if flying then pcall(StartFly) end
end)

local function GetRoot()
    return character and character:FindFirstChild("HumanoidRootPart")
end
local function GetHumanoid()
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- ══════════════════════════════════════════════════════════════
-- IN-GAME CHAT  (fires the actual Roblox chat remote so it
-- appears in the top-left chat log, not just a bubble)
-- ══════════════════════════════════════════════════════════════
local function SayInChat(msg)
    -- Method 1: SayMessageRequest remote (works in most games)
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if remote then
            remote:FireServer(msg, "All")
            return
        end
    end)

    -- Method 2: Legacy Players chat method
    pcall(function()
        LocalPlayer:Chat(msg)
    end)

    -- Method 3: TextChatService (newer games)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        local channel = tcs:FindFirstDescendant("RBXGeneral")
            or tcs:FindFirstDescendant("All")
        if channel then
            channel:SendAsync(msg)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- OWNER DETECTION
-- ══════════════════════════════════════════════════════════════
local ownerBillboard = nil

local function CreateOwnerBillboard(targetChar)
    if ownerBillboard then ownerBillboard:Destroy() end
    local head = targetChar:FindFirstChild("Head")
    if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "_OwnerBB"
    bb.Size = UDim2.new(0, 220, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Adornee = head
    bb.Parent = Workspace
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 17
    lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
    lbl.TextStrokeTransparency = 0.15
    lbl.TextStrokeColor3 = Color3.fromRGB(60, 30, 0)
    lbl.Text = "👑  OWNER"
    ownerBillboard = bb
end

local ownerGreeted = false

local function OnOwnerJoined(pl)
    -- Popup notification
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title   = "👑  Owner In Game!",
            Text    = OWNER_NAME .. " has joined. Greeting them!",
            Duration = 8,
        })
    end)

    -- Sound
    local s = Instance.new("Sound", SoundService)
    s.SoundId = "rbxassetid://4612398582"; s:Play()
    s.Ended:Connect(function() s:Destroy() end)

    -- Wait a moment then say hello in actual in-game chat
    task.delay(2, function()
        if not ownerGreeted then
            ownerGreeted = true
            SayInChat("Hello Master " .. OWNER_NAME .. " 👑")
        end
    end)

    -- Owner billboard
    if pl.Character then CreateOwnerBillboard(pl.Character) end
    pl.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        CreateOwnerBillboard(c)
    end)
end

local function CheckOwner()
    for _, pl in pairs(Players:GetPlayers()) do
        if pl.Name == OWNER_NAME and not ownerGreeted then
            OnOwnerJoined(pl)
            return
        end
    end
end

Players.PlayerAdded:Connect(function(pl)
    if pl.Name == OWNER_NAME then
        ownerGreeted = false
        OnOwnerJoined(pl)
    end
end)

Players.PlayerRemoving:Connect(function(pl)
    if pl.Name == OWNER_NAME then
        ownerGreeted = false
        if ownerBillboard then ownerBillboard:Destroy(); ownerBillboard = nil end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Owner Left",
                Text  = OWNER_NAME .. " has left.",
                Duration = 5,
            })
        end)
    end
end)

-- Check on load (owner might already be in game)
task.delay(3, CheckOwner)

-- ══════════════════════════════════════════════════════════════
-- LILLY USER DETECTION
-- Each Lilly client writes their name into a shared Workspace
-- folder. Other Lilly clients read that folder every frame and
-- create a BillboardGui DIRECTLY on the target's Head so it
-- follows them. Parented to Head = always on top of them.
-- Normal players never see it because they never run this code.
-- ══════════════════════════════════════════════════════════════
local LILLY_FOLDER_NAME = "_LillyUsers"
local lillyTags = {}   -- [Player] = BillboardGui

local function GetLillyFolder()
    local f = Workspace:FindFirstChild(LILLY_FOLDER_NAME)
    if not f then
        f = Instance.new("Folder", Workspace)
        f.Name = LILLY_FOLDER_NAME
    end
    return f
end

-- Write our own name into the shared folder so others detect us
local function RegisterSelf()
    pcall(function()
        local folder = GetLillyFolder()
        if not folder:FindFirstChild(LocalPlayer.Name) then
            local sv = Instance.new("StringValue", folder)
            sv.Name  = LocalPlayer.Name
            sv.Value = LocalPlayer.Name
        end
    end)
end

RegisterSelf()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    RegisterSelf()
end)

-- Build the tag and weld it directly to the player's Head
-- BillboardGui parented to Head = only WE see it (client-side)
-- and it automatically follows them since it's on their part
local function MakeLillyTag(pl)
    if pl == LocalPlayer then return end
    local char = pl.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Already tagged and still valid
    if lillyTags[pl] and lillyTags[pl].Parent == head then return end

    -- Remove stale tag
    if lillyTags[pl] then
        pcall(function() lillyTags[pl]:Destroy() end)
        lillyTags[pl] = nil
    end

    -- Parent directly to Head so it moves with the player
    -- Only clients running Lilly create this, so only they see it
    local bb = Instance.new("BillboardGui", head)
    bb.Name           = "_LillyTag"
    bb.Size           = UDim2.new(0, 200, 0, 36)
    bb.StudsOffset    = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop    = true
    bb.LightInfluence = 0
    bb.ResetOnSpawn   = false

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 15
    lbl.TextColor3             = Color3.fromRGB(190, 100, 255)
    lbl.TextStrokeTransparency = 0.2
    lbl.TextStrokeColor3       = Color3.fromRGB(40, 0, 80)
    lbl.Text                   = "✦ LILLY USER"

    lillyTags[pl] = bb
end

local function RemoveLillyTag(pl)
    if lillyTags[pl] then
        pcall(function() lillyTags[pl]:Destroy() end)
        lillyTags[pl] = nil
    end
end

-- Scan the shared folder every 0.5s and tag any Lilly users
task.spawn(function()
    while true do
        task.wait(0.5)
        local folder = Workspace:FindFirstChild(LILLY_FOLDER_NAME)
        if folder then
            for _, sv in pairs(folder:GetChildren()) do
                if sv:IsA("StringValue") then
                    local pl = Players:FindFirstChild(sv.Name)
                    if pl and pl ~= LocalPlayer then
                        MakeLillyTag(pl)
                    end
                end
            end
        end
    end
end)

-- Remove tag + folder entry when a player leaves
Players.PlayerRemoving:Connect(function(pl)
    RemoveLillyTag(pl)
    pcall(function()
        local folder = Workspace:FindFirstChild(LILLY_FOLDER_NAME)
        if folder then
            local sv = folder:FindFirstChild(pl.Name)
            if sv then sv:Destroy() end
        end
    end)
end)

-- Re-create tag after they respawn (new Head instance)
local function HookRespawn(pl)
    if pl == LocalPlayer then return end
    pl.CharacterAdded:Connect(function()
        RemoveLillyTag(pl)   -- next scan will re-create it
    end)
end
for _, pl in pairs(Players:GetPlayers()) do HookRespawn(pl) end
Players.PlayerAdded:Connect(HookRespawn)
-- ── Anti-Fling V2 ──────────────────────────────────────────────
local antiFling     = false
local savedVelocity = Vector3.new()

RunService.Stepped:Connect(function()
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            if antiFling then
                if part.AssemblyAngularVelocity.Magnitude > 50 then
                    pcall(function() part.AssemblyAngularVelocity = Vector3.new(0,0,0) end)
                end
                if part.AssemblyLinearVelocity.Magnitude > 500 then
                    pcall(function() part.AssemblyLinearVelocity = savedVelocity end)
                end
            end
        end
    end
    local root = GetRoot()
    if root and root.AssemblyLinearVelocity.Magnitude < 300 then
        savedVelocity = root.AssemblyLinearVelocity
    end
end)

RunService.Heartbeat:Connect(function()
    if not antiFling or not character then return end
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("Motor6D") and not v.Enabled then
            pcall(function() v.Enabled = true end)
        end
    end
end)

-- ── Network ────────────────────────────────────────────────────
if not getgenv().OrbitNetwork then
    getgenv().OrbitNetwork = true
    LocalPlayer.ReplicationFocus = Workspace
    RunService.Heartbeat:Connect(function()
        pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
    end)
end

-- ── Orbit folder ───────────────────────────────────────────────
local Folder = Instance.new("Folder", Workspace); Folder.Name = "_LillyOrbit"
local GlobalAnchor = Instance.new("Part", Folder)
GlobalAnchor.Anchored = true; GlobalAnchor.CanCollide = false
GlobalAnchor.Transparency = 1; GlobalAnchor.Size = Vector3.new(0.05,0.05,0.05)
Instance.new("Attachment", GlobalAnchor)

-- ── Orbit patterns ─────────────────────────────────────────────
local orbitEnabled=false; local orbitParts={}; local grabbedSet={}
local masterAngle=0; local ORBIT_SPIN=0.6; local orbitRadius=18; local orbitPattern=1

local function PatternHalo(i,n,angle,r)
    local ring=math.floor(i/30);local slot=i%30;local count=math.min(30,n-ring*30)
    local dir=ring%2==0 and 1 or -1;local a=angle*dir+(slot/math.max(count,1))*math.pi*2
    return Vector3.new(math.cos(a)*(r+ring*2.8),(ring-math.floor(n/30)*0.5)*2,math.sin(a)*(r+ring*2.8))
end
local function PatternHelix(i,n,angle,r)
    local strand=i%2;local t=math.floor(i/2)/math.max(n/2,1)
    local a=angle+t*math.pi*6+strand*math.pi
    return Vector3.new(math.cos(a)*r,(t-0.5)*16,math.sin(a)*r)
end
local function PatternStar(i,n,angle,r)
    local layer=math.floor(i/20);local t=(i%20)/math.max(math.min(20,n-layer*20),1)
    local frac=(t*5)%1;local outerR=r+layer*2.2;local innerR=outerR*0.45
    local rad=innerR+(outerR-innerR)*math.abs(math.sin(frac*math.pi))
    local a=angle*(layer%2==0 and 1 or -1)+t*math.pi*2
    return Vector3.new(math.cos(a)*rad,math.sin(angle*2+i*0.3)*1.5,math.sin(a)*rad)
end
local function PatternFigure8(i,n,angle,r)
    local petal=math.floor(i/15);local t=((i%15)/math.max(math.min(15,n-petal*15),1))*math.pi*2
    local pa=angle+petal*(math.pi/4);local scale=r*0.6;local denom=1+math.sin(t)*math.sin(t)
    local lx=scale*math.cos(t)/denom;local lz=scale*math.sin(t)*math.cos(t)/denom
    return Vector3.new(lx*math.cos(pa)-lz*math.sin(pa),math.sin(angle+petal*0.8)*2,lx*math.sin(pa)+lz*math.cos(pa))
end
local patternFns={PatternHalo,PatternHelix,PatternStar,PatternFigure8}

local function SetupPart(v,slotIdx)
    if not v:IsA("BasePart") then return false end
    if v:IsDescendantOf(Folder) or v:IsDescendantOf(Workspace.Terrain) then return false end
    for _,pl in pairs(Players:GetPlayers()) do
        if pl.Character and v:IsDescendantOf(pl.Character) then return false end
    end
    for _,x in pairs(v:GetChildren()) do
        if x:IsA("BodyMover") or x:IsA("Constraint") or x:IsA("Weld") or x:IsA("Motor6D") then
            pcall(function() x:Destroy() end)
        end
    end
    v.Anchored=false;v.CanCollide=false;v.Massless=true
    v.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0)
    local att=Instance.new("Attachment",v);att.Name="_OrbitAtt"
    local torq=Instance.new("Torque",v);torq.Name="_OrbitTorque"
    torq.Torque=Vector3.new(1e8,1e8,1e8);torq.Attachment0=att
    local slotPart=Instance.new("Part",Folder)
    slotPart.Anchored=true;slotPart.CanCollide=false;slotPart.Transparency=1
    slotPart.Size=Vector3.new(0.05,0.05,0.05);slotPart.Name="_Slot_"..slotIdx
    local slotAtt=Instance.new("Attachment",slotPart)
    local align=Instance.new("AlignPosition",v);align.Name="_OrbitAlign"
    align.MaxForce=math.huge;align.MaxVelocity=math.huge;align.Responsiveness=200
    align.Attachment0=att;align.Attachment1=slotAtt
    table.insert(orbitParts,{part=v,slot=slotPart,align=align});grabbedSet[v]=true
    return true
end

local function GrabEntireMap()
    local queue={}
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not grabbedSet[obj] then
            local skip=false
            for _,pl in pairs(Players:GetPlayers()) do
                if pl.Character and obj:IsDescendantOf(pl.Character) then skip=true;break end
            end
            if not skip then table.insert(queue,obj) end
        end
    end
    local idx=1
    local conn; conn=RunService.Heartbeat:Connect(function()
        local p=0
        while idx<=#queue and p<60 do
            local part=queue[idx];idx=idx+1;p=p+1
            if part and part.Parent and not grabbedSet[part] then SetupPart(part,#orbitParts+1) end
        end
        if idx>#queue then conn:Disconnect() end
    end)
end

Workspace.DescendantAdded:Connect(function(v)
    task.defer(function()
        if orbitEnabled and v:IsA("BasePart") and not v.Anchored and not grabbedSet[v] then
            local skip=false
            for _,pl in pairs(Players:GetPlayers()) do
                if pl.Character and v:IsDescendantOf(pl.Character) then skip=true;break end
            end
            if not skip then SetupPart(v,#orbitParts+1) end
        end
    end)
end)

Workspace.DescendantRemoving:Connect(function(v)
    if grabbedSet[v] then
        grabbedSet[v]=nil
        for i,entry in ipairs(orbitParts) do
            if entry.part==v then
                pcall(function() entry.slot:Destroy() end)
                pcall(function() entry.align:Destroy() end)
                table.remove(orbitParts,i);break
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local root=GetRoot();if not root then return end
    GlobalAnchor.CFrame=CFrame.new(root.Position)
    if not orbitEnabled then return end
    masterAngle=masterAngle+ORBIT_SPIN*dt
    local total=#orbitParts;if total==0 then return end
    local fn=patternFns[orbitPattern] or patternFns[1]
    for i,entry in ipairs(orbitParts) do
        if entry.part and entry.part.Parent and entry.slot and entry.slot.Parent then
            entry.slot.CFrame=CFrame.new(root.Position+fn(i-1,total,masterAngle,orbitRadius))
        end
    end
end)

-- ── Flight ─────────────────────────────────────────────────────
local flying=false;local flyBV=nil;local flyBG=nil
local currentWalkSpeed=16
local flySpeed=60
local walkSpeed=16
local jumpPower=50

function StartFly()
    local root=GetRoot();if not root then return end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    flying=true
    flyBV=Instance.new("BodyVelocity",root);flyBV.MaxForce=Vector3.new(1e6,1e6,1e6);flyBV.Velocity=Vector3.zero
    flyBG=Instance.new("BodyGyro",root);flyBG.MaxTorque=Vector3.new(1e6,1e6,1e6);flyBG.P=20000;flyBG.CFrame=root.CFrame
    local hum=GetHumanoid();if hum then hum.PlatformStand=true end
end
local function StopFly()
    flying=false
    if flyBV then pcall(function() flyBV:Destroy() end);flyBV=nil end
    if flyBG then pcall(function() flyBG:Destroy() end);flyBG=nil end
    local hum=GetHumanoid();if hum then hum.PlatformStand=false end
end

RunService.Heartbeat:Connect(function()
    if not flying then return end
    local root=GetRoot();local cam=Camera
    if not root or not cam then return end
    if not flyBV or not flyBV.Parent then StartFly();return end
    local mv=Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv+=cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv-=cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv-=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv+=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv-=Vector3.new(0,1,0) end
    if mv.Magnitude>0 then mv=mv.Unit end
    flyBV.Velocity=mv*flySpeed;flyBG.CFrame=cam.CFrame
end)

-- ── Fling ──────────────────────────────────────────────────────
local flinging=false;local flingBAV=nil;local SPIN_SPEED=999999999

local function StartFling()
    local root=GetRoot();if not root then return end
    flinging=true
    flingBAV=Instance.new("BodyAngularVelocity",root)
    flingBAV.MaxTorque=Vector3.new(0,math.huge,0)
    flingBAV.AngularVelocity=Vector3.new(0,SPIN_SPEED,0)
    flingBAV.P=math.huge
end
local function StopFling()
    flinging=false
    if flingBAV then flingBAV:Destroy();flingBAV=nil end
end
RunService.Heartbeat:Connect(function()
    if not flinging or not flingBAV or not flingBAV.Parent then return end
    flingBAV.AngularVelocity=Vector3.new(0,SPIN_SPEED,0)
end)

-- ── Attach (frame-chase) ───────────────────────────────────────
local attachTarget=nil;local attachRunning=false;local attachConn=nil

local function AttachToPlayer(pl)
    if attachConn then attachConn:Disconnect();attachConn=nil end
    attachTarget=pl;attachRunning=true
    attachConn=RunService.Heartbeat:Connect(function()
        if not attachRunning then return end
        if not pl or not pl.Parent then attachRunning=false;return end
        local myRoot=GetRoot()
        local tChar=pl.Character;if not myRoot or not tChar then return end
        local tRoot=tChar:FindFirstChild("HumanoidRootPart");if not tRoot then return end
        myRoot.CFrame=tRoot.CFrame*CFrame.new(0,0,-2.5)
    end)
end
local function Detach()
    attachRunning=false;attachTarget=nil
    if attachConn then attachConn:Disconnect();attachConn=nil end
end

-- ── Click TP ───────────────────────────────────────────────────
local clickTPEnabled=false

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe or not clickTPEnabled then return end
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local ur=Camera:ScreenPointToRay(input.Position.X,input.Position.Y)
    local hit,pos=Workspace:FindPartOnRayWithIgnoreList(Ray.new(ur.Origin,ur.Direction*1000),{character})
    if hit then
        local root=GetRoot();if not root then return end
        root.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
    end
end)

-- ── Anti-TP ────────────────────────────────────────────────────
local antiTP=false;local lastPos=Vector3.new();local ANTI_TP_DIST=20

RunService.Heartbeat:Connect(function()
    local root=GetRoot();if not root then return end
    if not antiTP then lastPos=root.Position;return end
    if (root.Position-lastPos).Magnitude>ANTI_TP_DIST then
        root.CFrame=CFrame.new(lastPos)
    else lastPos=root.Position end
end)

-- ══════════════════════════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════════════════════════
local espEnabled=false;local espBoxes=false;local espNames=true
local espHealth=true;local espTracers=false;local espDistance=true
local espMaxDist=500
local espHighlight=true

-- Team color mode:
-- espTeamColors = false → everyone gets espEnemyColor (red)
-- espTeamColors = true  → teammates = espTeamColor (blue), enemies = espEnemyColor (red)
local espTeamColors   = false
local espEnemyColor   = Color3.fromRGB(255, 50,  50)   -- red
local espTeamColor    = Color3.fromRGB(50,  120, 255)  -- blue

local espObjects={};local espFolder=Instance.new("Folder",Workspace);espFolder.Name="_LillyESP"

local function WorldToVP(pos)
    local v=Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X,v.Y),v.Z,v.Z>0
end

-- Returns the correct ESP color for a given player
local function ESPCol(pl)
    if espTeamColors then
        -- If we have team info and player is on our team → blue
        if LocalPlayer.Team and pl.Team and pl.Team == LocalPlayer.Team then
            return espTeamColor
        end
        -- Otherwise → red (enemy)
        return espEnemyColor
    end
    -- Team colors off → always red
    return espEnemyColor
end

-- Helper: is this player a teammate?
local function IsTeammate(pl)
    return LocalPlayer.Team ~= nil
        and pl.Team ~= nil
        and pl.Team == LocalPlayer.Team
end

local function CreateESP(pl)
    if pl==LocalPlayer or espObjects[pl] then return end
    local obj={}
    local box=Instance.new("SelectionBox");box.LineThickness=0.07;box.SurfaceTransparency=0.85
    box.Color3=espEnemyColor;box.SurfaceColor3=espEnemyColor;box.Parent=espFolder;obj.box=box
    local hl=Instance.new("Highlight");hl.FillTransparency=0.65;hl.OutlineTransparency=0
    hl.FillColor=espEnemyColor;hl.OutlineColor=espEnemyColor;hl.Parent=espFolder;obj.hl=hl
    local bb=Instance.new("BillboardGui");bb.Size=UDim2.new(0,180,0,58);bb.StudsOffset=Vector3.new(0,3.5,0)
    bb.AlwaysOnTop=true;bb.LightInfluence=0;bb.Parent=espFolder;obj.bb=bb
    local function Lbl(y,sz,col)
        local l=Instance.new("TextLabel",bb);l.Size=UDim2.new(1,0,0,16);l.Position=UDim2.new(0,0,0,y)
        l.BackgroundTransparency=1;l.Font=Enum.Font.GothamBold;l.TextSize=sz
        l.TextStrokeTransparency=0.35;l.TextColor3=col;l.Text="";return l
    end
    obj.nameLbl=Lbl(0,13,Color3.new(1,1,1));obj.hpLbl=Lbl(18,11,Color3.fromRGB(100,255,100))
    obj.distLbl=Lbl(34,10,Color3.fromRGB(180,180,255))
    local tr=Drawing.new("Line");tr.Visible=false;tr.Color=espEnemyColor;tr.Thickness=1.5;tr.Transparency=0.2;obj.tracer=tr
    espObjects[pl]=obj
end

local function RemoveESP(pl)
    local obj=espObjects[pl];if not obj then return end
    pcall(function() obj.box:Destroy() end);pcall(function() obj.hl:Destroy() end)
    pcall(function() obj.bb:Destroy() end);pcall(function() obj.tracer:Remove() end)
    espObjects[pl]=nil
end

local function UpdateESP()
    if not espEnabled then
        for _,obj in pairs(espObjects) do
            obj.box.Adornee=nil;obj.hl.Adornee=nil;obj.bb.Adornee=nil;obj.tracer.Visible=false
        end
        return
    end
    local myRoot=GetRoot()
    for _,pl in pairs(Players:GetPlayers()) do
        if pl~=LocalPlayer then
            if not espObjects[pl] then CreateESP(pl) end
            local obj=espObjects[pl];if not obj then continue end
            local tChar=pl.Character
            if not tChar then obj.box.Adornee=nil;obj.hl.Adornee=nil;obj.bb.Adornee=nil;obj.tracer.Visible=false;continue end
            local tRoot=tChar:FindFirstChild("HumanoidRootPart")
            if not tRoot then obj.box.Adornee=nil;obj.hl.Adornee=nil;obj.bb.Adornee=nil;obj.tracer.Visible=false;continue end
            local dist=myRoot and (tRoot.Position-myRoot.Position).Magnitude or 0
            if dist>espMaxDist then obj.box.Adornee=nil;obj.hl.Adornee=nil;obj.bb.Adornee=nil;obj.tracer.Visible=false;continue end
            local col=ESPCol(pl);local tHum=tChar:FindFirstChildOfClass("Humanoid")
            obj.box.Adornee=espBoxes and tChar or nil;obj.box.Color3=col;obj.box.SurfaceColor3=col
            obj.hl.Adornee=espHighlight and tChar or nil;obj.hl.FillColor=col;obj.hl.OutlineColor=col
            obj.bb.Adornee=tChar
            obj.nameLbl.Visible=espNames;obj.nameLbl.Text=pl.Name;obj.nameLbl.TextColor3=col
            if espHealth and tHum then
                local hp=math.floor(tHum.Health);local mx=math.max(tHum.MaxHealth,1);local pct=hp/mx
                obj.hpLbl.Visible=true;obj.hpLbl.Text="HP "..hp.."/"..math.floor(mx)
                obj.hpLbl.TextColor3=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),50)
            else obj.hpLbl.Visible=false end
            obj.distLbl.Visible=espDistance
            if espDistance then obj.distLbl.Text=math.floor(dist).."m" end
            if espTracers then
                local sp,depth,vis=WorldToVP(tRoot.Position)
                if vis then
                    local vp=Camera.ViewportSize
                    obj.tracer.From=Vector2.new(vp.X/2,vp.Y);obj.tracer.To=sp;obj.tracer.Color=col;obj.tracer.Visible=true
                else obj.tracer.Visible=false end
            else obj.tracer.Visible=false end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ══════════════════════════════════════════════════════════════
-- AIMBOT  (fully fixed — tracks RMB via InputBegan/Ended,
--          projects correctly, locks to exact bone position)
-- ══════════════════════════════════════════════════════════════
local aimbotEnabled   = false
local aimbotSmoothing = 0.08    -- 0 = instant, 0.95 = very slow
local aimbotFOV       = 150     -- screen pixel radius
local aimbotBone      = "Head"
local aimbotTeamCheck = false
local aimbotVisible   = false

-- ── Key picker ─────────────────────────────────────────────────
-- We track hold-state ourselves via InputBegan/Ended so RMB works reliably
local AIM_KEYS = {
    { label="RMB", mouse=true,  btn=Enum.UserInputType.MouseButton2 },
    { label="LMB", mouse=true,  btn=Enum.UserInputType.MouseButton1 },
    { label="E",   mouse=false, key=Enum.KeyCode.E  },
    { label="Q",   mouse=false, key=Enum.KeyCode.Q  },
    { label="F",   mouse=false, key=Enum.KeyCode.F  },
    { label="V",   mouse=false, key=Enum.KeyCode.V  },
    { label="Z",   mouse=false, key=Enum.KeyCode.Z  },
    { label="X",   mouse=false, key=Enum.KeyCode.X  },
}
local aimbotKeyIdx = 1   -- default: RMB
local aimKeyHeld   = false   -- tracked manually

-- Listen to all input events, update aimKeyHeld
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = AIM_KEYS[aimbotKeyIdx]
    if not k then return end
    if k.mouse then
        if input.UserInputType == k.btn then aimKeyHeld = true end
    else
        if input.KeyCode == k.key then aimKeyHeld = true end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local k = AIM_KEYS[aimbotKeyIdx]
    if not k then return end
    if k.mouse then
        if input.UserInputType == k.btn then aimKeyHeld = false end
    else
        if input.KeyCode == k.key then aimKeyHeld = false end
    end
end)

-- When the user changes the key, reset held state
local function SetAimKey(idx)
    aimbotKeyIdx = idx
    aimKeyHeld   = false
end

-- FOV circle
local aimFOVCircle = Drawing.new("Circle")
aimFOVCircle.Radius=aimbotFOV;aimFOVCircle.Thickness=1.8
aimFOVCircle.Color=Color3.fromRGB(255,80,80);aimFOVCircle.Transparency=0.35
aimFOVCircle.Filled=false;aimFOVCircle.Visible=false

-- Target dot
local aimDot = Drawing.new("Circle")
aimDot.Radius=5;aimDot.Thickness=2;aimDot.Color=Color3.fromRGB(255,255,0)
aimDot.Transparency=0;aimDot.Filled=true;aimDot.Visible=false

local function GetAimTarget()
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestTarget = nil
    local bestDist   = aimbotFOV

    for _, pl in pairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        if aimbotTeamCheck and IsTeammate(pl) then continue end
        local tChar = pl.Character; if not tChar then continue end
        local hum = tChar:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        -- Try selected bone, fall back gracefully
        local bone = tChar:FindFirstChild(aimbotBone)
            or tChar:FindFirstChild("Head")
            or tChar:FindFirstChild("UpperTorso")
            or tChar:FindFirstChild("HumanoidRootPart")
        if not bone then continue end

        -- Optional visibility check
        if aimbotVisible then
            local myRoot = GetRoot()
            if myRoot then
                local dir = (bone.Position - myRoot.Position)
                if dir.Magnitude > 0 then
                    local ray = Ray.new(myRoot.Position + dir.Unit * 2, dir.Unit * (dir.Magnitude - 2))
                    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {character, espFolder, Folder})
                    if hit and not hit:IsDescendantOf(tChar) then continue end
                end
            end
        end

        -- Project world position to viewport (returns Vector3: X, Y, Depth)
        local vpPoint = Camera:WorldToViewportPoint(bone.Position)
        -- vpPoint.Z > 0 means in front of camera
        if vpPoint.Z <= 0 then continue end

        local screenPos = Vector2.new(vpPoint.X, vpPoint.Y)
        local d2center  = (screenPos - center).Magnitude

        if d2center < bestDist then
            bestDist   = d2center
            bestTarget = { bone = bone, screenPos = screenPos, worldPos = bone.Position }
        end
    end

    return bestTarget
end

-- The actual aimbot loop runs on RenderStepped so camera updates are smooth
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then
        aimFOVCircle.Visible = false
        aimDot.Visible       = false
        return
    end

    -- Draw FOV circle every frame
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    aimFOVCircle.Position = center
    aimFOVCircle.Radius   = aimbotFOV
    aimFOVCircle.Visible  = true

    -- Only aim when key is held
    if not aimKeyHeld then
        aimDot.Visible = false
        return
    end

    local target = GetAimTarget()
    if not target then
        aimDot.Visible = false
        return
    end

    -- Show dot on target
    aimDot.Position = target.screenPos
    aimDot.Visible  = true

    -- Rotate camera to face the bone's world position
    local camCF   = Camera.CFrame
    local goalCF  = CFrame.new(camCF.Position, target.worldPos)

    if aimbotSmoothing <= 0.01 then
        -- Instant snap
        Camera.CFrame = CFrame.new(camCF.Position, target.worldPos)
    else
        -- Smooth lerp: higher smoothing = slower follow
        -- We use a fixed step so it's frame-rate independent
        Camera.CFrame = camCF:Lerp(goalCF, 1 - aimbotSmoothing)
    end
end)

-- ── Sounds ─────────────────────────────────────────────────────
local function playSound(id)
    local s=Instance.new("Sound",SoundService);s.SoundId="rbxassetid://"..id;s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end
playSound("2865227271")

-- ══════════════════════════════════════════════════════════════
-- GUI
-- ══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LillyV9"; ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local W  = 400
local CH = 330

-- ── Panel ──────────────────────────────────────────────────────
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0,W,0,50)
Panel.Position = UDim2.new(0.5,-W/2, 0.04, 0)
Panel.BackgroundColor3 = Color3.fromRGB(9,5,20)
Panel.BorderSizePixel = 0; Panel.Active = false; Panel.Draggable = false
Panel.ClipsDescendants = false; Panel.Parent = ScreenGui
Instance.new("UICorner",Panel).CornerRadius = UDim.new(0,16)
local _Stroke = Instance.new("UIStroke",Panel)
_Stroke.Color=Color3.fromRGB(100,20,210);_Stroke.Thickness=1.5;_Stroke.Transparency=0.45

-- ── Title bar ──────────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,46)
TitleBar.BackgroundColor3 = Color3.fromRGB(18,5,42)
TitleBar.BorderSizePixel = 0; TitleBar.Active = true; TitleBar.Parent = Panel
Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,16)
local _TBPatch = Instance.new("Frame",TitleBar)
_TBPatch.Size=UDim2.new(1,0,0,16);_TBPatch.Position=UDim2.new(0,0,1,-16)
_TBPatch.BackgroundColor3=Color3.fromRGB(18,5,42);_TBPatch.BorderSizePixel=0
local _TBLine = Instance.new("Frame",TitleBar)
_TBLine.Size=UDim2.new(1,0,0,1);_TBLine.Position=UDim2.new(0,0,1,-1)
_TBLine.BackgroundColor3=Color3.fromRGB(120,30,245);_TBLine.BorderSizePixel=0

local TitleTxt = Instance.new("TextLabel",TitleBar)
TitleTxt.Size=UDim2.new(1,-110,1,0);TitleTxt.Position=UDim2.new(0,14,0,0)
TitleTxt.BackgroundTransparency=1;TitleTxt.Font=Enum.Font.GothamBold;TitleTxt.TextSize=17
TitleTxt.TextColor3=Color3.new(1,1,1);TitleTxt.Text="✦  lilly"
TitleTxt.TextXAlignment=Enum.TextXAlignment.Left

local VerLbl = Instance.new("TextLabel",TitleBar)
VerLbl.Size=UDim2.new(0,32,0,20);VerLbl.Position=UDim2.new(1,-100,0.5,-10)
VerLbl.BackgroundColor3=Color3.fromRGB(80,15,170);VerLbl.BorderSizePixel=0
VerLbl.Font=Enum.Font.GothamBold;VerLbl.TextSize=10;VerLbl.TextColor3=Color3.new(1,1,1)
VerLbl.Text="v9"
Instance.new("UICorner",VerLbl).CornerRadius=UDim.new(0,6)

local minimised = false
local MinBtn = Instance.new("TextButton",TitleBar)
MinBtn.Size=UDim2.new(0,30,0,22);MinBtn.Position=UDim2.new(1,-58,0.5,-11)
MinBtn.BackgroundColor3=Color3.fromRGB(35,10,75);MinBtn.BorderSizePixel=0
MinBtn.Font=Enum.Font.GothamBold;MinBtn.TextSize=15
MinBtn.TextColor3=Color3.fromRGB(190,130,255);MinBtn.Text="–"
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",MinBtn).Color=Color3.fromRGB(80,20,160)

-- ── Tab row (horizontal across top) ────────────────────────────
local TabRow = Instance.new("Frame")
TabRow.Size=UDim2.new(1,-16,0,34);TabRow.Position=UDim2.new(0,8,0,50)
TabRow.BackgroundTransparency=1;TabRow.Parent=Panel

-- ── Content area ───────────────────────────────────────────────
local ContentArea = Instance.new("Frame")
ContentArea.Size=UDim2.new(1,-16,0,CH);ContentArea.Position=UDim2.new(0,8,0,88)
ContentArea.BackgroundColor3=Color3.fromRGB(12,5,28)
ContentArea.BorderSizePixel=0;ContentArea.ClipsDescendants=true;ContentArea.Parent=Panel
Instance.new("UICorner",ContentArea).CornerRadius=UDim.new(0,10)

Panel.Size=UDim2.new(0,W,0,88+CH+8)

-- Wire minimise
MinBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    if minimised then
        TabRow.Visible=false;ContentArea.Visible=false
        Panel.Size=UDim2.new(0,W,0,50)
        MinBtn.Text="▢"
    else
        TabRow.Visible=true;ContentArea.Visible=true
        Panel.Size=UDim2.new(0,W,0,88+CH+8)
        MinBtn.Text="–"
    end
end)

-- ── Key system ────────────────────────────────────────────────
local VALID_KEY   = "489-34"
local SAVE_FILE   = "lilly_key_saved.txt"   -- file executors use to save data
local keyUnlocked = false

-- Check if key was already saved from a previous session
local function IsSaved()
    pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            local saved = readfile(SAVE_FILE)
            if saved and saved:gsub("%s","") == VALID_KEY then
                keyUnlocked = true
            end
        end
    end)
end

local function SaveKey()
    pcall(function()
        if writefile then
            writefile(SAVE_FILE, VALID_KEY)
        end
    end)
end

IsSaved()   -- run immediately on load

-- ── Tab helpers ────────────────────────────────────────────────
local tabs={}; local activeTab=nil

local function SelectTab(name)
    -- Block switching to any tab except "🔑 Key" until unlocked
    if not keyUnlocked and name ~= "🔑 Key" then return end
    activeTab=name
    for _,t in pairs(tabs) do
        local on=t.name==name
        TweenService:Create(t.btn,TweenInfo.new(0.15),{
            BackgroundColor3=on and Color3.fromRGB(88,15,180) or Color3.fromRGB(18,6,42),
            TextColor3=on and Color3.new(1,1,1) or Color3.fromRGB(115,70,185),
            BackgroundTransparency=on and 0 or 0.25,
        }):Play()
        t.scroll.Visible=on
    end
end

-- Each tab gets a ScrollingFrame so all content is scrollable
local function AddTab(name,icon)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,1,1,0);btn.BackgroundColor3=Color3.fromRGB(16,5,38)
    btn.BackgroundTransparency=0.2
    btn.BorderSizePixel=0;btn.Font=Enum.Font.GothamBold;btn.TextSize=11
    btn.TextColor3=Color3.fromRGB(130,80,200);btn.Text=icon.." "..name;btn.Parent=TabRow
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)

    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,0)
    sf.BackgroundTransparency=1
    sf.BorderSizePixel=0
    sf.ScrollBarThickness=4
    sf.ScrollBarImageColor3=Color3.fromRGB(110,25,220)
    sf.CanvasSize=UDim2.new(0,0,0,0)
    sf.ScrollingDirection=Enum.ScrollingDirection.Y
    sf.Visible=false
    sf.Parent=ContentArea

    local entry={name=name,btn=btn,scroll=sf}; table.insert(tabs,entry)
    btn.MouseButton1Click:Connect(function()
        if not keyUnlocked and name ~= "🔑 Key" then
            for _,t in pairs(tabs) do
                if t.name == "🔑 Key" then
                    TweenService:Create(t.btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(140,15,15)}):Play()
                    task.delay(0.2, function()
                        TweenService:Create(t.btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(88,15,180)}):Play()
                    end)
                end
            end
            return
        end
        SelectTab(name); playSound("12221967")
    end)
    return sf
end

-- Key tab first so it appears on the left
local keySF   = AddTab("🔑 Key","")
local miscSF  = AddTab("Misc","⚙️")
local movSF   = AddTab("Move","🏃")
local espSF   = AddTab("ESP","👁")
local aimSF   = AddTab("Aim","🎯")
local plSF    = AddTab("Players","👥")

local function LayoutTabs()
    local n=#tabs;local gap=4
    local btnW=math.floor((W-16-gap*(n-1))/n)
    for i,t in ipairs(tabs) do
        t.btn.Size=UDim2.new(0,btnW,1,0)
        t.btn.Position=UDim2.new(0,(i-1)*(btnW+gap),0,0)
    end
end
LayoutTabs()

-- Content width inside scroll frames
local CW = W - 24   -- usable width inside scrollframe padding

-- ── Widget helpers ─────────────────────────────────────────────
local BTN_H = 36

local function PBtn(parent,text,y,w,x,col)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,w or CW,0,BTN_H);b.Position=UDim2.new(0,x or 8,0,y)
    b.BackgroundColor3=col or Color3.fromRGB(22,7,50);b.BorderSizePixel=0
    b.Font=Enum.Font.GothamBold;b.TextSize=13;b.TextColor3=Color3.fromRGB(210,155,255)
    b.Text=text;b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
    local _bs=Instance.new("UIStroke",b);_bs.Color=Color3.fromRGB(60,15,120);_bs.Thickness=1;_bs.Transparency=0.5
    return b
end

local function PLbl(parent,text,y,col)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0,CW,0,18);l.Position=UDim2.new(0,8,0,y)
    l.BackgroundTransparency=1;l.Font=Enum.Font.Gotham;l.TextSize=12
    l.TextColor3=col or Color3.fromRGB(100,60,160);l.Text=text
    l.TextXAlignment=Enum.TextXAlignment.Left;l.TextWrapped=true;l.Parent=parent
    return l
end

local function PToggle(parent,text,y,def,cb)
    local on=def or false
    local b=PBtn(parent,(on and "✓  " or "    ")..text,y,nil,nil,
        on and Color3.fromRGB(80,14,165) or Color3.fromRGB(22,7,50))
    b.TextXAlignment=Enum.TextXAlignment.Left
    local pad=Instance.new("UIPadding",b);pad.PaddingLeft=UDim.new(0,12)
    b.MouseButton1Click:Connect(function()
        on=not on
        b.Text=(on and "✓  " or "    ")..text
        b.BackgroundColor3=on and Color3.fromRGB(80,14,165) or Color3.fromRGB(22,7,50)
        cb(on);playSound("12221967")
    end)
    return b
end

local function Div(parent,y)
    local d=Instance.new("Frame",parent)
    d.Size=UDim2.new(0,CW,0,1);d.Position=UDim2.new(0,8,0,y)
    d.BackgroundColor3=Color3.fromRGB(50,16,90);d.BorderSizePixel=0
end

-- Helper: set canvas height of a scrollframe to fit all content
local function SetCanvas(sf,h)
    sf.CanvasSize=UDim2.new(0,0,0,h)
end

-- ══════════════════════════════════════════════════════
-- MISC PAGE  (scrollable)
-- ══════════════════════════════════════════════════════
local ToggleBtn    = PBtn(miscSF,"🪐  Orbit  OFF",8)
local AntiTPBtn    = PBtn(miscSF,"🛡️  Anti-TP  OFF",52,nil,nil,Color3.fromRGB(12,26,12))
local AntiFlingBtn = PBtn(miscSF,"🔒  Anti-Fling  OFF",96,nil,nil,Color3.fromRGB(16,16,44))

Div(miscSF,140)
PLbl(miscSF,"Orbit Radius:",146)
local DecBtn=PBtn(miscSF,"◀",166,40,8);DecBtn.TextSize=14
local RadLbl=Instance.new("TextLabel")
RadLbl.Size=UDim2.new(0,CW-88,0,BTN_H);RadLbl.Position=UDim2.new(0,54,0,166)
RadLbl.BackgroundColor3=Color3.fromRGB(14,4,30);RadLbl.Text="Radius: 18"
RadLbl.TextColor3=Color3.fromRGB(215,165,255);RadLbl.Font=Enum.Font.Gotham;RadLbl.TextSize=13
RadLbl.Parent=miscSF;Instance.new("UICorner",RadLbl).CornerRadius=UDim.new(0,9)
local IncBtn=PBtn(miscSF,"▶",166,40,CW-32);IncBtn.TextSize=14

Div(miscSF,212)
PLbl(miscSF,"Pattern:",218)
local patBtns={};local patNames={"Halo","Helix","★ Star","❋ Fig8"}
local patW=math.floor((CW-12)/4)
for i,nm in ipairs(patNames) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,patW,0,28);b.Position=UDim2.new(0,8+(i-1)*(patW+4),0,238)
    b.BackgroundColor3=i==1 and Color3.fromRGB(88,15,180) or Color3.fromRGB(16,5,38)
    b.BorderSizePixel=0;b.Font=Enum.Font.Gotham;b.TextSize=11
    b.TextColor3=Color3.fromRGB(215,160,255);b.Text=nm;b.Parent=miscSF
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7);patBtns[i]=b
end

SetCanvas(miscSF, 276)

-- ══════════════════════════════════════════════════════
-- MOVEMENTS PAGE
-- ══════════════════════════════════════════════════════
local FlyBtn     = PBtn(movSF,"✈️   Fly  OFF",8)

-- Fly speed slider
local fsSliderBG=Instance.new("Frame",movSF)
fsSliderBG.Size=UDim2.new(0,CW,0,36);fsSliderBG.Position=UDim2.new(0,8,0,52)
fsSliderBG.BackgroundColor3=Color3.fromRGB(16,5,38);fsSliderBG.BorderSizePixel=0
Instance.new("UICorner",fsSliderBG).CornerRadius=UDim.new(0,9)

local fsValLbl=Instance.new("TextLabel",fsSliderBG)
fsValLbl.Size=UDim2.new(0,60,1,0);fsValLbl.Position=UDim2.new(0,8,0,0)
fsValLbl.BackgroundTransparency=1;fsValLbl.Font=Enum.Font.GothamBold;fsValLbl.TextSize=12
fsValLbl.TextColor3=Color3.fromRGB(215,165,255);fsValLbl.Text="Fly: 60"
fsValLbl.TextXAlignment=Enum.TextXAlignment.Left

local fsTrackBG=Instance.new("Frame",fsSliderBG)
fsTrackBG.Size=UDim2.new(1,-72,0,6);fsTrackBG.Position=UDim2.new(0,64,0.5,-3)
fsTrackBG.BackgroundColor3=Color3.fromRGB(25,8,55);fsTrackBG.BorderSizePixel=0
Instance.new("UICorner",fsTrackBG).CornerRadius=UDim.new(1,0)

local fsTrackFill=Instance.new("Frame",fsTrackBG)
local fsDefault=(60-10)/(300-10)
fsTrackFill.Size=UDim2.new(fsDefault,0,1,0)
fsTrackFill.BackgroundColor3=Color3.fromRGB(14,86,172);fsTrackFill.BorderSizePixel=0
Instance.new("UICorner",fsTrackFill).CornerRadius=UDim.new(1,0)

local fsKnob=Instance.new("Frame",fsTrackBG)
fsKnob.Size=UDim2.new(0,14,0,14);fsKnob.Position=UDim2.new(fsDefault,-7,0.5,-7)
fsKnob.BackgroundColor3=Color3.new(1,1,1);fsKnob.BorderSizePixel=0
Instance.new("UICorner",fsKnob).CornerRadius=UDim.new(1,0)

local fsMin,fsMax=10,300
local fsSliding=false
fsKnob.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then fsSliding=true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then fsSliding=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if fsSliding and i.UserInputType==Enum.UserInputType.MouseMovement then
        local p=math.clamp((i.Position.X-fsTrackBG.AbsolutePosition.X)/fsTrackBG.AbsoluteSize.X,0,1)
        flySpeed=math.round(fsMin+(fsMax-fsMin)*p)
        fsTrackFill.Size=UDim2.new(p,0,1,0)
        fsKnob.Position=UDim2.new(p,-7,0.5,-7)
        fsValLbl.Text="Fly: "..flySpeed
    end
end)

local FlingBtn   = PBtn(movSF,"🌀  Fling  OFF",140,nil,nil,Color3.fromRGB(50,9,18))
local ClickTPBtn = PBtn(movSF,"🖱️  Click TP  OFF",184,nil,nil,Color3.fromRGB(12,7,44))
PLbl(movSF,"Click anywhere in the world to teleport there.",226)

Div(movSF,256)
PLbl(movSF,"Run Speed:",262)

-- Speed slider
local wsEnabled=false
local wsToggle=PBtn(movSF,"🚶  Speed  OFF",282,nil,nil,Color3.fromRGB(12,26,44))

local wsSliderBG=Instance.new("Frame",movSF)
wsSliderBG.Size=UDim2.new(0,CW,0,36);wsSliderBG.Position=UDim2.new(0,8,0,326)
wsSliderBG.BackgroundColor3=Color3.fromRGB(16,5,38);wsSliderBG.BorderSizePixel=0
Instance.new("UICorner",wsSliderBG).CornerRadius=UDim.new(0,9)

local wsValLbl=Instance.new("TextLabel",wsSliderBG)
wsValLbl.Size=UDim2.new(0,60,1,0);wsValLbl.Position=UDim2.new(0,8,0,0)
wsValLbl.BackgroundTransparency=1;wsValLbl.Font=Enum.Font.GothamBold;wsValLbl.TextSize=12
wsValLbl.TextColor3=Color3.fromRGB(215,165,255);wsValLbl.Text="16"
wsValLbl.TextXAlignment=Enum.TextXAlignment.Left

local wsTrackBG=Instance.new("Frame",wsSliderBG)
wsTrackBG.Size=UDim2.new(1,-72,0,6);wsTrackBG.Position=UDim2.new(0,64,0.5,-3)
wsTrackBG.BackgroundColor3=Color3.fromRGB(25,8,55);wsTrackBG.BorderSizePixel=0
Instance.new("UICorner",wsTrackBG).CornerRadius=UDim.new(1,0)

local wsTrackFill=Instance.new("Frame",wsTrackBG)
wsTrackFill.Size=UDim2.new(0,0,1,0)
wsTrackFill.BackgroundColor3=Color3.fromRGB(108,22,228);wsTrackFill.BorderSizePixel=0
Instance.new("UICorner",wsTrackFill).CornerRadius=UDim.new(1,0)

local wsKnob=Instance.new("Frame",wsTrackBG)
wsKnob.Size=UDim2.new(0,14,0,14);wsKnob.Position=UDim2.new(0,-7,0.5,-7)
wsKnob.BackgroundColor3=Color3.new(1,1,1);wsKnob.BorderSizePixel=0
Instance.new("UICorner",wsKnob).CornerRadius=UDim.new(1,0)

local wsMin,wsMax=8,300
local wsSliding=false
wsKnob.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then wsSliding=true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then wsSliding=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if wsSliding and i.UserInputType==Enum.UserInputType.MouseMovement then
        local p=math.clamp((i.Position.X-wsTrackBG.AbsolutePosition.X)/wsTrackBG.AbsoluteSize.X,0,1)
        currentWalkSpeed=math.round(wsMin+(wsMax-wsMin)*p)
        wsTrackFill.Size=UDim2.new(p,0,1,0)
        wsKnob.Position=UDim2.new(p,-7,0.5,-7)
        wsValLbl.Text=tostring(currentWalkSpeed)
        if wsEnabled then
            local h=GetHumanoid();if h then h.WalkSpeed=currentWalkSpeed end
        end
    end
end)

local wsConn=nil
wsToggle.MouseButton1Click:Connect(function()
    wsEnabled=not wsEnabled
    if wsConn then wsConn:Disconnect();wsConn=nil end
    if wsEnabled then
        wsConn=RunService.Heartbeat:Connect(function()
            local h=GetHumanoid();if h then h.WalkSpeed=currentWalkSpeed end
        end)
        wsToggle.Text="🚶  Speed  ON ✓"
        wsToggle.BackgroundColor3=Color3.fromRGB(14,86,172)
    else
        local h=GetHumanoid();if h then h.WalkSpeed=16 end
        wsToggle.Text="🚶  Speed  OFF"
        wsToggle.BackgroundColor3=Color3.fromRGB(12,26,44)
    end
    playSound("12221967")
end)

SetCanvas(movSF, 378)

-- ══════════════════════════════════════════════════════
-- ESP PAGE
-- ══════════════════════════════════════════════════════
PLbl(espSF,"👁   ESP Settings",8,Color3.fromRGB(210,145,255))
local ESPBtn=PBtn(espSF,"👁  ESP  OFF",28)

Div(espSF,72)

-- Team Color mode toggle — blue teammates, red enemies
local TeamESPToggle = PBtn(espSF,"🔵 Team Colors  OFF",78,nil,nil,Color3.fromRGB(20,30,80))
TeamESPToggle.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UIPadding",TeamESPToggle).PaddingLeft = UDim.new(0,12)

-- Color legend labels
local legendFrame = Instance.new("Frame",espSF)
legendFrame.Size=UDim2.new(0,CW,0,26);legendFrame.Position=UDim2.new(0,8,0,120)
legendFrame.BackgroundColor3=Color3.fromRGB(10,3,22);legendFrame.BorderSizePixel=0
Instance.new("UICorner",legendFrame).CornerRadius=UDim.new(0,7)

local legendTeam=Instance.new("TextLabel",legendFrame)
legendTeam.Size=UDim2.new(0.5,0,1,0);legendTeam.Position=UDim2.new(0,0,0,0)
legendTeam.BackgroundTransparency=1;legendTeam.Font=Enum.Font.GothamBold;legendTeam.TextSize=12
legendTeam.TextColor3=Color3.fromRGB(50,120,255);legendTeam.Text="🔵  Teammate"
legendTeam.TextXAlignment=Enum.TextXAlignment.Center

local legendEnemy=Instance.new("TextLabel",legendFrame)
legendEnemy.Size=UDim2.new(0.5,0,1,0);legendEnemy.Position=UDim2.new(0.5,0,0,0)
legendEnemy.BackgroundTransparency=1;legendEnemy.Font=Enum.Font.GothamBold;legendEnemy.TextSize=12
legendEnemy.TextColor3=Color3.fromRGB(255,50,50);legendEnemy.Text="🔴  Enemy"
legendEnemy.TextXAlignment=Enum.TextXAlignment.Center

TeamESPToggle.MouseButton1Click:Connect(function()
    espTeamColors = not espTeamColors
    if espTeamColors then
        TeamESPToggle.Text = "🔵 Team Colors  ON ✓"
        TeamESPToggle.BackgroundColor3 = Color3.fromRGB(15,55,160)
    else
        TeamESPToggle.Text = "🔵 Team Colors  OFF"
        TeamESPToggle.BackgroundColor3 = Color3.fromRGB(20,30,80)
    end
    playSound("12221967")
end)

Div(espSF,154)
PToggle(espSF,"Highlight / Character Glow",160,true,function(v) espHighlight=v end)
PToggle(espSF,"Box Outline",204,false,function(v) espBoxes=v end)
PToggle(espSF,"Names",248,true,function(v) espNames=v end)
PToggle(espSF,"Health Bars",292,true,function(v) espHealth=v end)
PToggle(espSF,"Tracers",336,false,function(v) espTracers=v end)
PToggle(espSF,"Distance",380,true,function(v) espDistance=v end)

SetCanvas(espSF, 426)

-- ══════════════════════════════════════════════════════
-- AIMBOT PAGE
-- ══════════════════════════════════════════════════════
PLbl(aimSF,"🎯  Aimbot Settings",8,Color3.fromRGB(210,145,255))
local AimBtn=PBtn(aimSF,"🎯  Aimbot  OFF",28)

Div(aimSF,72)
PLbl(aimSF,"Hold Key to Aim:",78)

-- Key picker buttons (2 rows of 4)
local keyBtns={}
local kW=math.floor((CW-12)/4)
for i,k in ipairs(AIM_KEYS) do
    local row = i <= 4 and 0 or 1
    local col = (i-1) % 4
    local yOff = 98 + row * 36
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,kW,0,28);b.Position=UDim2.new(0,8+col*(kW+4),0,yOff)
    b.BackgroundColor3=i==1 and Color3.fromRGB(88,15,180) or Color3.fromRGB(16,5,38)
    b.BorderSizePixel=0;b.Font=Enum.Font.GothamBold;b.TextSize=12
    b.TextColor3=Color3.fromRGB(215,160,255);b.Text=k.label;b.Parent=aimSF
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7);keyBtns[i]=b
    b.MouseButton1Click:Connect(function()
        SetAimKey(i)
        for j,kb in ipairs(keyBtns) do
            kb.BackgroundColor3=j==i and Color3.fromRGB(88,15,180) or Color3.fromRGB(16,5,38)
        end
        playSound("12221967")
    end)
end

Div(aimSF,176)
PLbl(aimSF,"Target Bone:",182)

-- Bone picker
local boneBtns={}
local boneNames={"Head","UpperTorso","Torso","Root"}
local boneActual={"Head","UpperTorso","Torso","HumanoidRootPart"}
local bW=math.floor((CW-12)/4)
for i,nm in ipairs(boneNames) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,bW,0,28);b.Position=UDim2.new(0,8+(i-1)*(bW+4),0,202)
    b.BackgroundColor3=i==1 and Color3.fromRGB(88,15,180) or Color3.fromRGB(16,5,38)
    b.BorderSizePixel=0;b.Font=Enum.Font.Gotham;b.TextSize=11
    b.TextColor3=Color3.fromRGB(215,160,255);b.Text=nm;b.Parent=aimSF
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7);boneBtns[i]=b
    b.MouseButton1Click:Connect(function()
        aimbotBone=boneActual[i]
        for j,bb in ipairs(boneBtns) do
            bb.BackgroundColor3=j==i and Color3.fromRGB(88,15,180) or Color3.fromRGB(16,5,38)
        end
        playSound("12221967")
    end)
end

Div(aimSF,240)
PToggle(aimSF,"Team Check (skip allies)",246,false,function(v) aimbotTeamCheck=v end)
PToggle(aimSF,"Visible Only (no wallbang)",290,false,function(v) aimbotVisible=v end)

Div(aimSF,334)
local fovLbl=PLbl(aimSF,"FOV Radius: 150 px",340)
local fovDec=PBtn(aimSF,"◀",360,40,8);fovDec.TextSize=14
local fovValLbl=Instance.new("TextLabel")
fovValLbl.Size=UDim2.new(0,CW-88,0,BTN_H);fovValLbl.Position=UDim2.new(0,54,0,360)
fovValLbl.BackgroundColor3=Color3.fromRGB(14,4,30);fovValLbl.Text="150 px"
fovValLbl.TextColor3=Color3.fromRGB(215,165,255);fovValLbl.Font=Enum.Font.Gotham;fovValLbl.TextSize=13
fovValLbl.Parent=aimSF;Instance.new("UICorner",fovValLbl).CornerRadius=UDim.new(0,9)
local fovInc=PBtn(aimSF,"▶",360,40,CW-32);fovInc.TextSize=14

fovDec.MouseButton1Click:Connect(function()
    aimbotFOV=math.max(30,aimbotFOV-10);aimFOVCircle.Radius=aimbotFOV
    fovValLbl.Text=aimbotFOV.." px";fovLbl.Text="FOV Radius: "..aimbotFOV.." px";playSound("12221967")
end)
fovInc.MouseButton1Click:Connect(function()
    aimbotFOV=math.min(700,aimbotFOV+10);aimFOVCircle.Radius=aimbotFOV
    fovValLbl.Text=aimbotFOV.." px";fovLbl.Text="FOV Radius: "..aimbotFOV.." px";playSound("12221967")
end)

Div(aimSF,408)
local smLbl=PLbl(aimSF,"Smoothing: 8%  (lower = snappier)",414)
local smDec=PBtn(aimSF,"◀",434,40,8);smDec.TextSize=14
local smValLbl=Instance.new("TextLabel")
smValLbl.Size=UDim2.new(0,CW-88,0,BTN_H);smValLbl.Position=UDim2.new(0,54,0,434)
smValLbl.BackgroundColor3=Color3.fromRGB(14,4,30);smValLbl.Text="8%"
smValLbl.TextColor3=Color3.fromRGB(215,165,255);smValLbl.Font=Enum.Font.Gotham;smValLbl.TextSize=13
smValLbl.Parent=aimSF;Instance.new("UICorner",smValLbl).CornerRadius=UDim.new(0,9)
local smInc=PBtn(aimSF,"▶",434,40,CW-32);smInc.TextSize=14

smDec.MouseButton1Click:Connect(function()
    aimbotSmoothing=math.max(0,math.floor(aimbotSmoothing*100+0.5)-5)/100
    smValLbl.Text=math.floor(aimbotSmoothing*100).."%"
    smLbl.Text="Smoothing: "..math.floor(aimbotSmoothing*100).."%  (lower = snappier)"
    playSound("12221967")
end)
smInc.MouseButton1Click:Connect(function()
    aimbotSmoothing=math.min(0.95,math.floor(aimbotSmoothing*100+0.5)+5)/100
    smValLbl.Text=math.floor(aimbotSmoothing*100).."%"
    smLbl.Text="Smoothing: "..math.floor(aimbotSmoothing*100).."%  (lower = snappier)"
    playSound("12221967")
end)

SetCanvas(aimSF, 480)

-- ══════════════════════════════════════════════════════
-- PLAYERS PAGE
-- ══════════════════════════════════════════════════════
local plScroll=Instance.new("ScrollingFrame")
plScroll.Size=UDim2.new(1,-6,0,CH-100);plScroll.Position=UDim2.new(0,3,0,4)
plScroll.BackgroundTransparency=1;plScroll.BorderSizePixel=0
plScroll.ScrollBarThickness=5;plScroll.ScrollBarImageColor3=Color3.fromRGB(110,30,200)
plScroll.CanvasSize=UDim2.new(0,0,0,0);plScroll.Parent=plSF
Instance.new("UIListLayout",plScroll).Padding=UDim.new(0,4)

local selectedPlayer=nil

local SelLabel=Instance.new("TextLabel")
SelLabel.Size=UDim2.new(0,CW,0,18);SelLabel.Position=UDim2.new(0,8,0,CH-88)
SelLabel.BackgroundTransparency=1;SelLabel.Font=Enum.Font.Gotham;SelLabel.TextSize=12
SelLabel.TextColor3=Color3.fromRGB(190,135,255);SelLabel.Text="No player selected"
SelLabel.TextXAlignment=Enum.TextXAlignment.Left;SelLabel.Parent=plSF

local ActionFrame=Instance.new("Frame")
ActionFrame.Size=UDim2.new(0,CW,0,44);ActionFrame.Position=UDim2.new(0,8,0,CH-66)
ActionFrame.BackgroundColor3=Color3.fromRGB(14,4,32);ActionFrame.BorderSizePixel=0
ActionFrame.Parent=plSF;Instance.new("UICorner",ActionFrame).CornerRadius=UDim.new(0,9)

local third3=(CW-12)/3
local TPBtn2 = PBtn(ActionFrame,"📍 TP",4,third3,4,Color3.fromRGB(16,65,145))
local AttBtn = PBtn(ActionFrame,"🔗 Attach",4,third3,third3+10,Color3.fromRGB(78,16,16))
local FlBtn  = PBtn(ActionFrame,"💀 Fling",4,third3,third3*2+16,Color3.fromRGB(86,6,6))
TPBtn2.TextSize=12;AttBtn.TextSize=12;FlBtn.TextSize=12

local RefreshBtn=PBtn(plSF,"🔄  Refresh Player List",CH-18,CW,8,Color3.fromRGB(16,5,42))
RefreshBtn.TextSize=12

SetCanvas(plSF, CH+10)

local plBtns={}

local function RefreshPlayers()
    for _,b in pairs(plBtns) do b:Destroy() end
    plBtns={};plScroll.CanvasSize=UDim2.new(0,0,0,0)
    local list=Players:GetPlayers();local totalH=0
    for _,pl in ipairs(list) do
        if pl~=LocalPlayer then
            local btn=Instance.new("TextButton")
            btn.Size=UDim2.new(1,-6,0,32);btn.BackgroundColor3=Color3.fromRGB(16,5,38)
            btn.BorderSizePixel=0;btn.Font=Enum.Font.Gotham;btn.TextSize=13
            btn.TextColor3=Color3.fromRGB(205,158,255)
            btn.Text="  👤  "..pl.Name;btn.TextXAlignment=Enum.TextXAlignment.Left
            btn.Parent=plScroll;Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
            if pl.Name==OWNER_NAME then
                btn.Text="  👑  "..pl.Name
                btn.TextColor3=Color3.fromRGB(255,215,0)
                btn.BackgroundColor3=Color3.fromRGB(48,32,4)
            end
            btn.MouseButton1Click:Connect(function()
                selectedPlayer=pl;SelLabel.Text="Selected:  "..pl.Name
                for _,b2 in pairs(plBtns) do
                    b2.BackgroundColor3=b2.Text:find(OWNER_NAME) and Color3.fromRGB(48,32,4) or Color3.fromRGB(22,7,46)
                end
                btn.BackgroundColor3=Color3.fromRGB(78,24,152);playSound("12221967")
            end)
            table.insert(plBtns,btn);totalH=totalH+36
        end
    end
    plScroll.CanvasSize=UDim2.new(0,0,0,totalH)
end

RefreshBtn.MouseButton1Click:Connect(function() RefreshPlayers();playSound("12221967") end)

TPBtn2.MouseButton1Click:Connect(function()
    if not selectedPlayer then return end
    local tChar=selectedPlayer.Character;if not tChar then return end
    local tRoot=tChar:FindFirstChild("HumanoidRootPart");if not tRoot then return end
    local root=GetRoot();if not root then return end
    root.CFrame=tRoot.CFrame*CFrame.new(0,0,-3);playSound("12221967")
end)

AttBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then return end
    if attachRunning and attachTarget==selectedPlayer then
        Detach();AttBtn.Text="🔗 Attach";AttBtn.BackgroundColor3=Color3.fromRGB(78,16,16)
    else
        AttachToPlayer(selectedPlayer);AttBtn.Text="🔗 Detach";AttBtn.BackgroundColor3=Color3.fromRGB(160,30,30)
    end
    playSound("12221967")
end)

FlBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then return end
    local tChar=selectedPlayer.Character;if not tChar then return end
    local tRoot=tChar:FindFirstChild("HumanoidRootPart");if not tRoot then return end
    local myRoot=GetRoot();if not myRoot then return end
    myRoot.CFrame=tRoot.CFrame*CFrame.new(0,0,-0.5)
    task.wait(0.05);StartFling()
    task.delay(1.5,function()
        StopFling();FlingBtn.Text="🌀  Fling  OFF";FlingBtn.BackgroundColor3=Color3.fromRGB(50,9,18)
    end)
    playSound("12221967")
end)

RefreshPlayers()
Players.PlayerAdded:Connect(function() RefreshPlayers() end)
Players.PlayerRemoving:Connect(function(pl)
    if selectedPlayer==pl then selectedPlayer=nil;SelLabel.Text="No player selected" end
    RefreshPlayers()
end)


-- ══════════════════════════════════════════════════════
-- KEY TAB CONTENT
-- ══════════════════════════════════════════════════════
local CW2 = W - 24   -- same as CW

-- lock icon
local KLockLbl = Instance.new("TextLabel", keySF)
KLockLbl.Size               = UDim2.new(0, CW2, 0, 50)
KLockLbl.Position           = UDim2.new(0, 8, 0, 10)
KLockLbl.BackgroundTransparency = 1
KLockLbl.Font               = Enum.Font.GothamBold
KLockLbl.TextSize            = 38
KLockLbl.TextColor3          = Color3.fromRGB(160, 80, 255)
KLockLbl.Text                = "🔑"

-- title
local KTitleLbl = Instance.new("TextLabel", keySF)
KTitleLbl.Size              = UDim2.new(0, CW2, 0, 22)
KTitleLbl.Position          = UDim2.new(0, 8, 0, 64)
KTitleLbl.BackgroundTransparency = 1
KTitleLbl.Font              = Enum.Font.GothamBold
KTitleLbl.TextSize           = 15
KTitleLbl.TextColor3         = Color3.fromRGB(210, 150, 255)
KTitleLbl.Text               = "Enter key to unlock lilly"
KTitleLbl.TextXAlignment     = Enum.TextXAlignment.Left

-- discord hint
local KHintLbl = Instance.new("TextLabel", keySF)
KHintLbl.Size               = UDim2.new(0, CW2, 0, 16)
KHintLbl.Position           = UDim2.new(0, 8, 0, 88)
KHintLbl.BackgroundTransparency = 1
KHintLbl.Font               = Enum.Font.Gotham
KHintLbl.TextSize            = 11
KHintLbl.TextColor3          = Color3.fromRGB(90, 70, 180)
KHintLbl.Text                = "Join discord.gg/8fq9bZ6c2A to get the key"
KHintLbl.TextXAlignment      = Enum.TextXAlignment.Left

-- input background
local KInputBG = Instance.new("Frame", keySF)
KInputBG.Size               = UDim2.new(0, CW2, 0, 40)
KInputBG.Position           = UDim2.new(0, 8, 0, 114)
KInputBG.BackgroundColor3   = Color3.fromRGB(18, 7, 40)
KInputBG.BorderSizePixel    = 0
Instance.new("UICorner", KInputBG).CornerRadius = UDim.new(0, 9)

local KBorder = Instance.new("Frame", KInputBG)
KBorder.Size                = UDim2.new(1, 2, 1, 2)
KBorder.Position            = UDim2.new(0, -1, 0, -1)
KBorder.BackgroundColor3    = Color3.fromRGB(80, 20, 170)
KBorder.BackgroundTransparency = 0.55
KBorder.BorderSizePixel     = 0
KBorder.ZIndex              = 0
Instance.new("UICorner", KBorder).CornerRadius = UDim.new(0, 10)

local KBox = Instance.new("TextBox", KInputBG)
KBox.Size                   = UDim2.new(1, -14, 1, 0)
KBox.Position               = UDim2.new(0, 7, 0, 0)
KBox.BackgroundTransparency = 1
KBox.Font                   = Enum.Font.GothamBold
KBox.TextSize                = 15
KBox.TextColor3              = Color3.fromRGB(220, 170, 255)
KBox.PlaceholderColor3       = Color3.fromRGB(80, 50, 120)
KBox.PlaceholderText         = "Enter key here..."
KBox.Text                    = ""
KBox.ClearTextOnFocus        = false
KBox.ZIndex                  = 2

-- status label
local KStatus = Instance.new("TextLabel", keySF)
KStatus.Size                = UDim2.new(0, CW2, 0, 18)
KStatus.Position            = UDim2.new(0, 8, 0, 160)
KStatus.BackgroundTransparency = 1
KStatus.Font                = Enum.Font.GothamBold
KStatus.TextSize             = 12
KStatus.TextColor3           = Color3.fromRGB(255, 80, 80)
KStatus.Text                 = ""
KStatus.TextXAlignment       = Enum.TextXAlignment.Left

-- submit button
local KSubmit = Instance.new("TextButton", keySF)
KSubmit.Size                = UDim2.new(0, CW2, 0, 40)
KSubmit.Position            = UDim2.new(0, 8, 0, 184)
KSubmit.BackgroundColor3    = Color3.fromRGB(78, 14, 162)
KSubmit.BorderSizePixel     = 0
KSubmit.Font                = Enum.Font.GothamBold
KSubmit.TextSize             = 14
KSubmit.TextColor3           = Color3.new(1, 1, 1)
KSubmit.Text                 = "🔓  Unlock"
Instance.new("UICorner", KSubmit).CornerRadius = UDim.new(0, 9)

KSubmit.MouseEnter:Connect(function()
    TweenService:Create(KSubmit,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(100,20,200)}):Play()
end)
KSubmit.MouseLeave:Connect(function()
    TweenService:Create(KSubmit,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(78,14,162)}):Play()
end)

-- discord copy button
local KDiscBtn = Instance.new("TextButton", keySF)
KDiscBtn.Size               = UDim2.new(0, CW2, 0, 34)
KDiscBtn.Position           = UDim2.new(0, 8, 0, 232)
KDiscBtn.BackgroundColor3   = Color3.fromRGB(35, 55, 175)
KDiscBtn.BorderSizePixel    = 0
KDiscBtn.Font               = Enum.Font.GothamBold
KDiscBtn.TextSize            = 12
KDiscBtn.TextColor3          = Color3.new(1, 1, 1)
KDiscBtn.Text                = "💬  Join Discord — discord.gg/8fq9bZ6c2A"
Instance.new("UICorner", KDiscBtn).CornerRadius = UDim.new(0, 9)

KDiscBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard("https://discord.gg/8fq9bZ6c2A") end end)
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title="💬 Discord",Text="Copied! discord.gg/8fq9bZ6c2A",Duration=4,
        })
    end)
    playSound("12221967")
end)

SetCanvas(keySF, 280)

-- Key validation
local function TryUnlock()
    local entered = KBox.Text:gsub("%s","")
    if entered == VALID_KEY then
        keyUnlocked = true
        SaveKey()   -- save so they don't need to enter it again
        KStatus.TextColor3  = Color3.fromRGB(80, 255, 120)
        KStatus.Text        = "✓  Key accepted! Welcome."
        KSubmit.Text        = "✓  Unlocked!"
        KSubmit.BackgroundColor3 = Color3.fromRGB(20, 110, 60)
        playSound("4612398582")
        task.delay(0.6, function()
            SelectTab("Misc")
        end)
        pcall(function()
            StarterGui:SetCore("SendNotification",{
                Title="✦  lilly  v9",Text="Unlocked! Welcome.",Duration=4,
            })
        end)
    else
        KStatus.TextColor3 = Color3.fromRGB(255, 70, 70)
        KStatus.Text       = "✗  Wrong key — join Discord to get it"
        playSound("12221967")
        task.spawn(function()
            local origPos = KInputBG.Position
            for i = 1, 4 do
                TweenService:Create(KInputBG,TweenInfo.new(0.05),{
                    Position=UDim2.new(origPos.X.Scale, origPos.X.Offset+(i%2==0 and 6 or -6), origPos.Y.Scale, origPos.Y.Offset)
                }):Play()
                task.wait(0.06)
            end
            TweenService:Create(KInputBG,TweenInfo.new(0.08),{Position=origPos}):Play()
        end)
    end
end

KSubmit.MouseButton1Click:Connect(function() TryUnlock() end)
KBox.FocusLost:Connect(function(enter) if enter then TryUnlock() end end)

-- If key was already saved skip straight to Misc
if keyUnlocked then
    KStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
    KStatus.Text       = "✓  Already unlocked — saved key found."
    KSubmit.Text       = "✓  Unlocked!"
    KSubmit.BackgroundColor3 = Color3.fromRGB(20, 110, 60)
    SelectTab("Misc")
else
    SelectTab("🔑 Key")
end

-- ── All button logic ───────────────────────────────────────────
ToggleBtn.MouseButton1Click:Connect(function()
    orbitEnabled=not orbitEnabled
    ToggleBtn.Text="🪐  Orbit  "..(orbitEnabled and "ON ✓" or "OFF")
    ToggleBtn.BackgroundColor3=orbitEnabled and Color3.fromRGB(80,14,165) or Color3.fromRGB(22,7,50)
    if orbitEnabled then GrabEntireMap()
    else
        for _,entry in ipairs(orbitParts) do
            pcall(function()
                entry.part:FindFirstChild("_OrbitAtt"):Destroy()
                entry.part:FindFirstChild("_OrbitAlign"):Destroy()
                entry.part:FindFirstChild("_OrbitTorque"):Destroy()
                entry.slot:Destroy()
            end)
        end
        orbitParts={};grabbedSet={}
    end
    playSound("12221967")
end)

AntiTPBtn.MouseButton1Click:Connect(function()
    antiTP=not antiTP
    if antiTP then local root=GetRoot();if root then lastPos=root.Position end end
    AntiTPBtn.Text="🛡️  Anti-TP  "..(antiTP and "ON ✓" or "OFF")
    AntiTPBtn.BackgroundColor3=antiTP and Color3.fromRGB(14,80,14) or Color3.fromRGB(12,26,12)
    playSound("12221967")
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    antiFling=not antiFling
    AntiFlingBtn.Text="🔒  Anti-Fling  "..(antiFling and "ON ✓" or "OFF")
    AntiFlingBtn.BackgroundColor3=antiFling and Color3.fromRGB(20,20,98) or Color3.fromRGB(16,16,44)
    playSound("12221967")
end)

FlyBtn.MouseButton1Click:Connect(function()
    if flying then StopFly();FlyBtn.Text="✈️   Fly  OFF";FlyBtn.BackgroundColor3=Color3.fromRGB(22,7,50)
    else StartFly();FlyBtn.Text="✈️   Fly  ON ✓";FlyBtn.BackgroundColor3=Color3.fromRGB(14,86,172) end
    playSound("12221967")
end)

FlingBtn.MouseButton1Click:Connect(function()
    if flinging then StopFling();FlingBtn.Text="🌀  Fling  OFF";FlingBtn.BackgroundColor3=Color3.fromRGB(50,9,18)
    else StartFling();FlingBtn.Text="🌀  Fling  ON ✓";FlingBtn.BackgroundColor3=Color3.fromRGB(165,12,30) end
    playSound("12221967")
end)

ClickTPBtn.MouseButton1Click:Connect(function()
    clickTPEnabled=not clickTPEnabled
    ClickTPBtn.Text="🖱️  Click TP  "..(clickTPEnabled and "ON ✓" or "OFF")
    ClickTPBtn.BackgroundColor3=clickTPEnabled and Color3.fromRGB(14,95,70) or Color3.fromRGB(12,7,44)
    playSound("12221967")
end)

ESPBtn.MouseButton1Click:Connect(function()
    espEnabled=not espEnabled
    ESPBtn.Text="👁  ESP  "..(espEnabled and "ON ✓" or "OFF")
    ESPBtn.BackgroundColor3=espEnabled and Color3.fromRGB(172,26,26) or Color3.fromRGB(22,7,50)
    if espEnabled then for _,pl in pairs(Players:GetPlayers()) do CreateESP(pl) end end
    playSound("12221967")
end)

AimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled=not aimbotEnabled
    aimKeyHeld=false   -- reset on toggle
    AimBtn.Text="🎯  Aimbot  "..(aimbotEnabled and "ON ✓" or "OFF")
    AimBtn.BackgroundColor3=aimbotEnabled and Color3.fromRGB(162,100,0) or Color3.fromRGB(22,7,50)
    if not aimbotEnabled then aimFOVCircle.Visible=false;aimDot.Visible=false end
    playSound("12221967")
end)

DecBtn.MouseButton1Click:Connect(function()
    orbitRadius=math.max(5,orbitRadius-2);RadLbl.Text="Radius: "..orbitRadius;playSound("12221967")
end)
IncBtn.MouseButton1Click:Connect(function()
    orbitRadius=math.min(500,orbitRadius+2);RadLbl.Text="Radius: "..orbitRadius;playSound("12221967")
end)

for i,btn in ipairs(patBtns) do
    btn.MouseButton1Click:Connect(function()
        orbitPattern=i
        for j,b in ipairs(patBtns) do b.BackgroundColor3=j==i and Color3.fromRGB(88,15,180) or Color3.fromRGB(16,5,38) end
        masterAngle=0;playSound("12221967")
    end)
end

-- ── Drag ───────────────────────────────────────────────────────
-- Drag from title bar only so sliders/buttons still work
local dragging,dragInput,dragStart,startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true;dragStart=input.Position;startPos=Panel.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input==dragInput then
        local d=input.Position-dragStart
        Panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- ── Startup ────────────────────────────────────────────────────
pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title="✦  lilly  v9",
        Text="Loaded — RMB Aimbot · Scrollable Tabs · Owner Detection",
        Duration=5,
    })
end)

print("✦ lilly v9 loaded")
