local DiscordCommand = require("../../Classes/DiscordCommand")
local DiscordAPI = require("../../../Submodules/DiscordLuaU/Source")

local FileSystem = require("@lune/fs")

local COMMAND_MODULE_ABSOLUTE_PATH = "Source/CommandModules"

local HotReloadCommand = DiscordCommand.new("hot-reload-commands")

function HotReloadCommand:HotReloadAllCommands()
	self.DiscordClient.Commands:LoadHotCommands()

	return DiscordAPI.DiscordEmbed.new()
		:SetTitle(`Success`)
		:SetDescription(`Successfully reloaded all commands`)
		:SetColor(0x808080)
end

function HotReloadCommand:HotReloadCommandFolder(commandFolder)
	if not FileSystem.isDir(`{COMMAND_MODULE_ABSOLUTE_PATH}/{commandFolder}`) then
		return DiscordAPI.DiscordEmbed.new()
			:SetTitle("FileSystem Error")
			:SetDescription(`Unable to locate command module **'{commandFolder}'**!`)
			:SetColor(0xFF0000)
	end

	self.DiscordClient.Commands:LoadHotCommandFolder(commandFolder)

	return DiscordAPI.DiscordEmbed.new()
		:SetTitle(`Success`)
		:SetDescription(`Successfully reloaded all commands for {commandFolder}`)
		:SetColor(0x808080)
end

function HotReloadCommand:OnActivated(interactionObject)
	local discordMessage = DiscordAPI.DiscordMessage.new()
	local embedObject

	if interactionObject.Data.Options then
		local commandFolder = interactionObject.Data.Options[1].Value

		embedObject = self:HotReloadCommandFolder(commandFolder)
	else
		embedObject = self:HotReloadAllCommands()
	end

	discordMessage:AddEmbed(embedObject)

	interactionObject:SendMessageAsync(discordMessage)
end

function HotReloadCommand:BuildCommand()
	return DiscordAPI.ApplicationCommand.new()
		:SetType(DiscordAPI.ApplicationCommand.Type.ChatInput)
		:SetName(HotReloadCommand.Name)
		:SetDescription(`Swap out '{self.DiscordClient.User.Username}' discord commands for the latest version.`)
		:AddOption(
			DiscordAPI.ApplicationCommandOptions.new()
				:SetName("command-module")
				:SetDescription("Optional argument to only reload a specific command folder")
				:SetType(DiscordAPI.ApplicationCommandOptions.Type.String)
				:SetRequired(false)
				:SetMinLength(1)
		)
end

return HotReloadCommand