BuffEventHandler = {}
for k, v in pairs(EventHandler) do
  BuffEventHandler[k] = v
end
BuffEventHandler.__index = BuffEventHandler

setmetatable(BuffEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

LibStub("AceEvent-3.0")
:Embed(BuffEventHandler)

local events = {
	['UNIT_AURA'] = true,
	['COMBAT_LOG_EVENT_UNFILTERED'] = true,
	['PLAYER_TARGET_CHANGED'] = true
}

function BuffEventHandler:new(buffer)
	EventHandler.new(self, events)

	self.buffer = buffer
end

function BuffEventHandler:COMBAT_LOG_EVENT_UNFILTERED()
	local event, _, srcGuid, _, _, _, dstGuid, _, _, _, spellId = select(2,CombatLogGetCurrentEventInfo())
	local now = GetTime()

	if self.buffer:NotInterestingByGuid(srcGuid, spellId) then return end

	if event == 'SPELL_CAST_SUCCESS' or event == 'SPELL_AURA_APPLIED' then
		self.buffer:CaptureBuff(dstGuid, now)
	end
end

function BuffEventHandler:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA(nil,EventHorizon.opt.buffs[self.buffer.spellName].unitId)	
end

function BuffEventHandler:UNIT_AURA(event, unitId)
	if unitId == EventHorizon.opt.buffs[self.buffer.spellName].unitId and UnitExists(unitId) then 
		self.buffer:CheckBuff()
	end
end