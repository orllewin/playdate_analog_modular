-- Playdate API
import 'CoreLibs/object'
import 'CoreLibs/frameTimer'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoreLibs/animator'

import 'Coracle/vector'

import 'global'
-- Core
import 'Core/event'
import 'Core/socket'

-- Components
--import 'Components/delay_component'
import 'Interface/modular_screen'
import 'Interface/text_input_screen'

local gfx <const> = playdate.graphics

local font = playdate.graphics.font.new("Fonts/parodius_ext")
playdate.graphics.setFont(font)

local textInputScreen = nil
local modularScreen = ModularScreen()


local inverted = false
local menu = playdate.getSystemMenu()

playdate.setCrankSoundsDisabled(true)

gBigFont = playdate.graphics.font.new("Fonts/pixarlmed")

function initialiseImages()
	local socket_width = 20
	local socket_height = 32
	-- Socket On --------------------------------------------
	local socketInImage = gfx.image.new(socket_width, socket_height)
	gfx.pushContext(socketInImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/4)	
	
	local arrow = playdate.graphics.image.new("Images/arrow_in")
	arrow:drawCentered(socket_width/2, 5)
		
	gfx.popContext()
	
	gSocketInImage = socketInImage
	
	-- Socket Out -------------------------------------------
	local socketOutImage = gfx.image.new(socket_width, socket_height)
	gfx.pushContext(socketOutImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/4)	
	
	local arrow = playdate.graphics.image.new("Images/arrow_out")
	arrow:drawCentered(socket_width/2, 5)
	
	gfx.popContext()
	
	gSocketOutImage = socketOutImage
	
	-- Socket -------------------------------------------
	local socketImage = gfx.image.new(socket_width, socket_height)
	gfx.pushContext(socketImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/4)		
	gfx.popContext()
	
	gSocketImage = socketImage
	
	-- Small socket --------------------------------------
	local smallSocketImage = playdate.graphics.image.new(16, 16)
	gfx.pushContext(smallSocketImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(8, 8, 8)
	playdate.graphics.setColor(gfx.kColorBlack)
	gfx.drawCircleAtPoint(8, 8, 8)	
	playdate.graphics.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(8, 8, 4)	
	
	gfx.popContext()
	
	gSmallSocketImage = smallSocketImage
	
	--Side sockets
	gSideSocketLeft = gfx.image.new("Images/side_socket_left")
	gSideSocketRight = gfx.image.new("Images/side_socket_right")
	gSideSocketBottom = gfx.image.new("Images/side_socket_bottom")
	gMixImage = gfx.image.new("Images/mix")
	
end

initialiseImages()

function load()
	print("OPENING")
	--todo - show chooser
	local patchFiles = {}
	local files = playdate.file.listFiles()
	for f=1, #files do
		local file = files[f]	
		print("Load: inspecting file: " .. file)
		if endswith(file, ".orlam") and not startswith(file, "_") then
			local patchFile = {
				label="".. replace(file, ".orlam", ""),
				file=file
			}
			table.insert(patchFiles, patchFile)
			print("Found patch: " .. file)
		end
	end
	
	for f=1,#patchFiles do
		print("file " .. f ..": " .. patchFiles[f].label)
	end
	
	local dividerMenuItem = {
		label="--------------",
		file=nil
	}
	table.insert(patchFiles, dividerMenuItem)
	
	--Now add built-in patches:
	local intro1Patch = {
		--todo - maybe get json and use the proper name the user entered instead of mangling the filename:
		label="Introduction 1",
		file="_Introduction_1.orlam"
	}
	table.insert(patchFiles, intro1Patch)
	
	local intro2Patch = {
		label="Introduction 2",
		file="_Introduction_2.orlam"
	}
	table.insert(patchFiles, intro2Patch)
	
	local intro3Patch = {
		label="Introduction 3",
		file="_Introduction_3.orlam"
	}
	table.insert(patchFiles, intro3Patch)
	
	local intro4Patch = {
		label="Introduction 4",
		file="_Introduction_4.orlam"
	}
	table.insert(patchFiles, intro4Patch)
	
	local intro5Patch = {
		label="Introduction 5",
		file="_Introduction_5.orlam"
	}
	table.insert(patchFiles, intro5Patch)
	
	local bedtimePatch = {
		label="Bedtime noise",
		file="_Bedtime.orlam"
	}
	table.insert(patchFiles, bedtimePatch)
	
	local loadPatchMenu = ModuleMenu(patchFiles, 320, 60, 150, 122)
	loadPatchMenu:show(function(selected, index) 
		if modularScreen:isShowing() then	modularScreen:loadPatch(patchFiles[index].file) end
	end, 1)	
end

function save()
	textInputScreen = TextInputScreen()
	gModularRunning = false
	textInputScreen:push("Enter patch name:", function(name)
		if modularScreen:isShowing() then	modularScreen:savePatch(name) end
		gModularRunning = true
		textInputScreen = nil
	end)
end

local patchMenuItem, error = menu:addMenuItem("Patch", function() 
	--todo - new popup with options: load, save, delete (if opened from load)	
	
	local y = 50
	local h = 87
	local options = {
		{ label="New"},
		{ label="Load"},
		{ label="Save"},
		{ label="Screenshot"},
	}
	
	if gPatchPath ~= nil then
		y = 67
		h = 123
		options = {
			{ label="New"},
			{ label="Load"},
			{ label="Save"},
			{ label="Save as"},
			{ label="Delete"},
			{ label="Screenshot"},
		}
	end
	
	local patchMenu = ModuleMenu(options, 333, y, 120, h)
	patchMenu:show(function(selected, index) 
		patchMenu = nil
		if selected == "New" then
			modularScreen:new()
		elseif selected == "Load" then
			load()
		elseif selected == "Save" then
			if gPatchPath ~= nil then
				--overwrite
				modularScreen:saveCurrentPatch()
			else
				--show dialog
				save()
			end
		elseif selected == "Save as" then
			--show dialog
			save()
		elseif selected == "Delete" then
			modularScreen:deletePatch(gPatchPath)
		elseif selected == "Screenshot" then
			modularScreen:screenshot()
		end
	end, 1)	
end)

local invertMenuItem, error = menu:addMenuItem("Invert screen", function()
		inverted = not inverted
		playdate.display.setInverted(inverted)
end)

if playdate.datastore.read("prefs") == nil then
	--first run, show tutorial
	modularScreen:push(gStartPatch)
else
	modularScreen:push(gStartPatch)
end

import 'intro'
local intro = Intro()
local showIntro = true
local introTime = true

playdate.timer.performAfterDelay(3500, function() 
	introTime = false
end)

function playdate.update()	
	playdate.timer.updateTimers()
	playdate.frameTimer.updateTimers()
	playdate.graphics.sprite.update()
	
	if gModularRunning == false then return end
	if textInputScreen == nil then
		if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:draw() end
	else
		if textInputScreen:isShowing() == false then
			if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:draw() end
		end
	end
	
	if showIntro and introTime then 
		intro:update()
	end
end