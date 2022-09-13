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
	self.gcdLength = nil
	self.textures = {}
	self.unusedTextures = {}
	self.fontStrings = {}
	self.unusedFontStrings = {}
end

function GcdUpdateHandler:OnUpdate(elapsed)
	local now = GetTime()
	local diff = now+EventHorizon.opt.past	

	if self.gcd.gcdEnd and EventHorizon.opt.gcd then				
		if self.gcd.gcdEnd<=now then
			self.gcd.gcdEnd = nil
			self.gcd.texture:Hide()
		else
			
			local p = (self.gcd.gcdEnd-diff)*EventHorizon.opt.scale
			if p<=1 then
				self.gcd.texture:SetPoint('RIGHT', self.frame, 'RIGHT', (p-1)*self.frame:GetWidth()+1, 0)
				self.gcd.texture:Show()
			end
		end
	else
		self.gcd.texture:Hide()
	end

	if EventHorizon.opt.gcdGrid then
		local newGcd = 1.5/((GetRangedHaste()/100)+1)
		if newGcd < 1 then newGcd = 1 end

		if (not self.gcdLength) or (newGcd ~= self.gcdLength) or (#self.textures == 0) then
			self.gcdLength = newGcd
			for i=#self.textures,1,-1 do			
				self:RecycleTexture(tremove(self.textures))
			end
			for i=#self.fontStrings,1,-1 do			
				self:RecycleFontString(tremove(self.fontStrings))
			end

			local numGcds = math.floor(EventHorizon.opt.future / self.gcdLength)

		
			for i=1, numGcds,1 do
				local ge = (self.gcdLength*i) + now
				local p = (ge-diff)*EventHorizon.opt.scale
				if p<=1 then
					local texture = self:GetTexture()
					local fontString = self:GetFontString(i)
					tinsert(self.textures, texture)
					tinsert(self.fontStrings, fontString)
					texture:SetPoint('LEFT', self.frame, 'RIGHT', ((p-1)*self.frame:GetWidth()+1)*1, 0)
					fontString:SetPoint('TOPRIGHT', self.frame, 'TOPRIGHT', (p-1)*self.frame:GetWidth()+1, 0)
				
					if EventHorizon.opt.gcdGrid then
						texture:Show()
						fontString:Show()
					else
						texture:Hide()
						fontString:Hide()
					end
				end
			end
		end
	elseif #self.textures then
		for i=#self.textures,1,-1 do			
			self:RecycleTexture(tremove(self.textures))
		end
		for i=#self.fontStrings,1,-1 do			
			self:RecycleFontString(tremove(self.fontStrings))
		end
	end
end


function GcdUpdateHandler:GetTexture()
	local texture
	if #self.unusedTextures > 0 then
		texture = tremove(self.unusedTextures)
	else
		 texture = self.frame:CreateTexture(nil, 'BACKGROUND',nil,-8)		
	end

	texture:SetPoint('BOTTOM', self.frame, 'BOTTOM')
	texture:SetPoint('TOP',self.frame,'TOP', -EventHorizon.opt.past/(EventHorizon.opt.future-EventHorizon.opt.past)*EventHorizon.opt.width-0.5+EventHorizon.opt.height, 0)	
	texture:SetWidth(1)
	texture:SetColorTexture(unpack(EventHorizon.opt.gcdColor))
	return texture
end

function GcdUpdateHandler:RecycleFontString(fontString)	
	fontString:ClearAllPoints()
	fontString:Hide()
	tinsert(self.unusedFontStrings, fontString)
end

function GcdUpdateHandler:GetFontString(text)
	local fontString
	if #self.unusedFontStrings > 0 then
		fontString = tremove(self.unusedFontStrings)
	else
		 fontString = self.frame:CreateFontString(nil, 'OVERLAY', "GameTooltipText")		
	end

	fontString:SetPoint('BOTTOM', self.frame, 'BOTTOM')
	fontString:SetPoint('TOP',self.frame,'TOP', -EventHorizon.opt.past/(EventHorizon.opt.future-EventHorizon.opt.past)*EventHorizon.opt.width-0.5+EventHorizon.opt.height, 0)	
	fontString:SetText(text)
	return fontString
end

function GcdUpdateHandler:RecycleTexture(texture)	
	texture:ClearAllPoints()
	texture:Hide()
	tinsert(self.unusedTextures, texture)
end

function GcdUpdateHandler:Disable()
	UpdateHandler.Disable(self)

	for i=#self.textures,1,-1 do
		self:RecycleTexture(tremove(self.textures))
	end
end