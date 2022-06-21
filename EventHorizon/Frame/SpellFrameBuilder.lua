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
	self.frame:SetSize(EventHorizon.opt.width, EventHorizon.opt.height)
	self.frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	self.frame:SetBackdropColor(1,1,1,.1)	
end


function SpellFrameBuilder:WithDebuff()
	self.debuff = true
	return self
end

function SpellFrameBuilder:WithCast()
	self.cast = true
	return self
end

function SpellFrameBuilder:WithChannel()	
	self.channel = true
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
	local spellComponents = {}
	if self.debuff then
		local debuffer = Debuffer(self.spellId, self.frame, self.cast)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, debuffer)
	end

	if self.cast then
		local caster = Caster(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, caster)
	end

	if self.channel then
		local channeler = Channeler(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, channeler)
	end

	if self.coolDown then
		local coolDowner = CoolDowner(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, coolDowner)
	end

	if self.sender then
		local sender = Sender(self.spellId, self.frame)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, sender)
	end

	local spellFrame = SpellFrame(self.spellId, self.frame, spellComponents, self.icon, self.order)

	if self.enabled then
		spellFrame:Enable()
	else
		spellFrame:Disable()
	end

	return spellFrame
end