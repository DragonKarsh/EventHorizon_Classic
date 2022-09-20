local pairs = pairs
local setmetatable = setmetatable

CastingIndicator = {}
for k, v in pairs(Indicator) do
  CastingIndicator[k] = v
end
CastingIndicator.__index = CastingIndicator

setmetatable(CastingIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CastingIndicator:new(start, stop, spell)
	Indicator.new(self, nil, start, stop, spell)	

	self.style.texture = self:GetColor('cast')
end

function CastingIndicator:IsVisible()
	if self.disposed then
		return false
	end

	return true	
end