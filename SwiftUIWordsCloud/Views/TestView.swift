//
//  TestView.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/29.
//

import SwiftUI

struct TestView: View {
    
    @State var rc: CGRect = .zero
    @State var x: CGFloat = 0.0
    @State var y: CGFloat = 0.0
    @StateObject var vm = ViewModel()

    var body: some View {
        VStack {

            Text("Combine")
                .rotationEffect(Angle(degrees: -30))
                
            
            Text("SwiftUI")
                .font(.system(size: 30))
                .background(TextsGeometry())
                .onPreferenceChange(TextsSizeKey.self) {
                    self.rc = $0
                    // 被多次调用，导致rectArray数组多出额外的数据
                    print("rc: \(rc)")
                }
                .offset(x: vm.x, y: vm.y)
            
            Button {
//                withAnimation {
//                    vm.x += 10
//                    vm.y += 10
//                }
                vm.move()
            } label: {
                Text("offset")
            }.offset(y: 100)

        }
    }
}

extension TestView {
    class ViewModel: ObservableObject {
        @Published var x: CGFloat = 0.0
        @Published var y: CGFloat = 0.0
        
        func move() {
            withAnimation {
                x += 10
                y += 10
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
