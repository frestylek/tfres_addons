
local PANEL = {}

AccessorFunc( PANEL, "m_bBorder", "DrawBorder", FORCE_BOOL )

function PANEL:OnReleased()
	self.pos = nil
	self.p = nil
	self:SetPos(self.posx,self.posy)
end

function PANEL:OnDepressed()
	if self.posx == nil then
	self.posx,self.posy = self:GetPos()
	end
	if self.pos == nil then
	self.pos = {x = gui.MouseX(), y = gui.MouseY()}
	end
	self.p = true
end

function PANEL:Contr(size)
	self.size = size
end

function PANEL:Paint2( w, h )
		surface.SetMaterial(Material("materials/fstands/circle.png"))
    if self:GetStyle() ~= 1 then
        surface.SetDrawColor(self:lessback())
        
        if self:IsHovered() then
            surface.SetDrawColor(self:pulse())
        else
            self.np = CurTime()
        end
        surface.DrawTexturedRect(0,0,w,h)
    else
        
        surface.SetDrawColor(self:GetBackground())
        surface.SetDrawColor(self:Fade(true))
        if self:IsHovered() then
            self.np = math.Clamp(self.np + FrameTime(),0,self:GetTime())
        else

            self.np = math.Clamp(self.np - FrameTime(),0,self:GetTime())
        end
        surface.DrawTexturedRect	(0,0,w,h)
    end
	--
	-- Draw the button text
	--
	return false

end

function PANEL:GetValue()
	return self.ma
end

function PANEL:Make()

end

function PANEL:Paint(w,h)
	self.size = self.size or self:GetWide()*0.5
	self.last = self.last or CurTime() - 1
	if self.p == true then
		local x = math.Clamp((gui.MouseX() - self.pos.x),-self.size,self.size)
		local y = math.Clamp((gui.MouseY() - self.pos.y),-self.size,self.size)
		self.ma = {x = 0, y=0}
		if math.abs(x) > self.size*0.2 then
			self.ma.x = x/self.size
		end
		if math.abs(y) > self.size*0.2 then
			self.ma.y = y/self.size
		end
		if (math.abs(x) > self.size*0.2 or math.abs(y) > self.size*0.2) and self.last < CurTime() - 0.05 then
			self.last = CurTime()
			self:Make(self:GetValue())
		end 
	self:SetPos(x +self.posx, y + self.posy)
	
	end
	self:Paint2(w,h)
end

local PANEL = derma.DefineControl( "FJoy", "Custom made joystick", PANEL, "FButton" )