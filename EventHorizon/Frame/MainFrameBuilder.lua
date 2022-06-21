MainFrameBuilder = {}
MainFrameBuilder.__index = MainFrameBuilder

setmetatable(MainFrameBuilder, {
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrameBuilder:new()
	self.frame = CreateFrame("Frame", "EventHorizon", UIParent, "BackdropTemplate")
end

function MainFrameBuilder:WithHandle()
	self.handle = CreateFrame("Frame", nil, UIParent)	
	self.handle:SetPoint("CENTER")
	self.handle:SetSize(10,5)
	self.handle:EnableMouse(true)
	self.handle:SetMovable(true)
	self.handle:RegisterForDrag("LeftButton")
	self.handle:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
	self.handle:SetScript("OnDragStop", function(frame) 
		frame:StopMovingOrSizing() 
		local a,b,c,d,e = frame:GetPoint(1)
		if type(b)=='frame' then
			b=b:GetName()
		end
		EventHorizon.opt.point = {a,b,c,d,e}
	end)

	if EventHorizon.opt.point then
		self.handle:SetPoint(unpack(EventHorizon.opt.point))
	end
	
	self.handle.texture = self.handle:CreateTexture(nil, "BORDER")
	self.handle.texture:SetAllPoints()
	self.handle:SetScript("OnEnter", function(frame) frame.texture:SetColorTexture(1,1,1,1) end)
	self.handle:SetScript("OnLeave", function(frame) frame.texture:SetColorTexture(1,1,1,0.1) end)
	self.handle.texture:SetColorTexture(1,1,1,0.1)

	self.frame:SetPoint("TOPRIGHT", self.handle, "BOTTOMRIGHT")

	return self
end

function MainFrameBuilder:WithNow()
	self.now = NowReference(self.frame)

	return self
end

function MainFrameBuilder:WithGcd()
	self.gcd = GcdReference(self.frame)
	:WithEventHandler()
	:WithUpdateHandler()

	return self
end

function MainFrameBuilder:Build()
	return MainFrame(self.frame, self.handle, self.now, self.gcd)
end