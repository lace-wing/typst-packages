#import "@preview/lacy-wings:0.1.0": *
#import data: *
#import drawing: *

#let str2int(s) = if s.clusters().all(c => c.match(regex("\d")) != none) {
  Just(int(s))
} else {
  Nothing("`str2int` failed.")
}

// #mapm(str2int, "1", "567", "1314520")
//
// #mapm_(str2int, "1", "567", "1314520")
//
// #mapm(str2int, "1", "刺客", "1314520")
//
// #mapm_(str2int, "1", "刺客", "1314520")
//
// #sequence(..("1", "567", "1314520").map(s => str2int(s)))
//
// #sequence_(..("1", "567", "1314520").map(s => str2int(s)))
//
// #sequence(..("1", "刺客", "1314520").map(s => str2int(s)))
//
// #sequence_(..("1", "刺客", "1314520").map(s => str2int(s)))

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
bind (shorting):
#bind(
  i,
  mother,
  father,
)

// gf
bind\_ (passing):
#bind_(
  i,
  mother,
  father,
  father,
  father,
)

// gm (none)
bind:
#bind(
  i,
  mother,
  mother,
)

// gm (none)
bind\_:
#bind_(
  i,
  mother,
  mother,
  mother,
  mother,
)

*/

#let dct = (("1", 2), ("3", 4))

#maybe-dict(dct)
