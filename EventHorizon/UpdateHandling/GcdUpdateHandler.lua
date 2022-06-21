GcdUpdateHandler = {}
for k, v in pairs(UpdateHandler) do
  GcdUpdateHandler[k] = v
end
GcdUpdateHandler.__index = GcdUpdateHandler

setmetatable(GcdUpdateHandler, {
	__index = UpdateHandler, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function GcdUpdateHandler:new(gcd)
	UpdateHandler.new(self, gcd.frame)

	self.gcd = gcd
end

function GcdUpdateHandler:OnUpdate(elapsed)
	if self.gcd.gcdEnd then
		local now = GetTime()
		if self.gcd.gcdEnd<=now then
			self.gcd.gcdEnd = nil
			self.gcd.texture:Hide()
		else
			local diff = now+EventHorizon.opt.past
			local p = (self.gcd.gcdEnd-diff)*EventHorizon.opt.scale
			if p<=1 then
				self.gcd.texture:SetPoint('RIGHT', self.frame, 'RIGHT', (p-1)*self.frame:GetWidth()+1, 0)
				self.gcd.texture:Show()
			end
		end
	else
		self.gcd.texture:Hide()
	end
end