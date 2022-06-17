Debuffer = {}
Debuffer.__index = Debuffer

setmetatable(Debuffer, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Debuffer:new(spell, duration, ticks, castTime)
	self.spell = spell
	self.duration = duration
	self.ticks = ticks
	self.castTime = castTime
	
	self.debuffs = {}	
	self.successes = {}

end

function Debuffer:WithEventHandler()
	self.eventHandler = DebuffEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end

function Debuffer:GetIndicator(target, start, stop)	
	local indicator
	if self.castTime then
		indicator = CastedDebuffIndicator(self.spell, target, start, stop)
		tinsert(self.spell.indicators, indicator.recast)
	else
		indicator = DebuffIndicator(self.spell, target, start, stop)
	end

	tinsert(self.spell.indicators, indicator)
	for k,v in pairs(indicator.ticks) do
		tinsert(self.spell.indicators, v)
	end
	return indicator
end

function Debuffer:UnitDebuffByName(unitId, debuff)
	for i = 1, 40 do
		local name, icon, count, debufftype, duration, expirationTime, isMine = UnitDebuff(unitId, i)

		if not name then break end

		if name == debuff then
			if duration >= 0 and (isMine == "player") then
				return name, icon, count, debufftype, duration, expirationTime
			end
		end
	end
end

function Debuffer:WasReplaced(debuffStop, stop, refresh)
	return debuffStop ~= stop and not refresh
end

function Debuffer:WasRefreshed(originalStop, lastSuccess, start, stop) 
	return originalStop ~= stop and math.abs(start - lastSuccess) > 0.5
end

function Debuffer:CheckTargetDebuff()
	local target = UnitGUID('target')
	local afflicted, icon, count, debuffType, duration, expirationTime = self:UnitDebuffByName('target', self.spell.spellName)	
	local shouldReplace, start	

	if afflicted then
		local startTime = expirationTime - duration
		self:ApplyDebuff(target,startTime, expirationTime)
	else
		self:RemoveDebuff(target)
	end
end

function Debuffer:CaptureDebuff(target, start)
	self.successes[target] = start	
end

function Debuffer:RemoveDebuff(target)
	self.debuffs[target] = nil
end

function Debuffer:ApplyDebuff(target, start, stop)	
	local lastSuccess = self.successes[target]
	local refreshed, replaced, applied
	if self.debuffs[target] then
		if lastSuccess then
			refreshed = self:WasRefreshed(self.debuffs[target].original.stop, lastSuccess, start, stop)
		end
		replaced = self:WasReplaced(self.debuffs[target].stop, stop, refreshed)				
		if replaced then
			self.debuffs[target]:Stop(start-0.2)
		end
	else
		applied = true
	end

	if replaced or applied then
		self.debuffs[target] = self:GetIndicator(target, start, stop)
	elseif refreshed then
		self.debuffs[target]:Refresh(start, stop)
		self.debuffs[target].original.stop = stop
	end
end