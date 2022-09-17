local pairs = pairs
local setmetatable = setmetatable

InCombatEventHandler = {}
for k, v in pairs(EventHandler) do
  InCombatEventHandler[k] = v
end
InCombatEventHandler.__index = InCombatEventHandler

setmetatable(InCombatEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

LibStub("AceEvent-3.0")
:Embed(InCombatEventHandler)

local events = {
	["PLAYER_REGEN_DISABLED"] = true,
	["PLAYER_REGEN_ENABLED"] = true,
}

function InCombatEventHandler:new(display)
	EventHandler.new(self, events)

	self.display = display
end

function InCombatEventHandler:PLAYER_REGEN_DISABLED()	
	EventHorizon.mainFrame:ShowOrHide(true)
end

function InCombatEventHandler:PLAYER_REGEN_ENABLED()	
	EventHorizon.mainFrame:ShowOrHide(false)
end