SpellFrameUpdateHandler = {}
for k, v in pairs(UpdateHandler) do
  SpellFrameUpdateHandler[k] = v
end
SpellFrameUpdateHandler.__index = SpellFrameUpdateHandler

setmetatable(SpellFrameUpdateHandler, {
	__index = UpdateHandler, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrameUpdateHandler:new(spell, frame)
	UpdateHandler.new(self, frame)

	self.spell = spell
	self.textures = {}
	self.unusedTextures = {}
end

function SpellFrameUpdateHandler:OnUpdate(elapsed)
	for i=#self.textures,1,-1 do
		if self.textures[i] and (not self.textures[i].indicator or self.textures[i].indicator.disposed) then
			self:RecycleTexture(tremove(self.textures, i))			
		end
	end

	for i=#self.spell.indicators,1,-1 do
		local left, right = self.spell.indicators[i]:GetPoints()
		left = self:PointInTime(left)
		right = self:PointInTime(right)
		

		if self:InPast(right) then
			local indicator = tremove(self.spell.indicators, i)
			indicator:Dispose()
		else		
			local texture = self:AttachTexture(self.spell.indicators[i])
			self:UpdateTexture(texture, left, right)

			if not self:InPast(right) and not self:InFuture(left) and self.spell.indicators[i]:IsVisible() then
				texture:Show()
			else
				texture:Hide()
			end
		end
	end
end

function SpellFrameUpdateHandler:GetTexture()
	if #self.unusedTextures > 0 then
		return tremove(self.unusedTextures)
	else
		return self.frame:CreateTexture(nil, "BORDER")
	end
end

function SpellFrameUpdateHandler:FindTexture(indicator)
	for k,v in pairs(self.textures) do
		if v.indicator.id == indicator.id then
			return v
		end
	end

	return nil
end

function SpellFrameUpdateHandler:AttachTexture(indicator)	
	local texture = self:FindTexture(indicator)

	if not texture then
		texture = self:GetTexture()
		tinsert(self.textures, texture)

		texture:ClearAllPoints()
		texture:Hide()	

		texture.indicator = indicator

		texture:SetColorTexture(unpack(indicator.style.texture))
		local a,c,d,e = unpack(indicator.style.point1)
		texture:SetPoint(a,self.frame,c,d,e)
		local a,c,d,e = unpack(indicator.style.point2)
		texture:SetPoint(a,self.frame,c,d,e)
	end

	if indicator:IsReady() then
		texture:SetColorTexture(unpack(indicator.style.ready))
	end

	return texture
end

function SpellFrameUpdateHandler:RecycleTexture(texture)
	texture.indicator = nil
	texture:ClearAllPoints()
	texture:Hide()
	tinsert(self.unusedTextures, texture)
end

function SpellFrameUpdateHandler:UpdateTexture(texture, left, right)	
	texture:SetPoint('LEFT', self.frame, 'LEFT', not self:InPast(left) and self:Widen(left) or 0, 0)
	if left ~= right then
		texture:SetPoint("RIGHT", self.frame, 'LEFT', not self:InFuture(right) and self:Widen(right)+1 or self.frame:GetWidth(), 0)
	end
end

function SpellFrameUpdateHandler:PointInTime(point)
	local diff = GetTime() + self.frame.past
	return (point-diff)*self.frame.scale
end

function SpellFrameUpdateHandler:InPast(point)
	return  point < 0
end

function SpellFrameUpdateHandler:InFuture(point)
	return point > 1
end

function SpellFrameUpdateHandler:Widen(point)
	return point * self.frame:GetWidth()
end