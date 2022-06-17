Caster = {}
Caster.__index = Caster

setmetatable(Caster, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Caster:new(spell, castTime)
	self.spell = spell
	self.castTime = castTime

	self.currentCast = nil
	
end

function Caster:WithEventHandler()
	self.eventHandler = CastEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end

function Caster:GetIndicator(start, stop)
	local indicator = CastingIndicator(self.spell, start, stop)
	tinsert(self.spell.indicators, indicator)
	return indicator
end

function Caster:StartCastingSpell(start, stop)
	self.currentCast = self:GetIndicator(start, stop)
end

function Caster:StopCastingSpell(time)
	if self.currentCast then
		self.currentCast:Stop(time)
		self.currentCast = nil
	end
end

function Caster:DelayCastingSpell(time)
	if self.currentCast then
		self.currentCast:Stop(time)
	end
end