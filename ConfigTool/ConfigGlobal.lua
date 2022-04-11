script.UpdateValue.OnServerEvent:Connect(function(plr, val, new, vsp)
	
	if val.Value or val.ClassName == "BoolValue" then
		if val:IsA("StringValue") then
			local TextService = game:GetService("TextService")
	    	local filteredText = ""
			local filteredTextResult = nil
	    	local success, errorMessage = pcall(function()
	    		filteredTextResult = TextService:FilterStringAsync(new, plr.UserId)
	    	end)
	    	if not success then
	    		warn("Error filtering text:", new, ":", errorMessage)
	    		filteredTextResult = nil
	    	end
			if filteredTextResult ~= nil then
				new = filteredTextResult:GetNonChatStringForBroadcastAsync()
				val.Value = new
			end
		else
		val.Value = new
	end
	elseif vsp ~= nil then
		if val == "MaxSpeed" then
			vsp.MaxSpeed = new
		elseif val == "Torque" then
			vsp.Torque = new
		elseif val == "Steer" then
			vsp.Steer = new
		elseif val == "TurnSpeed" then
			vsp.TurnSpeed = new
		end
	end
end)
