AuraIndicator = {}
for k, v in pairs(Indicator) do
  AuraIndicator[k] = v
end
AuraIndicator.__index = AuraIndicator

setmetatable(AuraIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function AuraIndicator:new(target, start, stop, spellId, texture, config)
	Indicator.new(self, target, start, stop)
	self.style.texture = texture
	self.style.ready = EventHorizon.opt.ready

	
	self.spellId = spellId
	self.spellName = GetSpellInfo(spellId)
	self.config = config
	self.casted = select(4, GetSpellInfo(self.spellId)) > 0

	if self.casted then
		self.style.point1 = {'TOP', 'TOP', 0, -3}
		self.style.point2 = {'BOTTOM', 'TOP', -3, -6}
		self.recast = RecastIndicator(target, start, stop, spellId, texture)
	end
	
	self.ticks = {}


	if config.ticks and config.ticks > 0 then		
		self.numTicks = config.ticks
		local duration = stop - start
		local interval = duration / self.numTicks
		for i=1,self.numTicks do
			local tick = TickIndicator(target, start + i*interval)
			tinsert(self.ticks, tick)
		end
	end
end

function AuraIndicator:Dispose()
	Indicator.Dispose(self)

	self.ticks = {}		
end

function AuraIndicator:Cancel(stop)	
	if self.casted then
		self.style.texture = EventHorizon.opt.ready
		self.style.point1 = {'TOP', 'TOP', 0, -3}
		self.style.point2 = {'BOTTOM', 'BOTTOM'}
		Indicator.Cancel(self,stop)
		self.recast:Dispose()
	else
		Indicator.Cancel(self,stop)
	end
end

function AuraIndicator:IsReady()
	if self.casted then
		local castTime = select(4, GetSpellInfo(self.spellId))/1000
		return GetTime() >= self.original.stop-castTime
	else
		return GetTime() >= self.stop
	end
end

function AuraIndicator:Stop(stop)
	Indicator.Stop(self,stop)

	if self.numTicks then
		self:RemoveTicksAfter(stop)
	end

	if self.casted then
		self.recast:Stop(stop)
	end
end

function AuraIndicator:Refresh(start, stop)
	if self.numTicks then
		local lastTick = self.ticks[#self.ticks]
		self:ApplyTicksAfter(start, stop, lastTick.start)			
	end

	if self.config.lastTick then
		local lastTick = self.ticks[#self.ticks]
		self:Stop(lastTick.start)
		self.original.stop = lastTick.start
	else
		self:Stop(stop)
		self.original.stop = stop
	end
end	

function AuraIndicator:ApplyTicksAfter(start, stop, lastTick)
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

function AuraIndicator:RemoveTicksAfter(time)
	for i=#self.ticks,1,-1 do
		local diff = self.ticks[i].start - time
		if diff > 0.1 then
			tremove(self.ticks,i):Dispose()
		end
	end
end