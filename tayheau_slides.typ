// ============================================================
// Tayheau Slides Touying Template
// Compatible Touying 0.6.1
// ============================================================

#set text(font: "IBM Plex Sans")

#import "@preview/touying:0.6.1": *

// ── Palette ──────────────────────────────────────────────────
#let blue-header = rgb(0, 0, 238)
#let blue-sub    = rgb("#2222AA")
#let blue-label  = rgb("#3333DD")
#let white-col   = rgb("#FFFFFF")
#let light-gray  = rgb("#EEEEEE")
#let dark-text   = rgb("#111111")
#let question-bg = rgb("#DDEEFF")
#let pad-x       = 1.2em
#let pad-y       = 0.6em

// ── Helpers visuels ──────────────────────────────────────────

#let slide-title(it) = {
  block(
    width: 100%,
    inset: (bottom: 0.6em),
    stroke: (bottom: 1.5pt + blue-header),
  )[
    #text(fill: blue-header, weight: "bold", size: 1.15em, it)
  ]
  v(0.4em)
}

#let slide-question(q) = {
  if q != none {
    v(1fr)
    block(
      width: 100%,
      fill: question-bg,
      stroke: (top: 1pt + blue-sub, left: 3pt + blue-sub),
      inset: (x: 0.8em, y: 0.5em),
      radius: (right: 4pt),
    )[
      #text(fill: blue-sub, size: 0.82em, style: "italic")[
        #sym.arrow.r.double #h(0.3em) #q
      ]
    ]
  }
}

// ── Slide de base ─────────────────────────────────────────────
// title   : titre pleine largeur au-dessus des colonnes (none = pas de titre)
// question: bandeau pleine largeur en bas               (none = pas de question)
// composer: tuple de tailles de colonnes, ex. (1fr, 1fr)
//           si une seule colonne, passer (1fr,) ou laisser à auto
// ..bodies : un bloc de contenu par colonne
#let slide(
  title: none,
  banner: none,
  question: none,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if banner != none { self.store.title = banner }
  if banner == none { self.store.title = none }

  let inner = if composer != auto and bodies.pos().len() > 1 {
    components.side-by-side(columns: composer, ..bodies)
  } else {
    bodies.pos().first()
  }

  let body = {
    if title != none { slide-title(title) }
    inner
    if question != none { slide-question(question) }
  }

  // setting reste intact, composer passe à auto car géré manuellement
  touying-slide(self: self, config: config, repeat: repeat,
                setting: setting, composer: auto, body)
})

// ── Slide de titre ────────────────────────────────────────────
#let title-slide(
  title: [],
  authors: [],
  doi: none,
  abstract-items: (),
  question: none,
  config: (:),
) = touying-slide-wrapper(self => {
  self.store.title = none
  let body = {
    text(weight: "bold", size: 1.35em, fill: dark-text, title)
    v(0.55em)
    text(size: 0.78em, fill: dark-text, authors)
    v(0.25em)
    if doi != none {
      text(size: 0.74em, weight: "bold", fill: dark-text)[doi: #doi]
    }
    v(0.45em)
    line(length: 100%, stroke: 0.5pt + rgb("#AAAAAA"))
    v(0.3em)
    if abstract-items.len() > 0 {
      set enum(numbering: "1.")
      for item in abstract-items { [+ #item] }
    }
    if question != none { slide-question(question) }
  }
  touying-slide(self: self, config: config, body)
})

// ── Slide de section ──────────────────────────────────────────
// label   : texte du bandeau bleu pleine largeur
// subtitle: fond gris sous le bandeau (peut contenir du markup)
// question: bandeau bleu clair en bas
#let section-slide(
  label: [],
  subtitle: none,
  question: none,
  config: (:),
) = touying-slide-wrapper(self => {
  self.store.title = none
  
  let body = {
    block(
      width: 100%,
      fill: blue-sub,
      inset: (x: pad-x, y: pad-y),
    )[
      #text(fill: white-col, weight: "bold", size: 1.25em, label)
    ]
    if subtitle != none {
      block(
        width: 100%,
        fill: light-gray,
        inset: (x: pad-x, y: 0.45em),
      )[
        #text(size: 0.88em, fill: dark-text, style: "italic", subtitle)
      ]
    }
    if question != none { slide-question(question) }
  }
  touying-slide(self: self, config: config, body)
})

// ── Citation slide ────────────────────────────────────────────
// authors     : tableau de (content, (clés d'affiliation...))
//               ex. (([John Doe], ("a","b")), ([Jane Smith], ("a",)))
// affiliations: dictionnaire clé → content
//               ex. ("a": [Univ. X], "b": [Lab Y])
#let citation-slide(
  title: [],
  banner: [],
  authors: (),
  affiliations: (:),
  doi: [],
  abstract-items: (),
  question: none,
  config: (:),
) = touying-slide-wrapper(self => {
  if banner != none { self.store.title = banner }
  if banner == none { self.store.title = none }
  let body = {
    text(weight: "bold", size: 1.35em, fill: dark-text, title)
    v(0.55em)

    // Auteurs avec exposants
    text(size: 0.78em, fill: dark-text)[
      #for (i, entry) in authors.enumerate() {
        let (name, aff-keys) = entry
    
        let aff = if type(aff-keys) == array { aff-keys.join(",") } else { aff-keys }
    
        [#name#super(aff)]
        if i < authors.len() - 1 [ · ]
      }
    ]

    v(0.25em)
    if doi != [] {
      text(size: 0.74em, weight: "bold", fill: dark-text)[doi: #doi]
    }
    v(0.45em)
    line(length: 100%, stroke: 0.5pt + rgb("#AAAAAA"))
    v(0.3em)

    // Affiliations triées par clé
    if affiliations.len() > 0 {
      let sorted = affiliations.pairs().sorted(key: ((k, v)) => k)
      text(size: 0.65em, fill: dark-text, style: "italic")[
        #for (key, aff) in sorted [
          #super(key) #aff #linebreak()
        ]
      ]
    }

    // Liste optionnelle (résumé/abstract)
    if abstract-items.len() > 0 {
      v(0.3em)
      line(length: 100%, stroke: 0.5pt + rgb("#AAAAAA"))
      v(0.2em)
      set enum(numbering: "1.")
      for item in abstract-items { [+ #item] }
    }

    if question != none { slide-question(question) }
  }
  touying-slide(self: self, config: config, body)
})

// ── Thème principal ───────────────────────────────────────────
#let journal-club-theme(
  aspect-ratio: "16-9",
  short-title: "[journal club]",
  author: "Auteur",
  ..args,
  body,
) = {
  set text(size: 16pt, font: "IBM Plex Sans")

  let header(self) = {
    block(
      width: 100%,
      fill: blue-header,
      inset: (x: pad-x, y: 0.5em),
    )[
      #set std.align(horizon)
      #text(fill: white-col, weight: "bold")[
        #utils.call-or-display(self, self.store.short-title)
      ]
    ]
    if self.store.title != none {
      block(
        width: 100%,
        fill: blue-sub,
        inset: (x: pad-x, y: 0.4em),
      )[
        #set std.align(horizon)
        #text(fill: white-col, weight: "bold", size: 0.95em)[
          #utils.call-or-display(self, self.store.title)
        ]
      ]
    }
  }

  let footer(self) = {
    block(
      width: 100%,
      fill: white-col,
      stroke: (top: 0.5pt + blue-header),
      inset: (x: 0.7em, y: 0.7em),
    )[
      #set std.align(horizon)
      #grid(
        columns: (1fr, auto),
        text(fill: blue-header, size: 0.7em, weight: "bold")[
          #utils.call-or-display(self, self.store.author)
        ],
        text(fill: blue-label, size: 0.7em, weight: "bold")[
          [#context utils.slide-counter.display()]
        ],
      )
    ]
  }

  show: touying-slides.with(
    config-page(
      paper:          "presentation-" + aspect-ratio,
      header:         header,
      footer:         footer,
      header-ascent:  2.2em,
      footer-descent: 0em,
      margin:         (top: 3.8em, bottom: 2em, x: 2.5em),
    ),
    config-common(slide-fn: slide),
    config-store(
      short-title: short-title,
      author:      author,
      title:       none,
    ),
    ..args,
  )

  body
}

// ============================================================
// ── EXEMPLE D'UTILISATION ────────────────────────────────────
// ============================================================

// #show: journal-club-theme.with(
//   aspect-ratio: "16-9",
//   short-title:  "[feb 27] lab meeting",
//   author:       "Theo HOPSORE",
// )
