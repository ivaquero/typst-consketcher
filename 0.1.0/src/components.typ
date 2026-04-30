#import "@preview/fletcher:0.5.8": edge, node, shapes
#import "utils.typ": *

// node style
// rectangle node
#let rnode(
  sym,
  label,
  shape: rect,
  height: 2em,
  corner-radius: 4pt,
  ..options,
) = node(
  sym,
  label,
  shape: shape,
  corner-radius: corner-radius,
  height: height,
  ..options,
)

// circle node
#let onode(
  sym,
  label,
  shape: circle,
  height: 1em,
  radius: 10pt,
  ..options,
) = node(
  sym,
  label,
  shape: shape,
  radius: radius,
  height: height,
  ..options,
)

#let gain-node(
  sym,
  label,
  dir: left,
  width: 4em,
  height: 4em,
  fit: 0.8,
  ..options,
) = node(
  sym,
  label,
  shape: shapes.triangle.with(dir: dir, fit: fit),
  width: width,
  height: height,
  ..options,
)

#let formula-node(
  sym,
  body,
  width: 8em,
  height: 3em,
  ..options,
) = rnode(
  sym,
  body,
  width: width,
  height: height,
  ..options,
)

// label node
#let label(sym, body, stroke: none, ..options) = node(
  sym,
  body,
  stroke: stroke,
  ..options,
)

#let edge-label(body, size: 0.6em, ..options) = if body == none {
  none
} else {
  text(body, size: size, ..options)
}

#let signed-node(
  sym,
  signs: (),
  node-maker: onode,
  label-maker: label,
  ..node-options,
) = {
  node-maker(sym, none, ..node-options)
  for sign in signs {
    if sign.body != none {
      label-maker(
        (sym.at(0) + sign.offset.at(0), sym.at(1) + sign.offset.at(1)),
        sign.body,
      )
    }
  }
}

#let reference(
  sym,
  x-sign: "+",
  y-sign: "-",
  x-offset: -.3,
  y-offset: .3,
  loss: none,
  loss-offset: -.5,
  ..options,
) = signed-node(
  sym,
  signs: (
    (body: loss, offset: (0, loss-offset)),
    (body: x-sign, offset: (x-offset, 0)),
    (body: y-sign, offset: (0, y-offset)),
  ),
  ..options,
)

#let reference3(
  sym,
  x: "+",
  top: "+",
  bottom: "+",
  x-offset: -0.25,
  top-offset: -0.25,
  bottom-offset: 0.25,
  radius: 1.35em,
  node-maker: onode,
  label-maker: label,
  ..node-options,
) = signed-node(
  sym,
  signs: (
    (body: x, offset: (x-offset, 0)),
    (body: top, offset: (0, top-offset)),
    (body: bottom, offset: (0, bottom-offset)),
  ),
  radius: radius,
  node-maker: node-maker,
  label-maker: label-maker,
  ..node-options,
)

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
  marks: none,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
  ..options,
) = connector(
  n1,
  n2,
  marks: if marks != none { marks } else if dashed { "--|>" } else { "-|>" },
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
  marks: none,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
  ..options,
) = connector(
  n1,
  n2,
  marks: if marks != none { marks } else if dashed { "--" } else { "-" },
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
  ..options,
)

#let dashed-box(
  enclose,
  stroke: (thickness: 0.5pt, dash: "dashed"),
  inset: 1.5em,
  fill: none,
  corner-radius: 4pt,
  ..options,
) = node(
  enclose: enclose,
  shape: rect,
  stroke: stroke,
  fill: fill,
  inset: inset,
  corner-radius: corner-radius,
  ..options,
)
