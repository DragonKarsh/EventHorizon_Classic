DebuffEventHandler = {}
for k, v in pairs(SpellComponentEventHandler) do
  DebuffEventHandler[k] = v
end
DebuffEventHandler.__index = DebuffEventHandler

setmetatable(DebuffEventHandler, {
	__index = SpellComponentEventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local events = {
	['UNIT_AURA'] = true,
	['COMBAT_LOG_EVENT_UNFILTERED'] = true,
	['PLAYER_TARGET_CHANGED'] = true
}

function DebuffEventHandler:new(debuffer)
	SpellComponentEventHandler.new(self, events, debuffer)

	self.debuffer = debuffer
end

function DebuffEventHandler:COMBAT_LOG_EVENT_UNFILTERED(...)
	local time, event, _, srcGuid, _, _, _, dstGuid, _, _, _, spellId = CombatLogGetCurrentEventInfo()
	local now = GetTime()

	if self:NotInterestingByGuid(srcGuid, spellId) then return end

	if event == 'SPELL_CAST_SUCCESS' then
		self.debuffer:CaptureDebuff(dstGuid, now)
	end
end

function DebuffEventHandler:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA('target')	
end

function DebuffEventHandler:UNIT_AURA(unitId)
	if unitId =='target' and UnitExists('target') then 
		self.debuffer:CheckTargetDebuff()
	end
end




