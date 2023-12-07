local DiscordAPI = require("../../Submodules/DiscordLuaU/Source")
local Console = require("../Dependencies/Github/Console")
local Env = require("../../.env")

local net = require("@lune/net")
local task = require("@lune/task")

local OPEN_AI_GPT_MODEL = "gpt-3.5-turbo"
local BOT_NAME = "pengu"

local DiscordAI = {}

DiscordAI.Interface = {}
DiscordAI.Prototype = {}

DiscordAI.Dictionary = {
	[{ "xd" }] = {
		"Stop with the gay",
	},
	[{ "uwu", "owo" }] = {
		"Stop being a furry - yes I stole this from emma!",
	},
	[{ "emma" }] = {
		"No one likes that bot",
		"I heard her sister was better >.>",
		"That bot is slacking on god.",
	},
}

function DiscordAI.Prototype:RespondToMessage(discordMessage)
	local userContext = self.UserContext[discordMessage.Author.Id]
	local openAiPrompt = {
		model = OPEN_AI_GPT_MODEL,
		messages = {
			{
				role = "system",
				content = self.AiContext,
			},
		},
	}

	for _, messageObject in userContext do
		table.insert(openAiPrompt.messages, messageObject)
	end

	local response = net.request({
		url = "https://api.openai.com/v1/chat/completions",
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = `Bearer {Env.OPEN_AI_TOKEN}`,
		},
		body = net.jsonEncode(openAiPrompt),
	})

	local product = net.jsonDecode(response.body)
	local choice = product.choices[1].message

	task.wait(#choice.content * 0.05)

	table.insert(self.UserContext[discordMessage.Author.Id], {
		role = choice.role,
		content = choice.content,
	})

	discordMessage:ReplyAsync(DiscordAPI.DiscordMessage.new(choice.content)):andThen(function()
		self.Reporter:Debug(
			`Responded to '{discordMessage.Author.Username} '{discordMessage.Content}' with '{choice.content}'`
		)
	end)
end

function DiscordAI.Prototype:AddMessageToUserContext(discordMessage)
	if not self.UserContext[discordMessage.Author.Id] then
		self.UserContext[discordMessage.Author.Id] = {}
	end

	table.insert(self.UserContext[discordMessage.Author.Id], {
		role = "user",
		content = discordMessage.Content,
	})
end

function DiscordAI.Prototype:ProcessDiscordMessage(discordMessage)
	if discordMessage.Author.Bot then
		return
	end

	self:AddMessageToUserContext(discordMessage)

	for searchFilters, filterResults in DiscordAI.Dictionary do
		for _, filter in searchFilters do
			if string.match(string.lower(discordMessage.Content), filter) then
				local message = filterResults[math.random(#filterResults)]

				table.insert(self.UserContext[discordMessage.Author.Id], {
					role = "assistant",
					content = message,
				})

				discordMessage:ReplyAsync(DiscordAPI.DiscordMessage.new(message))

				return
			end
		end
	end

	local shouldReply = math.random() > self.ResponsePercent

	if string.match(string.lower(discordMessage.Content), BOT_NAME) then
		shouldReply = true
	end

	if shouldReply then
		self.DiscordClient.Gateway:PostAsync(`/channels/{discordMessage.ChannelId}/typing`)

		self:RespondToMessage(discordMessage)
	end
end

function DiscordAI.Interface.new(discordClient)
	return setmetatable({
		AiContext = "you make short comments, tyically sassy and quick - you're on the Discord platform speaking on a Discord server, you're not there to answer questions but just to be a friend.",
		DiscordClient = discordClient,
		UserContext = {},
		ResponsePercent = 0,

		Reporter = Console.new("DiscordAI"),
	}, { __index = DiscordAI.Prototype })
end

return DiscordAI.Interface
