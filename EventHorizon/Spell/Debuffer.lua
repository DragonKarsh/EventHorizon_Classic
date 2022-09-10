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

function Debuffer:new(spellId, frame)
	SpellComponent.new(self, spellId, frame)
	
	self.debuffs = {}
	self.successes = {}

end

function Debuffer:WithEventHandler()
	self.eventHandler = DebuffEventHandler(self)
	return self
end

function Debuffer:GenerateDebuff(target, start, stop)	
	local debuff = AuraIndicator(target, start, stop, self.spellId, EventHorizon.opt.debuff, EventHorizon.opt.debuffs[self.spellName])
	
	if debuff.casted then
		tinsert(self.indicators, debuff.recast)	
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

function Debuffer:WasRefreshed(debuff, lastSuccess, start, stop)
	-- refresh should have a different stop value than original
	if debuff.original.stop ~= stop then
		-- if it is a dot, check for an edge case where the cast start is after the last tick. this is not considered as
		-- a refresh by the server
		if debuff.numTicks and #debuff.ticks > 0 and debuff.ticks[#debuff.ticks].start < start then
			return false
		end

		-- try to detect a cast, casts do not refresh dots
		if math.abs(start - lastSuccess) < 0.5 then
			return false
		end
	else
		return false	
	end
	
	-- checks to negate a refresh case did not pass. so it is a refresh
	return true
end

function Debuffer:CheckTargetDebuff()
	local target = UnitGUID('target')
	local afflicted, icon, count, debuffType, duration, expirationTime = self:UnitDebuffByName('target', self.spellName)	
	local shouldReplace, start	

	if count then
		self.stacks = count
	else
		self.stacks = 0
	end

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
			refreshed = self:WasRefreshed(debuff, lastSuccess, start, stop)
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
	for _,v in pairs(self.debuffs[target].ticks) do
		tinsert(self.indicators, v)
	end
end