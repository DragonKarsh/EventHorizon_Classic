SpellEventHandler = {}
for k, v in pairs(EventHandler) do
  SpellEventHandler[k] = v
end
SpellEventHandler.__index = SpellEventHandler

setmetatable(SpellEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellEventHandler:new(events, spell)
	events['UNIT_SPELLCAST_SENT'] = true
	EventHandler.new(self, events)

	self.spell = spell
	self.playerGuid = UnitGUID('player')
end

function SpellEventHandler:SpellNotInteresting(spellId)
	local spellName = GetSpellInfo(spellId)
	return self.spell.spellName ~= spellName
end

function SpellEventHandler:UnitNotInteresting(unitGuid)
	return self.playerGuid ~= unitGuid
end

function SpellEventHandler:NotInterestingByUnit(unitId, spellId)
	local unitGuid = UnitGUID(unitId)
	return self:NotInterestingByGuid(unitGuid, spellId)
end

function SpellEventHandler:NotInterestingByGuid(unitGuid, spellId)
	
	return self:UnitNotInteresting(unitGuid) or self:SpellNotInteresting(spellId)
end

function SpellEventHandler:UNIT_SPELLCAST_SENT(unitId, target, castGUID, spellId)	
	if self:NotInterestingByUnit(unitId, spellId) then return end
	self.spell:SentSpell(GetTime())
end