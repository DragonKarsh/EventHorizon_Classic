function EventHorizon:CreateBuffsOptions()
	self.options.args.buffs = {
		order=5,
		name = "Buffs",
		desc = "Edit buff spells",
		type = "group",
		cmdHidden = true,
		args = {
			createBuff = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new buff spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewBuffSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the buff spell to create",
						order = 2,
						get = function(info) return EventHorizon.newBuffSpell end,
						set = function(info,val) EventHorizon.newBuffSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing buff spells",
				desc = "Already created buffs",
				type = "group"
			}
		}
	}
end

function EventHorizon:RemoveBuffSpell(spellName)
	local spellId = self.opt.buffs[spellName].spellId
	self.opt.buffs[spellName] = nil
	self:CreateBuffSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:CreateNewBuffSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newBuffSpell)
	-- if no name was returned, it might be a debuff not from the spell book or typo
	if not spellName then
		local cacheSpells = self.spellCache.GetSpellIDsMatchingName(EventHorizon.newBuffSpell)
		if cacheSpells then
			for i,cacheSpell in pairs(cacheSpells) do
				local cast = select(4,GetSpellInfo(cacheSpell))
				if cast == nil or cast == 0 then
					-- select highest spellId found without a cast time (aura)
					spellId = cacheSpells[i]
					spellName = EventHorizon.newBuffSpell
				end
			end
		end
	end
	if spellName and not self.opt.buffs[spellName].spellId then
		local buff = {
			spellId=spellId, 
			unitId="player", 
			ticks=false, 
			tickType="count", 
			tickCount=1, 
			tickInterval=1, 
			lastTick=false, 
			enabled=true, 
			order=1,
			overrideColors=false,
			ownOnly=true,
			colors={
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
		}
		self.opt.buffs[spellName] = buff
	end	

	self.newBuffSpell = nil
	self:CreateBuffSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateBuffSpellsOptions()
	local buffSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.buffs) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		buffSpells[k] = {
			order = count,
			name = k,
			icon = self.spellCache.GetBestIconMatchingName(k),
			type = "group",
			width = "half",
			args = {
				spellId = {
					order = 1,
					name = "SpellID: "..EventHorizon.opt.buffs[k].spellId,
					type = "description",
					width = "full"
				},			
				enabled = {
					order = 2,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].enabled end,
					set = function(info, val) EventHorizon.opt.buffs[k].enabled = val EventHorizon:RefreshMainFrame(k) end,
					width = "full"
				},
				ownOnly = {
					order = 3,
					name = "Own only",
					type = "toggle",
					desc = "Track your spell only",
					get = function(info) return EventHorizon.opt.buffs[k].ownOnly end,
					set = function(info, val) EventHorizon.opt.buffs[k].ownOnly = val EventHorizon:RefreshMainFrame(k) end,
					width = "full"
				},
				order = {
					order = 4,
					name = "Order",
					type = "range",
					desc = "Sort order on frame",
					min = 1,
					max = 10,
					step = 1,
					get = function(info) return EventHorizon.opt.buffs[k].order end,
					set = function(info, val) EventHorizon.opt.buffs[k].order = val EventHorizon:RefreshMainFrame(k) end,
				},				
				unitId = {
					order = 5,
					name = "Unit",
					desc = "Which unit this buff targets",
					type = "select",
					values = {["player"]="player",["target"]="target"},
					get = function(info)  return EventHorizon.opt.buffs[k].unitId  end,
					set = function(info, val) EventHorizon.opt.buffs[k].unitId = val  EventHorizon:RefreshMainFrame(k) end
				},
				ticks = {
					order = 6,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.buffs[k].ticks = val self:CreateBuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 7,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.buffs[k].ticks = val self:CreateBuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 8,
					name = "Tick Type",
					desc = "How to set the ticks",
					type = "select",
					hidden =  not EventHorizon.opt.buffs[k].ticks,
					values = {["count"]="count",["interval"]="interval"},
					get = function(info) return EventHorizon.opt.buffs[k].tickType end,
					set = function(info, val) EventHorizon.opt.buffs[k].tickType = val self:CreateBuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end
				},
				tickCount = {
					order = 9,
					name = "Tick Count",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.buffs[k].ticks and EventHorizon.opt.buffs[k].tickType == "count"),
					get = function(info) return EventHorizon.opt.buffs[k].tickCount end,
					set = function(info, val) EventHorizon.opt.buffs[k].tickCount = val  EventHorizon:RefreshMainFrame(k) end
				},
				tickInterval = {
					order = 10,
					name = "Tick Interval",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.buffs[k].ticks and EventHorizon.opt.buffs[k].tickType == "interval"),
					get = function(info) return EventHorizon.opt.buffs[k].tickInterval end,
					set = function(info, val) EventHorizon.opt.buffs[k].tickInterval = val  EventHorizon:RefreshMainFrame(k) end
				},
				lastTick = {
					order = 11,
					name = "Last Tick",
					desc = "End buff on last detected tick",
					type = "toggle",
					hidden =  not EventHorizon.opt.buffs[k].ticks,
					get = function(info) return EventHorizon.opt.buffs[k].lastTick end,
					set = function(info, val) EventHorizon.opt.buffs[k].lastTick = val  EventHorizon:RefreshMainFrame(k) end
				},
				overrideColors = {
					order = 12,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.buffs[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.buffs[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.buffs[k]) 
						EventHorizon:CreateBuffSpellsOptions()
						EventHorizon:RefreshMainFrame() end,
					width = "full"
				},						
				colors = {
					order = 13,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.buffs[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 14,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveBuffSpell(k) end,				
					width = "full"
				},
			}
		}

		buffSpells[k].args.colors.args = self:GetColorOptions("buffs",k)	
	end

	EventHorizon.options.args.buffs.args.existing.args = buffSpells
end

