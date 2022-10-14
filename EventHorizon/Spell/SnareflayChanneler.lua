local pairs = pairs
local setmetatable = setmetatable
local tinsert = tinsert

SnareflayChanneler = {}
for k, v in pairs(Channeler) do
  SnareflayChanneler[k] = v
end
SnareflayChanneler.__index = SnareflayChanneler

setmetatable(SnareflayChanneler, {
	__index = Channeler,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SnareflayChanneler:new(frame, spell)
	Channeler.new(self, frame, spell)

	self.isTroll = select(3, UnitRace('player'))
end

function SnareflayChanneler:CalculateSnare()
	local hasMeta = GetInventoryItemGems(1) == 41335
	local snare = 0

	if hasMeta then snare = snare + 0.10 end
	if self.isTroll then snare = snare + 0.15 end

	snare = 1 - snare

	return snare
end
function SnareflayChanneler:StartChannelingSpell(start, stop)		
	local snare = self:CalculateSnare()
	stop = start + ((stop-start)*snare)
	Channeler.StartChannelingSpell(self, start, stop)
end

function SnareflayChanneler:GenerateChannel(start, stop)
	local snare = self:CalculateSnare()
	self.currentChannel = SnareflayChannelingIndicator(start, stop, self.spell, snare)
	tinsert(self.indicators, self.currentChannel)
	for k,v in pairs(self.currentChannel.ticks) do
		tinsert(self.indicators, v)
	end
end
