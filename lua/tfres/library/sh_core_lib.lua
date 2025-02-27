
local global = tfres.Global

if SERVER then
    util.AddNetworkString("tfres::Networking")
end

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return Color(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

function global:SaveData(addon,name,data)
    if !isstring(data) and istable(data) then
        data = util.TableToJSON(data)
    end
    file.CreateDir("tfres/" .. addon)
    file.Write("tfres/" .. addon .. "/" .. name .. ".json",data)
end

function global:LoadData(addon,name)
    local data = file.Read("tfres/" .. addon .. "/" .. name .. ".json","DATA")
    if !data then
        return
    end
    data = util.JSONToTable(data) or data
    return data
end

function global:SQL(query)
    sql.Query(query)
end

local function compressdata(data)
    data = util.TableToJSON(data)
    local compressed_message = util.Compress( data )
	local bytes_amount = #compressed_message
    return compressed_message,bytes_amount
end

function global:NetSend(name,info,ply)
    local data, bytes = compressdata(info)
    net.Start("tfres::Networking")
        net.WriteString(name)
        net.WriteUInt( bytes, 16 )
        net.WriteData( data, bytes )
    net.Send(ply)
end

function global:NetBroadcast(name,info,ply)
    local data, bytes = compressdata(info)
    net.Start("tfres::Networking")
        net.WriteString(name)
        net.WriteUInt( bytes, 16 )
        net.WriteData( data, bytes )
    net.Broadcast()
end


function global:NetServer(name,info)
    local data, bytes = compressdata(info)
    net.Start("tfres::Networking")
        net.WriteString(name)
        net.WriteUInt( bytes, 16 )
        net.WriteData( data, bytes )
    net.SendToServer()
end

global.Networks = global.Networks or {}
global.NetworksBypass = global.NetworksBypass or {}

function global:RegisterNetwork(name,func,bypass)  
    global.Networks[name] = func
    if bypass then
        global.NetworksBypass[name] = true 
    end
end


function global:GetNet(name)
    return global.Networks[name] ~= nil
end

function global:Log(addon, ...)
    print("[tfres]",addon, ...)
end

function global:Error(addon, ...)
    local traceback = debug.traceback()
    print("[tfres]",addon, ... , traceback)
end

net.Receive("tfres::Networking",function(len,ply)
    local name = net.ReadString()
    if SERVER then
        if !global.NetworksBypass[name] then
            if !ply then return end
            if ply.tfres_net and ply.tfres_net > CurTime() then return end
            ply.tfres_net = CurTime() + 0.1
        else
        end
    end
    
    if !global:GetNet(name) then global:Error("Networking","No network name.") return end
    local bytes = net.ReadUInt(16)
    local compress = net.ReadData(bytes)
    local data = util.Decompress(compress)
    local tbl = util.JSONToTable(data)
    global.Networks[name](tbl,ply)
end)