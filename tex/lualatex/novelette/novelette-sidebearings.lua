-----------------------------------------------------------------------
--            FILE:  novelette-sidebearings.lua
--  LUALATEX USAGE:  \directlua{require novelette-sidebearings.lua}
--     DESCRIPTION:  access sidebearings with Luatex
--    REQUIREMENTS:  luaotfload version >= 2.2
--          AUTHOR:  Philipp Gesang (Phg)
--         VERSION:  1.0
--         CREATED:  2013-08-27 15:27:20+0200
--         LICENSE:  No explicit license came with this file. However,
--                   it was posted by its author on tex.stackexchange.com,
--                   in response to question 45549. The web site states
--                   that responses of the above date are licensed according
--                   to the Creative Commons BY-SA 3.0 license. URLs:
--                   https://tex.stackexchange.com/help/licensing
--                   https://creativecommons.org/licenses/by-sa/3.0/
--         COMMENT:  The filename novelette-sidebearings.lua is for the
--                   purpose of unique identification. It should not be
--                   construed to mean that the author of Novelette had
--                   any part in creating this code.
-----------------------------------------------------------------------
--

packagedata                  = packagedata or { }
packagedata.sidebearings     = { }
local sidebearings           = packagedata.sidebearings

local utfbyte                = utf.byte
local texsprint              = tex.sprint

local get_sidebearings = function (id, char)
  local tfmdata = font.getfont (id)

  if not (tfmdata and tfmdata.shared) then
    return 0, 0
  end

  local descriptions = tfmdata.shared.rawdata.descriptions
  local glyphdata    = descriptions [char]
  if not glyphdata then
    --- font lacks the glyph
    return 0, 0
  end

  local boundingbox   = glyphdata.boundingbox
  local lside         = boundingbox [1] or 0
  local wd            = boundingbox [3] or glyphdata.width
  local rside         = glyphdata.width - wd

--  inspect (glyphdata)

  return lside / 100, rside /100
end

local sidebearings = function (id, char, left)
  char = utfbyte (char)
  local lside, rside = get_sidebearings (id, char)
  if left then
    texsprint (tostring (lside), "pt")
  else
    texsprint (tostring (rside), "pt")
  end
end

packagedata.sidebearings.left  = function (char)
  return sidebearings (font.current (), char, true)
end

packagedata.sidebearings.right = function (char)
  return sidebearings (font.current (), char, false)
end

-- End novelette-sidebearings.lua.
