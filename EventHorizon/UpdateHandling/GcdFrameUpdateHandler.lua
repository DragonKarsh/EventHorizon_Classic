GcdFrameUpdateHandler = {}
for k, v in pairs(FrameUpdateHandler) do
  GcdFrameUpdateHandler[k] = v
end
GcdFrameUpdateHandler.__index = GcdFrameUpdateHandler

setmetatable(GcdFrameUpdateHandler, {
	__index = FrameUpdateHandler, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function GcdFrameUpdateHandler:new(reference)
	FrameUpdateHandler.new(self, reference.uiFrame)

	self.reference = reference
end

function GcdFrameUpdateHandler:OnUpdate(elapsed)
	if self.reference.gcdEnd then
		local now = GetTime()
		if self.reference.gcdEnd<=now then
			self.reference.gcdEnd = nil
			self.reference.texture:Hide()
		else
			local diff = now+self.past
			local p = (self.reference.gcdEnd-diff)*self.scale
			if p<=1 then
				self.reference.texture:SetPoint('RIGHT', self.frame, 'RIGHT', (p-1)*self.frame:GetWidth()+1, 0)
				self.reference.texture:Show()
			end
		end
	else
		self.reference.texture:Hide()
	end
end



