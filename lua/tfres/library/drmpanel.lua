

if CLIENT then
    fframe = fframe
    function makedermadrm()

        local frame = vgui.Create("FFrame")
        fframe = frame
        frame:SetSize(ScrW()*0.4,ScrH()*0.4)
        frame:Center()
        frame:FadeIn(2)
        frame:MakePopup()
        local top = vgui.Create("DPanel",frame)
        top:Dock(TOP)
        top:SetSize(frame:GetWide(),frame:GetTall()*0.05)
        top.Paint = nil
        local button = vgui.Create("FButton",top)
        button:SetSize(frame:GetWide()*0.2,top:GetTall())
        button:SetPos(frame:GetWide()-button:GetWide(),0)
        button:SetText("X")
        button:SetFont("CloseCaption_Bold")
        button:SetColor(Color(0,0,0))
        button:SetBackground(Color(255,0,0))
        function button:DoClick()
            frame:FadeOut(2)
            net.Start("FDRM_AUTH")
                net.WriteBool(false)
            net.SendToServer()
        end
        local mid = vgui.Create("DPanel",frame)
        mid.Paint = nil
        mid:Dock(FILL)
        mid:SetSize(frame:GetWide(),frame:GetTall() -frame:GetTall()*0.1)
        local text = vgui.Create("DLabel",mid)
        text:SetFont("CloseCaption_Bold")
        text:SetText([[[FDRM] DRM SYSTEM
        
Welcome!
You are not authorized yet.
Press button below to authorisate addons.]])
        text:SizeToContents()
        text:Center()
        local auth = vgui.Create("FButton",mid)
        auth:SetSize(mid:GetWide()*0.7,mid:GetTall()*0.2)
        auth:SetPos(mid:GetWide()*.5 - auth:GetWide()/2,mid:GetTall()*.8)
        auth:SetText("AUTORYZUJ")
        auth:SetBackground(Color(115,187,70))
        auth:SetFont("CloseCaption_Bold")
        auth:SetStyle(2)
        function auth:DoClick()
            frame:FadeOut(5)
            net.Start("FDRM_AUTH")
                net.WriteBool(true)
            net.SendToServer()
        end
    end








    net.Receive("FDRM_AUTH",function(len)
        if !IsValid(fframe) then
            makedermadrm()
        end
    end)
end