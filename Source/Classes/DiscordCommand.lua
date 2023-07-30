local Console = require("../Dependencies/Github/Console")

local DiscordCommand = {}

DiscordCommand.Interface = {}
DiscordCommand.Prototype = {}

function DiscordCommand.Prototype:OnActivated() end

function DiscordCommand.Prototype:BuildCommand()
	return false
end

function DiscordCommand.Prototype:CanActivate()
	return true
end

function DiscordCommand.Interface.new(commandName)
	return setmetatable({
		Name = commandName,
		Reporter = Console.new(commandName)
	}, { __index = DiscordCommand.Prototype })
end

return DiscordCommand.Interface