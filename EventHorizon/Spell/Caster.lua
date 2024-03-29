local pairs = pairs
local setmetatable = setmetatable
local tinsert = tinsert

Caster = {}
for k, v in pairs(SpellComponent) do
  Caster[k] = v
end
Caster.__index = Caster

setmetatable(Caster, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Caster:new(frame, spell)
	SpellComponent.new(self, frame, spell)

	self.currentCast = nil	
end

function Caster:WithEventHandler()
	self.eventHandler = CastEventHandler(self)
	return self
end

function Caster:GenerateCast(start, stop)
	self.currentCast = CastingIndicator(start, stop, self.spell)
	tinsert(self.indicators, self.currentCast)
end

function Caster:StartCastingSpell(start, stop)
	self:GenerateCast(start, stop)
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
