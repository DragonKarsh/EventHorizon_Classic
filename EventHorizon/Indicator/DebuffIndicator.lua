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

function DebuffIndicator:new(debuffer, target, start, stop)
	Indicator.new(self, target, start, stop)	
	self.style.texture = {1,1,1,0.7}
	self.style.ready = {0.5,0.5,0.5,0.7}

	self.debuffer = debuffer
	self.ticks = {}

	local duration = stop - start
	local interval = duration / debuffer.ticks
	for i=1,debuffer.ticks do
		local tick = TickIndicator(target, start + i*interval)
		tinsert(self.ticks, tick)
	end

end

function DebuffIndicator:Dispose()
	Indicator.Dispose(self)

	if self.debuffer.debuffs[self.target] and self.debuffer.debuffs[self.target].id == self.id then
		self.debuffer:RemoveDebuff(self.target)
	end

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
	self:Stop(stop)
	self:ApplyTicksAfter(start)
end	

function DebuffIndicator:ApplyTicksAfter(time)
	local duration = self.stop - time
	local interval = duration / self.debuffer.ticks
	for i=1,self.debuffer.ticks do
		local tick = TickIndicator(self.target, time + i*interval)
		tinsert(self.ticks, tick)		
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