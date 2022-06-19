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

function GcdReference:new(frame, spellId)
	Reference.new(self, frame)

	self.spellId = spellId
	self.gcdEnd = nil

	self.texture:SetPoint('TOP',self.frame,'TOP', -self.frame.past/(self.frame.future-self.frame.past)*self.frame:GetWidth()-0.5+self.frame:GetHeight(), 0)	
	self.texture:SetColorTexture(1,1,1,0.5)	
	self.texture:Hide()
end

function GcdReference:Update()
	self.texture:SetPoint('TOP',self.frame,'TOP', -self.frame.past/(self.frame.future-self.frame.past)*self.frame:GetWidth()-0.5+self.frame:GetHeight(), 0)	
end

function GcdReference:WithUpdater()
	self.updater = GcdUpdateHandler(self)
	self.updater:Enable()
	return self
end

function GcdReference:WithEventHandler()
	self.eventHandler = GcdEventHandler(self)
	self.eventHandler:RegisterEvents()
	return self
end