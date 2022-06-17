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
end

function EventHandler:RegisterEvents()
	self.eventFrame:SetScript("OnEvent", function(frame, event, ...) if self[event] then self[event](self,...) end end)

	for k,v in pairs(self.events) do
		self:RegisterEvent(k)
	end
end

function EventHandler:RegisterEvent(event)
	self.eventFrame:RegisterEvent(event)
end