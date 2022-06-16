SpellFrameEventHandler = {}
SpellFrameEventHandler.__index = SpellFrameEventHandler

setmetatable(SpellFrameEventHandler, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrameEventHandler:new(frame)
	self.frame = frame
	self.spell = frame.spell

	frame.COMBAT_LOG_EVENT_UNFILTERED = SpellFrameEventHandler.COMBAT_LOG_EVENT_UNFILTERED
	frame.UNIT_AURA = SpellFrameEventHandler.UNIT_AURA
	frame.SPELL_UPDATE_COOLDOWN = SpellFrameEventHandler.SPELL_UPDATE_COOLDOWN
	frame.PLAYER_TARGET_CHANGED = SpellFrameEventHandler.PLAYER_TARGET_CHANGED
	frame.UNIT_SPELLCAST_CHANNEL_START = SpellFrameEventHandler.UNIT_SPELLCA
	frame.UNIT_SPELLCAST_CHANNEL_START = SpellFrameEventHandler.UNIT_SPELLCAST_CHANNEL_START
	frame.UNIT_SPELLCAST_CHANNEL_STOP = SpellFrameEventHandler.UNIT_SPELLCAST_CHANNEL_STOP
	frame.UNIT_SPELLCAST_CHANNEL_UPDATE = SpellFrameEventHandler.UNIT_SPELLCAST_CHANNEL_UPDATE
	frame.UNIT_SPELLCAST_SENT = SpellFrameEventHandler.UNIT_SPELLCAST_SENT
	frame.UNIT_SPELLCAST_START = SpellFrameEventHandler.UNIT_SPELLCAST_START
	frame.UNIT_SPELLCAST_STOP = SpellFrameEventHandler.UNIT_SPELLCAST_STOP
	frame.UNIT_SPELLCAST_DELAYED = SpellFrameEventHandler.UNIT_SPELLCAST_DELAYED
	frame.NotInteresting = SpellFrameEventHandler.NotInteresting

	self:RegisterAllEvents()
	frame:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](self,...) end end)

end

function SpellFrameEventHandler:RegisterAllEvents()
	if self.spell.caster then
		self:RegisterEvents(self.spell.caster.events)
	end

	if self.spell.debuffer then
		self:RegisterEvents(self.spell.debuffer.events)
	end

	if self.spell.coolDowner then
		self:RegisterEvents(self.spell.coolDowner.events)
	end
	
	self.frame:RegisterEvent('UNIT_SPELLCAST_SENT')

end

function SpellFrameEventHandler:RegisterEvents(events)
	for k,v in pairs(events) do
		self.frame:RegisterEvent(k)
	end
end

function SpellFrameEventHandler:NotInteresting(unitId, spellName)
	return unitId ~= 'player' or spellName ~= self.spell.spellName
end

function SpellFrameEventHandler:COMBAT_LOG_EVENT_UNFILTERED(...)
	local time, event, _, srcGuid, _, _, _, dstGuid, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
	local now = GetTime()
	local playerGuid = UnitGUID('player')
	if playerGuid == srcGuid and spellName == self.spell.spellName and event == 'SPELL_CAST_SUCCESS' and self.spell.debuff then
		self.spell:CaptureDebuff(dstGuid, now)
	end
end


function SpellFrameEventHandler:UNIT_SPELLCAST_SENT(unitId, target, castGUID, spellId)
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_SENT')
	self.spell:SentSpell(GetTime())
end

function SpellFrameEventHandler:UNIT_SPELLCAST_START(unitId, castGUID, spellId)	
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_START')
	local startTime, endTime = select(4,CastingInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.spell:StartCastingSpell(startTime,endTime)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_STOP(unitId, castGUID, spellId)
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_STOP')
	local now = GetTime()
	self.spell:StopCastingSpell(now)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_DELAYED(unitId, castGUID, spellId)
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_DELAYED')
	local endTime = select(5,CastingInfo())
	endTime = endTime/1000
	self.spell:DelayCastingSpell(endTime)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_CHANNEL_START(unitId, castGuid, spellId)
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_CHANNEL_START')
	local startTime, endTime = select(4,ChannelInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.spell:StartCastingSpell(startTime,endTime)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_CHANNEL_STOP(unitId, castGuid, spellId)
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_CHANNEL_STOP')
	local now = GetTime()
	self.spell:StopCastingSpell(now)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(unitId, castGuid, spellId)
	local spellName = GetSpellInfo(spellId)
	if self:NotInteresting(unitId, spellName) then return end
--	print(self.spell.spellName, 'UNIT_SPELLCAST_CHANNEL_UPDATE')
	local endTime = select(5,ChannelInfo())
	endTime = endTime/1000
	self.spell:DelayCastingSpell(endTime)
end


function SpellFrameEventHandler:UNIT_AURA(unitId)
	if unitId~='target' then return end
	self.spell:CheckDebuff()
end

function SpellFrameEventHandler:SPELL_UPDATE_COOLDOWN()	
	self.spell:CheckCooldown()
end

function SpellFrameEventHandler:PLAYER_TARGET_CHANGED()
--	print(self.spell.spellName, "PLAYER_TARGET_CHANGED")	

	if UnitExists('target') then
		self:UNIT_AURA('target')
	end
end