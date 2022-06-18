CoolDowner = {}
for k, v in pairs(SpellComponent) do
  CoolDowner[k] = v
end
CoolDowner.__index = CoolDowner

setmetatable(CoolDowner, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CoolDowner:new(spellId, frame)
	SpellComponent.new(self, spellId, frame)

	self.coolDown = nil
end

function CoolDowner:WithEventHandler()
	self.eventHandler = CoolDownEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end

function CoolDowner:GenerateCoolDown(start, stop)
	self.coolDown = CoolDownIndicator(start, stop)
	tinsert(self.indicators, self.coolDown)
	
end

function CoolDowner:CheckCooldown()
	local start, duration, enabled = GetSpellCooldown(self.spellName)
	if enabled==1 and start~=0 and duration and duration>1.5 then
		local ready = start + duration
		if not self.coolDown then
			self:GenerateCoolDown(start, ready) 
		end
	else
		self.coolDown = nil
	end
end