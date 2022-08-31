---if isClient() then return end

---@param cX Integer
---@param cY Integer
---@param cZ Integer
function updateGenerators(cX, cY, cZ)
    local minX = cX - 20
    local maxX = cX + 20
    local minY = cY - 20
    local maxY = cY + 20
    local tempCZ = cZ
    local minZ = Math.max(0, tempCZ - 3)
    local maxZ = Math.min(8, tempCZ + 3)
    for gZ=minZ,maxZ-1,1 do
        for gX=minX,maxX,1 do
            for gY=minY,maxY,1 do
                local utility = IsoUtils.DistanceToSquared(gX+.5,gY+.5,cX+.5,cY+.5)
                if utility <= 400.0 then
                    local actualCell = getWorld():getCell()
                    local actualSquare = actualCell:getGridSquare(gX,gY,gZ)
                    if actualSquare ~= nil then
                        for i=0,actualSquare:getObjects():size()-1,1 do
                            ---@type IsoObject
                            local actualObject = actualSquare:getObjects():get(i)
                            if actualObject ~= nil and instanceof(actualObject,"IsoGenerator") then
                                ---@type IsoGenerator
                                actualObject:setSurroundingElectricity()
                            end
                        end
                    end
                end
            end
        end
    end
end

---@param module String
---@param command String
---@param player IsoPlayer
---@param args KahluaTable
local function onClientCommand(module,command,player,args)

    if module == "fridges-off" then

        local objects = getWorld():getCell():getGridSquare(args.x,args.y,args.z):getObjects()

        ---@type IsoObject
        local object

        for i=0,objects:size()-1,1 do
            if objects:get(i):getContainerCount() > 0 then
                if objects:get(i):getContainerByEitherType("fridge","freezer") or objects:get(i):getContainerByEitherType("fridge_off","freezer_off") then
                    object = objects:get(i)
                    break
                end
            end
        end

        if object ~= nil then

            if command == "on" then

                if object:getContainerByType("fridge_off") ~= nil then
                    object:getContainerByType("fridge_off"):setType("fridge")
                end

                if object:getContainerByType("freezer_off") ~= nil then
                    object:getContainerByType("freezer_off"):setType("freezer")
                end

            end

            if command == "off" then

                if object:getContainerByType("fridge") ~= nil then
                    object:getContainerByType("fridge"):setType("fridge_off")
                end

                if object:getContainerByType("freezer") ~= nil then
                    object:getContainerByType("freezer"):setType("freezer_off")
                end

            end

            updateGenerators(object:getContainer():getSourceGrid():getX(),object:getContainer():getSourceGrid():getY(),object:getContainer():getSourceGrid():getZ())

            local fridge
            local freezer

            if object:getContainerByType("fridge") ~= nil then
                fridge = "on"
            else
                if object:getContainerByType("fridge_off") ~= nil then
                    fridge = "off"
                else
                    fridge = "empty"
                end
            end

            if object:getContainerByType("freezer") ~= nil then
                freezer = "on"
            else
                if object:getContainerByType("freezer_off") ~= nil then
                    freezer = "off"
                else
                    freezer = "empty"
                end
            end

            sendServerCommand("fridges-off","sync",{x=args.x,y=args.y,z=args.z,fridge=fridge,freezer=freezer})

        end

    end

end

Events.OnClientCommand.Add(onClientCommand)