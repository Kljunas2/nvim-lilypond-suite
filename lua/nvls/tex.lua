local Config = require('nvls.config')
local Make = require('nvls.make')
local tex = Config.fileInfos("tex").main

local M = {}

function M.ToggleLilypondSyntax()
  if vim.g.lytexSyn == 1 then
    vim.g.lytexSyn = 0
    vim.cmd('set syntax=tex')
  else
  M.DetectLilypondSyntax()
  end
end

local function has(file, string)
  local content = io.open(file, "r")
  if not content then return end
  content = content:read("*all")
  return content:find(string, 1, true) ~= nil
end

function M.DetectLilypondSyntax()
  if has(tex, "\\begin{lilypond}") or has(tex, "\\lilypond") then
    vim.b.current_syntax = nil
    vim.cmd('syntax include @lilypond syntax/lilypond.vim')
    vim.cmd([[
      syn match litexCmd "\\lilypond\>\(\s\|\n\)\{}"
      \ nextgroup=litexOpts,litexReg
      \ transparent
      hi def link litexCmd texStatement
    ]])
    vim.cmd([[
      syn match texInputFile "\\lilypondfile\=\(\[.\{-}\]\)\=\s*{.\{-}}"
      \ contains=texStatement,texInputCurlies,texInputFileOpt
    ]])
    vim.cmd([[
      syn region litexOpts
      \ matchgroup=texDelimiter
      \ start="\["
      \ end="\]\(\n\|\s\)\{}"
      \ contained
      \ contains=texComment,@texMathZones,@NoSpell
      \ nextgroup=litexReg
      ]])
    vim.cmd([[
      syntax region litexReg
      \ matchgroup=Delimiter
      \ start="{"
      \ end="}" 
      \ contained
      \ contains=@lilypond,@lilyMatchGroup
    ]])
    vim.cmd([[ 
      syntax region litexReg
      \ start="\\begin{lilypond}" 
      \ end="\\end{lilypond}" 
      \ contains=litexOpts,@lilypond,@lilyMatchGroup
      \ keepend
    ]])
    vim.g.lytexSyn = 1
  end
end

function M.SelectMakePrgType()
  local cmd = "lualatex"
  if (has(tex, "\\begin{lilypond}") or has(tex, "\\lilypond"))
    and not has(tex, "\\usepackage{lyluatex}")
  then cmd = "lilypond-book" end
  Make.async(cmd)
end

return M
