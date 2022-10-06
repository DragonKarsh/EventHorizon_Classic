local GetSpellInfo = GetSpellInfo

function EventHorizon:CreateCastedOptions()
	self.options.args.casts = {
		order=3,
		name = "Directs",
		desc = "Edit direct spells",
		type = "group",
		cmdHidden = true,
		args = {
			createCast = {
				order = 1,
				name = "Create new spell",
				desc = "Create a new direct spell",
				type = "group",
				inline = true,
				args = {
					create = {
						name = "Create",
						type = "execute",
						order = 1,
						func = function() EventHorizon:CreateNewCastedSpell() end
					},
					input = {
						name = "Spell name/id",
						type = "input",
						desc = "Enter spellname or spellId of the direct spell to create",
						order = 2,
						get = function(info) return EventHorizon.newCastedSpell end,
						set = function(info,val) EventHorizon.newCastedSpell = val end
					}
				}
			},
			existing = {
				order = 2,
				name = "Existing direct spells",
				desc = "Already created direct spells",
				type = "group"
			}
		}
	}
end

function EventHorizon:CreateNewCastedSpell()
	local spellName,_,_,_,_,_,spellId = GetSpellInfo(EventHorizon.newCastedSpell)

	if spellName and not self.opt.casts[spellName].spellId then
		local cast = {
			spellId=spellId, 
			enabled=true, 
			order=1,
			overrideColors=false,
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
		self.opt.casts[spellName] = cast
	end

	self.newCastedSpell = nil
	self:CreateCastedSpellsOptions()
	self:RefreshMainFrame()
end

function EventHorizon:RemoveCastedSpell(spellName)
	local spellId = self.opt.casts[spellName].spellId
	self.opt.casts[spellName] = nil
	self:CreateCastedSpellsOptions()
	self.mainFrame:ReleaseSpellFrame(spellId)
end

function EventHorizon:CreateCastedSpellsOptions()
	local castedSpells = {}
	local count = 0

	local sorted = {}
	for k,v in pairs(self.opt.casts) do
		tinsert(sorted, k)
	end

	for i,k in ipairs(sorted) do
		count = count + 1
		castedSpells[k] = {
			order = count,
			name = k,
			icon = select(3,GetSpellInfo(EventHorizon.opt.casts[k].spellId)),
			type = "group",
			width = "half",
			args = {
				enabled = {
					order = 1,
					name = "Enabled",
					type = "toggle",
					get = function(info) return EventHorizon.opt.casts[k].enabled end,
					set = function(info, val) EventHorizon.opt.casts[k].enabled = val EventHorizon:RefreshMainFrame() end,
					width = "full"
				},				
				order = {
					order = 2,
					name = "Order",
					type = "range",
					desc = "Sort order on frame",
					min = 1,
					max = 10,
					step = 1,
					get = function(info) return EventHorizon.opt.casts[k].order end,
					set = function(info, val) EventHorizon.opt.casts[k].order = val EventHorizon:RefreshMainFrame() end,
				},
				overrideColors = {
					order = 3,
					name = "Override default colors",
					type = "toggle",
					get = function(info) return EventHorizon.opt.casts[k].overrideColors end,
					set = function(info, val) 
						EventHorizon.opt.casts[k].overrideColors = val 
						EventHorizon:OverrideColors(EventHorizon.opt.casts[k])
						EventHorizon:CreateCastedSpellsOptions()
						EventHorizon:RefreshMainFrame() end,
					width = "full"
				},
					
				colors = {
					order = 4,
					name = "Colors",
					type = "group",
					inline = true,
					hidden = (not EventHorizon.opt.casts[k].overrideColors),
					args = {
					
					}
				},
				remove = {
					order = 5,
					name = "Remove",
					type = "execute",
					func = function() EventHorizon:RemoveCastedSpell(k) end,				
					width = "full"
				},
			}
		}

		castedSpells[k].args.colors.args = self:GetColorOptions("casts",k)	
	end

	EventHorizon.options.args.casts.args.existing.args = castedSpells
end