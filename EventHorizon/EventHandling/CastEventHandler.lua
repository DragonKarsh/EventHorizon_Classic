CastEventHandler = {}
for k, v in pairs(SpellComponentEventHandler) do
  CastEventHandler[k] = v
end
CastEventHandler.__index = CastEventHandler

setmetatable(CastEventHandler, {
	__index = SpellComponentEventHandler,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local events = {
	['UNIT_SPELLCAST_START'] = true,
	['UNIT_SPELLCAST_STOP'] = true,
	['UNIT_SPELLCAST_DELAYED'] = true
}

function CastEventHandler:new(caster)
	SpellComponentEventHandler.new(self, events, caster)

	self.caster = caster
end

function CastEventHandler:UNIT_SPELLCAST_START(unitId, castGUID, spellId)	
	if self:NotInterestingByUnit(unitId, spellId) then return end
	local startTime, endTime = select(4,CastingInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.caster:StartCastingSpell(startTime,endTime)
end

function CastEventHandler:UNIT_SPELLCAST_STOP(unitId, castGUID, spellId)
	if self:NotInterestingByUnit(unitId, spellId) then return end
	local now = GetTime()
	self.caster:StopCastingSpell(now)
end

function CastEventHandler:UNIT_SPELLCAST_DELAYED(unitId, castGUID, spellId)
	if self:NotInterestingByUnit(unitId, spellId) then return end
	local endTime = select(5,CastingInfo())
	endTime = endTime/1000
	self.caster:DelayCastingSpell(endTime)
end