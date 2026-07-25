import AppKit
import CoreGraphics

// Usage: swift make_iterm_icon.swift <input-1024.png> <output-1024.png>
let inPath = CommandLine.arguments[1]
let outPath = CommandLine.arguments[2]

guard let img = NSImage(contentsOfFile: inPath),
      let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff) else {
    fatalError("cannot load \(inPath)")
}
let w = rep.pixelsWide, h = rep.pixelsHigh

// 1. Find bounding box of the white ">_" glyph, scanning only the screen
//    interior window where it lives (avoids the light bezel highlights).
let scanX = 180...560, scanY = 160...430
var minX = w, maxX = 0, minY = h, maxY = 0
for y in scanY {
    for x in scanX {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8 && c.alphaComponent > 0.5 {
            if x < minX { minX = x }; if x > maxX { maxX = x }
            if y < minY { minY = y }; if y > maxY { maxY = y }
        }
    }
}
print("glyph bbox (bitmap coords, y down): x \(minX)-\(maxX)  y \(minY)-\(maxY)")
guard maxX > minX, maxY > minY else { fatalError("glyph not found") }

// 2. Erase glyph: fill expanded bbox row by row with color sampled to its left
//    (per-row sampling preserves the screen's vertical gradient).
let pad = 14
let x0 = max(0, minX - pad), x1 = min(w - 1, maxX + pad)
let y0 = max(0, minY - pad), y1 = min(h - 1, maxY + pad)
let sampleX = max(0, minX - 30)
for y in y0...y1 {
    guard let c = rep.colorAt(x: sampleX, y: y) else { continue }
    for x in x0...x1 {
        rep.setColor(c, atX: x, y: y)
    }
}

// 3. Draw green "$" + block cursor over the erased region.
let bboxH = CGFloat(maxY - minY + 1)
// Convert glyph bbox to view coords (y up)
let glyphTopView = CGFloat(h - minY)
let glyphBottomView = CGFloat(h - maxY)

let canvas = NSImage(size: NSSize(width: w, height: h))
canvas.lockFocus()
rep.draw(in: NSRect(x: 0, y: 0, width: w, height: h))

let green = NSColor(calibratedRed: 0.22, green: 0.85, blue: 0.29, alpha: 1.0)
let fontSize = bboxH * 1.35
guard let font = NSFont(name: "Menlo-Bold", size: fontSize) else { fatalError("no Menlo-Bold") }
let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: green]
let dollar = NSAttributedString(string: "$", attributes: attrs)
let dSize = dollar.size()

// Baseline such that the dollar's vertical center (cap-height band plus the
// slight over/undershoot of "$") is centered on the old glyph's band.
let bandMidY = (glyphTopView + glyphBottomView) / 2
let dollarVisualHalf = fontSize * 0.42   // "$" extends ~0.84em total (incl. vertical strokes)
let baselineY = bandMidY - fontSize * 0.35  // cap center sits ~0.35em above baseline
_ = dollarVisualHalf

let startX = CGFloat(minX)
// draw(at:) in an unflipped context: point = origin of the string's bounding
// box (bottom-left, includes font descender below baseline).
let bboxOriginY = baselineY + font.descender  // descender is negative
dollar.draw(at: NSPoint(x: startX, y: bboxOriginY))

// Block cursor after the "$", spanning the same band as the dollar strokes.
let cursorW = dSize.width * 0.34
let gap = dSize.width * 0.40
let cursorH = fontSize * 0.84
let cursorRect = NSRect(x: startX + dSize.width + gap,
                        y: bandMidY - cursorH / 2,
                        width: cursorW,
                        height: cursorH)
green.setFill()
NSBezierPath(roundedRect: cursorRect, xRadius: cursorW * 0.16, yRadius: cursorW * 0.16).fill()

canvas.unlockFocus()

guard let outTiff = canvas.tiffRepresentation,
      let outRep = NSBitmapImageRep(data: outTiff),
      let png = outRep.representation(using: .png, properties: [:]) else {
    fatalError("cannot encode output")
}
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
