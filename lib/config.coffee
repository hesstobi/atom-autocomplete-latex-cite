{ execSync } = require 'child_process'
path = require 'path'

texmfBibtexPath = undefinded

getTexmfBibtexPath: ->
  unless texmfBibtexPath?
    output = execSync('kpsewhich -var-value TEXMFHOME', {encoding: 'utf8'})
    @texmfBibtexPath = path.join(path.normalize(output.trim()),'bibtex','bib')
  return texmfBibtexPath

module.exports =
  globalBibPath:
    type: 'string'
    order: 2
    default: getTexmfBibtexPath()
    description: 'The path of for global bibtex libary files. Defaults to the texmf folder.'
  includeGlobalBibFiles:
    type: 'bool'
    order: 1
    default: true
    description: 'Add the bibtex entries in the global files to the suggestions list.'
