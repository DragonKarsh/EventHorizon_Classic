Channeler = {}
Channeler.__index = Channeler

setmetatable(Channeler, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Channeler:new(spell, channel, ticks)
	self.spell = spell
	self.channel = channel
	self.ticks = ticks

	self.currentChannel = nil
end

function Channeler:WithEventHandler()
	self.eventHandler = ChannelEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end

function Channeler:GetIndicator(start, stop)
	local indicator =  ChannelingIndicator(self.spell, start, stop)
	tinsert(self.spell.indicators, indicator)
	for k,v in pairs(indicator.ticks) do
		tinsert(self.spell.indicators, v)
	end
	return indicator
end

function Channeler:StartChannelingSpell(start, stop)
	self.currentChannel = self:GetIndicator(start, stop)
end

function Channeler:StopChannelingSpell(time)
	if self.currentChannel then
		self.currentChannel:Stop(time)
		self.currentChannel = nil
	end
end

function Channeler:UpdateChannelingSpell(time)
	if self.currentChannel then
		self.currentChannel:Stop(time)
	end
end