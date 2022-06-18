SendEventHandler = {}
for k, v in pairs(SpellComponentEventHandler) do
  SendEventHandler[k] = v
end
SendEventHandler.__index = SendEventHandler

setmetatable(SendEventHandler, {
	__index = SpellComponentEventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local events = {
	['UNIT_SPELLCAST_SENT'] = true
}

function SendEventHandler:new(sender)
	SpellComponentEventHandler.new(self, events, sender)

	self.sender = sender
end

function SpellComponentEventHandler:UNIT_SPELLCAST_SENT(unitId, target, castGUID, spellId)	
	if self:NotInterestingByUnit(unitId, spellId) then return end
	self.sender:SentSpell(GetTime())
end