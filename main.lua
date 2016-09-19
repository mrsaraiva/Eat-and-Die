-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require("src.resources")

display.setStatusBar( display.HiddenStatusBar )
local composer = require( "composer" )

local gpgs = require( "plugin.gpgs" )
local playerName
 
local function loadLocalPlayerCallback( event )
   playerName = event.data.alias
   saveSettings()  --save player data locally using your own "saveSettings()" function
end
 
local function gpgsLoginCallback( event )
   gpgs.request( "loadLocalPlayer", { listener=loadLocalPlayerCallback } )
   return true
end
 
local function gpgsInitCallback( event )
   gpgs.request( "login", { userInitiated=true, listener=gpgsLoginCallback } )
end
 
local function gpgsSetup()
   if ( system.getInfo("platformName") == "Android" ) then
      gpgs.init( "google", gpgsInitCallback )
   else
      gpgs.init( "gamecenter", gpgsLoginCallback )
   end
end
 
------HANDLE SYSTEM EVENTS------
local function systemEvents( event )
   print("systemEvent " .. event.type)
   if ( event.type == "applicationSuspend" ) then
      print( "suspending..........................." )
   elseif ( event.type == "applicationResume" ) then
      print( "resuming............................." )
   elseif ( event.type == "applicationExit" ) then
      print( "exiting.............................." )
   elseif ( event.type == "applicationStart" ) then
      gpgsSetup()  --login to the network here
   end
   return true
end
 
Runtime:addEventListener( "system", systemEvents )

composer.gotoScene("src.game")