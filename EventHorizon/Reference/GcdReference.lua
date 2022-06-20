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

function GcdReference:new(frame)
	Reference.new(self, frame)

	self.gcdEnd = nil
	self.texture:SetColorTexture(1,1,1,0.5)	
	self.texture:Hide()
end

function GcdReference:WithUpdateHandler()
	self.updateHandler = GcdUpdateHandler(self)
	self.updateHandler:Enable()
	return self
end

function GcdReference:WithEventHandler()
	self.eventHandler = GcdEventHandler(self)
--	self.eventHandler:RegisterEvents()
	self.eventHandler:Enable()
	return self
end