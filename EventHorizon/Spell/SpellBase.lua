SpellBase = {}
SpellBase.__index = SpellBase

setmetatable(SpellBase, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellBase:new (config)
	self.spellId = config.spellId
	self.abbrev = config.abbrev
	self.spellName = GetSpellInfo(config.spellId)

	self.cast = nil
	self.debuff = nil
	self.coolDown = nil

	self.debuffs = {}
	self.indicators = {}
	self.successes = {}
	
	if config.castTime then
		self.caster = Cast(self, config.castTime)
	elseif config.channel then
		self.caster = Channel(self, config.channel, config.ticks)
	end

	if config.debuff then
		self.debuffer = Debuff(self, config.debuff, config.ticks, config.castTime)
	end

	if config.coolDown then
		self.coolDowner = CoolDown(self, config.coolDown)
	end	
end

function SpellBase:DebuffWasReplaced(debuffStop, stop, refresh)
	return debuffStop ~= stop and not refresh
end

function SpellBase:DebuffWasRefreshed(originalStop, lastSuccess, start, stop) 
	return originalStop ~= stop and math.abs(start - lastSuccess) > 0.5
end

function SpellBase:CheckCooldown()
	local start, duration, enabled = GetSpellCooldown(self.spellName)
	if enabled==1 and start~=0 and duration and duration>1.5 then
		local ready = start + duration
		if not self.coolDown then
			self.coolDown = self.coolDowner:GetIndicator(start, ready) 
		end
	else
		self.coolDown = nil
	end
end

function SpellBase:CheckDebuff()
	local afflicted, icon, count, debuffType, duration, expirationTime = self:UnitDebuffByName(self.spellName)	
	local shouldReplace, start	

	if afflicted then
		local startTime = expirationTime - duration
		self:ApplyDebuff(startTime, expirationTime)
	else
		self:RemoveDebuff()
	end
end

function SpellBase:CaptureDebuff(start)
	local target = UnitGUID('target')
	self.successes[target] = start	
end

function SpellBase:RemoveDebuff()
	local target = UnitGUID('target')
	self.debuffs[target] = nil
end

function SpellBase:ApplyDebuff( start, stop)	
	local target = UnitGUID('target')
	local lastSuccess = self.successes[target]
	local refreshed, replaced, applied
	if self.debuffs[target] then
		if lastSuccess then
			refreshed = self:DebuffWasRefreshed(self.debuffs[target].original.stop, lastSuccess, start, stop)
		end
		replaced = self:DebuffWasReplaced(self.debuffs[target].stop, stop, refreshed)				
		if replaced then
			self.debuffs[target]:Stop(start-0.2)
		end
	else
		applied = true
	end

	if replaced or applied then
		self.debuffs[target] = self.debuffer:GetIndicator(target, start, stop)
	elseif refreshed then
		self.debuffs[target]:Refresh(start, stop)
		self.debuffs[target].original.stop = stop
	end
end

function SpellBase:SentSpell(time)
	local indicator  = SentIndicator(self, time)
	tinsert(self.indicators, indicator)
end

function SpellBase:StartCastingSpell(start, stop)
	self.cast = self.caster:GetIndicator(start, stop)
end

function SpellBase:StopCastingSpell(time)
	if self.cast then
		self.cast:Stop(time)
		self.cast = nil
	end
end

function SpellBase:DelayCastingSpell(time)
	if self.cast then
		self.cast:Stop(time)
	end
end

function SpellBase:UnitDebuffByName(debuff)
	for i = 1, 40 do
		local name, icon, count, debufftype, duration, expirationTime, isMine = UnitDebuff('target', i)

		if not name then break end

		if name == debuff then
			if duration >= 0 and (isMine == "player") then
				return name, icon, count, debufftype, duration, expirationTime
			end
		end
	end
end