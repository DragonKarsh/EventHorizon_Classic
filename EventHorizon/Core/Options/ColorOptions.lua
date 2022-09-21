function EventHorizon:OverrideColors(config)
	config.colors = {}
	config.colors.cast = EventHorizon.opt.colors.cast	
	config.colors.channel = EventHorizon.opt.colors.channel
	config.colors.tick = EventHorizon.opt.colors.tick
	config.colors.ready = EventHorizon.opt.colors.ready
	config.colors.coolDown = EventHorizon.opt.colors.coolDown
	config.colors.sent = EventHorizon.opt.colors.sent
	config.colors.aura = EventHorizon.opt.colors.aura
end

function EventHorizon:GetColor(indicator,spell,spellName)
	 if EventHorizon.opt[spell][spellName].colors 
	 and EventHorizon.opt[spell][spellName].colors[indicator] 
	 and #EventHorizon.opt[spell][spellName].colors[indicator] > 0 
	 then
		return EventHorizon.opt[spell][spellName].colors[indicator]
	else		
		return EventHorizon.opt.colors[indicator]
	end
end

function EventHorizon:GetColorOptions(spell,spellName)

	return {
			channel = {
				order = 1,
				type = "color",
				name = "Channel",
				desc = "Set the channeling color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon:GetColor('channel',spell,spellName)) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"channel",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			cast = {
				order = 2,
				type = "color",
				name = "Cast",
				desc = "Set the casting color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon:GetColor('cast',spell,spellName)) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"cast",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			aura = {
				order = 3,
				type = "color",
				name = "Aura",
				desc = "Set the aura color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon:GetColor('aura',spell,spellName)) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"aura",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			tick = {
				order = 4,
				type = "color",
				name = "Tick",
				desc = "Set the tick color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon:GetColor('tick',spell,spellName)) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"tick",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			coolDown = {
				order = 5,
				type = "color",
				name = "Cooldown",
				desc = "Set the cooldown color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon:GetColor('coolDown',spell,spellName)) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"coolDown",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			ready = {
				order = 6,
				type = "color",
				name = "Ready",
				desc = "Set the ready color",
				hasAlpha = true,
				get = function(info) return unpack(EventHorizon:GetColor('ready',spell,spellName)) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"ready",r,g,b,a) EventHorizon:RefreshMainFrame() end
			}
		}
		
end

function EventHorizon:OverrideColor(spell, spellName, color, r,g,b,a)
	if not EventHorizon.opt[spell][spellName].colors then
		self:OverrideColors(EventHorizon.opt[spell][spellName])
	end
	EventHorizon.opt[spell][spellName].colors[color] = {r,g,b,a}

	if spell == "channels" then self:CreateChanneledSpellsOptions()
	elseif spell == "casts" then self:CreateCastedSpellsOptions()
	elseif spell == "debuffs" then self:CreateDebuffSpellsOptions()
	elseif spell == "buffs" then self:CreateBuffSpellsOptions()
	end	
end