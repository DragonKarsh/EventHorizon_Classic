GcdReference = {}
for k, v in pairs(Reference) do
  GcdReference[k] = v
end
GcdReference.__index = GcdReference

setmetatable(GcdReference, {
  __index = Reference, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function GcdReference:new(uiFrame, spellId)
	Reference.new(self, uiFrame)

	self.spellId = spellId
	self.gcdEnd = nil

	self.texture:SetPoint('TOP',self.frame,'TOP', -self.uiFrame.past/(self.uiFrame.future-self.uiFrame.past)*self.frame:GetWidth()-0.5+self.frame:GetHeight(), 0)	
	self.texture:SetColorTexture(1,1,1,0.5)
end

function GcdReference:WithUpdater()
	self.updater = GcdFrameUpdateHandler(self)
	self.updater:Enable()
	return self
end

function GcdReference:WithEventHandler()
	self.eventHandler = GcdEventHandler(self, self.spellId)
	self.eventHandler:RegisterEvents()
	return self
end
