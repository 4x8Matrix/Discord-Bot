local Console = require("../Dependencies/Github/Console")

local FileSystem = require("@lune/fs")

local COMMAND_MODULE_ABSOLUTE_PATH = "Source/CommandModules"

local DiscordCommands = {}

DiscordCommands.Interface = {}
DiscordCommands.Prototype = {}

function DiscordCommands.Prototype:InvokeCommand(commandName, interactionObject)
	local commandModuleName = self.InteractionReferences[commandName]
	local commandModule = commandModuleName and self.CommandModules[commandModuleName]

	if not commandModule then
		self.Reporter:Warn(`Failed to locate application command '{commandName}'`)

		return
	end

	if not commandModule:CanActivate(interactionObject) then
		self.Reporter:Log(`Command '{commandName}' failed ':CanActivate' call - dropping interaction!`)

		return
	end

	self.Reporter:Debug(`User {interactionObject.User.Username} has invoked command '{commandName}'!`)

	return commandModule:OnActivated(interactionObject)
end

function DiscordCommands.Prototype:UpdateCommands()
	local discordCommandObjects = {}

	for _, commandObject in self.CommandModules do
		local discordCommandObject = commandObject:BuildCommand()

		if not discordCommandObject then
			continue
		end

		self.InteractionReferences[discordCommandObject.CommandName] = commandObject.Name

		table.insert(discordCommandObjects, discordCommandObject)
	end

	for _, discordCommandObject in discordCommandObjects do
		self.DiscordClient.Application:CreateGlobalCommandAsync(discordCommandObject):andThen(function()
			self.Reporter:Log(`Registered '{discordCommandObject.CommandName}' Application Command!`)
		end)
	end

	self.Reporter:Log(`Registered {#discordCommandObjects} Commands under {self.CommandGroupCount} Groups!`)
end

function DiscordCommands.Prototype:LoadHotCommandFolder(commandFolder)
	self.CommandGroups[commandFolder] = FileSystem.readDir(`{COMMAND_MODULE_ABSOLUTE_PATH}/{commandFolder}`)

	for _, commandModuleName in self.CommandGroups[commandFolder] do
		commandModuleName = string.sub(commandModuleName, 0, -5)

		FileSystem.copy(
			`{COMMAND_MODULE_ABSOLUTE_PATH}/{commandFolder}/{commandModuleName}.lua`,
			`{COMMAND_MODULE_ABSOLUTE_PATH}/{commandFolder}/{commandModuleName}-tmp-{self.HotReloadIndex}.lua`,
			{ overwrite = true }
		)

		local commandModule = require(`../CommandModules/{commandFolder}/{commandModuleName}-tmp-{self.HotReloadIndex}`)

		self.CommandModules[commandModule.Name] = commandModule
		self.CommandModules[commandModule.Name].DiscordClient = self.DiscordClient

		FileSystem.removeFile(
			`{COMMAND_MODULE_ABSOLUTE_PATH}/{commandFolder}/{commandModuleName}-tmp-{self.HotReloadIndex}.lua`
		)
	end
end

function DiscordCommands.Prototype:LoadHotCommands()
	self.CommandGroupCount = 0
	self.HotReloadIndex += 1

	self.CommandGroups = {}
	self.CommandModules = {}

	for _, commandFolder in FileSystem.readDir(COMMAND_MODULE_ABSOLUTE_PATH) do
		self.CommandGroupCount += 1

		self:LoadHotCommandFolder(commandFolder)
	end
end

function DiscordCommands.Prototype:DestroyAllExistingCommands()
	self.DiscordClient.Application:GetAllGuildCommandsAsync(737382889947136000):andThen(function(guildCommands)
		for _, guildCommandMetadata in guildCommands do
			self.DiscordClient.Application:DeleteGuildCommandAsync(737382889947136000, guildCommandMetadata.id):await()

			self.Reporter:Log(`Deleted command '{guildCommandMetadata.name}'`)
		end
	end)
end

function DiscordCommands.Interface.new(discordClient)
	local self = setmetatable({
		DiscordClient = discordClient,

		Reporter = Console.new("DiscordCommands"),

		CommandGroupCount = 0,
		HotReloadIndex = 0,

		CommandGroups = {},
		CommandModules = {},

		InteractionReferences = {},
	}, { __index = DiscordCommands.Prototype })

	self:LoadHotCommands()

	self.Reporter:Log(`Initiated {#self.CommandModules} Commands under {self.CommandGroupCount} Groups!`)

	return self
end

return DiscordCommands.Interface
