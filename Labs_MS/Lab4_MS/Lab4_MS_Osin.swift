import SwiftUI
import Charts

struct Table1: Identifiable{
    let id = UUID()
    let x: Int
    let r_1, r_2: Double
    let z_old, z_new, y: String
}


struct StatsData: Identifiable {
    let id = UUID()
    let name: String
    let count: Double
}

struct Lab4_MS: View {

    @State private var DataTable: [Table1] = []
    @State private var countY1 = 0;
    @State private var countY2 = 0;
    let states = ["z1","z2","z3","z4"]
    let statsData: [StatsData] = [
//        StatsData(name: "y1", count: countY1),
//        StatsData(name: "y2", count: countY2)
    ]
    var body: some View {
        VStack{
            Text("Вариант - 42.")
                .font(.system(size: 25, weight: .bold, design: .rounded))

            Text("Z-детерминированный P-автомат")

            Button("Сгенерировать"){
                generate()
            }
            .padding()

            Table(DataTable){
                TableColumn("x"){ row in Text("x\(row.x)") }.width(40).alignment(.center)
                TableColumn("z_old"){ row in Text(row.z_old) }.width(40).alignment(.center)
                TableColumn("r_1"){ row in Text(String(format: "%.2f", row.r_1)) }.width(40).alignment(.center)
                TableColumn("z_new"){ row in Text(row.z_new) }.width(40).alignment(.center)
                TableColumn("r_2"){ row in Text(String(format: "%.2f", row.r_2)) }.width(40).alignment(.center)
                TableColumn("y"){ row in Text(row.y) }.width(40).alignment(.center)
            }
            .frame(height: 250)

            Divider()

            Text("Статистика:")
                .font(.headline)
            Chart(statsData) { stat in
                BarMark(
                    x: .value("Выход", stat.name),
                    y: .value("Количество", stat.count)
                )
            }
            .frame(height: 200)

            let total = countY1 + countY2
            if total > 0 {
                Text("y1 = \(Double(countY1) / Double(total) * 100, specifier: "%.1f") %")
                Text("y2 = \(Double(countY2) / Double(total) * 100, specifier: "%.1f") %")
            }

            Spacer()
        }
        .frame(width: 700, height: 500)
        .padding()
    }

    func generate(){
        DataTable.removeAll()
        countY1 = 0
        countY2 = 0

        var currentState = "z1"

        for _ in 0..<10 {

            let x = Int.random(in: 1...2)
            let r1 = Double.random(in: 0...1)
            let r2 = Double.random(in: 0...1)

            let oldState = currentState

            
            currentState = nextState(x: x, state: currentState)

            
            let y = output(x: x, state: oldState, r2: r2)

            if y == "y1" { countY1 += 1 }
            else { countY2 += 1 }

            DataTable.append(
                Table1(
                    x: x,
                    r_1: r1,
                    r_2: r2,
                    z_old: oldState,
                    z_new: currentState,
                    y: y
                )
            )
        }
    }

    func nextState(x: Int, state: String) -> String {
        switch (x, state) {
        case (1, "z1"): return "z2"
        case (1, "z2"): return "z3"
        case (1, "z3"): return "z4"
        case (1, "z4"): return "z1"

        case (2, "z1"): return "z3"
        case (2, "z2"): return "z1"
        case (2, "z3"): return "z2"
        case (2, "z4"): return "z4"

        default: return state
        }
    }

    func output(x: Int, state: String, r2: Double) -> String {

        let p: Double

        if x == 1 {
            switch state {
            case "z1": p = 0.7
            case "z2": p = 0.4
            case "z3": p = 0.5
            case "z4": p = 0.2
            default: p = 0.5
            }
        } else {
            switch state {
            case "z1": p = 0.6
            case "z2": p = 0.3
            case "z3": p = 0.8
            case "z4": p = 0.1
            default: p = 0.5
            }
        }

        return r2 <= p ? "y1" : "y2"
    }
}

#Preview {
    Lab4_MS()
}
