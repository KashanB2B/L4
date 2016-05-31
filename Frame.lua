  
-- Author      : KashanB2B
-- Create Date : 3/12/2016 7:02:43 PM

-- Roles for search
roles = {
	lfTank = false,
	lfHeal = false,
	lfDD1 = false,
	lfDD2 = false,
	lfDD3 = false
}

-- default minimap position
minimapSettings = {
	MinimapPos = -65;
}

-- settings to hide frame and dungeon string
frameSettings = {
	visible = true,
	dungeon = "",
	point,
	relativePoint,
	relativeTo,
	offsetX,
	offsetY
}

-- local variable to check if editbox is in edit mode
local edit;
-- just simple things for debugging
local debug = 0;

-- eventhandling of the main window
function frmL4_OnEvent(event)

	-- if addon is loaded so stuff
	if event == "ADDON_LOADED" then
		inputDungeon:SetAutoFocus(false);
		inputDungeon:SetMultiLine(false);
		inputDungeon:SetText(tostring(frameSettings.dungeon));

		-- if minimapsettings is not yet in SavedVariablesPerCharacter initialize it
		if minimapSettings == nil then
			minimapSettings.MinimapPos = -60;
		end

		-- if roles is not yet in SavedVariablesPerCharacter initialize it
		if 	roles == nil then
			roles.lfTank = false;
			roles.lfHeal = false;
			roles.lfDD1 = false;
			roles.lfDD2 = false;
			roles.lfDD3 = false;
		end

		-- if framesettings is not yet in SavedVariablesPerCharacter initialize it
		if frameSettings == nil then
			frameSettings.visible = true;
			frameSettings.dungeon = "Enter Dungeon";
			point, relativeTo, relativePoint, xOfs, yOfs = MyAddon_Frame1:GetPoint();
			frameSettings.point = point;
			frameSettings.relativePoint = relativePoint;
			frameSettings.relativeTo = relativeTo;
			frameSettings.offsetX = xOfs;
			frameSettings.offsetY = yOfs;

		end
		self:UnregisterEvent("ADDON_LOADED");

	-- if player logs out do some stuff
	elseif event == "PLAYER_LOGOUT" then
		-- save roles to SavedVariablesPerCharacter
		roles["lfTank"] = chkTank:GetChecked();
		roles["lfHeal"] = chkHeal:GetChecked();
		roles["lfDD1"] = chkDD1:GetChecked();
		roles["lfDD2"] = chkDD2:GetChecked();
		roles["lfDD3"] = chkDD3:GetChecked();

		point, relativeTo, relativePoint, xOfs, yOfs = MyAddon_Frame1:GetPoint()
		frameSettings["point"] = point;
		frameSettings["relativeTo"] = relativePoint;
		frameSettings["relativePoint"] = relativePoint;
		frameSettings["offsetX"] = xOfs;
		frameSettings["offsetY"] = yOfs;
		self:UnregisterEvent("PLAYER_LOGOUT");
	end
	
end

-- Checkbox Functions
function chkTank_OnClick()
	roles["lfTank"] = chkTank:GetChecked();
end

function chkHeal_OnClick()
	roles["lfHeal"] = chkHeal:GetChecked();
end

function chkDD1_OnClick()
	roles["lfDD1"] = chkDD1:GetChecked();
end

function chkDD2_OnClick()
	roles["lfDD2"] = chkDD2:GetChecked();
end

function chkDD3_OnClick()
	roles["lfDD3"] = chkDD3:GetChecked();
end
local total = 0;

-- this method is called every frame (60fps = 60/second) and redraws the window
function frmL4_OnUpdate()
	chkTank:SetChecked(roles.lfTank);
	chkHeal:SetChecked(roles.lfHeal);
	chkDD1:SetChecked(roles.lfDD1);
	chkDD2:SetChecked(roles.lfDD2);
	chkDD3:SetChecked(roles.lfDD3);
	MinimapButton_Reposition();
	-- while the addon is being drawn, set the text of the input field
    if total <= 1 then
        inputDungeon:SetText(tostring(frameSettings.dungeon));
		total = total + arg1;
    end
	-- while the addon is being drawn, check if hidden flag is set and hide it
	if frameSettings.visible == false then
		frmL4:Hide();
	end
	if debug == 0 then
		btnDebug:Hide();
	end
	
end

-- search button click function
function btnSearch_OnClick()
	local inni = inputDungeon:GetText();
	local playerName = UnitName("player");
	local searchString = "LF";
	if chkTank:GetChecked() == 1 then
		searchString = searchString.." Tank";
	end
	if chkHeal:GetChecked() == 1 then
		searchString = searchString.." Heal";
	end
	-- only one --
	if chkDD1:GetChecked() == 1 and chkDD2:GetChecked() == nil and chkDD3:GetChecked() == nil then
		searchString = searchString.." DD";
	elseif chkDD2:GetChecked() == 1 and chkDD1:GetChecked() == nil and chkDD3:GetChecked() == nil then
		searchString = searchString.." DD";
	elseif chkDD3:GetChecked() == 1 and chkDD2:GetChecked() == nil and chkDD1:GetChecked() == nil then
		searchString = searchString.." DD";
	-- two --
	elseif (chkDD1:GetChecked() == 1 and chkDD2:GetChecked() == 1 and chkDD3:GetChecked() == nil) or
			(chkDD2:GetChecked() == 1 and chkDD3:GetChecked() == 1 and chkDD1:GetChecked() == nil) or
			(chkDD1:GetChecked() == 1 and chkDD3:GetChecked() == 1 and chkDD2:GetChecked() == nil) then
		searchString = searchString.." 2DDs";
		-- three --
	elseif (chkDD1:GetChecked() == 1 and chkDD2:GetChecked() and chkDD3:GetChecked() == 1) then
		searchString = searchString.." 3DDS";
	end
	searchString = searchString.." für "..inni.." /w me";

	local index = GetChannelName("SucheNachGruppe");
	if (index~=nil) then 
		if debug == 0 then
			SendChatMessage(searchString, "CHANNEL", nil, index);
		elseif debug ==1 then
			SendChatMessage(searchString, "WHISPER", nil, playerName);
		end
			
	end

	inputDungeon:ClearFocus();
	-- save dungeon when searched
	frameSettings["dungeon"] = inputDungeon:GetText();
end
-- input field events
function inputDungeon_OnEnterPressed()
	inputDungeon:ClearFocus();
	edit = false;
end

function inputDungeon_OnEscapePressed()
	inputDungeon:ClearFocus();	
	edit = false;
end

-- minimap functions
function MinimapButton_Reposition()
	MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(minimapSettings.MinimapPos)),(80*sin(minimapSettings.MinimapPos))-52);
end

-- calculate minimap position after drag
function MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition();
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();

	xpos = xmin-xpos/UIParent:GetScale()+70;
	ypos = ypos/UIParent:GetScale()-ymin-70;

	minimapSettings.MinimapPos = math.deg(math.atan2(ypos,xpos));
	MinimapButton_Reposition();
end

-- click on minimap icon wiht left mouse button toggles visibility of the addon
function MinimapButton_OnClick()
	if arg1 == "LeftButton" then
		if frmL4:IsVisible() then
			frmL4:Hide();
			frameSettings["visible"] = false;
		else 
			frmL4:Show();
			frameSettings["visible"] = true;
		end
	end
end

-- hide addon when click on the X button
function BtnClose_OnClick()
	frmL4:Hide();
	frameSettings["visible"] = false;
end

-- toggle info window on click
function btnInfo_OnClick()
	if arg1 == "LeftButton" then
		if frmInfo:IsVisible() then
			frmInfo:Hide();
		else 
			frmInfo:Show();
		end
	end
end

-- allow editing of input filed when a key is pressed
function inputDungeon_OnKeyDown()
	edit = true;
end
	
-- allow editing of input filed when a mouse button is pressed
function inputDungeon_OnMouseDown()
	edit = true;
end

-- hide info window when click on X button
function btnInfoClose_OnClick()
		frmInfo:Hide();
end
	
function btnDebug_OnClick()

end

	