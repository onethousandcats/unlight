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

--local title = display.newImage("logo.png")
local title = display.newText("unlight", w / 2, 160, "Infinity", 72)
--local touch = display.newImage("touch.png")
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

--local new = display.newImage("newgame.png")		
local new = display.newText("new game", w / 2, 230, "Infinity", 36)
titleScreen:insert( new , true )
new.x = w / 2; new.y = 230; new.alpha = 0;

--local tut = display.newImage("tut.png")		
local tut = display.newText("tutorial", 160, 300, "Infinity", 36)
titleScreen:insert( tut , true )
tut.x = w / 2; tut.y = 280; tut.alpha = 0;

--local highs = display.newImage("highscores.png")
local highs = display.newText("high scores", 160, 300, "Infinity", 36)		
titleScreen:insert( highs , true )
highs.x = w / 2; highs.y = 330; highs.alpha = 0;

local restart = display.newImage("restart.png")		
titleScreen:insert( restart , true )
restart.x = 30; restart.y = 60; restart.alpha = 0;

local lvlTxt = display.newText( lvl / 10 + 1, w - 70, 50, "Infinity", 24)
lvlTxt.alpha = 0;

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

function remove ( obj )
	obj:removeSelf();
	titleComplete = true;
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
			lvl = lvl + 1;
			removeComplete = false;
			createClouds();
		end
	end
end

local function restartLevel ( event )
	if ( event.phase == "began" ) then

		for row = 1, rowsize do
			for col = 1, colsize do
				
				if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
					transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = 1 } )
				else
					transition.to(board[(row - 1) * rowsize + col], { time = 1500, alpha = .2 } )
				end
						
			end
		end
	end
end

local function nextLevel ( event )
	removeClouds()
	removeComplete = true;

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
	
	restartRot = true
	levelComplete = false
	transition.to( lvlTxt, { time = 500, delay = 0, alpha = 1 })
	
end

local function createBoard()
	
	local row; local col;
	
	for row = 1, rowsize do
		for col = 1, colsize do
			local b = display.newImage("blocksmall.png")
			b.x = (col-1) * bw / rowsize + pan
			b.y = top + (row-1) * bw / colsize + pan
			
			b.alpha = 0

			if (lvlArray[lvl]:sub(row + (col - 1) * rowsize, row + (col - 1) * rowsize) == "1") then
				transition.to(b, { time = 1500, alpha = 1 } )
			else
				transition.to(b, { time = 1500, alpha = .2 } )
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
	--if removeTitle == true then
		--q:rotate(1)
		--q.y = q.y - 3
		--title.alpha = title.alpha - .01
		
		--if q.y < -30 then
		--	q:removeSelf()
			
		--	titleComplete = true;
		--	removeTitle = false;
		--end
		
	--end
	
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

	head:rotate(3)
	
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
	
end

local function onTouch ( event )
	if ( event.phase == "began" ) then
		transition.to( touch, { time = 2000, alpha = 0, onComplete = remove } )
		transition.to( q, { time = 2000, rotation = 90, y = -30, onComplete = remove } )
		transition.to( title, { time = 2000, alpha = 0, onComplete = removeAndContinue })
	end
end

local function newGameClicked ( event )
	if ( event.phase == "began" ) then
		newGame = true;
		print("new game")
	end
	
	print (event.phase)
end

local function showTutorials ( event )
	if ( event.phase == "began" ) then
		showTut = true;
		print("tutorial")
	end
end

local function showHighScores ( event )
	if ( event.phase == "began" ) then
		showScores = true;
		print("scores")
	end
end

q:addEventListener("touch", onTouch )

new:addEventListener("touch", newGameClicked )

tut:addEventListener("touch", showTutorials )

highs:addEventListener("touch", showHighScores )

Runtime:addEventListener( "enterFrame", frame )


