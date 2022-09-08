RecastIndicator = {}
for k, v in pairs(Indicator) do
  RecastIndicator[k] = v
end
RecastIndicator.__index = RecastIndicator

setmetatable(RecastIndicator, {
  __index = Indicator, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function RecastIndicator:new(target, start, stop, spellId, texture)
	Indicator.new(self, target, start, stop)	

	self.style.texture = texture
	self.style.ready = EventHorizon.opt.ready
	self.style.point1 = {'TOP', 'TOP', 0, -6}

	self.spellId = spellId

end

function RecastIndicator:Update()
	local castTime = select(4, GetSpellInfo(self.spellId))/1000
	self.stop = self.original.stop - castTime
end

function RecastIndicator:IsReady()
	return GetTime() >= self.stop
end