SpellComponent = {}
SpellComponent.__index = SpellComponent

setmetatable(SpellComponent, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellComponent:new(spellId, frame)
	self.spellId = spellId
	self.spellName = GetSpellInfo(spellId)
	self.frame = frame	
	self.playerGuid = UnitGUID('player')

	self.indicators = {}
end

function SpellComponent:ClearIndicator(indicator)
	return
end
function SpellComponent:WithEventHandler()
	error("abstract method WithEventHandler not implemented")
end

function SpellComponent:WithUpdateHandler()
	self.updateHandler = SpellComponentUpdateHandler(self)
	return self
end

function SpellComponent:Enable()
	if self.updateHandler then
		self.updateHandler:Enable()
	end

	if self.eventHandler then
		self.eventHandler:Enable()
	end
end

function SpellComponent:Disable()

	if self.updateHandler then
		self.updateHandler:Disable()
	end

	if self.eventHandler then
		self.eventHandler:Disable()
	end
end

function SpellComponent:SpellNotInteresting(spellId)
	local candidateSpellName = GetSpellInfo(spellId)
	-- some spell aura names are applied by other spell aura names
	local applliedBy = EventHorizon.appliedByCache.Get(self.spellName)

	--     not (                          interesting                                                  )
	return not (self.spellName == candidateSpellName or (applliedBy and applliedBy[candidateSpellName]))
end

function SpellComponent:UnitNotInteresting(unitGuid)
	return self.playerGuid ~= unitGuid
end

function SpellComponent:NotInterestingByUnit(unitId, spellId)
	local unitGuid = UnitGUID(unitId)
	return self:NotInterestingByGuid(unitGuid, spellId)
end

function SpellComponent:NotInterestingByGuid(unitGuid, spellId)
	return self:UnitNotInteresting(unitGuid) or self:SpellNotInteresting(spellId)
end