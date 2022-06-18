CastedDebuffIndicator = {}
for k, v in pairs(DebuffIndicator) do
  CastedDebuffIndicator[k] = v
end
CastedDebuffIndicator.__index = CastedDebuffIndicator

setmetatable(CastedDebuffIndicator, {
  __index = DebuffIndicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CastedDebuffIndicator:new(debuffer, target, start, stop)
	DebuffIndicator.new(self, debuffer, target, start, stop)
	
	self.style.point1 = {'TOP', 'TOP', 0, -3}
	self.style.point2 = {'BOTTOM', 'TOP', -3, -6}

	local castTime = select(4, GetSpellInfo(debuffer.spellId))/1000
	self.recast = RecastIndicator(target, start, stop-castTime)
end

function CastedDebuffIndicator:Stop(stop)
	DebuffIndicator.Stop(self,stop)
	self.recast:Stop(stop)
end

function CastedDebuffIndicator:IsReady()
	local castTime = select(4, GetSpellInfo(self.debuffer.spellId))/1000
	return GetTime() >= self.stop-castTime
end