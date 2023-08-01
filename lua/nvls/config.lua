local Utils = require('nvls.utils')
local nvls_options = require('nvls').get_nvls_options()

local main_folder
local main_file

local M = {}

function M.fileInfos(ft)
  local file = {}

  if ft == "tex" then
    main_folder = nvls_options.latex.options.main_folder
    main_file = nvls_options.latex.options.main_file
  elseif ft == "lilypond" then
    main_folder = nvls_options.lilypond.options.main_folder
    main_file = nvls_options.lilypond.options.main_file
  end

  local main = Utils.shellescape(vim.fn.expand('%:p'))
  local main_path = Utils.joinpath(vim.fn.expand(main_folder), main_file)

  if Utils.exists(Utils.joinpath(vim.fn.expand(main_folder), '.lilyrc')) then
    dofile(Utils.joinpath(vim.fn.expand(main_folder), '.lilyrc'))
    main = Utils.exists(main_path) and Utils.shellescape(main_path) or main
  elseif Utils.exists(main_path) then
    main = Utils.shellescape(main_path)
  end

  local os_type = Utils.os_type()

  local name = main:gsub("%.(i?ly)$", ""):gsub("%.tex$", "")
  if os_type == "Windows" then
    file.name = name:match('.*\\([^\\]+)$')
  else
    file.name = name:match('.*/([^/]+)$'):gsub([[\]], "")
  end

  file.pdf = Utils.change_extension(main, "pdf")
  file.mp3 = Utils.change_extension(main, "mp3")
  file.midi = Utils.change_extension(main, "midi")
  file.main = main
  file.folder = main_folder
  file.tmp = Utils.joinpath(vim.fn.stdpath('cache'), 'nvls/')

  return file
end

return M
