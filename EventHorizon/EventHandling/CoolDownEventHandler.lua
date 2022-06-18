CoolDownEventHandler = {}
for k, v in pairs(SpellComponentEventHandler) do
  CoolDownEventHandler[k] = v
end
CoolDownEventHandler.__index = CoolDownEventHandler

setmetatable(CoolDownEventHandler, {
	__index = SpellComponentEventHandler, 
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
	SpellComponentEventHandler.new(self, events, coolDowner)

	self.coolDowner = coolDowner
end

function CoolDownEventHandler:SPELL_UPDATE_COOLDOWN()	
	self.coolDowner:CheckCooldown()
end