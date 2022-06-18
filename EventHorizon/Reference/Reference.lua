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

	self.texture = self.frame:CreateTexture(nil, 'BORDER')
	self.texture:SetPoint('BOTTOM',self.frame,'BOTTOM')
	self.texture:SetWidth(1)
end