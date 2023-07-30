local DiscordAPI = require("../Submodules/DiscordLuaU/Source")
local DotEnv = require("../.env")

local DiscordCommands = require("Classes/DiscordCommands")
local DiscordStatus = require("Classes/DiscordStatus")

local Console = require("Dependencies/Github/Console")

local DiscordClient = DiscordAPI.DiscordClient.new(
	DiscordAPI.DiscordSettings.new()
		:SetDiscordToken(DotEnv.DISCORD_BOT_TOKEN)
		:SetIntents(DiscordAPI.DiscordIntents.all())
)

DiscordClient:Subscribe("OnInteraction", function(interactionObject)
	DiscordClient.Commands:InvokeCommand(interactionObject.Data.Name, interactionObject)
end)

DiscordClient:Subscribe("OnReady", function()
	DiscordClient.RuntimeReporter:Log(`Bot '{DiscordClient.User.Username}' is alive!`)
	DiscordClient.RuntimeReporter:Log(`Building application commands for '{DiscordClient.Application.Id}'!`)

	DiscordClient.Status:UpdateStatus()
	DiscordClient.Commands:UpdateCommands()
end)

DiscordClient:SetVerboseLogging(true)

Console.setGlobalSchema("[💿][%s][%s]: %s")
DiscordAPI.Console.setGlobalSchema("[📀][%s][%s]: %s")

DiscordClient:ConnectAsync():andThen(function()
	DiscordClient.RuntimeReporter = Console.new("DiscordClient")
	DiscordClient.Status = DiscordStatus.new(DiscordClient)
	DiscordClient.Commands = DiscordCommands.new(DiscordClient)
end):catch(function(exceptionMessage)
	print(`Discord bot failed to launch: {exceptionMessage}`)
end)