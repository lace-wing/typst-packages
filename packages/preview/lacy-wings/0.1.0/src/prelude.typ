//////////
// Math //
//////////

/// Linear interpolation.
/// It allows for any type, so make sure the operations are legal.
///
/// - min (any): The minimum.
/// - max (any): The maximum.
/// - amount (any): The amount to shift from `min` to `max`.
///   If it a `ratio`, then `min` must be a `ratio` too, so `min` and the shifting can be added.
/// -> any
#let lerp(min, max, amount) = min + amount * (max - min)


/// Chained `if-else`'s.
///
/// - subject (any): The subject to test.
/// - cases (arguments): The cases, `(test, out)`'s.
///   `test` can be
///   - a `function` as a predicate, which must take the `subject` and return a `bool`;
///   - a non-`function` as a match, which will be checked with the `subject` for equality.
///   `out` is the outcome when `test` turns `true`.
/// - default (any): The fallback value that is not solidified or called unless all `cases` fail.
/// - call-test (bool): Whether to call the `test`s in `cases` if they are `function`.
/// - call-out (bool): Whether to call the `out`s in `cases` if they are `function`.
/// - call-default (bool): Whether to call the `default` if they are `function`.
/// -> any
#let case(
  subject,
  ..cases,
  default: none,
  call-test: false,
  call-out: false,
  call-default: false,
) = {
  let (macthed, result) = cases
    .pos()
    .fold((false, none), ((stop, result), (test, out)) => if stop {
      (true, result)
    } else if call-test and type(test) == function and test() or test == subject {
      (
        true,
        (
          if call-out and type(out) == function {
            out()
          } else { out }
        ),
      )
    } else {
      (false, result)
    })

  if macthed {
    result
  } else {
    if call-default and type(default) == function {
      default()
    } else {
      default
    }
  }
}

/// Compose a series of functions.
///
/// - funcs (arguments): The functions to be composed, left-to-right.
/// -> any
#let compose(..funcs) = (..args) => (
  funcs
    .pos()
    .fold(args, (out, func) => func(..{
      if type(out) == arguments {
        out
      } else {
        arguments(out)
      }
    }))
)

/// Compose a series of functions and execute with arguments.
///
/// - args (any): Arguments for the composed function, are turned to an `arguments` if not one already.
/// - funcs (arguments): The functions to be composed, left-to-right.
/// -> any
#let compose_(args, ..funcs) = (compose(..funcs))(..{
  if type(args) == arguments {
    args
  } else {
    arguments(args)
  }
})

//////////
// Data //
//////////

#let val-or-call(val, ..args) = if type(val) == function {
  val(..args)
} else { val }

/// Construct a dictionary of `(ctor: ctor, values: values.pos())`.
/// It is used for matching constructors of data.
///
/// ```example
/// #let Just(value) = cnst("Just", value)
/// ```
///
/// - ctor (str): The constructor name.
/// - values (arguments): The arguments for the constructor.
/// -> dictionary
#let cnst(ctor, ..values) = (
  ctor: (if type(ctor) == function { repr(ctor) } else { ctor }),
  values: values.pos(),
)

/// Test if `arg` has a ctor.
///
/// - arg (any): The data to test.
/// -> bool
#let cnsted(arg) = type(arg) == dictionary and arg.at("ctor", default: none) != none

/// Cases of constructors (ctor).
///
/// ```example
/// ctors(
///   ma,
///   ("Nothing", () => Nothing()),
///   ("Just", a => something(a))
/// )
/// ```
///
/// - subject (dictionary): A dictionary with keys "ctor" and "values". You can generate such using `cnst` (construct).
/// - cases (arguments): 2-element arrays of `(ctor, action)` as cases, where `ctor` is a `str` and `action` is a function that takes all elements of `values` for dictionary with such `ctor`.
/// - default (any): Fallback when a ctor is found but not matched. If it is a `function`, it is called with values of the `subject`.
/// - noctor (any): Fallback when `subject` has no ctor.
///   - `auto` → default is used, the call, if does, has no argument.
///   - a `function` → it is called;
///   - otherwise, the value.
///
/// -> any
#let ctors(subject, ..cases, default: none, noctor: auto) = {
  if not cnsted(subject) {
    return if noctor == auto {
      val-or-call(default)
    } else {
      val-or-call(noctor)
    }
  }

  let (_, action) = cases
    .pos()
    .find(((ctor, _)) => {
      if type(ctor) == function { ctor = repr(ctor) }
      ctor == subject.ctor
    })
  if action == none {
    val-or-call(default)
  } else {
    action(..subject.values)
  }
}

/// Data definitions.
#let Data = (
  Maybe: (
    "Just",
    "Nothing",
  ),
)

/// Get the Data from `val`, if any; else `none`.
///
/// - val (any): The value to test.
/// -> str, none
#let get-data(val) = if cnsted(val) {
  let p = Data.pairs().find(((_, inss)) => inss.contains(val.ctor))
  if p == none { return none }
  p.at(0)
}

////////////////////
// Maybe & Either //
////////////////////

// Monad:
// - ctor: type, m
// - return: data builder, a -> m a
// - bind: combinator, m a -> (a -> m b) -> m b

/// Construct a `Just` data.
///
/// - value (any): Just a value.
/// -> dictionary
#let Just(value) = cnst(Just, value)

/// A `Nothing` data.
///
/// - args (arguments): An optional message as the first positional.
/// -> dictionary
#let Nothing(..args) = {
  let fst = args.pos().at(0, default: none)
  ctors(fst, (Nothing, fst), default: cnst(Nothing, fst), noctor: cnst(Nothing, fst))
}

/// Left-to-right chain combinator.
///
/// ```example
/// // Find Dolly's grandfather.
/// #bind(
///   dolly,
///   mother,
///   father,
/// ) // → `Nothing()`, she's a clone!
/// ```
///
/// - ma (dictionary): A `Maybe` data, `Just` or `Nothing`.
/// - ambs (arguments): Functions that build `Maybe`.
/// -> dictionary
#let bind(ma, ..ambs) = (ma, ..ambs.pos()).reduce((ma, amb) => ctors(
  ma,
  (Just, a => amb(a)),
  (Nothing, _ => ma),
  default: Nothing(),
))

/// Turn a list of monadic values into a monadic list. Short-circuits on `Nothing`.
/// For now, specifically handles only `Maybe`.
///
/// - mas (arguments): Monadic values to be sequenced.
/// -> array
#let sequence(..mas) = {
  mas = mas.pos()
  let d = get-data(mas.at(0))
  if (
    mas.fold(d, (t, ma) => {
      if d == none { return none }
      let dma = get-data(ma)
      if d != dma { return none }
      dma
    })
      == none
  ) {
    panic("Unconforming data for `sequence`!")
  }
  let (sht, seq) = mas.fold((false, ()), ((sht, seq), ma) => {
    if sht {
      return (true, seq)
    }
    ctors(
      ma,
      (Just, a => (false, seq + (a,))),
      (Nothing, a => (true, (if a == none { "`sequence` shorted on Nothing." } else { a }))),
      default: (..a) => (true, seq + (a.pos(),)),
    )
  })
  if sht { Nothing(seq) } else {
    case(call-out: true, call-default: true, d, ("Maybe", () => Just(seq)), default: () => panic(
      "Unsupported data `" + d + "`, yet.",
    ))
  }
}

/// `sequence . map`.
///
/// - amb (function): A `function` that builds `m b` from `a` in `arr`.
/// - arr (arguments): Items that `amb` will process.
/// -> dictionary
#let map-m(amb, ..arr) = sequence(..arr.pos().map(a => amb(a)))
