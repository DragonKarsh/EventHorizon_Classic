EventHorizon = LibStub("AceAddon-3.0")
:NewAddon("EventHorizon", "AceConsole-3.0")


function EventHorizon:OnInitialize()
	self.database = LibStub("AceDB-3.0")
	:New("EventHorizonDatabase", self.defaults, true)

	self:SetupOptionsTable()

	LibStub("AceConfig-3.0")
	:RegisterOptionsTable("EventHorizon", self.options, {"eventhorizon", "eh", "evh"})

	self.optionsFrame = LibStub("AceConfigDialog-3.0")
	:AddToBlizOptions("EventHorizon", "EventHorizon")

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

function EventHorizon:OnEnable()	
	self:CreateMainFrame()
	self:RefreshMainFrame()
end

function EventHorizon:CreateMainFrame()
	self.mainFrame = CreateFrame("Frame", "EventHorizon", UIParent, "BackdropTemplate")
	self.handle = CreateFrame("Frame", nil, UIParent)	
	
	self.handle:SetPoint("CENTER")
	self.handle:SetSize(10,5)
	self.handle:EnableMouse(true)
	self.handle:SetMovable(true)
	self.handle:RegisterForDrag("LeftButton")
	self.handle:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
	self.handle:SetScript("OnDragStop", function(frame) 
		frame:StopMovingOrSizing() 
		local a,b,c,d,e = frame:GetPoint(1)
		if type(b)=='frame' then
			b=b:GetName()
		end
		EventHorizon.database.profile.point = {a,b,c,d,e}
	end)

	if EventHorizon.database.profile.point then
		self.handle:SetPoint(unpack(EventHorizon.database.profile.point))
	end
	
	self.handle.texture = self.handle:CreateTexture(nil, "BORDER")
	self.handle.texture:SetAllPoints()
	self.handle:SetScript("OnEnter", function(frame) frame.texture:SetColorTexture(1,1,1,1) end)
	self.handle:SetScript("OnLeave", function(frame) frame.texture:SetColorTexture(1,1,1,0.1) end)
	self.handle.texture:SetColorTexture(1,1,1,0.1)


	self.mainFrame:SetPoint("TOPRIGHT", self.handle, "BOTTOMRIGHT")

	self.nowReference = NowReference(self.mainFrame)
	self.gcdReference = GcdReference(self.mainFrame)
	:WithEventHandler()
	:WithUpdateHandler()

	self.enabledSpellFrames = {}
	self.disabledSpellFrames = {}
end

function EventHorizon:DisableAllSpellFrames()
	while #self.enabledSpellFrames > 0 do
		local spellFrame = tremove(self.enabledSpellFrames)
		spellFrame:Disable()
		tinsert(self.disabledSpellFrames, spellFrame)
	end
end

function EventHorizon:OrderEnabledSpellFrames()
	table.sort(self.enabledSpellFrames, function(a,b) return a.order < b.order end)
end

function EventHorizon:UpdateAllFrames()
	local past = self.database.profile.past
	local future = self.database.profile.future
	local height = self.database.profile.height
	local width = self.database.profile.width
	local scale =  1/(self.database.profile.future-self.database.profile.past)

	self.scale = scale
	self.mainFrame:SetSize(width, #self.enabledSpellFrames * height)


	if self.nowReference then
		self.nowReference.texture:SetPoint('TOPLEFT',self.mainFrame,'TOPLEFT', -past/(future-past)*width, 0)	
	end

	if self.gcdReference then
		self.gcdReference.texture:SetPoint('TOP',self.mainFrame,'TOP', -past/(future-past)*width-0.5+height, 0)	
	end

	local relativeFrame = self.mainFrame	
	local relativePoint = "TOPLEFT"

	for i=1,#self.enabledSpellFrames do
		local spellFrame = self.enabledSpellFrames[i]
		spellFrame.frame:SetSize(width, height)
		if spellFrame.icon then
			spellFrame.icon:SetSize(height, height)
		end

		if i > 1 then
			relativeFrame = self.enabledSpellFrames[i-1].frame
			relativePoint = "BOTTOMLEFT"
		end

		spellFrame.frame:SetPoint("TOPLEFT", relativeFrame, relativePoint)
		spellFrame.frame:Show()
	end
end

function EventHorizon:RefreshMainFrame()
	self:DisableAllSpellFrames()
	self:LoadSpellFrames()
	self:OrderEnabledSpellFrames()
	self:UpdateAllFrames()
end

function EventHorizon:AddSpellFrame(spellFrame)
	if spellFrame.enabled then
		tinsert(self.enabledSpellFrames, spellFrame)
	else
		tinsert(self.disabledSpellFrames, spellFrame)
	end
end

function EventHorizon:CreateSpellFrameBuilder(spellId, enabled, order)
	local builder = SpellFrameBuilder(spellId, enabled, order)
	:WithIcon()
	:WithSender()

	if select(4, GetSpellInfo(spellId)) then
		builder:WithCast()
	end

	if GetSpellBaseCooldown(spellId) then
		builder:WithCoolDown()
	end

	return builder
end

function EventHorizon:LoadSpellFrames()
	for _,spell in pairs(self.database.profile.channels) do
		self:AddChanneledSpellFrame(spell.spellId, spell.ticks, spell.enabled, spell.order)
	end

	for _,spell in pairs(self.database.profile.directs) do
		self:AddDirectSpellFrame(spell.spellId, spell.enabled, spell.order)
	end

	for _,spell in pairs(self.database.profile.dots) do
		self:AddDotSpellFrame(spell.spellId, spell.ticks, spell.enabled, spell.order)
	end
end

function EventHorizon:AddChanneledSpellFrame(spellId, ticks, enabled, order)
	local spellFrame = self:RemoveSpellFrame(spellId)
	
	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spellId, enabled, order)
		:WithChannel(ticks)
		:Build()
	else
		spellFrame.channeler.ticks = ticks
		spellFrame:Update(order, enabled)
	end

	self:AddSpellFrame(spellFrame)
end

function EventHorizon:AddDirectSpellFrame(spellId, enabled, order)
	local spellFrame = self:RemoveSpellFrame(spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spellId, enabled, order)
		:Build()
	else
		spellFrame:Update(order, enabled)
	end

	self:AddSpellFrame(spellFrame)
end

function EventHorizon:AddDotSpellFrame(spellId, ticks, enabled, order)
	local spellFrame = self:RemoveSpellFrame(spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spellId, enabled, order)
		:WithDebuff(ticks)
		:Build()
	else
		spellFrame.debuffer.ticks = ticks
		spellFrame:Update(order, enabled)
	end

	self:AddSpellFrame(spellFrame)
end

function EventHorizon:RemoveSpellFrame(spellId)
	for i=#self.enabledSpellFrames,1,-1 do
		if GetSpellInfo(self.enabledSpellFrames[i].spellId) == GetSpellInfo(spellId) then
			return tremove(self.enabledSpellFrames,i)
		end
	end

	for i=#self.disabledSpellFrames,1,-1 do
		if GetSpellInfo(self.disabledSpellFrames[i].spellId) == GetSpellInfo(spellId) then
			return tremove(self.disabledSpellFrames,i)
		end
	end
end