CastingIndicator = {}
for k, v in pairs(Segment) do
  CastingIndicator[k] = v
end
CastingIndicator.__index = CastingIndicator

setmetatable(CastingIndicator, {
  __index = Segment, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CastingIndicator:new(spell, start, stop)
	Segment.new(self, spell, nil, start, stop)	

	self.style.texture = {0,1,0,0.9}
end

function CastingIndicator:IsVisible()
	if self.disposed then
		return false
	end

	return true	
end