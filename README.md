# autocomplete-latex-cite package

[![Build Status](https://travis-ci.org/hesstobi/atom-autocomplete-latex-cite.svg?branch=master)](https://travis-ci.org/hesstobi/atom-autocomplete-latex-cite)
[![apm](https://img.shields.io/apm/v/autocomplete-latex-cite.svg)](https://atom.io/packages/autocomplete-latex-cite)
[![apm](https://img.shields.io/apm/dm/autocomplete-latex-cite.svg)](https://atom.io/packages/autocomplete-latex-cite)
[![GitHub license](https://img.shields.io/github/license/hesstobi/atom-autocomplete-latex-cite.svg)](https://github.com/hesstobi/atom-autocomplete-latex-cite/blob/master/LICENSE.md)
[![Greenkeeper badge](https://badges.greenkeeper.io/hesstobi/atom-autocomplete-latex-cite.svg)](https://greenkeeper.io/)


Autocomplete+ Support for Bibtex References in Latex.

![A screenshot of your package](https://user-images.githubusercontent.com/929957/33224201-29ff294a-d167-11e7-8f9b-a673f290a68b.gif)

## Features
* searches for bibtex files in the project path and optional in a user defined global path
* updates the entries in the database when a bibtex file changes
* shows a simple formatted citation as description
* different icons and colors for different entry types
* support multiple cite commands (e.g. `cite`, `citeyear`, `textcite`)

## Description

This package pursues a different approach for the auto completion of references
then the [autocomplete-bibtex
package](https://atom.io/packages/autocomplete-bibtex). Its main application is
the usages within latex projects. Thus, it triggers the auto completion on the
default latex citation commands like `\cite` and it adds all entries of the
bibtex files within the project path to the auto completion database.
Additionally, a global path can be defined where also is searched for bibtex
files. This setting defaults to the texmf folder of the current user.



## See also
* [autocomplete-latex-references package](https://github.com/hesstobi/atom-autocomplete-latex-references): auto completion support for `ref` in latex
* [autocomplete-glossaries package](https://github.com/hesstobi/atom-autocomplete-glossaries): auto completion support glossaries entries
