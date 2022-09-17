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

function Channeler:new(frame, spell)
	SpellComponent.new(self, frame, spell)

	self.currentChannel = nil
end

function Channeler:WithEventHandler()
	self.eventHandler = ChannelEventHandler(self)
	return self
end

function Channeler:GenerateChannel(start, stop)
	self.currentChannel = ChannelingIndicator(start, stop, self.spell)
	tinsert(self.indicators, self.currentChannel)
	for k,v in pairs(self.currentChannel.ticks) do
		tinsert(self.indicators, v)
	end
end

function Channeler:StartChannelingSpell(start, stop)
	if self.currentChannel then
		self:StopChannelingSpell(start)
	end
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