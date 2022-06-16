MainFrame = {}

function MainFrame:CreateFrame(config)		
	local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")	

	local meta = getmetatable(frame)
	if meta and meta.__index then
		local metaindex = meta.__index
		setmetatable(frame, {__index = 
		function(self,k) 
			if MainFrame[k] then 
				self[k]=MainFrame[k] 
				return MainFrame[k] 
			end 
			return metaindex[k] 
		end})
	else
		setmetatable(frame, {__index = MainFrame})
	end

	frame.past = config.past
	frame.future = config.future
	frame.height = config.height
	frame.width = config.width
	frame.scale = config.scale

	frame.spellFrames = {}
	frame.gcdSpellId = config.gcdSpellId or 0
	frame.gcdEnd = nil	

	frame:SetWidth(frame.width)
	frame:SetHeight(frame.height)

	local handle = CreateFrame("Frame", "EventHorizonRowynHandle", UIParent)	
	frame:SetPoint("TOPRIGHT", handle, "BOTTOMRIGHT")
	
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

	frame.handle = handle

	frame.nowIndicator = frame:CreateTexture(nil, 'BORDER')
	frame.nowIndicator:SetPoint('BOTTOM',frame,'BOTTOM')
	frame.nowIndicator:SetPoint('TOPLEFT',frame,'TOPLEFT', -frame.past/(frame.future-frame.past)*frame.width, 0)
	frame.nowIndicator:SetWidth(1)
	frame.nowIndicator:SetColorTexture(1,1,1,1)
	
	frame.gcdIndicator = frame:CreateTexture(nil, 'BORDER')
	frame.gcdIndicator:SetPoint('BOTTOM',frame,'BOTTOM')
	frame.gcdIndicator:SetPoint('TOP',frame,'TOP', -frame.past/(frame.future-frame.past)*frame.width-0.5+frame.height, 0)
	frame.gcdIndicator:SetWidth(1)
	frame.gcdIndicator:SetColorTexture(1,1,1,0.5)
	frame.gcdIndicator:Hide()

	frame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
	frame:SetScript('OnEvent', function(self, event, ...) if self[event] then self[event](self,...) end end)

	return frame
end

function MainFrame:SPELL_UPDATE_COOLDOWN()
	if self.gcdIndicator then
		local start, duration = GetSpellCooldown(self.gcdSpellId)
		if start and duration and duration>0 then
			self.gcdEnd = start+duration
			self:SetScript('OnUpdate', self.OnUpdate)
		else
			self.gcdEnd = nil
			self.gcdIndicator:Hide()
			self:SetScript('OnUpdate', nil)
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
				self.gcdIndicator:SetPoint('RIGHT', self, 'RIGHT', (p-1)*self.width+1, 0)
				self.gcdIndicator:Show()
			end
		end
	end
end