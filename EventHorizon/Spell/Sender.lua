Sender = {}
for k, v in pairs(SpellComponent) do
  Sender[k] = v
end
Sender.__index = Sender

setmetatable(Sender, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Sender:new(frame, spell)
	SpellComponent.new(self, frame, spell)
end

function Sender:WithEventHandler()
	self.eventHandler = SendEventHandler(self)
	return self
end

function Sender:SentSpell(time)
	local indicator  = SentIndicator(time, self.spell)
	tinsert(self.indicators, indicator)
end