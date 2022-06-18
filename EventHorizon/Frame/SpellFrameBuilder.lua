SpellFrameBuilder = {}
for k, v in pairs(FrameBuilder) do
  SpellFrameBuilder[k] = v
end
SpellFrameBuilder.__index = SpellFrameBuilder

setmetatable(SpellFrameBuilder, {
	__index = FrameBuilder,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrameBuilder:new(config, spellId, mainFrame)
	FrameBuilder.new(self, config, GetSpellInfo(spellId), mainFrame)

	self.spellId = spellId

	self.icon = self.frame:CreateTexture(nil, "BORDER")
	local texture = select(3,GetSpellInfo(spellId))
	self.icon:SetTexture(texture)
	self.icon:SetPoint("TOPRIGHT", self.frame, "TOPLEFT")
	self.icon:SetSize(self.frame:GetHeight(), self.frame:GetHeight())
	
	self.frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -mainFrame.spells * self.config.height)	
	self.frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	self.frame:SetBackdropColor(1,1,1,.1)	
end


function SpellFrameBuilder:WithDebuff(duration, ticks)
	self.debuff = duration
	self.debuffTicks = ticks
	return self
end

function SpellFrameBuilder:WithCast(castTime)
	self.castTime = castTime
	return self
end

function SpellFrameBuilder:WithChannel(channel, ticks)
	self.channel = channel
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

function SpellFrameBuilder:Build()
	if self.debuff then
		self.debuffer = Debuffer(self.spellId, self.frame, self.debuff, self.debuffTicks, self.castTime)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if self.castTime then
		self.caster = Caster(self.spellId, self.frame, self.castTime)
		:WithEventHandler()
		:WithUpdateHandler()
	end

	if self.channel then
		self.channeler = Channeler(self.spellId, self.frame, self.channel, self.channelTicks)
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

	local spell = SpellBase(self.debuffer, self.caster, self.channeler, self.coolDowner, self.sender)
	return SpellFrame(self.frame, self.spell)
end