-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local levelPath = system.pathForFile( "levels.txt" )

local f = io.open( levelPath, "r" )

local lvlArray = {}
local tb = {}

for line in f:lines() do
	lvlArray[ #lvlArray + 1 ] = line
end

io.close(f)

local tutPath = system.pathForFile( "tutorial.txt" )

local tf = io.open( tutPath, "r" )

local tutArray = {}

for line in tf:lines() do
	tutArray[ #tutArray + 1 ] = line
end

io.close(tf)

local currentInfo = system.pathForFile( "current.txt" )

local cur = io.open( currentInfo, "r" )

local info = {}

for line in cur:lines() do 
	info[ #info + 1 ] = line
end

local w = display.viewableContentWidth
local h = display.viewableContentHeight

local dw = display.pixelWidth
local dh = display.pixelHeight

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
local tutLvl = 1
local theme = info[2]

local g = graphics.newGradient(
	{ 133, 215, 199 },
	{ 77, 144, 208 },
	"down"
)

if ( theme == "dark" ) then
	g = graphics.newGradient(
		{ 142, 23, 0 },
		{ 255, 166, 50 },
		"up"
	)
end

--sounds

audio.setVolume(.1)

local touchSounds = {}

touchSounds[ 1 ] = audio.loadSound("one.m4a")
touchSounds[ 2 ] = audio.loadSound("two.m4a") 
touchSounds[ 3 ] = audio.loadSound("three.m4a")
touchSounds[ 4 ] = audio.loadSound("four.m4a")

local curSound = 1;

--end

local background = display.newRect(0, 0, dw, dh)
background:setFillColor(g)
openScreen:insert( background, true)
background.x = dw/2; background.y = dh/2
background.width = dw; background.height = dh;

local titleScreen = display.newGroup()

local title = display.newText("unlight", w / 2, w / 2, "Infinity", 72)
local touch = display.newText("touch to start", w / 2, 300, "Infinity", 24)
local q = display.newImage("block.png")

titleScreen:insert( title, true )
titleScreen:insert( touch, true )
titleScreen:insert( q, true )
title.x = w / 2; title.y = h * .3; 
touch.x = w / 2; touch.y = h * .6; touch.alpha = 0;
q.x = w / 2; q.y = h / 2;

local head = display.newImage("block.png")		
titleScreen:insert( head , true )
head.x = w / 2; head.y = 120; head.alpha = 0;

local cont = display.newText("continue", w / 2, 230, "Infinity", 36)
titleScreen:insert( cont , true )
cont.x = w / 2; cont.y = 210; cont.alpha = 0;
	
local new = display.newText("new game", w / 2, 230, "Infinity", 36)
titleScreen:insert( new , true )
new.x = w / 2; new.y = cont.y + 50; new.alpha = 0;
	
local tut = display.newText("tutorial", w / 2, 300, "Infinity", 36)
titleScreen:insert( tut , true )
tut.x = w / 2; tut.y = new.y + 50; tut.alpha = 0;

local settings = display.newText("settings", w / 2, 300, "Infinity", 36)		
titleScreen:insert( settings , true )
settings.x = w / 2; settings.y = tut.y + 50; settings.alpha = 0;

local restart = display.newImage("restart.png")		
titleScreen:insert( restart , true )
restart.x = 60; restart.y = 64; restart.alpha = 0;

local lvlTxt = display.newText( lvl / 10 + 1, w - 70, 50, "Infinity", 24)
lvlTxt.alpha = 0;

local timer = display.newRect(0, 0, 220, 10)
titleScreen:insert( timer, true )
timer.x, timer.y, timer.alpha = w / 2, 90, 0

local menu = display.newText( "menu", w / 2, 50, "Infinity", 24)
menu.alpha = 0; menu.x = w / 2;

local complete = display.newText( "stage complete", w / 2, h / 2, "Infinity", 42)
titleScreen:insert( complete , true )
complete.x = w / 2; complete.y = h / 2; complete.alpha = 0;

-----------------------------------------------------------

local thm = display.newText("theme", w / 2, 230, "Infinity", 36)
titleScreen:insert( thm , true )
thm.x = w / 2; thm.y = 210; thm.alpha = 0;

local sounds = display.newText("sounds", w / 2, 300, "Infinity", 36)
titleScreen:insert( sounds , true )
sounds.x = w / 2; sounds.y = thm.y + 50; sounds.alpha = 0;

local ret = display.newText("return", w / 2, 300, "Infinity", 36)		
titleScreen:insert( ret , true )
ret.x = w / 2; ret.y = sounds.y + 50; ret.alpha = 0;

-----------------------------------------------------------

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

		--play sound
		--local touchChannel = audio.play( touchSounds[ curSound ] )

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
			f:write( lvl + 1, "\n" )
			f:write( theme )

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

	if (event.phase == "ended" or event.phase == "cancelled") then
		curSound = curSound + 1

		if curSound > 5 then curSound = 1 end
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

local function gameEnded ( event )
	lvl = 1
	savedLvl = lvl

	local congrats = display.newText("Status:945730 : Killscreen Reached", 10, 70, "Infinity", 24, "left" )
	congrats.alpha = 0;

	local info = display.newText("Human testing cycle fulfilled.", 20, 140, "Infinity", 18, "left" )
	info.alpha = 0; 

	local info1 = display.newText("Expectations were exceeded by user...", 20, 170, "Infinity", 18, "left" )
	info1.alpha = 0; 

	local info2 = display.newText("Metrics:", 20, 200, "Infinity", 18, "left" )
	info2.alpha = 0; 

	local s1 = display.newRect(0, 0, 6, 6)
	s1.x, s1.y, s1.alpha = 40, 260, 0

	local t1 = display.newText("Score", 52, 253, "Infinity", 16, "left" )
	t1.alpha = 0;

	local s2 = display.newRect(0, 0, 6, 6)
	s2.x, s2.y, s2.alpha = 40, 290, 0

	local t2 = display.newText("Average Time", 52, 283, "Infinity", 16, "left" )
	t2.alpha = 0;

	local s3 = display.newRect(0, 0, 6, 6)
	s3.x, s3.y, s3.alpha = 40, 320, 0

	local t3 = display.newText("Lapsed Time", 52, 313, "Infinity", 16, "left" )
	t3.alpha = 0;

	local s4 = display.newRect(0, 0, 6, 6)
	s4.x, s4.y, s4.alpha = 40, 350, 0

	local t4 = display.newText("Enhanced user experience", 52, 343, "Infinity", 16, "left" )
	t4.alpha = 0;

	transition.to( congrats, { time = 1800, delay = 2000, alpha = 1 })
	transition.to( info, { time = 1800, delay = 2000, alpha = 1 })
	transition.to( info1, { time = 1800, delay = 2000, alpha = 1 })
	transition.to( info2, { time = 1800, delay = 2000, alpha = 1 })

	transition.to( s1, { time = 1800, delay = 2200, alpha = 1 })
	transition.to( s2, { time = 1800, delay = 2400, alpha = 1 })
	transition.to( s3, { time = 1800, delay = 2600, alpha = 1 })
	transition.to( s4, { time = 1800, delay = 2800, alpha = 1 })

	transition.to( t1, { time = 1800, delay = 2300, alpha = 1 })
	transition.to( t2, { time = 1800, delay = 2500, alpha = 1 })
	transition.to( t3, { time = 1800, delay = 2700, alpha = 1 })
	transition.to( t4, { time = 1800, delay = 2900, alpha = 1 })


end

local function nextLevel ( event )
	if ( event.phase == "began" ) then

		for _,b in ipairs( board ) do
			b:removeEventListener( "touch", blockTouch )
		end

		transition.to( complete, { time = 1200, alpha = 0 })

		if #lvlArray == lvl then
			gameEnded()
			return
		end
		
		lvl = lvl + 1
		savedLvl = lvl
		
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

local function returnToMenu ( event )
	if ( event.phase == "began" ) then
		transition.to( thm, { time = 500, delay = 0, alpha = 0 })	
		transition.to( sounds, { time = 500, delay = 0, alpha = 0 })	
		transition.to( ret, { time = 500, delay = 0, alpha = 0 })

		if ( savedLvl > 0 ) then transition.to( cont, { time = 1400, alpha = 1 }) end
		transition.to( new, { time = 1400, alpha = 1 })
		transition.to( tut, { time = 1400, alpha = 1 })
		transition.to( settings, { time = 1400, alpha = 1 })

		transition.to( head, { time = 1000, y = 120 })
	end
end

local function changeTheme ( event )
	if ( event.phase == "began" ) then

		if (theme == "light") then
			theme = "dark"

			g = graphics.newGradient(
				{ 142, 23, 0 },
				{ 255, 166, 50 },
				"up"
			)

			background:setFillColor(g)

		else
			theme = "light"

			g = graphics.newGradient(
				{ 156, 250, 232 },
				{ 77, 144, 208 },
				"down"
			)

			background:setFillColor(g)
		end

		background:setFillColor(g)

		--record theme in log
		local f = io.open( currentInfo, "w" )
		f:write( lvl, "\n" )
		f:write( theme )

		io.close( f )
		f = nil

	end
end

local function continueClicked ( event )
	if ( event.phase == "began" ) then

		lvl = savedLvl
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

local function tutorialToMain ( event )
	if ( event.phase == "began" ) then

		for row = 1, 3 do
			for col = 1, 3 do
				tb[(row - 1) * 3 + col]:removeSelf()
			end
		end

		transition.to( event.target, { time = 1000, alpha = 0 })

		if ( savedLvl > 0 ) then transition.to( cont, { time = 1400, alpha = 1 }) end
		transition.to( new, { time = 1400, alpha = 1 })
		transition.to( tut, { time = 1400, alpha = 1 })
		transition.to( settings, { time = 1400, alpha = 1 })
		transition.to( head, { time = 1400, delay = 500, alpha = 1 })

		tutLvl = 1
	end
end

local function tutorialEndPuzzleInterim ( event )
	if ( event.phase == "began" ) then
		for _,b in ipairs( tb ) do
			transition.to( b, { time = 400, alpha = .2 })
			transition.to( b, { time = 1000, alpha = 0, delay = 600 })
		end

		local comp = display.newText("go forth and unlight", w / 2, h / 2, "Infinity", 32, "center" )
		comp.alpha = 0; comp.x = w / 2;

		transition.to( comp, { time = 1800, delay = 2000, alpha = 1 })
		comp:addEventListener( "touch", tutorialToMain )
	end
end

local function tutFirstTouch ( event )
	if ( event.phase == "began" ) then

		local b = event.target

		b:removeEventListener( "touch", tutFirstTouch )
		tb[(2 - 1) * 3 + 3]:addEventListener("touch", tutorialEndPuzzleInterim )
		
		toggle(b)

		toggle(tb[(2 - 1) * 3 + 3])
		toggle(tb[(3 - 1) * 3 + 2])
		toggle(tb[(1 - 1) * 3 + 2])
		toggle(tb[(2 - 1) * 3 + 1])
		
	end
end

local function tutorialThirdPuzzle ( event )
	if ( event.phase == "began" ) then

        transition.to( event.target, { time = 1000, alpha = 0 })

		tutLvl = tutLvl + 1

		for row = 1, 3 do
			for col = 1, 3 do
				local ca = 0

				if (tutArray[tutLvl]:sub(row + (col - 1) * 3, row + (col - 1) * 3) == "1") then
					ca = 1
				else
					ca = .2
				end

				transition.to(tb[(row - 1) * 3 + col], { time = 1500, alpha = ca } )

				if ( row == 2 and col == 2 ) then
					tb[(row - 1) * 3 + col]:addEventListener( "touch", tutFirstTouch )
				end
			end
		end		
	end
end

local function tutorialThirdPuzzleInterim ( event )
	if ( event.phase == "began" ) then
		
		event.target:removeEventListener( "touch", tutorialThirdPuzzleInterim )

		for _,b in ipairs( tb ) do
			transition.to( b, { time = 400, alpha = .2 })
			transition.to( b, { time = 1000, alpha = 0, delay = 600 })
		end

		local comp = display.newText("great, one last test", w / 2, h / 2, "Infinity", 32, "center" )
		comp.alpha = 0; comp.x = w / 2;

		transition.to( comp, { time = 1800, delay = 2000, alpha = 1 })
		comp:addEventListener( "touch", tutorialThirdPuzzle )

	end
end

local function tutorialSecondPuzzle ( event )
	if ( event.phase == "began" ) then
		
        transition.to( event.target, { time = 1000, alpha = 0 })

		tutLvl = tutLvl + 1

		for row = 1, 3 do
			for col = 1, 3 do
				local ca = 0

				if (tutArray[tutLvl]:sub(row + (col - 1) * 3, row + (col - 1) * 3) == "1") then
					ca = 1
				else
					ca = .2
				end

				transition.to(tb[(row - 1) * 3 + col], { time = 1500, alpha = ca } )

				if ( row == 2 and col == 3 ) then
					tb[(row - 1) * 3 + col]:addEventListener( "touch", tutorialThirdPuzzleInterim )
				end
			end
		end
	end
end

local function tutorialFirstPuzzle ( event )
	if ( event.phase == "began" ) then
		
		event.target:removeEventListener( "touch", tutorialFirstPuzzle )

		for _,b in ipairs( tb ) do
			transition.to( b, { time = 400, alpha = .2 })
			transition.to( b, { time = 1000, alpha = 0, delay = 600 })
		end

		local comp = display.newText("good, now try this one", w / 2, h / 2, "Infinity", 32, "center" )
		comp.alpha = 0; comp.x = w / 2;

		transition.to( comp, { time = 1800, delay = 2000, alpha = 1 })
		comp:addEventListener( "touch", tutorialSecondPuzzle )

	end
end

local function tutBoard ( event )

	if ( event.phase == "began" ) then
		
		transition.to( event.target, { time = 1200, alpha = 0 })

		for row = 1, 3 do
			for col = 1, 3 do

				local b = display.newRect(0, 0, 34, 34)

				b.x = (col-1) * bw / rowsize + pan + 50
				b.y = top + (row-1) * bw / colsize + pan + 50
				
				b.alpha = 0

				local ca = 0

				if (tutArray[tutLvl]:sub(row + (col - 1) * 3, row + (col - 1) * 3) == "1") then
					ca = 1
				else
					ca = .2
				end

				transition.to(b, { time = 1500, alpha = ca } )

				tb[ #tb + 1 ] = b

				if ( row == 2 and col == 2 ) then
					b:addEventListener("touch", tutorialFirstPuzzle )
				end
		
			end
		end

	end
end

local function showTutorials ( event )
	if ( event.phase == "began" ) then
		transition.to( cont, { time = 1200, alpha = 0 })
		transition.to( new, { time = 1200, alpha = 0 })
		transition.to( tut, { time = 1200, alpha = 0 })
		transition.to( settings, { time = 1200, alpha = 0 })
		transition.to( head, { time = 1200, alpha = 0 })

		local intro = display.newText("welcome to unlight", w / 2, h / 2, "Infinity", 32, "center" )
		intro.alpha = 0; intro.x = w / 2;

		transition.to( intro, { time = 1800, alpha = 1 })
		transition.to( intro, { time = 1800, delay = 2000, alpha = 0 })

		local goal = display.newText("turn off all of the lights", w / 2, h / 2, "Infinity", 32, "center" )
		goal.alpha = 0; goal.x = w / 2;

		transition.to( goal, { time = 1800, delay = 4000, alpha = 1 })
		goal:addEventListener( "touch", tutBoard )

	end
end

local function showSettings ( event )
	if ( event.phase == "began" ) then
		transition.to( cont, { time = 1200, alpha = 0 })
		transition.to( new, { time = 1200, alpha = 0 })
		transition.to( tut, { time = 1200, alpha = 0 })
		transition.to( settings, { time = 1200, alpha = 0 })

		transition.to( head, { time = 1000, y = 100 })

		transition.to( thm, { time = 1000, alpha = 1 })
		transition.to( sounds, { time = 1200, alpha = 1 })
		transition.to( ret, { time = 1200, alpha = 1 })
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

-------------------------------------------------

ret:addEventListener("touch", returnToMenu )

thm:addEventListener("touch", changeTheme )
