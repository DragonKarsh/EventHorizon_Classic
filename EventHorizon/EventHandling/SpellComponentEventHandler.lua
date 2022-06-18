SpellComponentEventHandler = {}
for k, v in pairs(EventHandler) do
  SpellComponentEventHandler[k] = v
end
SpellComponentEventHandler.__index = SpellComponentEventHandler

setmetatable(SpellComponentEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellComponentEventHandler:new(events, spellComponent)
	EventHandler.new(self, events)

	self.spellName = spellComponent.spellName
	self.playerGuid = UnitGUID('player')
end

function SpellComponentEventHandler:SpellNotInteresting(spellId)
	local spellName = GetSpellInfo(spellId)
	return self.spellName ~= spellName
end

function SpellComponentEventHandler:UnitNotInteresting(unitGuid)
	return self.playerGuid ~= unitGuid
end

function SpellComponentEventHandler:NotInterestingByUnit(unitId, spellId)
	local unitGuid = UnitGUID(unitId)
	return self:NotInterestingByGuid(unitGuid, spellId)
end

function SpellComponentEventHandler:NotInterestingByGuid(unitGuid, spellId)
	
	return self:UnitNotInteresting(unitGuid) or self:SpellNotInteresting(spellId)
end