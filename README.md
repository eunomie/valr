Valr: Changelog generator based on git commit
=============================================

[![Build Status](https://travis-ci.org/eunomie/valr.svg?branch=master)](https://travis-ci.org/eunomie/valr) [![Gem Version](https://badge.fury.io/rb/valr.svg)](https://badge.fury.io/rb/valr)

Installation
------------

### Prerequisites

- Ruby >= 2.2

### Setup

```
gem install valr
```

Usage
-----

A tool `valr` is available to generate a changelog from a repository.

The output contains the sha1 of the last commit (or the limits defined in the range)
and the list of changes in a markdown list.

```
    from: v0.1.0 <602fd435bde9767d924e4260df85ae0cf0094df4>
    to:   v0.1.1 <0c07c72a7c526d29bfe499771b37d41582450df3>

- Merge commit
- A commit
```

```
Usage: valr [options] [repository]

Range options:
    -r, --range [RANGE]              display commits only for the RANGE
    -f, --from [REV]                 display commits from REV to HEAD

Branch options:
    -b, --branch [BRANCH]            display commits for a specific BRANCH

Filter:
    -p, --first-parent               display only first-parent commits

Help:
    -h, --help                       Show this message
```

If `repository` is not defined, try with the current directory.

Contributing
------------

1. [Fork it](https://github.com/eunomie/valr/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes, with tests (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new _Pull Request_

LICENSE
-------

Please see [LICENSE][].

AUTHOR
------

Yves Brissaud, [@\_crev_](https://twiter.com/_crev_), [@eunomie](https://github.com/eunomie)

[LICENSE]: https://github.com/eunomie/valr/blob/master/LICENSE
