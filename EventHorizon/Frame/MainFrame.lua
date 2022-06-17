MainFrame = {}
MainFrame.__index = MainFrame

setmetatable(MainFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrame:new(config)	
	self.past = config.past
	self.future = config.future
	self.height = config.height
	self.width = config.width
	self.scale = 1/(self.future-self.past)

	self.spellFrames = {}

	self.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")	

	self.frame:SetSize(self.width, self.height)

	local handle = CreateFrame("Frame", nil, UIParent)	
	self.frame:SetPoint("TOPRIGHT", handle, "BOTTOMRIGHT")
	
	handle:SetPoint("CENTER")
	handle:SetSize(10,5)
	handle:EnableMouse(true)
	handle:SetMovable(true)
	handle:RegisterForDrag("LeftButton")
	handle:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
	handle:SetScript("OnDragStop", function(frame) 
		frame:StopMovingOrSizing() 
		local a,b,c,d,e = frame:GetPoint(1)
		if type(b)=='frame' then
			b=b:GetName()
		end
		config.database.point = {a,b,c,d,e}
	end)

	if config.database.point then
		handle:SetPoint(unpack(config.database.point))
	end
	
	handle.texture = handle:CreateTexture(nil, "BORDER")
	handle.texture:SetAllPoints()
	handle:SetScript("OnEnter",function(frame) frame.texture:SetColorTexture(1,1,1,1) end)
	handle:SetScript("OnLeave",function(frame) frame.texture:SetColorTexture(1,1,1,0.1) end)
	handle.texture:SetColorTexture(1,1,1,0.1)

	self.handle = handle
end

function MainFrame:WithNowReference()
	self.nowReference = NowReference(self)
	return self
end

function MainFrame:WithGcdReference(gcdSpellId)
	self.gcdReference = GcdReference(self, gcdSpellId):WithEventHandler():WithUpdater()
	return self
end

function MainFrame:NewSpell(spellConfig)
	local frame = SpellFrame(self, spellConfig)
	tinsert(self.spellFrames, frame)
	self.frame:SetHeight(#self.spellFrames * self.height)
	frame:Enable()
end