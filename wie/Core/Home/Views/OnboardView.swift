import SwiftUI

struct OnboardView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject private var userProgress: UserProgress
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let menuItems = Menu.options

    var body: some View {
        GeometryReader { geometry in
        
                VStack(alignment: .leading) {
                    header
                        .padding(.top)
                        .padding(.horizontal)
                    // WordLevelsView().environmentObject(vm)
                    //Spacer()
                    
                    menu(in: geometry)
                        .padding()
                }
            
            
        }
    }

    private func menu(in geometry: GeometryProxy) -> some View {
        let totalHeight = vm.showWordsList ? geometry.size.height * 0.58 : geometry.size.height * 0.82
        let itemHeight = totalHeight / CGFloat(menuItems.count)

        return VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 30 : 20) {
            ForEach(menuItems) { item in
                ZStack {
                    CustomNavLinkView(destination: destinationView(selectedId: item.id)) {
                        menuItemView(item, height: itemHeight, geometry: geometry)
                    }
                }
                
            }
        }
    }

    private func menuItemView(_ item: MenuItem, height: CGFloat, geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            if horizontalSizeClass == .regular {
                Image("\(item.id)")
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding(.trailing, 230)
            } else {
                Image("\(item.id)")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
            }

            Text(item.title)
                .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 40 : 30))
                .foregroundColor(Color.theme.accent)
                .multilineTextAlignment(.leading)
                .padding(.leading, horizontalSizeClass == .regular ? 200 : 115)
                .padding(.top, item.id == 1 ? 42 : 15)
                .padding(.trailing, horizontalSizeClass == .regular ? 100 : 0)
        }
        //.frame(width: .infinity)
        .frame(width: geometry.size.width * (horizontalSizeClass == .regular ? 0.96 : 0.92))
        .frame(height: height + ((vm.showWordsList && horizontalSizeClass == .regular) ? 10 : 0))
        .background(Color.theme.fillingColor)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        //.padding(.leading)
    }

    private func destinationView(selectedId: Int) -> some View {
        switch selectedId {
        case 1:
            return AnyView(CommonExceptionWordsView()
                .customNavigationTitle("Common Exception Words")
                .environmentObject(vm)
                .environmentObject(userProgress))
        case 2:
            return AnyView(WhatsOnTheTrayView()
                .customNavigationTitle("What's on the Tray")
                .environmentObject(vm)
                .environmentObject(userProgress))
        case 3:
            return AnyView(WordSearchView()
                .customNavigationTitle("Word Search")
                .environmentObject(vm)
                .environmentObject(userProgress))
        default:
            return AnyView(Text("Default View"))
        }
    }

    private var header: some View {
            VStack {
                Button(action: {
                    withAnimation {
                        vm.toogleWordsList()
                    }
                })  {
                    Text(vm.currentWordLevel.name)
                        .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 30 : 24))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(Color.theme.accent)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .leading) {
                            Image(systemName: "arrow.down")
                                .font(horizontalSizeClass == .regular ? .title : .headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color.theme.accent)
                                .padding()
                                .rotationEffect(Angle(degrees: vm.showWordsList ? 180 : 0))
                        }
                              }
                              
                              if vm.showWordsList {
                                  WordLevelsView().environmentObject(vm)
                               
                              }
                              
                          }
                          .background(Color.theme.fillingColor)
                          .cornerRadius(20)
                          .shadow(color: Color.theme.fillingColor.opacity(0.5), radius: 20, x: 0, y: 15)
                          
                      }
                  
}

struct Previews_OnboardView_Previews: PreviewProvider {
    static var previews: some View {

            OnboardView()
                .environmentObject(HomeViewModel())
                .environmentObject(UserProgress.shared)
               

       
    }
}

