--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c8720515224e27beed68a3a2a6ceae3b:b7d33a89d8f924bdade659d79efc6b2c:56b91c59e59dc579820165c1aa0864e1$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- comecome_00
            x=1,
            y=1,
            width=30,
            height=32,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 32,
            sourceHeight = 32
        },
        {
            -- comecome_01
            x=33,
            y=1,
            width=32,
            height=32,

        },
        {
            -- comecome_02
            x=67,
            y=1,
            width=32,
            height=32,

        },
        {
            -- comecome_03
            x=101,
            y=1,
            width=32,
            height=32,

        },
        {
            -- comecome_04
            x=135,
            y=1,
            width=32,
            height=32,

        },
        {
            -- comecome_05
            x=169,
            y=1,
            width=32,
            height=32,

        },
    },
    
    sheetContentWidth = 202,
    sheetContentHeight = 34
}

SheetInfo.frameIndex =
{

    ["comecome_00"] = 1,
    ["comecome_01"] = 2,
    ["comecome_02"] = 3,
    ["comecome_03"] = 4,
    ["comecome_04"] = 5,
    ["comecome_05"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
