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
	print( line )
end

local w = display.viewableContentWidth
local h = display.viewableContentHeight

local frame = {
	container = display.newRect( 0, 0, w, h ),
	reflectX = true,
}

local cloudFrame = {
	container = display.newRect( 0, 0, w, h ),
	reflectX = true,
}

local board = {
	container = display.newRect( 0, 0, w, h),
	reflectX = true,
}

display.setStatusBar( display.HiddenStatusbar )

local openScreen = display.newGroup()

local lvl = 1

local background = display.newImage("bg.png")
openScreen:insert( background, true)
background.x = 160; background.y = 240
background.width = w; background.height = h;

local titleScreen = display.newGroup()

local title = display.newImage("logo.png")
local touch = display.newImage("touch.png")
local q = display.newImage("block.png")

titleScreen:insert( title, true )
titleScreen:insert( touch, true )
titleScreen:insert( q, true )
title.x = 160; title.y = 160;
touch.x = 160; touch.y = 300;
q.x = 160; q.y = 240;

local head = display.newImage("logoblk.png")		
titleScreen:insert( head , true )
head.x = 60; head.y = 50; head.alpha = 0;

local new = display.newImage("newgame.png")		
titleScreen:insert( new , true )
new.x = 220; new.y = 200; new.alpha = 0;

local tut = display.newImage("tut.png")		
titleScreen:insert( tut , true )
tut.x = 220; tut.y = 250; tut.alpha = 0;

local highs = display.newImage("highscores.png")		
titleScreen:insert( highs , true )
highs.x = 220; highs.y = 300; highs.alpha = 0;

local restart = display.newImage("restart.png")		
titleScreen:insert( restart , true )
restart.x = 30; restart.y = 60; restart.alpha = 0;

local complete = display.newImage("complete.png")		
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
local touchAlphaDec = .02
local numParticles = 40
local particleFile = "particle.png"


local numClouds = 600
local cloudFile = "cloud.png"

local rowsize = 5
local colsize = 5
local pan = 65
local bw = w - 80;
local bh = h - 80;
local top = (bh - bw) / 2

--local debug = display.newText( "debug", 20, 20, "Helvetica", 16 )

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

local function toggle ( b )
	if ( b.alpha == .2 ) then
		b.alpha = 1
	else
		b.alpha = .2
	end
end

local function createClouds()
	for i=1, numClouds do
		
		local c = display.newImage( cloudFile )
		openScreen:insert(c)
		
		c.x = math.random( 1, w )
		c.y = math.random( h, h + 20 )
		
		c.vx = math.random( -3, 3 )
		c.vy = math.random( -10, -1 )
		
		cloudFrame[ #cloudFrame + 1 ] = c

	end
end

local function removeClouds()
	for _,p in ipairs( cloudFrame ) do
		p.x = 10000
		p.vy = 1
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
			if (b.alpha == 1) then lights = lights + 1 end
		end
		
		if (lights == 0) then
			levelComplete = true;
			removeComplete = false
			createClouds();
		end
	end
end

local function restartLevel ( event )
	if ( event.phase == "began" ) then
		for _,b in ipairs( board ) do
			b.alpha = 1;
		end
	end
end

local function nextLevel ( event )
	removeClouds()
	removeComplete = true;

	for _,b in ipairs( board ) do
		b.alpha = 1;
	end
	
	restartRot = true
	levelComplete = false
	
end

local function createBoard()
	
	local row; local col;
	
	for row = 1, rowsize do
		for col = 1, colsize do
			local b = display.newImage("blocksmall.png")
			b.x = (col-1) * bw / rowsize + pan
			b.y = top + (row-1) * bw / colsize + pan
			
			print( lvlArray[lvl].sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize + 1) )
			
			if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
				b.alpha = 1
			else
				b.alpha = .2
			end
			
			--b.width = bw; b.height = bh;
			b:addEventListener( "touch", blockTouch )
			board[ #board + 1 ] = b			
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
	
	for _,p in ipairs( cloudFrame ) do
		
		local newAlpha = p.alpha - alphaDec
		
		p:translate( p.vx, p.vy )
		
		if (p.alpha > 0 and p.y < h ) then
			p.alpha = newAlpha
		end
		
		if (p.y < 0 and p.x < 300) then
			p.y = h + 50
			p.x = math.random( 1, w )
			p.vx = math.random( -3, 3 )
			p.vy = math.random( -10, -1 )
			p.alpha = 1
		end
		
	end
	
	--check for gameplay
	if removeTitle == true then
		q:rotate(1)
		q.y = q.y - 3
		title.alpha = title.alpha - .01
		touchAlphaDec = .01
		
		if q.y < -30 then
			q:removeSelf()
			touch:removeSelf()
			titleComplete = true;
			removeTitle = false;
		end
		
	end
	
	if head.alpha < 1 and titleComplete == true then
		head.alpha = head.alpha + .01
		new.alpha = new.alpha + .01
		tut.alpha = tut.alpha + .01
		highs.alpha = highs.alpha + .01
	end
	
	if head.alpha > 0 and (newGame == true or showTut == true or showScores == true) then
		head.alpha = head.alpha - .02
		new.alpha = new.alpha - .02
		tut.alpha = tut.alpha - .03
		highs.alpha = highs.alpha - .04
	end
	
	if head.alpha <= 0 and newGame == true and gameStarted == false then
		createBoard()
		restartRot = true;
		gameStarted = true;
	end
	
	if (restartRot == true) then
		restart:rotate(1)
		restart:addEventListener( "touch", restartLevel )
		
		if (restart.alpha <= 1) then
			restart.alpha = restart.alpha + .02
		end
		
	end
	
	if (levelComplete == true) then
		if ( complete.alpha < 1 ) then
			complete.alpha = complete.alpha + .01
		end
		
		if ( levelComplete == true and restart.alpha > 0 ) then
			restart.alpha = restart.alpha - .02
		end
		
		for _,b in ipairs( board ) do
			if (b.alpha > 0) then b.alpha = b.alpha - .01 end
		end
		
		restartRot = false;
		
		complete:addEventListener( "touch", nextLevel )
		

	end
	
	if (removeComplete == true) then
		complete.alpha = complete.alpha - .03
	end
	
	if (titleComplete == false) then
		
		if (touch.alpha <= 1 and touch.alpha >= 0) then
			touch.alpha = touch.alpha - touchAlphaDec
		end
		
		if ( aStep == 100 and removeTitle == false ) then
			touchAlphaDec = touchAlphaDec * -1
			aStep = 0
		end
		
		aStep = aStep + 1
	
	end
	
end

local function onTouch ( event )
	if ( event.phase == "began" ) then
		removeTitle = true;
	end
	
	print (event.phase)
end
q:addEventListener("touch", onTouch )

local function newGameClicked ( event )
	if ( event.phase == "began" ) then
		newGame = true;
		print("new game")
	end
	
	print (event.phase)
end
new:addEventListener("touch", newGameClicked )

local function showTutorials ( event )
	if ( event.phase == "began" ) then
		showTut = true;
		print("tutorial")
	end
end
tut:addEventListener("touch", showTutorials )

local function showHighScores ( event )
	if ( event.phase == "began" ) then
		showScores = true;
		print("scores")
	end
end
highs:addEventListener("touch", showHighScores )

Runtime:addEventListener( "enterFrame", frame )


