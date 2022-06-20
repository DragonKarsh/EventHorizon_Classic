EventHorizon = LibStub("AceAddon-3.0")
:NewAddon("EventHorizon", "AceConsole-3.0")


function EventHorizon:OnInitialize()	
	self:InitializeDatabase()
	self:InitializeOptions()
	self:InitializeCommands()
end

function EventHorizon:OnEnable()	
	self:CreateMainFrame()
	self:RefreshMainFrame()
end

function EventHorizon:CreateMainFrame()
	self.mainFrame = MainFrameBuilder()
	:WithHandle()
	:WithNow()
	:WithGcd()
	:Build()
end

function EventHorizon:RefreshMainFrame()
	self.mainFrame:Refresh()
end