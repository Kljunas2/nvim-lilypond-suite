local g, b, fn = vim.g, vim.b, vim.fn
local expand = fn.expand

local M = {}

function M.lilyPlayer()
  if fn.empty(
    fn.glob(expand('%:p:h') 
    .. '/' .. g.nvls_short .. '.midi')) == 0 then
    print('Converting ' .. g.nvls_short .. '.midi to mp3...') 
    b.nvls_cmd = "fluidsynth"
    b.nvls_makeprg = 'rm -rf ' .. g.lilyAudioFile .. ' && ' ..
      b.nvls_cmd .. ' -T raw -F - ' .. g.lilyMidiFile .. 
      ' -s | ffmpeg -f s32le -i - ' .. g.lilyAudioFile
    b.nvls_efm = " " 
    require('nvls').make()
  else
    if fn.empty(
      fn.glob(expand('%:p:h') 
        .. '/' .. g.nvls_short .. '.mp3')) > 0 then
      print("[LilyPlayer] No mp3 file in working directory")
      do return end
    else
      dofile(b.lilyplay)
    end
  end
end

function M.DefineLilyVars()
-- default : main file is current file
  g.nvls_main = expand('%:p:S')

-- if folder containing opened file contains .lilyrc, read it
-- (and overwrite vim.g.nvls_main)
  if fn.empty(fn.glob('%:p:h' .. '/.lilyrc')) == 0 then
    dofile(expand('%:p:h') .. '/.lilyrc')
    g.nvls_main = "'" .. g.nvls_main .. "'"

-- if folder containing opened file contains main.ly, main file is main.ly
  elseif fn.empty(fn.glob(expand('%:p:h') .. '/main.ly')) == 0 then
      g.nvls_main = "'" .. expand('%:p:h') .. "/main.ly'"
  end

-- if vim.g.nvls_main_file exists, define nvls_main from here :
  if g.nvls_main_file then
  g.nvls_main = "'" .. g.nvls_main_file .. "'"
  end

-- create sub variables from vim.g.nvls_main variable
  local name,out = g.nvls_main:gsub("%.(ly')", "'")
  if out == 0 then
    name,out = g.nvls_main:gsub("%.(ily')", "'")
  end
  g.nvls_main_name = name
  g.nvls_short = g.nvls_main_name:match('/([^/]+)$'):gsub("'", "")
  g.lilyMidiFile = expand(
    "'" .. g.nvls_main_name:gsub("'", "") .. ".midi'")
  g.lilyAudioFile = expand(
    "'" .. g.nvls_main_name:gsub("'", "") .. ".mp3'")
  b.nvls_pdf = expand(
  "'" .. g.nvls_main_name:gsub("'", "") .. ".pdf'")

  -- other vars for async :make
  b.nvls_cmd = "lilypond"
  b.nvls_makeprg = vim.b.nvls_cmd .. " -o" .. 
    g.nvls_main_name .. ' ' .. g.nvls_main
  b.nvls_efm     = '%+G%f:%l:%c:, %f:%l:%c: %m,%-G%.%#'

end

return M
