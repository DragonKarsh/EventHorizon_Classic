MainFrame = {}
MainFrame.__index = MainFrame

setmetatable(MainFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrame:new(config, frame, handle, now, gcd)	
	self.frame = frame
	self.config = config
	self.handle = handle
	self.now = now
	self.gcd = gcd	
end

function MainFrame:Update()
	self:UpdateFrame()	

	for _,v in pairs(self.frame.spellFrames) do
		v:UpdateFrame(self.frame)
	end

	if self.now then
		self.now:Update()
	end

	if self.gcd then
		self.gcd:Update()
	end		
end

function MainFrame:UpdateFrame()
	self.frame.past = self.config.database.profile.past
	self.frame.future = self.config.database.profile.future
	self.frame.height = self.config.database.profile.height
	self.frame.width = self.config.database.profile.width
	self.frame.scale =  1/(self.frame.future-self.frame.past)
	self.frame:SetWidth(self.frame.width)
	self.frame:SetHeight(#self.frame.spellFrames * self.frame.height)
end