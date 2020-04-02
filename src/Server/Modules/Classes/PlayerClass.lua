-- Player Class
-- MrAsync
-- March 17, 2020



local PlayerClass = {}
PlayerClass.__index = PlayerClass


--//Api
local DataStore2
local TableUtil

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--//Controllers

--//Classes

--//Locals
local PlayerMetaData

local VALUE_EXCHANGE = {
	["number"] = "NumberValue",
	["string"] = "StringValue",
	["boolean"] = "BoolValue",
	["table"] = "StringValue",
}


function PlayerClass.new(player)

	local self = setmetatable({

		Player = player,
		Placements = {},

		DataKeys = {},
		DataFolder = ReplicatedStorage.ReplicatedData:FindFirstChild(tonumber(player.UserId))
	}, PlayerClass)

	--Construct a new DataFolder
	--Allows client to easily access parts of PlayersData
	local dataFolder = Instance.new("Folder")
	dataFolder.Name = player.UserId
	dataFolder.Parent = ReplicatedStorage.ReplicatedData

	--Store DataStore2 DataKeys
	for key, value in pairs(PlayerMetaData.MetaData) do
		self.DataKeys[key] = DataStore2(key, player)

		--Values beginning with '_' are not replicated to the Client
		if (string.sub(key, 1, 1) ~= '_') then
			--Construct a new serializedNode so client can detect changes efficiently
			local serializedNode = Instance.new(VALUE_EXCHANGE[type(value)])
			serializedNode.Name = key
			serializedNode.Parent = dataFolder

			--Tables are stored as encoded JSON, encode if needed
			--Else, set value like normal
			if (type(value) == "table") then
				serializedNode.Value = TableUtil.EncodeJSON( self:GetData(key) )
			else
				serializedNode.Value = self:GetData(key)
			end

			--Automatically update replicated values
			self.DataKeys[key]:OnUpdate(function(newValue)
				if (type(newValue) == "table") then
					serializedNode.Value = TableUtil.Encode(newValue)
				else
					serializedNode.Value = newValue
				end
			end)
		end
	end 

	self.DataFolder = dataFolder

	return self
end

--//Returns DataStore2 Data
function PlayerClass:GetData(key)
	return self.DataKeys[key]:Get(PlayerMetaData.MetaData[key])
end


--//Sets DataStore2 Key Data
function PlayerClass:SetData(key, value)
	local leaderstatsValue = self.Player.leaderstats:FindFirstChild(key)
	if (leaderstatsValue) then leaderstatsValue.Value = value end

	return self.DataKeys[key]:Set(value)
end


function PlayerClass:Start()

	--Combine all keys to master PlayerData key
	for key, value in pairs(PlayerMetaData.MetaData) do
		DataStore2.Combine("PlayerData", key)
	end
end


function PlayerClass:Init()
	--//Api
	DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
	TableUtil = self.Shared.TableUtil

	--//Services
	
	--//Controllers
	
	--//Classes
	
	--//Locals
	PlayerMetaData = require(ReplicatedFirst.MetaData:WaitForChild("Player"))

end


return PlayerClass