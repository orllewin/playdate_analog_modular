import 'Modules/mod_utils'
import 'CoracleViews/text_list'

class('ModulePopup').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local width = 150
local height = 122

function ModulePopup:init()
	ModulePopup.super.init(self)
	
	local backgroundImage = generateModBackgroundWithShadow(width, height)
	local bgW, bgH = backgroundImage:getSize()	
	self:setIgnoresDrawOffset(true)
	self:setZIndex(gModuleMenuZ)
	self:setImage(backgroundImage)
	self:moveTo(295, 175)
end

function ModulePopup:show(onSelect, selectedIndex, scale)
	self:add()
	
	if scale ~= nil then
		if scale == 1 then
			self:moveTo(295, 175)
		elseif scale == 2 then
			self:moveTo(100, 60)
		end
	end
	
	self.mods = getMenuModList()
	
	self.moduleList = TextList(self.mods, self.x - width/2 + 8, self.y - height/2 + 8, width - 16, height-2, 18, nil, function(index, item)
		if item.category ~= nil then
			print("Selected " .. item.category)
			self:updateCategory(item)
		else
			print("Mod Selected: " .. item.label .. " type: " .. item.type)
			onSelect(item)
			self:dismiss()
		end

	end, gModuleMenuZ + 1)
	
	self:setSelected(selectedIndex)
	
	self.modulePopupInputHandler = {
		
		BButtonDown = function()
			self:dismiss()
		end,
		
		AButtonDown = function()
			self.moduleList:tapA()
		end,
		
		leftButtonDown = function()
	
		end,
		
		rightButtonDown = function()
	
		end,
		
		upButtonDown = function()
			self.moduleList:goUp()
		end,
		
		downButtonDown = function()
			self.moduleList:goDown()
		end
	}
	playdate.inputHandlers.push(self.modulePopupInputHandler )
end

function ModulePopup:updateCategory(category)
	self.moduleList:updateItems(category.mods)
end

function ModulePopup:setSelected(index)
	self.moduleList:setSelected(index)
end

function ModulePopup:dismiss()
	print("ModulePopup:dismiss()")
	playdate.inputHandlers.pop()
	self.moduleList:removeAll()
	self:remove()
end