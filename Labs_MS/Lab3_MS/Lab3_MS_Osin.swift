import SwiftUI

struct TableRow: Identifiable {
    let id = UUID()
    let x: String
    let z1, z2, z3, z4, z5, z6: String
}

struct StepRow: Identifiable {
    let id = UUID()
    let rowTitle: String
    var c0, c1, c2, c3, c4, c5, c6: String
}


struct Lab3_MS: View {
    @State private var tableData: [TableRow] = [
        TableRow(x: "x1", z1: "z2", z2: "z3", z3: "z4", z4: "z5", z5: "z6", z6: "z1"),
        TableRow(x: "x2", z1: "z3", z2: "z4", z3: "z5", z4: "z6", z5: "z1", z6: "z2"),
        TableRow(x: "x3", z1: "z4", z2: "z5", z3: "z6", z4: "z1", z5: "z2", z6: "z3")
    ]
    
    @State private var StatusZ: String = "z1";
    @State private var StatusX: String = "x1";
    @State private var filledSteps: Int = 0;
    @State private var isBlocked=true;
    @State private var showAlert=false;
    @State private var logicRows: [StepRow] = [
            StepRow(rowTitle: "Входные символы",
                    c0: "", c1: "", c2: "", c3: "", c4: "", c5: "", c6: ""),
            StepRow(rowTitle: "Состояния автомата",
                    c0: "", c1: "", c2: "", c3: "", c4: "", c5: "", c6: "")
    ];
    
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
        isBlocked=false;
        if filledSteps==6{
            showAlert=true;
            return;
        }
        else if filledSteps == 0 {
            logicRows[0].c0 = "-"
            logicRows[1].c0 = StatusZ
        }
        showAlert=false;
        let stepIndex = filledSteps + 1
        let currentZ: String
        if filledSteps == 0 {
            currentZ = StatusZ
        } else {
            switch filledSteps {
            case 1: currentZ = logicRows[1].c1
            case 2: currentZ = logicRows[1].c2
            case 3: currentZ = logicRows[1].c3
            case 4: currentZ = logicRows[1].c4
            case 5: currentZ = logicRows[1].c5
            case 6: currentZ = logicRows[1].c6
            default: currentZ = StatusZ
            }
        }
        
        let x = StatusX
        let nextZ = nextState(from: currentZ, by: x)
        
        switch stepIndex {
        case 1:
            logicRows[0].c1 = x
            logicRows[1].c1 = nextZ
        case 2:
            logicRows[0].c2 = x
            logicRows[1].c2 = nextZ
        case 3:
            logicRows[0].c3 = x
            logicRows[1].c3 = nextZ
        case 4:
            logicRows[0].c4 = x
            logicRows[1].c4 = nextZ
        case 5:
            logicRows[0].c5 = x
            logicRows[1].c5 = nextZ
        case 6:
            logicRows[0].c6 = x
            logicRows[1].c6 = nextZ
        default:
            break
        }
        
        filledSteps += 1
        }
    
    func ClearTable(){
        logicRows[0] = StepRow(rowTitle: "Входные символы",
        c0: "", c1: "", c2: "", c3: "", c4: "", c5: "", c6: "")
        logicRows[1] = StepRow(rowTitle: "Состояния автомата",
        c0: "", c1: "", c2: "", c3: "", c4: "", c5: "", c6: "")
        isBlocked=true;
        filledSteps=0;
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Вариант - 2. Тип автомата - без выхода")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.blue.mix(with: .white, by: 0.45))
            GroupBox{
                Text("F=(X,Z,f),")
                Text("где X={x1,x2,x3} - входные сигналы;\nZ={z1,z2,z3,z4,z5,z6} - множество состояний;\nf-функция переходов;\nz[n+1]=f(z[n],x[n])")
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
                    .frame(width: 220)
                    .frame(height: 70)
                    .background(Color.black.mix(with: .white, by:0.25))
                }
                .border(Color.black,width: 3)
                .disabled(!isBlocked)
                
                GroupBox{
                    Text("Выберите вход")
                    Picker("Входной символ",selection: $StatusX){
                        Text("x1").tag("x1")
                        Text("x2").tag("x2")
                        Text("x3").tag("x3")
                    }.pickerStyle(.inline)
                    .frame(width: 220)
                    .padding(1)
                    .frame(height:70)
                    .background(Color.black.mix(with: .white, by: 0.2))
                }
                .border(Color.black,width: 3)
            }
            
            Spacer()
            HStack{
                Button("Запустить") {runMachine()}
                .padding(1)
                .background(Color.blue)
                .foregroundStyle(.yellow)
                .font(Font.headline)
                .cornerRadius(5)
                Button("Очистить таблицу"){ClearTable()}
                    .backgroundStyle(Color.black)
                    .foregroundStyle(Color.red)
                    .font(Font.subheadline)
                    .cornerRadius(5)
                    .padding(1)
            }
            
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
        .onAppear {ClearTable()}
        .alert("Таблица заполнена", isPresented: $showAlert){
            Button("ОК",role: .close){}
        } message: {
            Text("Все строки таблицы заполнены. Очистите таблицу")
        }
        
    }
}

#Preview {
    Lab3_MS()
}


