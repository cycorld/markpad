// Generates AppIcon.icns: rounded indigo square with a white "M↓" glyph.
// Usage: swift Scripts/make-icon.swift Assets/AppIcon.icns
import AppKit

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let iconset = FileManager.default.temporaryDirectory.appendingPathComponent("MarkPad.iconset")
try? FileManager.default.removeItem(at: iconset)
try! FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: px, height: px)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let s = CGFloat(px)
    let inset = s * 0.09
    let square = NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let shape = NSBezierPath(roundedRect: square, xRadius: s * 0.19, yRadius: s * 0.19)
    NSGradient(
        starting: NSColor(calibratedRed: 0.24, green: 0.30, blue: 0.56, alpha: 1),
        ending: NSColor(calibratedRed: 0.10, green: 0.12, blue: 0.26, alpha: 1)
    )!.draw(in: shape, angle: -60)

    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: s * 0.40, weight: .heavy),
        .foregroundColor: NSColor.white,
        .kern: -s * 0.01,
    ]
    let glyph = NSAttributedString(string: "M↓", attributes: attrs)
    let size = glyph.size()
    glyph.draw(at: NSPoint(x: (s - size.width) / 2, y: (s - size.height) / 2 + s * 0.01))

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

for base in [16, 32, 128, 256, 512] {
    try! render(base).write(to: iconset.appendingPathComponent("icon_\(base)x\(base).png"))
    try! render(base * 2).write(to: iconset.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconset.path, "-o", output.path]
try! task.run()
task.waitUntilExit()
print(task.terminationStatus == 0 ? "wrote \(output.path)" : "iconutil failed")
exit(task.terminationStatus)
