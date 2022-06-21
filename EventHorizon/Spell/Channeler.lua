Channeler = {}
for k, v in pairs(SpellComponent) do
  Channeler[k] = v
end
Channeler.__index = Channeler

setmetatable(Channeler, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Channeler:new(spellId, frame)
	SpellComponent.new(self, spellId, frame)

	self.currentChannel = nil
end

function Channeler:WithEventHandler()
	self.eventHandler = ChannelEventHandler(self)
	return self
end

function Channeler:GenerateChannel(start, stop)
	local ticks =  EventHorizon.opt.channels[self.spellName].ticks
	self.currentChannel = ChannelingIndicator(start, stop, ticks)
	tinsert(self.indicators, self.currentChannel)
	for k,v in pairs(self.currentChannel.ticks) do
		tinsert(self.indicators, v)
	end
end

function Channeler:StartChannelingSpell(start, stop)
	self:GenerateChannel(start, stop)
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