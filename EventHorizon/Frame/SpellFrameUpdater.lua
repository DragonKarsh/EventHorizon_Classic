SpellFrameUpdater = {}
SpellFrameUpdater.__index = SpellFrameUpdater

setmetatable(SpellFrameUpdater, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrameUpdater:new(frame)	
	self.frame = frame
	self.spell = frame.spell

	frame.OnUpdate = SpellFrameUpdater.OnUpdate
	frame.GetTexture = SpellFrameUpdater.GetTexture
	frame.AttachTexture = SpellFrameUpdater.AttachTexture
	frame.UpdateTexture = SpellFrameUpdater.UpdateTexture
	frame.RecycleTexture = SpellFrameUpdater.RecycleTexture
	frame.FindTexture = SpellFrameUpdater.FindTexture
	frame.InPast = SpellFrameUpdater.InPast
	frame.InFuture = SpellFrameUpdater.InFuture
	frame.Widen = SpellFrameUpdater.Widen
	frame.LeftPointInTime = SpellFrameUpdater.LeftPointInTime
	frame.RightPointInTime = SpellFrameUpdater.RightPointInTime

	frame:SetScript("OnUpdate", frame.OnUpdate)
end

function SpellFrameUpdater:OnUpdate(elapsed)
	for i=#self.textures,1,-1 do
		if self.textures[i] and (not self.textures[i].indicator or self.textures[i].indicator.disposed) then
			self:RecycleTexture(tremove(self.textures, i))			
		end
	end

	for i=#self.spell.indicators,1,-1 do
		local left, right = self.spell.indicators[i]:GetPoints()
		left = self:LeftPointInTime(left)
		right = self:RightPointInTime(right)
		

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

	for k,v in pairs(self.spell.debuffs)do
		if v.disposed then
			self.spell.debuffs[k] = nil
		end
	end
end

function SpellFrameUpdater:GetTexture()
	if #self.unusedTextures > 0 then
		return tremove(self.unusedTextures)
	else
		return self:CreateTexture(nil, "BORDER")
	end
end

function SpellFrameUpdater:FindTexture(indicator)
	for k,v in pairs(self.textures) do
		if v.indicator.id == indicator.id then
			return v
		end
	end

	return nil
end

function SpellFrameUpdater:AttachTexture(indicator)	
	local texture = self:FindTexture(indicator)

	if not texture then
		texture = self:GetTexture()
		tinsert(self.textures, texture)

		texture:ClearAllPoints()
		texture:Hide()	

		texture.indicator = indicator

		texture:SetColorTexture(unpack(indicator.style.texture))
		local a,c,d,e = unpack(indicator.style.point1)
		texture:SetPoint(a,self,c,d,e)
		local a,c,d,e = unpack(indicator.style.point2)
		texture:SetPoint(a,self,c,d,e)
	end

	if indicator:IsReady() then
		texture:SetColorTexture(unpack(indicator.style.ready))
	end

	return texture
end

function SpellFrameUpdater:RecycleTexture(texture)
	texture.indicator = nil
	texture:ClearAllPoints()
	texture:Hide()
	tinsert(self.unusedTextures, texture)
end

function SpellFrameUpdater:UpdateTexture(texture, left, right)	
	texture:SetPoint('LEFT', self, 'LEFT', not self:InPast(left) and self:Widen(left) or 0, 0)
	if left ~= right then
		texture:SetPoint("RIGHT", self, 'LEFT', not self:InFuture(right) and self:Widen(right)+1 or self.width, 0)
	end
end

function SpellFrameUpdater:LeftPointInTime(left)
	local diff = GetTime() + self.past
	return (left-diff)*self.scale
end

function SpellFrameUpdater:RightPointInTime(right)
	local diff = GetTime() + self.past
	return (right-diff)*self.scale 
end

function SpellFrameUpdater:InPast(point)
	return  point < 0
end

function SpellFrameUpdater:InFuture(point)
	return point > 1
end

function SpellFrameUpdater:Widen(point)
	return point * self.width
end