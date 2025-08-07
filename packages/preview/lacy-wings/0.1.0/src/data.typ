#import "prelude.typ": *

/// Maybe a dictionary.
/// Returns a `maybe` data.
///
/// ```example
/// #ctors(
///   maybe-dict(a),
///   ("Just", a => [It is a dictionary.]),
///   ("Nothing", () => [It is nothing])
/// )
/// ```
///
/// - value (any): The data to convert to dictionary.
/// -> dictionary
#let maybe-dict(value) = {
  let t = type(value)
  case(
    call-out: true,
    t,
    (dictionary, Just(value)),
    (
      array,
      () => if value.all(el => type(el) == array and el.len() == 2 and type(el.at(0)) == str) {
        Just(value.to-dict())
      } else {
        Nothing()
      },
    ),
    (module, () => Just(dictionary(value))),
    (arguments, () => Just(value.named())),
    (function, () => try-dict(value())),
    default: Nothing(),
  )
}

/// Convert `value` to a dictionary, panic on fail.
///
/// - value (dictionary, module, function, arguments): The data to convert to dictionary.
/// -> dictionary
#let to-dict(value) = {
  let t = type(value)
  case(
    call-out: true,
    call-default: true,
    t,
    (dictionary, value),
    (array, () => value.to-dict()),
    (module, () => dictionary(value)),
    (arguments, () => value.named()),
    (function, () => to-dict(value())),
    default: () => panic("A value of type `" + str(t) + "` cannot be converted to dictionary!"),
  )
}

/// Merge dictionaries, left-to-right.
/// On merge, values of existing keys are replaced, and values of new keys are added.
/// Values of type `dictionary` are not merged, instead their own pairs are merged.
///
/// - dicts (arguments): The `dictionary`s to be merged.
/// -> dictionary
#let merge-dicts(..dicts) = (
  dicts
    .pos()
    .reduce((orig, cand) => cand
      .keys()
      .fold(orig, (acc, k) => if k in orig.keys()
        and type(orig.at(k)) == dictionary
        and type(cand.at(k)) == dictionary {
        acc + ((k): merge-dicts(orig.at(k), cand.at(k)))
      } else {
        acc + ((k): cand.at(k))
      }))
)

/// Merge dictionaries, but non-`dictionary` arguments are first converted to `dictionary` and the value of the "config" key is taken.
///
/// - conf (arguments): The `dictionary`s a/o `module`s to be merged. Can also be `arguments` or anything accepted by `util.to-dict`.
/// -> dictionary
#let merge-configs(..conf) = merge-dicts(..conf
  .pos()
  .map(c => if type(c) == module { to-dict(c).at("config", default: (:)) } else { to-dict(c) }))

