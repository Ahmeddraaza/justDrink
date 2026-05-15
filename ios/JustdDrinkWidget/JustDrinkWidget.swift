import WidgetKit
import SwiftUI
import AppIntents

private let appGroup = "group.com.swifteck.justdrink"

// MARK: - Background Log Intent (no app launch)
struct LogWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a glass of water"
    static var description = IntentDescription("Logs one glass of water directly from the widget.")

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: appGroup)
        let currentMl  = defaults?.integer(forKey: "currentMl")  ?? 0
        let glassSize  = defaults?.integer(forKey: "glassSize")   ?? 250
        let goalMl     = defaults?.integer(forKey: "goalMl")      ?? 2500

        let newMl      = min(currentMl + glassSize, goalMl)
        let newGlasses = newMl / max(glassSize, 1)
        let newProgress = Double(newMl) / Double(max(goalMl, 1))

        defaults?.set(newMl,       forKey: "currentMl")
        defaults?.set(newGlasses,  forKey: "glassesCount")
        defaults?.set(newProgress, forKey: "progress")
        // Signal the app to sync on next foreground
        defaults?.set(glassSize,   forKey: "pendingWidgetLogMl")

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Timeline Entry
struct WaterEntry: TimelineEntry {
    let date: Date
    let currentMl: Int
    let goalMl: Int
    let glassSize: Int
    let glassesCount: Int
}

// MARK: - Timeline Provider
struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: Date(), currentMl: 500, goalMl: 2500, glassSize: 250, glassesCount: 2)
    }
    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
        completion(currentEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {
        let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [currentEntry()], policy: .after(refresh)))
    }
    private func currentEntry() -> WaterEntry {
        let d = UserDefaults(suiteName: appGroup)
        return WaterEntry(
            date:        Date(),
            currentMl:   d?.integer(forKey: "currentMl")   ?? 0,
            goalMl:      d?.integer(forKey: "goalMl")       ?? 2500,
            glassSize:   d?.integer(forKey: "glassSize")    ?? 250,
            glassesCount:d?.integer(forKey: "glassesCount") ?? 0
        )
    }
}

// MARK: - Premium Water Droplet (Improved)
struct WaterDropletView: View {
    var size: CGFloat
    var body: some View {
        ZStack {
            // MAIN DROPLET
            DropletShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#E0F7FF"), // Lightest sky blue
                            Color(hex: "#80E2FF"), // Vibrant light blue
                            Color(hex: "#3DBBFF")  // Soft medium blue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            // INNER SOFT LIGHT
            DropletShape()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.0)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .blur(radius: 2)
            // LONG LIGHT STREAK
            RoundedRectangle(cornerRadius: 100)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.11, height: size * 0.42)
                .rotationEffect(.degrees(-22))
                .offset(x: -size * 0.17, y: -size * 0.12)
                .blur(radius: 1)
            // SMALL HOTSPOT
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: size * 0.18)
                .blur(radius: 6)
                .offset(x: -size * 0.08, y: -size * 0.06)
            // INNER BOTTOM DEPTH
            DropletShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: size * 0.025
                )
                .blendMode(.screen)
        }
        .frame(width: size, height: size)
        // OUTER GLOW
        .shadow(
            color: Color(hex: "#56A8FF").opacity(0.55),
            radius: size * 0.18,
            x: 0,
            y: size * 0.10
        )
        // SECONDARY BLOOM
        .shadow(
            color: Color(hex: "#7FDBFF").opacity(0.35),
            radius: size * 0.28,
            x: 0,
            y: size * 0.15
        )
    }
}

// MARK: - Better Droplet Shape
struct DropletShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        // RIGHT SIDE
        p.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.68),
            control1: CGPoint(x: w * 0.82, y: h * 0.18),
            control2: CGPoint(x: w * 1.02, y: h * 0.48)
        )
        p.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 0.86, y: h * 0.92),
            control2: CGPoint(x: w * 0.66, y: h)
        )
        // LEFT SIDE
        p.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.68),
            control1: CGPoint(x: w * 0.34, y: h),
            control2: CGPoint(x: w * 0.14, y: h * 0.92)
        )
        p.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: -0.02 * w, y: h * 0.48),
            control2: CGPoint(x: w * 0.18, y: h * 0.18)
        )
        return p
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    var phase: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight: CGFloat = 10
        let startY = waveHeight
        
        path.move(to: CGPoint(x: 0, y: startY))
        
        stride(from: 0, through: rect.width, by: 1).forEach { x in
            let relX = x / rect.width
            // Use multiple sines for a more natural liquid look
            let y = startY + 
                    sin(relX * .pi * 2.2 + phase) * waveHeight * 0.7 + 
                    cos(relX * .pi * 1.5 + phase * 0.5) * waveHeight * 0.3
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Ensure it covers to the very bottom to avoid white gaps
        path.addLine(to: CGPoint(x: rect.width, y: rect.height + 20))
        path.addLine(to: CGPoint(x: 0, y: rect.height + 20))
        path.closeSubpath()
        return path
    }
}

// MARK: - Widget View
struct JustDrinkWidgetView: View {
    let entry: WaterEntry

    var fillFraction: CGFloat {
        guard entry.goalMl > 0 else { return 0 }
        return CGFloat(entry.currentMl) / CGFloat(entry.goalMl)
    }

    // Dynamic coloring - turning white earlier as requested
    var contentColor: Color {
        fillFraction > 0.50 ? .white : Color(hex: "#1A1C1E")
    }
    
    var subColor: Color {
        fillFraction > 0.40 ? .white.opacity(0.85) : Color(hex: "#5DCCFC").opacity(0.95)
    }

    var body: some View {
        PhaseAnimator([0.0, .pi * 2]) { phase in
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    // Animated Water Layers
                    if entry.currentMl > 0 {
                        let waveH = geo.size.height * fillFraction.clamped(to: 0.12...1.0)
                        let waterColor = Color(hex: "#5DCCFC").opacity(0.41)
                        
                        ZStack(alignment: .top) {
                            WaveShape(phase: phase * 0.8)
                                .fill(waterColor.opacity(0.4))
                                .frame(height: waveH + 25)
                                .offset(y: -15)

                            WaveShape(phase: phase * 1.2 + 1.5)
                                .fill(waterColor.opacity(0.7))
                                .frame(height: waveH + 10)
                                .offset(y: -5)

                            WaveShape(phase: phase * 1.5)
                                .fill(waterColor)
                                .frame(height: waveH)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    }

                    // Logo Image from Assets
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Image("logoicon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 110)
                                .foregroundStyle(
                                    fillFraction > 0.50 ? 
                                    AnyShapeStyle(Color.white) : 
                                    AnyShapeStyle(
                                        RadialGradient(
                                            stops: [
                                                .init(color: Color(hex: "#80E2FF"), location: 0.11),
                                                .init(color: Color(hex: "#3DBBFF"), location: 1.0)
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 55
                                        )
                                    )
                                )
                                .offset(x: 0, y: geo.size.height * 0.05)
                                .opacity(0.9)
                                .padding(.trailing, 10)
                            Spacer()
                        }
                    }

                    // Elegant Information Layout
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(entry.date, style: .time)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(contentColor)
                                .tracking(-0.5)

                            // Show glass count in stats
                            Text("\(entry.currentMl)ml / \(entry.goalMl)ml (\(entry.glassesCount) Glass)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(subColor)
                        }

                        Spacer()

                        // Refined Quick Action Button
                        Button(intent: LogWaterIntent()) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Add Glass")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    Capsule()
                                        .fill(.white.opacity(0.15))
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                                }
                            )
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .widgetBackground(Color.white)
                .ignoresSafeArea()
            }
        } animation: { _ in
            .linear(duration: 4.5)
        }
    }
}

// MARK: - Helpers
extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return self.background(backgroundView)
        }
    }
}

extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Widget Configuration
struct JustDrinkWidget: Widget {
    let kind = "JustDrinkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
            JustDrinkWidgetView(entry: entry)
        }
        .configurationDisplayName("JustDrink")
        .description("Track and log water intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}