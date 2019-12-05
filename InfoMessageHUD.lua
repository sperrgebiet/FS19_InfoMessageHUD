-- InfoMessageHUD specialization for FS19
--
-- This mod displays the 'info messages' which are usually just visible in the Help (F1) menu, without the need for opening this menu.
-- Messages are for example "You first need to fill the tool" or messages from other mods.
--
-- Author: sperrgebiet

InfoMessageHUD = {}
InfoMessageHUD.eventName = {}
InfoMessageHUD.ModName = g_currentModName
InfoMessageHUD.ModDirectory = g_currentModDirectory
InfoMessageHUD.Version = "1.0.0.0"

InfoMessageHUD.debug = fileExists(InfoMessageHUD.ModDirectory ..'debug')

InfoMessageHUD.Colors = {}
InfoMessageHUD.Colors[1]  = {'col_white', {1, 1, 1, 1}}				
InfoMessageHUD.Colors[2]  = {'col_black', {0, 0, 0, 1}}				
InfoMessageHUD.Colors[3]  = {'col_grey', {0.7411, 0.7450, 0.7411, 1}}	
InfoMessageHUD.Colors[4]  = {'col_blue', {0.0044, 0.15, 0.6376, 1}}	
InfoMessageHUD.Colors[5]  = {'col_red', {0.8796, 0.0061, 0.004, 1}}	
InfoMessageHUD.Colors[6]  = {'col_green', {0.0263, 0.3613, 0.0212, 1}}
InfoMessageHUD.Colors[7]  = {'col_yellow', {0.9301, 0.7605, 0.0232, 1}}
InfoMessageHUD.Colors[8]  = {'col_pink', {0.89, 0.03, 0.57, 1}}		
InfoMessageHUD.Colors[9]  = {'col_turquoise', {0.07, 0.57, 0.35, 1}}	
InfoMessageHUD.Colors[10] = {'col_brown', {0.1912, 0.1119, 0.0529, 1}}


print(string.format('InfoMessageHUD v%s - DebugMode %s)', InfoMessageHUD.Version, tostring(InfoMessageHUD.debug)))

function InfoMessageHUD:dp(val, fun, msg) -- debug mode, write to log
	if not InfoMessageHUD.debug then
		return;
	end

	if msg == nil then
		msg = ' ';
	else
		msg = string.format(' msg = [%s] ', tostring(msg));
	end

	local pre = 'InfoMessageHUD DEBUG:';

	if type(val) == 'table' then
		--if #val > 0 then
			print(string.format('%s BEGIN Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
			DebugUtil.printTableRecursively(val, '.', 0, 3);
			print(string.format('%s END Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
		--else
		--	print(string.format('%s Table is empty: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
		--end
	else
		print(string.format('%s [%s]%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
	end
end

function InfoMessageHUD:draw()
	-- Just render and burn CPU with all the other crap when the actual HUD is visible and we're on a client
	if g_client ~= nil and g_currentMission.hud.isVisible and not g_currentMission.inGameMenu.hud.inputHelp.overlay.visible then
		-- We've to declare and set the variables for the position already here, in case we've an actionEvent, but no extraHelpText
		
		local posX, posY = g_currentMission.hud.vehicleSchema:getPosition()
		local size = g_currentMission.inGameMenu.hud.inputHelp.helpTextSize
		
		if g_currentMission.controlledVehicle == nil then 
			posY = g_currentMission.inGameMenu.hud.inputHelp.origY
		else
			posY = posY - size - g_currentMission.inGameMenu.hud.inputHelp.helpTextOffsetY
		end
	
		if #g_currentMission.hud.inputHelp.extraHelpTexts > 0 then
			for _, text in ipairs(g_currentMission.inGameMenu.hud.inputHelp.extraHelpTexts) do
				InfoMessageHUD:renderText(posX, posY, size, text, false, 1)
				posY = posY - size
			end
		   
			--clearTable(g_currentMission.hud.inputHelp.extraHelpTexts)
			while #g_currentMission.hud.inputHelp.extraHelpTexts ~= 0 do rawset(g_currentMission.hud.inputHelp.extraHelpTexts, #g_currentMission.hud.inputHelp.extraHelpTexts, nil) end
		end
		
		--Check if we've an context action which is helpful
		local actionMsg = InfoMessageHUD:getContextAction()
		if actionMsg ~= nil then
			setTextColor(0.9301, 0.7605, 0.0232, 1) --Set text color for actions to yellow
			InfoMessageHUD:renderText(posX, posY, size, actionMsg, true, 7) -- colorId 7 is yellow
			setTextColor(1, 1, 1, 1)
		end		
	end
end

function InfoMessageHUD:getContextAction()
	--It's also helpful on foot, so always check if we've an activate object action
	--if g_currentMission.controlledVehicle ~= nil then
		for _, actionEvent in ipairs(g_inputBinding.displayActionEvents) do
			if actionEvent.action.name == "ACTIVATE_OBJECT" then
				return actionEvent.event.contextDisplayText
			end
		end
	--end
end

function InfoMessageHUD:renderText(x, y, size, text, bold, colorId)
	setTextColor(unpack(self.Colors[colorId][2]))
	setTextBold(bold)
	setTextAlignment(RenderText.ALIGN_LEFT)
	renderText(x, y, size, text)
	
	-- Back to defaults
	setTextBold(false)
	setTextColor(unpack(self.Colors[1][2])) --Back to default color which is white
	setTextAlignment(RenderText.ALIGN_LEFT)
end

addModEventListener(InfoMessageHUD)