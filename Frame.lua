  
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

Tank = Role:new("Paladin", 1, 0)
Heal = Role:new("Priest", 1, 0)
RDD = Role:new("Hunter", 1, 0)
MDD = Role:new("Rouge", 1, 0)

DataBase = {
	Tank = Tank,
	Heal = Heal,
	RDD = RDD,
	MDD = MDD
}

-- local variable to check if editbox is in edit mode
local edit;
-- just simple things for debugging
local debug = 1;

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

		if DataBase == nil then
			DataBase = {
				Tank = Tank,
				Heal = Heal,
				RDD = RDD,
				MDD = MDD
			}
		end

		self:UnregisterEvent("ADDON_LOADED");

	-- if player logs out do some stuff
	elseif event == "PLAYER_LOGOUT" then
		-- save roles to SavedVariablesPerCharacter

		point, relativeTo, relativePoint, xOfs, yOfs = MyAddon_Frame1:GetPoint()
		frameSettings["point"] = point;
		frameSettings["relativeTo"] = relativePoint;
		frameSettings["relativePoint"] = relativePoint;
		frameSettings["offsetX"] = xOfs;
		frameSettings["offsetY"] = yOfs;

		DataBase["Tank"] = Tank;
		DataBase["Heal"] = Heal;
		DataBase["RDD"] = RDD;
		DataBase["MDD"] = MDD;

		self:UnregisterEvent("PLAYER_LOGOUT");
	end
	
end



-- Checkbox Functions
function chkTank_OnClick()
	DataBase["Tank"]["active"] = chkTank:GetChecked();
end

function chkHeal_OnClick()
	DataBase["Heal"]["active"] = chkHeal:GetChecked();
end

function chkRDD_OnClick()
	DataBase["RDD"]["active"] = chkRDD:GetChecked();
end

function chkMDD_OnClick()
	DataBase["MDD"]["active"] = chkMDD:GetChecked();
end

function chkDD3_OnClick()
	DataBase["DD3"]["active"] = chkDD3:GetChecked();
end
local total = 0;

-- this method is called every frame (60fps = 60/second) and redraws the window
function frmL4_OnUpdate()
	chkTank:SetChecked(DataBase["Tank"]["active"]);
	chkHeal:SetChecked(DataBase["Heal"]["active"]);
	chkRDD:SetChecked(DataBase["RDD"]["active"]);
	chkMDD:SetChecked(DataBase["MDD"]["active"]);
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
	if chkRDD:GetChecked() == 1 and chkMDD:GetChecked() == nil and chkDD3:GetChecked() == nil then
		searchString = searchString.." DD";
	elseif chkMDD:GetChecked() == 1 and chkRDD:GetChecked() == nil and chkDD3:GetChecked() == nil then
		searchString = searchString.." DD";
	elseif chkDD3:GetChecked() == 1 and chkMDD:GetChecked() == nil and chkRDD:GetChecked() == nil then
		searchString = searchString.." DD";
	-- two --
	elseif (chkRDD:GetChecked() == 1 and chkMDD:GetChecked() == 1 and chkDD3:GetChecked() == nil) or
			(chkMDD:GetChecked() == 1 and chkDD3:GetChecked() == 1 and chkRDD:GetChecked() == nil) or
			(chkRDD:GetChecked() == 1 and chkDD3:GetChecked() == 1 and chkMDD:GetChecked() == nil) then
		searchString = searchString.." 2DDs";
		-- three --
	elseif (chkRDD:GetChecked() == 1 and chkMDD:GetChecked() and chkDD3:GetChecked() == 1) then
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

function btnTank_OnClick()
	
end
	
	function CheckButton1_OnClick()
		
	end
	
	function Frame1_OnLoad()
		
	end
	
	function EditBox3_OnTextChanged()
		
	end
	