DebuffEventHandler = {}
for k, v in pairs(EventHandler) do
  DebuffEventHandler[k] = v
end
DebuffEventHandler.__index = DebuffEventHandler

setmetatable(DebuffEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

LibStub("AceEvent-3.0")
:Embed(DebuffEventHandler)

local events = {
	['UNIT_AURA'] = true,
	['COMBAT_LOG_EVENT_UNFILTERED'] = true,
	['PLAYER_TARGET_CHANGED'] = true
}

function DebuffEventHandler:new(debuffer)
	EventHandler.new(self, events)

	self.debuffer = debuffer
end

function DebuffEventHandler:COMBAT_LOG_EVENT_UNFILTERED()
	local event, _, srcGuid, _, _, _, dstGuid, _, _, _, spellId = select(2,CombatLogGetCurrentEventInfo())
	local now = GetTime()

	if self.debuffer:NotInterestingByGuid(srcGuid, spellId) then return end

	if event == 'SPELL_CAST_SUCCESS' or event == 'SPELL_AURA_APPLIED' then
		self.debuffer:CaptureDebuff(dstGuid, now)
	end
end

function DebuffEventHandler:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA(nil,'target')	
end

function DebuffEventHandler:UNIT_AURA(event, unitId)
	if unitId =='target' and UnitExists('target') then 
		self.debuffer:CheckTargetDebuff()
	end
end