tfres = tfres or {}
tfres.Global = tfres.Global or {}

local rootDirectory = "tfres"
local function startload()
print([[
========================================================
_____ __              _                 _ _           
|_   _/ _|_ _ ___ ___ | |   ___  __ _ __| (_)_ _  __ _ 
  | ||  _| '_/ -_|_-< | |__/ _ \/ _` / _` | | ' \/ _` |
  |_||_| |_| \___/__/ |____\___/\__,_\__,_|_|_||_\__, |
                                                 |___/ 
========================================================
]])
end 

local filesc = 0
local function AddFile(File, directory)
    local prefix = string.lower(string.Left(File, 3))
    filesc = filesc + 1
    if SERVER and prefix == "sv_" then
        include(directory .. File)
    elseif prefix == "sh_" then
        if SERVER then
            AddCSLuaFile(directory .. File)
        end

        include(directory .. File)
    elseif prefix == "cl_" then
        if SERVER then
            AddCSLuaFile(directory .. File)
        elseif CLIENT then
            include(directory .. File)
        end
    elseif file ~= "config.lua" then
        if SERVER then
            AddCSLuaFile(directory .. File)
        end

        include(directory .. File)
    end
    if string.find(directory:lower(),"weapons") then
        if not SWEP then return end
        weapons.Register(SWEP, SWEP.ClassName or file)
    end
end

local function IncludeDir(directory)
    directory = directory .. "/"
    local files, directories = file.Find(directory .. "*", "LUA")

    for _, v in ipairs(files) do
        if string.StartsWith(v, "sv_") then
            AddFile(v, directory)
        end
    end

    for _, v in ipairs(directories) do
        if v == "class" then continue end
        if directory == rootDirectory .. "/" then
            print("Wczytywanie [" .. v .. "]")
        end
        IncludeDir(directory .. v)
    end
end

local function IncludeCir(directory)
    directory = directory .. "/"
    local files, directories = file.Find(directory .. "*", "LUA")

    for _, v in ipairs(files) do
        if string.EndsWith(v, "_lib.lua") then
            AddFile(v, directory)
        end
    end

    for _, v in ipairs(directories) do
        if v == "class" then continue end
        IncludeCir(directory .. v)
    end
end

local function IncludeCLir(directory)
    directory = directory .. "/"
    local files, directories = file.Find(directory .. "*", "LUA")
    
    for _, v in ipairs(files) do
        if !string.StartsWith(v, "sv_") then
            AddFile(v, directory)
        end
    end
    print(directory)
    for _, v in ipairs(directories) do
        if v == "class" then continue end
        print(directory .. "/" .. v)
        IncludeCLir(directory .. v)
    end
end

local function tfresLoad()
    if MRBEAST then
        MRBEAST()
    end
    if startload then
        startload()
    end
    print("[Tfres] Wczytywanie plików")
        print("CONFIGI")
        IncludeCir(rootDirectory)
        print("CLIENT")
        IncludeCLir(rootDirectory)
    print("[Tfres] Zakończono wczytywanie", "Plików: " .. filesc)
    FMAIN = FMAIN or {}
end

local function tfresLoadSV()
    print("[Tfres] Wczytywanie plików")
        print("SERVER")
        filesc = 0
        IncludeDir(rootDirectory)
    print("[Tfres] Zakończono wczytywanie", "Plików: " .. filesc)
end

hook.Add("InitPostEntity","tfres_ClientLoaded",function()
    if CLIENT then
        hook.Run("tfres_Loaded")
    end
end)

hook.Add("tfres_Loaded","ConsolePrint",function()
    print("[Tfres] Loaded All scripts")
end)

hook.Add("Initialize", "tfres_loader", function()
    tfresLoad()
    if SERVER then
        if game.GetIPAddress() == nil or string.find(tostring(game.GetIPAddress()),"0.0.0.0:") then
            print("[Tfres] Waiting for valid IP")
            timer.Create("Tfres_waitingip",5,0,function()
                if game.SinglePlayer() then
                    tfresLoadSV()
                    timer.Remove("Tfres_waitingip")
                    hook.Run("tfres_Loaded")
                    print("[Tfres] Loading SinglePlayer. Not all addons can work")
                    
                    return
                end
                if game.GetIPAddress() == nil or string.find(tostring(game.GetIPAddress()),"0.0.0.0:") then return end
                tfresLoadSV()
                if game.IsDedicated() and util.IsBinaryModuleInstalled("fdrm") then
                    require("fdrm")
                else
                    print("[Tfres] No DRM installed")
                end
                timer.Remove("Tfres_waitingip")
                hook.Run("tfres_Loaded")
            end)
        else
            print("[Tfres] Valid IP no waiting")
            tfresLoadSV()
            if game.IsDedicated() and util.IsBinaryModuleInstalled("fdrm") then
                require("fdrm")
            else
                print("[Tfres] No DRM installed")
            end
            hook.Run("tfres_Loaded")
        end
    end
    
end)