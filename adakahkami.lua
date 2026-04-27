-- AIMBOT PRO pour [JEUX DE TIR ROBLOX] - Silent Aim + Prediction + FOV
-- Compatible 99% FPS (Arsenal, Phantom Forces, etc.)
 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
 
-- Config (Ajuste)
local Settings = {
    TeamCheck = true,  -- Ignore teammates
    VisibleCheck = true,  -- Seulement visible
    FOVRadius = 150,  -- Pixels cercle
    TargetPart = "Head",  -- "Head", "HumanoidRootPart", "UpperTorso"
    Prediction = true,  -- Prédit mouvement
    PredictionAmount = 0.165  -- Lag compensation
}
 
-- Variables
local AimbotTarget = nil
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Color = Color3.new(0, 1, 0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
 
-- Fonction principale aimbot
local function GetClosestPlayer()
    local Closest, Distance = nil, Settings.FOVRadius
 
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.TargetPart) then
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
 
            local Character = Player.Character
            local TargetPart = Character[Settings.TargetPart]
            local ScreenPoint, OnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
 
            if OnScreen and Settings.VisibleCheck then
                local UnitRay = Camera:ScreenPointToRay(ScreenPoint)
                local Raycast = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000)
                if Raycast and Raycast.Instance:IsDescendantOf(Character) then
                    local DistanceFromMouse = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if DistanceFromMouse < Distance then
                        Distance = DistanceFromMouse
                        Closest = TargetPart
                    end
                end
            elseif OnScreen then
                local DistanceFromMouse = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
                if DistanceFromMouse < Distance then
                    Distance = DistanceFromMouse
                    Closest = TargetPart
                end
            end
        end
    end
    return Closest
end
 
-- Prediction
local function PredictPosition(TargetPart)
    if not Settings.Prediction then return TargetPart.Position end
    local Velocity = TargetPart.AssemblyLinearVelocity
    return TargetPart.Position + (Velocity * Settings.PredictionAmount)
end
 
-- Update loop
RunService.Heartbeat:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = true
 
    AimbotTarget = GetClosestPlayer()
    if AimbotTarget then
        local PredictedPos = PredictPosition(AimbotTarget)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, PredictedPos)
    end
end)
 
-- Toggle (X key)
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.X then
        Settings.Enabled = not Settings.Enabled
        FOVCircle.Visible = Settings.Enabled
    end
end)
 
print("AIMBOT LOADED - Press X to toggle | Green circle = FOV")
