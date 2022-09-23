EventHorizon.defaults = {
	profile = {
		past = -3,
		future = 9,
		height = 25,
		width = 375,
		version = 202209220,
		throttle = 10,
		texture = "EventHorizon_Smooth",
		colors = {		 
			cast = {r=0,g=1,b=0,a=0.9},
			channel = {r=0,g=1,b=0,a=0.9},
			aura = {r=1,g=1,b=1,a=0.7},
			coolDown = {r=0.9,g=0.9,b=0.9,a=0.7},
			ready = {r=0.5,g=0.5,b=0.5,a=0.7},
			tick = {r=1,g=1,b=1,a=1},
			sent = {r=1,g=1,b=1,a=1},
			now = {r=1,g=1,b=1,a=1},
			gcd = {r=1,g=1,b=1,a=0.5},
			border = {r=0,g=0,b=0,a=1},
			background = {r=1,g=1,b=1,a=0.1}
		},
		now=true,
		gcd=true,
		gcdSpell = 61304,
		enabled = true,
		shown = true,
		locked = false,
		combat = false,
		casts = {['*']={overrideColors=false}},
		channels = {['*']={overrideColors=false}},
		debuffs = {['*']={overrideColors=false}},
		buffs = {['*']={overrideColors=false}},
		zoom = 0,
	}
}

EventHorizon.defaults.profile.scale = 1/(EventHorizon.defaults.profile.future-EventHorizon.defaults.profile.past)

function EventHorizon:InitializeDatabase()
	self.database = LibStub("AceDB-3.0")
	:New("EventHorizonDatabase", self.defaults, true)
	self.opt = self.database.profile

	self:ApplyConversions()

	self.database.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.database.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.database.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.database.RegisterCallback(self, "OnNewProfile", "OnProfileChanged")
end

function EventHorizon:OnProfileChanged()
	self.opt = self.database.profile
	self:ApplyConversions()
	self:InitializeAllOptions()
	self:RefreshMainFrame()
end

function EventHorizon:ApplyConversions()
	--on 2022-09-16, color overrides were introduced. To avoid losing data, apply conversion
	if self.opt.version < 202209160 then
		self:ConvertColors()
		self.opt.version = 202209160
	end

	--on 2022-09-22, colors were changed to store r,g,b,a explicitly
	if self.opt.version < 202209220 then
		self:ExplicitRgbaColors()
		self.opt.version = 202209220
	end
end

function EventHorizon:ConvertColors()	
	if EventHorizon.opt.casting then
		EventHorizon.opt.colors.channel = EventHorizon.opt.casting
		EventHorizon.opt.colors.cast = EventHorizon.opt.casting
	end

	if EventHorizon.opt.tick then
		EventHorizon.opt.colors.tick = EventHorizon.opt.tick
	end

	if EventHorizon.opt.ready then
		EventHorizon.opt.colors.ready = EventHorizon.opt.ready
	end

	if EventHorizon.opt.coolDown then	
		EventHorizon.opt.colors.coolDown = EventHorizon.opt.coolDown
	end

	if EventHorizon.opt.debuff then
		EventHorizon.opt.colors.aura = EventHorizon.opt.debuff
	end

	if EventHorizon.opt.sent then
		EventHorizon.opt.colors.sent = EventHorizon.opt.sent
	end

	if EventHorizon.opt.gcdColor then
		EventHorizon.opt.colors.gcd = EventHorizon.opt.gcdColor
	end

	if EventHorizon.opt.nowColor then
		EventHorizon.opt.colors.now = EventHorizon.opt.nowColor
	end

	if EventHorizon.opt.border then
		EventHorizon.opt.colors.border = EventHorizon.opt.border
	end

	if EventHorizon.opt.background then
		EventHorizon.opt.colors.background = EventHorizon.opt.background
	end
end

function EventHorizon:ExplicitRgbaColors()
	local colors = {'aura','cast','channel','tick','sent','coolDown','ready','now','gcd','background','border'}

	for _, color in ipairs(colors) do
		self:FixGeneralRgba(color)
	end

	local categories = {'channels','casts','buffs','debuffs'}
	for _,category in ipairs(categories) do
		for spell,_ in pairs(self.opt[category]) do
			for _,color in ipairs(colors) do
				if self.opt[category][spell].overrideColors then
					self:FixRgba(self.opt[category][spell].colors, self.opt.colors, color)
				end
			end
		end
	end	
end

function EventHorizon:FixGeneralRgba(color)
	local r,g,b,a = unpack(self.opt.colors[color])
	self:FixGeneralRgbaValue(color,'r',r)
	self:FixGeneralRgbaValue(color,'g',g)
	self:FixGeneralRgbaValue(color,'b',b)
	self:FixGeneralRgbaValue(color,'a',a)
end
function EventHorizon:FixGeneralRgbaValue(color,value,current)
	if current and current ~= self.opt.colors[color][value] then
		self.opt.colors[color][value] = current
	end
end
function EventHorizon:FixRgba(colors, defaults, color)
	local values = {'r','g','b','a'}
	for _,value in ipairs(values) do
		if colors and colors[color] and not colors[color][value] then
			colors[color][value] = defaults[color][value]
		elseif  colors and not colors[color] then
			if defaults[color] then
				colors[color] = defaults[color]
			else
				colors[color] = EventHorizon.defaults.profile.colors[color]
			end
		end			
	end	
end

	
