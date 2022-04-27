//
//  PreferenceKey+Extensions.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/24.
//

import Foundation
import SwiftUI

struct TextsSizeKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct TextsGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: TextsSizeKey.self,
                    value: geometry.frame(in: .global))
        }
    }
}

extension CGRect {
//    func move(x: CGFloat, y: CGFloat) -> CGPoint {
//        let rc = self.offsetBy(dx: x, dy: y)
//        return CGPoint(x: rc.midX, y: rc.midY)
//    }
}
