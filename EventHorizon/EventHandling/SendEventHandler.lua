SendEventHandler = {}
for k, v in pairs(EventHandler) do
  SendEventHandler[k] = v
end
SendEventHandler.__index = SendEventHandler

setmetatable(SendEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

LibStub("AceEvent-3.0")
:Embed(SendEventHandler)

local events = {
	['UNIT_SPELLCAST_SENT'] = true
}

function SendEventHandler:new(sender)
	EventHandler.new(self, events)

	self.sender = sender
end

function SendEventHandler:UNIT_SPELLCAST_SENT(event, unitId, target, castGUID, spellId)	
	if self.sender:NotInterestingByUnit(unitId, spellId) then return end
	self.sender:SentSpell(GetTime())
end