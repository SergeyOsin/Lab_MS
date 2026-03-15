import SwiftUI

struct TableRow: Identifiable {
    let id = UUID()
    let x: String
    let z1, z2, z3, z4, z5, z6: String
}

struct StepRow: Identifiable {
    let id = UUID()
    let rowTitle: String
    let c0, c1, c2, c3, c4, c5, c6: String
}

struct Lab3_MS: View {
    @State private var tableData: [TableRow] = [
        TableRow(x: "x1", z1: "z2", z2: "z3", z3: "z4", z4: "z5", z5: "z6", z6: "z1"),
        TableRow(x: "x2", z1: "z3", z2: "z4", z3: "z5", z4: "z6", z5: "z1", z6: "z2"),
        TableRow(x: "x3", z1: "z4", z2: "z5", z3: "z6", z4: "z1", z5: "z2", z6: "z3")
    ]
    
    @State private var StatusZ: String = "z1"
    @State private var StatusX: String = "x1"
    
    @State private var logicRows: [StepRow] = []
    
    func nextState(from state: String, by input: String) -> String {
        guard let row = tableData.first(where: { $0.x == input }) else { return state }
        switch state {
        case "z1": return row.z1
        case "z2": return row.z2
        case "z3": return row.z3
        case "z4": return row.z4
        case "z5": return row.z5
        case "z6": return row.z6
        default:   return state
        }
    }
    
    func runMachine() {
        var colsZ: [String] = Array(repeating: "", count: 7)
        var colsX: [String] = Array(repeating: "", count: 7)
        var colsT: [String] = Array(repeating: "", count: 7)
        colsT[0] = "-"
        colsX[0] = "-"
        colsZ[0] = StatusZ
        
        var z = StatusZ
        
        for i in 1...6 {
            let x = StatusX
            colsT[i] = "\(i)"
            colsX[i] = x
            let zNext = nextState(from: z, by: x)
            colsZ[i] = zNext
            z = zNext
        }
        
        logicRows = [
            StepRow(rowTitle: "Входные символы",
                    c0: colsX[0], c1: colsX[1], c2: colsX[2], c3: colsX[3],
                    c4: colsX[4], c5: colsX[5], c6: colsX[6]),
            StepRow(rowTitle: "Состояния автомата",
                    c0: colsZ[0], c1: colsZ[1], c2: colsZ[2], c3: colsZ[3],
                    c4: colsZ[4], c5: colsZ[5], c6: colsZ[6])
        ]
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Вариант - 2. Тип автомата - без выхода")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.blue.mix(with: .white, by: 0.45))
            GroupBox{
                Text("X={x1,x2,x3} - входные сигналы;\nZ={z1,z2,z3,z4,z5,z6} - множество состояний;\nf-функция переходов;\nz[n+1]=f(z[n],x[n])")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.blue.mix(with: .white, by: 0.7))
            }.frame(height: 100)
            HStack(alignment: .top, spacing: 5){
                GroupBox("Таблица переходов"){
                    Table(tableData) {
                        TableColumn("Вход.символы") { row in
                            Text(row.x)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .width(100)
                        
                        TableColumn("z1") { row in Text(row.z1).frame(maxWidth: .infinity, alignment: .center) }.width(45)
                        TableColumn("z2") { row in Text(row.z2).frame(maxWidth: .infinity, alignment: .center) }.width(45)
                        TableColumn("z3") { row in Text(row.z3).frame(maxWidth: .infinity, alignment: .center) }.width(45)
                        TableColumn("z4") { row in Text(row.z4).frame(maxWidth: .infinity, alignment: .center) }.width(45)
                        TableColumn("z5") { row in Text(row.z5).frame(maxWidth: .infinity, alignment: .center) }.width(45)
                        TableColumn("z6") { row in Text(row.z6).frame(maxWidth: .infinity, alignment: .center) }.width(45)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .frame(height: 110)
                    .frame(width: 500)
                }
            }
            HStack(alignment: .top, spacing: 3){
                GroupBox{
                    Text("Выберите состояние")
                    Picker("Состояние", selection: $StatusZ) {
                        Text("z1").tag("z1")
                        Text("z2").tag("z2")
                        Text("z3").tag("z3")
                        Text("z4").tag("z4")
                        Text("z5").tag("z5")
                        Text("z6").tag("z6")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 210)
                    .frame(height: 70)
                    .padding(1)
                    .background(Color.black.mix(with: .white, by:0.3))
                }
                .border(Color.black,width: 3)
                
                GroupBox{
                    Text("Выберите вход")
                    Picker("Входной символ",selection: $StatusX){
                        Text("x1").tag("x1")
                        Text("x2").tag("x2")
                        Text("x3").tag("x3")
                    }
                    .pickerStyle(.inline)
                    .frame(width: 210)
                    .frame(height:70)
                    .background(Color.black.mix(with: .white, by: 0.2))
                }
                .border(Color.black,width: 3)
            }
            
            Spacer()
            
            Button("Запустить") {
                runMachine()
            }
            .padding(6)
            .background(Color.blue)
            .foregroundStyle(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        
            HStack(alignment: .top, spacing: 5){
                GroupBox("Логика работы автомата") {
                    Table(logicRows) {
                        TableColumn("") { row in
                            Text(row.rowTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .width(135)
                        
                        TableColumn("-") { row in
                            Text(row.c0).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                        
                        TableColumn("1") { row in
                            Text(row.c1).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                        
                        TableColumn("2") { row in
                            Text(row.c2).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                        
                        TableColumn("3") { row in
                            Text(row.c3).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                        
                        TableColumn("4") { row in
                            Text(row.c4).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                        
                        TableColumn("5") { row in
                            Text(row.c5).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                        
                        TableColumn("6") { row in
                            Text(row.c6).frame(maxWidth: .infinity, alignment: .center)
                        }.width(40)
                    }
                    .frame(height: 80)
                    .frame(width: 565)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
        .onAppear {
            runMachine()
        }
    }
}

#Preview {
    Lab3_MS()
}
