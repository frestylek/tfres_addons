local PANEL = {}

AccessorFunc( PANEL, "m_bIsMenuComponent",	"IsMenu",			FORCE_BOOL )
AccessorFunc( PANEL, "m_bDraggable",		"Draggable",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable",			"Sizable",			FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock",		"ScreenLock",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bDeleteOnClose",	"DeleteOnClose",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bPaintShadow",		"PaintShadow",		FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth",			"MinWidth",			FORCE_NUMBER )
AccessorFunc( PANEL, "m_iMinHeight",		"MinHeight",		FORCE_NUMBER )

AccessorFunc( PANEL, "m_bBackgroundBlur",	"BackgroundBlur",	FORCE_BOOL )

function PANEL:Init()

	self:SetFocusTopLevel( true )

	--self:SetCursor( "sizeall" )

	self:SetPaintShadow( true )
    self:SetColor(Color(0,0,0))
	self:SetDraggable( false )
	self:SetSizable( false )
	self:SetScreenLock( false )
	self:SetDeleteOnClose( true )
	self:SetTitle( "" )

	self:SetMinWidth( 1 )
	self:SetMinHeight( 1 )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

	self.m_fCreateTime = SysTime()

	self:DockPadding( 0, 0, 0, 0 )

end

function PANEL:ShowCloseButton( bShow )

	self.Close:SetVisible( bShow )

end

function PANEL:SetTitle( strTitle )

end

function PANEL:SetColor( color )
    self.c = color
end
function PANEL:GetColor( color )
    return self.c
end

function PANEL:Close()

	self:SetVisible( false )

	if ( self:GetDeleteOnClose() ) then
		self:Remove()
	end

	self:OnClose()

end

function PANEL:OnClose()
end

function PANEL:CloseIF()
	return false
end

function PANEL:Center()

	self:InvalidateLayout( true )
	self:CenterVertical()
	self:CenterHorizontal()

end

function PANEL:IsActive()

	if ( self:HasFocus() ) then return true end
	if ( vgui.FocusedHasParent( self ) ) then return true end

	return false

end

function PANEL:SetIcon( str )

	if ( !str && IsValid( self.imgIcon ) ) then
		return self.imgIcon:Remove() -- We are instructed to get rid of the icon, do it and bail.
	end

	if ( !IsValid( self.imgIcon ) ) then
		self.imgIcon = vgui.Create( "DImage", self )
	end

	if ( IsValid( self.imgIcon ) ) then
		self.imgIcon:SetMaterial( Material( str ) )
	end

end

function PANEL:Blur(check)
	self.blur = check
end

function PANEL:SlideIn(x,y,time,center)
    time = time or 0
    delay = delay or 0
    if center ~= true then
        self:MoveTo(x,y,time,delay,-0.00001)
    else
        self:MoveTo(ScrW()/2 - self:GetWide()/2,ScrH()/2 - self:GetTall()/2,time,delay,-1)
    end
end
function PANEL:Slide(side,time,delay)
    time = time or 1
    delay = delay or 0
    if side == TOP then
        self:MoveTo(self:GetX(),-self:GetTall(),time,delay,-0.00001)
    elseif side == BOTTOM then
        self:MoveTo(self:GetX(),ScrH() + self:GetTall(),time,delay,-0.00001)
    elseif side == LEFT then
        self:MoveTo(-self:GetWide(),self:GetY(),time,delay,-0.00001)
    else
        self:MoveTo(ScrW() + self:GetWide(),self:GetY(),time,delay,-0.00001)
    end


    timer.Simple(time+delay,function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end
function PANEL:FadeOut(time,delay)
    local alpha = self:GetAlpha()
    local anim = self:NewAnimation( time, delay, -1, function( anim, pnl )
        if IsValid(self) then
            self:Remove()
        end
    end )

    anim.Think = function( anim, pnl, fraction )
        pnl:SetAlpha(alpha *(1 - fraction))
    end

end
function PANEL:FadeHide(time,delay)
    local alpha = self:GetAlpha()
    local anim = self:NewAnimation( time, delay, -1, function( anim, pnl )
    end )

    anim.Think = function( anim, pnl, fraction )
        pnl:SetAlpha(math.max(alpha *(1 - fraction),1))
    end

end
function PANEL:FadeIn(time,alpha)
    alpha = alpha or 255
    local anim = self:NewAnimation( time, delay, -1, function( anim, pnl )
    end )

    anim.Think = function( anim, pnl, fraction )
        pnl:SetAlpha(alpha * fraction)
    end

end
function PANEL:TVLIKE(time)
    local w,h = self:GetWide(),self:GetTall()
    local x,y = self:GetX() + w/2,self:GetY() + h/2
    alpha = alpha or 255
    self:SetSize(0,0)
    self:SizeTo(5,5,0.8,0,-1)
    self:SetPos(x,y)
    self:SizeTo(w,5,time,0.8,-1)
    self:SizeTo(w,h,time,1.5 + 1,-1)
    local anim = self:NewAnimation( time+1.5 +1.6+time, 0, -1, function( anim, pnl )
    end )

    anim.Think = function( anim, pnl, fraction )
        pnl:SetPos(x-self:GetWide()/2,y-self:GetTall()/2)
    end
    

end

function PANEL:Think()
	if self:CloseIF() == true then
		self:FadeOut(0.2)
	end
	local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )

	if ( self.Dragging ) then

		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then

			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )

		end

		self:SetPos( x, y )

	end

	if ( self.Sizing ) then

		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()

		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW() - px && self:GetScreenLock() ) then x = ScrW() - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH() - py && self:GetScreenLock() ) then y = ScrH() - py end

		self:SetSize( x, y )
		self:SetCursor( "sizenwse" )
		return

	end

	local screenX, screenY = self:LocalToScreen( 0, 0 )

	if ( self.Hovered && self.m_bSizable && mousex > ( screenX + self:GetWide() - 20 ) && mousey > ( screenY + self:GetTall() - 20 ) ) then

		self:SetCursor( "sizenwse" )
		return

	end

	if ( self.Hovered && self:GetDraggable() && mousey < ( screenY + 24 ) ) then
		self:SetCursor( "sizeall" )
		return
	end

	self:SetCursor( "arrow" )

	-- Don't allow the frame to go higher than 0
	--if ( self.y < 0 ) then
		--self:SetPos( self.x, 0 )
	--end

end
local blur = Material( "pp/blurscreen" )
function BlurMenu( panel, layers, density, alpha )
	-- Its a scientifically proven fact that blur improves a script
	local x, y = panel:LocalToScreen( 0, 0 )

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 5 do
		blur:SetFloat( "$blur", ( i / 4 ) * 6 )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end
function PANEL:Paint( w, h )

	if ( self.m_bBackgroundBlur ) then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end
	
	if self.blur == true then
		BlurMenu( self, 5, 5, 255 )
		return true
	end
	surface.SetDrawColor(self:GetColor())
    surface.DrawRect(0,0,w,h)
	return true

end

function PANEL:OnMousePressed()

	local screenX, screenY = self:LocalToScreen( 0, 0 )

	if ( self.m_bSizable && gui.MouseX() > ( screenX + self:GetWide() - 20 ) && gui.MouseY() > ( screenY + self:GetTall() - 20 ) ) then
		self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
		self:MouseCapture( true )
		return
	end

	if ( self:GetDraggable() && gui.MouseY() < ( screenY + 24 ) ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end

end

function PANEL:OnMouseReleased()

	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )

end

function PANEL:PerformLayout()

	local titlePush = 0

	if ( IsValid( self.imgIcon ) ) then

		self.imgIcon:SetPos( 5, 5 )
		self.imgIcon:SetSize( 16, 16 )
		titlePush = 16

	end

end

derma.DefineControl( "FFrame", "Main Window", PANEL, "EditablePanel" )