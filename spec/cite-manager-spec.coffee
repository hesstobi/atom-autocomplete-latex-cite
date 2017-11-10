CiteManager = require '../lib/cite-manager'
path = require 'path'

describe "When the CiteManger gets initialized", ->
  manager = null

  beforeEach ->
    atom.project.setPaths([__dirname])
    manager = new CiteManager()

  it "is not null", ->
    expect(manager).not.toEqual(null)

  describe "When a bibtex file is added", ->
    bibFile = path.join(__dirname,'lib.bib')

    beforeEach ->
      waitsForPromise ->
        manager.addBibtexFile(bibFile)

    it "add file to the file list", ->
      expect(Object.keys(manager.pathWachters).length).toEqual(1)
      expect(manager.pathWachters.hasOwnProperty(bibFile))

    it "parsed the entries in the file", ->
      expect(Object.keys(manager.database).length).toEqual(4)
      expect(manager.database['kundur1994power']['id']).toEqual('kundur1994power')


    it "can search with author in the database", ->
      result  = manager.searchForPrefixInDatabase('Hess')
      expect(result[0].id).toEqual('7856203')

    it "can search with title in the database", ->
      result  = manager.searchForPrefixInDatabase('Studies on provision')
      expect(result[0].id).toEqual('7856203')
