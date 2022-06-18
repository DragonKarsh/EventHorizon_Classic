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

function CoolDownIndicator:new(spell, start, stop)
	Indicator.new(self, spell, nil, start, stop)	

	self.style.texture = {0.9,0.9,0.9,0.7}
	self.style.ready = {0.5,0.5,0.5,0.7}

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
