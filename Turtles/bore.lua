local SEPERATOR = "======================================="
local MINECRAFT_CHEST = "minecraft:chest"

local instructions = "";
local wc,hc,dc = false, false, false;
local movingRight = true;
local boreWidth, boreHeight, boreDepth, depositInterval = -1, -1, -1;
local layersMined;

--====================================================================================================================================
--// Core Functions
--====================================================================================================================================

function GetInstructions()
    shell.run("clear");
    local success, data = turtle.inspectDown()
    if not success or success and data.name ~= MINECRAFT_CHEST then print("Put a default chest below the turtle to collect items."); pause(); return false; end
    print(SEPERATOR)
    print("Enter Instructions:")
    print("[list: width, height, depth, deposit interval]")
    boreWidth = io.read()
    boreHeight = io.read()
    boreDepth = io.read()
    depositInterval = io.read()
    if string.find(string.lower(boreWidth),"c") then boreWidth = getNumber(boreWidth)*16; end
    if string.find(string.lower(boreHeight),"c") then boreHeight = getNumber(boreHeight)*16; end
    if string.find(string.lower(boreDepth),"c") then boreDepth = getNumber(boreDepth)*16; end
    print(SEPERATOR)
    --// Get and set input data
    --if type(boreWidth) ~= 'number' or type(boreHeight) ~= 'number' or type(boreDepth) ~= 'number' then return false; end
    return true;
end

function Start()
    untilSuccess(GetInstructions)
    Run()
end

function Run()
    layersMined = 0;
    print("Mining in progress... ("..layersMined.." / "..boreDepth..")")
    local layersSinceDeposit = 0
    updateDisplay();
    for i = 1, tonumber(boreDepth) do
        MineLayer()
        layersMined = layersMined + 1;
        layersSinceDeposit = layersSinceDeposit + 1;
        if layersSinceDeposit >= tonumber(depositInterval) then 
            ReturnToOrigin();
            if i ~= tonumber(boreDepth) then Repeat(layersMined,Dig); end
            layersSinceDeposit = 0
        end
        print("Mining in progress... ("..layersMined.." / "..boreDepth..")")
    end
    print(layersSinceDeposit)
    if layersSinceDeposit ~= 0 then ReturnToOrigin(); end
    print("End")
end

function MineLayer()
    Dig();
    turtle.turnRight();
    movingRight = true;
    -- up, then turn around
    for i = 1, boreHeight do -- assuming we are looking where we wanna go
        Repeat(boreWidth-1,Dig) -- mine row
        Repeat(2,turtle.turnLeft)
        if i < tonumber(boreHeight) then repeat turtle.digUp() until turtle.up(); movingRight = not movingRight; end
    end
    Repeat(boreHeight-1,DigDown)
    if movingRight then Repeat(boreWidth-1,Dig); turtle.turnRight(); else turtle.turnLeft(); end
end

--====================================================================================================================================
--// Utility Functions
--====================================================================================================================================

function ReturnToOrigin()
    Repeat(2,turtle.turnRight)
    Repeat(layersMined,Dig)
    Repeat(2,turtle.turnRight)
    updateDisplay()
    for i = 1, 16 do turtle.select(i); turtle.dropDown(); end
    turtle.select(1);
end

function MineRow()
    Repeat(boreWidth-1,Dig) -- mine row
end

function Dig()
    repeat turtle.dig() until turtle.forward();
end

function DigDown()
    repeat turtle.digDown() until turtle.down();
end

function Repeat(times,func,args)
    args = args or {nil}
    for i = 1, times, 1 do func(unpack(args)); end
end

function RepeatUntil(cond,func,args)
    args = args or {nil}
    repeat func(unpack(args)); until cond;
end

function pause() 
    print("\nPress ENTER to continue..."); 
    local pX,pY = term.getCursorPos()
    term.setCursorPos(0,-3);
    io.read(); 
    term.setCursorPos(pX,pY)
end

function getNumber(str) 
    local num = string.gsub(str, "%D+", ""); 
    return tonumber(num); 
end

function untilSuccess(func,...)
    local s = false
    repeat s = func(...); until s;
end

function writeTable(monitor,t,x,y)
    for i,v in pairs(t) do
        monitor.setCursorPos(x,y+(i-1))
        monitor.write(tostring(v))
    end
end

function updateDisplay()
    local monitor = peripheral.wrap("right")
    if not monitor then return; end
    local w,h = monitor.getSize()
    local lines = {
        SEPERATOR,"TURTLE STATUS",SEPERATOR,
        "Progress: "..layersMined.." / "..boreDepth,
        "Fuel: "..math.floor((turtle.getFuelLevel()/turtle.getFuelLimit())*100).."% ( "..(turtle.getFuelLevel()/1000).."k / "..(turtle.getFuelLimit()/1000).."k )",
    }
    monitor.clear()
    writeTable(monitor,lines,1,1)
end


Start();
