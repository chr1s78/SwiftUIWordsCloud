//
//  WordCloudViewModel.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/24.
//

import Foundation
import SwiftUI
import Combine

class WordCloudViewModel: ObservableObject {
    
    // 存储每个子View的CGRect信息
    @Published var rectArray: [CGRect] = []
    // 存储每个ziView的Position信息
    @Published var position: [CGPoint] = []
    
    @Published var randomPoint: [CGPoint] = []
    
    var maxWords: Int = 0
    
    // MARK: - 区域权重, 为5时表示只有序号为5的倍数时，才摆放在左侧
    //         其余情况都随机分布在上下两侧
    let weights: Int = 5

    let placeSubject = PassthroughSubject<Void, Never>()
    let moveSubject = PassthroughSubject<Void, Never>()
    let updateSubject = PassthroughSubject<(Int, CGRect), Never>()
    var cancellables = Set<AnyCancellable>()
    
    var dataService: WordCloudServiceProtocol
    
 
    init(dataService: WordCloudServiceProtocol) {
        
        self.dataService = dataService
        
        rectArray = [CGRect]( repeating: .zero, count: 30)
        position = [CGPoint]( repeating: .zero, count: 30)
        randomPoint = [CGPoint]( repeating: .zero, count: 30)
        
        updateSubject
            .flatMap { self.dataService.updateRects($0, rc: $1) }
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                withAnimation {
                    self?.position[value.0] = value.1
                }
            }
            .store(in: &cancellables)
        
        placeSubject
            .flatMap { self.dataService.getRandomPointInRect2() }
            .receive(on: RunLoop.main)
            .sink { pos in
                withAnimation {
                    self.position = pos
                }
                print("---sink pos: \(self.position)")
            }
            .store(in: &cancellables)
        
        moveSubject
//            .sink { _ in
//                self.compareRC()
//            }
            .flatMap { self.dataService.move() }
            .receive(on: RunLoop.main)
            .sink { pos in
                withAnimation {
                    self.position = pos
                }
                print("---move pos: \(self.position)")
            }
            .store(in: &cancellables)
    }
    
    // 设定词云图的View总数
    func setMaxWords(_ num: Int) {
        self.maxWords = num
        rectArray = [CGRect]( repeating: .zero, count: num)
        position = [CGPoint]( repeating: .zero, count: num)
        randomPoint = [CGPoint]( repeating: .zero, count: num)
      
    }
    // 更新或添加新的CGRect到rectArray
    func updateRCArray(_ rc: CGRect, _ index: Int) {
        guard index < self.maxWords && index > 0 else { return }
        self.rectArray[index] = rc
    }
    
    func showWholePosition() {
        print("+++ whole position: \(self.position)")
    }
    
    // 在主词云View中随机放置其余词云View
    func placeRandomRect() {
        
        // 初始矩形内分为三个区域
        let height = rectArray[0].maxY - rectArray[0].minY
        let width = rectArray[0].maxX - rectArray[0].minX
        // 左中区域
        let leftRange: (Range<Int>, Range<Int>) =
            (
                Int(rectArray[0].minX)..<Int(rectArray[0].minX + (width / 4)),
                Int(rectArray[0].minY + height / 4)..<Int(rectArray[0].minY + height * 3 / 4 )
            )
        // 上区域
        let topRange: (Range<Int>, Range<Int>) =
            (
                Int(rectArray[0].minX)..<Int(rectArray[0].maxX),
                Int(rectArray[0].minY)..<Int( rectArray[0].minY + height / 4)
            )
        // 下区域
        let bottomRange: (Range<Int>, Range<Int>) =
            (Int(rectArray[0].minX)..<Int(rectArray[0].maxX),
             Int(rectArray[0].midY + (rectArray[0].midY - rectArray[0].minY) / 2 )..<Int(rectArray[0].maxY)
            )

        print("++++ rect count : \(rectArray.count)")

        // 上下图云
        for i in 1..<rectArray.count {

            var r: (Range<Int>, Range<Int>)
            
            if i < 3 {
                r = leftRange
            }
            else if i % 2 == 0 {
                r = topRange
            } else {
                r = bottomRange
            }

            // 在随机选取的区域内随机取x和y坐标值
            let x = Int.random(in: r.0)
            let y = Int.random(in: r.1)

            randomPoint[i] = CGPoint(x: x, y: y)

            print("--- Random Place Rect ---- ")
            print("--- [\(i)]: \(rectArray[i])")
            print("--- range: \(r)")
            print("--- random point: x \(x), y \(y)")

            // 计算当前View移动到 以随机点为中点的View的偏移量
            let offsetX = CGFloat(x) - rectArray[0].midX
            let offsetY = CGFloat(y) - rectArray[0].midY
            self.rectArray[i] = self.rectArray[i].offsetBy(
                dx: offsetX ,
                dy: offsetY
            )
            // 计算offset
            self.position[i] = CGPoint(x: offsetX, y: offsetY)
            print("--- place pos: \(self.position[i])")
            print("--- place rec: \(self.rectArray[i])")
        }
        
        print("++++ after rect count : \(rectArray.count)")

    }
    
    // 如果两个矩形重叠，则移动矩形直到不重叠
    // 不重叠时返回 true
    func compare2Rects(rc1: CGRect, rc2: inout CGRect) -> Bool {
        
        var condition: Int = 0

        print("==[in while]: rc1: \(rc1), rc2: \(rc2)")

        repeat {
            let rc = rc1.intersection(rc2)
            if rc.isNull {
                print("rc1:\(rc1) rc2:\(rc2) 不重叠")
                condition = 1
            } else {
                
                // rc2左上角坐标是否在rc1内
                let topLeading = rc1.contains(CGPoint(x: rc2.minX, y: rc2.minY))
                // rc2右上角坐标是否在rc1内
                let topTrailing = rc1.contains(CGPoint(x: rc2.maxX, y: rc2.minY))
                // rc2左下角坐标是否在rc1内
                let bottomLeading = rc1.contains(CGPoint(x: rc2.minX, y: rc2.maxY))
                // rc2右下角坐标是否在rc1内
                let bottomTrailing = rc1.contains(CGPoint(x: rc2.maxX, y: rc2.maxY))
                
             //   print("rc1: \(rc1), rc2: \(rc2)")
                withAnimation(.easeInOut) {
    
                    // Condition 2.1: 重叠在正下方,rc2向下移动
                    if topLeading && topTrailing {
                      //      print("condition 2.1")
                        rc2 = rc2.offsetBy(dx: 0, dy: 1)
                    }
                    // Condition 2.2: 重叠在右下方,rc2向右、下移动
                    else if topLeading && !topTrailing {
                      //     print("condition 2.2")
                        rc2 = rc2.offsetBy(dx: 0, dy: 1)
                    }
                    // Condition 2.3: 重叠在右方,rc2向右移动
                    else if topLeading && !topTrailing && bottomLeading {
                     //      print("condition 2.3")
                        rc2 = rc2.offsetBy(dx: 1, dy: 0)
                    }
                    // Condition 2.4: 重叠在右上方,rc2向右、上移动
                    else if !topLeading && bottomLeading {
                       //    print("condition 2.4")
                        rc2 = rc2.offsetBy(dx: 0, dy: -1)
                    }
                    // Condition 2.5: 重叠在上方,rc2向上移动
                    else if bottomLeading && bottomTrailing {
                     //       print("condition 2.5")
                        rc2 = rc2.offsetBy(dx: 0, dy: -1)
                    }
                    // Condition 2.6: 重叠在左上方,rc2向左、上移动
                    else if !bottomLeading && bottomTrailing && !topTrailing {
                      //      print("condition 2.6")
                        rc2 = rc2.offsetBy(dx: 0, dy: -1)
                    }
                    // Condition 2.7: 重叠在左方,rc2向左移动
                    else if !bottomLeading && bottomTrailing && topTrailing {
                     //      print("condition 2.7")
                        rc2 = rc2.offsetBy(dx: -1, dy: 0)
                    }
                    // Condition 2.8: 重叠在左下方,rc2向左、下移动
                    else if !bottomLeading && !bottomTrailing && topTrailing {
                      //      print("condition 2.8")
                        rc2 = rc2.offsetBy(dx: 0, dy: 1)
                    }
                    else {
                      //    print("condition else")
                        rc2 = rc2.offsetBy(dx: 0, dy: 1)
                    }
                    
                }
            }
        } while condition == 0
        
        print("==[out while]: rc1: \(rc1), rc2: \(rc2)")
        return true
    }
    
    // 循环比较是否有两个重叠的矩形
    func compareRC() {
        
        print("===== rect count : \(rectArray.count)")
        
        // do while ...
      //  for _ in 0..<20 {
            for i in 0..<rectArray.count {
                let left = rectArray[i]
                print("------ left rc \(i): \(left)")
                for j in (i + 1)..<rectArray.count {
                    let old = rectArray[j]
                    print("------ old \(j): \(old)")
                    if compare2Rects(rc1: left, rc2: &rectArray[j]) {
                        withAnimation(.linear) {
                            self.position[j].x = rectArray[j].minX - old.minX
                            self.position[j].y = rectArray[j].minY - old.minY
                        }
                        print("offset[\(j)]: \(self.position[j])")
                    }
                }
            }
     //   }
    }
}
