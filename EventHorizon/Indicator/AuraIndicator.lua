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
	self.spellName = GetSpellInfo(self.spellId)
	self.config = config
	self.casted = select(4, GetSpellInfo(self.spellId)) > 0

	if self.casted then
		self.style.point1 = {'TOP', 'TOP', 0, -3}
		self.style.point2 = {'BOTTOM', 'TOP', -3, -6}
		self.recast = RecastIndicator(target, start, stop, spellId, texture)
	end
	
	self.ticks = {}
	self.isExtended = false
	self.adjustExtendedOffset = 0
	self.originalDuration = stop - start

	if config.ticks and config.ticks > 0 then		
		self.numTicks = config.ticks
		self.originalDuration = stop - start
		self.snapInterval = self.originalDuration / self.numTicks
		for i=1,self.numTicks do
			local tick = TickIndicator(target, start + i*self.snapInterval)
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

function AuraIndicator:Refresh(start, stop, duration)
	if self.numTicks then
		local lastTick = self.ticks[#self.ticks]
		self:ApplyTicksAfter(start, stop, lastTick.start, duration)			
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

function AuraIndicator:ApplyTicksAfter(start, stop, lastTick, duration)
	-- check if the aura was extended (e.g. like glyph of shred can extend rip aura duration)
	if self.original.stop < stop and not self:IsFullRefresh(start, stop) then 
		self.adjustExtendedOffset = self:CalcExtendedDotOffset(start)
		
		-- if so, mark it as extended and that's it, as the first extention cannot mess around with dot ticks
		if not self.isExtended then
			self.isExtended = true
		else
			-- this aura was already extended once.
			-- check if the refresh was done between the last and second last ticks
			if self:IsBeforeLastTick(start) then
				-- last tick should be moved forward by the adjustment offset
				self.ticks[#self.ticks].start = self.ticks[#self.ticks].start + self.adjustExtendedOffset
				self.ticks[#self.ticks].stop = self.ticks[#self.ticks].stop + self.adjustExtendedOffset
			end
		end
	end 

	-- lastTickProximiySec: Align the last added tick with proximity to the stop point of aura 
	-- (cosmetics due to server internal jitter on duration extending effects)
	local lastTickProximitySec = 0.2 
	
	for i=1,self.numTicks do
		local tickTime = lastTick + i*self.snapInterval

		-- Maybe align the last tick that will fit the window
		if tickTime-lastTickProximitySec <= stop and stop <= tickTime+lastTickProximitySec then
			tickTime = stop
		end

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

function AuraIndicator:IsFullRefresh(start, stop)
	elapsed = stop-start
	if self.originalDuration-0.5 < elapsed and elapsed < self.originalDuration+0.5 then
		return true
	end
	return false
end

function AuraIndicator:CalcExtendedDotOffset(currentTime)
	-- baseline of an extended dot offset is from initial cast
	local offset = currentTime-self.original.start

	-- if there are ticks in the past, they should be used as the baseline for the offset
	for i=1,#self.ticks,1 do
		if self.ticks[i].start <= currentTime then
			offset = currentTime - self.ticks[i].start
		else
			break
		end
	end
	return offset
end

function AuraIndicator:IsBeforeLastTick(currentTime)
	if #self.ticks > 1 and currentTime > self.ticks[#self.ticks-1].start then return true end
	return false
end