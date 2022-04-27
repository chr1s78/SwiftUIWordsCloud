//
//  InitOder.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/2/8.
//

import SwiftUI

struct InitOder: View {
    var body: some View {
        
        ZStack {
            ViewA()
            ViewB()
        }
    }
}

struct ViewA: View {
    init() {
        print("ViewA init")
    }
    var body: some View {
        Text("1")
    }
}

struct ViewB: View {
    init() {
        print("ViewB init")
    }
    var body: some View {
        Text("2")
    }
}

struct InitOder_Previews: PreviewProvider {
    static var previews: some View {
        InitOder()
    }
}
