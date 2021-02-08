
local SEPERATOR = "======================================="

local blocks = {};
local dupes = 1;
local lastBlock = 0;
local thisBlock = 0;
local width, depth, maxDupes = -1, -1, -1;

--====================================================================================================================================
--// Core Functions
--====================================================================================================================================

local goingBack = false
function Run()
    untilSuccess(GetInstructions)
    blocks = getMaterials();
    for w = 1, width do
        for d = 1, depth do placeBlock(); if d ~= depth then forward(); end end
        goingBack = not goingBack;
        if goingBack then turtle.turnRight(); forward(); digUnder(); turtle.turnRight(); else turtle.turnLeft(); forward(); digUnder(); turtle.turnLeft(); end
    end
end

function GetInstructions()
    shell.run("clear");
    print(SEPERATOR)
    print("Enter Instructions:")
    print("[list: width, depth, max dupes]")
    width = io.read()
    depth = io.read()
    maxDupes = io.read()
    if string.find(string.lower(width),"c") then width = getNumber(width)*16; end
    if string.find(string.lower(depth),"c") then depth = getNumber(depth)*16; end
    print(SEPERATOR)
    --// Get and set input data
    --if type(boreWidth) ~= 'number' or type(boreHeight) ~= 'number' or type(boreDepth) ~= 'number' then return false; end
    return true;
end

--====================================================================================================================================
--// Utility Functions
--====================================================================================================================================

function tLen(t) local ct = 0; for i,v in pairs(t) do ct=ct+1; end return ct; end
function getNumber(str) local num = string.gsub(str, "%D+", ""); return tonumber(num); end

function repeatFunc(times,func,args)
    args = args or {nil}
    for i = 1, times, 1 do func(unpack(args)); end
end

function untilSuccess(func,...)
    local s = false
    repeat s = func(...); until s;
end

function selectNewBlock()
    blocks = getMaterials()
    lastBlock = thisBlock;
    thisBlock = math.random(1,tLen(blocks))
    if lastBlock == thisBlock then dupes=dupes+1; else dupes = 0; end
    if dupes > tonumber(maxDupes) then selectNewBlock(); end
    return;
end

function forward()
    repeat turtle.dig() until turtle.forward();
end

function digUnder()
    turtle.select(16)
    turtle.dropUp()
    turtle.digDown()
    turtle.dropUp()
end

function placeBlock()
    digUnder()
    selectNewBlock()
    turtle.select(blocks[thisBlock].slot)
    turtle.placeDown()
end

function getMaterials()
    local returnData = {};
    for i = 1, 16 do
        local data = turtle.getItemDetail(i)
        if data then
            table.insert(returnData,{slot=i,block=data.name});
        end
    end
    return returnData;
end

math.randomseed(os.time())
Run()