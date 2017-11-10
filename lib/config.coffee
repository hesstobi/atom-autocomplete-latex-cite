TexmfHelper = require './texmf-helper'

module.exports =
  globalBibtexPath:
    type: 'string'
    order: 1
    default: TexmfHelper.getTexmfBibtexPath()
    description: 'The path of for global bibtex libary files. Defaults to the texmf folder.'
