SpellFrame = {}
SpellFrame.__index = SpellFrame

setmetatable(SpellFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrame:new(mainFrame, spellConfig)
	self.frame = CreateFrame("Frame", nil, mainFrame.frame, "BackdropTemplate")	

	self.spell = SpellBase(spellConfig)

	self.mainFrame = mainFrame	
	self.past = mainFrame.past
	self.future = mainFrame.future
	self.width = mainFrame.width
	self.height = mainFrame.height
	self.scale = mainFrame.scale

	self.icon = self.frame:CreateTexture(nil, "BORDER")
	local texture = select(3,GetSpellInfo(spellConfig.spellId))
	self.icon:SetTexture(texture)
	self.icon:SetPoint("TOPRIGHT", self.frame, "TOPLEFT")
	self.icon:SetWidth(self.height)
	self.icon:SetHeight(self.height)

	
	self.frame:SetPoint("TOPLEFT", mainFrame.frame, "TOPLEFT", 0, -#mainFrame.spellFrames * self.height)
	
	self.frame:SetWidth(self.width)
	self.frame:SetHeight(self.height)
	self.frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	self.frame:SetBackdropColor(1,1,1,.1)	
end

function SpellFrame:Enable()
	self.updater = SpellFrameUpdater(self)

	self.updater:Enable()
end