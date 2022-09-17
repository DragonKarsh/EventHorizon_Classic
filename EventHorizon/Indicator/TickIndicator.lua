TickIndicator = {}
for k, v in pairs(Indicator) do
  TickIndicator[k] = v
end
TickIndicator.__index = TickIndicator

setmetatable(TickIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function TickIndicator:new(target, start, spell)
	Indicator.new(self, target, start, start, spell)	
	
	self.style.texture = self.spell.overrideColors and self.spell.colors and self.spell.colors.tick or EventHorizon.opt.colors.tick
	self.style.point1 = {'TOP', 'TOP'}
	self.style.point2 = {'BOTTOM', 'TOP', 0, -5}

end