ChannelingIndicator = {}
for k, v in pairs(CastingIndicator) do
  ChannelingIndicator[k] = v
end
ChannelingIndicator.__index = ChannelingIndicator

setmetatable(ChannelingIndicator, {
  __index = CastingIndicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function ChannelingIndicator:new(spell, start, stop)
	CastingIndicator.new(self, spell, start, stop)

	self.style.texture = {0,1,0,0.9}
	self.ticks = {}

	local duration = stop - start
	local interval = duration / spell.channeler.ticks
	for i=1,spell.channeler.ticks do
		local tick = TickIndicator(spell, nil, start + i*interval)
		tinsert(self.ticks, tick)
	end
end

function ChannelingIndicator:Stop(stop)
	CastingIndicator.Stop(self,stop)
	self:RemoveTicksAfter(stop)
end

function ChannelingIndicator:RemoveTicksAfter(time)
	for i=#self.ticks,1,-1 do
		local diff = self.ticks[i].start - time
		if diff > 0.1 then
			tremove(self.ticks,i):Dispose()
		end
	end
end