MainFrame = {}
MainFrame.__index = MainFrame

setmetatable(MainFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrame:new(frame, handle, nowReference, gcdReference)
	self.frame = frame
	self.handle = handle
	self.nowReference = nowReference
	self.gcdReference = gcdReference
	
	self.enabledSpellFrames = {}
	self.disabledSpellFrames = {}

	self.spellFramePool = CreateFramePool("Frame",self.frame, "BackdropTemplate")
end

function MainFrame:GetFrame()
	return self.frame
end

function MainFrame:AddSpellFrame(spellFrame)
	if spellFrame:Enabled() then
		tinsert(self.enabledSpellFrames, spellFrame)
	else
		tinsert(self.disabledSpellFrames, spellFrame)
	end
end

function MainFrame:AddChanneledSpellFrame(spellId, ticks, enabled, order)
	local spellFrame = self:RemoveSpellFrame(spellId)
	
	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spellId, enabled, order)
		:WithChannel(ticks)
		:Build()
	else
		spellFrame
		:GetChanneler()
		:SetTicks(ticks)
		spellFrame:Update(order, enabled)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:AddDirectSpellFrame(spellId, enabled, order)
	local spellFrame = self:RemoveSpellFrame(spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spellId, enabled, order)
		:Build()
	else
		spellFrame:Update(order, enabled)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:AddDotSpellFrame(spellId, ticks, enabled, order)
	local spellFrame = self:RemoveSpellFrame(spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spellId, enabled, order)
		:WithDebuff(ticks)
		:Build()
	else
		spellFrame
		:GetDebuffer()
		:SetTicks(ticks)
		spellFrame:Update(order, enabled)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:CreateSpellFrameBuilder(spellId, enabled, order)
	local builder = SpellFrameBuilder(self.spellFramePool, spellId, enabled, order)
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

function MainFrame:Disable()
	self:DisableAllSpellFrames()
	self:Hide()
end

function MainFrame:DisableAllSpellFrames()
	while #self.enabledSpellFrames > 0 do
		local spellFrame = tremove(self.enabledSpellFrames)
		spellFrame:Disable()
		tinsert(self.disabledSpellFrames, spellFrame)
	end
end

function MainFrame:LoadSpellFrames()
	for _,spell in pairs(EventHorizon.opt.channels) do
		self:AddChanneledSpellFrame(spell.spellId, spell.ticks, spell.enabled, spell.order)
	end

	for _,spell in pairs(EventHorizon.opt.directs) do
		self:AddDirectSpellFrame(spell.spellId, spell.enabled, spell.order)
	end

	for _,spell in pairs(EventHorizon.opt.dots) do
		self:AddDotSpellFrame(spell.spellId, spell.ticks, spell.enabled, spell.order)
	end
end

function MainFrame:Lock()
	self.handle:SetMovable(false)
	self.handle:Hide()
end

function MainFrame:Unlock()
	self.handle:SetMovable(true)
	self.handle:Show()
end

function MainFrame:Show()
	self.frame:Show()
end

function MainFrame:Hide()
	self.frame:Hide()
end

function MainFrame:OrderEnabledSpellFrames()
	table.sort(self.enabledSpellFrames, function(a,b) return a.order < b.order end)
end

function MainFrame:ReleaseSpellFrame(spellId)
	local spellFrame = self:RemoveSpellFrame(spellId)
	spellFrame:Disable()

	self.spellFramePool:Release(spellFrame.frame)
	self:Refresh()
end

function MainFrame:RemoveSpellFrame(spellId)
	for i=#self.enabledSpellFrames,1,-1 do
		if self.enabledSpellFrames[i].spell.spellName == GetSpellInfo(spellId) then
			return tremove(self.enabledSpellFrames,i)
		end
	end

	for i=#self.disabledSpellFrames,1,-1 do
		if self.disabledSpellFrames[i].spell.spellName == GetSpellInfo(spellId) then
			return tremove(self.disabledSpellFrames,i)
		end
	end
end

function MainFrame:Refresh()
	self:DisableAllSpellFrames()
	self:LoadSpellFrames()
	self:OrderEnabledSpellFrames()
	self:UpdateAllFrames()

	if EventHorizon.opt.locked then
		self:Lock()
	else
		self:Unlock()
	end
	if EventHorizon.opt.hidden then
		self:Hide()
	else
		self:Show()
	end
end

function MainFrame:UpdateAllFrames()
	local past = EventHorizon.opt.past
	local future = EventHorizon.opt.future
	local height = EventHorizon.opt.height
	local width = EventHorizon.opt.width

	self.frame:SetSize(width, #self.enabledSpellFrames * height)


	if self.nowReference then
		self.nowReference
		:GetTexture()
		:SetPoint('TOPLEFT',self.frame,'TOPLEFT', -past/(future-past)*width, 0)	
	end

	if self.gcdReference then
		self.gcdReference
		:GetTexture()
		:SetPoint('TOP',self.frame,'TOP', -past/(future-past)*width-0.5+height, 0)	
	end

	local relativeFrame = self.frame	
	local relativePoint = "TOPLEFT"

	for i=1,#self.enabledSpellFrames do
		local spellFrame = self.enabledSpellFrames[i]

		spellFrame
		:GetFrame()
		:SetSize(width, height)

		if spellFrame:GetIcon() then
			spellFrame
			:GetIcon()
			:SetSize(height, height)
		end

		if i > 1 then
			relativeFrame = self.enabledSpellFrames[i-1]:GetFrame()
			relativePoint = "BOTTOMLEFT"
		end

		spellFrame
		:GetFrame()
		:SetPoint("TOPLEFT", relativeFrame, relativePoint)

		spellFrame
		:GetFrame()
		:Show()
	end
end
