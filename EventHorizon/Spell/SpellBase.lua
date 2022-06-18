SpellBase = {}
SpellBase.__index = SpellBase

setmetatable(SpellBase, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellBase:new(debuffer, caster, channeler, coolDowner, sender)
	self.debuffer = debuffer
	self.caster = vaster
	self.channeler = channeler
	self.coolDowner = coolDowner
	self.sender = sender
end
