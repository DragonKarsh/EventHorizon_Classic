DebuffIndicator = {}
for k, v in pairs(Indicator) do
  DebuffIndicator[k] = v
end
DebuffIndicator.__index = DebuffIndicator

setmetatable(DebuffIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function DebuffIndicator:new(target, start, stop, numTicks)
	Indicator.new(self, target, start, stop)	
	self.style.texture = EventHorizon.opt.debuff
	self.style.ready = EventHorizon.opt.ready

	self.ticks = {}
	self.numTicks = numTicks

	local duration = stop - start
	local interval = duration / numTicks
	for i=1,numTicks do
		local tick = TickIndicator(target, start + i*interval)
		tinsert(self.ticks, tick)
	end
end

function DebuffIndicator:Dispose()
	Indicator.Dispose(self)

	self.ticks = {}		
end

function DebuffIndicator:IsReady()
	return GetTime() >= self.stop
end

function DebuffIndicator:Stop(stop)
	Indicator.Stop(self,stop)
	self:RemoveTicksAfter(stop)
end

function DebuffIndicator:Refresh(start, stop)
	local lastTick = self.ticks[#self.ticks]
	self:ApplyTicksAfter(start, stop, lastTick.start)	
	lastTick = self.ticks[#self.ticks]
	self:Stop(lastTick.start)
	self.original.stop = lastTick.start
end	

function DebuffIndicator:ApplyTicksAfter(start, stop, lastTick)
	local duration = stop - start
	local interval = duration / self.numTicks
	for i=1,self.numTicks do
		local tickTime = lastTick + i*interval
		if tickTime <= stop then
			local tick = TickIndicator(self.target, tickTime)
			tinsert(self.ticks, tick)
		end
	end
end

function DebuffIndicator:RemoveTicksAfter(time)
	for i=#self.ticks,1,-1 do
		local diff = self.ticks[i].start - time
		if diff > 0.1 then
			tremove(self.ticks,i):Dispose()
		end
	end
end