local DiscordCommand = require("../../Classes/DiscordCommand")
local DiscordAPI = require("../../../Submodules/DiscordLuaU/Source")

local GetShardCountCommand = DiscordCommand.new("get-shard-count")

function GetShardCountCommand:OnActivated(interactionObject)
	local discordMessage = DiscordAPI.DiscordMessage.new()

	local shardCount = #self.DiscordClient.DiscordShards

	local pingEmbed = DiscordAPI.DiscordEmbed.new()
		:SetDescription(`\`\`\`lua\n{shardCount} Shards Active!\`\`\``)
		:SetColor(0x808080)

	discordMessage:AddEmbed(pingEmbed)
	interactionObject:SendMessageAsync(discordMessage)
end

function GetShardCountCommand:BuildCommand()
	return DiscordAPI.ApplicationCommand.new()
		:SetType(DiscordAPI.ApplicationCommand.Type.ChatInput)
		:SetName(GetShardCountCommand.Name)
		:SetDescription(`Retrieve the current shard count for '{self.DiscordClient.User.Username}'`)
end

return GetShardCountCommand