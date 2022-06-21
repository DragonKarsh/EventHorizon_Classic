SpellFrameBuilder = {}
SpellFrameBuilder.__index = SpellFrameBuilder

setmetatable(SpellFrameBuilder, {
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})


function SpellFrameBuilder:new(framePool, spellId, enabled, order)
	self.spellId = spellId	
	self.enabled = enabled
	self.order = order
	
	self.frame = framePool:Acquire()
	self.frame:SetSize(EventHorizon.database.profile.width, EventHorizon.database.profile.height)
	self.frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	self.frame:SetBackdropColor(1,1,1,.1)	
end


function SpellFrameBuilder:WithDebuff(ticks)
	self.debuffTicks = ticks
	return self
end

function SpellFrameBuilder:WithCast()
	self.castTime = true
	return self
end

function SpellFrameBuilder:WithChannel(ticks)	
	self.channelTicks = ticks
	return self
end

function SpellFrameBuilder:WithCoolDown()
	self.coolDown = true
	return self
end

function SpellFrameBuilder:WithSender()
	self.sender = true
	return self
end

function SpellFrameBuilder:WithIcon()
	self.icon = self.frame:CreateTexture(nil, "BORDER")
	local texture = select(3,GetSpellInfo(self.spellId))
	self.icon:SetTexture(texture)
	self.icon:SetPoint("TOPRIGHT", self.frame, "TOPLEFT")
	self.icon:SetSize(self.frame:GetHeight(), self.frame:GetHeight())
	return self
end

function SpellFrameBuilder:Build()
	if self.debuffTicks then
		self.debuffer = Debuffer(self.spellId, self.frame, self.debuffTicks, self.castTime)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if self.castTime then
		self.caster = Caster(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if self.channelTicks then
		self.channeler = Channeler(self.spellId, self.frame, self.channelTicks)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if self.coolDown then
		self.coolDowner = CoolDowner(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if self.sender then
		self.sender = Sender(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	local spell = SpellBase(self.spellId, self.debuffer, self.caster, self.channeler, self.coolDowner, self.sender)
	local spellFrame = SpellFrame(self.frame, spell, self.icon, self.order)

	if self.enabled then
		spellFrame:Enable()
	else
		spellFrame:Disable()
	end

	return spellFrame
end