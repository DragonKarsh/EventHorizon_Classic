local GetSpellInfo = GetSpellInfo

local setmetatable = setmetatable
local pairs = pairs
local tinsert = tinsert

SpellFrameBuilder = {}
SpellFrameBuilder.__index = SpellFrameBuilder

setmetatable(SpellFrameBuilder, {
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})


function SpellFrameBuilder:new(framePool, config)
	self.config = config
	
	self.frame = framePool:Acquire()
	self.frame:SetSize(EventHorizon.opt.width, EventHorizon.opt.height)
	local texture = EventHorizon.media:Fetch("statusbar", EventHorizon.opt.texture)
	self.frame:SetBackdrop({bgFile=texture})
	self.frame:SetBackdropColor(EventHorizon.Utils:UnpackColor(EventHorizon.opt.colors.background))	
	self.frame:SetFrameLevel(10)	


end


function SpellFrameBuilder:WithDebuff()
	self.debuff = true
	return self
end

function SpellFrameBuilder:WithBuff()
	self.buff = true
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
	self.frame.icon = icon
	self.frame.stacks = self.frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	self.frame.stacks:SetPoint("BOTTOMRIGHT",self.frame,"BOTTOMLEFT")
	local texture = select(3,GetSpellInfo(self.config.spellId))
	self.icon:SetTexture(texture)
	self.icon:SetPoint("TOPRIGHT", self.frame, "TOPLEFT")
	self.icon:SetSize(self.frame:GetHeight(), self.frame:GetHeight())
	return self
end

function SpellFrameBuilder:Build()
	local spellComponents = {}
	if self.debuff then
		local debuffer = Debuffer(self.frame, self.config)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, debuffer)
	end

	if self.buff then
		local buffer = Buffer(self.frame, self.config)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, buffer)
	end

	if self.cast then
		local caster = Caster(self.frame, self.config)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, caster)
	end

	if self.channel then
		local channeler = Channeler(self.frame, self.config)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, channeler)
	end

	if self.coolDown then
		local coolDowner = CoolDowner(self.frame, self.config)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, coolDowner)
	end

	if self.sender then
		local sender = Sender(self.frame, self.config)
		:WithEventHandler()
		:WithUpdateHandler()
		tinsert(spellComponents, sender)
	end

	local spellFrame = SpellFrame(self.frame, self.config, spellComponents, self.icon)

	if self.config.enabled then
		spellFrame:Enable()
	else
		spellFrame:Disable()
	end

	return spellFrame
end