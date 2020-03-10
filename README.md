# Litesite

This static site generator uses [Pandoc](http://pandoc.org)'s template system in order to create a flat lightweight website for minimalist blogging, e.g. on a shared host or on a personal server, such as a Raspberry Pi.

All articles are presented and linked on the top site.
Each article is placed on its own subsite with a unique URL.

The HTML template and (responsive) stylesheet are based on <http://bettermotherfuckingwebsite.com>. There are no Javascript or third-party dependencies.

Demo: <https://heidenblog.de/>

This repository doubles as the repository for the demo website.

## Verified requirements

- GNU bash 5.0.16
- GNU Make 4.3
- Perl 5.18
- rsync 2.6.9
- [Pandoc](http://pandoc.org) 2.9.2

## Installation

Git clone.

Test:

```
make site
```

## Usage

1. Create your HTML5 **templates** in `src/`. In order to use this repository as-is, you need:
    - An **article template**, starting with an `<article>` element at the top containing header and body (see <https://www.w3schools.com/tags/tag_article.asp>). This is the template on which per-article metadata is applied via [Pandoc](http://pandoc.org) (see <https://pandoc.org/MANUAL.html#templates>).
    - An **index template**, containing the full valid HTML5 template with a single `$body$` variable.
2. Create your **articles** in `src/`. Note:
    - Each article is represented by a plain text file in [Pandoc](http://pandoc.org) (Markdown) format.
    - It is recommended to use a number prefix in the file name for manual sorting.
    - Subdirectories within `src/` are ignored.
3. If you need **assets** (such as images), put them into a separate directory, e.g. `assets/`.
4. Adjust the **configuration** section in `Makefile` as documented.
5. Run the **commands** below.

Refer to existing files as a guideline.

## Commands

Clean the output directory:

```
make clean
```

Compile modified sources and synchronize the assets:

```
make site
```

Publish the site on a remote host by rsyncing the output directory:

```
make sync
```

Compile and publish in one go:

```
make
```

## Todo

- Pagination
- Parameterised templates

