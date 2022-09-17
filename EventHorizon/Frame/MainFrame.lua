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

	self.inCombat = InCombatEventHandler(self.frame)
	self.inCombat:Enable()
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

function MainFrame:AddChanneledSpellFrame(spell)
	local spellFrame = self:RemoveSpellFrame(spell.spellId)
	
	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spell)
		:WithChannel()
		:Build()
	else
		spellFrame:Update(spell)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:AddCastedSpellFrame(spell)
	local spellFrame = self:RemoveSpellFrame(spell.spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spell)
		:Build()
	else
		spellFrame:Update(spell)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:AddDebuffSpellFrame(spell)
	local spellFrame = self:RemoveSpellFrame(spell.spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spell)
		:WithDebuff()
		:Build()
	else
		spellFrame:Update(spell)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:AddBuffSpellFrame(spell)
	local spellFrame = self:RemoveSpellFrame(spell.spellId)

	if not spellFrame then
		spellFrame = self:CreateSpellFrameBuilder(spell)
		:WithBuff()
		:Build()
	else
		spellFrame:Update(spell)
	end

	self:AddSpellFrame(spellFrame)
end

function MainFrame:CreateSpellFrameBuilder(spell)
	local builder = SpellFrameBuilder(self.spellFramePool, spell)
	:WithIcon()
	:WithSender()
	:WithCoolDown()

	local castTime = select(4, GetSpellInfo(spell.spellId))
	if (castTime or 0) > 0 then
		builder:WithCast()
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
		self:AddChanneledSpellFrame(spell)
	end

	for _,spell in pairs(EventHorizon.opt.casts) do
		self:AddCastedSpellFrame(spell)
	end

	for _,spell in pairs(EventHorizon.opt.debuffs) do
		self:AddDebuffSpellFrame(spell)
	end

	for _,spell in pairs(EventHorizon.opt.buffs) do
		self:AddBuffSpellFrame(spell)
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

function MainFrame:ShowOrHide(combat)
	if EventHorizon.opt.shown then
		if EventHorizon.opt.combat then
			if combat then
				self:Show()
			else
				self:Hide()
			end
		else
			self:Show()
		end
	else
		self:Hide()
	end

end

function MainFrame:ToggleNowReference(toggle)
	if self.nowReference then
		if toggle then
			self.nowReference.texture:Show()
		else
			self.nowReference.texture:Hide()
		end
	end
end

function MainFrame:ToggleGcdReference(toggle)
	if self.gcdReference then
		if toggle then
			self.gcdReference.texture:Show()
		else
			self.gcdReference.texture:Hide()
		end
	end
end

function MainFrame:OrderEnabledSpellFrames()
	table.sort(self.enabledSpellFrames, function(a,b) return a.spell.order < b.spell.order end)
end

function MainFrame:ReleaseSpellFrame(spellId)
	local spellFrame = self:RemoveSpellFrame(spellId)
	spellFrame:Disable()

	self.spellFramePool:Release(spellFrame.frame)
	self:Refresh()
end

function MainFrame:RemoveSpellFrame(spellId)
	for i=#self.enabledSpellFrames,1,-1 do
		if self.enabledSpellFrames[i].spellName == GetSpellInfo(spellId) then
			return tremove(self.enabledSpellFrames,i)
		end
	end

	for i=#self.disabledSpellFrames,1,-1 do
		if self.disabledSpellFrames[i].spellName == GetSpellInfo(spellId) then
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
	local inCombat = InCombatLockdown() or false
	self:ShowOrHide(inCombat)
end

function MainFrame:UpdateAllFrames()
	local past = EventHorizon.opt.past
	local future = EventHorizon.opt.future
	local height = EventHorizon.opt.height
	local width = EventHorizon.opt.width

	self.frame:SetSize(width, #self.enabledSpellFrames * height)
	
	local texture = EventHorizon.media:Fetch("statusbar", EventHorizon.opt.texture)

	self.frame:SetBackdrop({edgeFile=texture, edgeSize=1})
	self.frame:SetBackdropBorderColor(unpack(EventHorizon.opt.colors.border))	

	if EventHorizon.opt.point then
		self.handle:SetPoint(unpack(EventHorizon.opt.point))
	end

	if self.nowReference then
		self.nowReference
		:GetTexture()
		:SetPoint('TOPLEFT',self.frame,'TOPLEFT', -past/(future-past)*width, -1)	

		self.nowReference
		:GetTexture()
		:SetColorTexture(unpack(EventHorizon.opt.colors.now))	
	end

	if self.gcdReference then
		self.gcdReference
		:GetTexture()
		:SetPoint('TOP',self.frame,'TOP', -past/(future-past)*width-0.5+height, -1)	

		self.gcdReference
		:GetTexture()
		:SetColorTexture(unpack(EventHorizon.opt.colors.gcd))	
	end


	local relativeFrame = self.frame	
	local relativePoint = "TOPLEFT"

	for i=1,#self.enabledSpellFrames do
		local spellFrame = self.enabledSpellFrames[i]

		spellFrame
		:GetFrame()
		:SetBackdrop({bgFile=texture})			

		spellFrame
		:GetFrame()
		:SetBackdropColor(unpack(EventHorizon.opt.colors.background))


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
