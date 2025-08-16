local WebModule = {}
local Functions = {}
local Strings = {}
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    HTTP = game:GetService("HttpService")
}

local Config = { TInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), TInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut) }
local SectionConfig = { Hover = UDim2.new(2.65, 0, 2.65, 0), NoHover = UDim2.new(2, 0, 2, 0) }

local Backend = {
    ["Other Modules"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Other Modules", 5),
    ["Other Remotes"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Other Remotes", 5),
    ["Server Communication"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Server Communication", 5),
    ["FUNCTION_TREE"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Server Communication"):WaitForChild("FUNCTION_TREE", 5),
    ["REMOTE_TREE"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Server Communication"):WaitForChild("REMOTE_TREE", 5),
    ["Movement"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Other Remotes"):WaitForChild("Movement", 5),
    ["ClientUtils"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Other Modules"):WaitForChild("ClientUtils", 5),
    ["Entity"] = Services.ReplicatedStorage:WaitForChild("Backend"):WaitForChild("Other Modules"):WaitForChild("Entity", 5),
}

local COLOR_STATES = {
    STATIC = Color3.fromRGB(255, 255, 255),
    UNLOCKED = Color3.fromRGB(0, 34, 255)
}

WebModule.__index = WebModule
Functions.__index = Functions
Strings.__index = Strings
Config.__index = Config
Backend.__index = Backend

-- }} vars {{ --

WebModule.SELECTED_TREE = nil
WebModule.SKILLS = nil
WebModule.HIDDEN_GUIS = {}

WebModule.PROTECTED_GUIS = {}
WebModule.REGISTRY = {}
WebModule.CONNECTOR_LINE = nil

WebModule.Smoke = nil
WebModule.Ambient = nil
WebModule.Player = nil
WebModule.LevelFrame = nil
WebModule.data = nil
WebModule.Tween = nil
WebModule.TreeConfig = nil
WebModule.CurrentlyOwned = {}
WebModule.ConnectorLines = {}
WebModule.pEntity = nil
WebModule.LastPS = {}

WebModule.Modules = {
    Utils = require(Backend["Other Modules"].UtilModule),
    Prompts = require(Backend["Other Modules"].PromptModule),
    ClientUtils = require(Backend["Other Modules"].ClientUtils),
    Entity = require(Backend["Other Modules"].Entity),
}

function Strings:_DeclareDescriptions()

    -- SKILL DESCRIPTIONS, make sure to update this, otherwise the server & client won't recognize other skill instances

    self.Descriptions = {
        ["Vitality1"] = {
            Name = "Vitality I",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+1 Maximum Health"
                }
            },

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then 
                    player = character
                    character = character.Character
                end

                local humanoid = character.Humanoid
                humanoid.MaxHealth += 1
                humanoid.Health = humanoid.MaxHealth
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 1
                humanoid.Health = humanoid.MaxHealth
            end
        },

        ["Vitality2"] = {
            Name = "Vitality II",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+1 Maximum Health"
                }
            },
            Parents = {"Vitality1"},

            -- NEW: effects

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth += 1
                humanoid.Health = humanoid.MaxHealth
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 1
                humanoid.Health = humanoid.MaxHealth
            end
        },
        
        ["Stoic1"] = {
            Name = "Stoic I",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+1 Maximum Health"
                },
                {
                    color = Color3.fromRGB(255,0,0),
                    text = "-0.75 Movement Speed"
                }
            },

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth += 1
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", -0.75)
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
            
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 1
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", 0.75)
            end
        },

        --[[
            GM:AddSkill(SKILL_STOIC1, "Stoic I", GOOD.."+1 maximum health\n"..BAD.."-0.75 movement speed",
                                                                            -4,			-6,					{SKILL_NONE, SKILL_STOIC2}, TREE_HEALTHTREE)
            GM:AddSkill(SKILL_STOIC2, "Stoic II", GOOD.."+2 maximum health\n"..BAD.."-1.5 movement speed",
                                                                            -4,			-4,					{SKILL_STOIC3, SKILL_VITALITY1, SKILL_REGENERATOR}, TREE_HEALTHTREE)
            GM:AddSkill(SKILL_STOIC3, "Stoic III", GOOD.."+4 maximum health\n"..BAD.."-3 movement speed",
                                                                            -3,			-2,					{SKILL_STOIC4}, TREE_HEALTHTREE)
            GM:AddSkill(SKILL_STOIC4, "Stoic IV", GOOD.."+6 maximum health\n"..BAD.."-4.5 movement speed",
                                                                            -3,			0,					{SKILL_STOIC5}, TREE_HEALTHTREE)
            GM:AddSkill(SKILL_STOIC5, "Stoic V", GOOD.."+7 maximum health\n"..BAD.."-5.25 movement speed",
                                                                            -3,			2,					{SKILL_BLOODARMOR, SKILL_TANKER}, TREE_HEALTHTREE)
        ]]

        ["Stoic2"] = {
            Name = "Stoic II",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+2 Maximum Health"
                },
                {
                    color = Color3.fromRGB(255,0,0),
                    text = "-1 Movement Speed"
                }
            },
            Parents = {"Stoic1"},

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth += 2
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", -1)
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
            
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 2
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", 1)
            end
        },

        ["Stoic3"] = {
            Name = "Stoic III",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+4 Maximum Health"
                },
                {
                    color = Color3.fromRGB(255,0,0),
                    text = "-2.5 Movement Speed"
                }
            },
            Parents = {"Stoic1", "Stoic2"},

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth += 4
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", -2.5)
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
            
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 4
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", 1)
            end
        },

        ["Stoic4"] = {
            Name = "Stoic IV",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+6 Maximum Health"
                },
                {
                    color = Color3.fromRGB(255,0,0),
                    text = "-4.35 Movement Speed"
                }
            },
            Parents = {"Stoic1", "Stoic2", "Stoic3"},

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth += 6
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", -4.35)
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
            
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 6
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", 4.35)
            end
        },

        ["Stoic5"] = {
            Name = "Stoic V",
            Desc = {
                {
                    color = Color3.fromRGB(0,255,0),
                    text = "+7 Maximum Health"
                },
                {
                    color = Color3.fromRGB(255,0,0),
                    text = "-5 Movement Speed"
                }
            },
            Parents = {"Stoic1", "Stoic2", "Stoic3", "Stoic4"},

            ApplySkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
                
                local humanoid = character.Humanoid
                humanoid.MaxHealth += 7
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", -5)
            end,
            
            RemoveSkillEffect = function(player, character)
                if character:IsA("Player") then
                    player = character
                    character = character.Character
                end
            
                local humanoid = character.Humanoid
                humanoid.MaxHealth -= 7
                humanoid.Health = humanoid.MaxHealth

                self:MovementMethod(player, "wsrate", 5)
            end
        },
    }
end

function Strings:MapToNormalUnits(ws) 
    local GModDefault = 225 
    local RobloxDefault = 16 
    return ws * RobloxDefault / GModDefault 
end

function Strings:MovementMethod(player, mode, ...)
    local args = {...}
    repeat task.wait() until player and (player.Character or player.CharacterAdded:Wait())

    local humanoid = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid", 5)
    if not humanoid then return end

    if mode == "setwalkspeed" then
        local NEW_WS_ROBLOX = self:MapToNormalUnits(args[1]) + (args[2] or 0)
        Backend.Movement:FireClient(player, mode, NEW_WS_ROBLOX)
        humanoid:SetAttribute("ew", NEW_WS_ROBLOX)

    elseif mode == "wsrate" then
        local CURRENT_WS_GMOD = humanoid.WalkSpeed * 225 / 16
        local NEW_WS_GMOD = CURRENT_WS_GMOD + (args[1] or 0)
        local NEW_WS_ROBLOX = self:MapToNormalUnits(NEW_WS_GMOD)
        Backend.Movement:FireClient(player, "setwalkspeed", NEW_WS_ROBLOX)
        humanoid:SetAttribute("ew", NEW_WS_ROBLOX)

    elseif mode == "getcurrentspeed" then
        local callback = args[1]
        if typeof(callback) == "function" then
            local currentSpeed = humanoid:GetAttribute("ew") or humanoid.WalkSpeed
            callback(currentSpeed)
        end

    elseif mode == "applyspeedmodifier" then
        Backend.Movement:FireClient(player, mode, args[1], args[2])
    elseif mode == "removespeedmodifier" then
        Backend.Movement:FireClient(player, mode, args[1])
    elseif mode == "updatecurrentspeed" then
        Backend.Movement:FireClient(player, mode)
    elseif mode == "resettodefault" then
        Backend.Movement:FireClient(player, mode)
    end
end

Strings:_DeclareDescriptions()
Strings._DeclareDescriptions = nil

for id, desc in pairs(Strings.Descriptions) do
    WebModule.REGISTRY[id] = {
        Name = desc.Name, 
        Cost = desc.Cost or 1, 
        Parents = desc.Parents or {},
        ApplySkillEffect = desc.ApplySkillEffect,
        RemoveSkillEffect = desc.RemoveSkillEffect
    }
end


-- }} main module {{ --

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Functions:PromptChoice(title, desc, btns)
    local frame, bt = WebModule.Modules.Prompts:CREATE_CHOICE(title, desc, btns)

    local proxytbl = {}
    for key, btn in pairs(bt) do
        proxytbl[key] = btn
    end

    return frame, WebModule.Modules.Prompts, proxytbl
end

function Functions:BlurBG(status)
    WebModule.Modules.Utils:Blur(WebModule.Player, status)
end

function Functions:DECLARE_ERROR(msg)
	error("[WebModule/DECLARE_ERROR]: " .. tostring(msg))
end

function Functions:Debug(msg)
    print(msg)
end

function Functions:RefundSP()
    self:Debug("i wanna refund my skill points lol")
end

function Functions:OnSectionHover(btn, st)
    if WebModule.Tween then
        WebModule.Tween:Pause()
    end

    local hoveringbtn = st

    if hoveringbtn then
        task.spawn(function()
            WebModule.Modules.ClientUtils:PlaySound("ui/misc1.ogg")        
        end)
    end

    local t;

    local success, err = pcall(function()
        t = TweenService:Create(btn.Glow, Config.TInfo2, {
            Size = (hoveringbtn and SectionConfig.Hover or SectionConfig.NoHover)
        })
    end)

    if not success and err then
        self:DECLARE_ERROR("failed to define tween")
        return
    end

    WebModule.Tween = t
    WebModule.Tween:Play()
    WebModule.Tween.Completed:Connect(function()
        WebModule.Tween = nil
    end)
end

function Functions:OnHover(info, button, hovering) 
    if info:FindFirstChild(button.Name) and hovering then
        return
    end

    if hovering then
        local BoolValue = Instance.new("BoolValue", info)
        BoolValue.Name = button.Name
        BoolValue.Value = true

        task.spawn(function()
            WebModule.Modules.ClientUtils:PlaySound("ui/misc1.ogg")
        end)
    end

    local Description

    if button.Name == "Remort" then
        Description = { Desc = { "Go even further beyond.", "Lose all skills, experience, skill points, and levels.", "Start at level 1 but with 1 extra skill point.", "Can remort multiple times for multiple extra skill points." } }
    else
        Description = Strings.Descriptions[button.Name]
    end

	if not hovering then
        for _, children in ipairs(info:GetChildren()) do
            if not children:IsA("UIListLayout") and children:IsA("TextLabel") then
                TweenService:Create(children, Config.TInfo, {TextTransparency = 1}):Play()

                local stroke = children:FindFirstChildWhichIsA("UIStroke")

                if stroke then
                    TweenService:Create(stroke, Config.TInfo, {Transparency = 1}):Play()
                end

                task.delay(Config.TInfo.Time, function()
                    if children and children.Parent then
                        children:Destroy()
                    end
                end)
            end
        end

        task.delay(Config.TInfo.Time + 0.1, function()
            if info:FindFirstChild(button.Name) and info:FindFirstChild(button.Name):IsA("BoolValue") then
                info[button.Name]:Destroy()
            end
        end)

		button:FindFirstChild("Name").TextColor3 = Color3.fromRGB(165, 165, 165)
		return
	end

	button:FindFirstChild("Name").TextColor3 = Color3.fromRGB(255, 255, 255)

	local namelabel = self:CreateInfoLabel({
		txt = Description.Name or button.Name,
		color = Color3.fromRGB(255, 255, 255),
	})

	namelabel.Name = "A-Name"

    local labels = {}

    if typeof(Description.Desc) == "string" then
        local label = self:CreateInfoLabel({
            txt = Description.Desc,
            color = Color3.fromRGB(255, 255, 255)
        })

        label.Name = "Description1"
        label.RichText = true
        label.Parent = info
        label.TextTransparency = 1
        label.Visible = true
        label.ZIndex = 5
        labels[#labels+1] = label
    elseif type(Description.Desc) == "table" then
        for i, item in ipairs(Description.Desc) do
            local label

            if type(item) == "table" and item.text and item.color then
                label = self:CreateInfoLabel({
                    txt = tostring(item.text),
                    color = item.color
                })
            else
                label = self:CreateInfoLabel({
                    txt = tostring(item),
                    color = Color3.fromRGB(255, 255, 255)
                })
            end

            label.Name = "Description" .. i
            label.RichText = true
            label.Parent = info
            label.TextTransparency = 1
            label.Visible = true
            label.ZIndex = 5
            labels[#labels+1] = label
        end
    end

	namelabel.Parent = info

	local ts1 = TweenService:Create(namelabel, Config.TInfo, {TextTransparency = 0})
    local stroke1 = namelabel:FindFirstChildWhichIsA("UIStroke")

    if stroke1 then
        stroke1.Transparency = 1
        TweenService:Create(stroke1, Config.TInfo, {Transparency = 0}):Play()
    end

    local othertweens = {}

    namelabel.TextTransparency = 1
    namelabel.Visible = true

    for _, label in ipairs(labels) do
        local stroke = label:FindFirstChildWhichIsA("UIStroke")
        label.TextTransparency = 1
        label.Visible = true
        table.insert(othertweens, TweenService:Create(label, Config.TInfo, {TextTransparency = 0}))

        if stroke then
            stroke.Transparency = 1
            table.insert(othertweens, TweenService:Create(stroke, Config.TInfo, {Transparency = 0}))
        end
    end

	ts1:Play()

    for _, tween in ipairs(othertweens) do
        tween:Play()
    end
end

function Functions:GetLineRelatedTo(_1, _2)
    for _, con in ipairs(WebModule.ConnectorLines) do
        local lineframe, sl, el = con[1], con[2], con[3]

        if _2 then
            if (sl == _1 and el == _2) or (sl == _2 and el == _1) then
                return lineframe
            end
        else
            if sl == _1 or el == _1 then
                return lineframe
            end
        end
    end
    
    return nil
end

function Functions:GetLinesRelatedTo(label)
    local res = {}

    for _, con in ipairs(WebModule.ConnectorLines) do
        if con[2] == label or con[3] == label then
            table.insert(res,con[1])
        end
    end

    return res
end

function Functions:ConnectLine(containerFrame, lineFrame, startLabel, endLabel, duration)
    local start = startLabel.AbsolutePosition + startLabel.AbsoluteSize / 2
    local _end = endLabel.AbsolutePosition + endLabel.AbsoluteSize / 2

    local delta = _end - start
    local length = delta.Magnitude
    local angle = math.deg(math.atan2(delta.Y, delta.X))

    local midpoint = (start + _end) / 2

    local relativeMidpoint = Vector2.new(
        midpoint.X - containerFrame.AbsolutePosition.X,
        midpoint.Y - containerFrame.AbsolutePosition.Y
    )

    lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    lineFrame.Position = UDim2.new(0, relativeMidpoint.X, 0, relativeMidpoint.Y)
    lineFrame.Rotation = angle
    lineFrame.Size = UDim2.new(0, 0, 0, 1)

    local ti = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = { Size = UDim2.new(0, length, 0, 1) }
    TweenService:Create(lineFrame, ti, goal):Play()

    WebModule.ConnectorLines[#WebModule.ConnectorLines+1] = {
        [1] = lineFrame,
        [2] = startLabel,
        [3] = endLabel
    }

    return lineFrame
end

function Functions:DoSectionHovers()
    do
        for _, children in WebModule.SKILLS:GetChildren() do
            if children:IsA("Frame") and children.Name == "Open" then
                local btn = children:FindFirstChild("Click")
                local img = children:FindFirstChild("Image")

                btn.MouseEnter:Connect(function()
                    self:OnSectionHover(img, true)
                end)

                btn.MouseLeave:Connect(function()
                    self:OnSectionHover(img, false)
                end)
            end
        end
    end
end

function Functions:_Toggle(t, v)
    for _, k in WebModule.SKILLS:GetChildren() do
        if k:IsA("Frame") and k.Name == "Open" then
            k.Visible = t
        end
    end

    for _, otherframe in WebModule.SKILLS:GetChildren() do
        if otherframe:IsA("Frame") and otherframe.Name ~= (v and v.Name or "") and not otherframe:GetAttribute("tree") then
            otherframe.Visible = t
        end
    end

    WebModule.SKILLS.Remort.Visible = t
end

function Functions:OpenSection(name)
    local frame = WebModule.SKILLS:FindFirstChild(name)
    if frame then
        self:_Toggle(false, frame)
        frame.Visible = true
    else
        self:DECLARE_ERROR("provided incorrect section name : " .. tostring(name))
    end
end

function Functions:HideSection(name)
    local frame = WebModule.SKILLS:FindFirstChild(name)
    if frame then
        self:_Toggle(true, frame)
        frame.Visible = false
    else
        self:DECLARE_ERROR("provided incorrect section name : " .. tostring(name))
    end
end

function Functions:HideAllSections()
    for _, frame in WebModule.SKILLS:GetChildren() do
        if frame:IsA("Frame") and frame.Name ~= "Remort" then
            frame.Visible = false
        end
    end
    self:_Toggle(true, nil)
end

function Functions:RestoreGUIs()
    for _, gui in ipairs(WebModule.HIDDEN_GUIS) do
        if gui and gui.Parent and not WebModule.PROTECTED_GUIS[gui] then
            gui.Enabled = true
        end
    end

    WebModule.HIDDEN_GUIS = {}
    UIS.MouseIconEnabled = false
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function Functions:TweenAmbient(v)
    if not WebModule.Ambient then self:DECLARE_ERROR("Ambient was not initialized in WebModule!") end
    local Tween
    if v then
        Tween = TweenService:Create(WebModule.Ambient, TweenInfo.new(0.5), {Volume = 0.5})
    else
        Tween = TweenService:Create(WebModule.Ambient, TweenInfo.new(0.5), {Volume = 0})
    end
    Tween:Play()
end

function Functions:TweenSmoke(IsOpening)
	if not WebModule.Smoke then self:DECLARE_ERROR("Smoke was not initialized in WebModule!") end
	local CurrentValue = IsOpening and 1 or 0.5
	local GoalValue = IsOpening and 0.5 or 1
	local Rate = IsOpening and -0.02 or 0.02
	local Connection
	Connection = game:FindService("RunService").Stepped:Connect(function()
		CurrentValue += Rate
		if (Rate < 0 and CurrentValue <= GoalValue) or (Rate > 0 and CurrentValue >= GoalValue) then
			CurrentValue = GoalValue
			Connection:Disconnect()
		end
		WebModule.Smoke:SetAttribute("Transparency", NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1, 0),
			NumberSequenceKeypoint.new(0.2, 0.5, 0),
			NumberSequenceKeypoint.new(0.8, 0.5, 0),
			NumberSequenceKeypoint.new(1, 1, 0)
		}))
	end)
end

function Functions:ConfigAllSkills(skillstatus) end

function Functions:QuitSkillWeb(WebFrame, Ambient, LocalPlayer)
    if not WebFrame.Parent.Visible then return end
    WebFrame.Parent.Visible = false

    LocalPlayer.CameraMaxZoomDistance = .5
    LocalPlayer.CameraMinZoomDistance = .5
    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

    self:RestoreGUIs()
    self:TweenAmbient(false)
    self:TweenSmoke(false)
    self:HideAllSections()
    repeat task.wait() until Ambient.Volume == 0
    Ambient:Stop()
end

function Functions:OnClick(btn)
	if btn.Name == "Close" then
		WebModule:Close()
	elseif btn.Name == "Save" then
		Functions:SaveTree()
	elseif btn.Name == "Load" then
		Functions:LoadTree()
    elseif btn.Name == "Quit" then
        Functions:QuitSkillWeb(btn.Parent.Parent, btn.Parent.Parent:FindFirstChild("Ambient"), WebModule.Player)
	end
end

function Functions:Remort() 
    Backend.FUNCTION_TREE:InvokeServer("REMORT", WebModule.Player)
end

function Functions:UIStroke(v)
	local stroke = Instance.new("UIStroke", v)
	stroke.Name = "Stroke"
	stroke.Thickness = 1.65
	stroke.Color = Color3.fromRGB(0,0,0)
	return stroke
end

function Functions:CreateInfoLabel(info)
	local v = Instance.new("TextLabel")
	v.Visible = false
	v.Name = "Label"
	v.Text = info.txt
	v.TextColor3 = info.color
	v.TextScaled = true
	v.FontFace = Font.new("rbxasset://fonts/families/SpecialElite.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	v.FontFace.Weight = Enum.FontWeight.Bold
	v.Size = UDim2.new(1, 0, 0, 25)
	v.BackgroundTransparency = 1

	self:UIStroke(v)

	return v
end

function Functions:GetSectionBySkillName(skillname)
    for _, imglabel in WebModule.SKILLS:GetDescendants() do
        if imglabel:IsA("ImageLabel") and imglabel:FindFirstChild("Click") and imglabel:FindFirstChild("Prompt") and imglabel.Parent:GetAttribute("tree") and imglabel.Parent:IsA("Frame") then
            if imglabel.Name == skillname then
                return imglabel.Parent
            end            
        end
    end

    return nil
end

function Functions:GetToggleFrameBySectionName(skillname)
    for _, children in WebModule.SKILLS:GetChildren() do
        if children.Name == "Open" and children:IsA("Frame") and children:FindFirstChild("Unlocked") and children:GetAttribute("Name") then
            if children:GetAttribute("Name") == skillname then
                return children
            end
        end
    end
    
    return nil
end

function Functions:DebugSkillLines(SKILL_TABLE)
    for skillName, info in pairs(WebModule.REGISTRY) do
        local parents = info.Parents
        if not parents or #parents == 0 then
            continue
        end

        local skill = SKILL_TABLE[skillName]
        local skillOwned = (skill and skill.Owned) or false

        local parentOwned = false
        for _, parentName in ipairs(parents) do
            local parent = SKILL_TABLE[parentName]
            if parent and parent.Owned then
                parentOwned = true
                break
            end
        end

        local lineColor
        if not parentOwned and not skillOwned then
            lineColor = "RED (locked)"
        elseif parentOwned and not skillOwned then
            lineColor = "YELLOW (available)"
        elseif parentOwned and skillOwned then
            lineColor = "BLUE (owned)"
        end

        print(string.format(
            "[Skill: %s] Owned: %s | Parent Owned: %s | Line Color: %s",
            skillName,
            tostring(skillOwned),
            tostring(parentOwned),
            lineColor
        ))
    end
end

function Functions:UpdateAllSkills(SKILL_TABLE)
    if not SKILL_TABLE then
        self:DECLARE_ERROR("provided a nil table")
        return
    end

    local SECTIONS = {}

    for SKILL_NAME, _ in pairs(SKILL_TABLE) do
        local SEC = self:GetSectionBySkillName(SKILL_NAME)
        if SEC and not SECTIONS[SEC.Name] then
            SECTIONS[SEC.Name] = {}
        end
    end

    for SKILL_NAME, INFO in pairs(SKILL_TABLE) do
        local SEC = self:GetSectionBySkillName(SKILL_NAME)
        if SEC and SECTIONS[SEC.Name] then
            SECTIONS[SEC.Name][SKILL_NAME] = INFO

            local SECTION_CONTAINER = WebModule.SKILLS:FindFirstChild(SEC.Name)
            if SECTION_CONTAINER then
                local SKILL_IMAGE = SECTION_CONTAINER:FindFirstChild(SKILL_NAME)
                if SKILL_IMAGE and SKILL_IMAGE:IsA("ImageLabel") then
                    if INFO.Enabled then
                        local Glow = self:GetGlowByName(SKILL_IMAGE.Name)
                        Glow.ImageColor3 = COLOR_STATES.UNLOCKED
                        SKILL_IMAGE.ImageColor3 = COLOR_STATES.UNLOCKED
                        SKILL_IMAGE.Prompt.Click.Text = "Deactivate"
                    else
                        local Glow = self:GetGlowByName(SKILL_IMAGE.Name)
                        Glow.ImageColor3 = COLOR_STATES.STATIC
                        SKILL_IMAGE.ImageColor3 = COLOR_STATES.STATIC
                        SKILL_IMAGE.Prompt.Click.Text = "Activate"
                    end
                end
            end
        end
    end

    self:DebugSkillLines(SKILL_TABLE)
end

function Functions:UpdateOwnedSections(SKILL_TABLE)
	if not SKILL_TABLE then
		self:DECLARE_ERROR("provided a nil table")
		return
	end

	local SECTIONS = {}

	for SKILL_NAME, _ in pairs(SKILL_TABLE) do
		local SEC = self:GetSectionBySkillName(SKILL_NAME)
		if SEC and not SECTIONS[SEC.Name] then
			SECTIONS[SEC.Name] = {}
			SECTIONS[SEC.Name.."-OPENFRAME"] = self:GetToggleFrameBySectionName(SEC.Name)
		end
	end

	for SKILL_NAME, INFO in pairs(SKILL_TABLE) do
		local SEC = self:GetSectionBySkillName(SKILL_NAME)
		if SEC and SECTIONS[SEC.Name] then
			SECTIONS[SEC.Name][SKILL_NAME] = INFO
		end
	end

	for SECTION_NAME, SKILLS in pairs(SECTIONS) do
		if type(SKILLS) == "table" and not SECTION_NAME:match("%-OPENFRAME$") then
			local OWNED_COUNT = 0
			local TOTAL_COUNT = 0

			local OPEN_FRAME = SECTIONS[SECTION_NAME.."-OPENFRAME"]
			if OPEN_FRAME then
				local SKILL_FRAME_NAME = OPEN_FRAME:GetAttribute("Name")
				local SECTION_SKILLS = WebModule.SKILLS:FindFirstChild(SKILL_FRAME_NAME)
				if SECTION_SKILLS then
					for _, child in pairs(SECTION_SKILLS:GetChildren()) do
						if child:FindFirstChild("Prompt") and child:FindFirstChild("Click") then
							TOTAL_COUNT += 1
							if SKILLS[child.Name] and SKILLS[child.Name].Owned then
								OWNED_COUNT += 1
							end
						end
					end
				end
			end

			if OPEN_FRAME and OPEN_FRAME:FindFirstChild("Unlocked") and OPEN_FRAME.Unlocked:IsA("TextLabel") then
				OPEN_FRAME.Unlocked.Text = string.format("%d/%d", OWNED_COUNT, TOTAL_COUNT)
			end
		end
	end

    self:UpdateAllSkills(SKILL_TABLE)
end

function Functions:DoSectionAmount()
    do
        for _, frame in WebModule.SKILLS:GetChildren() do
            if frame:IsA("Frame") and frame.Name == "Open" then
                if frame:FindFirstChild("Unlocked") then
                    local section = WebModule.SKILLS:FindFirstChild(frame:GetAttribute("Name"))
                    if section then
                        local validchildren = {}
                        
                        for _, v in section:GetChildren() do
                            if v:FindFirstChild("Prompt") and v:FindFirstChild("Name") and v:FindFirstChild("Click") then
                                validchildren[#validchildren+1] = v
                            end
                        end

                        frame.Unlocked.Text = string.format("0/%d", #validchildren)
                    end
                end
            end
        end
    end
end

function Functions:DoSkillPurchase(skillname)
    if WebModule.Player:FindFirstChild("SP") and WebModule.Player:FindFirstChild("SP").Value >= 1 then
        self:Debug("can purchase " .. skillname)
        Backend.REMOTE_TREE:FireServer("PURCHASE_SKILL", {skillname})

        local v = WebModule.pPlayer
        print(v)

        if not v then
            v = WebModule.Modules.Entity.new()
            WebModule.pPlayer = v:init(WebModule.Player)
            warn(WebModule.pPlayer)
            warn("brborborobr")
            if not WebModule.pPlayer then self:DECLARE_ERROR("ggs bro") end
        end

        WebModule.LevelFrame.SP.Text = "Unused Skill Points: " .. tostring(WebModule.pPlayer:GetZSSPLeft() - 1)
        return true
    elseif WebModule.Player:FindFirstChild("SP") and WebModule.Player:FindFirstChild("SP").Value < 1 then
        self:Debug("not enough SP")
        return false
    end
end

function Functions:GetZSQWorthAmount()
    return 100
end

function Functions:UpdatePlayerStats()
    local speed
    local health = WebModule.Player and (WebModule.Player.Character or WebModule.Player.CharacterAdded:Wait()):WaitForChild("Humanoid", 5).Health
    local worth = self:GetZSQWorthAmount()
    local playerstats = WebModule.TreeConfig.PlayerStats

    Strings:MovementMethod(WebModule.Player, "getcurrentspeed", function(ws) speed = ws end)

    playerstats.Health.Text = string.format("Health: %d", health)
    playerstats.Speed.Text = string.format("Speed: %d", math.floor(speed))
    playerstats.Worth.Text = string.format("Worth: %d", worth)
end

function Functions:ThinkOnce(method)
    if method == "SP" then
        local S, E = pcall(function()
            local SP = WebModule.pEntity:GetZSSPLeft()
            WebModule.LevelFrame.SP.Text = "Unused Skill Points: " .. tostring(SP)
        end)

        if not S then
            self:Debug("big warning: failed to ThinkOnce'SP' / pEntity might have been nil?")
        end
    end
end

function Functions:RecursiveFind(parent, name)
    local result = nil

    if not parent or not name then return nil end

    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == name then
            return child
        end

        local found = self:RecursiveFind(child, name)

        if found then
            result = found
        end
    end

    return result
end

function Functions:DoConnectors()
    for SkillName, SkillData in WebModule.REGISTRY do
        if SkillData.Parents and #SkillData.Parents > 0 then
            do
                for _, parents in SkillData.Parents do
                    local button, button2 = self:RecursiveFind(WebModule.SKILLS, parents), self:RecursiveFind(WebModule.SKILLS, SkillName)

                    if button and button2 then
                        local newline = WebModule.CONNECTOR_LINE:Clone()
                        newline.Parent = button.Parent

                        self:ConnectLine(WebModule.SKILLS, newline, button, button2, 0)
                    else
                        self:DECLARE_ERROR("failed to get btn1/btn2 [recursive find failed] for " .. SkillName .. " with parents " .. tostring(parents))
                    end
                end
            end
        end
    end
end

function Functions:DoUI()
    local plr = WebModule.Player
    local coroutines = {
        unused_skill_points = coroutine.wrap(function()
            local sp = plr:WaitForChild("SP", 5)
            if not sp then
                self:DECLARE_ERROR("Player does not have SP value.")
                return
            end

            sp:GetPropertyChangedSignal("Value"):Connect(function()
                if sp.Value > -1 then
                    WebModule.LevelFrame.SP.Text = string.format("Unused Skill Points: %d", sp.Value)
                end
            end)
        end)
    }

    for _, coroutineFunc in next, coroutines do coroutineFunc() end
end

function Functions:HideOtherPrompts(v)
    do
        for _, imagelabel in WebModule.SKILLS:GetDescendants() do
            if imagelabel:IsA("ImageLabel") and imagelabel:FindFirstChild("Click") and imagelabel.Parent:GetAttribute("tree") and not (imagelabel == v) then
                if imagelabel.Prompt.Visible then
                    imagelabel.Prompt.Visible = false
                end
            end
        end 
    end
end

function Functions:ChangeSkillState(skillname, status)
    Backend.REMOTE_TREE:FireServer((status and "ENABLE_SKILL" or "DISABLE_SKILL"), {skillname})
end

function Functions:GetPlayerSkills(PLAYER)
    if not PLAYER or not PLAYER:WaitForChild("SKILL_INFO", 2) then
        print("[GetPlayerSkills] no SKILL_INFO found for player")
        return { ["SKILLS"] = {} }
    end

    local JSON_STRING = PLAYER.SKILL_INFO.Value
    local SUCCESS, SKILLS_TABLE = pcall(function()
        return Services.HTTP:JSONDecode(JSON_STRING)
    end)

    if not SUCCESS or type(SKILLS_TABLE) ~= "table" then
        print("[GetPlayerSkills] failed to decode json or invalid table")
        return { ["SKILLS"] = {} }
    end

    SKILLS_TABLE["SKILLS"] = SKILLS_TABLE["SKILLS"] or {}

    for SKILL_NAME, SKILL_DATA in pairs(SKILLS_TABLE["SKILLS"]) do
        if type(SKILL_DATA) == "boolean" then
            SKILLS_TABLE["SKILLS"][SKILL_NAME] = { Owned = SKILL_DATA, Enabled = false }
        else
            SKILL_DATA.Owned = SKILL_DATA.Owned or false
            SKILL_DATA.Enabled = SKILL_DATA.Enabled or false
        end
    end

    return SKILLS_TABLE
end

function Functions:RunPromptConnections()
    for _, imagelabel in WebModule.SKILLS:GetDescendants() do
        if not imagelabel:IsA("ImageLabel") then
            continue
        end
        if not imagelabel:FindFirstChild("Click") then
            continue
        end
        if not imagelabel.Parent:GetAttribute("tree") then
            continue
        end
        if not imagelabel:FindFirstChild("Prompt") then
            continue
        end

        local clickbtn = imagelabel.Prompt:FindFirstChild("Click")
        if not clickbtn then
            continue
        end

        local states = {
            [1] = "Activate",
            [2] = "Deactivate"
        }

        clickbtn.MouseButton1Click:Connect(function()

            self:HideOtherPrompts(imagelabel)

            if clickbtn.Text == "Unlock" then
                local Success = self:DoSkillPurchase(imagelabel.Name)
                if Success then
                    imagelabel.ImageColor3 = COLOR_STATES.UNLOCKED
                    imagelabel.Prompt.Click.Text = states[2]
                    task.spawn(function()
                        WebModule.Modules.ClientUtils:PlaySound("ui/misc2.ogg")        
                    end)
                    imagelabel.Prompt.Visible = false
                else
                    warn("failed to buy [not enough SP maybe]")
                    return
                end 

                clickbtn.Parent.Visible = false
                local currentsk = self:GetPlayerSkills(WebModule.Player)

                self:ChangeSkillState(imagelabel.Name, true)
                self:UpdateAllSkills(currentsk)
                self:UpdateOwnedSections(currentsk)
            elseif clickbtn.Text == states[1] then
                self:ChangeSkillState(imagelabel.Name, true)
                clickbtn.Text = states[2]
                imagelabel.ImageColor3 = COLOR_STATES.UNLOCKED

                local currentsk = self:GetPlayerSkills(WebModule.Player)

                self:UpdateAllSkills(currentsk)
                self:UpdateOwnedSections(currentsk)
                imagelabel.Prompt.Visible = false
                task.spawn(function()
                    WebModule.Modules.ClientUtils:PlaySound("ui/misc2.ogg")        
                end)
            elseif clickbtn.Text == states[2] then
                self:ChangeSkillState(imagelabel.Name, false)
                clickbtn.Text = states[1]
                imagelabel.ImageColor3 = COLOR_STATES.STATIC

                local currentsk = self:GetPlayerSkills(WebModule.Player)

                self:UpdateAllSkills(currentsk)
                self:UpdateOwnedSections(currentsk)
                imagelabel.Prompt.Visible = false
                task.spawn(function()
                    WebModule.Modules.ClientUtils:PlaySound("ui/misc2.ogg")        
                end)
            end
        end)
    end
end

function Functions:DoSkillConnections()
    do
        for _, imagelabel in WebModule.SKILLS:GetDescendants() do
            if imagelabel:IsA("ImageLabel") and imagelabel:FindFirstChild("Click") and imagelabel.Parent:GetAttribute("tree") then
                imagelabel.Click.MouseButton1Click:Connect(function()
                    self:HideOtherPrompts(imagelabel)
                    imagelabel.Prompt.Visible = not imagelabel.Prompt.Visible 
                end)
            end
        end 
    end
end

function Functions:DoRotationTask(v)
    do
        task.spawn(function()
            while task.wait() do
                v.Rotation += 1
            end
        end)        
    end
end

function Functions:DoDropdown() -- disabled
    local TreeConfigButtons = WebModule.TreeConfig.TreeConfigButtons
    local DropdownStatus = TreeConfigButtons.DropdownStatus
    local DropdownFrame = TreeConfigButtons.Dropdown
    local Buttons = TreeConfigButtons.Frame

    local Load, Save, Delete = Buttons.ALoad, Buttons.BSave, Buttons.CDelete

    local IsOnDB, DB = false, false
    local KEYS = {
        "↑",
        "↓"
    }

    DropdownStatus.MouseButton1Click:Connect(function()
        if IsOnDB then return end

        IsOnDB = true

        if not DB then
            DB = true
            DropdownStatus.Text = KEYS[1]
            TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {Size = UDim2.new(0, 125, 0, 100)}):Play()
            task.wait(0.3)
            IsOnDB = false
        else
            DB = false
            DropdownStatus.Text = KEYS[2]
            TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {Size = UDim2.new(0, 125, 0, 0)}):Play()
            task.wait(0.3)
            IsOnDB = false
        end
    end)
end

function Functions:GetGlowByName(name)
    for _, imglabel in WebModule.SKILLS:GetDescendants() do
        if imglabel:IsA("ImageLabel") and imglabel.Name == "Glow" then
            if imglabel:GetAttribute("RespectiveTo") == name then
                return imglabel
            end
        end
    end

    return nil
end

function Functions:DoGlowInstances()
    do
        for _, imagelabel in WebModule.SKILLS:GetDescendants() do
            if imagelabel:IsA("ImageLabel") and imagelabel:FindFirstChild("Click") and imagelabel:FindFirstChild("Name") and not (imagelabel.Name == "Glow") and not (imagelabel.Name == "Remort") then
                local new = Instance.new("ImageLabel")
                -- rbxassetid://2785081456

                new.Image = "rbxassetid://252246909"
                new.BackgroundTransparency = 1
                new.Size = UDim2.new(0, 62, 0, 62)
                
                new.Parent = imagelabel.Parent
                new.AnchorPoint = imagelabel.AnchorPoint
                new.Position = imagelabel.Position
                new.Name = "Glow"
                new.ZIndex = -5
                new:SetAttribute("RespectiveTo", imagelabel.Name)

                self:DoRotationTask(new)
            end
        end
    end
end

function Functions:DoTreeButtonsConfig()
    do
        local Buttons = WebModule.TreeConfig.TreeButtons

        local Activate, Deactivate, Reset = Buttons.Activate, Buttons.Deactivate, Buttons.Reset

        Reset.Button.MouseButton1Click:Connect(function()

            if WebModule.Player.PlayerGui.SkillTree:FindFirstChild("RefundSP") then
                return
            end

            self:BlurBG(true)

            local choice, mod, tbl = self:PromptChoice("Warning", "Reset all skills and refund SP?\nYou can only do this once per week.", {
                Yes = "OK",
                No = "Cancel"
            })

            mod:GetClickSignal(tbl.Yes):Connect(function()
                self:BlurBG(false)
                self:RefundSP()
                choice:Destroy()
            end)

            mod:GetClickSignal(tbl.No):Connect(function()
                self:BlurBG(false)
                choice:Destroy()
            end)

            choice.Parent = WebModule.Player.PlayerGui.SkillTree
            choice.ZIndex = 5000
            choice.Name = "RefundSP"
        end)

        Activate.Button.MouseButton1Click:Connect(function()
            for _, imglabel in WebModule.SKILLS:GetDescendants() do
                if imglabel:FindFirstChild("Prompt") and imglabel:IsA("ImageLabel") then
                    self:ChangeSkillState(imglabel.Name, true)
                end
            end
        end)

        Deactivate.Button.MouseButton1Click:Connect(function()
            for _, imglabel in WebModule.SKILLS:GetDescendants() do
                if imglabel:FindFirstChild("Prompt") and imglabel:IsA("ImageLabel") then
                    self:ChangeSkillState(imglabel.Name, false)
                end
            end
        end)
    end
end

function Functions:DoFunctions()
    self:DoConnectors()
    self:DoUI()
    self:DoSectionHovers()
    self:DoSkillConnections()
    self:DoSectionAmount()
    self:DoGlowInstances()
    self:RunPromptConnections()
    self:DoDropdown()
    self:DoTreeButtonsConfig()
    self:UpdateAllSkills(self:GetPlayerSkills(WebModule.Player))

    self:ThinkOnce("SP")
end


function Functions:Init(WebFrame, Player)
	if not WebFrame then
		self:DECLARE_ERROR("WebFrame is required for initialization.")
	end

    for _, gui in ipairs(Player.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Enabled then
            WebModule.PROTECTED_GUIS[gui] = true
        end
    end

    WebModule.Ambient = WebFrame:FindFirstChild("Ambient")
    WebModule.Smoke = WebFrame.Parent:FindFirstChild("Smoke")
    WebModule.data = {
        tree_data = WebFrame:FindFirstChild("data").tree_data,
        current_tree_name = WebFrame:FindFirstChild("data").current_tree_name,
    }

	local Info = WebFrame.Parent:FindFirstChild("Info")
	local Skills = WebFrame:FindFirstChild("Skills")

	for _, btn in ipairs(Skills:GetDescendants()) do
        if btn:IsA("ImageLabel") and btn:FindFirstChild("Name") and btn:FindFirstChild("Click") then
            btn.MouseEnter:Connect(function()
                Functions:OnHover(Info, btn, true)
            end)

            btn.MouseLeave:Connect(function()
                Functions:OnHover(Info, btn, false)
            end)
        end
	end

    for _, sectionopen in Skills:GetChildren() do
        if sectionopen:IsA("Frame") and sectionopen:GetAttribute("Name") and sectionopen:FindFirstChild("Click") and sectionopen:FindFirstChild("Unlocked") then
            local sectionName = sectionopen:GetAttribute("Name")
            sectionopen.Click.MouseButton1Click:Connect(function()
                Functions:OpenSection(sectionName)
            end)
        end
    end

    WebFrame.CloseFrame.Quit.MouseButton1Click:Connect(function()
        Functions:OnClick(WebFrame.CloseFrame.Quit)
    end)

    local Sections = {}

    for _, section in Skills:GetChildren() do
        if section:GetAttribute("tree") and section:IsA("Frame") then
            local skillCount = #section:GetChildren()
            Sections[section.Name] = skillCount
            print("loaded " .. section.Name .. " section with a total of " .. skillCount .. " skills")
        end
    end

    WebModule.Player = Player

    local entity = WebModule.Modules.Entity.new()
    entity:init(Player)

    WebModule.pEntity = entity
    print(WebModule.pEntity)
    warn("boy.")
    WebModule.SKILLS = Skills
    WebModule.CONNECTOR_LINE = WebFrame.WebClient:FindFirstChild("ConnectorLine")
    WebModule.LevelFrame = WebFrame:FindFirstChild("LevelFrame")
    WebModule.TreeConfig = WebFrame:FindFirstChild("TreeConfig")
    
    Functions:DoFunctions()
end

WebModule.Funcs = Functions
WebModule.Strings = Strings

if RunService:IsClient() then
    print("web module required by client")
elseif RunService:IsServer() then
    print("web module required by server")
end

return WebModule
