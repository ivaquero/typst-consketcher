#import "@preview/cetz:0.5.0": draw
#import "core.typ": *

#let edge-label(body, size: 0.6em, ..options) = if body == none {
  none
} else {
  text(body, size: size, ..options)
}

#let connector(
  n1,
  n2,
  marks: "-",
  label: none,
  label-pos: 0.5,
  label-side: left,
  corner: none,
  corner-radius: 4pt,
  stroke: auto,
  name: none,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (corner-radius, options)
  _edge-body(
    ctx,
    _path-points(n1, n2, corner: corner),
    label,
    label-pos,
    label-side,
    marks,
    stroke,
    false,
    name,
  )
})

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
  stroke: auto,
  name: none,
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
  stroke: stroke,
  name: name,
  ..options,
)

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
  stroke: auto,
  name: none,
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
  stroke: stroke,
  name: name,
  ..options,
)

#let _uturn(
  n1,
  n2,
  label,
  label-pos,
  label-side,
  marks,
  height,
  offset: none,
  vertical: false,
  stroke: auto,
  name: none,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = options
  _edge-body(
    ctx,
    _uturn-points(n1, n2, height, offset: offset, vertical: vertical),
    label,
    label-pos,
    label-side,
    marks,
    stroke,
    false,
    name,
  )
})

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
  stroke: auto,
  name: none,
  ..options,
) = {
  let _ = (corner, corner-radius)
  _uturn(
    n1,
    n2,
    label,
    label-pos,
    label-side,
    marks,
    height,
    stroke: stroke,
    name: name,
    ..options,
  )
}

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
  stroke: auto,
  name: none,
  ..options,
) = {
  let _ = (corner, corner-radius)
  _uturn(
    n1,
    n2,
    label,
    label-pos,
    label-side,
    marks,
    height,
    offset: offset,
    stroke: stroke,
    name: name,
    ..options,
  )
}

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
  stroke: auto,
  name: none,
  ..options,
) = {
  let _ = (corner, corner-radius)
  _uturn(
    n1,
    n2,
    label,
    label-pos,
    label-side,
    marks,
    height,
    vertical: true,
    stroke: stroke,
    name: name,
    ..options,
  )
}

#let uturn_v = uturn-v

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
  stroke: auto,
  name: none,
  ..options,
) = {
  let _ = (corner, corner-radius)
  _uturn(
    n1,
    n2,
    label,
    label-pos,
    label-side,
    marks,
    height,
    offset: offset,
    vertical: true,
    stroke: stroke,
    name: name,
    ..options,
  )
}

#let uturn2_v = uturn2-v
