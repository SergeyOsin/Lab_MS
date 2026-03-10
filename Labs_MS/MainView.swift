
import SwiftUI

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {MainView()}
    }
}


struct MainView: View {
    private var NameDisc: String = "'Моделирование систем'";
    var body: some View {
        NavigationStack{
            VStack(spacing: 10){
                Text("Лабораторные работы по дисциплине \(NameDisc)")
                    .font(.title)
                NavigationLink("Лабораторная работа №2"){
                    Lab2_MS()
                }.background(Color.accentColor)
                    .fontDesign(Font.Design.rounded)
                    .cornerRadius(10)
                NavigationLink("Лабораторная работа №3"){
                    Lab3_MS()
                }.background(Color.mint)
                    .cornerRadius(10)
            }.frame(width:750, height:250)
        }
        ZStack(alignment: .bottomTrailing){
            Button("Выйти"){
                NSApplication.shared.terminate(nil);
            } .background(Color.secondary)
        }
    }
    
}

#Preview {MainView()}
