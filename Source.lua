--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback 
end

cloneref = missing("function", cloneref, function(...) return ... end)

local Services = setmetatable({}, {
    __index = function(_, name)
        return cloneref(game:GetService(name))
    end
})

local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
end)

--// Settings
local Settings = {}
Settings["Stop On Move"] = true
Settings["Fade In"]     = 0.1
Settings["Fade Out"]    = 0.1
Settings["Weight"]      = 1
Settings["Speed"]       = 1
Settings["Allow Invisible"]    = true
Settings["Time Position"] = 0

local CurrentTrack
local lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()

local FIXED_EMOTE_ID = 93224413172183

local function LoadTrack()
    if CurrentTrack then 
        CurrentTrack:Stop(0) 
    end

    local animId = "rbxassetid://" .. tostring(FIXED_EMOTE_ID)
    
    local success, result = pcall(function()
        return game:GetObjects(animId)
    end)
    
    if success and result and #result > 0 then
        local anim = result[1]
        if anim:IsA("Animation") then
            animId = anim.AnimationId
        end
        for _, obj in ipairs(result) do
            pcall(function() obj:Destroy() end)
        end
    end

    local newAnim = Instance.new("Animation")
    newAnim.AnimationId = animId
    local newTrack = humanoid:LoadAnimation(newAnim)
    newTrack.Priority = Enum.AnimationPriority.Action4

    local weight = Settings["Weight"]
    if weight == 0 then
        weight = 0.001
    end

    newTrack:Play(Settings["Fade In"], weight, Settings["Speed"])
    
    CurrentTrack = newTrack
    
    task.wait(0.1)
    if CurrentTrack.Length > 0 then
        CurrentTrack.TimePosition = math.clamp(Settings["Time Position"], 0, 1) * CurrentTrack.Length
    end

    return newTrack
end

local function StopTrack()
    if CurrentTrack then
        CurrentTrack:Stop(Settings["Fade Out"])
        CurrentTrack = nil
    end
end

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SettingsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = Services.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 200)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "SKYBOX OF THE VOID"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BorderColor3 = Color3.fromRGB(255, 255, 255)
title.BorderSizePixel = 1
title.Parent = mainFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 0, 30)
buttonContainer.Position = UDim2.new(0, 10, 0, 35)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0.48, 0, 1, 0)
playButton.Position = UDim2.new(0, 0, 0, 0)
playButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
playButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
playButton.BorderSizePixel = 2
playButton.Text = "▶ Play"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Font = Enum.Font.GothamBold
playButton.TextSize = 14
playButton.Parent = buttonContainer
Instance.new("UICorner", playButton).CornerRadius = UDim.new(0, 6)

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.48, 0, 1, 0)
stopButton.Position = UDim2.new(0.52, 0, 0, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
stopButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
stopButton.BorderSizePixel = 2
stopButton.Text = "■ Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Parent = buttonContainer
Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 6)

playButton.MouseButton1Click:Connect(function()
    CurrentTrack = LoadTrack()
end)

stopButton.MouseButton1Click:Connect(function()
    StopTrack()
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -85)
scrollFrame.Position = UDim2.new(0, 10, 0, 75)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scrollFrame.Parent = mainFrame

RunService.RenderStepped:Connect(function()
    if character.PrimaryPart then
        if Settings["Stop On Move"] and CurrentTrack and CurrentTrack.IsPlaying then
            local moved = (character.PrimaryPart.Position - lastPosition).Magnitude > 0.1
            local jumped = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping
            
            if moved or jumped then
                CurrentTrack:Stop(Settings["Fade Out"])
                CurrentTrack = nil
            end
        end
        lastPosition = character.PrimaryPart.Position
    end
end)

local function lockX()
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y)
end

scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(lockX)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 6)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

local function createSlider(name, min, max, default)
    Settings[name] = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    bg.BorderColor3 = Color3.fromRGB(255, 255, 255)
    bg.BorderSizePixel = 2
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.2f", name, Settings[name])
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.5, -20, 0, 20)
    textBox.Position = UDim2.new(0.5, 10, 0, 5)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
    textBox.BorderSizePixel = 2
    textBox.Text = tostring(Settings[name])
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    textBox.Parent = bg
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -40, 0, 12)
    sliderBar.Position = UDim2.new(0, 20, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.BorderColor3 = Color3.fromRGB(255, 255, 255)
    sliderBar.BorderSizePixel = 1
    sliderBar.Parent = bg
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 6)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 6)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    thumb.BorderColor3 = Color3.fromRGB(0, 0, 0)          -- borde negro en el círculo
    thumb.BorderSizePixel = 2
    thumb.Parent = sliderBar
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local function tweenVisual(rel)
        local visualRel = math.clamp(rel, 0, 1)
        TweenService:Create(sliderFill, TweenInfo.new(0.15), {Size = UDim2.new(visualRel, 0, 1, 0)}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.15), {Position = UDim2.new(visualRel, 0, 0.5, 0)}):Play()
    end

    local function applyValue(value)
        Settings[name] = value
        label.Text = string.format("%s: %.2f", name, value)
        textBox.Text = tostring(value)
        
        local visualValue = math.clamp(value, min, max)
        local rel = (visualValue - min) / (max - min)
        tweenVisual(rel)

        if CurrentTrack and CurrentTrack.IsPlaying then
            if name == "Speed" then
                CurrentTrack:AdjustSpeed(Settings["Speed"])
            elseif name == "Weight" then
                local weight = Settings["Weight"]
                if weight == 0 then weight = 0.001 end
                CurrentTrack:AdjustWeight(weight)
            elseif name == "Time Position" then
                if CurrentTrack and CurrentTrack.IsPlaying and CurrentTrack.Length > 0 then
                    CurrentTrack.TimePosition = math.clamp(value, 0, 1) * CurrentTrack.Length
                end
            end
        end
    end
   
    local dragging = false
    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor((min + (max - min) * relX) * 100) / 100
        applyValue(value)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(textBox.Text)
            if num then
                applyValue(num)
            else
                textBox.Text = tostring(Settings[name])
            end
        end
    end)

    applyValue(Settings[name])
end

local function createToggle(name)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    container.BorderColor3 = Color3.fromRGB(255, 255, 255)
    container.BorderSizePixel = 2
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 24)
    toggleBtn.Position = UDim2.new(1, -70, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)          -- fondo blanco siempre
    toggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BorderSizePixel = 2
    toggleBtn.Text = Settings[name] and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)                      -- letras negras
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    toggleBtn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        toggleBtn.Text = Settings[name] and "ON" or "OFF"
        -- fondo siempre blanco, solo cambia el texto
    end)
end

-- Crear controles
createToggle("Stop On Move")
createSlider("Time Position", 0, 1, Settings["Time Position"])
createSlider("Speed", 0, 5, Settings["Speed"])
createSlider("Weight", 0, 1, Settings["Weight"])
createSlider("Fade In", 0, 2, Settings["Fade In"])
createSlider("Fade Out", 0, 2, Settings["Fade Out"])
createToggle("Allow Invisible")

-- Colisiones invisibles (sin cambios)
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local originalCollisionStates = {}
local lastFixClipState = Settings["Allow Invisible"]

local function saveCollisionStates()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= humanoidRootPart then
            originalCollisionStates[part] = part.CanCollide
        end
    end
end

local function disableCollisionsExceptRootPart()
    if not Settings["Allow Invisible"] then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= humanoidRootPart then
            part.CanCollide = false
        end
    end
end

local function restoreCollisionStates()
    for part, canCollide in pairs(originalCollisionStates) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
    originalCollisionStates = {}
end

saveCollisionStates()

local connection = RunService.Stepped:Connect(function()
    if character and character.Parent then
        local current = Settings["Allow Invisible"]
        if lastFixClipState ~= current then
            if current then
                saveCollisionStates()
                disableCollisionsExceptRootPart()
            else
                restoreCollisionStates()
            end
            lastFixClipState = current
        elseif current then
            disableCollisionsExceptRootPart()
        end
    else
        restoreCollisionStates()
        connection:Disconnect()
    end
end)

player.CharacterAdded:Connect(function(newChar)
    restoreCollisionStates()
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    saveCollisionStates()
    lastFixClipState = Settings["Allow Invisible"]
    
    if connection then connection:Disconnect() end
    
    connection = RunService.Stepped:Connect(function()
        if character and character.Parent then
            local current = Settings["Allow Invisible"]
            if lastFixClipState ~= current then
                if current then
                    saveCollisionStates()
                    disableCollisionsExceptRootPart()
                else
                    restoreCollisionStates()
                end
                lastFixClipState = current
            elseif current then
                disableCollisionsExceptRootPart()
            end
        else
            restoreCollisionStates()
            connection:Disconnect()
        end
    end)
end)
