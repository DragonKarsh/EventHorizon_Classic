UpdateHandler = {}
UpdateHandler.__index = UpdateHandler

setmetatable(UpdateHandler, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function UpdateHandler:new(frame)
	self.frame = frame
	self.timeSinceLastUpdate = 0
end

function UpdateHandler:Enable()
	self.frame:SetScript("OnUpdate", 
		function(frame, elapsed) 
			local realElapsed = self.timeSinceLastUpdate + elapsed
			self.timeSinceLastUpdate = realElapsed
			if self.timeSinceLastUpdate >= (EventHorizon.opt.throttle/1000) then
				self.timeSinceLastUpdate = 0
				self:OnUpdate(realElapsed) 
			end
		end)
end	

function UpdateHandler:Disable()
	self.frame:SetScript("OnUpdate", nil)
end

function UpdateHandler:OnUpdate(elapsed)
	error("abstract method OnUpdate not implemented")
end