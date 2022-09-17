local GetTime = GetTime

local pairs = pairs
local setmetatable = setmetatable

CoolDownIndicator = {}
for k, v in pairs(Indicator) do
  CoolDownIndicator[k] = v
end
CoolDownIndicator.__index = CoolDownIndicator

setmetatable(CoolDownIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CoolDownIndicator:new(start, stop, spell)
	Indicator.new(self, nil, start, stop, spell)	

	self.style.texture = self.spell.overrideColors and self.spell.colors and self.spell.colors.coolDown or EventHorizon.opt.colors.coolDown
	self.style.ready = self.spell.overrideColors and self.spell.colors and self.spell.colors.ready or EventHorizon.opt.colors.ready

end

function CoolDownIndicator:IsReady()
	return GetTime() >= self.stop
end

function CoolDownIndicator:IsVisible()
	if self.disposed then
		return false
	end

	return true	
end
