EventHorizon.options = { 
	name = "EventHorizon",
	handler = EventHorizon,
	type = "group",
	childGroups = "tab",
	args = {
	}	
}

function EventHorizon:InitializeOptions()	
	self:InitializeAllOptions()
	
	LibStub("AceConfig-3.0")
	:RegisterOptionsTable("EventHorizon", self.options, {"eventhorizon", "eh", "evh"})
	
	self.options.args.profiles = LibStub("AceDBOptions-3.0")
	:GetOptionsTable(self.database)

	self.optionsFrame = LibStub("AceConfigDialog-3.0")
	:AddToBlizOptions("EventHorizon", "EventHorizon")
end

function EventHorizon:InitializeAllOptions()
	self:CreateGlobalOptions()
	self:CreateChannelsOptions()
	self:CreateCastedOptions()
	self:CreateDebuffsOptions()
	self:CreateBuffsOptions()
	self:CreateChanneledSpellsOptions()
	self:CreateCastedSpellsOptions()
	self:CreateDebuffSpellsOptions()
	self:CreateBuffSpellsOptions()
	self:CreateExportImportOptions()
end