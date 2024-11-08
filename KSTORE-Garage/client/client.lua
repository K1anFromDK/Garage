local ESX = exports["es_extended"]:getSharedObject()
local spawnedvehicle = false
local parkCommandFunction = nil
local PlayerPed = PlayerPedId()

CreateThread(function()
    for garageName, garage in pairs(Config.Garages) do
        RequestModel('s_m_m_doctor_01')
        while not HasModelLoaded('s_m_m_doctor_01') do
            Wait(1)
        end
        local ped = CreatePed(4, 's_m_m_doctor_01', garage.pedLocation, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        exports.ox_target:addLocalEntity(ped, {
            {
                label = garage.label,
                name = garageName,
                icon = "fa-solid fa-car",
                onSelect = function()
                    OpenGarage(garageName, garage)
                end,
                distance = 3.0
            }
        })
    end
end)

function OpenGarage(garageName, garage)
    ESX.TriggerServerCallback('garage:getVehiclesInParkingLot', function(vehicles)
        if not vehicles or not next(vehicles) then return TriggerEvent('ox_lib:notify', { title = 'Du har ikke en bil i denne garage', type = 'error', position = 'top'}) end

        local options = {}

        for k, vehicle in ipairs(vehicles) do
            local vehicleData = json.decode(vehicle.vehicle)
            local vehicleName = GetDisplayNameFromVehicleModel(vehicleData.model)

            options[#options + 1] = {
                title = vehicleName,
                icon = "fa-solid fa-car",
                colorScheme = 'blue',
                description =  'Nummerplade ' ..vehicleData.plate.. '. benzin ' ..vehicleData.fuelLevel.. '%',
                metadata = {
                    {
                        label = 'Krops liv',
                        progress = vehicleData.bodyHealth/10,
                    },
                    {
                        label = 'Bil parkerings info: ' ..vehicle.parkinglot
                    },
                    {
                        label = 'Bås. '.. vehicle.parkingspace
                    }
                },
               -- progress = vehicleData.tankHealth/10,
                onSelect = function()
                    if spawnedvehicle then
                        TriggerEvent('ox_lib:notify', { title = 'Du har en bil ude!', type = 'error', position = 'top'})
                    elseif not spawnedvehicle then
                        SpawnVehicleInParkingLot(vehicle.parkinglot, vehicle.parkingspace, vehicleData.model, vehicleData)
                        TaskWarpPedIntoVehicle(PlayerPedId(), vehicleName, -1)
                        TriggerEvent('ox_lib:notify', { title = 'Din ' ..vehicleName.. ' er spawnet', type = 'success', position = 'top'})
                        spawnedvehicle = true
                        else
                            lib.notify({description = 'Der er fejl i scriptet', type = 'error'})
                    end
            end
            }
        end

        lib.registerContext({
            id = 'garage_menu',
            title = garageName,
            menu = 'garage_menu',
            options = options
          })
         
          lib.showContext('garage_menu')
    end, garageName)
end

        -- local vehicleData = json.decode(vehicles[1].vehicle)
        

        -- SpawnVehicleInParkingLot(garageName, math.random(1, 5), vehicleData.model, vehicleData)

function SpawnVehicleInParkingLot(parkingLot, parkingSpace, vehicle, data)
    local coords = Config.Garages[parkingLot].parkingSpaces[parkingSpace]
    ESX.Game.SpawnVehicle(vehicle, coords.xyz, coords.w, function(vehEntity)
        ESX.Game.SetVehicleProperties(vehEntity, data)
    end)
end

function ParkVehicle(garageName, parkingSpace)
    local coords = GetEntityCoords(PlayerPedId())
    local parkingSpace = parkingSpace
    -- local parkingSpace = GetClosestParkingSpace(coords, garageName)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())

    if not DoesEntityExist(vehicle) then return end

    TriggerServerEvent("garage:parkVehicle", vehicle, ESX.Game.GetVehicleProperties(vehicle), garageName, parkingSpace)

    DeleteEntity(vehicle)
    spawnedvehicle = false
end


-- function GetClosestParkingSpace(coords, garageName)
--     local closestSpace = nil
--     local minDistance = math.huge

--     for k, spaceCoords in pairs(Config.Garages[garageName].parkingSpaces) do
--         local distance = #(coords - spaceCoords)

--         if distance < minDistance then
--             minDistance = distance
--             closestSpace = k
--         end
--     end

--     return closestSpace
-- end


CreateThread(function()
    for garageName,garage in pairs(Config.Garages) do
        for parkingSpace, coords in ipairs(garage.parkingSpaces) do
                BoxZone:Create(coords.xyz, 3.0, 5.0, {
                name= garageName.. '_' .. parkingSpace,
                heading = coords.w + 90,
                offset={0.0, 0.0, 0.0},
                scale={1.0, 1.0, 1.0},
                debugPoly=true,
            }):onPlayerInOut(function(isPointInside,point)
                -- isInParkingSpace = isPointInside
                if isPointInside and IsPedInAnyVehicle(PlayerPedId()) then
                    parkCommandFunction = function()
                        ParkVehicle(garageName, parkingSpace)
                    end
                    lib.showTextUI('[E] - Parker køretøj')
                else
                    parkCommandFunction = nil
                    lib.hideTextUI()
                end
            end)
        end
    end
end)

RegisterCommand("parkvehicle", function()
    if parkCommandFunction then
        parkCommandFunction()
    end
end)

RegisterKeyMapping("parkvehicle", "Parkerer dit køretøj ved en parkeringsplads", "keyboard", "E")
