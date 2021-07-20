from ctypes import cdll
import tkinter as tk
from tkinter import simpledialog
from tkinter import messagebox
from tkinter import *
from tkinter.filedialog import askopenfilename, asksaveasfilename
import time
import json
import os 
import keyboard
import shelve
root = tk.Tk()
_sopen = cdll.msvcrt._sopen
_close = cdll.msvcrt._close
_SH_DENYRW = 0x10
def interpretRunOnceLua(Name):
    interpretCodeFile=open(Name,"r")
    interpretCode=interpretCodeFile.read()
    runOncelua=open("RunOnce.lua","w+")
    oldCode=runOncelua.read()
    runOncelua.write(interpretCode)
    refreshTick()
    runOncelua.write(oldCode)
def registerHotkey(Name):
    ObjData = WorkspaceObj.ReadFromDisk(Name)
    CreationMode = ObjData[0]
    Delay = ObjData[1]
    Hotkey = ObjData[2]
    keyboard.add_hotkey(Hotkey, interpretRunOnceLua(Name))
    
def createObj(Name,Mode,Delay,Hotkey):
    WorkspaceObj(Name,Mode,Delay,Hotkey)
    WorkspaceObj.WriteToDisk(Name,Mode,Delay,Hotkey)
def editObjMsg(Name):
    ObjData = WorkspaceObj.ReadFromDisk(Name)
    CreationMode = ObjData[0]
    Delay = ObjData[1]
    Hotkey = ObjData[2]
    top = tk.Toplevel()
    label = tk.Label(top,text="Mode",width=20)
    label.grid()
    radio1 = Radiobutton(top,text="Loop",variable = CreationMode,value=True,anchor="n")
    radio1.grid()
    radio2 = Radiobutton(top,text="Once",variable = CreationMode,value=False,anchor="n")
    radio2.grid()
    label3 = tk.Label(top,text="Delay(ms)",width=20)
    label3.grid()
    DelayEntry = tk.Entry(top,width=20)
    DelayEntry.grid()
    DelayEntry.insert(0,Delay)
    labe2 = tk.Label(top,text="Hotkey",width=20)
    labe2.grid()
    CreationEntry = tk.Entry(top,width=20)
    CreationEntry.grid()
    CreationEntry.insert(0,Hotkey)
   
    def SaveBtn():
        Hotkey = CreationEntry.get()
        Delay = DelayEntry.get()
        createObj(Name,CreationMode,Delay,Hotkey)
        registerHotkey(Name)
        top.destroy()
        refreshfList()
       
    CreationBtn = Button(top, text="Save", command=SaveBtn)
    CreationBtn.grid()
    top.mainloop()
def createObjMsg(Name):
    CreationMode = False
    top = tk.Toplevel()
    label = tk.Label(top,text="Mode",width=20)
    label.grid()
    radio1 = Radiobutton(top,text="Loop",variable = CreationMode,value=True,anchor="n")
    radio1.grid()
    radio2 = Radiobutton(top,text="Once",variable = CreationMode,value=False,anchor="n")
    radio2.grid()
    label3 = tk.Label(top,text="Delay(ms)",width=20)
    label3.grid()
    DelayEntry = tk.Entry(top,width=20)
    DelayEntry.grid()
    labe2 = tk.Label(top,text="Hotkey",width=20)
    labe2.grid()
    CreationEntry = tk.Entry(top,width=20)
    CreationEntry.grid()
   
    def SaveBtn():
        Hotkey = CreationEntry.get()
        Delay = DelayEntry.get()
        createObj(Name,CreationMode,Delay,Hotkey)
        registerHotkey(Name)
        top.destroy()
        refreshfList()
       
    CreationBtn = Button(top, text="Save", command=SaveBtn)
    CreationBtn.grid()
    top.mainloop()
    
def getrowcount():
    count = len(open("test.txt").readlines())
    return count
def codetofile(filename,code):
    curfile = open(filename,"w+")
    curfile.write(code)
def jsontofile(name,jsonstr):
    curjson = open(name+".json","w+")
    curjson.write(jsonstr)
def fetchcode(filename):
    curfile = open(filename)
    return(curfile.read())
def createcodesnippet(name,code):
    codetofile(name,code)
    createObjMsg(name)
    






class WorkspaceObj: #added a class that handles code snippet creation
    
    def __init__(self,Name,Mode,Delay,Hotkey):
        self.Name = Name
        self.Mode = Mode
        self.Delay = Delay
        self.Hotkey = Hotkey
    def WriteToDisk(Name,Mode,Delay,Hotkey):
        
        db=shelve.open("Moddata/"+Name)
        db["Name"]=Name
        db["Mode"]=Mode
        db["Delay"]=Delay
        db["Hotkey"]=Hotkey
        db.close()
    def ReadFromDisk(Name):
        db=shelve.open("Moddata/"+Name)
        Mode = db["Mode"]
        Delay = db["Delay"]
        Hotkey = db["Hotkey"]
        WorkspaceObj(Name,Mode,Delay,Hotkey)
        return Mode,Delay,Hotkey
def is_open(filename):
    if not os.access(filename, os.F_OK):
        return False # file doesn't exist
    h = _sopen(filename, 0, _SH_DENYRW, 0)
    if h == 3:
        _close(h)
        return False # file is not opened by anyone else
    return True # file is already open
def refreshTick():
	Luatofile("gameTick = 1","GameTick.lua")
	time.sleep(0.16)
	Luatofile("--gameTick = 1","GameTick.lua")
	return
def Luatofile(source,filename):
	curfilename = open(filename,"w")
	curfilename.write(source)
	curfilename.close()
	return
def executeBtn():
	
	curText=texteditor.get("1.0","end")
	runOncelua=open("RunOnce.lua","w")
	runOncelua.write(curText)
	refreshTick()
	
def renameFile():
    curfilename = flistbox.get(flistbox.curselection())
    destfilename = simpledialog.askstring(title="Rename file",prompt="New filename:")
    os.rename(curfilename,destfilename)
    refreshfList()
def saveFile():
    """Save the current file as a new file."""
    filepath = asksaveasfilename(
        defaultextension="lua",
        filetypes=[("Text Files", "*.txt"), ("All Files", "*.*")],
    )
    if not filepath:
        return
    with open(filepath, "w") as output_file:
        text = txt_edit.get(1.0, tk.END)
        output_file.write(text)
        refreshfList()
def propertiesFile():
    Name = flistbox.get(flistbox.curselection())
    editObjMsg(Name)
def saveascodesnippet(): #the function gets called when save as code snippet button is pressed
    codecontent = texteditor.get("1.0","end")
    codename = simpledialog.askstring(title="Save as code snippet",prompt="Filename:")
    createcodesnippet(codename+".lua",codecontent)
    refreshfList()
def do_popup(event):
    try:
        flistbox.selection_clear(0,tk.END)
        flistbox.selection_set(flistbox.nearest(event.y))
        flistbox.activate(flistbox.nearest(event.y))
        m.tk_popup(event.x_root, event.y_root)
    finally:
        m.grab_release()
def showcontent(event):
    x = flistbox.curselection()[0]
    file = flistbox.get(x)
    with open(file) as file:
        try:
            file = file.read()
            
        except ValueError:
            messagebox.showerror("Oops!", "Something went wrong while accessing the file. Make sure you have selected a proper text file.")

    texteditor.delete('1.0', tk.END)
    texteditor.insert(tk.END, file)

texteditor=tk.Text(root,height=30,width=80,bg="white")
texteditor.pack(side="left",fill="both", expand=True)

 #change stuff inside this for accurate journey stuff, doesn't matter now if you put it under root folder of journey install.
flistbox = tk.Listbox(root)
flistbox.pack(fill="both", expand=True)
def refreshfList():
    flistbox.delete(0,tk.END)
    flist = os.listdir()
    for item in flist:
        
        flistbox.insert(tk.END, item)
m = tk.Menu(root, tearoff = 0)
m.add_command(label ="Save As...",command= saveFile)
m.add_command(label ="Rename",command = renameFile)
m.add_command(label ="Proterties",command = propertiesFile)
m.add_command(label ="meh")
m.add_separator()
m.add_command(label ="Reload",command = refreshfList)

  
flistbox.bind("<Button-3>", do_popup)
# Listbox operations
refreshfList()

flistbox.bind("<<ListboxSelect>>", showcontent)
flistscrollbar = tk.Scrollbar(flistbox)
flistscrollbar.pack(side = "right", fill = "both")
flistbox.config(yscrollcommand = flistscrollbar.set)
flistscrollbar.config(command = flistbox.yview)
sendLua = tk.Button(root,text="Execute",padx=40,pady=5,fg="black",bg="gray",command=executeBtn)
savecodeassnippets = tk.Button(root,text="NewObj",padx=40,pady=5,fg="black",bg="gray",command=saveascodesnippet)#added a button for saving as code snippet
sendLua.pack(side="right",anchor="s")
savecodeassnippets.pack(side="right",anchor="s")
root.mainloop()
#DOTO: add a table-of-content file for loading settings for individual code snippets when traversing the code snippet directory.Contains required settings for each codesnippet such as name(used to identify the code snippet),
#isLoop(a boolean value that is saved to each code snippet),shortcuts(key shortcut to activate the code)
#to alazar: sry for my broken continuity in coding, its always too late when I try to fix TT
