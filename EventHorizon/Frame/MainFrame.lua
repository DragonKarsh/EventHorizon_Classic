MainFrame = {}
MainFrame.__index = MainFrame

setmetatable(MainFrame, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function MainFrame:new(config, frame, handle, now, gcd, spellFrames)	
	self.frame = frame
	self.config = config
	self.handle = handle
	self.now = now
	self.gcd = gcd
	self.spellFrames = spellFrames	
end