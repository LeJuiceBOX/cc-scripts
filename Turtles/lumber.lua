
local SEPERATOR = "======================================="
local SLOT_SAPLINGS = 1;
local SLOT_FERTILIZER = 2; 
local SLOT_LOGS = 3; 


local inStorage = true;
local loopFarmTrees = false;
local treesToFarm, logName, sapName = -1, "minecraft:oak_log", "minecraft:oak_sapling";
local yLevel = 0;
local treesFarmed = 1
local fertUsed = 0

--====================================================================================================================================
--// Core Functions
--====================================================================================================================================

function Run()
    untilSuccess(GetInstructions)
    pitStop()
    loopFarmTrees = true
    while loopFarmTrees do
        growTree()
        chopTree()
        treesFarmed=treesFarmed+1;
        pitStop()
        if tonumber(treesToFarm) > 0 and treesFarmed >= tonumber(treesToFarm) then break; end
    end
    pitStop()
    turtle.down()
end

function GetInstructions()
    shell.run("clear");
    print(SEPERATOR)
    print("How many trees to farm? (-1 to go forever)")
    treesToFarm = io.read()
    print("What is the log name? ( ex. oak_log ('minecraft:oak_log') )")
    logName = io.read()
    print("What is the sapling name? ( ex. minecraft:oak_sapling )")
    sapName = io.read()
    print(SEPERATOR)
    return true;
end

--====================================================================================================================================
--// Utility Functions
--====================================================================================================================================

function untilSuccess(func,...)
    local s = false
    repeat s = func(...); until s;
end

function doesntEqual(val,...)
    for i,v in pairs({...}) do if val == v then return false; end end
    return true;
end

function growTree()
    turtle.select(SLOT_SAPLINGS)
    turtle.place()
    turtle.select(SLOT_FERTILIZER)
    while true do
        --// did tree grow?
        local success, data = turtle.inspect()
        if success and data and string.find(data.name,logName) then break; end
        --// use fertilizer
        turtle.select(SLOT_FERTILIZER)
        local fertPlaced = turtle.place()
        if fertPlaced then fertUsed = fertUsed + 1; end
    end
end

function chopTree()
    turtle.select(SLOT_LOGS)
    turtle.dig();
    turtle.forward();
    while true do
        local success, data = turtle.inspectUp()
        if success and data and not string.find(data.name,logName) then break; end
        turtle.digUp()
        turtle.up()
        yLevel=yLevel+1;
    end
    for i = yLevel, 1, -1 do
        repeat turtle.digDown() until turtle.down();
    end
    turtle.back()
    yLevel = 0;
end

function pitStop()
    turtle.down()
    restock()
    deposit()
    turtle.up()
end

-- right: saplings, left: fertilizer, back: logs
function deposit()
    turtle.select(SLOT_LOGS); 
    turtle.dropDown();
    updateDisplay()
end

function restock()
    --// grab fertilizer
    turtle.turnLeft()
    turtle.select(SLOT_FERTILIZER)
    local fSuc = turtle.suck(turtle.getItemSpace(SLOT_FERTILIZER));
    --// grab saplings
    turtle.turnLeft()
    turtle.turnLeft()

    repeat
        turtle.select(SLOT_SAPLINGS)
        local sSuc = turtle.suck(turtle.getItemSpace(SLOT_SAPLINGS));
    until isSapling()

    turtle.turnLeft()
    updateDisplay()
    if turtle.getItemCount(SLOT_FERTILIZER) < 1 or turtle.getItemCount(SLOT_SAPLINGS) < 1  then print("Not enough resources.") return false; end
    return true;
end

function isSapling()
    local data = turtle.getItemDetail(i)
    if data and data.name ~= sapName then turtle.select(SLOT_SAPLINGS); turtle.dropDown(); return false; end
    return true;
end

function writeTable(monitor,t,x,y)
    for i,v in pairs(t) do
        monitor.setCursorPos(x,y+(i-1))
        monitor.write(tostring(v))
    end
end

function updateDisplay()
    local monitor = peripheral.wrap("back")
    if not monitor then return; end
    local w,h = monitor.getSize()
    local lines = {
        "LUMBER TURTLE STATUS",SEPERATOR,
        "Trees: "..treesFarmed.." / "..tonumber(treesToFarm),
        "Fert: "..fertUsed,
        "Fuel: "..math.floor((turtle.getFuelLevel()/turtle.getFuelLimit())*100).."% ( "..(turtle.getFuelLevel()/1000).."k / "..(turtle.getFuelLimit()/1000).."k )",
    }
    monitor.clear()
    writeTable(monitor,lines,1,1)
end

Run()