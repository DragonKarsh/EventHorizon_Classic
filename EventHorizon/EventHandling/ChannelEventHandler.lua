ChannelEventHandler = {}
for k, v in pairs(EventHandler) do
  ChannelEventHandler[k] = v
end
ChannelEventHandler.__index = ChannelEventHandler

setmetatable(ChannelEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

LibStub("AceEvent-3.0")
:Embed(ChannelEventHandler)

local events = {
	['UNIT_SPELLCAST_CHANNEL_START'] = true,
	['UNIT_SPELLCAST_CHANNEL_STOP'] = true,
	['UNIT_SPELLCAST_CHANNEL_UPDATE'] = true
}

function ChannelEventHandler:new(channeler)
	EventHandler.new(self, events)

	self.channeler = channeler
end


function ChannelEventHandler:UNIT_SPELLCAST_CHANNEL_START(event, unitId, castGuid, spellId)
	if self.channeler:NotInterestingByUnit(unitId, spellId) then return end
	local startTime, endTime = select(4,ChannelInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.channeler:StartChannelingSpell(startTime,endTime)
end

function ChannelEventHandler:UNIT_SPELLCAST_CHANNEL_STOP(event, unitId, castGuid, spellId)
	if self.channeler:NotInterestingByUnit(unitId, spellId) then return end
	local now = GetTime()
	self.channeler:StopChannelingSpell(now)
end

function ChannelEventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitId, castGuid, spellId)
	if self.channeler:NotInterestingByUnit(unitId, spellId) then return end
	local endTime = select(5,ChannelInfo())
	endTime = endTime/1000
	self.channeler:UpdateChannelingSpell(endTime)
end