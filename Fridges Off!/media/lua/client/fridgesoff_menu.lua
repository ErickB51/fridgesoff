---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Erick.
--- DateTime: 24/08/2022 16:34
---

---@class ISToggleFridgesFreezers : ISBaseTimedAction
ISToggleFridgesFreezers = ISBaseTimedAction:derive("ISToggleFridgesFreezers");

function ISToggleFridgesFreezers:isValid()
    return true
end

function ISToggleFridgesFreezers:update()
end

function ISToggleFridgesFreezers:start()
    self.character:faceThisObject(self.object)
end

function ISToggleFridgesFreezers:stop()
    ISBaseTimedAction.stop(self)
end

function ISToggleFridgesFreezers:perform()
    if self.state == 0 then
        if self.object:getContainerByType("fridge") ~= nil then
            self.object:getContainerByType("fridge"):setType("fridge_off")
        end
        if self.object:getContainerByType("freezer") ~= nil then
            self.object:getContainerByType("freezer"):setType("freezer_off")
        end
    else
        if self.object:getContainerByType("fridge_off") ~= nil then
            self.object:getContainerByType("fridge_off"):setType("fridge")
        end
        if self.object:getContainerByType("freezer_off") ~= nil then
            self.object:getContainerByType("freezer_off"):setType("freezer")
        end
    end
    updateGenerators(self.object:getContainer():getSourceGrid():getX(),self.object:getContainer():getSourceGrid():getY(),self.object:getContainer():getSourceGrid():getZ())
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISToggleFridgesFreezers:new(objPlayer, state, obj)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = objPlayer
    o.stopOnWalk = false
    o.stopOnRun = false
    o.maxTime = 0
    -- custom fields
    o.object = obj
    o.state = state
    return o
end

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

---@param player IsoPlayer
---@param context KahluaTable
---@param worldObjects KahluaTable
---@param _ Boolean
local function customizedContextMenu(player, context, worldObjects, _)

    local objectPlayer = getSpecificPlayer(player)

    if objectPlayer:isAsleep() then
        return
    end

    ---@param objPlayer IsoPlayer
    ---@param state Integer
    ---@param o IsoObject
    local changeFridgeFreezerState = function(_,objPlayer,state,o)
        if luautils.walkAdj(objPlayer, o:getSquare()) then
            ISTimedActionQueue.add(ISToggleFridgesFreezers:new(objPlayer, state, o))
        end
    end

    ---@type IsoObject
    local actualObject = worldObjects[1]
    if actualObject then
        local containerCount = actualObject:getContainerCount()
        if containerCount > 0 then
            local containerType = actualObject:getContainer():getType()
            if containerType == "fridge" or containerType == "freezer" then
                context:addOptionOnTop(getText("Turn Off"), worldObjects, changeFridgeFreezerState, objectPlayer, 0, actualObject)
            end
            if containerType == "fridge_off" or containerType == "freezer_off" then
                context:addOptionOnTop(getText("Turn On"), worldObjects, changeFridgeFreezerState, objectPlayer, 1, actualObject)
            end
        end
    end
end

local function loadNewIcons()
    ---@type Texture
    local textureFridgeOff = getTexture("media/ui/Container_FridgeOff.png")
    ---@type Texture
    local textureFreezerOff = getTexture("media/ui/Container_FreezerOff.png")
    ContainerButtonIcons.fridge_off = textureFridgeOff
    ContainerButtonIcons.freezer_off = textureFreezerOff
end

Events.OnGameBoot.Add(loadNewIcons)
Events.OnPreFillWorldObjectContextMenu.Add(customizedContextMenu)