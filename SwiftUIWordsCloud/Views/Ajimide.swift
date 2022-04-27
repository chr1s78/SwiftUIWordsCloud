//
//  Ajimide.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/2/7.
//

import SwiftUI

struct Ajimide: View {
    
//    x = (a+b∗θ)∗cosθ
//    y = (a+b∗θ)∗sinθ
    
    var body: some View {

        ZStack {
            ForEach( Array(stride(from: 0.0, to: Double.pi * 6.0, by: Double.pi * 0.1)), id: \.self) { i in
                Text(".")
                    .offset(x: (2+6.1 * i) * cos(i) )
                    .offset(y: (2+6.1 * i) * sin(i) )
            }
        }
    }
}

struct AjimideR: View {
    
//    x=r∗cosθ
//    y=r∗sinθ
    
    var body: some View {
        ZStack {
            ForEach( Array(stride(from: 0.0, to: Double.pi * 6.0, by: Double.pi * 0.01)), id: \.self) { i in
                Text(".")
                    .offset(x: 9 * cos(i) )
                    .offset(y: 9 * sin(i) )
            }
        }
    }
}

struct Ajimide_Previews: PreviewProvider {
    static var previews: some View {
        Ajimide()
     //   AjimideR()
    }
}
