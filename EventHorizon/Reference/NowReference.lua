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

function NowReference:new(uiFrame)
	Reference.new(self, uiFrame)

	self.texture:SetPoint('TOPLEFT',self.frame,'TOPLEFT', -self.uiFrame.past/(self.uiFrame.future-self.uiFrame.past)*self.frame:GetWidth(), 0)
	self.texture:SetColorTexture(1,1,1,1)
	self.texture:Show()
end
