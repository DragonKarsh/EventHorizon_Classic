Cast = {}
Cast.__index = Cast

setmetatable(Cast, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Cast:new(spell, castTime)
	self.spell = spell
	self.castTime = castTime
	self.events = {
		['UNIT_SPELLCAST_START'] = true,
		['UNIT_SPELLCAST_STOP'] = true,
		['UNIT_SPELLCAST_DELAYED'] = true
	}
end

function Cast:GetIndicator(start, stop)
	local indicator = CastingIndicator(self.spell, start, stop)
	tinsert(self.spell.indicators, indicator)
	return indicator
end