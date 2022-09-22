function EventHorizon:OverrideColors(config)
	config.colors = {
		cast = {
			r=EventHorizon.opt.colors.cast.r,
			g=EventHorizon.opt.colors.cast.g,
			b=EventHorizon.opt.colors.cast.b,
			a=EventHorizon.opt.colors.cast.a
		
		},
		channel = {
			r=EventHorizon.opt.colors.channel.r,
			g=EventHorizon.opt.colors.channel.g,
			b=EventHorizon.opt.colors.channel.b,
			a=EventHorizon.opt.colors.channel.a
		},
		tick = {
			r=EventHorizon.opt.colors.tick.r,
			g=EventHorizon.opt.colors.tick.g,
			b=EventHorizon.opt.colors.tick.b,
			a=EventHorizon.opt.colors.tick.a
		},
		ready = {
			r=EventHorizon.opt.colors.ready.r,
			g=EventHorizon.opt.colors.ready.g,
			b=EventHorizon.opt.colors.ready.b,
			a=EventHorizon.opt.colors.ready.a
		},
		coolDown = {
			r=EventHorizon.opt.colors.coolDown.r,
			g=EventHorizon.opt.colors.coolDown.g,
			b=EventHorizon.opt.colors.coolDown.b,
			a=EventHorizon.opt.colors.coolDown.a
		},
		sent = {
			r=EventHorizon.opt.colors.sent.r,
			g=EventHorizon.opt.colors.sent.g,
			b=EventHorizon.opt.colors.sent.b,
			a=EventHorizon.opt.colors.sent.a
		},
		aura = {
			r=EventHorizon.opt.colors.aura.r,
			g=EventHorizon.opt.colors.aura.g,
			b=EventHorizon.opt.colors.aura.b,
			a=EventHorizon.opt.colors.aura.a
		}
	}
end

function EventHorizon:GetColor(indicator,spell,spellName)
	 if EventHorizon.opt[spell][spellName].overrideColors then
		return  self.Utils:UnpackColor(EventHorizon.opt[spell][spellName].colors[indicator])
	else		
		return self.Utils:UnpackColor(EventHorizon.opt.colors[indicator])
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
				get = function(info) return EventHorizon:GetColor('channel',spell,spellName) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"channel",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			cast = {
				order = 2,
				type = "color",
				name = "Cast",
				desc = "Set the casting color",
				hasAlpha = true,
				get = function(info) return EventHorizon:GetColor('cast',spell,spellName) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"cast",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			aura = {
				order = 3,
				type = "color",
				name = "Aura",
				desc = "Set the aura color",
				hasAlpha = true,
				get = function(info) return EventHorizon:GetColor('aura',spell,spellName) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"aura",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			tick = {
				order = 4,
				type = "color",
				name = "Tick",
				desc = "Set the tick color",
				hasAlpha = true,
				get = function(info) return EventHorizon:GetColor('tick',spell,spellName) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"tick",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			coolDown = {
				order = 5,
				type = "color",
				name = "Cooldown",
				desc = "Set the cooldown color",
				hasAlpha = true,
				get = function(info) return EventHorizon:GetColor('coolDown',spell,spellName) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"coolDown",r,g,b,a) EventHorizon:RefreshMainFrame() end
			},
			ready = {
				order = 6,
				type = "color",
				name = "Ready",
				desc = "Set the ready color",
				hasAlpha = true,
				get = function(info) return EventHorizon:GetColor('ready',spell,spellName) end,
				set = function(info,r,g,b,a)  EventHorizon:OverrideColor(spell,spellName,"ready",r,g,b,a) EventHorizon:RefreshMainFrame() end
			}
		}
		
end

function EventHorizon:OverrideColor(spell, spellName, color, r,g,b,a)
	if not EventHorizon.opt[spell][spellName].colors then
		self:OverrideColors(EventHorizon.opt[spell][spellName])
	end

	EventHorizon.opt[spell][spellName].colors[color].r = r
	EventHorizon.opt[spell][spellName].colors[color].g = g
	EventHorizon.opt[spell][spellName].colors[color].b = b
	EventHorizon.opt[spell][spellName].colors[color].a = a

	if spell == "channels" then self:CreateChanneledSpellsOptions()
	elseif spell == "casts" then self:CreateCastedSpellsOptions()
	elseif spell == "debuffs" then self:CreateDebuffSpellsOptions()
	elseif spell == "buffs" then self:CreateBuffSpellsOptions()
	end	
end