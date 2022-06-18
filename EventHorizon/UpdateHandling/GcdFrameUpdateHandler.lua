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

function GcdFrameUpdateHandler:new(gcd, frame)
	FrameUpdateHandler.new(self, frame)

	self.gcd = gcd
end

function GcdFrameUpdateHandler:OnUpdate(elapsed)
	if self.gcd.gcdEnd then
		local now = GetTime()
		if self.gcd.gcdEnd<=now then
			self.gcd.gcdEnd = nil
			self.gcd.texture:Hide()
		else
			local diff = now+self.past
			local p = (self.gcd.gcdEnd-diff)*self.scale
			if p<=1 then
				self.gcd.texture:SetPoint('RIGHT', self.frame, 'RIGHT', (p-1)*self.frame:GetWidth()+1, 0)
				self.gcd.texture:Show()
			end
		end
	else
		self.gcd.texture:Hide()
	end
end



