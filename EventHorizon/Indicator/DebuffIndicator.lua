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

function DebuffIndicator:new(target, start, stop, spellId)
	Indicator.new(self, target, start, stop)	
	self.style.texture = EventHorizon.opt.debuff
	self.style.ready = EventHorizon.opt.ready

	
	self.spellId = spellId
	self.spellName = GetSpellInfo(spellId)
	
	self.ticks = {}


	if EventHorizon.opt.debuffs[self.spellName].dot then		
		self.numTicks = EventHorizon.opt.debuffs[self.spellName].ticks
		local duration = stop - start
		local interval = duration / self.numTicks
		for i=1,self.numTicks do
			local tick = TickIndicator(target, start + i*interval)
			tinsert(self.ticks, tick)
		end
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

	if self.numTicks then
		self:RemoveTicksAfter(stop)
	end
end

function DebuffIndicator:Refresh(start, stop)
	if self.numTicks then
		local lastTick = self.ticks[#self.ticks]
		self:ApplyTicksAfter(start, stop, lastTick.start)			
	end

	if EventHorizon.opt.debuffs[self.spellName].lastTick then
		local lastTick = self.ticks[#self.ticks]
		self:Stop(lastTick.start)
		self.original.stop = lastTick.start
	else
		self:Stop(stop)
		self.original.stop = stop
	end
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