EventHandler = {}
EventHandler.__index = EventHandler

setmetatable(EventHandler, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function EventHandler:new(events)	
	self.events = events
	self.eventFrame = CreateFrame('Frame', nil)
	self.eventFrame:SetScript("OnEvent", function(frame, event, ...) if self[event] then self[event](self,...) end end)
end

function EventHandler:Enable()
	self:RegisterEvents()	
end

function EventHandler:Disable()
	self:UnregisterEvents()
end

function EventHandler:RegisterEvents()
	for k,v in pairs(self.events) do
		self:RegisterEvent(k)
	end
end

function EventHandler:UnregisterEvents()
	for k,v in pairs(self.events) do
		self:UnregisterEvent(k)
	end
end

function EventHandler:RegisterEvent(event)
	self.eventFrame:RegisterEvent(event)
end

function EventHandler:UnregisterEvent(event)
	self.eventFrame:RegisterEvent(event)
end