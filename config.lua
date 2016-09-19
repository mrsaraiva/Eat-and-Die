--
-- For more information on config.lua see the Corona SDK Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

--application =
--{
--	content =
--	{
--		width = 320,
--		height = 480,
--		scale = "zoomEven",
--		fps = 60,
--		antialias = true,
--               
--		imageSuffix =
--		{
--			["@2x"] = 2,
--		},
--	},
--}

--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth
 
application = {
   content = {
      -- width = aspectRatio > 1.5 and 320 or math.floor( 480 / aspectRatio ),
      -- height = aspectRatio < 1.5 and 480 or math.floor( 320 * aspectRatio ),
	  width = 320,
	  height = 480,
      scale = "zoomEven",
      fps = 60,
	  antialias = true,
 
      imageSuffix = {
         ["@2x"] = 1.5,
         ["@4x"] = 3.0,
      },
   },
   license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApmSyvEQLUPnWrx701Z5sKZd1h6PSYwk1rkGF9NZG7tM2m0eVpeu99b8J1uqTScCKyyPoMCdtRGPdoLbciuki0LK+NbvqIlAtqQEaXVAdc4hMxLKtxF5EdCrkXzxYyXrK61cTFTKB02KP8L35KULJzcViecvPHD6u7F0xQnCXJbPn5TAUCbwDlB18OxFS0BSN/2KX9Dh/Ln03DrQsWDwrjbZ5f0S6tcuBmgToii+A4ts2kujcrqEJwGXIsb2YAHkKM/VuiKqpQ1UPa+RKUOSe7FZ2UJZjOkcpnJijRFyioXqkcWOhVDgYaRfux0OdoMZ3BSK/eXJIyZBqljVBgpa0UwIDAQAB",
            -- policy = "this is optional",
        },
    },
}
