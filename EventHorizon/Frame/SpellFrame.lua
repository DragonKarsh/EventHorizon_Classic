SpellFrame = {}
SpellFrame.__index = SpellFrame

setmetatable(SpellFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function SpellFrame:new(config, frame, spell, icon)
	self.config = config
	self.frame = frame
	self.spell = spell
	self.icon = icon
end

function SpellFrame:UpdateFrame(mainFrame)
	self.frame.past = mainFrame.past
	self.frame.future = mainFrame.future
	self.frame.height = mainFrame.height
	self.frame.width = mainFrame.width
	self.frame.scale =  1/(self.frame.future-self.frame.past)
	self.frame:SetSize(self.frame.width, self.frame.height)

	if self.icon then		
		self.icon:SetSize(self.frame:GetHeight(), self.frame:GetHeight())	
	end
end