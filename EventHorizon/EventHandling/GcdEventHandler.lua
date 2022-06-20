GcdEventHandler = {}
for k, v in pairs(EventHandler) do
  GcdEventHandler[k] = v
end
GcdEventHandler.__index = GcdEventHandler

setmetatable(GcdEventHandler, {
	__index = EventHandler, 
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

local events = {
	["SPELL_UPDATE_COOLDOWN"] = true
}

function GcdEventHandler:new(reference)
	EventHandler.new(self, events)

	self.reference = reference
end

function GcdEventHandler:SPELL_UPDATE_COOLDOWN()		
	local start, duration = GetSpellCooldown(EventHorizon.database.profile.gcdSpellId)
	if start and duration and duration>0 then
		self.reference.gcdEnd = start+duration
	else
		self.reference.gcdEnd = nil
	end
end