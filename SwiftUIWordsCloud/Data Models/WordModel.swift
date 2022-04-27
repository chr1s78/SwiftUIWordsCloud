//
//  WordModel.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/27.
//

import Foundation
import SwiftUI

struct WordModel: Identifiable {
    let id = UUID()
    var text: String
    var size: CGFloat
    var color: Color
    var angle: CGFloat
    
    init(text: String = "", size: CGFloat = 0.0, color: Color = .clear, angle: CGFloat = 0.0) {
        self.text = text
        self.size = size
        self.color = color
        self.angle = angle
    }
}
