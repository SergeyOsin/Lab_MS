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

struct Transition: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let label: String
    let probability: Double
}


struct Lab4_MS: View {

    @State private var DataTable: [Table1] = []
    @State private var countY1 = 0
    @State private var countY2 = 0
    @State private var CountSteps: Int = 6

    let states = ["z1","z2","z3","z4"]

    var statsData: [StatsData] {
        [
            StatsData(name: "y1", count: Double(countY1)),
            StatsData(name: "y2", count: Double(countY2))
        ]
    }

    var transitions: [Transition] {
        [
            Transition(from: "z1", to: "z2", label: "x1", probability: 0.7),
            Transition(from: "z2", to: "z3", label: "x1", probability: 0.4),
            Transition(from: "z3", to: "z4", label: "x1", probability: 0.5),
            Transition(from: "z4", to: "z1", label: "x1", probability: 0.2),

            Transition(from: "z1", to: "z3", label: "x2", probability: 0.6),
            Transition(from: "z2", to: "z1", label: "x2", probability: 0.3),
            Transition(from: "z3", to: "z2", label: "x2", probability: 0.8),
            Transition(from: "z4", to: "z4", label: "x2", probability: 0.1)
        ]
    }

    var body: some View {
        VStack{
            Text("Вариант - 42.")
                .font(.system(size: 25, weight: .bold, design: .rounded))

            Text("Z-детерминированный P-автомат")

            HStack {
                Text("Количество:")
                TextField("", value: $CountSteps, format: .number)
                    .frame(width: 100)
                    .textFieldStyle(.roundedBorder)
                    .shadow(color: .blue, radius: 5);
            }

            Table(DataTable){
                TableColumn("x"){ row in Text("x\(row.x)") }.width(45)
                TableColumn("z_old"){ row in Text(row.z_old) }.width(40)
                TableColumn("r_1"){ row in Text(String(format: "%.2f", row.r_1)) }.width(40)
                TableColumn("z_new"){ row in Text(row.z_new) }.width(45)
                TableColumn("r_2"){ row in Text(String(format: "%.2f", row.r_2)) }.width(40)
                TableColumn("y"){ row in Text(row.y) }.width(45)
            }
            .frame(width: 370, height: 150)
            .border(.black)
            .shadow(color: .blue, radius: 10)

            Button("Сгенерировать"){
                generate()
            }.background(.red)
                .shadow(color: .blue, radius: 10)
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.glass)
            .padding()

            Divider()

            Text("Статистика")
                .font(.headline)

            Chart(statsData) { stat in
                BarMark(
                    x: .value("Выход", stat.name),
                    y: .value("Количество", stat.count)
                )
            }
            .frame(width: 350, height: 80)

            let total = countY1 + countY2
            if total > 0 {
                Text("y1 = \(Double(countY1) / Double(total) * 100, specifier: "%.1f") %")
                Text("y2 = \(Double(countY2) / Double(total) * 100, specifier: "%.1f") %")
            }

            Divider()

            Text("Граф переходов состояний")
                .font(.headline)

            GraphView(states: states, transitions: transitions)

            Spacer()
        }
        .frame(width: 700, height: 650)
        .padding()
    }

    func generate(){
        DataTable.removeAll()
        countY1 = 0
        countY2 = 0

        var currentState = "z1"

        for _ in 0..<CountSteps {

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

// MARK: - Graph View

struct GraphView: View {
    let states: [String]
    let transitions: [Transition]

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius: CGFloat = 100

            let positions: [String: CGPoint] = Dictionary(uniqueKeysWithValues:
                states.enumerated().map { index, state in
                    let angle = 2 * .pi * Double(index) / Double(states.count)
                    let point = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    )
                    return (state, point)
                }
            )

            ZStack {

                ForEach(transitions) { t in
                    if let from = positions[t.from],
                       let to = positions[t.to] {

                        Path { path in
                            path.move(to: from)
                            path.addLine(to: to)
                        }
                        .stroke(t.label == "x1" ? Color.blue : Color.red, lineWidth: 2)

                        Text("\(t.label)\np=\(String(format: "%.1f", t.probability))")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .position(
                                x: (from.x + to.x) / 2,
                                y: (from.y + to.y) / 2
                            )
                    }
                }

                ForEach(states, id: \.self) { state in
                    if let pos = positions[state] {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)

                            Text(state)
                                .font(.caption)
                        }
                        .position(pos)
                    }
                }
            }
        }
        .frame(height: 210)
        .padding()
    }
}

#Preview {
    Lab4_MS()
}
