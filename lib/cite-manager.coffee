{watchPath, CompositeDisposable} = require 'atom'
promisify = require "promisify-node"
fs = promisify('fs')
Fuse = require 'fuse.js'

Cite = require 'citation-js'

module.exports =
class CiteManager
  fuseOptions =
    shouldSort: true,
    threshold: 0.6,
    location: 0,
    distance: 100,
    maxPatternLength: 32,
    minMatchCharLength: 1,
    keys: ["id","author","title"]


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
    watcher.dispose()
    @pathWachters.delete(watcher)

    # Renove file from List


    # Remove Database Entries for File

  addBibtexFile: (file) ->
    # Create a watcher for the file
    watcherPromise = watchPath file, {}, (events) =>
      for e in events
        switch e.action
          when "modified"
            @parseBibtexFile(e.path)
          when "deleted"
            @removeBibtexFile(e.path)

    watcherPromise.then (watcher) =>
      @disposables.add watcher
      @pathWachters[file] = watcher

    return Promise.all([@parseBibtexFile(file),watcherPromise])

  parseBibtexFile: (file) ->
    return new Promise((resolve, reject) =>
      fs.readFile(file, 'utf8').then( (content) =>
        content = @replaceEscapeMendeleySequences(content)
        data = new Cite(content)

        data.sort()
        output = data.get
          format: 'real',
          type: 'html',
          lang: 'en-US'
          style: 'citation-apa',
        output = output.querySelectorAll('div.csl-entry')

        for el,i in data.data
          el['fullcite'] = output[i]
          el['sourcefile'] = file
          delete el['_graph']
          delete el['_label']
          @database[el['id']] = el

        @fuse = new Fuse(Object.values(@database),fuseOptions)
        resolve(@database)
      ).catch( (error) ->
        reject(error)
      )
    )

  replaceEscapeMendeleySequences: (content) ->
    content = content.replace(/\$\\backslash\$/g,"\\")
    return content

  searchForPrefixInDatabase: (prefix) ->
    @fuse.search(prefix)
