EventHorizon = LibStub("AceAddon-3.0")
:NewAddon("EventHorizon", "AceConsole-3.0")


function EventHorizon:OnInitialize()
	self:InitializeMedia()
	self:InitializeDatabase()
	self:InitializeCache()
	self:InitializeOptions()
	self:InitializeCommands()
end

function EventHorizon:OnEnable()
	if not self.mainFrame then
		self:CreateMainFrame()
	end
	self:RefreshMainFrame()
end

function EventHorizon:OnDisable()
	self.mainFrame:Disable()
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