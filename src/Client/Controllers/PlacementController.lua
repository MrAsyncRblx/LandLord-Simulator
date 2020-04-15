-- Placement Controller
-- MrAsync
-- April 3, 2020


--[[

    Handle signals and method calls from and to the PlacementApi

    Methods
        private void ShowQueue()
        private void HideQueue()
        
]]



local PlacementController = {}


--//Api
local PlacementApi
local RoadApi

--//Services
local TweenService = game:GetService("TweenService")

local PlacementService
local MetaDataService

--//Controllers
local NotificationDispatcher

--//Classes

--//Locals
local PlotObject

local PlayerGui
local PlacementSelectionQueue

local selectedPlacement


--Shows the selection queue
local function ShowQueue()
    PlacementSelectionQueue.Container.Size = UDim2.new(0, 0, 0, 0)

    PlacementSelectionQueue.Container.Visible = true
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
end


--Hides the selection queue
local function HideQueue()
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.25, true, function()
        PlacementSelectionQueue.Enabled = false
        PlacementSelectionQueue.Adornee = nil

        PlacementSelectionQueue.Container.Visible = false
    end)
end


--Resets the selection queue adornee
local function ResetSelection()
    PlacementSelectionQueue.Adornee = nil
    selectedPlacement = nil
end


function PlacementController:Start()
    --[[
        PlacementApi intereaction
    ]]
    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local placementSuccess, model, noticeIden = PlacementService:PlaceObject(itemId, localPosition)

        NotificationDispatcher:Dispatch(noticeIden)
    end)

    --When player finishes moving an object, tell server
    PlacementApi.ObjectMoved:Connect(function(guid, localPosition, oldPosition)
        local moveSuccess, noticeIden = PlacementService:MovePlacement(guid, localPosition)
        HideQueue()
        ResetSelection()

        NotificationDispatcher:Dispatch(noticeIden)

        --If move success, stop placing
        if (moveSuccess) then
            PlacementApi:StopPlacing()
        else
            PlacementApi:StopPlacing(true)
        end
    end)
    

    --[[
        Selection Queue
    ]]
    --When player selects placed object, setup PlacementSelectionQueue, tween
    PlacementApi.PlacementSelectionStarted:Connect(function(placementObject)
        PlacementSelectionQueue.StudsOffsetWorldSpace = Vector3.new(0, placementObject.PrimaryPart.Size.Y, 0)
        PlacementSelectionQueue.Adornee = placementObject.PrimaryPart
        PlacementSelectionQueue.Enabled = true

        --Only tween UI if selectedPlacement fresh, or hot-selecting a different placementObject
        if (not selectedPlacement or (selectedPlacement and (placementObject ~= selectedPlacement))) then
            ShowQueue()
        end
        
        selectedPlacement = placementObject
    end)

    --When player stops selecting a placedObject, tween, cleanup PlacementSelectionQueue
    PlacementApi.PlacementSelectionEnded:Connect(function(placementObject)
        selectedPlacement = nil
        HideQueue()
    end)


    --[[
        SelectionQueue buttons
    ]]
    local actionButtons = PlacementSelectionQueue.Container.Buttons

    actionButtons.Sell.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            local sellSuccess, noticeIden = PlacementService:SellPlacement(selectedPlacement.Name)
       
            NotificationDispatcher:Dispatch(noticeIden)
        end
    end)

    actionButtons.Upgrade.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            local upgradeSuccess, upgradedModel, noticeIden = PlacementService:UpgradePlacement(selectedPlacement.Name)

            --Reset selection queue to new model
            if (upgradeSuccess and upgradedModel) then
                PlacementSelectionQueue.StudsOffsetWorldSpace = Vector3.new(0, upgradedModel.PrimaryPart.Size.Y, 0)
                PlacementSelectionQueue.Adornee = upgradedModel.PrimaryPart
            end

            NotificationDispatcher:Dispatch(noticeIden)
        end
    end)

    actionButtons.Move.MouseButton1Click:Connect(function()
        if (selectedPlacement) then     
            HideQueue()      
            PlacementApi:StartPlacing(selectedPlacement)
        end
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.API.PlacementApi
    RoadApi = self.Modules.API.RoadApi

    --//Services
    PlacementService = self.Services.PlacementService
    MetaDataService = self.Services.MetaDataService

    --//Controllers
    NotificationDispatcher = self.Controllers.NotificationDispatcher

    --//Classes

    --//Locals
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlacementSelectionQueue = PlayerGui:WaitForChild("PlacementSelectionQueue")

    PlotObject = self.Player:WaitForChild("PlotObject").Value
        
end


return PlacementController