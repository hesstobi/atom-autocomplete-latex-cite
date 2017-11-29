CiteManager = require '../lib/cite-manager'
path = require 'path'
fs = require 'fs-extra'
os = require 'os'

describe "When the CiteManger gets initialized", ->
  manager = null

  beforeEach ->
    atom.project.setPaths([__dirname])
    manager = new CiteManager()
    waitsForPromise ->
      manager.initialize()

  it "is not null", ->
    expect(manager).not.toEqual(null)


  it "parsed the entries in the bib file", ->
    expect(Object.keys(manager.database).length).toEqual(4)
    expect(manager.database['kundur1994power']['id']).toEqual('kundur1994power')


  it "can search with author in the database", ->
    result  = manager.searchForPrefixInDatabase('Hess')
    expect(result[0].id).toEqual('7856203')

  it "can search with title in the database", ->
    result  = manager.searchForPrefixInDatabase('Studies on provision')
    expect(result[0].id).toEqual('7856203')

  describe "When a secound bibtex file is added", ->
    bibFile2 = path.join(__dirname,'lib2.bib')

    beforeEach ->
      runs ->
        fs.appendFileSync bibFile2, '@book{schwab2017elektroenergiesysteme,
          title={Elektroenergiesysteme: Erzeugung, {\"U}bertragung und Verteilung elektrischer Energie},
          author={Schwab, A.J.},
          isbn={9783662553169},
          url={https://books.google.de/books?id=Gq80DwAAQBAJ},
          year={2017},
          publisher={Springer Berlin Heidelberg}
        }'

      waitsForPromise ->
        manager.addBibtexFile(bibFile2)

    afterEach ->
      fs.removeSync bibFile2

    it "add the file to the databse", ->
      expect(Object.keys(manager.database).length).toEqual(5)
      expect(manager.database['schwab2017elektroenergiesysteme']['id']).toEqual('schwab2017elektroenergiesysteme')

    it "remove the entries when the file is removed", ->
      fs.removeSync bibFile2
      manager.removeBibtexFile(bibFile2)
      expect(Object.keys(manager.database).length).toEqual(4)

  describe "When the bibtex file is not valid", ->
    bibFile2 = path.join(__dirname,'lib2.bib')

    beforeEach ->
      fs.appendFileSync bibFile2, '@book{schwab2017elektroenergiesysteme,
          title={Elektroenergiesysteme: Erzeugung, {\"U}bertragung und Verteilung elektrischer Energie},
          author={Schwab, A.J.},
          isbn={9783662553169}
          url={https://books.google.de/books?id=Gq80DwAAQBAJ},
          year={2017,
          publisher={Springer Berlin Heidelberg}
        }'

      waitsForPromise ->
        manager.addBibtexFile(bibFile2)

    afterEach ->
      fs.removeSync bibFile2

    it "show a warning", ->
      noti = atom.notifications.getNotifications()
      expect(noti.length).toEqual 1
      expect(noti[0].message).toEqual "Autocomplete Latex Cite Warning"
      expect(noti[0].type).toEqual "warning"
      expect(noti[0].options.description).toContain "lib2.bib"
      expect(noti[0].options.description).toContain "Token mismatch: match"

  describe "When the global Path is enabled", ->
    manager = null

    beforeEach ->
      atom.config.set 'autocomplete-latex-cite.globalBibPath', __dirname
      atom.config.set 'autocomplete-latex-cite.includeGlobalBibFiles', true

      manager = new CiteManager()
      waitsForPromise ->
        manager.initialize()

    it "Add the entries to the database", ->
      expect(Object.keys(manager.database).length).toEqual(4)
      expect(manager.database['kundur1994power']['id']).toEqual('kundur1994power')

    it "Removes the entries when the global path is disabled", ->
      runs ->
        atom.config.set 'autocomplete-latex-cite.includeGlobalBibFiles', false

      waitsFor ->
        Object.keys(manager.database).length < 4

      runs ->
        expect(Object.keys(manager.database).length).toEqual(0)

    it "Changes the entries when the path is changed", ->
      runs ->
        atom.config.set 'autocomplete-latex-cite.globalBibPath', path.join(__dirname,'..','lib')

      waitsFor ->
        Object.keys(manager.database).length < 4

      runs ->
        expect(Object.keys(manager.database).length).toEqual(0)

    it "Removes the entries when the path is set to empty string", ->
      runs ->
        atom.config.set 'autocomplete-latex-cite.globalBibPath', ''

      waitsFor ->
        Object.keys(manager.database).length < 4

      runs ->
        expect(Object.keys(manager.database).length).toEqual(0)
