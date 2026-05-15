import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), currentMl: 0, goalMl: 2500, glassSize: 250, glassesCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            currentMl: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "currentMl") ?? 0,
            goalMl: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "goalMl") ?? 2500,
            glassSize: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "glassSize") ?? 250,
            glassesCount: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "glassesCount") ?? 0
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let entry = SimpleEntry(
            date: date,
            currentMl: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "currentMl") ?? 0,
            goalMl: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "goalMl") ?? 2500,
            glassSize: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "glassSize") ?? 250,
            glassesCount: UserDefaults(suiteName: "group.com.swifteck.justdrink")?.integer(forKey: "glassesCount") ?? 0
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let currentMl: Int
    let goalMl: Int
    let glassSize: Int
    let glassesCount: Int
}

struct JustDrinkWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color.white
            
            // Waves at bottom
            VStack {
                Spacer()
                Image("widget_water_waves")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 80 + (CGFloat(entry.currentMl) / CGFloat(entry.goalMl) * 100))
                    .opacity(0.4)
                    .foregroundColor(Color(red: 0.36, green: 0.8, blue: 0.99)) // #5DCCFC
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date, style: .time)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                
                Text("\(entry.currentMl)ml water(\(entry.glassesCount) Glass)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.56, green: 0.57, blue: 0.6))
                
                Spacer()
                
                // Add Button
                Button(intent: AddWaterIntent(amount: entry.glassSize)) {
                    Text("Tap to Add Water")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            
            // Drop image
            VStack {
                HStack {
                    Spacer()
                    Image("widget_water_drops")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                }
                Spacer()
            }
        }
    }
}

import AppIntents

struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Water"
    
    @Parameter(title: "Amount")
    var amount: Int
    
    init() {}
    init(amount: Int) {
        self.amount = amount
    }
    
    func perform() async throws -> some IntentResult {
        let url = URL(string: "justdrink://log?amount=\(amount)")!
        _ = try? await UserDefaults(suiteName: "group.com.swifteck.justdrink")?.set(amount, forKey: "lastLoggedAmount")
        // HomeWidget uses the URL to trigger the background callback
        return .result()
    }
}

struct JustDrinkWidget: Widget {
    let kind: String = "JustDrinkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JustDrinkWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("JustDrink")
        .description("Quickly log your water intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
