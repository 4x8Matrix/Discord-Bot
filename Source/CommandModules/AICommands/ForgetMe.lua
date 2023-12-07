local DiscordCommand = require("../../Classes/DiscordCommand")
local DiscordAPI = require("../../../Submodules/DiscordLuaU/Source")

local ForgetMeCommand = DiscordCommand.new("forget-me")

function ForgetMeCommand:OnActivated(interactionObject)
	self.DiscordClient.AI.UserContext[interactionObject.User.Id] = nil

	interactionObject:SendMessageAsync(
		DiscordAPI.DiscordMessage.new(`I have magically forgetten our convo! Feel free to message me again or whatever`)
	)
end

function ForgetMeCommand:BuildCommand()
	return DiscordAPI.ApplicationCommand
		.new()
		:SetType(DiscordAPI.ApplicationCommand.Type.ChatInput)
		:SetName(ForgetMeCommand.Name)
		:SetDescription("Forget about your existance!")
end

return ForgetMeCommand
