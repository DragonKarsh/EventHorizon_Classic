local select = select
local pairs = pairs
local setmetatable = setmetatable

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