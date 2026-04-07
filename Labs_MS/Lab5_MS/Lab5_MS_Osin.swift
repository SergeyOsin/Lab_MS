import SwiftUI

struct MatrixRow: Identifiable {
    let id = UUID()
    let state: String
    let q1: Double
    let q2: Double
    let q3: Double
}

struct ResultRow: Identifiable {
    let id = UUID()
    let state: String
    let kolmogorov: Double
    let stationary: Double
    let error: Double
}

struct Lab5_MS: View {
    
    @State private var p1: Double = 1
    @State private var p2: Double = 0
    @State private var p3: Double = 0
    @State private var maxLen: Double = 20;
    @State private var step: Double = 0.1;
    
    @State private var resultData: [ResultRow] = []
    @State private var errorMessage: String = ""
    
    let matrixData: [MatrixRow] = [
        MatrixRow(state: "S1", q1: -0.8, q2: 0.6, q3: 0.2),
        MatrixRow(state: "S2", q1: 0.4, q2: -0.4, q3: 0.0),
        MatrixRow(state: "S3", q1: 0.0, q2: 0.5, q3: -0.5)
    ]
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Лабораторная работа №5")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack {
                Image("Graph")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 100)
                
                Table(matrixData) {
                    TableColumn("") { row in
                        Text(row.state).bold()
                    }.width(25)
                    
                    TableColumn("S1") { row in
                        Text(String(format: "%.1f", row.q1))
                    }.width(30)
                    
                    TableColumn("S2") { row in
                        Text(String(format: "%.1f", row.q2))
                    }.width(30)
                    
                    TableColumn("S3") { row in
                        Text(String(format: "%.1f", row.q3))
                    }.width(30)
                }
                .frame(width: 185, height: 105)
                .border(Color.gray)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("p1'(t) = -0.8p1(t) + 0.4p2(t)")
                    Text("p2'(t) = 0.6p1(t) - 0.4p2(t) + 0.5p3(t)")
                    Text("p3'(t) = 0.2p1(t) - 0.5p3(t)")
                }
                .font(.system(size: 13))
                .padding()
                .border(Color.red)
                .frame(width: 250)
            }
            HStack(spacing: 20) {
                VStack {
                    Text("Предел:")
                    TextField("0", value: $maxLen, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
                VStack {
                    Text("Шаг")
                    TextField("0", value: $step, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
                VStack {
                    Text("p1:")
                    TextField("0", value: $p1, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
                VStack {
                    Text("p2:")
                    TextField("0", value: $p2, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
                VStack {
                    Text("p3:")
                    TextField("0", value: $p3, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
            }
            .frame(maxWidth: .infinity)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: runCalculation) {
                Text("Запустить")
                    .frame(width: 120, height: 35)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text("Результаты:")
                    .font(.headline)
                
                Table(resultData) {
                    TableColumn("Состояние") { row in
                        Text(row.state)
                    }
                    TableColumn("Колмогоров") { row in
                        Text(String(format: "%.4f", row.kolmogorov))
                    }
                    TableColumn("Стационарная") { row in
                        Text(String(format: "%.4f", row.stationary))
                    }
                    TableColumn("Погрешность") { row in
                        Text(String(format: "%.6f", row.error))
                    }
                }
                .frame(width: 700, height: 115)
                .border(Color.gray)
            }
        }
        .padding()
        .frame(minWidth: 700, maxWidth: 700, alignment: .top)
    }
    
    func runCalculation() {
        errorMessage = ""
        let sum = p1 + p2 + p3
        if abs(sum - 1.0) > 0.0001 {
            errorMessage = "Ошибка: p1 + p2 + p3 должно быть равно 1"
            resultData = []
            return
        }
        
        let result = solveKolmogorov(p1: p1, p2: p2, p3: p3, step: step, maxLen: maxLen);
        let stationary = [0.25, 0.375, 0.375]
        let kolmogorov = [result.0, result.1, result.2]
        
        resultData = [
            ResultRow(state: "S1", kolmogorov: kolmogorov[0], stationary: stationary[0], error: abs((kolmogorov[0] - stationary[0])/stationary[0]*100)),
            ResultRow(state: "S2", kolmogorov: kolmogorov[1], stationary: stationary[1], error: abs((kolmogorov[1] - stationary[1])/stationary[1] * 100)),
            ResultRow(state: "S3", kolmogorov: kolmogorov[2], stationary: stationary[2], error: abs((kolmogorov[2] - stationary[2]))/stationary[2] * 100)
        ]
    }
    
    func solveKolmogorov(p1: Double, p2: Double, p3: Double, step: Double, maxLen: Double) -> (Double, Double, Double) {
        var p1 = p1, p2 = p2, p3 = p3
        var t = 0.0
        while t < maxLen {
            let dp1 = -0.8 * p1 + 0.4 * p2
            let dp2 = 0.6 * p1 - 0.4 * p2 + 0.5 * p3
            let dp3 = 0.2 * p1 - 0.5 * p3

            p1 += dp1 * step
            p2 += dp2 * step
            p3 += dp3 * step

            t += step
        }
        return (p1, p2, p3)
    }

}

#Preview{
    Lab5_MS()
}
