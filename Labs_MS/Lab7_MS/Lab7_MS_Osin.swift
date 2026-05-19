import SwiftUI
import Charts

struct HistogramBin: Identifiable {
    let id = UUID()
    let center: Double
    let lower: Double
    let upper: Double
    let density: Double
    let theoreticalDensity: Double
}

struct Lab7_MS: View {
    
    @State private var nText = "10"
    
    @State private var sampleMean: Double = 0
    @State private var sampleVariance: Double = 0
    @State private var histData: [HistogramBin] = []
    
    @State private var kolmogorovD: Double = 0
    @State private var kolmogorovCritical: Double = 0
    @State private var isHypothesisAccepted: Bool = true
    
    let theoreticalMean: Double = 1.33
    let theoreticalVariance: Double = 0.88
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Закон распределения:\nf(z) = 1/2 - z/8  (0 ≤ z ≤ 4)")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                HStack {
                    Text("N:")
                        .font(.headline)
                    
                    TextField("Размер выборки", text: $nText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                    
                    Button("Рассчитать") {
                        generate()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Divider()
                
                HStack(spacing: 60) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Теоретические значения")
                            .font(.headline)
                        Text(String(format: "M(X) = %.6f", theoreticalMean))
                        Text(String(format: "D(X) = %.6f", theoreticalVariance))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Выборочные оценки")
                            .font(.headline)
                        Text(String(format: "Среднее = %.6f", sampleMean))
                        Text(String(format: "Дисперсия = %.6f", sampleVariance))
                    }
                }
                
                Divider()
                
                if !histData.isEmpty {
                    VStack(alignment: .center, spacing: 15) {
                        
                        VStack(spacing: 2) {
                            Text("N = \(nText)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isHypothesisAccepted ? .green : .red)
                            
                            Text(String(format: "Колмогоров: %.3f < %.3f", kolmogorovD, kolmogorovCritical))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isHypothesisAccepted ? .green : .red)
                            
                            Text(isHypothesisAccepted ? "Гипотеза принята" : "Гипотеза отвергнута")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isHypothesisAccepted ? .green : .red)
                        }
                        
                        Chart {
                            ForEach(histData) { bin in
                                BarMark(
                                    xStart: .value("Начало", bin.lower),
                                    xEnd: .value("Конец", bin.upper),
                                    y: .value("Плотность", bin.density)
                                )
                                .foregroundStyle(Color.blue.opacity(0.8))
                                
                                LineMark(
                                    x: .value("z", bin.center),
                                    y: .value("Теоретическая f(z)", bin.theoreticalDensity)
                                )
                                .foregroundStyle(Color.red)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            }
                        }
                        .chartXScale(domain: 0...4)
                        
                        .chartXAxisLabel(position: .bottom, alignment: .center) {
                            Text("z").font(.system(size: 14, weight: .semibold))
                        }
                        .chartYAxisLabel(position: .leading, alignment: .center) {
                            Text("f(z)").font(.system(size: 14, weight: .semibold))
                        }
                        
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 10)) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                                AxisTick()
                                AxisValueLabel() {
                                    if let doubleValue = value.as(Double.self) {
                                        Text(String(format: "%.2f", doubleValue))
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                                AxisTick()
                                AxisValueLabel()
                            }
                        }

                        .overlay(
                            Rectangle().stroke(Color.black.opacity(0.5), lineWidth: 1)
                        )
                        .frame(width: 450, height: 280)
                    }
                    
                    .padding(.top, 10)
                }
            }
            .padding()
            .frame(minWidth: 800,
                   maxWidth: 800,
                   minHeight: 750,
                   maxHeight: 750)
        }
        .onAppear {
            generate()
        }
    }
    
    func generate() {
        guard let n = Int(nText), n > 1 else { return }
        
        let sample = (0..<n).map { _ in generateZ() }.sorted()
        
        sampleMean = sample.reduce(0, +) / Double(n)
        sampleVariance = sample.reduce(0) { $0 + pow($1 - sampleMean, 2) } / Double(n - 1)
        
        var maxD = 0.0
        let nDouble = Double(n)
        
        for i in 0..<n {
            let z = sample[i]
            let fTheor = cdf(z)
            
            let empLeft = Double(i) / nDouble
            let empRight = Double(i + 1) / nDouble
            
            let d1 = abs(fTheor - empLeft)
            let d2 = abs(fTheor - empRight)
            
            maxD = max(maxD, d1, d2)
        }
        
        kolmogorovD = maxD
        kolmogorovCritical = 1.358 / sqrt(nDouble)
        isHypothesisAccepted = kolmogorovD < kolmogorovCritical
        
        let k = max(5, Int(1 + 3.322 * log10(Double(n))))
        let zMin = 0.0
        let zMax = 4.0
        let step = (zMax - zMin) / Double(k)
        
        var newHistData: [HistogramBin] = []
        
        for i in 0..<k {
            let lower = zMin + Double(i) * step
            let upper = (i == k - 1) ? zMax + 0.001 : lower + step
            let center = lower + step / 2.0
            
            let count = sample.filter { $0 >= lower && $0 < upper }.count
            let density = (Double(count) / nDouble) / step
            let theoreticalDensity = 0.5 - center / 8.0
            
            newHistData.append(HistogramBin(
                center: center,
                lower: lower,
                upper: upper,
                density: density,
                theoreticalDensity: theoreticalDensity
            ))
        }
        
        histData = newHistData
    }
    
    
    func generateZ() -> Double {
        let u = Double.random(in: 0...1)
        return 4.0 - 4.0 * sqrt(1.0 - u)
    }
    
    func cdf(_ z: Double) -> Double {
        if z <= 0 { return 0 }
        if z >= 4 { return 1 }
        return z / 2.0 - (z * z) / 16.0
    }
}

#Preview {
    Lab7_MS()
}
