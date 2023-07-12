import 'Modules/mod_utils'
import 'Interface/reticle_sprite'
import 'Interface/module_popup'
import 'Interface/modal_dialog'
import 'Modules/module_manager'

-- Modules
import 'Modules/patch_cable'

import 'Modules/Sprites/bang_sprite'
import 'Modules/Sprites/socket_sprite'

import 'Modules/Arpeggiator/arp_mod'
import 'Modules/Bifurcate2/bifurcate2_mod'
import 'Modules/Bifurcate4/bifurcate4_mod'
import 'Modules/Blackhole/blackhole_mod'
import 'Modules/Clock/clock_mod'
import 'Modules/Clock2/clock2_mod'
import 'Modules/ClockDelay/clock_delay_mod'
import 'Modules/ClockDivider/clock_divider_mod'
import 'Modules/ClockDoubler/clock_doubler_mod'
import 'Modules/DrumMachine/drum_mod'

import 'Modules/MidiGen/midi_gen_mod'
import 'Modules/Mixers/Mixer1/mix1_mod'
import 'Modules/Mixers/Mixer1v2/mix1v2_mod'
import 'Modules/Mixers/Mixer4/mix4_mod'
import 'Modules/Mixers/Mixer8/mix8_mod'
import 'Modules/Mixers/Mixer8Sliders/mix8sliders_mod'
import 'Modules/Mixers/Mixer4Sliders/mix4sliders_mod'
import 'Modules/NormalisedToMidi/normalised_to_midi_mod'
import 'Modules/OR606/or606_mod'
import 'Modules/Print/print_module'
import 'Modules/Random/random_mod'
import 'Modules/SequencerGrid/seq_grid_mod'
import 'Modules/Switches/Timed/timed_switch_mod'
import 'Modules/Switch/switch_mod'
import 'Modules/SwitchSPDT/switch_spdt_mod'

--Synths
import 'Modules/MicroSynth/micro_synth_mod'
import 'Modules/Synths/NoiseBox/noise_box_mod'
import 'Modules/Synths/Sine/simplex_sine_mod'
import 'Modules/Synths/StochasticTriangle/stochastic_triangle_mod'
import 'Modules/Synths/StochasticSquare/stochastic_square_mod'
import 'Modules/Synth/synth_mod'

--Effects
import 'Modules/Effects/Bitcrusher/bitcrusher_mod'
import 'Modules/Effects/Delay/delay_mod'
import 'Modules/Effects/Highpass/highpass_mod'
import 'Modules/Effects/Lowpass/lowpass_mod'
import 'Modules/Effects/OnePoleFilter/one_pole_filter_mod'
import 'Modules/Effects/Overdrive/overdrive_mod'
import 'Modules/Effects/RingModulator/ring_modulator_mod'

--UI
import 'Modules/UI/LabelRegular/label_mod'
import 'Modules/UI/LabelLarge/large_label_mod'
import 'Modules/UI/Button/button_mod'
import 'Modules/UI/Arrow/arrow_mod'


import 'CoracleViews/rotary_encoder'

class('ModularScreen').extends()

local gfx <const> = playdate.graphics

globalXDrawOffset = 800
globalYDrawOffset = 0

local modeStandard = 1
local modeGhostModule = 2

local globalScrollStep = 8
local smallScrollStep = 4
local modulePopup = nil

function ModularScreen:init(value)
	ModularScreen.super.init(self)
	
	self.showing = false
	self.allowScroll = true
	
	self.mode = modeStandard
	
	self.scale = 1
	
	self.modules = ModuleManager()
	
	self.ghostSprite = nil--used when adding new modules

	--local backgroundTable = gfx.imagetable.new("Images/background-table-64-64")
	local backgroundTable = gfx.imagetable.new("Images/background_lite-table-64-64")
	self.tilemap = gfx.tilemap.new()
	self.tilemap:setImageTable(backgroundTable)
	self.tilemap:setSize(30,20)
	
	for y = 0,40 do
		for x = 0,50 do
			self.tilemap:setTileAtPosition(x,y,1)
		end
	end	
	
	self.backgroundSprite = gfx.sprite.new(self.tilemap)
	self.backgroundSprite:moveTo(0, 0)
	self.backgroundSprite:add()
		
	self.reticle = ReticleSprite()
	
	self:move()
	
	self.scrollhandled = false
end

function ModularScreen:new()
	local newDialog = ModalDialog("Discard unsaved changes")
	newDialog:show(function(confirm) 
		if confirm == true then
			gPatchPath = nil
			self.modules:deleteAll()
		end
	end)
end

function ModularScreen:loadPatch(path, overrideCheck)
	if path == nil then
		print("Can't load nil patch")
		return
	end
	if overrideCheck ~= nil and overrideCheck == true then
		gPatchPath = path
		self.modules:loadPatch(path, function() 
			self:move()
		end)
	else
		local newDialog = ModalDialog("Discard unsaved changes")
		newDialog:show(function(confirm) 
			if confirm == true then
				gPatchPath = path
				self.modules:loadPatch(path, function() 
					self:move()
				end)
			end
		end)
	end
	
end

function ModularScreen:saveCurrentPatch()
	self.modules:saveCurrent()
end

function ModularScreen:savePatch(name)
	print("Save Patch... " .. name)
	self.modules:savePatch(name)
end

function ModularScreen:deletePatch(patch)
	local newDialog = ModalDialog("Delete " .. patch, "(B) No", "(A) Yes")
	newDialog:show(function(confirm) 
		if confirm == true then
			gPatchPath = nil
			self.modules:deleteAll()
			playdate.file.delete(patch)
		end
	end)
end

--https://sdk.play.date/inside-playdate/#_querying_buttons_directly
function ModularScreen:push(patchPath)
	self.inputHandler = {
		
		cranked = function(change, acceleratedChange)
			self.scrollhandled = false
			self.didScale = false
			if playdate.buttonIsPressed(playdate.kButtonLeft) or playdate.buttonIsPressed(playdate.kButtonRight) then
				globalXDrawOffset += change
				self.scrollhandled = true
			end
			if playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonDown) then
				globalYDrawOffset += change
				self.scrollhandled = true
			end
			if playdate.buttonIsPressed(playdate.kButtonB) then
				if change > 0 and	playdate.display.getScale() ~= 1  then
					playdate.display.setScale(1)
					self:scaleChanged()
				elseif change < 0  and	playdate.display.getScale() ~= 2 then
					playdate.display.setScale(2)
					self:scaleChanged()
				end
				
				self.didScale = true
				self.scrollhandled = true
			end
			
			if self.scrollhandled == false then
				local xLocation = (-1 * globalXDrawOffset) + 200
				local yLocation = (-1 * globalYDrawOffset) + 120
				if self.scale == 2 then
					xLocation = (-1 * globalXDrawOffset) + 100
					yLocation = (-1 * globalYDrawOffset) + 60
				end
				self.modules:handleCrankTurn(xLocation, yLocation, change)
			else
				if self.didScale == false then
					self:move()
				end
			end
		end,
		
		leftButtonUp = function() self:checkReticleLocation() end,
		rightButtonUp = function() self:checkReticleLocation() end,
		upButtonUp = function() self:checkReticleLocation() end,
		downButtonUp = function() self:checkReticleLocation() end,
		
		BButtonDown = function()
			if self.mode == modeGhostModule then
				self.ghostSprite:remove()
				self.ghostSprite = nil
				self.mode = modeStandard
			else
				local xLocation = (-1 * globalXDrawOffset) + 200
				local yLocation = (-1 * globalYDrawOffset) + 120
				
				if self.scale == 2 then
					xLocation = (-1 * globalXDrawOffset) + 100
					yLocation = (-1 * globalYDrawOffset) + 60
				end
				
				if self.modules:collides(xLocation, yLocation) then
					self.modules:handleCableAt(xLocation, yLocation)
				else
					self.modules:dropCable()
				end
			end
		end,
		
		AButtonDown = function()
			local xLocation = (-1 * globalXDrawOffset) + 200
			local yLocation = (-1 * globalYDrawOffset) + 120
			
			if self.scale == 2 then
				xLocation = (-1 * globalXDrawOffset) + 100
				yLocation = (-1 * globalYDrawOffset) + 60
			end
			
			if self.mode == modeStandard then
				if self.modules:collides(xLocation, yLocation) then
					self:handleModClick(xLocation, yLocation)
				else
					modulePopup = ModulePopup()
					gScrollLock = true
					modulePopup:show(function(module) 
						self.ghostModuleType = module.type
						self.ghostSprite = self.modules:getGhostSprite(module.type)
						if self.ghostSprite ~= nil then
							self.ghostSprite:setIgnoresDrawOffset(true)
							if self.scale == 1 then
								self.ghostSprite:moveTo(200, 120)
							elseif self.scale == 2 then
								self.ghostSprite:moveTo(100, 60)
							end
							
							self.ghostSprite:add()
							self.mode = modeGhostModule
						else
							-- just add for now
							print("No ghost - adding: " .. module.type)
							self.modules:addNewAt(module.type, xLocation, yLocation)
							self.mode = modeStandard
						end
						gScrollLock = false
					end, 1, self.scale)
				end
			elseif self.mode == modeGhostModule then
				print("GHOST MOD TYPE " .. self.ghostModuleType)
				if self.ghostModuleType == "LabelMod" or self.ghostModuleType == "LargeLabelMod" or self.ghostModuleType == "ButtonMod" then
					self.textInputScreen = TextInputScreen()
					gModularRunning = false
					self.textInputScreen:push("Enter label:", function(name)
						self.ghostSprite:remove()
						self.ghostSprite = nil
						self.modules:addNewLabelAt(self.ghostModuleType, name, xLocation, yLocation)
						self.mode = modeStandard
						gModularRunning = true
						self.textInputScreen = nil
					end)
				else
					self.ghostSprite:remove()
					self.ghostSprite = nil
					self.modules:addNewAt(self.ghostModuleType, xLocation, yLocation)
					self.mode = modeStandard
				end
			end
		end
	}
	playdate.inputHandlers.push(self.inputHandler)
	self.showing = true
	
	if patchPath ~= nil then
		self:loadPatch(patchPath, true)
	end
end

function ModularScreen:scaleChanged()
	if playdate.display.getScale()  == 1 then
		self.reticle:moveTo(200, 120)
		self.scale = 1
		globalXDrawOffset += 100
		globalYDrawOffset += 60
		self:move()
	else
		self.reticle:moveTo(100, 60)
		self.scale = 2
		globalXDrawOffset -= 100
		globalYDrawOffset -= 60
		self:move()
	end
end

function ModularScreen:checkReticleLocation()
	local xLocation = (-1 * globalXDrawOffset) + 200
	local yLocation = (-1 * globalYDrawOffset) + 120
	
	-- if self.modules:collides(xLocation, yLocation) then
	-- local module = self.modules:moduleAt(xLocation, yLocation)
	-- self:toast("" .. getModName(module:type()))
	--end
end

function ModularScreen:handleModClick(x, y)
	local module, moduleIndex = self.modules:moduleAt(x, y)
	if module.type == "ButtonMod" then
		local destination = module:getDestination()
		print("Destination: " .. destination)
	elseif module.handleModClick ~= nil then
		module:handleModClick(x, y, function(action) 
				if action == "nav" then
					print("modular screen - get nav from mod and navigate")
					if module.getNavTarget ~= nil then 
						local navTarget = module:getNavTarget()
						if navTarget ~= nil then
							self:loadPatch(navTarget, true)
						else
							print("Nav target is NIL")
						end
					end
				elseif action == "Remove" then
					--todo modal confirmation
					if module.evaporate ~= nil then
						module:evaporate(function(moduleId, cableId)  
							--remove a cable from attached module
							local module = self.modules:getById(moduleId)
							if module~= nil and module.unplug ~= nil then module:unplug(cableId) end
						end)
						self.modules:removeEvaporatedModule(moduleIndex)
					else
						self:toast("Module " .. module.type() .. " does not have evaporate()")
					end
					--todo cleanup cables
					self.modules:removeModule(moduleIndex)
				end
			end)
	else
		self:toast("No menu implemented for " .. module:type())
	end
end

function ModularScreen:toast(message, ms)
	if gSuppressToast then return end
	if ms == nil then
		ms = 2000
	end
	local toastSprite = gfx.sprite.spriteWithText(string.upper(message), 390, 10, playdate.graphics.kColorWhite)
	
	-- I don't know why but the above returns nil and crashes below if the save dialog is showing:
	if toastSprite == nil then return end
	
	toastSprite:moveTo(3 + (toastSprite.width/2), 240 - (toastSprite.height + 1))
	toastSprite:setIgnoresDrawOffset(true)
	toastSprite:add()
	playdate.timer.performAfterDelay(ms, function()  
		toastSprite:remove()
		toastSprite = nil
	end)
end

function ModularScreen:move()
	gfx.setDrawOffset(globalXDrawOffset, globalYDrawOffset)
	local xLocation = (-1 * globalXDrawOffset) + 200
	local yLocation = (-1 * globalYDrawOffset) + 120
	if self.scale == 2 then
		xLocation = (-1 * globalXDrawOffset) + 100
		yLocation = (-1 * globalYDrawOffset) + 60
	end
	self.modules:move(xLocation, yLocation)
	-- if self.scale == 1 then
	-- 	local xLocation = (-1 * globalXDrawOffset) + 200
	-- 	local yLocation = (-1 * globalYDrawOffset) + 120
	-- 	self.modules:move(xLocation, yLocation)
	-- elseif self.scale == 2 then
	-- 	local xLocation = (-1 * globalXDrawOffset) + 100
	-- 	local yLocation = (-1 * globalYDrawOffset) + 60
	-- 	self.modules:move(xLocation, yLocation)
	-- end
end

function ModularScreen:pop()
	playdate.inputHandlers.pop()
	self.showing = false
end

function ModularScreen:isShowing()
	return self.showing
end	

function ModularScreen:draw()
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		if gScrollLock == true then return end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalXDrawOffset += globalScrollStep
		else
			globalXDrawOffset += smallScrollStep
		end
		
		self:move()
	elseif playdate.buttonIsPressed(playdate.kButtonRight) then
		if gScrollLock == true then return end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalXDrawOffset -= globalScrollStep
		else
			globalXDrawOffset -= smallScrollStep
		end
		
		self:move()
	end
		
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		if gScrollLock == true then return end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalYDrawOffset += globalScrollStep
		else
			globalYDrawOffset += smallScrollStep
		end
		
		self:move()
	elseif playdate.buttonIsPressed(playdate.kButtonDown) then
		if gScrollLock == true then return end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalYDrawOffset -= globalScrollStep
		else
			globalYDrawOffset -= smallScrollStep
		end
		
		self:move()
	end
end

function ModularScreen:screenshot()
	self.reticle:remove()
	self.modules:screenshot(function(filename)
		self.reticle:add()
		self:toast("" .. filename .. " saved")
	end)
end
