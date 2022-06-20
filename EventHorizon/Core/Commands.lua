function EventHorizon:InitializeCommands()	
	self:RegisterChatCommand("eventhorizon", "CommandHandler")
	self:RegisterChatCommand("eh", "CommandHandler")
	self:RegisterChatCommand("evh", "CommandHandler")	
end

function EventHorizon:CommandHandler(input)
	if not input or input:trim() == "" then
		LibStub("AceConfigDialog-3.0")
		:Open("EventHorizon")
	else
		LibStub("AceConfigCmd-3.0")
		:HandleCommand("eventhorizon", "EventHorizon", input)
	end
end