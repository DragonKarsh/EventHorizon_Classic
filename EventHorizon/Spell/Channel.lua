Channel = {}
Channel.__index = Channel

setmetatable(Channel, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Channel:new(spell, channel, ticks)
	self.spell = spell
	self.channel = channel
	self.ticks = ticks
	self.events = {
		['UNIT_SPELLCAST_CHANNEL_START'] = true,
		['UNIT_SPELLCAST_CHANNEL_STOP'] = true,
		['UNIT_SPELLCAST_CHANNEL_UPDATE'] = true
	}
end

function Channel:GetIndicator(start, stop)
	local indicator =  ChannelingIndicator(self.spell, start, stop)
	tinsert(self.spell.indicators, indicator)
	for k,v in pairs(indicator.ticks) do
		tinsert(self.spell.indicators, v)
	end
	return indicator
end