SpellComponentUpdateHandler = {}
for k, v in pairs(UpdateHandler) do
  SpellComponentUpdateHandler[k] = v
end
SpellComponentUpdateHandler.__index = SpellComponentUpdateHandler

setmetatable(SpellComponentUpdateHandler, {
	__index = UpdateHandler, 
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellComponentUpdateHandler:new(spellComponent)
	UpdateHandler.new(self, CreateFrame("Frame"))

	self.spellComponent = spellComponent
	self.indicators = spellComponent.indicators
	self.uiFrame = spellComponent.frame
	self.textures = {}
	self.unusedTextures = {}
end

function SpellComponentUpdateHandler:OnUpdate(elapsed)
	for i=#self.textures,1,-1 do
		if self.textures[i] and (not self.textures[i].indicator or self.textures[i].indicator.disposed) then
			self:RecycleTexture(tremove(self.textures, i))			
		end
	end

	for i=#self.indicators,1,-1 do
		self.indicators[i]:Update()
		local left, right = self:GetIndicatorPoints(i)		

		if self:InPast(right) then
			self:RemoveIndicator(i)
		else		
			self:UpdateIndicator(i, left, right)
		end
	end
end

function SpellComponentUpdateHandler:RemoveIndicator(index)
	local indicator = tremove(self.indicators, index)
	indicator:Dispose()
	self.spellComponent:ClearIndicator(indicator)
end

function SpellComponentUpdateHandler:UpdateIndicator(index, left, right)
	local texture = self:AttachTexture(self.indicators[index])
	self:UpdateTexture(texture, left, right)
	self:ShowIfVisible(texture, index, left, right)
end
function SpellComponentUpdateHandler:ShowIfVisible(texture, index, left, right)
	if self:InBounds(left, right) and self.indicators[index]:IsVisible() then		
		texture:Show()
	else
		texture:Hide()
	end
end
function SpellComponentUpdateHandler:GetIndicatorPoints(index)
	local left, right = self.indicators[index]:GetPoints()
	return self:PointInTime(left), self:PointInTime(right)
end

function SpellComponentUpdateHandler:GetTexture()
	if #self.unusedTextures > 0 then
		return tremove(self.unusedTextures)
	else
		return self.uiFrame:CreateTexture(nil, "BORDER")
	end
end

function SpellComponentUpdateHandler:FindTexture(indicator)
	for k,v in pairs(self.textures) do
		if v.indicator.id == indicator.id then
			return v
		end
	end

	return nil
end

function SpellComponentUpdateHandler:AttachTexture(indicator)	
	local texture = self:FindTexture(indicator)

	if not texture then
		texture = self:GetTexture()
		texture.indicator = indicator
		tinsert(self.textures, texture)
	end

	texture:SetColorTexture(unpack(indicator.style.texture))
	local a,c,d,e = unpack(indicator.style.point1)
	texture:SetPoint(a,self.uiFrame,c,d,e)
	local a,c,d,e = unpack(indicator.style.point2)
	texture:SetPoint(a,self.uiFrame,c,d,e)

	if indicator:IsReady() then
		texture:SetColorTexture(unpack(indicator.style.ready))
	end

	return texture
end

function SpellComponentUpdateHandler:RecycleTexture(texture)	
	texture.indicator = nil
	texture:ClearAllPoints()
	texture:Hide()
	tinsert(self.unusedTextures, texture)
end

function SpellComponentUpdateHandler:UpdateTexture(texture, left, right)	
	texture:SetPoint('LEFT', self.uiFrame, 'LEFT', not self:InPast(left) and self:Widen(left) or 0, 0)
	if left ~= right then
		texture:SetPoint("RIGHT", self.uiFrame, 'LEFT', not self:InFuture(right) and self:Widen(right)+1 or self.uiFrame:GetWidth(), 0)
	end
end

function SpellComponentUpdateHandler:PointInTime(point)
	local diff = GetTime() + EventHorizon.opt.past
	return (point-diff)*EventHorizon.opt.scale
end

function SpellComponentUpdateHandler:InBounds(left, right)
	return not self:InPast(right) and not self:InFuture(left)
end
function SpellComponentUpdateHandler:InPast(point)
	return  point < 0
end

function SpellComponentUpdateHandler:InFuture(point)
	return point > 1
end

function SpellComponentUpdateHandler:Widen(point)
	return point * self.uiFrame:GetWidth()
end