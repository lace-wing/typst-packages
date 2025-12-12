#import "@preview/lacy-ubc-math-project:0.3.0": *
#import util: config-state, embed-pin, make-content-tree, make-tree-content
#config-state.update(defaults)

#let leaf(a) = embed-pin(usage: "leaf", data: make-content-tree(a))

#let t = make-content-tree[
  #set text(red)
  #leaf(question([what #leaf(question[whhhha])]))
]

#t

// #qns(..t.flatten())
