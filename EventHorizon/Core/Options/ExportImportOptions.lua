function EventHorizon:CreateExportImportOptions()
	self.options.args.expimp = {
		order=6,
		name = "Export/Import",
		desc = "Export / Import settings",
		type = "group",
		cmdHidden = true,
		args = {
			controls = {
				order = 1,
				name = "Export current settings / Import settings into a profile",
				type = "group",
				inline = true,
				args = {
					exportButton = {
						name = "Export",
						type = "execute",
						order = 1,
						width = "half",
						func = function() self:DoExport() end
					},
					importButton = {
						name = "Import",
						type = "execute",
						order = 2,
						width = "half",
						func = function() if self:DoImport() then self:OnProfileChanged() end end
					},
					newProfile = {
						name = " New profile name",
						type = "input",
						order = 4,
						width = 1.0,
						get = function(info) return self.newProfileName end,
						set = function(info,val) self.newProfileName = val end
					}
				}
			},
			userInput = {
				order = 2,
				name = "    Output/Input",
				type = "input",
				width = "full",
				multiline = 10,
				order = 2,
				get = function(info) return self.exportImportString end,
				set = function(info,val) self.exportImportString = val end
			}
		}
	}
end

function EventHorizon:DoExport()
	local profile = {}
	EventHorizon.Utils:Copy(self.database.profile, profile)

	self.exportImportString = EventHorizon.Utils:CompressAndEncodeObj(profile)
end

function EventHorizon:DoImport()
	if not self.exportImportString then
		print("EventHorizon ERROR: output/input field is empty, or you did not press \"Accept\" after pasting.")
		return false
	end

	if self.newProfileName then
		for _,profileName in pairs(self.database:GetProfiles()) do
			if self.newProfileName == profileName then
				print("EventHorizon ERROR: profile name already exists. delete the old one first if desirable.")
				return false
			end
		end
	else
		print("EventHorizon ERROR: empty profile name")	
		return false
	end

	local newProfile = EventHorizon.Utils:DecodeAndDecompressString(self.exportImportString)
	if newProfile then
		self.database:SetProfile(self.newProfileName)
		self.database:ResetProfile(false, true)
		EventHorizon.Utils:Copy(self:LocalizeSpellOptions(newProfile), self.database.profile)
	else
		print("EventHorizon ERROR: error importing profile data string.")
		return false
	end
	self.exportImportString = nil
	self.newProfileName = nil
	return true
end

function EventHorizon:LocalizeSpellOptions(profile)
	targetCategories = {"debuffs", "buffs", "channels", "casts"}
	for _, category in ipairs(targetCategories) do
		local convertedSpellOptions = {}
		for spellName, spellInfo in pairs(profile[category]) do
			local localizedSpellName = select(1, GetSpellInfo(spellInfo.spellId))
			convertedSpellOptions[localizedSpellName] = spellInfo
		end
		if next(convertedSpellOptions) ~= nil then
			profile[category] = convertedSpellOptions
		end
	end
	return profile
end