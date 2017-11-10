{ execSync } = require 'child_process'
path = require 'path'

module.exports =
  texmfBibtexPath: null

  getTexmfBibtexPath: ->
    unless @texmfBibtexPath?
      output = execSync('kpsewhich -var-value TEXMFHOME', {encoding: 'utf8'})
      @texmfBibtexPath = path.join(path.normalize(output.trim()),'bibtex','bib')
    return @texmfBibtexPath
