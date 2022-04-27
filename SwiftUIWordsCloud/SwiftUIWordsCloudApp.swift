//
//  SwiftUIWordsCloudApp.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/24.
//

import SwiftUI

@main
struct SwiftUIWordsCloudApp: App {
    
    let dataService = WordCloudService(
        words: [
            WordModel(text: "风行者", size: 14, color: .pink, angle:-90),
            WordModel(text: "龙骑士", size: 14, color: .red, angle: -90),
            WordModel(text: "破晓晨星", size: 14, color: .purple, angle: 0),
            WordModel(text: "屠夫", size: 14, color: .pink, angle: 0),
            WordModel(text: "痛苦之源", size: 14, color: .green, angle: 0),
            WordModel(text: "马格纳斯", size: 14, color: .pink, angle: 0),
            WordModel(text: "瘟疫法师", size: 14, color: .red, angle: 0),
            WordModel(text: "斧王", size: 20, color: .purple, angle: 0),
            WordModel(text: "米波", size: 20, color: .pink, angle: 0),
            WordModel(text: "痛苦女王", size: 20, color: .green, angle: 0),
            WordModel(text: "昆卡", size: 20, color: .blue, angle: 0),
            WordModel(text: "潮汐使者", size: 20, color: .purple, angle: 0),
            WordModel(text: "天涯墨客", size: 30, color: .purple, angle: 0),
            WordModel(text: "电炎绝手", size: 30, color: .red, angle: 0),
            WordModel(text: "凤凰", size: 30, color: .red, angle: 0),
            WordModel(text: "森海飞霞", size: 30, color: .pink, angle: 0),
            WordModel(text: "敌法师", size: 40, color: .yellow),
        ]
    )
    var body: some Scene {
        WindowGroup {
         //   InitOder()
          WordCloudView(dataService: dataService)
           // TestView()
        }
    }
}
