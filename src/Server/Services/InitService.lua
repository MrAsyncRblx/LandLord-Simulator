-- Init Service
-- MrAsync
-- June 26, 2020



local InitService = {Client = {}}
InitService.__aeroOrder = 1

--//Api
local NumberUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--//Classes

--//Controllers

--//Locals



function InitService:Start()
--[[
    for _, model in pairs(Workspace.Items:GetChildren()) do
        if (not model:IsA("Model")) then continue end

        local orientation, size = model:GetBoundingBox()
        local decor = Instance.new("Folder")
        decor.Name = "Decor"
        decor.Parent = model

        local primaryPart = Instance.new("Part")
        primaryPart.Parent = model
        primaryPart.Size = size + Vector3.new(0.01, 0.01, 0.01)
        primaryPart.Size = Vector3.new(math.ceil(primaryPart.Size.X), primaryPart.Size.Y, math.ceil(primaryPart.Size.Z))
        primaryPart.CFrame = CFrame.new(orientation.Position - Vector3.new(0, 0.01, 0)) * CFrame.Angles(0, 0, 0)
        primaryPart.Transparency = 0.5
        primaryPart.Color = Color3.fromRGB(0, 0, 255)
        primaryPart.Anchored = true
        primaryPart.CanCollide = false
        primaryPart.Name = "PrimaryPart"
        primaryPart.TopSurface = Enum.SurfaceType.Smooth
        primaryPart.BottomSurface = Enum.SurfaceType.Smooth

        for _, part in pairs(model:GetChildren()) do
            if (part:IsA("Folder") or part.Name == "PrimaryPart") then continue end
            part.Parent = decor

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = primaryPart
            weld.Part1 = part
            weld.Parent = part

            part.CanCollide = false
            part.Anchored = false
        end

        model.PrimaryPart = primaryPart
    end
]]--    

--[[
    for _, part in pairs(game.Selection:Get()[1]:GetChildren()) do
        if (not part:FindFirstChild("WeldConstraint")) then continue end
    
        part.WeldConstraint:Destroy()
    end
]]    

    Workspace.Items.Parent = ReplicatedStorage
    Workspace.Particles.Parent = ReplicatedStorage
end


function InitService:Init()
	--//Api
    NumberUtil = self.Shared.NumberUtil

    --//Services
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return InitService