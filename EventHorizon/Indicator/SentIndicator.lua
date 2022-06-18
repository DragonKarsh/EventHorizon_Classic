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

function SentIndicator:new(spell, start)
	Indicator.new(self, spell, nil, start, start)
end