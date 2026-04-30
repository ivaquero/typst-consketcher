#import "utils.typ": *

// node style
// rectangle node
#let rnode(
  sym,
  label,
  height: 2em,
  corner-radius: 4pt,
  ..options,
) = node(
  sym,
  label,
  shape: rect,
  corner-radius: corner-radius,
  height: height,
  ..options,
)

// circle node
#let onode(
  sym,
  label,
  height: 1em,
  radius: 10pt,
  ..options,
) = node(
  sym,
  label,
  shape: circle,
  radius: radius,
  height: height,
  ..options,
)

// label node
#let label(sym, body, ..options) = node(sym, body, stroke: none, ..options)

#let edge-label(body, size: 0.6em, ..options) = if body == none {
  none
} else {
  text(body, size: size, ..options)
}

#let reference(
  sym,
  x-sign: "+",
  y-sign: "-",
  x-offset: -.3,
  y-offset: .3,
  loss: none,
  loss-offset: (0, -0.75),
  node-maker: onode,
  label-maker: label,
  ..node-options,
) = {
  node-maker(sym, none, ..node-options)
  label-maker(
    (sym.at(0) + loss-offset.at(0), sym.at(1) + loss-offset.at(1)),
    loss,
  )
  label-maker(
    (sym.at(0) + x-offset, sym.at(1)),
    x-sign,
  )
  label-maker(
    (sym.at(0), sym.at(1) + y-offset),
    y-sign,
  )
}

// edge style
#let connector(
  n1,
  n2,
  marks: "-",
  label: none,
  label-pos: 0.5,
  label-side: left,
  corner: none,
  corner-radius: 4pt,
  ..options,
) = edge(
  n1,
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  ..options,
)

// edge with arrowhead
#let arrow(
  n1,
  n2,
  label,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
  ..options,
) = connector(
  n1,
  n2,
  marks: if (dashed) { "--|>" } else { "-|>" },
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: if corner-radius == none { 4pt } else { corner-radius },
  ..options,
)

// edge without arrowhead
#let segment(
  n1,
  n2,
  label,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
  ..options,
) = connector(
  n1,
  n2,
  marks: if (dashed) { "--" } else { "-" },
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: if corner-radius == none { 4pt } else { corner-radius },
  ..options,
)

// u-turned edge
#let uturn(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 1.25,
  corner: right,
  corner-radius: 4pt,
  ..options,
) = edge(
  n1,
  (n1.at(0), n1.at(1) + height),
  (n2.at(0), n2.at(1) + height),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  kind: "poly",
  ..options,
)

// twice u-turned edge
#let uturn2(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 1.25,
  corner: right,
  corner-radius: 4pt,
  offset: 1,
  ..options,
) = edge(
  n1,
  (n1.at(0), n1.at(1) + height),
  (n2.at(0) - offset, n2.at(1) + height),
  (n2.at(0) - offset, n2.at(1)),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  kind: "poly",
  ..options,
)

// vertical u-turned edge
#let uturn-v(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 2.5,
  corner: right,
  corner-radius: 4pt,
  ..options,
) = edge(
  n1,
  (n1.at(0) + height, n1.at(1)),
  (n2.at(0) + height, n2.at(1)),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  kind: "poly",
  ..options,
)

// vertical twice u-turned edge
#let uturn2-v(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 2.5,
  corner: right,
  corner-radius: 4pt,
  offset: 1,
  ..options,
) = edge(
  n1,
  (n1.at(0) + height, n1.at(1) - offset),
  (n2.at(0), n2.at(1) - offset),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  kind: "poly",
  ..options,
)
