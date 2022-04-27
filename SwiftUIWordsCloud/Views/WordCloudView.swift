//
//  WordCloudView.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/24.
//

import SwiftUI

struct WordCloudView: View {
    
    @StateObject var vm: WordCloudViewModel
    
    init(dataService: WordCloudServiceProtocol) {
        _vm = StateObject(wrappedValue: WordCloudViewModel(dataService: dataService))
    }
    
    var body: some View {
        ZStack {

 
            ForEach(0..<vm.dataService.words.count) { i in
                let word = vm.dataService.words[i]
                WordView(text: word.text, size: word.size, color: word.color, index: i, angle: word.angle)
                    .environmentObject(vm)
            }
            
//            Button {
//                vm.dataService.showWholeRects()
//                vm.showWholePosition()
//            } label: {
//                Text("show")
//            }.offset(y: 240)
//
//            Button {
//                vm.placeSubject.send(Void())
//            } label: {
//                Text("place")
//            }.offset(y: 300)
//
//            Button {
//                vm.moveSubject.send(Void())
//            } label: {
//                Text("move")
//            }.offset(y: 320)

        }
    }
}

extension WordCloudView {
    
    func word_cloud_view() -> some View {
        
        ZStack {
            ForEach(0..<vm.dataService.words.count) { i in
                let word = vm.dataService.words[i]
                WordView(text: word.text, size: word.size, color: word.color, index: i, angle: word.angle)
                    .environmentObject(vm)
            }
        }
        .rotationEffect(Angle(degrees: 30))
    }
}

//struct WordCloudView_Previews: PreviewProvider {
//    static let dataService = WordCloudService(words: ["SwiftUI", "A"])
//    static var previews: some View {
//        WordCloudView(dataService: dataService)
//    }
//}
