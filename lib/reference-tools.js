'use babel';

const small = "(a|an|and|as|at|but|by|en|for|if|in|of|on|or|the|to|v[.]?|via|vs[.]?)"
const punct = "([!\"#$%&'()*+,./:;<=>?@[\\\\\\]^_`{|}~-]*)"

function titleCaps(title) {
  let parts = []
  let split = /[:.;?!] |(?: |^)["Ò]/g
  let index = 0

  while (true) {
    var m = split.exec(title)

    parts.push(title.substring(index, m ? m.index : title.length)
			.replace(/\b([A-Za-z][a-z.'Õ]*)\b/g, function(all) {
  return /[A-Za-z]\.[A-Za-z]/.test(all) ? all : upper(all)
})
			.replace(RegExp("\\b" + small + "\\b", "ig"), lower)
			.replace(RegExp("^" + punct + small + "\\b", "ig"), function(all, punct, word) {
  return punct + upper(word)
})
			.replace(RegExp("\\b" + small + punct + "$", "ig"), upper))

    index = split.lastIndex

    if (m) parts.push(m[0])
    else break
  }

  return parts.join("").replace(/ V(s?)\. /ig, " v$1. ")
		.replace(/(['Õ])S\b/ig, "$1s")
		.replace(/\b(AT&T|Q&A)\b/ig, function(all) {
  return all.toUpperCase()
})
}

function lower(word) {
  return word.toLowerCase()
}

function upper(word) {
  return word.substr(0, 1).toUpperCase() + word.substr(1)
}

function enhanceReferences(references) {
  for (let reference of references) {
    if (reference.title) {
      reference.title = reference.title.replace(/(^\{|\}$)/g, "")
      reference.prettyTitle = this.prettifyTitle(reference.title)
    }

    reference.prettyAuthors = ''
    if (reference.author) {
      reference.prettyAuthors = this.prettifyAuthors(reference.author)
    }

    reference.type = reference.type.toLowerCase()

    reference.in = reference.in || reference.journal || reference.booktitle

    reference.fullcite = ''
  }
  return references
}

function prettifyTitle(title) {
  let colon
  if (!title) {
    return
  }
  if (((colon = title.indexOf(':')) !== -1) && (title.split(" ").length > 5)) {
    title = title.substring(0, colon)
  }

  // make title into titlecaps
  title = titleCaps(title)
  return title
}

function prettifyAuthors(authors) {
  if ((authors == null)) {
    return ''
  }
  if (!authors.length) {
    return ''
  }


  let firstAuthors = []
  for (let author of authors.slice(0,3)) {
    firstAuthors.push(this.prettifyName(author))
  }

  let name = firstAuthors.join('; ')

  if (authors.length > 3) {
    return `${name} et al.`
  }
  return `${name}`
}

function prettifyName(person, inverted = false, separator = ' ') {
  if (inverted) {
    return this.prettifyName({
      given: person.family,
      family: person.given
    }, false, ', ')
  }
  let name = ((person.given) ? person.given : '') +
        ((person.given) && (person.family) ? separator : '') +
        ((person.family) ? person.family : '')
  return name.replace(/(^\{|\}$)/g, "")
}

module.exports = {enhanceReferences, prettifyTitle, prettifyAuthors, prettifyName, titleCaps}
