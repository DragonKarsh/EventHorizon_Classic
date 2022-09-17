local select = select
local pairs = pairs
local setmetatable = setmetatable

CoolDownEventHandler = {}
for k, v in pairs(EventHandler) do
  CoolDownEventHandler[k] = v
end
CoolDownEventHandler.__index = CoolDownEventHandler

setmetatable(CoolDownEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

LibStub("AceEvent-3.0")
:Embed(CoolDownEventHandler)

local events = {
	['SPELL_UPDATE_COOLDOWN'] = true
}

function CoolDownEventHandler:new(coolDowner)
	EventHandler.new(self, events)

	self.coolDowner = coolDowner
end

function CoolDownEventHandler:SPELL_UPDATE_COOLDOWN()	
	self.coolDowner:CheckCooldown()
end