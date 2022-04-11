function onWire(player, sink, source)
	sink.Source = source
end

script.Wire.OnServerEvent:Connect(onWire)
