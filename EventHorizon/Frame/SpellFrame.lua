SpellFrame = {}

function SpellFrame:CreateFrame(mainFrame, spellConfig)
	local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")	

	frame.spell = SpellBase(spellConfig)

	frame.mainFrame = mainFrame	
	frame.past = mainFrame.past
	frame.future = mainFrame.future
	frame.width = mainFrame.width
	frame.height = mainFrame.height
	frame.scale = mainFrame.scale

	local texture = select(3,GetSpellInfo(spellConfig.spellId))
	frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -#mainFrame.spellFrames * mainFrame.height)
	tinsert(mainFrame.spellFrames, frame)
	mainFrame:SetHeight(#mainFrame.spellFrames * mainFrame.height)
	frame:SetWidth(mainFrame.width)
	frame:SetHeight(mainFrame.height)
	frame:SetBackdrop{bgFile = [[Interface\Addons\EventHorizon\Smooth]]}
	frame:SetBackdropColor(1,1,1,.1)

	local icon = frame:CreateTexture(nil, "BORDER")
	icon:SetTexture(texture)
	icon:SetPoint("TOPRIGHT", frame, "TOPLEFT")
	icon:SetWidth(mainFrame.height)
	icon:SetHeight(mainFrame.height)
	frame.icon = icon	

	frame.updater = SpellFrameUpdater(frame)
	frame.eventHandler = SpellFrameEventHandler(frame)

	frame.updater:Enable()
	frame.eventHandler:Enable()

	return frame
end