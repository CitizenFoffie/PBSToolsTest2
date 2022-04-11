--scripted by goos honk* (*a considerable amount of code was also put together from a free model uploaded by killmeister2271)

local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local cam = workspace.CurrentCamera
local xrot = 0
local yrot = 0
local zrot = 0
local isModel = nil
local mouseIsDown = false
local stdrpos = nil
local newb = nil
local selb = nil
local dragdir = nil
local dragisfinished = true
local dimension = 1
local ogpos = nil
local md = nil

local joints = game:GetService("JointsService")

function onEquip()
	script.Parent.StamperGui.Parent = localPlayer.PlayerGui
	localPlayer.PlayerGui.StamperGui.LoadCategories.Load:Fire()
	selb = Instance.new("SelectionBox", localPlayer.PlayerGui)
	selb.Color3 = Color3.fromRGB(0, 255, 255)
end

function onUnequip()
	localPlayer.PlayerGui.StamperGui.Parent = script.Parent
	if script.CurrentPart.Value ~= nil then
		script.CurrentPart.Value:Remove()
		script.CurrentPart.Value = nil
	end
	joints:ClearJoinAfterMoveJoints()
end

function onPartGot(part)
	local ghostPart = part:Clone()
	ghostPart.Parent = workspace
	mouse.TargetFilter = ghostPart
	if ghostPart:IsA("Model") then
		isModel = true
		local partsinside = ghostPart:GetChildren()
		local num = 1
		for i = 1, #partsinside do
			if partsinside[num]:IsA("BasePart") then
				partsinside[num].Anchored = true
				partsinside[num].CanCollide = false
				if partsinside[num].Transparency == 0 then
				partsinside[num].Transparency = 0.5
				local partsinsided = partsinside[num]:GetChildren()
					if partsinsided ~= nil then
						local numm = 1
						for i = 1, #partsinsided do
							if partsinsided[numm].ClassName == "Decal" or partsinsided[numm].ClassName == "Texture" then
								partsinsided[numm].Transparency = 0.5
							end
							numm = numm+1
						end
					end
				end
			end
			num = num+1
		end
	else
		isModel = false
		ghostPart.Transparency = 0.5
		ghostPart.Anchored = true
		ghostPart.CanCollide = false
		local partsinsided = ghostPart:GetChildren()
		if partsinsided ~= nil then
			local numm = 1
			for i = 1, #partsinsided do
				if partsinsided[numm].ClassName == "Decal" or partsinsided[numm].ClassName == "Texture" then
					partsinsided[numm].Transparency = 0.5
				end
				numm = numm+1
			end
		end
	end
	if script.CurrentPart.Value ~= nil then
		script.CurrentPart.Value:Remove()
	end
	script.CurrentPart.Value = ghostPart
	script.PartPlacing.Value = part
	if isModel == true then
	xrot = ghostPart.PrimaryPart.Rotation.X
	yrot = ghostPart.PrimaryPart.Rotation.Y
	zrot = ghostPart.PrimaryPart.Rotation.Z
	else
	xrot = ghostPart.Rotation.X
	yrot = ghostPart.Rotation.Y
	zrot = ghostPart.Rotation.Z
	end
	local target, pos, lookV, M = workspace:FindPartOnRay(Ray.new(cam.CFrame.p,(mouse.Hit.p-cam.CFrame.p).unit*5000),script.CurrentPart.Value,false,true)
	joints:ClearJoinAfterMoveJoints()
	if isModel == true then
		script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)) * CFrame.Angles(math.rad(xrot), math.rad(yrot), math.rad(zrot)))	
	elseif isModel == false then
		script.CurrentPart.Value.CFrame = CFrame.new(OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)) * CFrame.Angles(math.rad(xrot), math.rad(yrot), math.rad(zrot))
	end
	localPlayer.PlayerGui.StamperGui.MainFrame.MainFrameScript.LeaveScreen:Fire()
end


--credit to killmeister2271 for the functions xdeci, vxdeci, worldpos and voxellize. these were taken from a broken
--stamper tool that was presumably made by killmeister

function XDeci(num)
	--isolates decimal from number (ex: input is 4.6, will return 4, 0.6)
	local x = tostring(num)
	local len = string.len(x)
	local num = "0"
	local deci
	for i = 1, len do
		local char = string.sub(x,i,i)
		if char=="." then
			num = string.sub(x,1,i-1)
			deci = string.sub(x,i,len)
		end
	end
	num=tonumber(num)
	deci=tonumber(deci)
	return num, deci
end

function VXDeci(V,g)
	--seems to simply run xdeci on a vector3 value, g may be unused
	local x = XDeci(V.X)
	local y = XDeci(V.Y)
	local z = XDeci(V.Z)
	local v = Vector3.new(x,y,z)
	return v
end

function WorldPos(p)
	--seems to be a corrector for misalignment between where the cursor is and where the actual stamper part is
	if typeof(p)~="Vector3" then return Vector3.new() end
	local x = p.X
	local y = p.Y
	local z = p.Z
	if x~=0 then x=x/math.abs(x) end
	if y~=0 then y=y/math.abs(y) end
	if z~=0 then z=z/math.abs(z) end
	x = x+1
	y = y+1
	z = z+1
	return Vector3.new(x,y,z)
end

function voxellizeTopSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(p.X, 0, p.Z)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.Y + (tp.Size.Y-1)*0.5
		p=p+Vector3.new(2*w.X,AUH+2.5,2*w.Z)
	else
		p=p+Vector3.new(2*w.X,3,2*w.Z)
	end
	return p
end

function voxellizeBottomSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(p.X, 0, p.Z)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.Y - (tp.Size.Y-1)*0.5
		p=p+Vector3.new(2*w.X,AUH-2.5,2*w.Z)
	else
		p=p+Vector3.new(2*w.X,3,2*w.Z)
	end
	return p
end

function voxellizeRightSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(0, p.Y, p.Z)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.X + (tp.Size.X-1)*0.5
		p=p+Vector3.new(AUH+2.5,2*w.Y,2*w.Z)
	else
		p=p+Vector3.new(3,2*w.Y,2*w.Z)
	end
	return p
end

function voxellizeLeftSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(0, p.Y, p.Z)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.X - (tp.Size.X-1)*0.5
		p=p+Vector3.new(AUH-2.5,2*w.Y,2*w.Z)
	else
		p=p+Vector3.new(3,2*w.Y,2*w.Z)
	end
	return p
end

function voxellizeFrontSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(p.X, p.Y, 0)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.Z - (tp.Size.Z-1)*0.5
		p=p+Vector3.new(2*w.X,2*w.Y,AUH-2.5)
	else
		p=p+Vector3.new(2*w.X,2*w.Y,3)
	end
	return p
end


function voxellizeBackSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(p.X, p.Y, 0)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.Z + (tp.Size.Z-1)*0.5
		p=p+Vector3.new(2*w.X,2*w.Y,AUH+2.5)
	else
		p=p+Vector3.new(2*w.X,2*w.Y,3)
	end
	return p
end

function voxellizeLeftSurf(pos,grid,tp)
	local p = pos/grid
	p=VXDeci(p,grid)
	p=p*grid
	p = Vector3.new(0, p.Y, p.Z)
	local w = WorldPos(pos)
	if tp ~= nil then
		local AUH = tp.Position.X - (tp.Size.X-1)*0.5
		p=p+Vector3.new(AUH-2.5,2*w.Y,2*w.Z)
	else
		p=p+Vector3.new(3,2*w.Y,2*w.Z)
	end
	return p
end

function getUniversalFace(face,orientation)
	local x0y0z0 = {Enum.NormalId.Front, Enum.NormalId.Left, Enum.NormalId.Back, Enum.NormalId.Right, Enum.NormalId.Top, Enum.NormalId.Bottom}
	local x0y90z0 = {Enum.NormalId.Left, Enum.NormalId.Back, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Top, Enum.NormalId.Bottom}
	local x0y180z0 = {Enum.NormalId.Back, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Left, Enum.NormalId.Top, Enum.NormalId.Bottom}
	local x0yneg90z0 = {Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Left, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom}
	

	local findnum = nil
	local ort = nil
	if face == Enum.NormalId.Front then findnum = 1 end
	if face == Enum.NormalId.Left then findnum = 2 end
	if face == Enum.NormalId.Back then findnum = 3 end
	if face == Enum.NormalId.Right then findnum = 4 end
	if face == Enum.NormalId.Top then findnum = 5 end
	if face == Enum.NormalId.Bottom then findnum = 6 end
	
	if orientation == Vector3.new(0,0,0) then ort = x0y0z0 end
	if orientation == Vector3.new(0,90,0) then ort = x0y90z0 end
	if orientation == Vector3.new(0,180,0) then ort = x0y180z0 end
	if orientation == Vector3.new(0,-90,0) then ort = x0yneg90z0 end
	
	if findnum == nil then findnum = 1 end
	if ort == nil then ort = x0y0z0 end
	
	return ort[findnum]
end

function Voxellize(pos,grid,tp,surface)
	local p = nil
	
	--[[if tp ~= nil then
	surface = getUniversalFace(surface, tp.Orientation	)
	end
	print(surface)]]
	
	if surface == Enum.NormalId.Top then p = voxellizeTopSurf(pos,grid,tp)
		
	elseif surface == Enum.NormalId.Bottom then p = voxellizeBottomSurf(pos,grid,tp)
		
	elseif surface == Enum.NormalId.Right then p = voxellizeRightSurf(pos,grid,tp)
		
	elseif surface == Enum.NormalId.Left then p = voxellizeLeftSurf(pos,grid,tp)
		
	elseif surface == Enum.NormalId.Front then p = voxellizeFrontSurf(pos,grid,tp)
		
	elseif surface == Enum.NormalId.Back then p = voxellizeBackSurf(pos,grid,tp)
		
	else p = voxellizeTopSurf(pos,grid,tp)
	end
	return p
end

function OnGrid(pos,grid,MyPart,TargetPart,lookVector)
	--modified from killmeister's OnGrid function
	pos = pos-Vector3.new(2,2,2)
	local p = Voxellize(pos,grid,TargetPart,mouse.TargetSurface)
	if typeof(TargetPart)=="Instance" then
		if TargetPart.Size.magnitude== Vector3.new(4,4,4).magnitude then
			p=TargetPart.Position+(lookVector*grid)
		end
	end
	return p
end

function onKeyPress(inputObject, gameProcessedEvent)
	if script.CurrentPart.Value ~= nil then
		if inputObject.KeyCode == Enum.KeyCode.R then
			yrot = yrot + 90
			if yrot > 360 then
				yrot = 0
			end
		elseif inputObject.KeyCode == Enum.KeyCode.T then
			xrot = xrot + 90
			if xrot > 360 then
				xrot = 0
			end
		elseif inputObject.KeyCode == Enum.KeyCode.Y then
			zrot = zrot + 90
			if zrot > 360 then
				zrot = 0
			end
		elseif inputObject.KeyCode == Enum.KeyCode.E then
			yrot = 0
			xrot = 0
			zrot = 0
		elseif inputObject.KeyCode == Enum.KeyCode.C and dragisfinished == false then
			if dimension < 2 then dimension = dimension+1 else dimension = 2 end
			if script.CurrentPart.Value ~= nil then ogpos = script.CurrentPart.Value.Part.Position end
		end
	end
end

local function getOrientationBump(face)
	if face == Enum.NormalId.Front then return Vector3.new(0,0,0)	
	elseif face == Enum.NormalId.Right then return Vector3.new(0,-90,0)
	elseif face == Enum.NormalId.Back then return Vector3.new(0,180,0)
	elseif face == Enum.NormalId.Left then return Vector3.new(0,90,0)
	else return nil end 
end



function onMove()
	wait()
	if script.CurrentPart.Value ~= nil and mouse.Hit ~= nil then
		local target, pos, lookV, M = workspace:FindPartOnRay(Ray.new(cam.CFrame.p,(mouse.Hit.p-cam.CFrame.p).unit*5000),script.CurrentPart.Value,false,true)
		if isModel == true and not script.CurrentPart.Value:FindFirstChild("IsTerrain") then
			if script.CurrentPart.Value.PrimaryPart == nil then
				script.CurrentPart.Value.PrimaryPart = script.CurrentPart.Value:FindFirstChildWhichIsA("BasePart"):GetRootPart()
			end
			if script.CurrentPart.Value:FindFirstChild("AutoAlignToFace") and mouse.Target ~= nil then
				if getOrientationBump(mouse.TargetSurface) ~= nil then
				local ort3 = mouse.Target.Orientation + getOrientationBump(mouse.TargetSurface)
				xrot = ort3.X
				yrot = ort3.Y
				zrot = ort3.Z
				end
			end
			script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)) * CFrame.Angles(math.rad(xrot), math.rad(yrot), math.rad(zrot)))
		elseif isModel == false then
			script.CurrentPart.Value.CFrame = CFrame.new(OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)) * CFrame.Angles(math.rad(xrot), math.rad(yrot), math.rad(zrot))
		end
		if script.CurrentPart.Value:FindFirstChild("IsTerrain") then
			if stdrpos ~= nil and script.CurrentPart.Value.Part.Position ~= stdrpos then
				if md == nil then
					md = Instance.new("Model", workspace)
					md.Name = "Stamper Drag Model"
				end
				dragisfinished = false
				script.CurrentPart.Value.Parent = md
				if newb ~= nil then newb:Remove() newb = nil end
				newb = Instance.new("Part", md)
				newb.Size = Vector3.new(4,4,4)
				newb.Position = stdrpos
				newb.Anchored = true
				newb.Locked = true
				newb.CanCollide = false
				newb.Transparency = 1
				mouse.TargetFilter = md
				selb.Adornee = md
				local og = OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)
				dragisfinished = false
				if dimension == 1 then
					if script.CurrentPart.Value.Part.Position.X ~= stdrpos.X then
					script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(og.X, stdrpos.Y, stdrpos.Z)))
					dragdir = "X"
					elseif script.CurrentPart.Value.Part.Position.Z ~= stdrpos.Z then
					script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(stdrpos.X, stdrpos.Y, og.Z)))	
					dragdir = "Z"
					elseif script.CurrentPart.Value.Part.Position.Y ~= stdrpos.Y then
					script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(stdrpos.X, og.Y, stdrpos.Z)))
					dragdir = "Y"
					end
				elseif dimension == 2 then
					if dragdir == "X" or dragdir == "XY" or dragdir == "XZ" then
						script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(ogpos.X, og.Y, og.Z)))
						if script.CurrentPart.Value.Part.Position.Y ~= stdrpos.Y then
							script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(ogpos.X, og.Y, stdrpos.Z)))
							dragdir = "XY"
						elseif script.CurrentPart.Value.Part.Position.Z ~= stdrpos.Z then
							script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(ogpos.X, stdrpos.Y, og.Z)))
							dragdir = "XZ"
						end
					end
					if dragdir == "Y" or dragdir == "YX" or dragdir == "YZ" then
						script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(og.X, ogpos.Y, og.Z)))
						if script.CurrentPart.Value.Part.Position.X ~= stdrpos.X then
							script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(og.X, ogpos.Y, stdrpos.Z)))
							dragdir = "YX"
						elseif script.CurrentPart.Value.Part.Position.Z ~= stdrpos.Z then
							script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(stdrpos.X, ogpos.Y, og.Z)))
							dragdir = "YZ"
						end
					end
					if dragdir == "Z" or dragdir == "ZX" or dragdir == "ZY" then
						script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(og.X, og.Y, ogpos.Z)))
						if script.CurrentPart.Value.Part.Position.X ~= stdrpos.X then
							script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(og.X, stdrpos.Y, ogpos.Z)))
							dragdir = "ZX"
						elseif script.CurrentPart.Value.Part.Position.Y ~= stdrpos.Y then
							script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(Vector3.new(stdrpos.X, og.Y, ogpos.Z)))
							dragdir = "ZY"
						end
					end
					ogpos = script.CurrentPart.Value.Part.Position
				end
			else 
				if script.CurrentPart.Value.PrimaryPart.ClassName == "Part" then
				script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)))
				elseif script.CurrentPart.Value.PrimaryPart.ClassName == "WedgePart" or script.CurrentPart.Value.PrimaryPart.ClassName == "CornerWedgePart" then
				script.CurrentPart.Value:SetPrimaryPartCFrame(CFrame.new(OnGrid(pos, 4, script.CurrentPart.Value, target, lookV)) * CFrame.Angles(math.rad(0), math.rad(yrot), math.rad(0)))
				end
			end
		end
		joints:ClearJoinAfterMoveJoints()
		joints:SetJoinAfterMoveInstance(script.CurrentPart.Value)
		joints:SetJoinAfterMoveTarget(mouse.Target)
		joints:ShowPermissibleJoints()
	end
end

function onClick()
	mouseIsDown = false
	if newb ~= nil then newb:Remove() newb = nil end
	if script.PartPlacing.Value ~= nil and selb.Adornee == nil and script.CurrentPart.Value ~= nil then
		joints:ClearJoinAfterMoveJoints()
		if isModel == true and not script.CurrentPart.Value:FindFirstChild("IsTerrain") then
		script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, script.CurrentPart.Value.PrimaryPart.Position, xrot, yrot, zrot, mouse.Target, true)
		elseif isModel == false then
		script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, script.CurrentPart.Value.Position, xrot, yrot, zrot, mouse.Target, false)	
		elseif script.CurrentPart.Value:FindFirstChild("IsTerrain") then
			if stdrpos ~= nil then
				if script.CurrentPart.Value.Part.Position == stdrpos then
					script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, script.CurrentPart.Value.PrimaryPart.Position, xrot, yrot, zrot, mouse.Target, true)
				else return end
			else 
			script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, script.CurrentPart.Value.PrimaryPart.Position, xrot, yrot, zrot, mouse.Target, true)
			end
		end
		wait(0.1)
		onMove()
	elseif script.PartPlacing.Value ~= nil and selb.Adornee ~= nil and script.CurrentPart.Value ~= nil then
		if script.CurrentPart.Value.PrimaryPart.Position ~= stdrpos then
			if dimension == 1 then
				if dragdir == "X" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.X - stdrpos.X
					dist = dist/4
					local absdist = math.abs(dist)
					for i = 0, absdist do
						if i == absdist+1 then return else
							if absdist == dist then
							script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)
							else
							script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)	
							end
						end
					end
				end
				if dragdir == "Z" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.Z - stdrpos.Z
					dist = dist/4
					local absdist = math.abs(dist)
					for i = 0, absdist do
						if i == absdist+1 then return else
							if absdist == dist then
							script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y, stdrpos.Z + i*4), xrot, yrot, zrot, mouse.Target, true)
							else
							script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y, stdrpos.Z - i*4), xrot, yrot, zrot, mouse.Target, true)	
							end
						end
					end
				end
				if dragdir == "Y" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.Y - stdrpos.Y
					dist = dist/4
					local absdist = math.abs(dist)
					for i = 0, absdist do
						if i == absdist+1 then return else
							if absdist == dist then
							script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y + i*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)
							else
							script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y - i*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)	
							end
						end
					end
				end
			elseif dimension == 2 then
				if dragdir == "XY" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.X - stdrpos.X
					dist = dist/4
					local absdist = math.abs(dist)
					local dist2 = script.CurrentPart.Value.PrimaryPart.Position.Y - stdrpos.Y
					dist2 = dist2/4
					local absdist2 = math.abs(dist2)
					for o = 0, absdist2 do
						if o == absdist2+1 then return else
							for i = 0, absdist do
								if absdist2 == dist2 then
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y + o*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y + o*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								else
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y - o*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y - o*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								end
							end
						end
					end
				end
				if dragdir == "XZ" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.X - stdrpos.X
					dist = dist/4
					local absdist = math.abs(dist)
					local dist2 = script.CurrentPart.Value.PrimaryPart.Position.Z - stdrpos.Z
					dist2 = dist2/4
					local absdist2 = math.abs(dist2)
					for o = 0, absdist2 do
						if o == absdist2+1 then return else
							for i = 0, absdist do
								if absdist2 == dist2 then
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								else
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								end
							end
						end
					end
				end
				if dragdir == "YX" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.Y - stdrpos.Y
					dist = dist/4
					local absdist = math.abs(dist)
					local dist2 = script.CurrentPart.Value.PrimaryPart.Position.X - stdrpos.X
					dist2 = dist2/4
					local absdist2 = math.abs(dist2)
					for o = 0, absdist2 do
						if o == absdist2+1 then return else
							for i = 0, absdist do
								if absdist2 == dist2 then
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + o*4, stdrpos.Y + i*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + o*4, stdrpos.Y - i*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								else
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - o*4, stdrpos.Y + i*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - o*4, stdrpos.Y - i*4, stdrpos.Z), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								end
							end
						end
					end
				end
				if dragdir == "YZ" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.Y - stdrpos.Y
					dist = dist/4
					local absdist = math.abs(dist)
					local dist2 = script.CurrentPart.Value.PrimaryPart.Position.Z - stdrpos.Z
					dist2 = dist2/4
					local absdist2 = math.abs(dist2)
					for o = 0, absdist2 do
						if o == absdist2+1 then return else
							for i = 0, absdist do
								if absdist2 == dist2 then
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y + i*4, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y - i*4, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								else
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y + i*4, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y - i*4, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								end
							end
						end
					end
				end
				if dragdir == "ZX" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.X - stdrpos.X
					dist = dist/4
					local absdist = math.abs(dist)
					local dist2 = script.CurrentPart.Value.PrimaryPart.Position.Z - stdrpos.Z
					dist2 = dist2/4
					local absdist2 = math.abs(dist2)
					for o = 0, absdist2 do
						if o == absdist2+1 then return else
							for i = 0, absdist do
								if absdist2 == dist2 then
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								else
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X + i*4, stdrpos.Y, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X - i*4, stdrpos.Y, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								end
							end
						end
					end
				end
				if dragdir == "ZY" then
					local dist = script.CurrentPart.Value.PrimaryPart.Position.Y - stdrpos.Y
					dist = dist/4
					local absdist = math.abs(dist)
					local dist2 = script.CurrentPart.Value.PrimaryPart.Position.Z - stdrpos.Z
					dist2 = dist2/4
					local absdist2 = math.abs(dist2)
					for o = 0, absdist2 do
						if o == absdist2+1 then return else
							for i = 0, absdist do
								if absdist2 == dist2 then
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y + i*4, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y - i*4, stdrpos.Z + o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								else
									if i == absdist+1 then return else
										if absdist == dist then
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y + i*4, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)
										else
										script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, Vector3.new(stdrpos.X, stdrpos.Y - i*4, stdrpos.Z - o*4), xrot, yrot, zrot, mouse.Target, true)	
										end
									end
								end
							end
						end
					end
				end
			end
			dragisfinished = true
			dimension = 1
			ogpos = nil
		else
			script.Parent.StamperGlobal.PlacePart:FireServer(script.PartPlacing.Value, script.CurrentPart.Value.PrimaryPart.Position, xrot, yrot, zrot, mouse.Target, true)
		end
	end
	stdrpos = nil
	if selb~= nil then
	selb.Adornee = nil
	end
	dragdir = nil
end

function onMouseDown()
	mouseIsDown = true
	if script.CurrentPart.Value ~= nil then
		if script.CurrentPart.Value:FindFirstChild("IsTerrain") then
			stdrpos = script.CurrentPart.Value.Part.Position
		end
	end
end



game:GetService("UserInputService").InputBegan:connect(onKeyPress)
mouse.Button1Up:Connect(onClick)
script.Parent.Equipped:Connect(onEquip)
script.Parent.Unequipped:Connect(onUnequip)
script:WaitForChild("GetPart").Event:Connect(onPartGot)
mouse.Move:Connect(onMove)
mouse.Button1Down:Connect(onMouseDown)
