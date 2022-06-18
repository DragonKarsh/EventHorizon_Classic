FrameBuilder = {}
FrameBuilder.__index = FrameBuilder

setmetatable(FrameBuilder, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function FrameBuilder:new(config, frameType, frameName, parentFrame, inheritsFrame)	
	self.config = config
	self.frame = CreateFrame(frameType, frameName, parentFrame, inheritsFrame)
	self.frame:SetSize(config.width, config.height)
	self.frame.past = config.past
	self.frame.future = config.future
	self.frame.scale =  1/(config.future-config.past)	
end

function FrameBuilder:Build()
	error("abstract method Build not implemented")
end