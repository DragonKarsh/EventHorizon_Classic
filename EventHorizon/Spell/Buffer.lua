local UnitBuff = UnitBuff
local UnitGUID = UnitGUID
local GetTime = GetTime


local abs = math.abs
local pairs = pairs
local setmetatable = setmetatable
local tinsert = tinsert
local tremove = tremove

Buffer = {}
for k, v in pairs(SpellComponent) do
  Buffer[k] = v
end
Buffer.__index = Buffer

setmetatable(Buffer, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Buffer:new(frame, spell)
	SpellComponent.new(self, frame, spell)
	
	self.buffs = {}
	self.successes = {}

end

function Buffer:WithEventHandler()
	self.eventHandler = BuffEventHandler(self)
	return self
end

function Buffer:GenerateBuff(target, start, stop)	
	local buff = AuraIndicator(target, start, stop, self.spell)
	local alwaysShow = self.spell.unitId == 'player'
	buff.alwaysShow = alwaysShow

	if buff.casted then
		tinsert(self.indicators, buff.recast)
	end

	tinsert(self.indicators, buff)
	self.buffs[target] = buff

	for _,v in pairs(buff.ticks) do
		v.alwaysShow = alwaysShow
		tinsert(self.indicators, v)
	end
end

function Buffer:UnitBuffByName(unitId, buff, ownOnly)
	for i = 1, 40 do
		local name, icon, count, bufftype, duration, expirationTime, isMine = UnitBuff(unitId, i)

		if not name then break end

		if name == buff then
			if duration >= 0 and ((not ownOnly) or isMine == "player") then
				return name, icon, count, bufftype, duration, expirationTime
			end
		end
	end
end

function Buffer:WasReplaced(buffStop, stop, refresh)
	return buffStop ~= stop and not refresh
end

function Buffer:WasRefreshed(originalStop, lastSuccess, start, stop) 
	return originalStop ~= stop and abs(start - lastSuccess) > 0.5
end

function Buffer:CheckBuff()
	local unitId = self.spell.unitId
	local target = UnitGUID(unitId)
	local affected, icon, count, buffType, duration, expirationTime = self:UnitBuffByName(unitId, self.spellName, self.spell.ownOnly)	

	if count then
		self.stacks = count
	else
		self.stacks = 0
	end

	local shouldReplace, start	

	if affected then
		local startTime = expirationTime - duration
		self:ApplyBuff(target,startTime, expirationTime)
	else
		self:RemoveBuff(target)
	end
end

function Buffer:CaptureBuff(target, start)
	self.successes[target] = start	
end

function Buffer:RemoveBuff(target)
	-- manually stop indicators (once) since buffs can be right-clicked or dispelled
	if self.buffs[target] then
		local now = GetTime()
		for i=#self.indicators,1,-1 do
			local indicator = self.indicators[i]
			if indicator and indicator.target == target then
				if indicator.start < indicator.stop then
					indicator:Stop(now)
				elseif indicator.start == indicator.stop and indicator.start > now + 0.1 then -- a future tick indicator (100ms grace)
					tremove(self.indicators,i):Dispose()
				end
			end 
		end
	end
	self.buffs[target] = nil
end

function Buffer:ClearIndicator(indicator)
	if indicator.target and self.buffs[indicator.target] and self.buffs[indicator.target].id == indicator.id then
		self:RemoveBuff(indicator.target)
	end
end

function Buffer:ApplyBuff(target, start, stop)	
	local refreshed, replaced, applied
	local buff = self.buffs[target]
	local lastSuccess = self.successes[target]

	if buff then
		if lastSuccess then
			refreshed = self:WasRefreshed(buff.original.stop, lastSuccess, start, stop)
		end

		replaced = self:WasReplaced(buff.stop, stop, refreshed)	
	else
		applied = true
	end

	if applied then
		self:GenerateBuff(target, start, stop)
	elseif replaced then
		self:ReplaceBuff(target, start, stop)
	elseif refreshed then
		self:RefreshBuff(target, start, stop)
	end
end

function Buffer:ReplaceBuff(target, start, stop)
	self.buffs[target]:Cancel(start-0.2)
	self:GenerateBuff(target, start, stop)
end

function Buffer:RefreshBuff(target, start, stop)
	self.buffs[target]:Refresh(start, stop)
	for _,v in pairs(self.buffs[target].ticks) do
		tinsert(self.indicators, v)
	end
end
