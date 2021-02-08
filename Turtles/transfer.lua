local enabled = false

function Run()
    print("Running...")
    enabled = true
    while enabled do
        turtle.select(1)
        for i = 1, 16 do sleep(0.01) turtle.select(i) turtle.suckUp() end
        for i = 1, 16 do sleep(0.01) turtle.select(i) turtle.drop(); end
    end
end

function repeatFunc(times,func,args)
    args = args or {nil}
    for i = 1, times, 1 do func(unpack(args)); end
end

function untilSuccess(func,...)
    local s = false
    repeat s = func(...); until s;
end

shell.run("clear")
print("Press ENTER to begin...")
io.read()
Run()
