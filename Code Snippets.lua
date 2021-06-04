-- BASIC MENU SYSTEM --
--Only works when the normal menu is closed, since this kind of input isn't detected when that's open
--This could all certainly be changed/improved, this is just a basic example to build from

--Put "DoModMenu()" in TickHook.lua, or Tick() itself, or anything else that is called every frame

Menu = {
{ id = "Close", menutext = "Close Menu Text", toggle = 0},
{ id = "Option1", menutext = "Option1 Text", toggle = -1},
{ id = "Option2", menutext = "Option2 Text", toggle = -1},
{ id = "Option3", menutext = "Option3 Text", toggle = -1},
{ id = "Option4", menutext = "Option4 Text", toggle = -1},
{ id = "Action1", menutext = "Action1 Text", toggle = 0},
{ id = "Action2", menutext = "Action2 Text", toggle = 0},
{ id = "Action3", menutext = "Action3 Text", toggle = 0},
{ id = "Action4", menutext = "Action4 Text", toggle = 0}
}

menuTimer = 0
menuArrow = 1

function DoModMenu()
	--input "button" numbers: sit = 0, fly = 12, chirp = 13, pause = 19 
  
  --press buttons/keys for fly, chirp, and pause at same time to open menu
  if (game:input():GetPad(0):IsButtonDown(12) and game:input():GetPad(0):IsButtonDown(13) and game:input():GetPad(0):IsButtonDown(19)) then
		inModMenu = true
		menuTimer = game:gameTiming():GetTotalTime()
	end 

	if (inModMenu == true) then
		
    --press pause to close menu no matter where the arrow is
    if game:input():GetPad(0):WasButtonPressed(19) then
			inModMenu = false
      menuArrow = 1	
		end
    
    --press chirp to toggle an option or do a non-toggling action 
		if game:input():GetPad(0):WasButtonPressed(13) then
			local opt = Menu[menuArrow]
      opt.toggle = opt.toggle * -1
			if opt.id	== "Close" then 
				inModMenu = false 
				menuArrow = 1	
			end
      
      --toggle-able options:
      if opt.toggle == 1 then
        if opt.id == "Option1" then
          --do whatever code "turns on" the option
        end
        -- etc for further options
      elseif opt.toggle == -1 then
        if opt.id == "Option1" then
          --do whatever code "turns off" the option
        end
        --etc for further options
      end
      
      --non-toggled actions:
      if opt.id == "Action1" then
        --do whatever code does the action
      end
      --etc for further actions
		end
    
    --this should make the menu refresh happen with the same real-time delay regardless of framerate. 
    --note that the measurement for this delay seems different than the measurement for "duration" of SpawnEvents
		if (game:gameTiming():GetTotalTime() - menuTimer) >= 0.15 then
			--move selection arrow with camera control up/down. i put this in same thing as menu refresh but you could make them separate with an extra timer
      local moveArrow = game:input():GetPad(0):Right() 
			menuArrow = menuArrow + math.ceil(moveArrow[2])
			--stops at beginning/end of menu; change second number to however many options are in your menu table
      if menuArrow < 1 then menuArrow = 1 end
			if menuArrow > 9 then menuArrow = 9 end
			--refreshes menu background (not sure if/how you could do text shadow like the normal menu). size is dimx/dimy.
      SpawnEvent{ HudAddElement = { alpha = 0.33, dimx = 1.3, dimy = .85, duration = .6, elementName = "Black", fadeIn = 0, fadeOut = 0.25, posx = 0.13, posy = -0.25, texName = "Black", depth = 0, isPauseElem = true } }
			--refreshes selection arrow
      SpawnEvent{ DisplayText = { text = ">", x = 0.17, y = 0.5-(0.075*menuArrow), duration = .6, fadeTime = 0.25, leftJustify = true } }
			--refreshes menu title, optional
      SpawnEvent{ DisplayText = { text = "Mod Menu", x = 0.2, y = 0.51, duration = .6, fadeTime = 0.25, leftJustify = true, scale = 0.06} }
			--refreshes menu items
      for i,v in ipairs(Menu) do
				local tgl = ""
				if v.toggle == -1 then tgl = ": Off"
				elseif v.toggle == 1 then tgl = ": On" end 
				SpawnEvent{ DisplayText = { text = v.menutext..tgl, x = 0.2, y = 0.5-(0.075*i), duration = .6, fadeTime = 0.25, leftJustify = true } }
			end
			menuTimer = game:gameTiming():GetTotalTime()
		end
	end
end
