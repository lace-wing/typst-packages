#import "prelude.typ": *

/// Convert numbers to a coordinate dictionary.
///
/// - args (arguments): Dimensions, they are taken as follow:
///   - positional `int`s/`decimal`s/`float`s → in order of x, y, z;
///   - an `array` → elements in order of x, y, z;
///   - a `dictionary` → every key that is "x", "y" or "z";
///   - an `arguments` → try the `dictionary` conversion first, then use `array`'s if result is empty.
/// -> dictionary
#let to-dims(..args) = {
  args = args.pos()
  let fst = args.at(0)
  let t = type(fst)
  let dims = ("x", "y", "z")
  case(
    call-test: true,
    call-out: true,
    call-default: true,
    t,
    (
      () => t in (int, decimal, float),
      () => dims.zip(args),
    ),
    (
      array,
      () => dims.zip(fst),
    ),
    (
      dictionary,
      () => dims.map(d => if d in fst { ((d): fst.at(d)) }).join(),
    ),
    (
      arguments,
      () => {
        let fstn = fst.named()
        let dimsn = dims.map(d => if d in fstn { ((d): fstn.at(d)) }).join()
        if dimsn != (:) { return dimsn }
        let fstp = fst.pos()
        dims.zip(fstp)
      },
    ),
    default: () => panic("Invalid dimensions!"),
  )
}

#let ctx(
  pn,
  px,
  py,
  pw,
  ph,
  spaced: false,
  spacer: false,
) = (
  pn: pn,
  px: px,
  py: py,
  pw: pw,
  ph: ph,
  spaced: spaced,
  spacer: spacer,
)

#let ctx-spacer = ctx(
  0,
  0pt,
  0pt,
  0pt,
  0pt,
  spacer: true,
)

#let spaced(spacer, body) = context {
  let (width, height) = measure(spacer)
  box(width: width, height: height, place(body))
}

#let draw-ctx(drawer) = context {
  let spacer = drawer(ctx-spacer)
  let (width, height) = measure(spacer)
  spaced(spacer, {
    let pos = here().position()
    let (pn, px, py) = (pos.page, pos.x, pos.y)
    drawer(ctx(
      pn,
      px,
      py,
      width,
      height,
      spaced: true,
    ))
  })
}

//////////////
// Drawings //
//////////////

#let blur-cross(
  steps: (
    left: 2,
    right: 2,
    top: 2,
    bottom: 2,
  ),
  shifts: (
    left: 2pt,
    right: 2pt,
    top: 1pt,
    bottom: 1pt,
  ),
  orig: auto,
  body,
) = {
  if orig == auto and type(body) != function {
    orig = body
    body = (dir, step, step-max) => text(fill: black.transparentize(lerp(70%, 90%, step / step-max)), body)
  }
  spaced(orig, {
    place(orig)
    steps
      .keys()
      .map(k => range(1, steps.at(k) + 1).map(s => place(
        ..case(
          k,
          ("left", (dx: s * shifts.at(k) * -1)),
          ("right", (dx: s * shifts.at(k))),
          ("top", (dy: s * shifts.at(k) * -1)),
          ("bottom", (dy: s * shifts.at(k))),
        ),
        body(k, s, steps.at(k)),
      )))
      .flatten()
      .join()
  })
}
