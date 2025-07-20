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


//////////
// Data //
//////////

/// Construct a dictionary of `(ctor: ctor, values: values.pos())`.
/// It is used for matching constructors of data.
///
/// ```example
/// #let Just(value) = cnst("Just", value)
/// #let Nothing = cnst("Nothing")
/// ```
///
/// - ctor (str): The constructor name.
/// - values (arguments): The arguments for the constructor.
/// -> dictionary
#let cnst(ctor, ..values) = (
  ctor: (if type(ctor) == function { repr(ctor) } else { ctor }),
  values: values.pos(),
)

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
///
/// -> any
#let ctors(subject, ..cases, default: none) = {
  let (_, action) = cases
    .pos()
    .find(((ctor, _)) => {
      if type(ctor) == function { ctor = repr(ctor) }
      ctor == subject.ctor
    })
  if action == none {
    default
  } else {
    action(..subject.values)
  }
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
/// -> dictionary
#let Nothing() = cnst(Nothing)

//TODO doc
#let Left(message) = cnst(Left, message)
#let Right(value) = cnst(Right, value)

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
  (Right, a => amb(a)),
  (Left, a => Left(a)),
  default: Nothing(),
))

#let sequence(..mas) = none

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
