CoolDownEventHandler = {}
for k, v in pairs(SpellEventHandler) do
  CoolDownEventHandler[k] = v
end
CoolDownEventHandler.__index = CoolDownEventHandler

setmetatable(CoolDownEventHandler, {
	__index = SpellEventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local events = {
	['SPELL_UPDATE_COOLDOWN'] = true
}

function CoolDownEventHandler:new(coolDowner)
	SpellEventHandler.new(self, events, coolDowner.spell)

	self.coolDowner = coolDowner
end

function CoolDownEventHandler:SPELL_UPDATE_COOLDOWN()	
	self.coolDowner:CheckCooldown()
end