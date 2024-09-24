-- SPDX-FileCopyrightText: © 2016 SIL International
-- SPDX-License-Identifier: MIT

-- Help the CLI locate template files wherever LuaRocks stashes them
return function ()
  local src = debug.getinfo(1, "S").source:sub(2)
  local base = src:match("(.*[/\\])")
  return base
end

