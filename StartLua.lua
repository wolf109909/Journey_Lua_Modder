-- ! Functions required for program to work ! --

function RunOnceDetect()
	if gameTick < 7 then
		gameTick = gameTick + 1
	elseif gameTick == 7 then
		gameTick = 9001
		status = xpcall( RunOnce , MyErrorHandler )
		MakeFile(status)
	end
end

function RunOnce()
dofile("RunOnce.lua")
end

function MyErrorHandler( err )
    file2 = io.open("stderr.txt","a")
    file2:write(os.date( "%a %b %d, %H:%M").." - "..err.."\n")
    file2:close()
    Prompt( err )
end

function Prompt(text)
os.execute("@echo "..text.."&timeout 6")
end

function MakeFile(content)
file = io.open("mkfreturn.txt","a")
file:write(tostring(content).."\n")
file:close()
end

function PrintToFile( s, name )
    name = name or "stdout.txt"
    file = io.open(name, "a")
    io.output(file)
    io.write(os.date( "%a %b %d, %H:%M").." - "..s.."\n")
    file:close()
end

-- Optional functions --

function FunctionInfo(f)
	for key,value in pairs(debug.getinfo(f)) do
		PrintToFile("found member " .. key.."   value:"..tostring(value), "FunctionInfo.txt")
	end
end

function DumpClassInfos( c )
    local classInfos = {}
    for name,var in pairs( c ) do
            table.insert( classInfos, { name = name, data = tostring(var) } )
    end
    table.sort( classInfos, function( t0, t1 ) return t0.name < t1.name end )

    for i,classInfo in ipairs( classInfos ) do
        PrintToFile( "KEY: "..classInfo.name.." ): "..classInfo.data, "ClassInfo.txt" )
    end
end

-- Optional overwrites of functions already defined in Journey's lua scripts, to mod and/or fix them --

function DebugPrintError( ... )
    local sep = ""
    for i,arg in ipairs( { ... } ) do
        PrintToFile( sep..tostring( arg ), "stderr.txt" )
        sep = "\t"
    end
    PrintToFile( "\n", "stderr.txt" )
end

function DebugPrint( ... )
		return print( ... )
end

function DumpMetaSys()
    out = io.open( "TempMetasystem.lua", "w+" )
    PrintMeta( out )
    out:close()
end

function ActivateTriggerByName( triggerName )
	print( "Trying to activate" .. triggerName )
	Names[ triggerName ]:Start()
end

function SpawnEvent( eventTable )
	local eventBarn = _G[ "game" ]:eventBarn()
	
	for eventType, eventParams in pairs( eventTable ) do		
		if _G[ eventType ] == nil then
			print( "SpawnEvent(): invalid event type '"..eventType.."'\n" )
			return
		end
		
		--useful for debug, but maybe laggy/take up space if spawning tons of events and have print() going to file
		--print( "Spawning event '"..eventType.."'" )
		
		local event = eventBarn:MetaAddEvent( eventType )
		local eventImplPtr = _G[ eventType ].cast( event )
	
		for key,val in pairs( eventParams ) do
			if eventImplPtr[ key ] == nil then
				print( "SpawnEvent(): invalid param '"..key.."' for event '"..eventType.."'" )
			else
				eventImplPtr[ key ]( eventImplPtr, val )
			end
		end
		
		eventImplPtr:Start()
	end	
end
