local ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('garage:getVehiclesInParkingLot', function(source, cb, parkingLot)
  local xPlayer = ESX.GetPlayerFromId(source)
  -- print(json.encode(xPlayer, {indent=true}))
    local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? AND parkinglot = ?", {xPlayer.identifier, parkingLot})
    cb(vehicles)
end)

RegisterNetEvent("garage:parkVehicle", function(vehicle, vehicleData, parkingLot, parkingSpace)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local plate = vehicleData.plate

  MySQL.update("UPDATE owned_vehicles SET vehicle = ?, parkinglot = ?, parkingspace = ? WHERE owner = ? AND plate = ?", {
    json.encode(vehicleData, {indent=true}), parkingLot, parkingSpace, xPlayer.identifier, plate
  })
end)