
local function Clip( x, xmin, xmax )
	return math.min( xmax, math.max( xmin, x ) )
end
local function Delerp( t, x0, x1 )
	local diff = x1 - x0
	if diff > -0.00001 and diff < 0.00001 then return 1 end
	local val = ( t - x0 ) / diff
	return Clip( val, 0, 1 )
end
local function Lerp( t, x0, x1 )
	local val = Clip( t, 0, 1 )
	return x1*val+x0*(1-val)
end
local function Dist2Sq( x1, y1, x2, y2 )
    return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end

-- PrintMeta()
-- Prints out all the classes that have been exposed to Lua, as well as their
-- member variables.
function PrintMeta( out )
	local metasystem = {}

	for classname,classtbl in pairs( _G ) do
		if type( classtbl ) == "table" and classtbl.__vars then
			local class = {}

			-- abstract
			class.abstract = ( type( classtbl.new ) ~= "function" )

			-- vars
			local vars = {}
			class.vars = vars;
			if not class.abstract then
				local classinst = classtbl.new()

				for varname,varfun in pairs( classtbl.__vars ) do
					local vartable = {}

					local varinst = varfun( classinst )
					local vartype = type( varinst )
					-- See if the var is a Class pointer.
					if varinst == nil or vartype == "userdata" then
						local retcode,errmsg = pcall( varfun, classinst, "baddata" )
						if not retcode then
							vartype = errmsg:match( "Expected ([^,]+)" )
						else
							vartype = "class"
						end
					end
					-- See if the var is a Vectormath object.
					if vartype == "table" then
						local tbllen = #varinst
						local basetype = nil
						for i,v in ipairs( varinst ) do
							if type( v ) == "number" then
								if basetype and basetype ~= "Vector" then basetype = nil break end
								basetype = "Vector"
							elseif type( v ) == "table" then
								local allNumbers = true
								for ii,vv in ipairs( v ) do
									if type( vv ) ~= "number" then allNumbers = false break end
								end
								if (#v ~= tbllen or not allNumbers) or
									(basetype and basetype ~= "Matrix") then basetype = nil break end
								basetype = "Matrix"
							end
						end
						if basetype then vartype = basetype..tbllen end
					end

					local metadatatable = {}
					for metaname,metadata in pairs( varfun.__metadata ) do
						metadatatable[ metaname ] = metadata
					end

					vartable.type = vartype
					vartable.metadata = metadatatable

					vars[ varname ] = vartable
				end
			end	

			-- functions

			-- metadata
			-- ...I hope no one is dyslexic! metatadatatabatable
			local metadatatable = {}
			for metaname,metadata in pairs( classtbl.__metadata ) do
				metadatatable[ metaname ] = metadata
			end
			class.metadata = metadatatable


			--delete classinst
			--@HACK: delete isn't implemented, so we just leak a bunch of memory.

			metasystem[ classname ] = class
		end
	end

	print( "\n\n\n" )
	out:write( "-- A table of all non-abstract classes registered with the meta system.\n" )
    out:write( "Metasystem =" )
	PrintTable( out, metasystem )
    out:write( "\n" )
    out:write( "\n" )
	out:write( "-- A hash of the names of all classes and their members.  Can be used to\n" )
	out:write( "-- quickly determine if two metasystems are compatible.\n" )
    out:write( "Metahash = "..MetaGetHash() )

	print( "\n\n\n" )
	print( "Dumping the metasystem." )
	print( "-- Warning: The current implementation of the metasystem dump has a serious memory leak." )
	print( "-- Your game may become unstable after this point." )
	print( "\n\n\n" )
end

-- DumpMetaSys()
-- moved out here so it can be called directly from the native code 
function DumpMetaSys()
	out = io.open( "/app_home/TempMetasystem.lua", "w+" )
	PrintMeta( out )
	out:close()
	LuaCallWindowsCmd( "/app_home/EXEC:cmd /c \"p4 edit Metasystem.lua &&"
		.."move /Y TempMetasystem.lua Metasystem.lua && del TempMetasystem.lua 2>nul\"" )

	-- Generate a JSON version of the metasystem, as well.
	LuaCallWindowsCmd( "/app_home/EXEC:cmd /c \"MetasystemLuaToJson.bat\"" )
end

-- DumpClassSizes()
-- Prints the sizes of all the classes registered with the metasystem to stdout.
function DumpClassSizes()
	local classSizes = {}
	for name,var in pairs( _G ) do
		if type( var ) == "table" and var.__sizeof then
			table.insert( classSizes, { name = name, size = var.__sizeof } )
		end
	end
	table.sort( classSizes, function( t0, t1 ) return t0.size < t1.size end )

	for i,classSize in ipairs( classSizes ) do
		print( "sizeof( "..classSize.name.." ): "..classSize.size )
	end
end

gameTick = 0

function Tick( game, gameTiming, input )
	if gameTick == 0 then 
		dofile("StartLua.lua")
	end
	Tick_game = game
	Tick_gameTiming = gameTiming
	Tick_input = input
	dofile("TickHook.lua")
end
