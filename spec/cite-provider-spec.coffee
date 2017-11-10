describe "Latex Cite Autocompletions", ->
  [editor, provider] = []

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

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('autocomplete-latex-cite')

    runs ->
      provider = atom.packages.getActivePackage('autocomplete-latex-cite').mainModule.provide()
