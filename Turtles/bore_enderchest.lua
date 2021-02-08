local SEPERATOR = "======================================="
local BLACKLIST_FILENAME = "bore_blacklist"
local CHEST_NAME = "enderstorage:ender_chest"
local CHEST_SLOT = 16

local blacklist = nil

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
    --// check for enderchest
    local data = turtle.getItemDetail(CHEST_SLOT)
    if data == nil or (data and data.name ~= CHEST_NAME) then print("Put an ENDER CHEST in the bottom right slot before continuing."); pause(); return false; end
    --// collect arguments from user
    print(SEPERATOR)
    print("Enter Instructions:")
    print("[list: width, height, depth, deposit interval]")
    boreWidth = io.read()
    boreHeight = io.read()
    boreDepth = io.read()
    depositInterval = io.read()
    --// parse data
    if string.find(string.lower(boreWidth),"c") then boreWidth = getNumber(boreWidth)*16; end
    if string.find(string.lower(boreHeight),"c") then boreHeight = getNumber(boreHeight)*16; end
    if string.find(string.lower(boreDepth),"c") then boreDepth = getNumber(boreDepth)*16; end
    print(SEPERATOR)
    --// Get and set input data
    --if type(boreWidth) ~= 'number' or type(boreHeight) ~= 'number' or type(boreDepth) ~= 'number' then return false; end
    return true;
end

function Start()
    blacklist = require("./"..BLACKLIST_FILENAME)
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
        if layersSinceDeposit >= tonumber(depositInterval) then Deposit(); layersSinceDeposit = 0; end
        print("Mining in progress... ("..layersMined.." / "..boreDepth..")")
    end
    if layersSinceDeposit ~= 0 then Deposit(); end
    print("End")
end

function MineLayer()
    Dig();
    turtle.turnRight();
    movingRight = true;
    -- up, then turn around
    for i = 1, boreHeight do -- assuming we are looking where we wanna go
        Repeat(boreWidth-1,Dig) -- mine row
        throwBlacklisted()
        Repeat(2,turtle.turnLeft)
        if i < tonumber(boreHeight) then repeat turtle.digUp() until turtle.up(); movingRight = not movingRight; end
    end
    Repeat(boreHeight-1,DigDown)
    if movingRight then Repeat(boreWidth-1,Dig); turtle.turnRight(); else turtle.turnLeft(); end
end

--====================================================================================================================================
--// Utility Functions
--====================================================================================================================================

function Dig() repeat turtle.dig() until turtle.forward(); end
function DigDown() repeat turtle.digDown() until turtle.down(); end

function Deposit()
    turtle.select(CHEST_SLOT)
    turtle.digDown()
    turtle.placeDown()
    for i = 1, 16 do if i ~= CHEST_SLOT then turtle.select(i); turtle.dropDown(); end end
    turtle.select(CHEST_SLOT);
    turtle.digDown()
    turtle.select(1)
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

function onBlacklist(n)
    if not fs.exists(BLACKLIST_FILENAME..".lua") or blacklist == nil then return; end
    for _,bName in pairs(blacklist) do
        if bName == n then return true; end
    end
    return false;
end

function throwBlacklisted()
    if not fs.exists(BLACKLIST_FILENAME..".lua") or blacklist == nil then return; end
    for i = 1, 16 do
        local data = turtle.getItemDetail(i);
        if data and onBlacklist(data.name) then turtle.select(i); turtle.dropDown(); end
    end
    turtle.select(1)
end

Start();
