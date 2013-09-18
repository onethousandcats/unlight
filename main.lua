-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local levelPath = system.pathForFile( "levels.txt" )

local f = io.open( levelPath, "r" )

local lvlArray = {}

for line in f:lines() do
	lvlArray[ #lvlArray + 1 ] = line
end

io.close(f)

local currentInfo = system.pathForFile( "current.txt" )

local cur = io.open( currentInfo, "r" )

local info = {}

for line in cur:lines() do 
	info[ #info + 1 ] = line
end

local w = display.viewableContentWidth
local h = display.viewableContentHeight

local frame = {
	container = display.newRect( 0, 0, w, h ),
	reflectX = true,
}

local board = {
	container = display.newRect( 0, 0, w, h),
	reflectX = true,
}

display.setStatusBar( display.HiddenStatusbar )

local openScreen = display.newGroup()

local savedLvl = tonumber(info[1])
local lvl = 1

local g = graphics.newGradient(
	{ 156, 250, 232 },
	{ 77, 144, 208 },
	"up"
)

local background = display.newRect(0, 0, w, h)
background:setFillColor(g)
openScreen:insert( background, true)
background.x = 160; background.y = 240
background.width = w; background.height = h;

local titleScreen = display.newGroup()

local title = display.newText("unlight", w / 2, 160, "Infinity", 72)
local touch = display.newText("touch to start", 160, 300, "Infinity", 24)
local q = display.newImage("block.png")

titleScreen:insert( title, true )
titleScreen:insert( touch, true )
titleScreen:insert( q, true )
title.x = 160; title.y = 160; 
touch.x = 160; touch.y = 300; touch.alpha = 0;
q.x = 160; q.y = 240;

local head = display.newImage("block.png")		
titleScreen:insert( head , true )
head.x = w / 2; head.y = 120; head.alpha = 0;

local cont = display.newText("continue", w / 2, 230, "Infinity", 36)
titleScreen:insert( cont , true )
cont.x = w / 2; cont.y = 210; cont.alpha = 0;
	
local new = display.newText("new game", w / 2, 230, "Infinity", 36)
titleScreen:insert( new , true )
new.x = w / 2; new.y = cont.y + 50; new.alpha = 0;
	
local tut = display.newText("tutorial", 160, 300, "Infinity", 36)
titleScreen:insert( tut , true )
tut.x = w / 2; tut.y = new.y + 50; tut.alpha = 0;

local settings = display.newText("settings", 160, 300, "Infinity", 36)		
titleScreen:insert( settings , true )
settings.x = w / 2; settings.y = tut.y + 50; settings.alpha = 0;

local restart = display.newImage("restart.png")		
titleScreen:insert( restart , true )
restart.x = 60; restart.y = 64; restart.alpha = 0;

local lvlTxt = display.newText( lvl / 10 + 1, w - 70, 50, "Infinity", 24)
lvlTxt.alpha = 0;

local menu = display.newText( "menu", w / 2, 50, "Infinity", 24)
menu.alpha = 0; menu.x = w / 2;

local complete = display.newText( "stage complete", w / 2, h / 2, "Infinity", 42)
titleScreen:insert( complete , true )
complete.x = w / 2; complete.y = h / 2; complete.alpha = 0;

local removeTitle = false;
local titleComplete = false;
local newGame = false;
local showTut = false;
local showScores = false;
local gameStarted = false;
local showMenu = false;
local restartRot = false;
local levelComplete = false;
local removeComplete = false;

local alphaDec = .01
local numParticles = 40
local particleFile = "particle.png"

local rowsize = 5
local colsize = 5
local pan = 65
local bw = w - 80;
local bh = h - 80;
local top = (bh - bw) / 2

--add particles
for i=1, numParticles do
	
	local particle = display.newImage( particleFile )
	openScreen:insert(particle)
	
	particle.x = math.random( 1, w )
	particle.y = h + math.random( 5, 400 )
	
	particle.vx = math.random( -3, 3 )
	particle.vy = math.random( -10, -1 )
	
	frame[ #frame + 1 ] = particle

end

local blink, remove, removeAndContinue

function remove ( obj )
	obj:removeSelf();
end

function removeAndContinue ( obj )
	obj:removeSelf();
	
	--show options
	if ( savedLvl > 0 ) then transition.to( cont, { time = 1400, alpha = 1 }) end
	transition.to( new, { time = 1400, alpha = 1 })
	transition.to( tut, { time = 1400, alpha = 1 })
	transition.to( settings, { time = 1400, alpha = 1 })
	transition.to( head, { time = 1400, alpha = 1 })
end

function blink ( obj )
	if ( obj.alpha == 1 ) then		
		transition.to( obj, { time = 2000, alpha = 0, onComplete = blink })
	else
		transition.to( obj, { time = 2000, alpha = 1, onComplete = blink })
	end
end

--main screen setup
transition.to( touch, { time = 2000, alpha = 0, onComplete = blink })

local function toggle ( b )
	if ( b.alpha == .2 ) then
		b.alpha = 1
	else
		b.alpha = .2
	end
end

local function blockTouch ( event )
	if ( event.phase == "began" ) then

		local b = event.target
		bx = (event.target.x - pan) * rowsize / bw + 1
		by = (event.target.y - top - pan) * colsize / bw + 1
		
		index = bx + (by - 1) * rowsize
		iu = bx + (by - 2) * rowsize
		id = bx + by * rowsize
		
		if (bx > 1) then
			toggle(board[index - 1])
		end
		
		if (bx < rowsize) then
			toggle(board[index + 1])
		end
		
		if (by > 1) then
			toggle(board[iu])
		end
		
		if (by < colsize) then
			toggle(board[id])
		end
		
		toggle(b)
		
		local lights = 0
		--check endgame
		for _,b in ipairs( board ) do
			if (b.alpha > .2) then lights = lights + 1 end
		end
		
		if (lights == 0) then

			--level is completed successfully

			--record level in log
			local f = io.open( currentInfo, "w" )
			f:write( lvl )

			io.close( f )
			f = nil

			for _,b in ipairs( board ) do
				transition.to( b, { time = 1200, alpha = 0 })
			end

			transition.to( lvlTxt, { time = 1000, alpha = 0 })
			transition.to( menu, { time = 1000, alpha = 0 })
			transition.to( restart, { time = 1000, alpha = 0 })	
			
			transition.to( complete, { time = 1000, alpha = 1 })
		end
	end
end

local function restartLevel ( event )
	if ( event.phase == "began" ) then

		for _,b in ipairs( board ) do
			b:removeEventListener( "touch", blockTouch )
		end

		for row = 1, rowsize do
			for col = 1, colsize do
				if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
					transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = 1 } )
				else
					transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = .2 } )
				end	
			end
		end

		for _,b in ipairs( board ) do
			b:addEventListener( "touch", blockTouch )
		end

	end
end

local function nextLevel ( event )
	if ( event.phase == "began" ) then

		for _,b in ipairs( board ) do
			b:removeEventListener( "touch", blockTouch )
		end

		transition.to( complete, { time = 1200, alpha = 0 })
		lvl = lvl + 1;
		
		local row; local col;
		
		for row = 1, rowsize do
			for col = 1, colsize do
				if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
					transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = 1 } )
				else
					transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = .2 } )
				end
			end
		end
		
		for _,b in ipairs( board ) do
			b:addEventListener( "touch", blockTouch )
		end

		lvlTxt.text = lvl / 10 + 1
		transition.to( lvlTxt, { time = 500, delay = 0, alpha = 1 })
		transition.to( menu, { time = 500, delay = 0, alpha = 1 })
		transition.to( restart, { time = 500, delay = 0, alpha = 1 })	
	end
end

local function showLevel( event )

	for _,b in ipairs( board ) do
		b:removeEventListener( "touch", blockTouch )
	end
	
	local row; local col;
	
	for row = 1, rowsize do
		for col = 1, colsize do
			if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
				transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = 1 } )
			else
				transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = .2 } )
			end
		end
	end
	
	for _,b in ipairs( board ) do
		b:addEventListener( "touch", blockTouch )
	end

	lvlTxt.text = lvl / 10 + 1
	transition.to( lvlTxt, { time = 500, delay = 0, alpha = 1 })
	transition.to( menu, { time = 500, delay = 0, alpha = 1 })
	transition.to( restart, { time = 500, delay = 0, alpha = 1 })	


end


local function addListeners( )
	local row; local col;
	
	for row = 1, rowsize do
		for col = 1, colsize do
			board[(row - 1) * rowsize + col]:addEventListener( "touch", blockTouch )		
		end
	end	
end

local function createBoard( )
	local row; local col;
	
	for row = 1, rowsize do
		for col = 1, colsize do

			local b = display.newRect(0, 0, 34, 34)

			b.x = (col-1) * bw / rowsize + pan
			b.y = top + (row-1) * bw / colsize + pan
			
			b.alpha = 0

			local ca = 0

			if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
				ca = 1
			else
				ca = .2
			end

			if ( row < rowsize and col < colsize ) then
				transition.to(b, { time = 1500, alpha = ca } )
			else
				transition.to(b, { time = 1500, alpha = ca, onComplete = addListeners })
			end

			board[ #board + 1 ] = b

			transition.to( lvlTxt, { time = 1500, delay = 0, alpha = 1 })	
			transition.to( menu, { time = 1500, delay = 500, alpha = 1 })	
			transition.to( restart, { time = 1500, delay = 0, alpha = 1 })		
		end
	end

end

local aStep = 0

function frame:enterFrame( event )
	
	for _,p in ipairs( frame ) do
		
		local newAlpha = p.alpha - alphaDec
		
		p:translate( p.vx, p.vy )
		
		if (p.alpha > 0 and p.y < h ) then
			p.alpha = newAlpha
		end
		
		if (p.y < 0) then
			p.y = h + 50
			p.x = math.random( 1, w )
			p.vx = math.random( -3, 3 )
			p.vy = math.random( -10, -1 )
			p.alpha = 1
		end
		
	end

	head:rotate(3)
	restart:rotate(1)
	
end

local function onTouch ( event )
	if ( event.phase == "began" ) then
		transition.to( touch, { time = 2000, alpha = 0, onComplete = remove } )
		transition.to( q, { time = 2000, rotation = 90, y = -30, onComplete = remove } )
		transition.to( title, { time = 2000, alpha = 0, onComplete = removeAndContinue })
	end
end

local function goToMenu ( event )
	if ( event.phase == "began" ) then

		for _,b in ipairs( board ) do
			transition.to( b, { time = 500, delay = 0, alpha = 0 })	
		end

		transition.to( lvlTxt, { time = 500, delay = 0, alpha = 0 })	
		transition.to( menu, { time = 500, delay = 0, alpha = 0 })	
		transition.to( restart, { time = 500, delay = 0, alpha = 0 })	

		if ( savedLvl > 0 ) then transition.to( cont, { time = 1400, alpha = 1 }) end
		transition.to( new, { time = 1400, alpha = 1 })
		transition.to( tut, { time = 1400, alpha = 1 })
		transition.to( settings, { time = 1400, alpha = 1 })
		transition.to( head, { time = 1400, delay = 500, alpha = 1 })
	end
end

local function newGameClicked ( event )
	if ( event.phase == "began" ) then

		lvl = 1
		lvlTxt.text = lvl / 10 + 1

		transition.to( cont, { time = 1200, alpha = 0 })
		transition.to( new, { time = 1200, alpha = 0 })
		transition.to( tut, { time = 1200, alpha = 0 })
		transition.to( settings, { time = 1200, alpha = 0 })
		if ( #board == 0 ) then 
			transition.to( head, { time = 1200, alpha = 0, onComplete = createBoard })
		else
			transition.to( head, { time = 1200, alpha = 0, onComplete = showLevel })
		end
	end
end

local function continueClicked ( event )
	if ( event.phase == "began" ) then

		lvl = savedLvl + 1
		lvlTxt.text = lvl / 10 + 1

		transition.to( cont, { time = 1200, alpha = 0 })
		transition.to( new, { time = 1200, alpha = 0 })
		transition.to( tut, { time = 1200, alpha = 0 })
		transition.to( settings, { time = 1200, alpha = 0 })
		if ( #board == 0 ) then 
			transition.to( head, { time = 1200, alpha = 0, onComplete = createBoard })
		else
			transition.to( head, { time = 1200, alpha = 0, onComplete = showLevel })
		end
	end
end

local function showTutorials ( event )
	if ( event.phase == "began" ) then

	end
end

local function showSettings ( event )
	if ( event.phase == "began" ) then

	end
end

q:addEventListener("touch", onTouch )

cont:addEventListener("touch", continueClicked )

new:addEventListener("touch", newGameClicked )

tut:addEventListener("touch", showTutorials )

settings:addEventListener("touch", showSettings )

Runtime:addEventListener( "enterFrame", frame )

complete:addEventListener( "touch", nextLevel )

restart:addEventListener( "touch", restartLevel )

menu:addEventListener("touch", goToMenu )


