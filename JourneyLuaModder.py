from ctypes import cdll
import tkinter as tk
import time
import os 
root = tk.Tk()
_sopen = cdll.msvcrt._sopen
_close = cdll.msvcrt._close
_SH_DENYRW = 0x10

def is_open(filename): #copied from somewhere i don't remember but didn't use it yet
    if not os.access(filename, os.F_OK):
        return False # file doesn't exist
    h = _sopen(filename, 0, _SH_DENYRW, 0)
    if h == 3:
        _close(h)
        return False # file is not opened by anyone else
    return True # file is already open
def refreshTick(): #some shit code that actually works
	Luatofile("gameTick = 1","GameTick.lua")
	time.sleep(0.16)
	Luatofile("--gameTick = 1","GameTick.lua")
	return
def Luatofile(source,filename): #this doesn't work due to \n is invalid syntax, will look into it later
	curfilename = open(filename,"w")
	curfilename.write(source)
	curfilename.close()
	return
def executeBtn(): #function on button press
	
	curText=texteditor.get("1.0","end")
	runOncelua=open("RunOnce.lua","w")
	runOncelua.write(curText)
	refreshTick()
	return


texteditor=tk.Text(root,height=30,width=80,bg="white") #made it white so you can actually see cursor
texteditor.pack(side="left")
sendLua = tk.Button(root,text="Execute",padx=40,pady=5,fg="black",bg="gray",command=executeBtn)
sendLua.pack(side="right",anchor="s")
root.mainloop()
