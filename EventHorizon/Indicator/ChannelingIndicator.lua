ChannelingIndicator = {}
for k, v in pairs(CastingIndicator) do
  ChannelingIndicator[k] = v
end
ChannelingIndicator.__index = ChannelingIndicator

setmetatable(ChannelingIndicator, {
  __index = CastingIndicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function ChannelingIndicator:new(start, stop, numTicks)
	CastingIndicator.new(self, start, stop)

	self.style.texture = EventHorizon.opt.casting
	self.ticks = {}

	local duration = stop - start
	local interval = duration / numTicks
	for i=1,numTicks do
		local tick = TickIndicator(nil, start + i*interval)
		tinsert(self.ticks, tick)
	end
end

function ChannelingIndicator:Stop(stop)
	CastingIndicator.Stop(self,stop)
	self:RemoveTicksAfter(stop)
end

function ChannelingIndicator:RemoveTicksAfter(time)
	for i=#self.ticks,1,-1 do
		local diff = self.ticks[i].start - time
		if diff > 0.1 then
			tremove(self.ticks,i):Dispose()
		end
	end
end