FrameUpdateHandler = {}
for k, v in pairs(UpdateHandler) do
  FrameUpdateHandler[k] = v
end
FrameUpdateHandler.__index = FrameUpdateHandler

setmetatable(FrameUpdateHandler, {
	__index = UpdateHandler, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function FrameUpdateHandler:new(uiFrame)
	UpdateHandler.new(self, uiFrame.frame)

	self.past = uiFrame.past
	self.future = uiFrame.future
	self.scale = 1/(self.future-self.past)
end



