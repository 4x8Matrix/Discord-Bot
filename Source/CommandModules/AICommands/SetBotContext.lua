local DiscordCommand = require("../../Classes/DiscordCommand")
local DiscordAPI = require("../../../Submodules/DiscordLuaU/Source")

local SetBotContextCommand = DiscordCommand.new("set-ai-context")

function SetBotContextCommand:OnActivated(interactionObject)
	self.DiscordClient.AI.AiContext = interactionObject.Data.Options[1].Value

	interactionObject:SendMessageAsync(
		DiscordAPI.DiscordMessage.new(
			`I've updated the tone/context of the bot, uhhhh, this'll change for everyone lol.`
		)
	)
end

function SetBotContextCommand:BuildCommand()
	return DiscordAPI.ApplicationCommand
		.new()
		:SetType(DiscordAPI.ApplicationCommand.Type.ChatInput)
		:SetName(SetBotContextCommand.Name)
		:SetDescription("Set the discord AI context")
		:AddOption(
			DiscordAPI.ApplicationCommandOptions
				.new()
				:SetName("prompt")
				:SetDescription("discord AI prompt")
				:SetType(DiscordAPI.ApplicationCommandOptions.Type.String)
				:SetRequired(true)
		)
end

return SetBotContextCommand
