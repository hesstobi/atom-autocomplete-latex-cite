CiteManager = require '../lib/cite-manager'
path = require 'path'
fs = require 'fs-extra'
os = require 'os'

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


    describe "When the bibtex file is changed", ->

      beforeEach ->
        fs.copySync bibFile, path.join(os.tmpdir(),'lib.bib.bak')
        fs.appendFileSync bibFile, '@book{schwab2017elektroenergiesysteme,
          title={Elektroenergiesysteme: Erzeugung, {\"U}bertragung und Verteilung elektrischer Energie},
          author={Schwab, A.J.},
          isbn={9783662553169},
          url={https://books.google.de/books?id=Gq80DwAAQBAJ},
          year={2017},
          publisher={Springer Berlin Heidelberg}
          }\n'
        waitsForPromise ->
          waitForChanges(manager.pathWachters[bibFile],bibFile)

      afterEach ->
        fs.moveSync path.join(os.tmpdir(),'lib.bib.bak'), bibFile, { overwrite: true }

      #it "updates the database", ->
      #  expect(Object.keys(manager.database).length).toEqual(5)
      #  expect(manager.database['schwab2017elektroenergiesysteme']['id']).toEqual('schwab2017elektroenergiesysteme')

    describe "When a secound bibtex file is added", ->
      bibFile2 = path.join(__dirname,'lib2.bib')

      beforeEach ->
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
        manager.removeBibtexFile bibFile2
        fs.removeSync bibFile2

      it "add the file to the databse", ->
        expect(Object.keys(manager.pathWachters).length).toEqual(2)
        expect(manager.pathWachters.hasOwnProperty(bibFile2))
        expect(Object.keys(manager.database).length).toEqual(5)
        expect(manager.database['schwab2017elektroenergiesysteme']['id']).toEqual('schwab2017elektroenergiesysteme')


      it "remove the entries when the file is removed", ->
        manager.removeBibtexFile bibFile2
        expect(Object.keys(manager.pathWachters).length).toEqual(1)
        expect(Object.keys(manager.database).length).toEqual(4)

  describe "When the bibtex file is not existing", ->
    bibFile = path.join(__dirname,'lib2.bib')

    beforeEach ->
      waitsForPromise ->
        manager.addBibtexFile(bibFile)

    it "show a warning", ->
      noti = atom.notifications.getNotifications()
      expect(noti).toHaveLength 1
      expect(noti[0].message).toEqual "Autocomple Latex Cite Warning"
      expect(noti[0].type).toEqual "warning"
