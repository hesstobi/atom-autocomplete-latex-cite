CiteManager = require('./cite-manager')
path = require 'path'

module.exports =
class CiteProvider
  selector: '.text.tex.latex'
  disableForSelector: '.comment'
  inclusionPriority: 2
  suggestionPriority: 3
  excludeLowerPriority: false
  commandList: [
    "cite"
    "citet"
    "citep"
    "citeautor"
    "citeyear"
    "citeyearpar"
    "citealt"
    "citealp"
    "citetext"
    "textcite"
  ]

  constructor: ->
    @manager = new CiteManager()
    @manager.initialize()

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix?.length
    new Promise (resolve) =>
      results = @manager.searchForPrefixInDatabase(prefix)
      suggestions = []
      for result in results
        suggestion = @suggestionForResult(result, prefix)
        suggestions.push suggestion
      resolve(suggestions)

  suggestionForResult: (result, prefix) ->
    iconClass = "icon-mortar-board"
    if (result.class == 'article' || result.class == 'inproceedings' || result.class == "incollection")
      iconClass = "icon-file-text"
    else if (result.class == 'book' ||  result.class == 'inbook')
      iconClass = "icon-repo"


    suggestion =
      text: result.id
      replacementPrefix: prefix
      type: result.class
      className: 'latex-cite'
      descriptionMarkdown: result.markdownCite
      descriptionMoreURL: result.url
      iconHTML: "<i class=\"#{iconClass}\"></i>"


  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  dispose: ->
    @manager = []

  getPrefix: (editor, bufferPosition) ->
    cmdprefixes = @commandList.join '|'

    # Whatever your prefix regex might be
    regex = ///
            \\(#{cmdprefixes}) #comand group
            (\*)? #starred commands
            (\[[\\\w-]*\])? # optional paramters
            {([\w-:]+)$ # machthing the prefix
            ///
    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    # Match the regex to the line, and return the match
    line.match(regex)?[4] or ''
