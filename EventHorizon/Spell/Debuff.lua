Debuff = {}
Debuff.__index = Debuff

setmetatable(Debuff, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Debuff:new(spell, duration, ticks, castTime)
	self.spell = spell
	self.duration = duration
	self.ticks = ticks
	self.castTime = castTime
	self.events = {
		['UNIT_AURA'] = true,
		['COMBAT_LOG_EVENT_UNFILTERED'] = true,
		['PLAYER_TARGET_CHANGED'] = true
	}
end

function Debuff:GetIndicator(target, start, stop)	
	local indicator
	if self.castTime then
		indicator = CastedDebuffIndicator(self.spell, target, start, stop)
		tinsert(self.spell.indicators, indicator.recast)
	else
		indicator = DebuffIndicator(self.spell, target, start, stop)
	end

	tinsert(self.spell.indicators, indicator)
	for k,v in pairs(indicator.ticks) do
		tinsert(self.spell.indicators, v)
	end
	return indicator
end