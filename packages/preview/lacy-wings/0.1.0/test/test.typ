#import "@preview/lacy-wings:0.1.0": *
#import data: *
#import drawing: *

#set text(size: 2cm)

www#blur-orth[www]

中文#blur-orth[中文]

中文#dash-orth("bottom")[中文]中文

www#dash-orth("right")[www]

#dash-orth("left")[中文]中文


/*
#let sheep(id, f, m) = Right((
  id: id,
  father: f,
  mother: m,
))

#let gf = sheep(0, Left("no dad"), Left("no mom"))
#let f = sheep(1, Left("no dad"), Left("no mom"))
#let m = sheep(2, gf, Left("no mom"))
#let i = sheep(3, f, m)

#let father(s) = s.father
#let mother(s) = s.mother

// gf
#bind(
  i,
  mother,
  father,
)

#context here().position()
// gm (none)
#bind(
  i,
  mother,
  mother,
)

