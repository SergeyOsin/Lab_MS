
import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let t: Double
    let values: [Double]
}

struct Lab2_MS: View {
    
    @State private var stepInput: Double = 0.1
    @State private var data: [DataPoint] = []
    
    @State private var xT: [Double] = Array(repeating: 0, count: 5)
    @State private var delta: Double = 0
    @State private var autoStep: Double = 0
    
    @State private var deltaHData: [DataPoint] = []
    @State private var costHData: [DataPoint] = []
    
    let p: Double = 100000
    let a: Double = 0.8
    let m: Double = 2000
    let u: Double = 10
    let cx: Double = 0.02
    let cy: Double = 0.003
    let M1: Double = 0.05
    let M2: Double = 0.01
    let T: Double = 11
    let g: Double = 9.81
    
    let x0: [Double] = [1800, 0.8, 0, 0, 0.8]
    
    let colors: [Color] = [.red, .green, .blue, .orange, .purple]
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 20) {
                GroupBox("Входные данные") {
                    VStack(alignment: .leading) {
                        TextField("Шаг h", value: $stepInput, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .border(Color.white)
                            .fontDesign(Font.Design.monospaced)
                            .frame(width: 100, height: 30)
                        HStack {
                            Text("Система уравнений 5-го порядка\t\t\t\t")
                            Text("Исходные данные")
                        }.bold(true)
                        HStack(alignment: .top) {
                            Image("Formula")
                                .resizable()
                                .frame(width: 300, height: 180)
                            VStack(alignment: .leading) {
                                Text("p = \(p, specifier: "%.0f")")
                                Text("a = \(a, specifier: "%.1f")")
                                Text("m = \(m, specifier: "%.0f")")
                                Text("u = \(u, specifier: "%.0f")")
                                Text("cx = \(cx, specifier: "%.2f")")
                                Text("cy = \(cy, specifier: "%.0f")")
                                Text("M1 = \(M1, specifier: "%.2f")")
                                Text("M2 = \(M2, specifier: "%.2f")")
                                Text("T = \(T, specifier: "%.0f")")
                                Text("g = \(g, specifier: "%.2f")")
                            }
                            VStack {
                                ForEach(0..<x0.count, id: \.self) { i in
                                    Text("x\(i+1)(0) = \(String(format: "%.2f", x0[i]))")
                                }
                            }
                        }
                    }
                }
                
                HStack(alignment: .center) {
                    Button("Решить систему") {
                        solveSystem(step: stepInput)
                    }.cornerRadius(25)
                        .foregroundStyle(Color.blue)
                        .fontDesign(Font.Design.serif)
                    Button("Автоподбор шага") {
                        autoSelectStep()
                    }.cornerRadius(25)
                        .foregroundStyle(Color.red.mix(with: .white, by: 0.4))
                }
                if !data.isEmpty {
                    GroupBox("Таблица решения") {
                        ScrollView(.horizontal) {
                            VStack {
                                HStack {
                                    Text("t").frame(width: 60)
                                    ForEach(0..<5) { i in
                                        Text("x\(i+1)").frame(width: 80)
                                    }
                                }
                                Divider()
                                ForEach(data) { point in
                                    HStack {
                                        Text(String(format: "%.3f", point.t)).frame(width: 60)
                                        ForEach(point.values, id: \.self) { val in
                                            Text(String(format: "%.3f", val)).frame(width: 80)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 150)

                    }
                }
                
                
                GroupBox("Графики xi(t)") {
                    VStack(spacing: 20) {
                        ForEach(0..<5) { i in
                            VStack(alignment: .leading) {
                                Text("x\(i+1)(t)").font(.headline)
                                Chart(data) { point in
                                    LineMark(
                                        x: .value("t", point.t),
                                        y: .value("x\(i+1)", point.values[i])
                                    )
                                    .foregroundStyle(colors[i])
                                }
                                .frame(width: 200, height: 150)
                            }
                        }
                    }
                }
                
                
                GroupBox("Погрешности точности и трудоемкости") {
                    VStack {
                        Text("δ(h)")
                        Chart(deltaHData) { point in
                            LineMark(
                                x: .value("h", point.t),
                                y: .value("δ", point.values[0])
                            )
                        }
                        .frame(height: 100)
                        
                        Text("Трудоемкость N(h)")
                        Chart(costHData) { point in
                            LineMark(
                                x: .value("h", point.t),
                                y: .value("N", point.values[0])
                            )
                        }
                        .frame(height: 100)
                    }
                }
            }
            .padding()
        }
    }
}

extension Lab2_MS {
    
    func f(t: Double, x: [Double]) -> [Double] {
        let dx1 = -g * sin(x[1]) + (p - a*cx*x[0]*x[0])/(m - u*t)
        let dx2 = (-g + (p * sin(x[4] - x[1]) + a*cy*x[0]*x[0])/(m - u*t)) / x[0]
        let dx3 = (M1*a*(x[1] - x[4])*x[0]*x[0] - M2*a*x[0]*x[0]*x[2])/(m - u*t)
        let dx4 = x[0] * sin(x[1])
        let dx5 = x[2]
        return [dx1, dx2, dx3, dx4, dx5]
    }
    
    func rk4(step h: Double) -> ([Double], [[Double]]) {
        let N = Int(T / h)
        var t = [0.0]
        var x = Array(repeating: x0, count: N+1)
        
        for i in 0..<N {
            let ti = Double(i) * h
            t.append(ti + h)
            let k1 = f(t: ti, x: x[i])
            let k2 = f(t: ti + h/2, x: zip(x[i], k1).map {$0 + h*$1/2})
            let k3 = f(t: ti + h/2, x: zip(x[i], k2).map {$0 + h*$1/2})
            let k4 = f(t: ti + h, x: zip(x[i], k3).map {$0 + h*$1})
            var next = [Double]()
            for j in 0..<5 {
                next.append(x[i][j] + h*(k1[j] + 2*k2[j] + 2*k3[j] + k4[j])/6)
            }
            x[i+1] = next
        }
        return (t, x)
    }
    
    func computeDeltaH() {
        let (_, xRef) = rk4(step: 0.001)
        let xRefT = xRef.last![0]
        
        var deltaList: [DataPoint] = []
        var costList: [DataPoint] = []
        let steps: [Double] = stride(from: 0.01, through: 0.5, by: 0.02).map { $0 }
        for h in steps {
            let (_, xH) = rk4(step: h)
            let xHT = xH.last![0]
            let d = abs(xHT - xRefT)/abs(xRefT)
            deltaList.append(DataPoint(t: h, values: [d]))
            costList.append(DataPoint(t: h, values: [T/h]))
        }
        deltaHData = deltaList
        costHData = costList
    }
    
    func solveSystem(step h: Double) {
        guard h > 0 else { return }
        let (tVals, xVals) = rk4(step: h)
        xT = xVals.last!
        data = zip(tVals, xVals).map { DataPoint(t: $0.0, values: $0.1) }
        
        
        let (_, xRef) = rk4(step: 0.001)
        delta = abs(xT[0] - xRef.last![0]) / abs(xRef.last![0])
        
        computeDeltaH()
    }
    
    func autoSelectStep() {
        // ЭТАЛОН ВЫЧИСЛЯЕМ ОДИН РАЗ ДО ЦИКЛА!
        let (_, xRef) = rk4(step: 0.001)
        let xRefT = xRef.last![0]
        
        var h = 0.5
        
        // Максимум 10 итераций вместо бесконечного цикла
        for _ in 0..<10 {
            let (tVals, xVals) = rk4(step: h)
            let xTcurr = xVals.last![0]
            let d = abs(xTcurr - xRefT)/abs(xRefT)
            
            if d <= 0.01 {
                // Нашли подходящий шаг
                autoStep = h
                delta = d
                xT = xVals.last!
                data = zip(tVals, xVals).map { DataPoint(t: $0.0, values: $0.1) }
                stepInput = h
                computeDeltaH()
                return  
            }
            
            h /= 2
            if h < 0.01 { break }
        }
    }
}

#Preview {
    Lab2_MS()
}
