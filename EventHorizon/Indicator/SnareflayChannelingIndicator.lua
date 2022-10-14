local pairs = pairs
local setmetatable = setmetatable
local tinsert = tinsert
local tremove = tremove

SnareflayChannelingIndicator = {}
for k, v in pairs(ChannelingIndicator) do
  SnareflayChannelingIndicator[k] = v
end
SnareflayChannelingIndicator.__index = SnareflayChannelingIndicator

setmetatable(SnareflayChannelingIndicator, {
  __index = ChannelingIndicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SnareflayChannelingIndicator:new(start, stop, spell, snare)
	ChannelingIndicator.new(self, start, stop, spell)
	
	self.snare = snare
	self:AdjustTicks()	
end

function SnareflayChannelingIndicator:AdjustTicks()
	local delta = self:GetTickIntervalDelta()
	for i =1, #self.ticks-1 do
		local t = self.ticks[i].start + delta
		self.ticks[i].start = t
		self.ticks[i].stop = t
	end	
end

function SnareflayChannelingIndicator:GetTickIntervalDelta()	
	local startTime, endTime = select(4,UnitChannelInfo("player"))
	local channel = (endTime/1000 - startTime/1000)

	return  channel - (channel*self.snare)	
end

