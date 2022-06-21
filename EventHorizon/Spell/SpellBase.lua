SpellBase = {}
SpellBase.__index = SpellBase

setmetatable(SpellBase, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellBase:new(spellId, debuffer, caster, channeler, coolDowner, sender)
	self.spellId = spellId
	self.spellName = GetSpellInfo(spellId)
	self.debuffer = debuffer
	self.caster = caster
	self.channeler = channeler
	self.coolDowner = coolDowner
	self.sender = sender
end

function SpellBase:Enable()
	if self.debuffer then
		self.debuffer:Enable()
	end

	if self.caster then
		self.caster:Enable()
	end

	if self.channeler then
		self.channeler:Enable()
	end

	if self.coolDowner then
		self.coolDowner:Enable()
	end

	if self.sender then
		self.sender:Enable()
	end
end

function SpellBase:Disable()
	if self.debuffer then
		self.debuffer:Disable()
	end

	if self.caster then
		self.caster:Disable()
	end

	if self.channeler then
		self.channeler:Disable()
	end

	if self.coolDowner then
		self.coolDowner:Disable()
	end

	if self.sender then
		self.sender:Disable()
	end
end