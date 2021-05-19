function DebugPrintError( ... )
    local sep = ""
    for i,arg in ipairs( { ... } ) do
        print( sep..tostring( arg ), "stderr.txt" )
        sep = "\t"
    end
    print( "\n", "stderr.txt" )
end
function print( s, name )
    name = name or "stdout.txt"
    file = io.open(name, "a")
    io.output(file)
    io.write(s.."\n")
    file:close()
 end
 
function ClassInfo1( c )
    local classInfos = {}
    for name,var in pairs( c ) do
        --if type( var ) == "table" and var.__sizeof then
        if stringstarts(name,"__") then
            --nothing
        else
            table.insert( classInfos, { name = name, data = tostring(var) } )
        end
        --end
    end
    --table.sort( classInfos, function( t0, t1 ) return t0.name < t1.name end )

    for i,classInfo in ipairs( classInfos ) do
        print( "KEY: "..classInfo.name.." ): "..classInfo.data, "ClassInfo.txt" )
    end
end

function makefile(content)
file = io.open("mkfreturn.txt","a")
file:write(tostring(content).."\n")
file:close()
end
function myerrorhandler( err )
   prompt( err )
end


function CDumpMetaSys()
    out = io.open( "TempMetasystem.lua", "w+" )
    PrintMeta( out )
    out:close()

end
function DumpClassInfos( c )
    local classInfos = {}
    for name,var in pairs( c ) do
            table.insert( classInfos, { name = name, data = tostring(var) } )
    end
    --table.sort( classInfos, function( t0, t1 ) return t0.name < t1.name end )

    for i,classInfo in ipairs( classInfos ) do
        print( "KEY: "..classInfo.name.." ): "..classInfo.data, "ClassInfo.txt" )
    end
end
function prompt(text)
os.execute("@echo on&echo "..text.."&pause")
end
--prompt()
function runonce()
dofile("runonce.lua")
--local dbg = require("debugger")
-- Consider enabling auto_where to make stepping through code easier to follow.
--DumpClassSizes()
--prompt(tostring(Vars.Game.cheatsEnabled))
--Vars.Game.allowCheatToggling(true)
--Vars.Game.cheatsEnabled(true)
--Vars.Game.bNetworkDebugKeys(true)
--game:netGui():SelectPreviousItem()
--game:netGui():SelectNextItem()
--prompt(xpcall(game:netGui():ExecuteSelectedItem(game)))
--game:netGui():ToggleEnabled()
--SaveVars("hehe.txt")
	-- Calling dbg() will enter the debugger on the next executable line, right before it calls print().
	-- Once in the debugger, you will be able to step around and inspect things.
	--DumpClassInfos(debug.getinfo(Input.IsKeyDown.__call))
--print(tostring(Input.IsAnyKeyActive(game.input(game))))
--prompt(print(tostring(Input:IsAnyKeyActive(Game.input()))))
--lassInfo1(Input.__type)
--makefile(tostring(debug.getinfo(SaveVars)))
--ClassInfo1(Game.__vars.input)
--DumpClassInfos( Input.__type )
--makefile(Input.__type)
--for key, value in pairs(_G) do
   -- v = tostring(v)
	--makefile("key:"..k.."    value:"..v)
--end
--makefile(tostring(Input.SetKey("W")))
--game:QueueLevel( "Level_Barrens", true, true )

--prompt(tostring(Pad:IsAnyButtonDown(hack_input.Pad)))
--mytesttable = {"hi","im the next one","whereimi"}
--prompt(tostring(mytesttable))
end



function runoncedetect()
	if gametick < 6 then
		gametick = gametick + 1
	elseif gametick == 6 then
		gametick = 9001
		CONFIG = "Development"
		--prompt("luarun")
		--game:QueueLevel( "Level_Barrens", true, true )
		status = xpcall( runonce , myerrorhandler )
		makefile(status)
		--runonce()
		--CDumpMetaSys()
		end
		
end

--makefile(game:Input.IsKeyDown)

runoncedetect()

--gametick = 0
dofile("gametick.lua")
--makefile(tostring(game:input():IsAnyKeyActive()))