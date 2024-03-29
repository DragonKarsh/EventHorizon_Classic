local GetSpellInfo = GetSpellInfo
local GetTime = GetTime

local pairs = pairs
local setmetatable = setmetatable

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

function RecastIndicator:new(target, start, stop, spell)
	Indicator.new(self, target, start, stop, spell)	

	self.style.texture = self:GetColor('aura')
	self.style.ready = self:GetColor('ready')
	self.style.point1 = {'TOP', 'TOP', 0, -6}

end

function RecastIndicator:Update()
	local castTime = select(4, GetSpellInfo(self.spellId))/1000
	self.stop = self.original.stop - castTime
end

function RecastIndicator:IsReady()
	return GetTime() >= self.stop
end

function RecastIndicator:GetType()
	return "RecastIndicator"
end