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

function TickIndicator:new(target, start)
	Indicator.new(self, target, start, start)	
	
	self.style.texture = EventHorizon.opt.tick
	self.style.point1 = {'TOP', 'TOP'}
	self.style.point2 = {'BOTTOM', 'TOP', 0, -5}

end