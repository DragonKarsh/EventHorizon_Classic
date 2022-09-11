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

function Indicator:new(target, start, stop)		

	id = id + 1
	self.id = 'Ind'..id
	self.target = target
	self.start = start
	self.stop = stop
	self.original = {start=start,stop=stop}

	self.disposed = false	
	self.alwaysShow = false

	self.style = {
		texture = {1,1,1,1},
		point1 = {'TOP', 'TOP', 0, -3},
		point2 = {'BOTTOM', 'BOTTOM'}
	}

	self.style.ready = self.style.texture
end

function Indicator:Dispose()
	self.disposed = true
end

function Indicator:Update()
	return
end

function Indicator:IsReady()
	return false
end

function Indicator:GetPoints()
	return self.start, self.stop
end

function Indicator:IsVisible()
	if self.alwaysShow then return true end

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

function Indicator:Stop(stop)
	self.stop = stop
end

function Indicator:Cancel(stop)
	self.original.stop = stop
	self:Stop(stop)
end