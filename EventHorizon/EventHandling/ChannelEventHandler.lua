ChannelEventHandler = {}
for k, v in pairs(SpellEventHandler) do
  ChannelEventHandler[k] = v
end
ChannelEventHandler.__index = ChannelEventHandler

setmetatable(ChannelEventHandler, {
	__index = SpellEventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local events = {
	['UNIT_SPELLCAST_CHANNEL_START'] = true,
	['UNIT_SPELLCAST_CHANNEL_STOP'] = true,
	['UNIT_SPELLCAST_CHANNEL_UPDATE'] = true
}

function ChannelEventHandler:new(channeler)
	SpellEventHandler.new(self, events, channeler.spell)

	self.channeler = channeler
end


function ChannelEventHandler:UNIT_SPELLCAST_CHANNEL_START(unitId, castGuid, spellId)
	if self:NotInterestingByUnit(unitId, spellId) then return end
	local startTime, endTime = select(4,ChannelInfo())
	startTime, endTime = startTime/1000, endTime/1000
	self.channeler:StartChannelingSpell(startTime,endTime)
end

function ChannelEventHandler:UNIT_SPELLCAST_CHANNEL_STOP(unitId, castGuid, spellId)
	if self:NotInterestingByUnit(unitId, spellId) then return end
	local now = GetTime()
	self.channeler:StopChannelingSpell(now)
end

function ChannelEventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(unitId, castGuid, spellId)
	if self:NotInterestingByUnit(unitId, spellId) then return end
	local endTime = select(5,ChannelInfo())
	endTime = endTime/1000
	self.channeler:UpdateChannelingSpell(endTime)
end