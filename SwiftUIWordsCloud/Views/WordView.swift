//
//  WordView.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/24.
//

import SwiftUI

struct WordView: View {
    
    @State var rc: CGRect = .zero
    @EnvironmentObject var vm: WordCloudViewModel
    
    var text: String
    var size: CGFloat
    var color: Color
    var index: Int
    var angle: CGFloat
    
    var body: some View {

            Text(text)
            .font(.system(size: size)).bold()
                .foregroundColor(color)
                .rotated(Angle(degrees: angle))
                .offset(x: vm.position[index].x)
                .offset(y: vm.position[index].y)
                .background(TextsGeometry())
                .onPreferenceChange(TextsSizeKey.self) {
                    self.rc = $0
                    print("\(index) \(text) rc: \(rc)")
                    print("position[\(index)] = \(vm.position[index])")
                    print("")
                 //   vm.dataService.updateRects(index, rc: $0)
                    vm.updateSubject.send((index, self.rc))
                }
                
    }
}


struct WordView_Previews: PreviewProvider {
    static var previews: some View {
        WordView(text: "SwiftUI", size: 40, color: .yellow, index: 1, angle: 0.0)
    }
}
