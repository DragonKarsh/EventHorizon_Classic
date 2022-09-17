local setmetatable = setmetatable


Reference = {}
Reference.__index = Reference

setmetatable(Reference, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Reference:new(frame)
	self.frame = frame

	self.texture = self.frame:CreateTexture(nil, 'OVERLAY')
	self.texture:SetPoint('BOTTOM',self.frame,'BOTTOM', 0, 1)
	self.texture:SetWidth(1)
end

function Reference:GetTexture()
	return self.texture
end