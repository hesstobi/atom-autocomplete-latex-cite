{ execSync } = require 'child_process'
path = require 'path'
os = require 'os'

texmfBibtexPath = undefined

getTexmfBibtexPath = ->
  unless texmfBibtexPath?
    ENV = null
    if process.platform == 'darwin'
      ENV = { PATH: ['/Library/TeX/texbin',process.env.PATH].join(":") }
    try
      output = execSync('kpsewhich -var-value TEXMFHOME',
        { env: ENV, encoding: 'utf8'})
      texmfBibtexPath = path.normalize(output.trim())
    catch
      texmfBibtexPath = ''

    if texmfBibtexPath
      texmfBibtexPath = path.join(texmfBibtexPath,'bibtex','bib')
      if process.platform == 'darwin'
        texmfBibtexPath = path.join(os.homedir(),texmfBibtexPath)
  return texmfBibtexPath

module.exports =
  globalBibPath:
    type: 'string'
    order: 2
    default: getTexmfBibtexPath()
    description: 'The path of for global bibtex libary files. Defaults to the texmf folder.'
  includeGlobalBibFiles:
    type: 'boolean'
    order: 1
    default: false
    description: 'Add the bibtex entries in the global files to the suggestions list.'
