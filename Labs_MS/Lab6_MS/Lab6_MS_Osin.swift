import SwiftUI
import AppKit

struct NodeMetrics: Identifiable {
    let id = UUID()
    let name: String
    let alpha: Double
    let lambda: Double
    let beta: Double
    let rho: Double
    let isStable: Bool
    let p0: Double
    let lq: Double
    let l: Double
    let wq: Double
    let w: Double
}

struct StepResult: Identifiable {
    let id = UUID()
    let step: Int
    let metrics: [NodeMetrics]
}

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            if let window = view.window {
                callback(window)
            }
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct Lab6_MS: View {

    @State private var matrix: [[Double]] = [
        [0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.25, 0.0, 0.75, 0.0],
        [0.0, 0.0, 0.0, 0.0, 0.1667, 0.8333],
        [0.0, 0.0, 0.9, 0.0, 0.0, 0.1],
        [0.0, 0.0, 0.1, 0.0, 0.0, 0.9],
        [0.9375, 0.0625, 0.0, 0.0, 0.0, 0.0]
    ]

    @State private var kChannels: [Int] = [1,2,2,4,1]

    @State private var vTimes: [Double] = [0.5,0.5,0.5,0.5,0.5]

    @State private var lambda0: Double = 4.0

    @State private var iterations: [StepResult] = []

    @State private var totalIterations: Int = 0

    @State private var netL: Double = 0.0
    @State private var netN: Double = 0.0
    @State private var netW: Double = 0.0
    @State private var netT: Double = 0.0

    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    GroupBox {
                        HStack {
                            Text("λ₀:")
                                .font(.system(size: 12))

                            Spacer()

                            TextField("", value: $lambda0, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 70)
                                .font(.system(size: 11))
                        }
                    } label: {
                        Text("Параметры")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    GroupBox {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Узел")
                                    .bold()
                                    .font(.system(size: 11))

                                Spacer()

                                Text("K")
                                    .bold()
                                    .font(.system(size: 11))

                                Spacer()

                                Text("V")
                                    .bold()
                                    .font(.system(size: 11))
                            }

                            Divider()

                            ForEach(0..<5, id: \.self) { i in
                                HStack {
                                    Text("S\(i + 1)")
                                        .font(.system(size: 11))

                                    Spacer()

                                    Stepper(value: $kChannels[i], in: 1...20) {
                                        Text("\(kChannels[i])")
                                            .font(.system(size: 11))
                                    }
                                    .frame(width: 90)
                                    .scaleEffect(0.8)

                                    Spacer()

                                    TextField("", value: $vTimes[i], format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 60)
                                        .font(.system(size: 11))
                                }
                            }
                        }
                    } label: {
                        Text("Узлы")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    GroupBox {
                        matrixEditor
                    } label: {
                        Text("Матрица переходов")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    Button(action: calculate) {
                        Text("Рассчитать")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(10)
            }
            .frame(width: 300)

            Divider()

            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 14) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 10
                    ) {
                        dashboardCard(
                            title: "L",
                            value: netL,
                            unit: "шт",
                            icon: "person.3.sequence",
                            color: .orange
                        )

                        dashboardCard(
                            title: "N",
                            value: netN,
                            unit: "шт",
                            icon: "network",
                            color: .blue
                        )

                        dashboardCard(
                            title: "W",
                            value: netW,
                            unit: "с",
                            icon: "timer",
                            color: .purple
                        )

                        dashboardCard(
                            title: "T",
                            value: netT,
                            unit: "с",
                            icon: "clock.badge.checkmark",
                            color: .green
                        )
                    }

                    HStack {
                        Text("Итераций: \(totalIterations)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        Spacer()
                    }

                    networkScheme

                    iterationsView
                }
                .padding(10)
                .frame(minWidth: 900)
            }
        }
        .frame(width: 1150, height: 650)
        .background(
            WindowAccessor { window in
                window.title = "Лабораторная работа №6"
                window.styleMask.remove(.resizable)
                window.collectionBehavior.remove(.fullScreenPrimary)
                window.center()
            }
        )
        .onAppear {
            calculate()
        }
    }

    private var matrixEditor: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            GridRow {
                Text("")
                    .frame(width: 24)

                ForEach(0..<6, id: \.self) { i in
                    Text("S\(i)")
                        .bold()
                        .font(.system(size: 10))
                        .frame(width: 38)
                }
            }

            ForEach(0..<6, id: \.self) { row in
                GridRow {
                    Text("S\(row)")
                        .bold()
                        .font(.system(size: 10))
                        .frame(width: 24)

                    ForEach(0..<6, id: \.self) { col in
                        Text(format(matrix[row][col]))
                            .font(.system(size: 10, design: .monospaced))
                            .frame(width: 38, height: 22)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(5)
                    }
                }
            }
        }
    }

    private var networkScheme: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Структурная схема сети")
                .font(.system(size: 13, weight: .semibold))

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))

                Canvas { context, size in

                    let s1 = CGPoint(x: 110, y: 90)
                    let s2 = CGPoint(x: 300, y: 60)
                    let s3 = CGPoint(x: 540, y: 120)
                    let s4 = CGPoint(x: 300, y: 200)
                    let s5 = CGPoint(x: 540, y: 200)

                    func drawArrow(from: CGPoint, to: CGPoint, text: String) {
                        var path = Path()
                        path.move(to: from)
                        path.addLine(to: to)

                        context.stroke(path, with: .color(.black), lineWidth: 1.5)

                        let angle = atan2(to.y - from.y, to.x - from.x)
                        let len: CGFloat = 8

                        let p1 = CGPoint(
                            x: to.x - len * cos(angle - .pi / 6),
                            y: to.y - len * sin(angle - .pi / 6)
                        )

                        let p2 = CGPoint(
                            x: to.x - len * cos(angle + .pi / 6),
                            y: to.y - len * sin(angle + .pi / 6)
                        )

                        var arrow = Path()
                        arrow.move(to: to)
                        arrow.addLine(to: p1)
                        arrow.move(to: to)
                        arrow.addLine(to: p2)

                        context.stroke(arrow, with: .color(.black), lineWidth: 1.5)

                        let mid = CGPoint(
                            x: (from.x + to.x) / 2,
                            y: (from.y + to.y) / 2
                        )

                        context.draw(
                            Text(text).font(.system(size: 10)),
                            at: CGPoint(x: mid.x, y: mid.y - 10)
                        )
                    }

                    func drawLoop(center: CGPoint, text: String) {
                        let rect = CGRect(
                            x: center.x + 12,
                            y: center.y - 32,
                            width: 28,
                            height: 28
                        )

                        context.stroke(
                            Path(ellipseIn: rect),
                            with: .color(.black),
                            lineWidth: 1.5
                        )

                        context.draw(
                            Text(text).font(.system(size: 10)),
                            at: CGPoint(x: rect.midX + 10, y: rect.midY - 12)
                        )
                    }

                    drawArrow(from: CGPoint(x: 20, y: 90), to: s1, text: "λ₀")

                    drawArrow(from: s1, to: s2, text: "0.25")
                    drawArrow(from: s1, to: s4, text: "0.75")

                    drawArrow(from: s2, to: s3, text: "0.25")
                    drawArrow(from: s2, to: s5, text: "0.75")

                    drawArrow(from: s4, to: s3, text: "0.9")
                    drawArrow(from: s4, to: s5, text: "0.1")

                    drawArrow(from: s3, to: s5, text: "0.1")

                    drawArrow(from: s5, to: s1, text: "0.0625")
                    drawArrow(from: s5, to: CGPoint(x: 760, y: 200), text: "0.9375")
                }

                nodeView(title: "S1", k: kChannels[0])
                    .position(x: 110, y: 90)

                nodeView(title: "S2", k: kChannels[1])
                    .position(x: 300, y: 60)

                nodeView(title: "S3", k: kChannels[2])
                    .position(x: 540, y: 120)

                nodeView(title: "S4", k: kChannels[3])
                    .position(x: 300, y: 200)

                nodeView(title: "S5", k: kChannels[4])
                    .position(x: 540, y: 200)
            }
            .frame(height: 300)
        }
    }

    private func nodeView(title: String, k: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.15))
                .frame(width: 70, height: 45)
                .overlay(
                    VStack(spacing: 2) {


                        Text("K=\(k)")
                            .font(.system(size: 9))
                    }
                )
        }
    }

    private func dashboardCard(
        title: String,
        value: Double,
        unit: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 11))

                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(format(value))
                    .font(.system(size: 16, weight: .bold))

                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var iterationsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(iterations) { step in
                Grid(
                    alignment: .trailing,
                    horizontalSpacing: 8,
                    verticalSpacing: 4
                ) {
                    GridRow {
                        Text("Узел").bold()
                        Text("α").bold()
                        Text("λ").bold()
                        Text("β").bold()
                        Text("ρ").bold()
                        Text("P₀").bold()
                        Text("Lq").bold()
                        Text("L").bold()
                        Text("Wq").bold()
                        Text("W").bold()
                        Text("OK").bold()
                    }
                    .font(.system(size: 10))

                    Divider()

                    ForEach(step.metrics) { m in
                        GridRow {
                            Text(m.name).bold()

                            Text(format(m.alpha))
                            Text(format(m.lambda))
                            Text(format(m.beta))
                            Text(format(m.rho))

                            Text(m.isStable ? format(m.p0) : "-")
                            Text(m.isStable ? format(m.lq) : "-")
                            Text(m.isStable ? format(m.l) : "-")
                            Text(m.isStable ? format(m.wq) : "-")
                            Text(m.isStable ? format(m.w) : "-")

                            Image(
                                systemName:
                                    m.isStable
                                    ? "+"
                                    : "-"
                            )
                            .foregroundColor(
                                m.isStable
                                ? .green
                                : .red
                            )
                            .font(.system(size: 10))
                        }
                        .font(.system(size: 10, design: .monospaced))
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
        }
    }

    private func calculate() {
        var lambdas = Array(repeating: 0.0, count: 6)

        var currentStep = 0

        var history: [StepResult] = []

        let maxIterations = 100

        let epsilon = 1e-6

        while currentStep < maxIterations {
            currentStep += 1

            var nextLambdas = Array(repeating: 0.0, count: 6)

            for j in 1...5 {
                nextLambdas[j] =
                lambda0 * matrix[0][j]
            }

            for j in 1...5 {
                for i in 1...5 {
                    nextLambdas[j] +=
                    lambdas[i] * matrix[i][j]
                }
            }

            let maxDiff =
            zip(lambdas, nextLambdas)
                .map { abs($0 - $1) }
                .max() ?? 0

            lambdas = nextLambdas

            var metrics: [NodeMetrics] = []

            for i in 1...5 {
                metrics.append(
                    calculateQueueMetrics(
                        nodeIndex: i,
                        lambda: lambdas[i]
                    )
                )
            }

            history.append(
                StepResult(
                    step: currentStep,
                    metrics: metrics
                )
            )

            if maxDiff < epsilon {
                break
            }
        }

        iterations = Array(history.suffix(1))

        totalIterations = currentStep

        if let finalMetrics = history.last?.metrics {
            netL =
            finalMetrics
                .filter { $0.isStable }
                .reduce(0) { $0 + $1.lq }

            netN =
            finalMetrics
                .filter { $0.isStable }
                .reduce(0) { $0 + $1.l }

            netW = netL / lambda0

            netT = netN / lambda0
        }
    }

    private func calculateQueueMetrics(
        nodeIndex: Int,
        lambda: Double
    ) -> NodeMetrics {

        let v = vTimes[nodeIndex - 1]

        let kInt = kChannels[nodeIndex - 1]

        let k = Double(kInt)

        let alpha = lambda / lambda0

        let beta = lambda * v

        let rho = beta / k

        let isStable = rho < 1.0

        var p0 = 0.0
        var lq = 0.0
        var l = 0.0
        var wq = 0.0
        var w = 0.0

        if isStable && lambda > 0 {
            var sum = 0.0

            for n in 0..<kInt {
                sum +=
                pow(beta, Double(n))
                / factorial(n)
            }

            let lastTerm =
            pow(beta, k)
            /
            (
                factorial(kInt)
                * (1 - rho)
            )

            p0 = 1.0 / (sum + lastTerm)

            lq =
            (
                p0 * pow(beta, k + 1)
            )
            /
            (
                k
                * factorial(kInt)
                * pow(1 - rho, 2)
            )

            l = lq + beta

            wq = lq / lambda

            w = wq + v
        }

        return NodeMetrics(
            name: "S\(nodeIndex)",
            alpha: alpha,
            lambda: lambda,
            beta: beta,
            rho: rho,
            isStable: isStable,
            p0: p0,
            lq: lq,
            l: l,
            wq: wq,
            w: w
        )
    }

    private func factorial(_ n: Int) -> Double {
        if n <= 1 {
            return 1.0
        }

        return Double((1...n).reduce(1, *))
    }

    private func format(_ value: Double) -> String {
        value.formatted(
            .number.precision(
                .fractionLength(4)
            )
        )
    }
}

#Preview {
    Lab6_MS()
}
