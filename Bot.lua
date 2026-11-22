
--!strict
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

local botEnabled = false
local generation = 0

-- GUI MENU
local gui = Instance.new("ScreenGui")
gui.Name = "LunyxBotMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(190, 105)
frame.Position = UDim2.new(0.5, -95, 0.5, -52)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "LUNYX BOT"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 42)
toggle.Position = UDim2.fromOffset(10, 48)
toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
toggle.Text = "START"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 16
toggle.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggle

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Lunyx Bot",
            Text = message,
            Duration = 3
        })
    end)
end

local function runBot(myGeneration)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Không teleport, giữ nguyên vị trí hiện tại
    task.wait(1)

    if not botEnabled or myGeneration ~= generation then
        return
    end

    notify("Bot đang hoạt động!")

    -- Tìm và đuổi theo người chơi gần nhất
    task.spawn(function()
        while botEnabled
            and myGeneration == generation
            and character.Parent do

            local closest = nil
            local shortest = math.huge

            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and other.Character then
                    local otherRoot =
                        other.Character:FindFirstChild("HumanoidRootPart")
                    local otherHumanoid =
                        other.Character:FindFirstChild("Humanoid")

                    if otherRoot and otherHumanoid
                        and otherHumanoid.Health > 0 then

                        local distance =
                            (hrp.Position - otherRoot.Position).Magnitude

                        if distance < shortest then
                            shortest = distance
                            closest = otherRoot
                        end
                    end
                end
            end

            if closest then
                humanoid:MoveTo(closest.Position)

                if (hrp.Position - closest.Position).Magnitude <= 10 then
                    humanoid.Jump = true
                end
            end

            task.wait(0.1)
        end
    end)

    -- Tự kích hoạt công cụ đang cầm
    task.spawn(function()
        while botEnabled
            and myGeneration == generation
            and character.Parent do

            local tool = character:FindFirstChildOfClass("Tool")

            if tool then
                pcall(function()
                    tool:Activate()

                    local remote =
                        tool:FindFirstChildWhichIsA("RemoteEvent", true)

                    if remote then
                        remote:FireServer()
                    end
                end)
            end

            task.wait(0.1)
        end
    end)

    -- Nhấn phím E định kỳ
    task.spawn(function()
        while botEnabled
            and myGeneration == generation
            and character.Parent do

            pcall(function()
                VirtualInputManager:SendKeyEvent(
                    true, Enum.KeyCode.E, false, nil
                )
                VirtualInputManager:SendKeyEvent(
                    false, Enum.KeyCode.E, false, nil
                )
            end)

            task.wait(math.random(1, 10))
        end
    end)
end

local function startBot()
    if botEnabled then return end

    botEnabled = true
    generation += 1

    toggle.Text = "STOP"
    toggle.BackgroundColor3 = Color3.fromRGB(40, 150, 75)

    task.spawn(runBot, generation)
end

local function stopBot()
    if not botEnabled then return end

    botEnabled = false
    generation += 1

    toggle.Text = "START"
    toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 45)

    notify("Bot đã dừng!")
end

toggle.MouseButton1Click:Connect(function()
    if botEnabled then
        stopBot()
    else
        startBot()
    end
end)

-- Tự chạy lại sau khi hồi sinh nếu bot đang bật
player.CharacterAdded:Connect(function()
    if botEnabled then
        generation += 1
        local currentGeneration = generation

        task.wait(1)

        if botEnabled and currentGeneration == generation then
            task.spawn(runBot, currentGeneration)
        end
    end
end)

notify("Menu đã sẵn sàng!")
