function buildGhostModule(w, h)
	local gfx <const> = playdate.graphics
	local templateImage = gfx.image.new(w, h)
	gfx.pushContext(templateImage)
	gfx.setLineWidth(6)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRoundRect(3, 3, w-6, h-6, 8)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local ghostImage = gfx.image.new(w, h)
	gfx.pushContext(ghostImage)
	templateImage:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	return gfx.sprite.new(ghostImage)
end

function getModName(type)
	local modList = getMenuModList()
	for c=1,#modList do
		local mods = modList[c].mods
		for m=1,#mods do
			local mod = mods[m]
			if mod.type == type then
				return mod.label
			end
		end
	end
end

function getMenuModList()
	return {
		{
			category = "Clock",
			mods = {
				{
					label = "Clock",
					type = "ClockMod"
				},
				{
					label = "Bifurcate x2",
					type = "Bifurcate2Mod"
				},
				{
					label = "Bifurcate x4",
					type = "Bifurcate4Mod"
				},
				{
					label = "Blackhole",
					type = "BlackholeMod"
				},
				{
					label = "Delay",
					type = "ClockDelayMod"
				},
				{
					label = "Divider",
					type = "ClockDividerMod"
				},
				{
					label = "Doubler",
					type = "ClockDoublerMod"
				}
			}
		},
		{
			category = "Sequencing",
			mods = {
				{
					label = "Sequencer",
					type = "ArpMod"
				},
				{
					label = "Smol Sequencer",
					type = "SeqGridMod"
				},
				{
					label = "SPST Switch",
					type = "SwitchMod"
				},
				{
					label = "SPST Timed",
					type = "TimedSwitchMod"
				},
				{
					label = "SPDT Switch",
					type = "SwitchSPDTMod"
				},
			}
		},
		{
			category = "Drums",
			mods = {
		  	{
					label = "Drum Machine",
					type = "DrumMod"
				},
				{
					label = "OR-606",
					type = "OR606Mod"
				}
			}
		},
		{
			category = "Synths",
			mods = {
				{
					label = "Max Synth",
					type = "SynthMod"
				},
				{
					label = "Micro Synth",
					type = "MicroSynthMod"
				}
			}
		},
		{
			category = "Effects",
			mods = {
				{
					label = "Bitcrusher",
					type = "BitcrusherMod"
				},
				{
					label = "Delay",
					type = "DelayMod"
				},
				{
					label = "Low-pass Filter",
					type = "LowpassMod"
				},
				{
					label = "One Pole Filter",
					type = "OnePoleFilterMod"
				},
				{
					label = "Overdrive",
					type = "OverdriveMod"
				},
				{
					label = "Ring Modulator",
					type = "RingModulatorMod"
				},
			}
		},
		{
			category = "Notes/Midi",
			mods = {
				{
					label = "MidiGen",
					type = "MidiGenMod"
				},
				{
					label = "Value2Midi",
					type = "NormalisedToMidiMod"
				}
			}
		},
		{
			category = "Output",
			mods = {
				{
					label = "Mix output x1",
					type = "SpeakerMod"
				},
				{
					label = "Mix output x4",
					type = "Mix4Mod"
				},
				{
					label = "Mix output x4 v2",
					type = "Mix4SliderMod"
				},
				{
					label = "Mix output x8",
					type = "Mix8Mod"
				},
				{
					label = "Mix output x8 v2",
					type = "Mix8SliderMod"
				}
			}
		},
		{
			category = "Utilities",
			mods = {
				{
					label = "Print/Log",
					type = "PrintMod"
				},
				{
					label = "RNG",
					type = "RandomMod"
				},
				{
					label = "Label",
					type = "LabelMod"
				}
			}
		}
	}
end

function generateModBackground(w, h)
	local gfx <const> = playdate.graphics
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(2)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.setLineWidth(1)
	gfx.popContext()
	
	return backgroundImage
end


function generateModBackgroundWithShadow(w, h)
	local gfx <const> = playdate.graphics
	
	local shadowPadding = 7
	local shadowW = w + (shadowPadding*2)
	local shadowH = h + (shadowPadding*2)
	local backgroundShadowImage = gfx.image.new(shadowW, shadowH)
	gfx.pushContext(backgroundShadowImage)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.fillRoundRect(shadowPadding/2, shadowPadding/2, shadowW - (shadowPadding/2), shadowH - (shadowPadding/2), gCornerRad)
	gfx.popContext()
	
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(2)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local baseW = shadowW + (shadowPadding*2)
	local baseH = shadowH + (shadowPadding*2)
	local baseImage = gfx.image.new(baseW, baseH)
	gfx.pushContext(baseImage)
	backgroundShadowImage:drawBlurred((baseW - shadowW)/2, (baseH - shadowH)/2, 6, 2, playdate.graphics.image.kDitherTypeDiagonalLine)
	--backgroundShadowImage:draw(baseImagePadding, baseImagePadding)
	
	
	gfx.popContext()
	
	
	local baseImage2 = gfx.image.new(baseW, baseH)
	gfx.pushContext(baseImage2)
	baseImage:drawFaded(0, 0, 0.6, playdate.graphics.image.kDitherTypeScreen)
	backgroundImage:draw((baseW - w)/2, (baseH - h)/2)
	gfx.popContext()
	return baseImage2
end

function generateModBackgroundWithShadow2(w, h)
	local gfx <const> = playdate.graphics
	
	local shadowPadding = 7
	local shadowW = w + (shadowPadding*2)
	local shadowH = h + (shadowPadding*2)
	local backgroundShadowImage = gfx.image.new(shadowW, shadowH)
	gfx.pushContext(backgroundShadowImage)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.fillRoundRect(shadowPadding/2, shadowPadding/2, shadowW - (shadowPadding/2), shadowH - (shadowPadding/2), gCornerRad)
	gfx.popContext()
	
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(2)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local baseW = shadowW + (shadowPadding*2)
	local baseH = shadowH + (shadowPadding*2)
	local baseImage = gfx.image.new(baseW, baseH)
	gfx.pushContext(baseImage)
	backgroundShadowImage:drawBlurred((baseW - shadowW)/2, (baseH - shadowH)/2, 4, 4, playdate.graphics.image.kDitherTypeDiagonalLine)
	backgroundImage:draw((baseW - w)/2, (baseH - h)/2)
	
	gfx.popContext()
	
	return baseImage
end