game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=59785529")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61423967")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61427382")

local configIconImage = "http://www.roblox.com/asset/?id=59785529"
local configIconOverImage = "http://www.roblox.com/asset/?id=61423967"
local configIconHoverImage = "http://www.roblox.com/asset/?id=61427382"

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local selbStorage = nil
local selgui = nil
local screen = nil
local guiMain = nil

local width = UDim.new(3, 0)
local height = 20 
local transparency = 0.5
local buttonColor = BrickColor.new("Mid gray")
local frameColor = BrickColor.new("Pastel yellow")
local textSize = 5

local RbxGui = require(game:GetService("ReplicatedStorage"):
    WaitForChild("LoadLibrary"):WaitForChild("RbxGui"))

local configParts = {}
local valueConnections = {}
local origValueMap = {}
local objectValueSelect = {}

local enabled = false

local c = workspace:GetDescendants()
for i = 1, #c do
	if c[i]:IsA("Configuration") or c[i]:IsA("VehicleSeat") then
		if c[i].Parent:IsA("Part") then
			if c[i].Parent.Parent.ClassName == "Model" then
				table.insert(configParts, #configParts+1, c[i].Parent.Parent)
				c[i].AncestryChanged:Connect(function()
					if table.find(configParts, c[i].Parent.Parent) then
						table.remove(configParts, table.find(configParts, c[i].Parent.Parent))
					end
				end)
			elseif c[i].Parent.Parent == workspace then
				table.insert(configParts,#configParts+1,c[i].Parent)
				c[i].AncestryChanged:Connect(function()
					if table.find(configParts, c[i].Parent) then
						table.remove(configParts, table.find(configParts, c[i].Parent))
					end
				end)
			end
		elseif c[i].Parent.ClassName == "Model" then
			table.insert(configParts,#configParts+1,c[i].Parent)
			c[i].AncestryChanged:Connect(function()
				if table.find(configParts, c[i].Parent) then
					table.remove(configParts, table.find(configParts, c[i].Parent))
				end
			end)
		end
	end
end

workspace.ChildAdded:Connect(function(child)
	wait()
	if child:FindFirstChildWhichIsA("Configuration", true) or child:FindFirstChildWhichIsA("VehicleSeat") or child:IsA("VehicleSeat") then
		table.insert(configParts,#configParts+1,child)
		child.AncestryChanged:Connect(function()
			if table.find(configParts, child) then
				table.remove(configParts, table.find(configParts, child))
			end
		end)
	end
end)

script.Parent.Equipped:Connect(function()
	enabled = true
	selbStorage = Instance.new("Folder", plr.PlayerGui)
	selbStorage.Name = "ConfigSelectionBoxStorage"
	for i = 1, #configParts do
		local selb = Instance.new("SelectionBox",selbStorage)
		selb.Color = BrickColor.new("Really blue")
		selb.Adornee = configParts[i]
		local billbgui = Instance.new("BillboardGui",selb)
		billbgui.Adornee = configParts[i]
		billbgui.AlwaysOnTop = true
		billbgui.Size = UDim2.new(1.5,0,1.5,0)
		billbgui.ExtentsOffset = Vector3.new(0,0,0)
		local image = Instance.new("ImageButton",billbgui)
		image.Image = configIconImage
		image.Size = UDim2.new(1,0,1,0)
		image.BackgroundTransparency = 1
		local connectVal = Instance.new("ObjectValue",configParts[i])
		connectVal.Name = "ConfigSelBoxConnection"
		connectVal.Value = selb
		local backConnect = Instance.new("ObjectValue",selb)
		backConnect.Name = "ConfigSelBoxBackwardsConnection"
		backConnect.Value = connectVal
	end
end)

script.Parent.Unequipped:Connect(function()
	enabled = false
	local stored = selbStorage:GetChildren()
	for i = 1, #stored do
		if stored[i]:FindFirstChild("ConfigSelBoxBackwardsConnection") then
			stored[i].ConfigSelBoxBackwardsConnection.Value:Remove()
		end
	end
	if selbStorage then selbStorage:Remove() selbStorage = nil end
end)

function onMouseEnterPalette(mouse)
	colorPaletteSelectMode = true
end
function onMouseLeavePalette(paletteFrame)
	colorPaletteSelectMode = false
	paletteFrame.Visible = false
end
function onShowColorDialog(paletteFrame)
	paletteFrame.Visible = not(paletteFrame.Visible)
	colorPaletteSelectMode = true
end
function constrained(valueObject)
	return (valueObject:IsA("IntConstrainedValue") or valueObject:IsA("DoubleConstrainedValue"))
end
function onMouseLeave(hoverSelection, selectedButtonTable, oldButton)
	if oldButton[0] then
		local notSelected = true;
		local selectionText = "";
		for key, value in pairs(selectedButtonTable) do
			if oldButton[0] == value then
				notSelected = false
			else
				selectionText = value.BackgroundColor.Name;
			end
		end
		if notSelected then
			hoverSelection.Text = selectionText;
			oldButton[0].Parent.BackgroundColor = BrickColor.Black();
		end
	end
	oldButton[0] = nil
end

function onMouseEnter(hoverSelection, guiButton, selectedButtonTable, oldButton)
	onMouseLeave(hoverSelection, selectedButtonTable, oldButton)
	hoverSelection.Text = guiButton.BackgroundColor.Name
	--if guiButton ~= selectedButton then
		guiButton.Parent.BackgroundColor = BrickColor.White();
		oldButton[0] = guiButton
	--end
end
function changeColorSelection(colorHolder, paletteFrame, guiButton, selectedButtonTable)
	if selectedButtonTable[colorHolder] ~= nil then
		selectedButtonTable[colorHolder].Parent.BackgroundColor = BrickColor.Black();
	end

	guiButton.Parent.BackgroundColor = BrickColor.Yellow();
	colorHolder.BackgroundColor = guiButton.BackgroundColor
	selectedButtonTable[colorHolder] = guiButton
end
function onMouseUp(colorHolder, paletteFrame, guiButton, selectedButtonTable)
	changeColorSelection(colorHolder, paletteFrame, guiButton, selectedButtonTable)

	onMouseLeavePalette(paletteFrame)
end
function onObjectValueMouseClick(guiFrame, value, objectButton)
	objectValueSelect["Value"] = value
	objectValueSelect["Frame"] = guiFrame
	objectValueSelect["Enabled"] = true

	onObjectValueMouseLeave(value, objectButton)
end

function onObjectValueMouseEnter(value, objectButton)
	objectValueSelect["HoverValue"] = value
	if value.Value then
		objectButton.BackgroundColor = BrickColor.Blue()
	else
		objectButton.BackgroundColor = BrickColor.White()
	end
end
	
function onObjectValueMouseLeave(value, objectButton)
	if objectValueSelect["HoverValue"] == value then
		objectValueSelect["HoverValue"] = nil
	end
	objectButton.BackgroundColor = buttonColor
end
function setObjectButtonText(guiFrame, objectButton, objectValue)
	if objectValueSelect["Enabled"] and objectValue == objectValueSelect["Value"] then
		guiFrame.Visible = true
		objectValueSelect["Enabled"] = false
		objectValueSelect["Value"] = nil
	end

	if  objectValue.Value ~= nil then
		objectButton.Text = objectValue.Value.Name
	else
		objectButton.Text = "[nil]"
	end
	objectButton.BackgroundColor = buttonColor
end


--create various gui elements

function createTextBox(size, text)
	local textBox = Instance.new("TextBox")
	textBox.Position = UDim2.new(0.5, 1, 0.0, 1)
	textBox.Size = size
	textBox.BackgroundTransparency = 1
	textBox.FontSize = textSize - 3
	textBox.TextColor3 = Color3.new(1,1,1)
	textBox.Text = text	
	textBox.ZIndex = 2

	local textBoxBacking = Instance.new("TextButton")
	textBoxBacking.Text = ""
	textBoxBacking.Style = Enum.ButtonStyle.RobloxButtonDefault
	textBoxBacking.Size = UDim2.new(1,0,1,0)
	textBoxBacking.Parent = textBox

	return textBox
end

function createCheckBox(value)
	local checkBox = Instance.new("TextButton")
	checkBox.Position = UDim2.new(0.75, -(height-4)/2, 0.0, 2)
	checkBox.Size = UDim2.new(0.0, height-4, 0.0, height-4)
	checkBox.Style = Enum.ButtonStyle.RobloxButtonDefault
	checkBox.TextColor3 = Color3.new(1,1,1)
	checkBox.FontSize = textSize
	setCheckBoxValue(checkBox, value)
	return checkBox
end

function setCheckBoxValue(checkBox, value)
	if value then
		checkBox.Text = "X"
	else
		checkBox.Text = ""
	end
end

--no mroe create gui element
--process functions

function sharedProcess(name, parentFrame)
	local subFrame = Instance.new("Frame")
	subFrame.Name = name
	subFrame.Size = UDim2.new(1.0, 0, 0, height)
	subFrame.BackgroundTransparency = 1.0
	subFrame.BorderSizePixel = 0
	
	local label = Instance.new("TextLabel")
	label.Font = Enum.Font.ArialBold
	label.Position = UDim2.new(0.0, 0, 0.0, 0)
	label.Size = UDim2.new(0.5, 0, 1.0, 0)
	label.FontSize = textSize
	label.TextColor = BrickColor.White()
	label.Text = name
	label.Parent = subFrame
	label.BackgroundTransparency = 1.0
	label.BorderSizePixel = 0

	return subFrame
end

function processBoolValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local checkBox = createCheckBox(value.Value)
	
	--Tie the two values together... we'll need to break these connections later
	checkBox.MouseButton1Down:connect(function() value.Value = not(value.Value) end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) setCheckBoxValue(checkBox, newValue) end)	
	checkBox.Parent = subFrame
	return subFrame
end


function processBrickColorValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)

	local sideBar = Instance.new("Frame")
	sideBar.Position = UDim2.new(0.5, 0, 0.0, 0)
	sideBar.Size = UDim2.new(0.5, 0, 1.0, 0)
	sideBar.BackgroundTransparency = 1.0
	sideBar.Parent = subFrame
	sideBar.BorderSizePixel = 0

	local primaryColor = Instance.new("TextButton")
	primaryColor.Position = UDim2.new(0.0, 1, 0.0, 1)
	primaryColor.Size = UDim2.new(0.0, height-2, 0, height-2)
	primaryColor.Text  = ""	
	primaryColor.FontSize = textSize
	primaryColor.BackgroundColor = value.Value
	primaryColor.BorderColor = BrickColor.Black()
	primaryColor.Parent = sideBar

	local hoverSelection = Instance.new("TextLabel")
	hoverSelection.Position = UDim2.new(0.0, height+2, 0.0, 0)
	hoverSelection.Size = UDim2.new(1.0, -height - 4, 1.0, 0)
	hoverSelection.Text = ""
	hoverSelection.Font = Enum.Font.ArialBold
	hoverSelection.FontSize = textSize
	hoverSelection.BackgroundTransparency = 1.0
	hoverSelection.BorderSizePixel = 0
	hoverSelection.TextColor = BrickColor.White()
	hoverSelection.Text = primaryColor.BackgroundColor.Name;
	hoverSelection.Parent = sideBar

	local paletteFrame = Instance.new("Frame")
	paletteFrame.Position = UDim2.new(primaryColor.Position.X.Scale, primaryColor.Position.X.Offset + height, primaryColor.Position.Y.Scale, primaryColor.Position.Y.Offset - height*7)
	paletteFrame.Size = UDim2.new(0, height*8, 0, height*8)
	paletteFrame.BackgroundColor = BrickColor.White()
	paletteFrame.BorderColor = BrickColor.White()
	paletteFrame.Visible = false;
	paletteFrame.Parent = sideBar
	paletteFrame.ZIndex = 2
	paletteFrame.MouseEnter:connect(function() onMouseEnterPalette(mouse) end)
	paletteFrame.MouseLeave:connect(function() onMouseLeavePalette(paletteFrame, mouse) end)

	primaryColor.MouseButton1Down:connect(function() onShowColorDialog(paletteFrame) end)

	local selectedButtonTable = {}
	local colorButtonTable = {}
	local oldButton = {}
	for xOffset = 0, 7 do
		for yOffset = 0,7 do
			local guiFrame = Instance.new("Frame")
			guiFrame.Position = UDim2.new(1.0/8 * xOffset, 0, 1.0/8*yOffset, 0)
			guiFrame.Size = UDim2.new(1.0/8, 0, 1.0/8, 0)
			guiFrame.BackgroundColor = BrickColor.White();
			guiFrame.BorderSizePixel = 0
			guiFrame.Parent = paletteFrame;
			guiFrame.ZIndex = 2
		
			local guiButton = Instance.new("TextButton")
			guiButton.FontSize = textSize
			guiButton.Position = UDim2.new(0.0, 1, 0.0, 1)
			guiButton.Size = UDim2.new(1.0, -2, 1.0, -2)
			guiButton.Text = ""
			guiButton.BorderSizePixel = 0
			guiButton.AutoButtonColor = false
			local color = BrickColor.palette(xOffset + yOffset*8)
			colorButtonTable[color.Number] = guiButton
			guiButton.BackgroundColor = color
			guiButton.MouseEnter:connect(function() onMouseEnter(hoverSelection, guiButton, selectedButtonTable, oldButton) end)
			guiButton.MouseButton1Up:connect(function() onMouseUp(primaryColor, paletteFrame, guiButton, selectedButtonTable, oldButton) end)
			guiButton.MouseButton1Up:connect(function() value.Value = guiButton.BackgroundColor end)
			guiButton.Parent = guiFrame
			guiButton.ZIndex = 2

			if guiButton.BackgroundColor == primaryColor.BackgroundColor then
				guiFrame.BackgroundColor = BrickColor.White()
				selectedButtonTable[primaryColor] = guiButton
			end
		end
	end

	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) changeColorSelection(primaryColor, paletteFrame, colorButtonTable[newValue.Number], selectedButtonTable) end)	
	return subFrame
end


function processConstrainedNumberValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), value.ConstrainedValue, function(textBox) value.ConstrainedValue = textBox.Text end)
	textBox.Name = value.Name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop)
		if prop == "Text" then
			local prevValue = value.ConstrainedValue
			--[[if textBox.Text ~= "" then
				pcall(function() script.Parent.ConfigGlobal.Configure:FireServer(value, textBox.Text) end)
			end
			local function onClickOff()
			wait()
			textBox.Text = value.ConstrainedValue
			end
			textBox.FocusLost:Connect(onClickOff)]]
		end
	end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) textBox.Text = newValue end)
	
	textBox.Parent = subFrame
	return subFrame;
end

function processIntValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), value.Value, function(textBox) value.Value = textBox.Text end)
	textBox.Name = value.Name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop)
		if prop == "Text" then
			local prevValue = value.Value
			--[[if textBox.Text ~= "" then
				--pcall(function() value.Value = textBox.Text end)
				pcall(function() script.Parent.ConfigGlobal.Configure:FireServer(value, textBox.Text) end)
			end
			local function onClickOff()
			wait()
			textBox.Text = value.Value
			end
			textBox.FocusLost:Connect(onClickOff)]]
		end
	end)
	valueConnections[#valueConnections+1] = value.Changed:connect(function(newValue) textBox.Text = newValue end)
	
	textBox.Parent = subFrame
	return subFrame;
end

function processPropertyValue(object, name, field, guiFrame)
	origValueMap[name] = object[field]

	local subFrame = sharedProcess(name, guiFrame)
	local textBox = createTextBox(UDim2.new(0.5,-2, 1.0, -2), object[field], function(textBox) object[field] = textBox.Text end)
	textBox.Name = name

	--Tie the two values together... we'll need to break these connections later
	textBox.Changed:connect(function(prop) 
		if prop == "Text" then
			--[[if textBox.Text ~= "" then
				--local success = pcall(function() object[field] = textBox.Text end)
				print(object)
				local success = pcall(function() script.Parent.ConfigGlobal.Configure:FireServer(object, textBox.Text) end)
			end
			local function onClickOff()
			wait()
			textBox.Text = object[field]
			end
			textBox.FocusLost:Connect(onClickOff)]]
		end
	end)

	valueConnections[#valueConnections+1] = object.Changed:connect(function(property) if property == field then textBox.Text = object[field] end end)
	
	textBox.Parent = subFrame
	return subFrame
end


function processEnumValue(value, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)

	local valueChildren = value:GetChildren()
	local enumNames = {}
	for i = 1, #valueChildren do
		if valueChildren[i]:IsA("BoolValue") and valueChildren[i].Value == true then
			table.insert(enumNames,valueChildren[i].Name)
		end
	end

	local valueToChange = value
	local enumSelect = function(item)
		--script.Parent.ConfigGlobal.UpdateValue:FireServer(valueToChange, tostring(item))
	end

	local dropDownEnumMenu, updateEnumSelection = RbxGui.CreateDropDownMenu(enumNames, enumSelect)
	dropDownEnumMenu.Position = UDim2.new(0.5,0,0,0)
	dropDownEnumMenu.Size = UDim2.new(0.5,0,0,20)
	dropDownEnumMenu.Parent = subFrame

	for i = 1, #valueChildren do
		if value.Value == valueChildren[i].Name then
			dropDownEnumMenu.DropDownMenuButton.Text = valueChildren[i].Name
			break
		end
	end

	return subFrame
end



function processNumberValue(value, guiFrame)
	return processIntValue(value, guiFrame)
end


function processStringValue(value, guiFrame)
	return processIntValue(value, guiFrame)
end


function processObjectValue(value, playerGui, guiFrame)
	local subFrame = sharedProcess(value.Name, guiFrame)
	local objectButton = Instance.new("TextButton")
	objectButton.FontSize = textSize
	objectButton.Position = UDim2.new(0.5, 2, 0.0, 2)
	objectButton.Size = UDim2.new(0.5, -4, 1.0, -4)
	objectButton.BackgroundColor = BrickColor.White()
	objectButton.TextColor = BrickColor.Black()
	objectButton.Parent = subFrame
	objectButton.AutoButtonColor = false

	objectButton.MouseButton1Click:connect(function() onObjectValueMouseClick(guiFrame, value, objectButton) end)
	objectButton.MouseEnter:connect(function() onObjectValueMouseEnter(value, objectButton) end)
	objectButton.MouseLeave:connect(function() onObjectValueMouseLeave(value, objectButton) end)

	valueConnections[#valueConnections+1] = value.Changed:connect(function(newObjectValue) setObjectButtonText(guiFrame, objectButton, value) end)	

	setObjectButtonText(guiFrame, objectButton, value)
	return subFrame
end

function processValue(value, playerGui, guiFrame)
	if constrained(value) then origValueMap[value.Name] = value.ConstrainedValue
	else origValueMap[value.Name] = value.Value end

	if #value:GetChildren() > 0 and value:IsA("StringValue") then
		return processEnumValue(value, guiFrame)
	else
		if value.className == "BoolValue" then
			return processBoolValue(value, guiFrame)
		elseif value.className == "IntValue" then
			return processIntValue(value, guiFrame)
		elseif value.className == "NumberValue" then
			return processNumberValue(value, guiFrame)
		elseif value.className == "StringValue" then
			return processStringValue(value, guiFrame)
		elseif value.className == "ObjectValue" then
			return processObjectValue(value, playerGui, guiFrame)
		elseif value.className == "BrickColorValue" then
			return processBrickColorValue(value, guiFrame)
		elseif value.className == "IntConstrainedValue" or value.className == "DoubleConstrainedValue" then
			return processConstrainedNumberValue(value, guiFrame)
		else
			return nil
		end
	end
end

mouse.Move:Connect(function()
	if enabled == false then return end
	if selgui then if selgui:FindFirstChild("ImageButton") then selgui.ImageButton.Image = configIconImage end selgui = nil end
	if mouse.Target == nil then return end
	local selb = nil
	if mouse.Target:FindFirstChild("ConfigSelBoxConnection") then selb = mouse.Target.ConfigSelBoxConnection.Value end
	if mouse.Target.Parent:FindFirstChild("ConfigSelBoxConnection") then selb = mouse.Target.Parent.ConfigSelBoxConnection.Value end
	if selb == nil then return end
	selb.BillboardGui.ImageButton.Image = configIconHoverImage
	selgui = selb.BillboardGui
end)

mouse.Button1Down:Connect(function()
	if selgui == nil then return end
	if not selgui:FindFirstChild("ImageButton") then return end
	selgui.ImageButton.Image = configIconOverImage
end)

mouse.Button1Up:Connect(function()
	if selgui == nil then return end
	if not selgui.Parent then return end
	if screen then screen:Remove() screen = nil end
	
	local valueStorage =nil
	local selconfigpart = selgui.Parent.ConfigSelBoxBackwardsConnection.Value.Parent
	if selconfigpart:IsA("VehicleSeat") then
		valueStorage = selconfigpart
	elseif selconfigpart:IsA("Model") or selconfigpart:IsA("Part") then
		local conf = selconfigpart:FindFirstChildWhichIsA("Configuration", true)
		local conf2 = selconfigpart:FindFirstChildWhichIsA("VehicleSeat", true)
		if conf2 then valueStorage = conf2 end
		if conf then valueStorage = conf end
		if not conf and not conf2 then return end
	end
	if valueStorage == nil then return end
	
	screen = Instance.new("BillboardGui")
	screen.Name = "ConfigGui"
	screen.Size = UDim2.new(0,360,0,180)
	screen.Active = true
	screen.Parent = selgui.Parent
	screen.AlwaysOnTop = true
	screen.Adornee = selgui.Adornee
	
	guiMain = Instance.new("Frame")
	guiMain.Style = Enum.FrameStyle.RobloxRound
	guiMain.Size = UDim2.new(1,0,1,0)
	guiMain.Parent = screen
	
	local buttonFrame = Instance.new("Frame",guiMain)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Position = UDim2.new(0,0,1,-25)
	buttonFrame.Size = UDim2.new(1,0,0,20)
	
	local cancelButton = Instance.new("TextButton",buttonFrame)
	cancelButton.Position = UDim2.new(0.2,2,0,2)
	cancelButton.Size = UDim2.new(0.25,-4,0,25)
	cancelButton.Font = Enum.Font.ArialBold
	cancelButton.Text = "Cancel"
	cancelButton.TextSize = 14
	cancelButton.Style = Enum.ButtonStyle.RobloxButton
	cancelButton.TextColor3 = Color3.fromRGB(242, 243, 243)
	cancelButton.Name = "cancelButton"
	
	cancelButton.MouseButton1Click:Connect(function()
		screen:Remove()
		screen = nil
	end)
	
	local okButton = Instance.new("TextButton",buttonFrame)
	okButton.Position = UDim2.new(0.55,2,0,2)
	okButton.Size = UDim2.new(0.25,-4,0,25)
	okButton.Font = Enum.Font.ArialBold
	okButton.Text = "Ok"
	okButton.TextSize = 14
	okButton.Style = Enum.ButtonStyle.RobloxButton
	okButton.TextColor3 = Color3.fromRGB(242, 243, 243)
	okButton.Name = "OkButton"
	
	local titleLabel = Instance.new("TextLabel",guiMain)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1,0,0,20)
	titleLabel.Font = Enum.Font.ArialBold
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Color3.fromRGB(242, 243, 243)
	titleLabel.Name = "TitleLabel"
	titleLabel.Text = valueStorage.Name
	
	local closeButton = Instance.new("TextButton",guiMain)
	closeButton.Position = UDim2.new(1,-16,0,-5)
	closeButton.Size = UDim2.new(0,20,0,20)
	closeButton.Style = Enum.ButtonStyle.RobloxButtonDefault
	closeButton.TextColor3 = Color3.fromRGB(255,255,255)
	closeButton.TextSize = 18
	closeButton.Font = Enum.Font.ArialBold
	closeButton.Text = "X"
	
	local valueContainer = Instance.new("Frame", guiMain)
	valueContainer.Position = UDim2.new(0,0,0,25)
	valueContainer.Size = UDim2.new(1,-17,1,-50)
	valueContainer.BackgroundTransparency = 1
	
	if valueStorage:IsA("Configuration") then
		local vals = valueStorage:GetChildren()
		for i = 1, #vals do
			local processed = processValue(vals[i],plr.PlayerGui,valueContainer)
			processed.Parent = valueContainer
			processed.Position = UDim2.new(0,0,0,(i-1)*20)
		end
	elseif valueStorage:IsA("VehicleSeat") then
		local maxspd = Instance.new("NumberValue",valueStorage)
		maxspd.Value = valueStorage.MaxSpeed
		maxspd.Name = "MaxSpeed"
		local steer = Instance.new("DoubleConstrainedValue",valueStorage)
		steer.MinValue = 0
		steer.MaxValue = 1
		steer.Value = valueStorage.Steer
		steer.Name = "Steer"
		local torque = Instance.new("NumberValue",valueStorage)
		torque.Value = valueStorage.Torque
		torque.Name = "Torque"
		local turnspd = Instance.new("NumberValue",valueStorage)
		turnspd.Value = valueStorage.TurnSpeed
		turnspd.Name = "TurnSpeed"
		local proc = processValue(maxspd,plr.PlayerGui,valueContainer)
		proc.Parent = valueContainer
		proc.Position = UDim2.new(0,0,0,0)
		local proc = processValue(steer,plr.PlayerGui,valueContainer)
		proc.Parent = valueContainer
		proc.Position = UDim2.new(0,0,0,20)
		local proc = processValue(torque,plr.PlayerGui,valueContainer)
		proc.Parent = valueContainer
		proc.Position = UDim2.new(0,0,0,40)
		local proc = processValue(turnspd,plr.PlayerGui,valueContainer)
		proc.Parent = valueContainer
		proc.Position = UDim2.new(0,0,0,60)
	end
	
	closeButton.MouseButton1Click:Connect(function()
		screen:Remove()
		screen = nil
	end)
	
	okButton.MouseButton1Click:Connect(function()
		if valueStorage:IsA("Configuration") then
			local vals = valueStorage:GetChildren()
			for i = 1, #vals do
				local input = valueContainer:FindFirstChild(vals[i].Name)
				if input then
					if vals[i]:IsA("BoolValue") then
						local TextButton = input:FindFirstChild("TextButton")
						if TextButton.Text == "X" then
							script.Parent.ConfigGlobal.UpdateValue:FireServer(vals[i],true)
						else
							script.Parent.ConfigGlobal.UpdateValue:FireServer(vals[i],false)
						end
						
					end
					if input:FindFirstChild(vals[i].Name,true) then
						script.Parent.ConfigGlobal.UpdateValue:FireServer(vals[i],input:FindFirstChild(vals[i].Name,true).Text)
					elseif input:FindFirstChild("DropDownMenu") then
						script.Parent.ConfigGlobal.UpdateValue:FireServer(vals[i],input:FindFirstChild("DropDownMenuButton",true).Text)
					end
				end
			end
		end
		if valueStorage:IsA("VehicleSeat") then
			local vals = valueStorage:GetChildren()
			for i = 1, #vals do
				local input = valueContainer:FindFirstChild(vals[i].Name)
				if input then
					if input:FindFirstChild(vals[i].Name,true) then
						if vals[i].Name == "MaxSpeed" then
							script.Parent.ConfigGlobal.UpdateValue:FireServer("MaxSpeed",input:FindFirstChild(vals[i].Name,true).Text, valueStorage)
							vals[i]:Remove()
						elseif vals[i].Name == "Torque" then
							script.Parent.ConfigGlobal.UpdateValue:FireServer("Torque",input:FindFirstChild(vals[i].Name,true).Text, valueStorage)
							vals[i]:Remove()
						elseif vals[i].Name == "TurnSpeed" then
							script.Parent.ConfigGlobal.UpdateValue:FireServer("TurnSpeed",input:FindFirstChild(vals[i].Name,true).Text, valueStorage)
							vals[i]:Remove()
						elseif vals[i].Name == "Steer" then
							script.Parent.ConfigGlobal.UpdateValue:FireServer("Steer",input:FindFirstChild(vals[i].Name,true).Text, valueStorage)
							vals[i]:Remove()
						end
					end
				end
			end
		end
		screen:Remove()
		screen = nil
	end)
end)
