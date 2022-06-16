Segment = {}
for k, v in pairs(Indicator) do
  Segment[k] = v
end
Segment.__index = Segment

setmetatable(Segment, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Segment:new(spell, target, start, stop)
	Indicator.new(self, spell, target, start)

	self.stop = stop or 0
	self.original = {start=start,stop=stop}
end

function Segment:GetPoints()
	return self.start, self.stop
end

function Segment:Stop(stop)
	self.stop = stop
end