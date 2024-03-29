local pairs = pairs
local setmetatable = setmetatable
local unpack = unpack


NowReference = {}
for k, v in pairs(Reference) do
  NowReference[k] = v
end
NowReference.__index = NowReference

setmetatable(NowReference, {
  __index = Reference, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function NowReference:new(frame)
	Reference.new(self, frame)

	self.texture:SetColorTexture(EventHorizon.Utils:UnpackColor(EventHorizon.opt.colors.now))
end
