{watchPath, CompositeDisposable} = require 'atom'
promisify = require "promisify-node"
fs = promisify('fs')
glob = require 'glob'
path = require 'path'
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
    @database = {}
    @globalPathWatcher = undefined
    @fuse = new Fuse(Object.values(@database),fuseOptions)

  handleWatcherEvents: (events) =>
    # Filter for bib files
    events = events.filter (e) -> /bib$/.test(e.path)
    # Filter multiple events for one file
    flags = {}
    events = events.reverse().filter (e) ->
      if flags[e.path]
        return false
      flags[e.path] = true
      return true
    for e in events
      switch e.action
        when "created"
          @addBibtexFile(e.path)
        when "modified"
          @addBibtexFile(e.path)
        when "deleted"
          @removeBibtexFile(e.path)

  initialize: ->
    # Add Bibfiles to the Database
    promises = []
    for ppath in atom.project.getPaths()
      promises.push(@addFilesFromFolder(ppath))
      promises.push(atom.project.getWatcherPromise(ppath))

    # Init the Path watcher
    watcher =  atom.project.onDidChangeFiles((events) =>
      @handleWatcherEvents(events))
    @disposables.add watcher

    # handle global Path
    if atom.config.get('autocomplete-latex-cite.includeGlobalBibFiles')
      if atom.config.get('autocomplete-latex-cite.globalBibPath')
        promises.push(@addGlobalBibFiles())

    # Subscripe to events
    @subscripeForConfigChanges()

    return Promise.all(promises)

  subscripeForConfigChanges: () ->
    atom.config.onDidChange 'autocomplete-latex-cite.includeGlobalBibFiles', ({newValue, oldValue}) =>
      if newValue
        if atom.config.get('autocomplete-latex-cite.globalBibPath')
          @addGlobalBibFiles()
      else
        @removeGlobalBibFiles()
    atom.config.onDidChange 'autocomplete-latex-cite.globalBibPath', ({newValue, oldValue}) =>
      if newValue
        if atom.config.get('autocomplete-latex-cite.includeGlobalBibFiles')
          @removeGlobalBibFiles()
          @addGlobalBibFiles()
      else
        @removeGlobalBibFiles()

  addGlobalBibFiles: () ->
    return new Promise ( (resolve) =>
      globalPath = atom.config.get('autocomplete-latex-cite.globalBibPath')
      @addFilesFromFolder(globalPath).then( (result) =>
        watchPath(globalPath,{},( (events) =>
          @handleWatcherEvents(events))).then ( (watcherDisposal) =>
            @disposables.add watcherDisposal
            @globalPathWatcher = watcherDisposal
            resolve(result)
        )
      )
    )

  removeGlobalBibFiles: () ->
    if @globalPathWatcher
      files = glob.sync(path.join(@globalPathWatcher.watchedPath, '**/*.bib'))
      for file in files
        @removeBibtexFile(file)
      @globalPathWatcher.dispose()
      @disposables.remove @globalPathWatcher
      @globalPathWatcher = undefined

  addFilesFromFolder: (folder) ->
    files = glob.sync(path.join(folder, '**/*.bib'))
    promises = []
    for file in files
      promises.push(@addBibtexFile(file))
    return Promise.all(promises)

  destroy: () ->
    @disposables.dispose()

  removeBibtexFile: (file) ->
    # Remove Database Entries for File
    for key,value of @database
      if value.sourcefile is file
        delete @database[key]
    @fuse = new Fuse(Object.values(@database),fuseOptions)

  addBibtexFile: (file) ->
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
        message = "Autocomplete Latex Cite Warning"
        options = {
          'dismissable': true
          'description': """Unable to parse Bibtex file #{file}. It will be
          ignored for autocompletion. (`#{error.message}`)
          """
        }
        atom.notifications.addWarning(message, options)
        resolve(@database)
      )
    )

  searchForPrefixInDatabase: (prefix) ->
    @fuse.search(prefix)
