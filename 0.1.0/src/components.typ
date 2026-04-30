#import "@preview/cetz:0.5.0": draw, util
#import "utils.typ": *

#let _state(ctx) = ctx.shared-state.at(
  "consketcher",
  default: (
    nodes: (:),
    defaults: (
      node-stroke: 1pt,
      mark-scale: 80%,
    ),
  ),
)

#let _defaults(ctx) = _state(ctx).defaults

#let _node-key(sym) = if type(sym) == str {
  sym
} else {
  repr(sym)
}

#let _register-node(sym, data) = draw.set-ctx(ctx => {
  let ctx = ctx
  let state = _state(ctx)
  state.nodes.insert(_node-key(sym), data)
  ctx.shared-state.insert("consketcher", state)
  ctx
})

#let _lookup-node(ctx, sym) = (
  _state(ctx).nodes.at(_node-key(sym), default: none)
)

#let _resolve(ctx, value) = util.resolve-number(ctx, value)

#let _measure(ctx, body) = if body == none {
  (0, 0)
} else {
  util.measure(ctx, body)
}

#let _rect-corners(center, width, height) = {
  let half-width = width / 2
  let half-height = height / 2
  (
    (center.at(0) - half-width, center.at(1) - half-height),
    (center.at(0) + half-width, center.at(1) + half-height),
  )
}

#let _triangle-points(center, width, height, dir) = {
  let half-width = width / 2
  let half-height = height / 2
  if dir == right or dir == "right" {
    (
      (center.at(0) - half-width, center.at(1) + half-height),
      (center.at(0) - half-width, center.at(1) - half-height),
      (center.at(0) + half-width, center.at(1)),
    )
  } else if dir == up or dir == "up" {
    (
      (center.at(0) - half-width, center.at(1) - half-height),
      (center.at(0) + half-width, center.at(1) - half-height),
      (center.at(0), center.at(1) + half-height),
    )
  } else if dir == down or dir == "down" {
    (
      (center.at(0) - half-width, center.at(1) + half-height),
      (center.at(0) + half-width, center.at(1) + half-height),
      (center.at(0), center.at(1) - half-height),
    )
  } else {
    (
      (center.at(0) + half-width, center.at(1) + half-height),
      (center.at(0) + half-width, center.at(1) - half-height),
      (center.at(0) - half-width, center.at(1)),
    )
  }
}

#let _offset-point(point, offset) = (
  point.at(0) + offset.at(0),
  point.at(1) + offset.at(1),
)

#let _as-offset(x, y) = if type(y) == array {
  y
} else {
  (x, y)
}

#let _sign(value) = if value < 0 { -1 } else if value > 0 { 1 } else { 0 }

#let _trim-rect(node, toward) = {
  let center = node.center
  let dx = toward.at(0) - center.at(0)
  let dy = toward.at(1) - center.at(1)
  if dx == 0 and dy == 0 {
    center
  } else {
    let half-width = node.width / 2
    let half-height = node.height / 2
    let scale-x = if dx == 0 { none } else { half-width / calc.abs(dx) }
    let scale-y = if dy == 0 { none } else { half-height / calc.abs(dy) }
    let scale = if scale-x == none {
      scale-y
    } else if scale-y == none {
      scale-x
    } else if scale-x < scale-y {
      scale-x
    } else {
      scale-y
    }
    (
      center.at(0) + dx * scale,
      center.at(1) + dy * scale,
    )
  }
}

#let _trim-circle(node, toward) = {
  let center = node.center
  let dx = toward.at(0) - center.at(0)
  let dy = toward.at(1) - center.at(1)
  if dx == 0 and dy == 0 {
    center
  } else {
    let rx = node.rx
    let ry = node.ry
    let scale = calc.sqrt((dx * dx) / (rx * rx) + (dy * dy) / (ry * ry))
    (
      center.at(0) + dx / scale,
      center.at(1) + dy / scale,
    )
  }
}

#let _cross(a, b) = a.at(0) * b.at(1) - a.at(1) * b.at(0)

#let _sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))

#let _add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))

#let _scale(v, factor) = (v.at(0) * factor, v.at(1) * factor)

#let _trim-polygon(node, toward) = {
  let center = node.center
  let ray = _sub(toward, center)
  if ray.at(0) == 0 and ray.at(1) == 0 {
    center
  } else {
    let best = none
    let points = node.points
    for i in range(points.len()) {
      let a = points.at(i)
      let b = points.at(if i + 1 == points.len() { 0 } else { i + 1 })
      let edge = _sub(b, a)
      let denom = _cross(ray, edge)
      if calc.abs(denom) > 1e-6 {
        let delta = _sub(a, center)
        let ray-t = _cross(delta, edge) / denom
        let seg-t = _cross(delta, ray) / denom
        if ray-t >= 0 and seg-t >= 0 and seg-t <= 1 {
          let candidate = _add(center, _scale(ray, ray-t))
          if best == none or ray-t < best.t {
            best = (t: ray-t, point: candidate)
          }
        }
      }
    }
    if best == none { center } else { best.point }
  }
}

#let _trim-point(node, toward) = if node == none {
  none
} else if node.kind == "rect" {
  _trim-rect(node, toward)
} else if node.kind == "circle" {
  _trim-circle(node, toward)
} else if node.kind == "polygon" {
  _trim-polygon(node, toward)
} else {
  none
}

#let _path-points(n1, n2, corner: none) = {
  if n1.at(0) == n2.at(0) or n1.at(1) == n2.at(1) or corner == none {
    (n1, n2)
  } else if corner == right or corner == "right" {
    (n1, (n1.at(0), n2.at(1)), n2)
  } else {
    (n1, (n2.at(0), n1.at(1)), n2)
  }
}

#let _trim-path(ctx, points) = {
  let points = points
  if points.len() >= 2 {
    let start-node = _lookup-node(ctx, points.first())
    let end-node = _lookup-node(ctx, points.last())

    let start = _trim-point(start-node, points.at(1))
    if start != none {
      points.at(0) = start
    }

    let end = _trim-point(end-node, points.at(points.len() - 2))
    if end != none {
      points.at(points.len() - 1) = end
    }
  }
  points
}

#let _segment-length(a, b) = calc.sqrt(
  calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2),
)

#let _point-on-path(points, ratio) = {
  if points.len() <= 1 {
    (point: points.first(), dir: (1, 0))
  } else {
    let lengths = ()
    let total = 0.0
    for i in range(points.len() - 1) {
      let length = _segment-length(points.at(i), points.at(i + 1))
      lengths.push(length)
      total += length
    }

    if total == 0 {
      (point: points.first(), dir: (1, 0))
    } else {
      let target = calc.clamp(ratio, 0, 1) * total
      let walked = 0.0
      for i in range(lengths.len()) {
        let length = lengths.at(i)
        let next = walked + length
        if target <= next or i == lengths.len() - 1 {
          let start = points.at(i)
          let stop = points.at(i + 1)
          let local = if length == 0 { 0 } else { (target - walked) / length }
          return (
            point: (
              start.at(0) + (stop.at(0) - start.at(0)) * local,
              start.at(1) + (stop.at(1) - start.at(1)) * local,
            ),
            dir: (stop.at(0) - start.at(0), stop.at(1) - start.at(1)),
          )
        }
        walked = next
      }
      (
        point: points.last(),
        dir: _sub(points.last(), points.at(points.len() - 2)),
      )
    }
  }
}

#let _label-anchor(point, dir, side, offset) = {
  let length = _segment-length((0, 0), dir)
  if length == 0 {
    point
  } else {
    let normal = (
      -dir.at(1) / length,
      dir.at(0) / length,
    )
    let signed-offset = if side == right or side == "right" {
      -offset
    } else {
      offset
    }
    (
      point.at(0) + normal.at(0) * signed-offset,
      point.at(1) + normal.at(1) * signed-offset,
    )
  }
}

#let _stroke(stroke, dashed: false) = if not dashed {
  stroke
} else if type(stroke) == dictionary {
  let stroke = stroke
  stroke.insert("dash", "dashed")
  stroke
} else if type(stroke) == length {
  (thickness: stroke, dash: "dashed")
} else {
  (paint: stroke, thickness: 1pt, dash: "dashed")
}

#let _mark(marks, scale) = if type(marks) == str and marks.contains(">") {
  (
    end: "stealth",
    scale: if type(scale) == ratio { scale / 100% } else { scale },
  )
} else {
  none
}

#let _edge-body(
  ctx,
  points,
  label,
  label-pos,
  label-side,
  marks,
  stroke,
  dashed,
  name,
) = {
  let trimmed = _trim-path(ctx, points)
  let defaults = _defaults(ctx)
  let stroke = if stroke == auto { defaults.node-stroke } else { stroke }
  let body = draw.line(
    ..trimmed,
    name: name,
    stroke: _stroke(
      stroke,
      dashed: dashed
        or (
          type(marks) == str and marks.starts-with("--")
        ),
    ),
    mark: _mark(marks, defaults.mark-scale),
  )

  if label != none {
    let label-size = _measure(ctx, label)
    let mark = _point-on-path(trimmed, label-pos)
    let offset = calc.max(label-size.at(1) / 2 + 0.15, 0.25)
    body += draw.content(
      _label-anchor(mark.point, mark.dir, label-side, offset),
      label,
    )
  }

  body
}

// node style
// rectangle node
#let rnode(
  sym,
  label,
  shape: rect,
  width: auto,
  height: 2em,
  corner-radius: 4pt,
  fill: none,
  stroke: auto,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = shape
  let width = if width == auto {
    let measured = _measure(ctx, label)
    let padding = _resolve(ctx, 0.8em)
    calc.max(measured.at(0) + padding, _resolve(ctx, height) * 1.6)
  } else {
    _resolve(ctx, width)
  }
  let height = _resolve(ctx, height)
  let stroke = if stroke == auto { _defaults(ctx).node-stroke } else { stroke }
  let (a, b) = _rect-corners(sym, width, height)

  (
    _register-node(
      sym,
      (
        kind: "rect",
        center: sym,
        width: width,
        height: height,
      ),
    )
      + draw.rect(
        a,
        b,
        radius: corner-radius,
        fill: fill,
        stroke: stroke,
      )
      + if label == none {
        ()
      } else {
        draw.content(sym, label)
      }
  )
})

// circle node
#let onode(
  sym,
  label,
  shape: circle,
  height: 1em,
  radius: 10pt,
  fill: none,
  stroke: auto,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (shape, height, options)
  let measured = _measure(ctx, label)
  let padding = _resolve(ctx, 0.35em)
  let rx = calc.max(_resolve(ctx, radius), measured.at(0) / 2 + padding)
  let ry = calc.max(_resolve(ctx, radius), measured.at(1) / 2 + padding)
  let stroke = if stroke == auto { _defaults(ctx).node-stroke } else { stroke }

  (
    _register-node(
      sym,
      (
        kind: "circle",
        center: sym,
        rx: rx,
        ry: ry,
      ),
    )
      + draw.circle(
        sym,
        radius: (rx, ry),
        fill: fill,
        stroke: stroke,
      )
      + if label == none {
        ()
      } else {
        draw.content(sym, label)
      }
  )
})

#let gain-node(
  sym,
  label,
  dir: left,
  width: 4em,
  height: 4em,
  fit: 0.8,
  fill: none,
  stroke: auto,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (fit, options)
  let width = _resolve(ctx, width)
  let height = _resolve(ctx, height)
  let stroke = if stroke == auto { _defaults(ctx).node-stroke } else { stroke }
  let points = _triangle-points(sym, width, height, dir)

  (
    _register-node(
      sym,
      (
        kind: "polygon",
        center: sym,
        points: points,
      ),
    )
      + draw.line(
        ..points,
        close: true,
        fill: fill,
        stroke: stroke,
      )
      + if label == none {
        ()
      } else {
        draw.content(sym, label)
      }
  )
})

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
#let label(sym, body, stroke: none, fill: none, inset: 0pt, ..options) = {
  let _ = options
  if stroke == none and fill == none {
    draw.content(sym, body)
  } else {
    draw.content(sym, box(inset: inset, stroke: stroke, fill: fill, body))
  }
}

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
  let body = node-maker(sym, none, ..node-options)
  for sign in signs {
    if sign.body != none {
      body += label-maker(
        _offset-point(sym, sign.offset),
        sign.body,
      )
    }
  }
  draw.scope(body)
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
    (body: loss, offset: _as-offset(0, loss-offset)),
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
  stroke: auto,
  name: none,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (corner, corner-radius, options)
  _edge-body(
    ctx,
    (
      n1,
      (n1.at(0), n1.at(1) + height),
      (n2.at(0), n2.at(1) + height),
      n2,
    ),
    label,
    label-pos,
    label-side,
    marks,
    stroke,
    false,
    name,
  )
})

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
  stroke: auto,
  name: none,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (corner, corner-radius, options)
  _edge-body(
    ctx,
    (
      n1,
      (n1.at(0), n1.at(1) + height),
      (n2.at(0) - offset, n2.at(1) + height),
      (n2.at(0) - offset, n2.at(1)),
      n2,
    ),
    label,
    label-pos,
    label-side,
    marks,
    stroke,
    false,
    name,
  )
})

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
  stroke: auto,
  name: none,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (corner, corner-radius, options)
  _edge-body(
    ctx,
    (
      n1,
      (n1.at(0) + height, n1.at(1)),
      (n2.at(0) + height, n2.at(1)),
      n2,
    ),
    label,
    label-pos,
    label-side,
    marks,
    stroke,
    false,
    name,
  )
})

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
  stroke: auto,
  name: none,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (corner, corner-radius, options)
  _edge-body(
    ctx,
    (
      n1,
      (n1.at(0) + height, n1.at(1) - offset),
      (n2.at(0), n2.at(1) - offset),
      n2,
    ),
    label,
    label-pos,
    label-side,
    marks,
    stroke,
    false,
    name,
  )
})

#let dashed-box(
  enclose,
  stroke: (thickness: 0.5pt, dash: "dashed"),
  inset: 1.5em,
  fill: none,
  corner-radius: 4pt,
  ..options,
) = draw.rect-around(
  enclose,
  stroke: stroke,
  padding: inset,
  fill: fill,
  radius: corner-radius,
  ..options,
)
