# Consketcher

Draws Control Sketches using [fletcher](https://github.com/Jollywatt/typst-fletcher) and [CeTZ](https://github.com/cetz-package/cetz).

Consketcher provides ready-to-use control block diagrams, plus composable node and edge helpers for custom sketches.

## Get Started

Import `consketcher` from the `@preview` namespace.

```typst
#import "@preview/consketcher:0.1.0": *
```

For local development, import it from the `@local` namespace.

```typst
#import "@local/consketcher:0.1.0": *
```

Create a simple open-loop block:

```typst
#block-open(
  transfer: $G(s)$,
  input: $R(s)$,
  output: $Y(s)$,
)
```

Create a closed-loop block:

```typst
#block-closed(
  transfer: $G(s)$,
  transfer2: $H(s)$,
  reference: $R(s)$,
  input: $E(s)$,
  output: $Y(s)$,
  output2: $B(s)$,
  loss: [Error],
)
```

![example](https://raw.githubusercontent.com/ivaquero/typst-consketcher/refs/heads/main/examples/example.png)

![example2](https://raw.githubusercontent.com/ivaquero/typst-consketcher/refs/heads/main/examples/example2.png)

For more details, see [examples.typ](https://github.com/ivaquero/typst-consketcher/blob/main/examples/example.typ).

## Diagram Templates

### Blocks

```typst
#block-open(
  transfer: none,
  input: none,
  output: none,
  width: 2,
  height: 2em,
  line: -2,
  start: 1,
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  node-maker: rnode,
  edge-maker: arrow,
)
```

```typst
#block-closed(
  transfer: none,
  transfer2: none,
  input: none,
  output: none,
  output2: none,
  loss: none,
  reference: none,
  line: 0.5,
  start: 1,
  reference-gap: auto,
  input-gap: auto,
  feedback-height: 1.25,
  label-size: 0.6em,
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  node-maker: rnode,
  junction-maker: summing-junction,
  edge-maker: arrow,
  feedback-edge-maker: uturn-v,
)
```

### Control Systems

```typst
#sys-open(
  controler: none,
  actuator: none,
  process: none,
  input: none,
  output: none,
  output2: none,
  output3: none,
  subunit: none,
  line: -2,
  start: -2,
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  node-maker: rnode,
  edge-maker: arrow,
  boundary-edge-maker: uturn,
  label-maker: label,
)
```

```typst
#sys-closed(
  controler: none,
  actuator: none,
  sensor: none,
  input: none,
  output: none,
  output2: none,
  loss: none,
  reference: none,
  line: 0.5,
  start: 1,
  feedback-height: 1.25,
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  node-maker: rnode,
  junction-maker: summing-junction,
  edge-maker: arrow,
)
```

## Components

Use these helpers inside `control-diagram(...)` or pass them into templates as maker functions.

### Text and Layout

```typst
#ctext(label, size: .8em, font: "Songti SC", ..options)
#control-diagram(spacing: (1.5em, 1.5em), node-stroke: 1pt, mark-scale: 80%, ..body)
#edge-label(body, size: 0.6em, ..options)
#auto-gap(body, scale: 1, fallback: 1)
```

### Nodes

```typst
#rnode(sym, label, height: 2em, corner-radius: 4pt, ..options)

#onode(sym, label, height: 1em, radius: 10pt, ..options)
#label(sym, body, ..options)

#summing-junction(
  sym,
  loss: none,
  plus: text("+", size: 0.8em),
  minus: text("-", size: 1.2em),
  loss-offset: (0, -0.75),
  plus-offset: (-0.4, -0.25),
  minus-offset: (-0.2, 0.35),
  node-maker: onode,
  label-maker: label,
  ..node-options,
)
```

### Edges

```typst
#connector(n1, n2, marks: "-", label: none, label-pos: 0.5, label-side: left, corner: none, corner-radius: 4pt, ..options)

#arrow(n1, n2, label, label-pos: 0.5, label-side: left, dashed: false, corner: none, corner-radius: none, ..options)

#segment(n1, n2, label, label-pos: 0.5, label-side: left, dashed: false, corner: none, corner-radius: none, ..options)

#uturn(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 1.25, corner: right, corner-radius: 4pt, ..options)

#uturn2(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 1.25, corner: right, corner-radius: 4pt, offset: 1, ..options)

#uturn-v(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 2.5, corner: right, corner-radius: 4pt, ..options)

#uturn2-v(n1, n2, label, label-pos: 0.15, label-side: left, marks: "-|>", height: 2.5, corner: right, corner-radius: 4pt, offset: 1, ..options)
```

## Customization

Template functions are composable. Pass custom maker functions to change node, edge, label, or summing-junction behavior without rewriting a whole diagram.

```typst
#let thick-arrow(n1, n2, body, ..options) = arrow(
  n1,
  n2,
  body,
  stroke: 1.5pt,
  ..options,
)

#block-open(
  transfer: $G(s)$,
  input: $u$,
  output: $y$,
  spacing: (2em, 1.2em),
  node-maker: rnode.with(corner-radius: 2pt),
  edge-maker: thick-arrow,
)
```

The source is split into focused modules:

- `src/utils.typ`: shared diagram wrapper, Chinese text helper, and label measurement.
- `src/components.typ`: reusable nodes, labels, summing junctions, and edges.
- `src/charts.typ`: high-level block and control-system templates.

## Clone the Repository

To compile, please refer to the guide on [typst-packages](https://github.com/typst/packages) and clone this repository to your `@local` workspace:

- Linux：
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS：`~/Library/Application\ Support/typst/packages/local`
- Windows：`%APPDATA%/typst/packages/local`

Clone the [consketcher](https://github.com/ivaquero/typst-consketcher) repository in the above path

```bash
git clone https://github.com/ivaquero/typst-consketcher consketcher
```

and then import it in the document

```typst
#import "@local/consketcher:0.1.0": *
```
