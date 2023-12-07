local DiscordCommand = require("../../Classes/DiscordCommand")
local DiscordAPI = require("../../../Submodules/DiscordLuaU/Source")

local SetReplyPercentCommand = DiscordCommand.new("set-reply-percent")

function SetReplyPercentCommand:OnActivated(interactionObject)
	self.DiscordClient.AI.ResponsePercent = 1 - (interactionObject.Data.Options[1].Value / 100)

	interactionObject:SendMessageAsync(DiscordAPI.DiscordMessage.new(`I've updated the response percent lol`))
end

function SetReplyPercentCommand:BuildCommand()
	return DiscordAPI.ApplicationCommand
		.new()
		:SetType(DiscordAPI.ApplicationCommand.Type.ChatInput)
		:SetName(SetReplyPercentCommand.Name)
		:SetDescription("Set the discord AI context")
		:AddOption(
			DiscordAPI.ApplicationCommandOptions
				.new()
				:SetName("prompt")
				:SetDescription("discord AI prompt")
				:SetType(DiscordAPI.ApplicationCommandOptions.Type.String)
				:SetRequired(true)
				:SetMinValue(0)
				:SetMaxValue(100)
		)
end

return SetReplyPercentCommand
