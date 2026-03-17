import SwiftUI
import Charts

struct Lab4_MS: View {
    let data = [
        (day: "Mon", value: 10),
        (day: "Tue", value: 25),
        (day: "Wed", value: 15),
        (day: "Thu", value: 30),
        (day: "Fri", value: 22)
    ]

    var body: some View {
        Chart(data, id: \.day) { item in
            LineMark(
                x: .value("Day", item.day),
                y: .value("Value", item.value)
            )
        }
        .frame(height: 300)
        .padding()
    }
}
