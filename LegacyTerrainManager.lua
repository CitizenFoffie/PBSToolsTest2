--scripted by goos_honk
--thank you to soliddshibe for getting the legacy terrain textures for this game
--play shinjuku 2006 on soliddshibe profile it is good game


--[[
TO DO:
test water
bug fixes
]]
--definitions

math.randomseed(tick())
--***math.randomseed so that the random raycasts are based on unix time

local terrainParts = game.Workspace.Terrain.TerrainParts
local terrainTextures = game.ServerStorage.TerrainTextures
--***define locations of folders

--part level functions

function createPart(position,material,norefresh, autowedge)
	local new = Instance.new("Part")
	new.Size = Vector3.new(4,4,4)
	new.Position = Vector3.new(GridPos(position.X), GridPos(position.Y), GridPos(position.Z))
	new.Anchored = true
	new.Locked = true
	new.Parent = assignChunk(new.Position)
	--***create part, apply properties
	if new.Parent:FindFirstChild(getNameFromPos(new.Position)) then
		new.Parent[getNameFromPos(new.Position)]:Destroy()
	end
	--***if found part at position, replace
	new.Name = getNameFromPos(new.Position)
	new.TopSurface = Enum.SurfaceType.Smooth
	new.BottomSurface = Enum.SurfaceType.Smooth
	--*** set name by position, apply surfaces
	local isCovered = Instance.new("BoolValue", new)
	isCovered.Value = false
	isCovered.Name = "isCovered"
	local Material = Instance.new("StringValue", new)
	Material.Value = material
	Material.Name = "TerrainMaterial"
	local isTerrain = Instance.new("BoolValue",new)
	isTerrain.Name = "IsTerrain"
	local shape = Instance.new("StringValue", new)
	shape.Name = "TerrainShape"
	shape.Value = "Block"
	--***assign values
	new.Parent = assignChunk(new.Position)
	--***assign part chunk (see function assignChunk)
	if not norefresh then
		local findabove = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,4,0)))
		if findabove then
			refreshPartCoverState(findabove)
		end
		local findbelow = new.Parent:FindFirstChild(getNameFromPos(new.Position-Vector3.new(0,4,0)))
		if findbelow then
			refreshPartCoverState(findbelow)
		end
		local findparts = Instance.new("Part", workspace)
		findparts.Anchored = true
		findparts.CanCollide = false
		findparts.Locked = true
		findparts.Position = new.Position	
		findparts.Size = Vector3.new(12,4,12)
		findparts.Touched:Connect(function()end)
		if findabove then
			refreshPartCoverState(findabove)
		end
		if findbelow then
			refreshPartCoverState(findbelow)
		end
		local founds = findparts:GetTouchingParts()
		for i = 1, #founds do
			if founds[i]:FindFirstChild("IsTerrain") and founds[i] ~= new then
				refreshPartCoverState(founds[i])
			end
		end
		findparts:Destroy()
	end
	assignTextures(new)
	refreshPartCoverState(new)
	if autowedge == true then autoWedgePart(new) end
end

function createVerticalWedge(position,material,rotation, isauto)
	local new = game.ServerStorage.TerrainShapeTemplate.VerticalWedge:Clone()
	new.Position = Vector3.new(GridPos(position.X), GridPos(position.Y), GridPos(position.Z))
	new.Anchored = true
	new.Locked = true
	new.Orientation = rotation
	if rotation ~= Vector3.new(0,0,0) and rotation ~= Vector3.new(0,90,0) and rotation ~= Vector3.new(0,180,0) and rotation ~= Vector3.new(0,-90,0) and rotation ~= Vector3.new(0,270,0) then
		new.Orientation	 = Vector3.new(0,0,0)
	end
	new.Parent = assignChunk(new.Position)
	if new.Parent:FindFirstChild(getNameFromPos(new.Position)) then
		new.Parent[getNameFromPos(new.Position)]:Destroy()
	end
	new.Name = getNameFromPos(new.Position)
	new.TopSurface = Enum.SurfaceType.Smooth
	new.BottomSurface = Enum.SurfaceType.Smooth
	local isCovered = Instance.new("BoolValue", new)
	isCovered.Value = false
	isCovered.Name = "isCovered"
	local Material = Instance.new("StringValue", new)
	Material.Value = material
	Material.Name = "TerrainMaterial"
	local isTerrain = Instance.new("BoolValue",new)
	isTerrain.Name = "IsTerrain"
	local shape = Instance.new("StringValue", new)
	shape.Name = "TerrainShape"
	shape.Value = "VWedge"
	local findabove = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,4,0)+getPositionThingFromRotation(new.Orientation)*4))
	if findabove then
		refreshPartCoverState(findabove)
	end
	if isauto then
		local findbelow = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,-4,0)))
		if findbelow then if findbelow.TerrainShape.Value ~= "Block" and new.Parent ~= nil then
			createPart(findbelow.Position, findbelow.TerrainMaterial.Value)
		end end
	end
	assignTextures(new)
	refreshPartCoverState(new)
	new.Parent.ChildRemoved:Connect(function()
		if new.Parent == nil then return end 
		wait()refreshPartCoverState(new)
	end)
	new.Parent.ChildAdded:Connect(function()
		if new.Parent == nil then return end 
		wait()refreshPartCoverState(new)
	end)
end

function createHorizWedge(position,material,rotation)
	local new = game.ServerStorage.TerrainShapeTemplate.HorizontalWedge:Clone()
	new.Position = Vector3.new(GridPos(position.X), GridPos(position.Y), GridPos(position.Z))
	new.Anchored = true
	new.Locked = true
	new.Rotation = rotation
	if rotation ~= Vector3.new(0,0,0) and rotation ~= Vector3.new(0,90,0) and rotation ~= Vector3.new(0,180,0) and rotation ~= Vector3.new(0,-90,0) and rotation ~= Vector3.new(0,270,0) then
		new.Rotation = Vector3.new(0,0,0)
	end
	new.Parent = assignChunk(new.Position)
	if new.Parent:FindFirstChild(getNameFromPos(new.Position)) then
		new.Parent[getNameFromPos(new.Position)]:Destroy()
	end
	new.Name = getNameFromPos(new.Position)
	new.TopSurface = Enum.SurfaceType.Smooth
	new.BottomSurface = Enum.SurfaceType.Smooth
	local isCovered = Instance.new("BoolValue", new)
	isCovered.Value = false
	isCovered.Name = "isCovered"
	local Material = Instance.new("StringValue", new)
	Material.Value = material
	Material.Name = "TerrainMaterial"
	local isTerrain = Instance.new("BoolValue",new)
	isTerrain.Name = "IsTerrain"
	local shape = Instance.new("StringValue", new)
	shape.Name = "TerrainShape"
	shape.Value = "HWedge"
	local findabove = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,4,0)))
	if findabove then
		refreshPartCoverState(findabove)
	end
	local findbelow = new.Parent:FindFirstChild(getNameFromPos(new.Position-Vector3.new(0,4,0)))
	if findbelow then
		refreshPartCoverState(findbelow)
	end
	local findx = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(4,0,0)))
	if findx then 
		refreshPartCoverState(findx)
	end
	local findnegx = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(-4,0,0)))
	if findnegx then 
		refreshPartCoverState(findnegx)
	end
	local findz = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(0,0,4)))
	if findz then 
		refreshPartCoverState(findz)
	end
	local findnegz = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(0,0,-4)))
	if findnegz then 
		refreshPartCoverState(findnegz)
	end
	assignTextures(new)
	refreshPartCoverState(new)
end

function createCornerWedge(position,material,rotation, isauto)
	local new = game.ServerStorage.TerrainShapeTemplate.CornerWedge:Clone()
	new.Position = Vector3.new(GridPos(position.X), GridPos(position.Y), GridPos(position.Z))
	new.Anchored = true
	new.Locked = true
	new.Orientation = rotation
	if rotation ~= Vector3.new(0,0,0) and rotation ~= Vector3.new(0,90,0) and rotation ~= Vector3.new(0,180,0) and rotation ~= Vector3.new(0,-90,0) and rotation ~= Vector3.new(0,270,0) then
		new.Orientation	 = Vector3.new(0,0,0)
	end
	new.Parent = assignChunk(new.Position)
	if new.Parent:FindFirstChild(getNameFromPos(new.Position)) then
		new.Parent[getNameFromPos(new.Position)]:Destroy()
	end
	new.Name = getNameFromPos(new.Position)
	new.TopSurface = Enum.SurfaceType.Smooth
	new.BottomSurface = Enum.SurfaceType.Smooth
	local isCovered = Instance.new("BoolValue", new)
	isCovered.Value = false
	isCovered.Name = "isCovered"
	local Material = Instance.new("StringValue", new)
	Material.Value = material
	Material.Name = "TerrainMaterial"
	local isTerrain = Instance.new("BoolValue",new)
	isTerrain.Name = "IsTerrain"
	local shape = Instance.new("StringValue", new)
	shape.Name = "TerrainShape"
	shape.Value = "CWedge"
	local findabove = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,4,0)+getPositionThingFromRotationForCWedge(new.Orientation)*4))
	if findabove then
		refreshPartCoverState(findabove)
	end
	if isauto then
		local findbelow = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,-4,0)))
		if findbelow then if findbelow.TerrainShape.Value ~= "Block" then
			createHorizWedge(findbelow.Position, findbelow.TerrainMaterial.Value, new.Orientation-Vector3.new(0,90,0))
		end end
	end
	assignTextures(new)
	refreshPartCoverState(new)
	new.Parent.ChildRemoved:Connect(function()
		if new.Parent == nil then return end 
		wait()refreshPartCoverState(new)
	end)
	new.Parent.ChildAdded:Connect(function()
		if new.Parent == nil then return end 
		wait()refreshPartCoverState(new)
	end)
end

function createInverseWedge(position,material,rotation)
	local new = game.ServerStorage.TerrainShapeTemplate.InverseCornerWedge:Clone()
	new.Position = Vector3.new(GridPos(position.X), GridPos(position.Y), GridPos(position.Z))
	new.Anchored = true
	new.Locked = true
	new.Rotation = rotation
	if rotation ~= Vector3.new(0,0,0) and rotation ~= Vector3.new(0,90,0) and rotation ~= Vector3.new(0,180,0) and rotation ~= Vector3.new(0,-90,0) and rotation ~= Vector3.new(0,270,0) then
		new.Rotation = Vector3.new(0,0,0)
	end
	new.Parent = assignChunk(new.Position)
	if new.Parent:FindFirstChild(getNameFromPos(new.Position)) then
		new.Parent[getNameFromPos(new.Position)]:Destroy()
	end
	new.Name = getNameFromPos(new.Position)
	new.TopSurface = Enum.SurfaceType.Smooth
	new.BottomSurface = Enum.SurfaceType.Smooth
	local isCovered = Instance.new("BoolValue", new)
	isCovered.Value = false
	isCovered.Name = "isCovered"
	local Material = Instance.new("StringValue", new)
	Material.Value = material
	Material.Name = "TerrainMaterial"
	local isTerrain = Instance.new("BoolValue",new)
	isTerrain.Name = "IsTerrain"
	local shape = Instance.new("StringValue", new)
	shape.Name = "TerrainShape"
	shape.Value = "IWedge"
	local findabove = new.Parent:FindFirstChild(getNameFromPos(new.Position+Vector3.new(0,4,0)))
	if findabove then
		refreshPartCoverState(findabove)
	end
	local findbelow = new.Parent:FindFirstChild(getNameFromPos(new.Position-Vector3.new(0,4,0)))
	if findbelow then
		refreshPartCoverState(findbelow)
	end
	local findx = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(4,0,0)))
	if findx then 
		refreshPartCoverState(findx)
	end
	local findnegx = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(-4,0,0)))
	if findnegx then 
		refreshPartCoverState(findnegx)
	end
	local findz = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(0,0,4)))
	if findz then 
		refreshPartCoverState(findz)
	end
	local findnegz = findFirstChildInAdjacentChunks(new.Parent, getNameFromPos(new.Position+Vector3.new(0,0,-4)))
	if findnegz then 
		refreshPartCoverState(findnegz)
	end
	assignTextures(new)
	refreshPartCoverState(new)
end

function GridPos(num)
	if num/4 - math.floor(num/4) < 0.5 then return math.floor(num/4)*4 else return math.ceil(num/4)*4 end
end

function getNameFromPos(pos)
	return pos.X..","..pos.Y..","..pos.Z
end

function getPositionThingFromRotation(rot)
	if rot == Vector3.new(0,0,0) then
		return 	Vector3.new(0,0,1) 
	elseif rot == Vector3.new(0,90,0) then
		return 	Vector3.new(1,0,0) 
	elseif rot == Vector3.new(0,-180,0) then
		return 	Vector3.new(0,0,-1)
	elseif rot == Vector3.new(0,-90,0) or rot == Vector3.new(0,270,0) then
		return 	Vector3.new(-1,0,0)
	end
	return Vector3.new(0,0,0)
end

function getPositionThingFromRotationForCWedge(rot)
	if rot == Vector3.new(0,0,0) then
		return Vector3.new(1,0,1)
	elseif rot == Vector3.new(0,90,0) then
		return 	Vector3.new(1,0,-1) 
	elseif rot == Vector3.new(0,-180,0) then
		return 	Vector3.new(-1,0,-1)
	elseif rot == Vector3.new(0,-90,0) or rot == Vector3.new(0,270,0) then
		return 	Vector3.new(-1,0,1)
	end
	return Vector3.new(1,0,1)
end

function assignTextures(part)
	if not part.Parent then return end
	if not part:IsA("BasePart") then return end
	local pchild = part:GetChildren()
	for i = 1, #pchild do if pchild[i]:IsA("Texture") then pchild[i]:Destroy() end end
	local textures = terrainTextures[part.TerrainMaterial.Value]:GetChildren()
	for i = 1, #textures do
		local newt = textures[i]:Clone()
		newt.Parent = part
		if newt.Name == "FrontTexture" or newt.Name == "BackTexture" then
			if math.floor(part.Position.X/8) ~= part.Position.X/8 then
				newt.OffsetStudsU = 4
			end
			if part.isCovered.Value == true then
				if math.floor(part.Position.Y/16) == part.Position.Y/16 then
					newt.OffsetStudsV = 4
				else
					newt.OffsetStudsV = part.Position.Y
				end
			end
			if part.Name ~= "ClusterChunkPart" then
				if newt.Name == "FrontTexture" and findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position-Vector3.new(0,0,4))) and part.TerrainShape.Value == "Block" then
					if part.Parent[getNameFromPos(part.Position-Vector3.new(0,0,4))].TerrainShape.Value == "Block" then
						newt:Destroy()
					end
				end
				if newt.Name == "BackTexture" and findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(0,0,4))) and part.TerrainShape.Value == "Block" then
					if part.Parent[getNameFromPos(part.Position+Vector3.new(0,0,4))].TerrainShape.Value == "Block" then
						newt:Destroy()
					end
				end
				if part.TerrainShape.Value == "HWedge" or part.TerrainShape.Value == "CWedge" or part.TerrainShape.Value == "IWedge" then
					newt.OffsetStudsV = newt.OffsetStudsV+2
					if newt.StudsPerTileV == 20 then newt.OffsetStudsU = newt.OffsetStudsU+2 end
				end
			end
		end
		if newt.Name == "LeftTexture" or newt.Name == "RightTexture" then
			if math.floor(part.Position.Z/8) ~= part.Position.Z/8 then
				newt.OffsetStudsU = 4
			end
			if part.isCovered.Value == true then
				if math.floor(part.Position.Y/16) == part.Position.Y/16 then
					newt.OffsetStudsV = 4
				else
					newt.OffsetStudsV = part.Position.Y
				end
			end
			if part.Name ~= "ClusterChunkPart" then
				if newt.Name == "RightTexture" and findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(4,0,0))) and part.TerrainShape.Value == "Block" then
					if part.Parent[getNameFromPos(part.Position+Vector3.new(4,0,0))].TerrainShape.Value == "Block" then
						newt:Destroy()
					end
				end
				if newt.Name == "LeftTexture" and 	findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position-Vector3.new(4,0,0))) and part.TerrainShape.Value == "Block" then
					if part.Parent[getNameFromPos(part.Position-Vector3.new(4,0,0))].TerrainShape.Value == "Block" then
						newt:Destroy()
					end
				end
			end
			if part.TerrainShape.Value == "HWedge" or part.TerrainShape.Value == "CWedge" or part.TerrainShape.Value == "IWedge" and newt.StudsPerTileV == 16 then
				newt.OffsetStudsV = newt.OffsetStudsV+2
				if newt.StudsPerTileV == 20 then newt.OffsetStudsU = newt.OffsetStudsU+2 end
			end
		end
		if newt.Name == "TopTexture" or newt.Name == "BottomTexture" then 

			newt.OffsetStudsU = part.Position.X - part.Position.X*2 
			newt.OffsetStudsV = part.Position.Z - part.Position.Z*2 
			if newt.Name == "TopTexture" and part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,4,0))) then
				if part.Parent[getNameFromPos(part.Position+Vector3.new(0,4,0))].TerrainShape.Value == "Block" and part.TerrainShape.Value == "Block" then
					newt:Destroy()
				end
			end
			if newt.Name == "BottomTexture" and part.Parent:FindFirstChild(getNameFromPos(part.Position-Vector3.new(0,4,0))) then
				if part.Parent[getNameFromPos(part.Position-Vector3.new(0,4,0))].TerrainShape.Value == "Block" then
					newt:Destroy()
				end
			end
		end
		if newt.Name == "SlopeTexture" then
			if part.TerrainShape.Value ~= "VWedge" and part.TerrainShape.Value ~= "CWedge" then newt:Destroy() end
			if part.isCovered.Value == false then
				newt.OffsetStudsV = 0
			end
			if part.isCovered.Value == true then 
				if part.Position.Y/16 ~= math.floor(part.Position.Y/16) then newt.OffsetStudsV = part.Position.Y else newt.OffsetStudsV = 4 end
			end
			if part.TerrainShape.Value == "CWedge" then newt.OffsetStudsV = newt.OffsetStudsV+2 
				newt.Face = Enum.NormalId.Front 
			end
		end
		if newt.Name == "InverseSlopeTexture" then
			if part.TerrainShape.Value ~= "IWedge" then newt:Destroy() end
			if part.isCovered.Value == false then
				newt.OffsetStudsV = 0
			end
			if part.isCovered.Value == true then 
				if part.Position.Y/16 ~= math.floor(part.Position.Y/16) then newt.OffsetStudsV = part.Position.Y else newt.OffsetStudsV = 4 end
			end
			newt.OffsetStudsV = newt.OffsetStudsV+2 
			newt.OffsetStudsU = newt.OffsetStudsU+2
		end
		if newt.Name == "FrontTexture" then if part.TerrainShape.Value == "VWedge" or part.TerrainShape.Value == "CWedge" or part.TerrainShape.Value == "IWedge" then newt:Destroy() end end
		if newt.Name == "TopTexture" then if part.TerrainShape.Value == "VWedge" or part.TerrainShape.Value == "CWedge" then newt:Destroy() end end
	end
end

function refreshPartCoverState(part, blockCascade)
	if not part:FindFirstChild("TerrainShape") then return end
	if part.Name ~= "ClusterChunkPart" and part.ClassName ~= "Vector3Value" and part.TerrainShape.Value == "Block" or part.Name ~= "ClusterChunkPart" and part.ClassName ~= "Vector3Value" and part.TerrainShape.Value == "HWedge" or part.Name ~= "ClusterChunkPart" and part.ClassName ~= "Vector3Value" and part.TerrainShape.Value == "IWedge" then
			local findabove = part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,4,0)))
			if findabove then
				part.isCovered.Value = true
				assignTextures(part)
			else
				part.isCovered.Value = false
				assignTextures(part)
			end
			if part.TerrainShape.Value ~= "Block" then return end
			local isobscured = true
			local findabove = part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,4,0)))
			if not findabove then  isobscured = false elseif findabove and findabove.TerrainShape.Value ~= "Block" then isobscured = false else
				local findbelow = part.Parent:FindFirstChild(getNameFromPos(part.Position-Vector3.new(0,4,0)))
				if not findbelow then isobscured = false elseif findbelow and findbelow.TerrainShape.Value ~= "Block" then isobscured = false else
					local findx = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(4,0,0)))
					if not findx then isobscured = false elseif findx and findx.TerrainShape.Value ~= "Block" then isobscured = false else
						local findnegx = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(-4,0,0)))
						if not findnegx then isobscured = false elseif findnegx and findnegx.TerrainShape.Value ~= "Block" then isobscured = false else
							local findz = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(0,0,4)))
							if not findz then isobscured = false elseif findz and findz.TerrainShape.Value ~= "Block" then isobscured = false else
								local findnegz = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(0,0,-4)))
								if not findnegz then isobscured = false elseif findnegz and findnegz.TerrainShape.Value ~= "Block" then isobscured = false end
							end
						end
					end
				end
			end
			if isobscured == true then turnPartIntoIntangible(part) end
	elseif part:IsA("Vector3Value") and not part:FindFirstChild("IsClusterChunk") then
		local isobscured = true
		local findabove = part.Parent:FindFirstChild(getNameFromPos(part.Value+Vector3.new(0,4,0)))
		if not findabove then isobscured = false elseif findabove.TerrainShape ~= "Block" then isobscured = false else
			local findbelow = part.Parent:FindFirstChild(getNameFromPos(part.Value-Vector3.new(0,4,0)))
			if not findbelow then isobscured = false elseif findbelow.TerrainShape ~= "Block" then isobscured = false else
				local findx = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Value+Vector3.new(4,0,0)))
				if not findx then isobscured = false elseif findx.TerrainShape ~= "Block" then isobscured = false else
					local findnegx = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Value+Vector3.new(-4,0,0)))
					if not findnegx then isobscured = false elseif findnegx.TerrainShape ~= "Block" then isobscured = false else
						local findz = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Value+Vector3.new(0,0,4)))
						if not findz then isobscured = false elseif findz.TerrainShape ~= "Block" then isobscured = false else
							local findnegz = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Value+Vector3.new(0,0,-4)))
							if not findnegz then isobscured = false elseif findnegz.TerrainShape ~= "Block" then isobscured = false else end
						end
					end
				end
			end
		end
		if isobscured == false then turnIntangibleIntoPart(part) end
	elseif part:IsA("Part") and part.Name == "ClusterChunkPart" then
		splitClusterChunk(part)
	elseif part:IsA("Vector3Value") and part:FindFirstChild("IsClusterChunk") then
		splitClusterChunk(part.IsClusterChunk.Value)
	elseif part:IsA("WedgePart") and part.TerrainShape.Value == "VWedge" then
		local findabove = part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,4,0)+getPositionThingFromRotation(part.Orientation)*4))
		if not findabove then part.isCovered.Value = false assignTextures(part) else part.isCovered.Value = true assignTextures(part) end
		local findbelow = part.Parent:FindFirstChild(getNameFromPos(part.Position-Vector3.new(0,4,0)))
		if findbelow then refreshPartCoverState(findbelow) end
		if blockCascade ~= true then
			local findparts = Instance.new("Part", workspace)
			findparts.Anchored = true
			findparts.Position = part.Position
			findparts.Size = Vector3.new(12,12,12)
			findparts.CanCollide = false
			findparts.Transparency = 1
			local tfindparts = findparts:GetTouchingParts()
			for i = 1, #tfindparts do
				if tfindparts[i]:FindFirstChild("IsTerrain") and tfindparts[i] ~= part then refreshPartCoverState(tfindparts[i], true) end
			end
			findparts:Destroy()
		end
	elseif part:IsA("UnionOperation") and part.TerrainShape.Value == "CWedge" then
		local findabove = part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,4,0)+getPositionThingFromRotationForCWedge(part.Orientation)*4))
		if not findabove then part.isCovered.Value = false assignTextures(part) else part.isCovered.Value = true assignTextures(part) end
		local findbelow = part.Parent:FindFirstChild(getNameFromPos(part.Position-Vector3.new(0,4,0)))
		if findbelow then refreshPartCoverState(findbelow) end
		if blockCascade ~= true then
			local findparts = Instance.new("Part", workspace)
			findparts.Anchored = true
			findparts.Position = part.Position
			findparts.Size = Vector3.new(12,12,12)
			findparts.CanCollide = false
			findparts.Transparency = 1
			local tfindparts = findparts:GetTouchingParts()
			for i = 1, #tfindparts do
				if tfindparts[i]:FindFirstChild("IsTerrain") and tfindparts[i] ~= part then refreshPartCoverState(tfindparts[i], true) end
			end
			findparts:Destroy()
		end
	end
end

function findFirstChildInAdjacentChunks(chunk, search)
	if chunk == nil or search == nil then return end
	local searched = chunk:FindFirstChild(search)
	if searched then return searched end
	local adjchunk = terrainParts:FindFirstChild(chunk.FolderPosition.Value.X+1 ..","..chunk.FolderPosition.Value.Z+1)
	if adjchunk then
		searched = chunk:FindFirstChild(search)
		if searched then return searched end
	end
	local adjchunk = terrainParts:FindFirstChild(chunk.FolderPosition.Value.X-1 ..","..chunk.FolderPosition.Value.Z+1)
	if adjchunk then
		searched = chunk:FindFirstChild(search)
		if searched then return searched end
	end
	local adjchunk = terrainParts:FindFirstChild(chunk.FolderPosition.Value.X+1 ..","..chunk.FolderPosition.Value.Z-1)
	if adjchunk then
		searched = chunk:FindFirstChild(search)
		if searched then return searched end
	end
	local adjchunk = terrainParts:FindFirstChild(chunk.FolderPosition.Value.X-1 ..","..chunk.FolderPosition.Value.Z-1)
	if adjchunk then
		searched = chunk:FindFirstChild(search)
		if searched then return searched end
	end
	return nil 
end

function removePart(part)
	local findabove = part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,4,0)))
	local findbelow = part.Parent:FindFirstChild(getNameFromPos(part.Position+Vector3.new(0,-4,0)))
	local findparts = Instance.new("Part", workspace)
	findparts.Anchored = true
	findparts.CanCollide = false
	findparts.Locked = true
	findparts.Position = part.Position	
	findparts.Size = Vector3.new(12,4,12)
	findparts.Touched:Connect(function()end)
	part:Destroy()
	if findabove then
		refreshPartCoverState(findabove)
	end
	if findbelow then
		refreshPartCoverState(findbelow)
	end
	local founds = findparts:GetTouchingParts()
	for i = 1, #founds do
		if founds[i]:FindFirstChild("IsTerrain") then
			refreshPartCoverState(founds[i])
		end
	end
	findparts:Destroy()
end

--these deal primarily with intangibles

function turnPartIntoIntangible(part,chunk)
	if not part then return end
	local intangible = Instance.new("Vector3Value", part.Parent)
	intangible.Name = part.Name
	intangible.Value = part.Position
	local isCovered = Instance.new("BoolValue", intangible)
	isCovered.Value = part.isCovered.Value
	isCovered.Name = "isCovered"
	local Material = Instance.new("StringValue", intangible)
	Material.Value = part.TerrainMaterial.Value
	Material.Name = "TerrainMaterial"
	local Shape = Instance.new("StringValue", intangible)
	Shape.Value = part.TerrainShape.Value
	Shape.Name = "TerrainShape"
	if chunk ~= nil then
		local link = Instance.new("ObjectValue", chunk.PartsConnection)
		link.Name = intangible.Name
		link.Value = intangible
		local intmarker = Instance.new("ObjectValue",intangible)
		intmarker.Name = "IsClusterChunk"
		intmarker.Value = chunk
	end
	part:Destroy()
end

function turnIntangibleIntoPart(intangible,norefresh)
	if not intangible then return end
		createPart(intangible.Value, intangible.TerrainMaterial.Value,true)
	if intangible then intangible:Destroy() end
end

function createClusterChunk(parts,pos,size,material,covered)
	local clusterchunk = Instance.new("Part", parts[1].Parent)
	clusterchunk.Size = size
	clusterchunk.Position = pos
	clusterchunk.Name = "ClusterChunkPart"
	clusterchunk.Locked = true
	clusterchunk.Anchored = true
	clusterchunk.TopSurface = Enum.SurfaceType.Smooth
	clusterchunk.BottomSurface = Enum.SurfaceType.Smooth
	local tm = Instance.new("StringValue", clusterchunk)
	tm.Value = material
	tm.Name = "TerrainMaterial"
	local cov = Instance.new("BoolValue",clusterchunk)
	cov.Name = "isCovered"
	cov.Value = covered
	local ts = Instance.new("StringValue", clusterchunk)
	ts.Value = "Block"
	ts.Name = "TerrainShape"
	local partsFolder = Instance.new("Folder", clusterchunk)
	partsFolder.Name = "PartsConnection"
	for i = 1,#parts do
	turnPartIntoIntangible(parts[i],clusterchunk)
	end
	assignTextures(clusterchunk)
end

function splitClusterChunk(cChunk, delete)
	if not cChunk:FindFirstChild("PartsConnection") then return end
	if delete then
		if cChunk.PartsConnection:FindFirstChild(delete) then
			if cChunk.PartsConnection[delete].Value then cChunk.PartsConnection[delete].Value:Destroy() end
			cChunk.PartsConnection[delete]:Destroy()
		end
	end
	local intang = cChunk.PartsConnection:GetChildren()
	for i =1, #intang do
		if intang[i].Value then
			turnIntangibleIntoPart(cChunk.Parent:FindFirstChild(intang[i].Name),true)
		end
	end
	cChunk:Destroy()
end

--chunk level functions

function assignChunk(pos)
	local x = nil
	local z = nil
	--define x and z positions
	local fl = math.floor((pos.X+30)/60)
	local cl = math.ceil((pos.X+30)/60)
	--get "fl" (rounded down position) and "cl" (rounded up position)
	local cdif = pos.X/60 - cl
	local fdif = pos.X/60 - fl
	if cdif > fdif then
		x = fl
	else
		x = cl
	end
	--check which is closer to the actual position and assign
	local fl = math.floor((pos.Z+30)/60)
	local cl = math.ceil((pos.Z+30)/60)
	local cdif = pos.Z/60 - cl
	local fdif = pos.Z/60 - fl
	if cdif > fdif then
		z = fl
	else
		z = cl
	end
	--ditto, but for z axis
	local name = x..","..z
	local folder = nil
	--assign name and create folder value
	if not terrainParts:FindFirstChild(name) then
		folder = Instance.new("Folder", terrainParts)
		folder.Name = name
		local pos = Instance.new("Vector3Value", folder)
		pos.Value = Vector3.new(x,0,z)
		pos.Name = "FolderPosition"
	else folder = terrainParts[name] end
	--assign folder
	return folder

end

function clusterChunkOptimization(chunk)
	local tpc = chunk:GetChildren()
	for i = 1, #tpc do
		if tpc[i]:IsA("Part") and tpc[i]:FindFirstChild("TerrainMaterial") and not tpc[i]:FindFirstChild("IsClusterChunk") then
			if tpc[i].TerrainShape.Value == "Block" then
				local findparts = Instance.new("Part", workspace)
				findparts.Size = Vector3.new(28,4,28)
				findparts.Position = tpc[i].Position
				findparts.Anchored = true
				findparts.CanCollide = false
				findparts.Transparency = 1
				findparts.Touched:Connect(function()end)
				local parts = findparts:GetTouchingParts()
				local requirescovered = false
				local actuals = {}
				for ii = 1, #parts do
					if parts[ii].Parent == chunk and parts[ii].Name ~= "ClusterChunkPart" then
						if parts[ii].TerrainMaterial.Value == tpc[i].TerrainMaterial.Value and parts[ii].TerrainShape.Value == "Block" then
							if parts[ii].isCovered.Value == false and requirescovered == false then
								table.insert(actuals,#actuals+1, parts[ii])
							elseif parts[ii].isCovered.Value == true and requirescovered == false then
								actuals = {}
								requirescovered = true
								ii = 1
								table.insert(actuals,#actuals+1, parts[ii])
							elseif parts[ii].isCovered.Value == true and requirescovered == true then
								table.insert(actuals,#actuals+1, parts[ii])
							end
						end
					end
				end
				if #actuals == 49 then
					createClusterChunk(actuals,findparts.Position,findparts.Size,actuals[1].TerrainMaterial.Value, requirescovered)
				end
				findparts:Destroy()
			end
		end
	end
	local tpc = chunk:GetChildren()
	for i = 1, #tpc do
		if tpc[i]:IsA("Part") and tpc[i]:FindFirstChild("TerrainMaterial") and not tpc[i]:FindFirstChild("IsClusterChunk") then
			if tpc[i].TerrainShape == "Block" then
				local findparts = Instance.new("Part", workspace)
				findparts.Size = Vector3.new(20,4,20)
				findparts.Position = tpc[i].Position
				findparts.Anchored = true
				findparts.CanCollide = false
				findparts.Touched:Connect(function()end)
				findparts.Name = "ClusterPart"
				local parts = findparts:GetTouchingParts()
				local requirescovered = false
				local actuals = {}
				for ii = 1, #parts do
					if parts[ii].Parent == chunk and parts[ii].Name ~= "ClusterChunkPart" then
						if parts[ii].TerrainMaterial.Value == tpc[i].TerrainMaterial.Value and parts[ii].TerrainShape.Value == "Block" then
							if parts[ii].isCovered.Value == false and requirescovered == false then
								table.insert(actuals,#actuals+1, parts[ii])
							elseif parts[ii].isCovered.Value == true and requirescovered == false then
								actuals = {}
								requirescovered = true
								ii = 1
								table.insert(actuals,#actuals+1, parts[ii])
							elseif parts[ii].isCovered.Value == true and requirescovered == true then
								table.insert(actuals,#actuals+1, parts[ii])
							end
						end
					end
				end
				if #actuals == 25 then
					createClusterChunk(actuals,findparts.Position,findparts.Size,actuals[1].TerrainMaterial.Value, requirescovered)
				end
				findparts:Destroy()
			end
		end
	end
	local tpc = chunk:GetChildren()
	for i = 1, #tpc do
		if tpc[i]:IsA("Part") and tpc[i]:FindFirstChild("TerrainMaterial") and not tpc[i]:FindFirstChild("IsClusterChunk")then
			if tpc[i].TerrainShape.Value == "Block" then
			local findparts = Instance.new("Part", workspace)
			findparts.Size = Vector3.new(12,4,12)
			findparts.Position = tpc[i].Position
			findparts.Anchored = true
			findparts.Transparency = 1
			findparts.CanCollide = false
			findparts.Touched:Connect(function()end)
			findparts.Name = "ClusterPart"
			local parts = findparts:GetTouchingParts()
			local requirescovered = false
			local actuals = {}
			for ii = 1, #parts do
				if parts[ii].Parent == chunk and parts[ii].Name ~= "ClusterChunkPart"  and parts[ii].TerrainShape.Value == "Block"  then
					if parts[ii].TerrainMaterial.Value == tpc[i].TerrainMaterial.Value then
						if parts[ii].isCovered.Value == false and requirescovered == false then
							table.insert(actuals,#actuals+1, parts[ii])
						elseif parts[ii].isCovered.Value == true and requirescovered == false then
							actuals = {}
							requirescovered = true
							ii = 1
							table.insert(actuals,#actuals+1, parts[ii])
						elseif parts[ii].isCovered.Value == true and requirescovered == true then
							table.insert(actuals,#actuals+1, parts[ii])
						end
					end
				end
			end
			if #actuals == 9 then
				createClusterChunk(actuals,findparts.Position,findparts.Size,actuals[1].TerrainMaterial.Value, requirescovered)
			end
			findparts:Destroy()
			end
		end
	end
end

function doExplosion(rays,passes,pos,range)
	local restrict = {}
	for i = 1, rays do
		local ray = Ray.new(pos, Vector3.new(math.random(-500,500.01),math.random(-500,500.01),math.random(-500,500.01)))
		
		for i = 1, passes do
			local part, hitpos = workspace:FindPartOnRay(ray, script.Parent)
			if part then 
				if part:FindFirstChild("IsTerrain") and part.Name ~= "ClusterChunkPart" and (part.Position - pos).magnitude <= range then 
				table.insert(restrict, part.Position)
				removePart(part) 
				elseif part:FindFirstChild("PartsConnection") and part.Name == "ClusterChunkPart" then
				splitClusterChunk(part)
				i = i-1
				end
			end
		end
	end
	local autowedgesphere = Instance.new("Part", workspace)
	autowedgesphere.Position = pos
	autowedgesphere.Anchored = true
	autowedgesphere.Size = Vector3.new(range,range,range)
	autowedgesphere.Transparency = 1
	autowedgesphere.CanCollide = false
	autowedgesphere.Touched:Connect(function()end)
	local tp = autowedgesphere:GetTouchingParts()
	for i = 1, #tp do
		if tp[i]:FindFirstChild("IsTerrain") and tp[i].Name ~= "ClusterChunkPart" then
			if tp[i].TerrainShape.Value == "Block" then
				autoWedgePart(tp[i], restrict)
			end
		end
	end
	for i = 1, #tp do
		if tp[i]:FindFirstChild("IsTerrain") then
			refreshPartCoverState(tp[i])
		end
	end
	autowedgesphere:Destroy()
end

function calculateInverseWedge(rot1,rot2)
	if rot1 == Vector3.new(0,0,0) and rot2 == Vector3.new(0,-90,0) or rot1 == Vector3.new(0,-90,0) and rot2 == Vector3.new(0,0,0) then
		return Vector3.new(0,0,0)
	end
	if rot1 == Vector3.new(0,0,0) and rot2 == Vector3.new(0,90,0) or rot1 == Vector3.new(0,90,0) and rot2 == Vector3.new(0,0,0) then
		return Vector3.new(0,90,0)
	end
	if rot1 == Vector3.new(0,90,0) and rot2 == Vector3.new(0,180,0) or rot1 == Vector3.new(0,180,0) and rot2 == Vector3.new(0,90,0) then
		return Vector3.new(0,180,0)
	end
	if rot1 == Vector3.new(0,180,0) and rot2 == Vector3.new(0,-90,0) or rot1 == Vector3.new(0,-90,0) and rot2 == Vector3.new(0,180,0) then
		return Vector3.new(0,-90,0)
	end
	return nil
 end

function autoWedgePart(part, restrictTo)
	
	if not part:FindFirstChild("IsTerrain") then return end
	if not part:FindFirstChild("TerrainMaterial") then return end
	
	--wedges
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(0,0,-4)) or not restrictTo then
		local findblocker = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(0,0,-4)))
		if not findblocker then
			createVerticalWedge(part.Position+Vector3.new(0,0,-4), part.TerrainMaterial.Value, Vector3.new(0,0,0),true)
		end
		if findblocker and findblocker:FindFirstChild("TerrainShape") then
			if findblocker.TerrainShape.Value == "CWedge" then
				createVerticalWedge(part.Position+Vector3.new(0,0,-4), part.TerrainMaterial.Value, Vector3.new(0,0,0), true)
			elseif findblocker.TerrainShape.Value == "VWedge" then
				if calculateInverseWedge(Vector3.new(0,0,0),findblocker.Orientation) ~= nil then
				createInverseWedge(part.Position+Vector3.new(0,0,-4), part.TerrainMaterial.Value, calculateInverseWedge(Vector3.new(0,0,0),findblocker.Orientation))
				else
				createPart(part.Position+Vector3.new(0,0,-4), part.TerrainMaterial.Value)
				end
			end
		end
	end
	
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(0,0,4)) or not restrictTo then
		local findblocker = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(0,0,4)))
		if not findblocker then
			createVerticalWedge(part.Position+Vector3.new(0,0,4), part.TerrainMaterial.Value, Vector3.new(0,180,0),true)
		end
		if findblocker and findblocker:FindFirstChild("TerrainShape") then
			if findblocker.TerrainShape.Value == "CWedge" then
				createVerticalWedge(part.Position+Vector3.new(0,0,4), part.TerrainMaterial.Value, Vector3.new(0,180,0),true)
			elseif findblocker.TerrainShape.Value == "VWedge" then
				if calculateInverseWedge(Vector3.new(0,180,0),findblocker.Orientation) ~= nil then
				createInverseWedge(part.Position+Vector3.new(0,0,4), part.TerrainMaterial.Value, calculateInverseWedge(Vector3.new(0,180,0),findblocker.Orientation))
				else
				createPart(part.Position+Vector3.new(0,0,4), part.TerrainMaterial.Value)
				end
			end
		end
	end
	
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(-4,0,0)) or not restrictTo then
		local findblocker = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(-4,0,0)))
		if not findblocker then
			createVerticalWedge(part.Position+Vector3.new(-4,0,0), part.TerrainMaterial.Value, Vector3.new(0,90,0),true)
		end
		if findblocker and findblocker:FindFirstChild("TerrainShape") then
			if findblocker.TerrainShape.Value == "CWedge" then
				createVerticalWedge(part.Position+Vector3.new(-4,0,0), part.TerrainMaterial.Value, Vector3.new(0,90,0),true)
			elseif findblocker.TerrainShape.Value == "VWedge" then
				if calculateInverseWedge(Vector3.new(0,90,0),findblocker.Orientation) ~= nil then
				createInverseWedge(part.Position+Vector3.new(-4,0,0), part.TerrainMaterial.Value, calculateInverseWedge(Vector3.new(0,90,0),findblocker.Orientation))
				else
				createPart(part.Position+Vector3.new(-4,0,0), part.TerrainMaterial.Value)	
				end
			end
		end
	end
	
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(4,0,0)) or not restrictTo then
		local findblocker = findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(4,0,0)))
		if not findblocker then
			createVerticalWedge(part.Position+Vector3.new(4,0,0), part.TerrainMaterial.Value, Vector3.new(0,-90,0),true)
		end
		if findblocker and findblocker:FindFirstChild("TerrainShape") then
			if findblocker.TerrainShape.Value == "CWedge" then
				createVerticalWedge(part.Position+Vector3.new(4,0,0), part.TerrainMaterial.Value, Vector3.new(0,-90,0),true)
			elseif findblocker.TerrainShape.Value == "VWedge" then
				if calculateInverseWedge(Vector3.new(0,-90,0),findblocker.Orientation) ~= nil then
				createInverseWedge(part.Position+Vector3.new(4,0,0), part.TerrainMaterial.Value, calculateInverseWedge(Vector3.new(0,-90,0),findblocker.Orientation))
				else
				createPart(part.Position+Vector3.new(4,0,0), part.TerrainMaterial.Value)	
				end
			end
		end
	end
	
	--cornerwedges
	if not part:FindFirstChild("TerrainMaterial") then return end
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(-4,0,-4)) or not restrictTo then
		if not findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(-4,0,-4))) then
			createCornerWedge(part.Position+Vector3.new(-4,0,-4), part.TerrainMaterial.Value, Vector3.new(0,0,0),true)
		end
	end
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(4,0,4)) or not restrictTo then
		if not findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(4,0,4))) then
			createCornerWedge(part.Position+Vector3.new(4,0,4), part.TerrainMaterial.Value, Vector3.new(0,180,0),true)
		end
	end
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(-4,0,4)) or not restrictTo then
		if not findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(-4,0,4))) then
			createCornerWedge(part.Position+Vector3.new(-4,0,4), part.TerrainMaterial.Value, Vector3.new(0,90,0),true)
		end
	end
	if restrictTo and table.find(restrictTo, part.Position+Vector3.new(4,0,-4)) or not restrictTo then
		if not findFirstChildInAdjacentChunks(part.Parent, getNameFromPos(part.Position+Vector3.new(4,0,-4))) then
			createCornerWedge(part.Position+Vector3.new(4,0,-4), part.TerrainMaterial.Value, Vector3.new(0,-90,0),true)
		end
	end
end

workspace.ChildAdded:Connect(function(child)
	if child.ClassName ~= "Explosion" then return end
	if child.ExplosionType ~= Enum.ExplosionType.Craters then return end
	doExplosion(child.BlastRadius*2, 2, child.Position, child.BlastRadius)
end)

script.PlaceTerrainBlock.Event:Connect(function(mat,pos)
	createPart(pos,mat)
end)

script.DeleteBlock.Event:Connect(function(block)
	removePart(block)
end)

script.SplitChunk.Event:Connect(function(cChunk, delete) 
	splitClusterChunk(cChunk, delete) 
end)

script.PlaceTerrainVRamp.Event:Connect(function(mat,pos,rot)
	createVerticalWedge(pos,mat,rot)
end)

script.PlaceTerrainIRamp.Event:Connect(function(mat,pos,rot)
	createInverseWedge(pos,mat,rot)
end)

script.PlaceTerrainCRamp.Event:Connect(function(mat,pos,rot)
	createCornerWedge(pos,mat,rot)
end)

script.PlaceTerrainHRamp.Event:Connect(function(mat,pos,rot)
	createHorizWedge(pos,mat,rot)
end)


while true do
	wait(10)
	local chunks = terrainParts:GetChildren()
	for i = 1, #chunks do
		wait(1)
		clusterChunkOptimization(chunks[i])
	end
end

