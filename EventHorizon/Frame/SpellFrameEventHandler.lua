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

	self:RegisterAllEvents()
end

function SpellFrameEventHandler:Enable()
	self.frame:SetScript("OnEvent", function(frame, event, ...) if self[event] then self[event](self,...) end end)
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

function SpellFrameEventHandler:NotInteresting(unitId, spellId)
	local spellName = GetSpellInfo(spellId)
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
	if self:NotInteresting(unitId, spellId) then return end
	self.spell:SentSpell(GetTime())
end

function SpellFrameEventHandler:UNIT_SPELLCAST_START(unitId, castGUID, spellId)	
	if self:NotInteresting(unitId, spellId) then return end
	local startTime, endTime = select(4,CastingInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.spell:StartCastingSpell(startTime,endTime)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_STOP(unitId, castGUID, spellId)
	if self:NotInteresting(unitId, spellId) then return end
	local now = GetTime()
	self.spell:StopCastingSpell(now)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_DELAYED(unitId, castGUID, spellId)
	if self:NotInteresting(unitId, spellId) then return end
	local endTime = select(5,CastingInfo())
	endTime = endTime/1000
	self.spell:DelayCastingSpell(endTime)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_CHANNEL_START(unitId, castGuid, spellId)
	if self:NotInteresting(unitId, spellId) then return end
	local startTime, endTime = select(4,ChannelInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.spell:StartCastingSpell(startTime,endTime)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_CHANNEL_STOP(unitId, castGuid, spellId)
	if self:NotInteresting(unitId, spellId) then return end
	local now = GetTime()
	self.spell:StopCastingSpell(now)
end

function SpellFrameEventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(unitId, castGuid, spellId)
	if self:NotInteresting(unitId, spellId) then return end
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
	if UnitExists('target') then
		self:UNIT_AURA('target')
	end
end