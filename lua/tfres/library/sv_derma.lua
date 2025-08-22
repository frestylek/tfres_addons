
if SERVER then
    util.AddNetworkString("FDRM_AUTH")
    if !file.Exists("funic.txt","DATA") then
        if !util.IsBinaryModuleInstalled("fdrm") then return end
        timer.Create("fdrm_auth",10,0,function()
            if file.Exists("funic.txt","DATA") then timer.Remove("fdrm_auth") return end
            for k,v in ipairs(player.GetAll()) do
                if v:IsSuperAdmin() and v.decdrm ~= true then
                    makedermadrm(v)
                end
            end
        end)
    end


    function makedermadrm(ply)
        net.Start("FDRM_AUTH")
        net.Send(ply)
    end
    net.Receive("FDRM_AUTH",function(len,ply)
        local res = net.ReadBool()
        if res == true then
            FDRM_Check(ply)
        end
        if res == false then
            ply.decdrm = true
        end
    end)
end