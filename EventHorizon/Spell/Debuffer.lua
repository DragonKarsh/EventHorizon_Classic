Debuffer = {}
for k, v in pairs(SpellComponent) do
  Debuffer[k] = v
end
Debuffer.__index = Debuffer

setmetatable(Debuffer, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Debuffer:new(spellId, frame, casted)
	SpellComponent.new(self, spellId, frame)
	
	self.casted = casted
	self.debuffs = {}
	self.successes = {}

end

function Debuffer:WithEventHandler()
	self.eventHandler = DebuffEventHandler(self)
	return self
end

function Debuffer:GenerateDebuff(target, start, stop)	
	local debuff
	local ticks = EventHorizon.opt.dots[self.spellName].ticks
	if self.casted then		
		debuff = CastedDebuffIndicator(target, start, stop, ticks, self.spellId)
		tinsert(self.indicators, debuff.recast)
	else
		debuff = DebuffIndicator(target, start, stop, ticks)		
	end

	tinsert(self.indicators, debuff)
	self.debuffs[target] = debuff

	for _,v in pairs(debuff.ticks) do
		tinsert(self.indicators, v)
	end

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
	local afflicted, icon, count, debuffType, duration, expirationTime = self:UnitDebuffByName('target', self.spellName)	
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

function Debuffer:ClearIndicator(indicator)
	if indicator.target and self.debuffs[indicator.target] and self.debuffs[indicator.target].id == indicator.id then
		self:RemoveDebuff(indicator.target)
	end
end

function Debuffer:ApplyDebuff(target, start, stop)	
	local refreshed, replaced, applied
	local debuff = self.debuffs[target]
	local lastSuccess = self.successes[target]

	if debuff then
		if lastSuccess then
			refreshed = self:WasRefreshed(debuff.original.stop, lastSuccess, start, stop)
		end

		replaced = self:WasReplaced(debuff.stop, stop, refreshed)	
	else
		applied = true
	end

	if applied then
		self:GenerateDebuff(target, start, stop)
	elseif replaced then
		self:ReplaceDebuff(target, start, stop)
	elseif refreshed then
		self:RefreshDebuff(target, start, stop)
	end
end

function Debuffer:ReplaceDebuff(target, start, stop)
	self.debuffs[target]:Cancel(start-0.2)
	self:GenerateDebuff(target, start, stop)
end

function Debuffer:RefreshDebuff(target, start, stop)
	self.debuffs[target]:Refresh(start, stop)
end