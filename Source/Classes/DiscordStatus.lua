local DiscordAPI = require("../../Submodules/DiscordLuaU/Source")

local Console = require("../Dependencies/Github/Console")

local DiscordStatus = {}

DiscordStatus.Interface = {}
DiscordStatus.Prototype = {}

function DiscordStatus.Prototype:UpdateStatus()
	local discordPresence = DiscordAPI.DiscordPresence.new()
	local discordActivity = DiscordAPI.DiscordActivity.new()

	discordActivity:SetActivityName("AsyncMatrix program at 3AM")
	discordActivity:SetActivityType(DiscordAPI.DiscordActivity.Type.Watching)

	discordPresence:SetStatus(DiscordAPI.DiscordPresence.Status.Idle)
	discordPresence:AddActivity(discordActivity)

	self.DiscordClient:UpdatePresenceAsync(discordPresence):andThen(function()
		self.Reporter:Log(`Updated Presence for '{self.DiscordClient.User.Username}'!`)
	end)
end

function DiscordStatus.Interface.new(discordClient)
	return setmetatable({
		DiscordClient = discordClient,
		
		Reporter = Console.new("DiscordStatus"),
	}, { __index = DiscordStatus.Prototype })
end

return DiscordStatus.Interface