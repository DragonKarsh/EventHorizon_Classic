Indicator = {}
Indicator.__index = Indicator

setmetatable(Indicator, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local id = 0

function Indicator:new(spell, target, start)		

	id = id + 1
	self.id = 'Ind'..id
	self.spell = spell
	self.target = target
	self.start = start
	self.disposed = false	

	self.style = {
		texture = {1,1,1,1},
		point1 = {'TOP', 'TOP', 0, -5},
		point2 = {'BOTTOM', 'BOTTOM'}
	}

	self.style.ready = self.style.texture
end

function Indicator:Dispose()
	self.disposed = true
end

function Indicator:IsReady()
	return false
end

function Indicator:GetPoints()
	return self.start, self.start
end

function Indicator:IsVisible()
	local target = UnitGUID('target')
	local dead = UnitIsDead('target')

	if not target or dead or self.disposed then
		return false
	elseif not self.target or self.target == target then
		return true
	else
		return false
	end
end

function Indicator:Start(start)
	self.start = start
end