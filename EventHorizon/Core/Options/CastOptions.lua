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

	if spellName and not self.opt.casts[spellName] then
		local cast = {
			spellId=spellId, 
			enabled=true, 
			order=1,
			overrideColors=false,
			colors={
				cast=EventHorizon.opt.colors.cast,
				tick=EventHorizon.opt.colors.tick,
				coolDown=EventHorizon.opt.colors.coolDown,
				ready=EventHorizon.opt.colors.ready,
				channel=EventHorizon.opt.colors.channel,
				sent=EventHorizon.opt.colors.sent
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