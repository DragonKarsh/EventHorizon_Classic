local GetSpellInfo = GetSpellInfo

function EventHorizon:CreateDebuffsOptions()
	self.options.args.debuffs = {
		order=4,
		name = "Debuffs",
		desc = "Edit debuff spells",
		type = "group",
		cmdHidden = true,
		args = {
			createDebuff = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new debuff spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewDebuffSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the debuff spell to create",
						order = 2,
						get = function(info) return EventHorizon.newDebuffSpell end,
						set = function(info,val) EventHorizon.newDebuffSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing debuff spells",
				desc = "Already created debuffs",
				type = "group"
			}
		}
	}
end

function EventHorizon:RemoveDebuffSpell(spellName)
	local spellId = self.opt.debuffs[spellName].spellId
	self.opt.debuffs[spellName] = nil
	self:CreateDebuffSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:CreateNewDebuffSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newDebuffSpell)
	-- if no name was returned, it might be a debuff not from the spell book or typo
	if not spellName then
		local cacheSpells = self.spellCache.GetSpellIDsMatchingName(EventHorizon.newDebuffSpell)
		if cacheSpells then
			for i,cacheSpell in pairs(cacheSpells) do
				local cast = select(4,GetSpellInfo(cacheSpell))
				if cast == nil or cast == 0 then
					-- select highest spellId found without a cast time (aura)
					spellId = cacheSpells[i]
					spellName = EventHorizon.newDebuffSpell
				end
			end
		end
	end
	if spellName and not self.opt.debuffs[spellName].spellId then
		local debuff = {
			spellId=spellId, 
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
		self.opt.debuffs[spellName] = debuff
	end	

	self.newDebuffSpell = nil
	self:CreateDebuffSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:CreateDebuffSpellsOptions()
	local debuffSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.debuffs) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		debuffSpells[k] = {
			order = count,
			name = k,
			icon = self.spellCache.GetBestIconMatchingName(k),
			type = "group",
			width = "half",
			args = {
				spellId = {
					order = 1,
					name = "SpellID: "..EventHorizon.opt.debuffs[k].spellId,
					type = "description",
					width = "full"
				},
				enabled = {
					order = 2,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].enabled end,
					set = function(info, val) EventHorizon.opt.debuffs[k].enabled = val EventHorizon:RefreshMainFrame(k) end,
					width = "full"
				},
				ownOnly = {
					order = 3,
					name = "Own only",
					type = "toggle",
					desc = "Track your spell only",
					get = function(info) return EventHorizon.opt.debuffs[k].ownOnly end,
					set = function(info, val) EventHorizon.opt.debuffs[k].ownOnly = val EventHorizon:RefreshMainFrame(k) end,
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
					get = function(info) return EventHorizon.opt.debuffs[k].order end,
					set = function(info, val) EventHorizon.opt.debuffs[k].order = val EventHorizon:RefreshMainFrame(k) end,
				},
				ticks = {
					order = 5,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.debuffs[k].ticks = val self:CreateDebuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 6,
					name = "Ticks",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].ticks end,
					set = function(info, val) EventHorizon.opt.debuffs[k].ticks = val self:CreateDebuffSpellsOptions() EventHorizon:RefreshMainFrame(k) end,
					width="full"
				},
				tickType = {
					order = 7,
					name = "Tick Type",
					desc = "How to set the ticks",
					type = "select",
					values = {["count"]="count",["interval"]="interval"},
					hidden = not EventHorizon.opt.debuffs[k].ticks,
					get = function(info) return EventHorizon.opt.debuffs[k].tickType end,
					set = function(info, val) EventHorizon.opt.debuffs[k].tickType = val self:CreateDebuffSpellsOptions()  EventHorizon:RefreshMainFrame(k) end
				},
				tickCount = {
					order = 8,
					name = "Tick Count",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.debuffs[k].ticks and EventHorizon.opt.debuffs[k].tickType == "count"),
					get = function(info) return EventHorizon.opt.debuffs[k].tickCount end,
					set = function(info, val) EventHorizon.opt.debuffs[k].tickCount = val  EventHorizon:RefreshMainFrame(k) end
				},
				tickInterval = {
					order = 9,
					name = "Tick Interval",
					type = "range",
					min = 1,
					max = 15,
					step = 1,
					hidden =  not (EventHorizon.opt.debuffs[k].ticks and EventHorizon.opt.debuffs[k].tickType == "interval"),
					get = function(info) return EventHorizon.opt.debuffs[k].tickInterval end,
					set = function(info, val) EventHorizon.opt.debuffs[k].tickInterval = val  EventHorizon:RefreshMainFrame(k) end
				},
				lastTick = {
					order = 10,
					name = "Last Tick",
					desc = "End debuff on last detected tick",
					type = "toggle",
					hidden =  not EventHorizon.opt.debuffs[k].ticks,
					get = function(info) return EventHorizon.opt.debuffs[k].lastTick end,
					set = function(info, val) EventHorizon.opt.debuffs[k].lastTick = val  EventHorizon:RefreshMainFrame(k) end
				},
				overrideColors = {
					order = 11,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.debuffs[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.debuffs[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.debuffs[k]) 
						EventHorizon:CreateDebuffSpellsOptions()
						EventHorizon:RefreshMainFrame() 
						end,
					width = "full"
				},							
				colors = {
					order = 12,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.debuffs[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 13,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveDebuffSpell(k) end,				
					width = "full"
				},
			}
		}

		debuffSpells[k].args.colors.args = self:GetColorOptions("debuffs",k)	
	end

	EventHorizon.options.args.debuffs.args.existing.args = debuffSpells
end
