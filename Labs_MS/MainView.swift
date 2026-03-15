import SwiftUI;
import QuickLook;
import UniformTypeIdentifiers;

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {MainView()}
            .windowResizability(.contentSize)
        WindowGroup{Lab3_MS()}.windowResizability(.automatic)
    }
}


struct MainView: View {
    let RADIUS: CGFloat=10;
    private var NameDisc: String = "'Моделирование систем'";
    var body: some View {
        NavigationStack{
            Text("Осин С.М. 23ВП2. Вариант - 16")
                .font(Font.largeTitle)
                .foregroundStyle(Color.primary.mix(with: .red, by: 0.2))
            VStack(spacing: 15){
                Text("Лабораторные работы по дисциплине \(NameDisc)")
                    .font(.title)
                NavigationLink("Лабораторная работа №2"){
                    Lab2_MS()
                }.background(Color.white)
                    .fontDesign(Font.Design.rounded)
                    .cornerRadius(RADIUS)
                    .foregroundStyle(Color.black)
                NavigationLink("Лабораторная работа №3"){
                    Lab3_MS()
                }.background(Color.blue)
                    .cornerRadius(RADIUS)
                NavigationLink("Лабораторная работа №4"){} .background(Color.red)
                    .cornerRadius(RADIUS)
            }.frame(width:750, height:250)
            
        }
        .overlay(alignment: .bottomTrailing){
            Button("Выйти"){
                NSApplication.shared.terminate(nil);
            } .background(Color.blue.mix(with: .black, by: 0.3))
                .cornerRadius(RADIUS)
                .padding(10)
        }
    }
}

#Preview {MainView()}
