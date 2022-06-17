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
	self.scale = config.scale

	self.spellFrames = {}
	self.gcdSpellId = config.gcdSpellId or 0
	self.gcdEnd = nil	

	self.frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")	

	self.frame:SetWidth(self.width)
	self.frame:SetHeight(self.height)

	local handle = CreateFrame("Frame", nil, UIParent)	
	self.frame:SetPoint("TOPRIGHT", handle, "BOTTOMRIGHT")
	
	handle:SetPoint("CENTER")
	handle:SetWidth(10)
	handle:SetHeight(5)
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

	self.nowIndicator = self.frame:CreateTexture(nil, 'BORDER')
	self.nowIndicator:SetPoint('BOTTOM',self.frame,'BOTTOM')
	self.nowIndicator:SetPoint('TOPLEFT',self.frame,'TOPLEFT', -self.past/(self.future-self.past)*self.width, 0)
	self.nowIndicator:SetWidth(1)
	self.nowIndicator:SetColorTexture(1,1,1,1)
	
	self.gcdIndicator = self.frame:CreateTexture(nil, 'BORDER')
	self.gcdIndicator:SetPoint('BOTTOM',self.frame,'BOTTOM')
	self.gcdIndicator:SetPoint('TOP',self.frame,'TOP', -self.past/(self.future-self.past)*self.width-0.5+self.height, 0)
	self.gcdIndicator:SetWidth(1)
	self.gcdIndicator:SetColorTexture(1,1,1,0.5)
	self.gcdIndicator:Hide()

	

end

function MainFrame:Enable()
	self.frame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
	self.frame:SetScript('OnEvent', function(frame, event, ...) if self[event] then self[event](self,...) end end)
end

function MainFrame:SPELL_UPDATE_COOLDOWN()
	if self.gcdIndicator then
		local start, duration = GetSpellCooldown(self.gcdSpellId)
		if start and duration and duration>0 then
			self.gcdEnd = start+duration
			self.frame:SetScript('OnUpdate', function(frame, elapsed) self:OnUpdate(elapsed) end)
		else
			self.gcdEnd = nil
			self.gcdIndicator:Hide()
			self.frame:SetScript('OnUpdate', nil)
		end
	end
end

function MainFrame:OnUpdate(elapsed)
	if self.gcdEnd then
		local now = GetTime()
		if self.gcdEnd<=now then
			self.gcdEnd = nil
			self.gcdIndicator:Hide()
		else
			local diff = now+self.past
			local p = (self.gcdEnd-diff)*self.scale
			if p<=1 then
				self.gcdIndicator:SetPoint('RIGHT', self.frame, 'RIGHT', (p-1)*self.width+1, 0)
				self.gcdIndicator:Show()
			end
		end
	end
end

function MainFrame:NewSpell(spellConfig)
	local frame = SpellFrame(self, spellConfig)
	tinsert(self.spellFrames, frame)
	self.frame:SetHeight(#self.spellFrames * self.height)
	frame:Enable()
end