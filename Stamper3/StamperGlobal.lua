
function onPlace(user, part, position, xr, yr, zr, target, ismodel)
	if not part:FindFirstChild("IsTerrain") then
		local placedPart = part:Clone()
		placedPart.Parent = workspace
		if ismodel == true then
			placedPart:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(math.rad(xr), math.rad(yr), math.rad(zr)))
			placedPart:MakeJoints()
			workspace:JoinToOutsiders(placedPart:GetChildren(), Enum.JointCreationMode.All)
		elseif ismodel == false then
		placedPart.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(xr), math.rad(yr), math.rad(zr))
		placedPart:MakeJoints()
		workspace:JoinToOutsiders({placedPart}, Enum.JointCreationMode.All)
		end
		if part:FindFirstChild("PlayerIdTag") then part.PlayerIdTag.Value = user.UserId end
		if part:FindFirstChild("PlayerNameTag") then part.PlayerIdTag.Value = user.Name end
		if part:FindFirstChild("StamperFloorRemover") then
			placedPart.StamperFloorRemover.Disabled = false
		end
		if part:FindFirstChild("ElevatorScript") then
			placedPart.ElevatorScript.Disabled = false
		end
		if part.Name == "Smashy" then
			placedPart.Smasher.BodyPosition.Position = placedPart.Smashy.Position
		end
	else
		if part.PrimaryPart.ClassName == "Part" then
		game.ServerScriptService.LegacyTerrainManager.PlaceTerrainBlock:Fire(part.Name, position)
		elseif part.PrimaryPart.ClassName == "WedgePart" and not part:FindFirstChild("wedge") then
		if not part:FindFirstChild("IsInverse") then
		game.ServerScriptService.LegacyTerrainManager.PlaceTerrainVRamp:Fire(part.Name, position, Vector3.new(0,yr,0))
		else
		game.ServerScriptService.LegacyTerrainManager.PlaceTerrainIRamp:Fire(part.Name, position, Vector3.new(0,yr,0))
		end
		elseif part.PrimaryPart.ClassName == "CornerWedgePart" then
		game.ServerScriptService.LegacyTerrainManager.PlaceTerrainCRamp:Fire(part.Name, position, Vector3.new(0,yr,0)+Vector3.new(0,90,0))
		elseif part:FindFirstChild("wedge") then
		game.ServerScriptService.LegacyTerrainManager.PlaceTerrainHRamp:Fire(part.Name, position, Vector3.new(0,yr,0))
		end
	end
end

script.PlacePart.OnServerEvent:Connect(onPlace)
