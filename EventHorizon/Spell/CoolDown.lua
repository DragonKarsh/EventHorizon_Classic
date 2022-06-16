CoolDown = {}
CoolDown.__index = CoolDown

setmetatable(CoolDown, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CoolDown:new(spell, coolDown)
	self.spell = spell
	self.coolDown = coolDown
	self.events = {
		['SPELL_UPDATE_COOLDOWN'] = true
	}
end

function CoolDown:GetIndicator(start, stop)
	local indicator = CoolDownIndicator(self.spell, start, stop)
	tinsert(self.spell.indicators, indicator)
	return indicator
end