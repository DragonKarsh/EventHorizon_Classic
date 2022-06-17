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
end

function UpdateHandler:Enable()
	self.frame:SetScript("OnUpdate", function(frame, elapsed) self:OnUpdate(elapsed) end)
end

function UpdateHandler:Disable()
	self.frame:SetScript("OnUpdate", nil)
end

function UpdateHandler:OnUpdate(elapsed)
	error("abstract method OnUpdate not implemented")
end