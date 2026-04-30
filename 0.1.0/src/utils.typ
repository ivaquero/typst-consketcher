#import "@preview/cetz:0.5.0": canvas, draw

// shared diagram style
#let control-diagram(
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  ..body,
) = {
  let raw-body = body.pos()
  let body = ()
  for item in raw-body {
    if type(item) == function {
      body.push(item)
    } else if type(item) == array {
      for sub in item {
        if type(sub) == function {
          body.push(sub)
        }
      }
    }
  }
  let setup = draw.set-ctx(ctx => {
    let ctx = ctx
    ctx.shared-state.insert(
      "consketcher",
      (
        nodes: (:),
        defaults: (
          node-stroke: node-stroke,
          mark-scale: mark-scale,
        ),
      ),
    )
    ctx
  })
  canvas(
    length: spacing.at(0),
    setup + draw.scope(body),
  )
}

// font style
// chinese text
#let ctext(
  label,
  size: .8em,
  font: "Songti SC",
  ..options,
) = text(
  label,
  size: size,
  font: font,
  ..options,
)

#let label-length(body, fallback: 1) = if body == none {
  fallback
} else if type(body) == content {
  body.body.children.len()
} else if type(body) == str {
  body.len()
} else {
  fallback
}

#let auto-gap(body, scale: 1, fallback: 1) = {
  let measured = label-length(body, fallback: fallback) * scale
  if measured < fallback {
    fallback
  } else {
    measured
  }
}
