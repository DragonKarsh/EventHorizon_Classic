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

function CastedDebuffIndicator:new(target, start, stop, numTicks, spellId)
	DebuffIndicator.new(self, target, start, stop, numTicks)
	
	self.style.point1 = {'TOP', 'TOP', 0, -3}
	self.style.point2 = {'BOTTOM', 'TOP', -3, -6}

	self.spellId = spellId
	self.recast = RecastIndicator(target, start, stop, spellId)

end

function CastedDebuffIndicator:Cancel(stop)	
	self.style.texture = EventHorizon.opt.ready
	self.style.point1 = {'TOP', 'TOP', 0, -3}
	self.style.point2 = {'BOTTOM', 'BOTTOM'}
	DebuffIndicator.Cancel(self,stop)
	self.recast:Dispose()
end

function CastedDebuffIndicator:Stop(stop)
	DebuffIndicator.Stop(self,stop)
	self.recast:Stop(stop)
end

function CastedDebuffIndicator:IsReady()
	local castTime = select(4, GetSpellInfo(self.spellId))/1000
	return GetTime() >= self.original.stop-castTime
end