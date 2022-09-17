local GetSpellCooldown = GetSpellCooldown

local pairs = pairs
local setmetatable = setmetatable
local tinsert = tinsert

CoolDowner = {}
for k, v in pairs(SpellComponent) do
  CoolDowner[k] = v
end
CoolDowner.__index = CoolDowner

setmetatable(CoolDowner, {
	__index = SpellComponent,
	__call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function CoolDowner:new(frame, spell)
	SpellComponent.new(self, frame, spell)

	self.coolDown = nil
end

function CoolDowner:WithEventHandler()
	self.eventHandler = CoolDownEventHandler(self)
	return self
end

function CoolDowner:GenerateCoolDown(start, stop)
	self.coolDown = CoolDownIndicator(start, stop, self.spell)
	tinsert(self.indicators, self.coolDown)
	
end

function CoolDowner:RefreshCoolDown(start, stop)
	if self.coolDown and not self.coolDown.disposed then
		if self.coolDown.original.start == start then
			self.coolDown:Stop(stop)
		else
			self:GenerateCoolDown(start, stop)
		end
	else
		self.coolDown = nil
	end	
end

function CoolDowner:CheckCooldown()
	local start, duration, enabled = GetSpellCooldown(self.spellName)	
	if enabled==1 and start~=0 and duration and duration>1.5 then		
		local ready = start + duration
		if not self.coolDown or self.coolDown.disposed then
			self:GenerateCoolDown(start, ready) 
		end
			self:RefreshCoolDown(start, ready)
	else
		self.coolDown = nil
	end
end