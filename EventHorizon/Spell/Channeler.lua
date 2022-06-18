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

function Channeler:new(spellId, frame, channel, ticks)
	SpellComponent.new(self, spellId, frame)

	self.channel = channel
	self.ticks = ticks

	self.currentChannel = nil
end

function Channeler:WithEventHandler()
	self.eventHandler = ChannelEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end

function Channeler:GenerateChannel(start, stop)
	self.currentChannel = ChannelingIndicator(self, start, stop)
	tinsert(self.indicators, self.currentChannel)
	for k,v in pairs(self.currentChannel.ticks) do
		tinsert(self.indicators, v)
	end
end


function Channeler:RemoveTicksAfter(time)
	for i=#self.ticks,1,-1 do
		local diff = self.ticks[i].start - time
		if diff > 0.1 then
			tremove(self.ticks,i):Dispose()
		end
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