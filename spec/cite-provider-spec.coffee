path = require 'path'

describe "Latex Cite Autocompletions", ->
  [editor, provider] = []
  bibFile = path.join(__dirname,'lib.bib')

  getCompletions = ->
    cursor = editor.getLastCursor()
    bufferPosition = cursor.getBufferPosition()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    # https://github.com/atom/autocomplete-plus/blob/9506a5c5fafca29003c59566cfc2b3ac37080973/lib/autocomplete-manager.js#L57
    prefix = /(\b|['"~`!@#$%^&*(){}[\]=+,/?>])((\w+[\w-]*)|([.:;[{(< ]+))$/.exec(line)?[2] ? ''
    request =
      editor: editor
      bufferPosition: bufferPosition
      scopeDescriptor: cursor.getScopeDescriptor()
      prefix: prefix
    provider.getSuggestions(request)

  checkSuggestion = (text) ->
    waitsForPromise ->
      getCompletions().then (values) ->
        expect(values.length).toBeGreaterThan 0
        expect(values[0].text).toEqual text



  beforeEach ->

    atom.packages.triggerActivationHook('language-latex:grammar-used')
    atom.packages.triggerDeferredActivationHooks()
    atom.project.setPaths([__dirname])

    waitsForPromise -> atom.packages.activatePackage('autocomplete-latex-cite')
    waitsForPromise -> atom.workspace.open('test.tex')

    runs ->
      provider = atom.packages.getActivePackage('autocomplete-latex-cite').mainModule.provide()
      editor = atom.workspace.getActiveTextEditor()
    waitsFor -> Object.keys(provider.manager.database).length > 0


  it "returns no completions when not at the start of a tag", ->
    editor.setText('')
    expect(getCompletions()).not.toBeDefined()

    editor.setText('d')
    editor.setCursorBufferPosition([0, 0])
    expect(getCompletions()).not.toBeDefined()
    editor.setCursorBufferPosition([0, 1])
    expect(getCompletions()).not.toBeDefined()

  it "has no completions for prefix without first letter", ->
    editor.setText('\\cite{')
    expect(getCompletions()).not.toBeDefined()

  it "has completions for prefix starting with the first letter", ->
    editor.setText('\\cite{Hess')
    checkSuggestion('7856203')

  it "supports multiple arguments", ->
    editor.setText('\\cite{7286496,Hess')
    checkSuggestion('7856203')
