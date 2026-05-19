import SwiftUI;
import QuickLook;
import UniformTypeIdentifiers;

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {MainView()}
            .windowResizability(.contentSize)
    }
}


struct MainView: View {
    let RADIUS: CGFloat=10;
    let FONTDESIGN: Font.Design = .rounded;
    private var NameDisc: String = "'Моделирование систем'";
    var body: some View {
        NavigationStack{
            Text("Осин С.М. 23ВП2.")
                .font(Font.largeTitle)
                .foregroundStyle(Color.primary.mix(with: .red, by: 0.2))
            Text("Лабораторные работы по дисциплине \(NameDisc)")
                .font(.title)
            VStack(spacing: 15){
                HStack{
                    NavigationLink("Лабораторная работа №2"){
                        Lab2_MS()
                    }.background(Color.white)
                        .fontDesign(FONTDESIGN)
                        .cornerRadius(RADIUS)
                        .foregroundStyle(Color.black)
                        .buttonStyle(.bordered)
                    NavigationLink("Лабораторная работа №3"){
                        Lab3_MS()
                    }.background(.white)
                        .cornerRadius(RADIUS)
                        .foregroundStyle(.black)
                        .buttonStyle(.bordered)
                }
                HStack{
                    NavigationLink("Лабораторная работа №4"){
                        Lab4_MS()
                    } .background(.blue)
                        .cornerRadius(RADIUS)
                        .foregroundStyle(.white)
                        .buttonStyle(.glass)
                    NavigationLink("Лабораторная работа №5"){Lab5_MS()}
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(RADIUS)
                        .font(.title2)
                        .buttonStyle(.glass)
                }
                HStack{
                    NavigationLink("Лабораторная работа №6"){
                        Lab6_MS()
                    }.background(Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(RADIUS)
                    NavigationLink("Лабораторная работа №7"){
                        Lab7_MS()
                    }.foregroundStyle(.white)
                        .background(.red)
                        .font(.title2)
                        .cornerRadius(RADIUS)
                        
                }
                
            }.frame(width:750, height: 220)
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
