FrameBuilder = {}
FrameBuilder.__index = FrameBuilder

setmetatable(FrameBuilder, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function FrameBuilder:new(config, frameName, parentFrame)	
	self.config = config
	self.frame = CreateFrame("Frame", frameName, parentFrame, "BackdropTemplate")
	self.frame:SetSize(config.database.profile.width, config.database.profile.height)
	self.frame.past = config.database.profile.past
	self.frame.future = config.database.profile.future
	self.frame.scale =  1/(config.database.profile.future-config.database.profile.past)	
end

function FrameBuilder:Build()
	error("abstract method Build not implemented")
end