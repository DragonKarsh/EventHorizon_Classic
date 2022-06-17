CoolDowner = {}
CoolDowner.__index = CoolDowner

setmetatable(CoolDowner, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CoolDowner:new(spell, coolDown)
	self.spell = spell
	self.coolDown = coolDown
end

function CoolDowner:WithEventHandler()
	self.eventHandler = CoolDownEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end

function CoolDowner:GetIndicator(start, stop)
	local indicator = CoolDownIndicator(self.spell, start, stop)
	tinsert(self.spell.indicators, indicator)
	return indicator
end

function CoolDowner:CheckCooldown()
	local start, duration, enabled = GetSpellCooldown(self.spell.spellName)
	if enabled==1 and start~=0 and duration and duration>1.5 then
		local ready = start + duration
		if not self.coolDown then
			self.coolDown = self:GetIndicator(start, ready) 
		end
	else
		self.coolDown = nil
	end
end