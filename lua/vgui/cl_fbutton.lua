
local PANEL = {}

AccessorFunc( PANEL, "m_bBorder", "DrawBorder", FORCE_BOOL )

function PANEL:Init()

	self:SetContentAlignment( 5 )

	--
	-- These are Lua side commands
	-- Defined above using AccessorFunc
	--
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
    self:SetText("PRZYCISK")
    self:SetTime(1)
	self:SetTall( 22 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )

	self:SetCursor( "hand" )
	self:SetFont( "DermaDefault" )

end

function PANEL:IsDown()

	return self.Depressed

end


function PANEL:GetBackground()

	return self.bcolor or Color(255,255,255)

end
function PANEL:SetBackground(color)
    self.bcolor = color

end

function PANEL:SetImage( img )

	if ( !img ) then

		if ( IsValid( self.m_Image ) ) then
			self.m_Image:Remove()
		end

		return
	end

	if ( !IsValid( self.m_Image ) ) then
		self.m_Image = vgui.Create( "DImage", self )
	end

	self.m_Image:SetImage( img )
	self.m_Image:SizeToContents()
	self:InvalidateLayout()

end
PANEL.SetIcon = PANEL.SetImage

function PANEL:SetMaterial( mat )

	if ( !mat ) then

		if ( IsValid( self.m_Image ) ) then
			self.m_Image:Remove()
		end

		return
	end

	if ( !IsValid( self.m_Image ) ) then
		self.m_Image = vgui.Create( "DImage", self )
	end

	self.m_Image:SetMaterial( mat )
	self.m_Image:SizeToContents()
	self:InvalidateLayout()

end

function PANEL:lessback()

    local col = self:GetBackground()
    col = Color(col.r*0.9,col.g*0.9,col.b*0.9)
    return col

end

function PANEL:pulse()
    local t = self.np or CurTime()
    local pulse = (math.sin((CurTime() - self.np)*3) * 0.2) + 0.7
    local col = self:GetBackground()
    col = Color(col.r*pulse,col.g*pulse,col.b*pulse)
    return col

end

function PANEL:SetTime(s)
    self.t = s
end
function PANEL:GetTime(s)
    return self.t
end

function PANEL:Fade(alpha)
        local t = self.np or 0
        local pulse = math.Clamp(t/self:GetTime(),0,1)
        local col = self:GetBackground()
        if alpha ~= true then
        col = Color(col.r*pulse,col.g*pulse,col.b*pulse)
        else
            col = Color(col.r,col.g,col.b,self:GetAlpha()*pulse)
        end
        return col
end


function PANEL:SetStyle(s)
    if s == 1 then
        self.np = 0
    else
        self.np = CurTime()
    end
    self.s = s
end
function PANEL:GetStyle()
    return self.s
end

function PANEL:Paint( w, h )
    if self:GetStyle() ~= 1 then
        surface.SetDrawColor(self:lessback())
        
        if self:IsHovered() then
            surface.SetDrawColor(self:pulse())
        else
            self.np = CurTime()
        end
        surface.DrawRect(0,0,w,h)
    else
        
        surface.SetDrawColor(self:GetBackground())
        surface.SetDrawColor(self:Fade(true))
        if self:IsHovered() then
            self.np = math.Clamp(self.np + FrameTime(),0,self:GetTime())
        else

            self.np = math.Clamp(self.np - FrameTime(),0,self:GetTime())
        end
        surface.DrawRect(0,0,w,h)
    end
	--
	-- Draw the button text
	--
	return false

end

function PANEL:UpdateColours( skin )

	if ( !self:IsEnabled() )					then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
	if ( self:IsDown() || self.m_bSelected )	then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
	if ( self.Hovered )							then return self:SetTextStyleColor( skin.Colours.Button.Hover ) end

	return self:SetTextStyleColor( skin.Colours.Button.Normal )

end

function PANEL:PerformLayout( w, h )

	--
	-- If we have an image we have to place the image on the left
	-- and make the text align to the left, then set the inset
	-- so the text will be to the right of the icon.
	--
	if ( IsValid( self.m_Image ) ) then

		local targetSize = math.min( self:GetWide() - 4, self:GetTall() - 4 )

		local imgW, imgH = self.m_Image.ActualWidth, self.m_Image.ActualHeight
		local zoom = math.min( targetSize / imgW, targetSize / imgH, 1 )
		local newSizeX = math.ceil( imgW * zoom )
		local newSizeY = math.ceil( imgH * zoom )

		self.m_Image:SetWide( newSizeX )
		self.m_Image:SetTall( newSizeY )

		if ( self:GetWide() < self:GetTall() ) then
			self.m_Image:SetPos( 4, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		else
			self.m_Image:SetPos( 2 + ( targetSize - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		end

		self:SetTextInset( self.m_Image:GetWide() + 16, 0 )

	end

	DLabel.PerformLayout( self, w, h )

end

function PANEL:SetConsoleCommand( strName, strArgs )

	self.DoClick = function( slf, val )
		RunConsoleCommand( strName, strArgs )
	end

end

function PANEL:SizeToContents()
	local w, h = self:GetContentSize()
	self:SetSize( w + 8, h + 4 )
end

local PANEL = derma.DefineControl( "FButton", "Custom Button", PANEL, "DLabel" )