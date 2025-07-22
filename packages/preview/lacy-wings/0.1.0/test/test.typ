#import "@preview/lacy-wings:0.1.0": *
#import data: *
#import drawing: *

#let str2int(s) = if s.clusters().all(c => c.match(regex("\d")) != none) {
  Just(int(s))
} else {
  Nothing("`str2int` failed.")
}

#map-m(str2int, "1", "567", "1314520")

#map-m(str2int, "1", "刺客", "1314520")

/*
#let sheep(id, f, m) = Just((
  id: id,
  father: f,
  mother: m,
))

#let gf = sheep(0, Nothing("no dad"), Nothing("no mom"))
#let f = sheep(1, Nothing("no dad"), Nothing("no mom"))
#let m = sheep(2, gf, Nothing("no mom"))
#let i = sheep(3, f, m)

#let father(s) = s.father
#let mother(s) = s.mother

// gf
#bind(
  i,
  mother,
  father,
)

// gm (none)
#bind(
  i,
  mother,
  mother,
)

