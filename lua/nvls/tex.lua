local b, g, fn, cmd = vim.b, vim.g, vim.fn, vim.cmd
local Config = require('nvls.config')
local Make = require('nvls.make')

local M = {}

function M.ToggleLilypondSyntax()
  if g.lytexSyn == 1 then
    g.lytexSyn = 0
    cmd[[set syntax=tex]]
  else
  M.DetectLilypondSyntax()
  end
end

function M.DetectLilypondSyntax()
  if fn.search("\\\\begin\\|\\\\lilypond[^%]*$", "nw") ~= 0 then
    b.current_syntax = nil
    cmd('syntax include @lilypond syntax/lilypond.vim')
    cmd([[ 
      syntax region litex 
      \ start="\\begin{lilypond}" 
      \ end="\\end{lilypond}" 
      \ keepend
      \ contains=@lilypond
    ]])
    cmd([[
      syntax region litex 
      \ matchgroup=texStatement
      \ start="\\lilypond{"
      \ end="}" 
      \ contains=@lilypond
    ]])
    g.lytexSyn = 1
  end
end

function M.SelectMakePrgType()
  tex = Config.fileInfos("tex")

  local file = io.open(tex.main, "r")

  if file then
    local content = file:read("*all")
    file:close()

    local useLyLuaTex = string.find(content, "\\usepackage{lyluatex}")
    local useLilypond = string.find(content, "\\begin{lilypond}") or string.find(content, "\\lilypond")

    if useLyLuaTex then
      Make.async("lualatex")
    elseif useLilypond then
      Make.async("lilypond-book")
    else
      Make.async("lualatex")
    end
  end

end

return M
