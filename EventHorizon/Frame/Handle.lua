Handle = {}
Handle.__index = Handle

setmetatable(Handle, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Handle:new(database)	
	self.frame = CreateFrame("Frame", nil, UIParent)	
	
	self.frame:SetPoint("CENTER")
	self.frame:SetSize(10,5)
	self.frame:EnableMouse(true)
	self.frame:SetMovable(true)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
	self.frame:SetScript("OnDragStop", function(frame) 
		frame:StopMovingOrSizing() 
		local a,b,c,d,e = frame:GetPoint(1)
		if type(b)=='frame' then
			b=b:GetName()
		end
		database.profile.point = {a,b,c,d,e}
	end)

	if database.profile.point then
		self.frame:SetPoint(unpack(database.profile.point))
	end
	
	self.frame.texture = self.frame:CreateTexture(nil, "BORDER")
	self.frame.texture:SetAllPoints()
	self.frame:SetScript("OnEnter", function(frame) frame.texture:SetColorTexture(1,1,1,1) end)
	self.frame:SetScript("OnLeave", function(frame) frame.texture:SetColorTexture(1,1,1,0.1) end)
	self.frame.texture:SetColorTexture(1,1,1,0.1)
end