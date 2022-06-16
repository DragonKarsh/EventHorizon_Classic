DebuffIndicator = {}
for k, v in pairs(Segment) do
  DebuffIndicator[k] = v
end
DebuffIndicator.__index = DebuffIndicator

setmetatable(DebuffIndicator, {
  __index = Segment, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function DebuffIndicator:new(spell, target, start, stop)
	Segment.new(self,spell, target, start, stop)	
	
	self.style.texture = {1,1,1,0.7}
	self.style.ready = {0.5,0.5,0.5,0.7}
	self.ticks = {}

	local duration = stop - start
	local interval = duration / spell.debuffer.ticks
	for i=1,spell.debuffer.ticks do
		local tick = TickIndicator(spell, target, start + i*interval)
		tinsert(self.ticks, tick)
	end
end

function DebuffIndicator:Stop(stop)
	Segment.Stop(self,stop)
	self:RemoveTicksAfter(stop)
end

function DebuffIndicator:IsReady()
	return GetTime() >= self.stop
end

function DebuffIndicator:Refresh(start, stop)
	self:Stop(stop)
	self:ApplyTicksAfter(start)
end	

function DebuffIndicator:ApplyTicksAfter(time)
	local duration = stop - time
	local interval = duration / self.spell.debuffer.ticks
	for i=1,self.spell.debuffer.ticks do
		local tick = TickIndicator(self.spell, self.target, time + i*interval)
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