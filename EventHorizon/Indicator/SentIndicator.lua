local pairs = pairs
local setmetatable = setmetatable

SentIndicator = {}
for k, v in pairs(Indicator) do
  SentIndicator[k] = v
end
SentIndicator.__index = SentIndicator

setmetatable(SentIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SentIndicator:new(start, spell)
	Indicator.new(self, nil, start, start, spell)

	self.style.texture =  EventHorizon.opt.colors.sent
end