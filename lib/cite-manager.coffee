{watchPath, CompositeDisposable} = require 'atom'
promisify = require "promisify-node"
fs = promisify('fs')
Fuse = require 'fuse.js'
bibtexParse = require './lite-bibtex-parse'
referenceTools = require './reference-tools'

module.exports =
class CiteManager
  fuseOptions =
    shouldSort: true,
    threshold: 0.6,
    location: 0,
    distance: 100,
    maxPatternLength: 32,
    minMatchCharLength: 1,
    keys: [{
        "name": "title",
        "weight": 0.3
    },
    {
        "name": "author.family",
        "weight": 0.6
    },
    {
        "name": "author.given",
        "weight": 0.6
    },
    {
        "name": "id",
        "weight": 0.1
    }]


  constructor: ->
    @disposables = new CompositeDisposable
    @pathWachters = {}
    @database = {}
    @fuse = new Fuse(Object.values(@database),fuseOptions)

  destroy: () ->
    @disposables.dispose()

  removeBibtexFile: (file) ->
    # Dispose File watcher
    watcher = @pathWachters[file]

    unless watcher is undefined
      watcher.dispose()
      delete @pathWachters[file]

      # Remove Database Entries for File
      for key,value of @database
        if value.sourcefile is file
          delete @database[key]
      @fuse = new Fuse(Object.values(@database),fuseOptions)

  addBibtexFile: (file) ->
    # Create a watcher for the file
    return new Promise( (resolve, reject) =>

      @parseBibtexFile(file).then( (result) =>

        watcherPromise = watchPath file, {}, (events) =>
          for e in events
            switch e.action
              when "modified"
                @parseBibtexFile(e.path)

        watcherPromise.then (watcher) =>
          @disposables.add watcher
          @pathWachters[file] = watcher
          resolve(@database)

      ).catch( (error) ->
        message = "Autocomple Latex Cite Warning"
        options = {
          'dismissable': true
          'description': """ Unable to parse Bibtex file #{file}. It will be
          ignored for autocompletion. (`#{error.message}`)
          """
        }
        atom.notifications.addWarning(message, options)
        resolve(@database)
      )
    )


  parseBibtexFile: (file) ->
    return new Promise((resolve, reject) =>
      fs.readFile(file, 'utf8').then( (content) =>

        bibtex = bibtexParse.toJSON(content)
        bibtex = referenceTools.enhanceReferences(bibtex)

        for el in bibtex
          el['sourcefile'] = file
          @database[el['id']] = el

        @fuse = new Fuse(Object.values(@database),fuseOptions)
        resolve(@database)
      ).catch( (error) ->
        reject(error)
      )
    )

  replaceEscapeMendeleySequences: (content) ->
    # replace backslash
    content = content.replace(/\$\\backslash\$/g,"\\")
    content = content.replace(/\\textgreater/g,'>')
    return content

  searchForPrefixInDatabase: (prefix) ->
    @fuse.search(prefix)
