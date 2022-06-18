RecastIndicator = {}
for k, v in pairs(Indicator) do
  RecastIndicator[k] = v
end
RecastIndicator.__index = RecastIndicator

setmetatable(RecastIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function RecastIndicator:new(spell, target, start, stop)
	Indicator.new(self,spell, target, start, stop)	

	self.style.texture = {1,1,1,0.7}
	self.style.ready = {0.5,0.5,0.5,0.7}
	self.style.point1 = {'TOP', 'TOP', 0, -6}

end

function RecastIndicator:IsReady()
	return GetTime() >= self.stop
end