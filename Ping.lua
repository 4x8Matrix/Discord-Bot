local DiscordCommand = require("../../Classes/DiscordCommand")
local DiscordAPI = require("../../../Submodules/DiscordLuaU/Source")

local PingCommand = DiscordCommand.new("ping")

function PingCommand:OnAllShardPing()
	local discordMessage = DiscordAPI.DiscordMessage.new()

	local shardCount = 0
	local shardPingSum = 0

	for _, shardObject in self.DiscordClient.DiscordShards do
		if not shardObject.HeartbeatPing then
			continue
		end

		shardCount += 1
		shardPingSum += shardObject.HeartbeatPing
	end

	local pingEmbed = DiscordAPI.DiscordEmbed.new()
		:SetTitle(`All Shards`)
		:SetDescription(`\`\`\`lua\n{string.sub(tostring(shardPingSum / shardCount), 0, 5)} ms\`\`\``)
		:SetColor(0x808080)

	discordMessage:AddEmbed(pingEmbed)

	return discordMessage
end

function PingCommand:OnSpecificShardPing(shardId)
	local discordMessage = DiscordAPI.DiscordMessage.new()
	local discordShard = self.DiscordClient.DiscordShards[shardId]

	local embedObject

	if discordShard then
		embedObject = DiscordAPI.DiscordEmbed.new()
			:SetTitle(`Shard {shardId}`)
			:SetDescription(`\`\`\`lua\n{string.sub(discordShard.HeartbeatPing, 0, 5)} ms\`\`\``)
			:SetColor(0x808080)
	else
		embedObject = DiscordAPI.DiscordEmbed.new()
			:SetTitle("Shard Error")
			:SetDescription(`Unable to locate shard **'{shardId}'**!`)
			:SetColor(0xFF0000)
	end

	discordMessage:AddEmbed(embedObject)

	return discordMessage
end

function PingCommand:OnActivated(interactionObject)
	local discordMessage

	if interactionObject.Data.Options then
		local shardId = interactionObject.Data.Options[1].Value

		discordMessage = self:OnSpecificShardPing(shardId)
	else
		discordMessage = self:OnAllShardPing()
	end

	interactionObject:SendMessageAsync(discordMessage)
end

function PingCommand:BuildCommand()
	return DiscordAPI.ApplicationCommand.new()
		:SetType(DiscordAPI.ApplicationCommand.Type.ChatInput)
		:SetName(PingCommand.Name)
		:SetDescription("Retrieve the millisecond deltatime between the bot and discord API")
		:AddOption(
			DiscordAPI.ApplicationCommandOptions.new()
				:SetName("shard-id")
				:SetDescription("Optional argument to the ping for a specific shard.")
				:SetType(DiscordAPI.ApplicationCommandOptions.Type.Integer)
				:SetRequired(false)
				:SetMinValue(0)
				:SetMaxValue(100)
		)
end

return PingCommand