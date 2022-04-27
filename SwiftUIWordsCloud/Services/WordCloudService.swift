//
//  WordCloudService.swift
//  SwiftUIWordsCloud
//
//  Created by Chr1s on 2022/1/27.
//

import Foundation
import SwiftUI
import Combine

protocol WordCloudServiceProtocol {
    
    // 词云权重
    var weight: Int { get set }
    // 词云数据
    var words: [WordModel] { get set }
    // 词云初始矩形
    var rects: [CGRect] { get set }
    
    // 更新词云每个单词的矩形区域
  //  func updateRects(_ index: Int, rc: CGRect)
    func updateRects(_ index: Int, rc: CGRect) -> AnyPublisher<(Int, CGPoint), Never> 

    
    // 在主词云区域(rects[0])内获取随机点，返回偏移量点坐标
    func getRandomPointInRect() -> AnyPublisher<[CGPoint], Never>
    func getRandomPointInRectLine() -> AnyPublisher<[CGPoint], Never>
    func getRandomPointInRect2() -> AnyPublisher<[CGPoint], Never>

    // 判断是否有重叠或相交的两个矩形
    func move() -> AnyPublisher<[CGPoint], Never>
    
    func showWholeRects() 
    
}

class WordCloudService: WordCloudServiceProtocol {
    
    var weight: Int
    var words: [WordModel]
    var rects: [CGRect] = []
    var oldrects: [CGRect] = []
    var majorRect: CGRect = .zero

    
    init(weight: Int = 5, words: [WordModel]) {
        self.weight = weight
        self.words = words
        self.rects = [CGRect]( repeating: .zero, count: words.count)
        self.oldrects = [CGRect]( repeating: .zero, count: words.count)

    }
    
    func updateRects(_ index: Int, rc: CGRect) {
        self.rects[index] = rc
        print("+++ [service] rects[\(index)]: \(self.rects[index])")
        print("+++ whole rects: \(self.rects)")
        if index == 0 {
            self.majorRect = rc
        }
    }
    
    func showWholeRects() {
        print("")
        print("+++ whole rects: \(self.rects)")
        print("")
    }
    
    func updateRects(_ index: Int, rc: CGRect) -> AnyPublisher<(Int, CGPoint), Never> {
        
        guard  rc.width != 0 && rc.height != 0 else {
            return Just((0,.zero)).eraseToAnyPublisher()
        }
        self.rects[index] = rc
        print("")
        print("+++ Update Rects ++++")
        print("+++ [service] rects[\(index)]: \(self.rects[index])")
        print("+++ whole rects: \(self.rects)")
        if index == 0 {
            self.majorRect = rc
        }
        
        var moveIndex: Int = 0
         
        // 循环判断放置此视图到哪个点
        for i in stride(
            from: 0.0,//Double(index) * 0.1 * Double.pi,
            to: Double.pi * 20.0,
            by: 0.08 * Double.pi) {
            
            print("i = \(i)")
          
            // 如果交叠
            if isOverlap(index: index) {
                // 计算当前点的x、y坐标(偏移量)
                let dx = (0 + 0.8 * i) * cos(i)
                let dy = (2 + 0.8 * i) * sin(i)
                self.rects[index] = self.rects[index].offsetBy(dx: dx, dy: dy)
                
                continue
            } else {
                break
            }
        }
        
//        if moveIndex != -1 {
//            print("得到 \(moveIndex): \(self.rects[moveIndex])")
//
//            let p = CGPoint(
//                x: Int(self.rects[index].midX - rc.midX),
//                y: Int(self.rects[index].midY - rc.midY))
//            print("\r\n p: \(p) \r\n")
//            return Just((index, p)).eraseToAnyPublisher()
//        } else {
//            return Just((0, .zero)).eraseToAnyPublisher()
//        }
        print("得到 \(index): \(self.rects[index])")
        
        let p = CGPoint(
            x: Int(self.rects[index].midX - rc.midX),
            y: Int(self.rects[index].midY - rc.midY))
        print("\r\n p: \(p) \r\n")
        return Just((index, p)).eraseToAnyPublisher()
        
    }
    
    // 是否有重叠的矩形
    // true: 有重叠  false: 无重叠
//    func isOverlap(rc: CGRect) -> Bool {
//        for i in 0..<words.count {
//
//            if rects[i] == .zero {
//                continue
//            }
//
//            let result = rects[i].intersection(rc)
//            print("比较 : \(rc)")
//            print("rects[\(i)]: \(rects[i])")
//            if result.isNull {
//                print("不相交,continue")
//                continue
//            } else {
//                print("相交")
//                return true
//            }
//        }
//        print("最后判定不相交")
//        return false
//    }
    
   //  序号为index的View是否与其他View有交集
    func isOverlap(index: Int) -> Bool {
        for i in 0..<words.count {

            if rects[i] == .zero {
                continue
            }

            if index == i {
                continue
            }

            let result = rects[i].intersection(rects[index])
            print("比较 : \(rects[index])")
            print("rects[\(i)]: \(rects[i])")
            if result.isNull {
                print("不相交,continue")
                continue
            } else {
                print("相交")
                return true
            }
        }
        print("最后判定不相交")
        return false
    }
//
    // 序号为index的View是否与其他View有交集，有交集返回需要移动的View的序号
//    func isOverlap(index: Int) -> Int {
//        for i in 0..<words.count {
//
//            if rects[i] == .zero {
//                continue
//            }
//
//            if index == i {
//                continue
//            }
//
//            let result = rects[i].intersection(rects[index])
//            print("比较 : \(rects[index])")
//            print("rects[\(i)]: \(rects[i])")
//            if result.isNull {
//                print("不相交,continue")
//                continue
//            } else {
//                print("相交")
//                return (i >= index ) ? i : index
//            }
//        }
//        print("最后判定不相交")
//        return -1
//    }
    
    func spiral(rc1: CGRect, rc2: inout CGRect) -> CGPoint {
        
        var condition: Int = 1
        var dx: CGFloat = 0.0
        var dy: CGFloat = 0.0
        var r:CGFloat = 1.0
        var w: CGFloat = 1.0
        var t: CGFloat = 0.0
        var θ: CGFloat = 0.0
        
        var p: CGPoint = .zero
        var rcold: CGRect = rc2

        
        repeat {
            
            let rc = rc1.intersection(rc2)
            if rc.isNull {
                p.x = rc2.midX - rcold.midX
                p.y = rc2.midY - rcold.midY
                condition = 0
            } else {
                
                /*
                 x=r∗cosθ
                 y=r∗sinθ
                 */
//                t += 1.5
//                θ += t
//                dx = r * cos(θ)
//                dy = r * sin(θ)
                
                θ += 0.01 * Double.pi
                dx = (2+4.1 * θ) * cos(θ)
                dy = (2+4.1 * θ) * sin(θ)
                rc2 = rc2.offsetBy(dx: dx, dy: dy)
                
                /*
                 x=(a+b∗θ)∗cosθ
                 y=(a+b∗θ)∗sinθ
                 a = 1
                 b = 0.1
                 */
//                θ += 0.5 * Double.pi
//                dx = (2.0 + 0.1 * θ) * cos(θ)
//                dx = (2.0 + 0.1 * θ) * sin(θ)
//                rc2 = rc2.offsetBy(dx: dx, dy: dy)
                
            }
            
        } while condition == 1
        
        return p
    }
    
    func move() -> AnyPublisher<[CGPoint], Never> {
     
        var points: [CGPoint] = [CGPoint]( repeating: .zero, count: words.count)
        
       // var rcold: [CGRect] = self.rects
        
      //  for _ in 0..<100 {
            for i in 0..<self.rects.count {
                let left = rects[i]
                for j in (i + 1)..<rects.count {
                    print("")
                    print("比较: \(words[i].text) \(left) \r\n, \(words[j].text) \(rects[j])")
                 //   let p = moveUntilNoIntersection(rc1: left, rc2: &rects[j])
                    spiral(rc1: left, rc2: &rects[j])
                    
                    print(" --- : \(words[j].text) \(rects[j])")
    //                points[j] = moveUntilNoIntersection(rc1: left, rc2: &rects[j])
    //
    //                // ** 循环会导致本来计算好的偏移又变为0.0
    //                print("points[\(j)] = \(points[j])")
                }
            }
    //    }
        
        for i in 1..<self.rects.count {
            print("-- getoffset: \(self.rects[i]), \(oldrects[i])")
          //  points[i] = getOffset(rc1: self.rects[i], rc2: oldrects[i])
            points[i] = getOffset(rc: self.rects[i])
            print("points[\(i)] = \(points[i])")
        }
        
        print(" ============= ")
        for i in 0..<self.rects.count {
            print("old[\(i)] = \(oldrects[i])")
            print("rects[\(i)] = \(rects[i])")
            print("points[\(i)] = \(points[i])")
        }
        print(" ============= ")

        
        return Just(points).eraseToAnyPublisher()
    }
    
    // 根据新旧CGRect计算偏移量
    func getOffset(rc1: CGRect, rc2: CGRect) -> CGPoint {
        return CGPoint(x: rc1.midX - rc2.midX, y: rc1.midY - rc2.midY)
    }
    
    func getOffset(rc: CGRect) -> CGPoint {
        return CGPoint(x: rc.midX - self.majorRect.midX, y: rc.midY - self.majorRect.midY)
    }
    
    // 在主词云View的上边和下边上随机取点
    func getRandomPointInRectLine() -> AnyPublisher<[CGPoint], Never> {
        
        let rc = rects[0]
        var position: [CGPoint] = [CGPoint]( repeating: .zero, count: words.count)
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0

        for i in 1..<words.count {
            // 在主词云view上边和下边随机取点
            x = CGFloat.random(in: (rc.minX)..<(rc.maxX))
            // 偶数取上边，奇数取下边
            y = (i % 2 == 0) ? rc.minY : rc.maxY
      
            print("--- Random Place Rect ---- ")
            print("--- [\(i)] point: x \(x), y \(y)")
            
            var offsetX: CGFloat = 0.0
            var offsetY: CGFloat = 0.0
            
            // 如果是偶数点，此View的左下角点位移到上边上的随机点
            if i % 2 == 0 {
                offsetX = x - rc.midX
                offsetY = y - rects[0].midY - rects[i].height / 2 - 5
            } else {
                offsetX = x - rc.midX
                offsetY = y - rects[0].midY + rects[i].height / 2 + 5
            }
            
            self.rects[i] = self.rects[i].offsetBy(
                dx: offsetX ,
                dy: offsetY
            )

            // 计算当前View移动到 以随机点为中点的View的偏移量
            // 此方式为移动新rc的中心点到随机点，可以尝试改为移动新rc的顶点到随机点
//            let offsetX = x - rects[0].midX
//            let offsetY = y - rects[0].midY
//            self.rects[i] = self.rects[i].offsetBy(
//                dx: offsetX ,
//                dy: offsetY
//            )
            // 计算offset
              //  withAnimation(.easeInOut) {
                    position[i] = CGPoint(x: offsetX, y: offsetY)
              //  }
        
            print("--- place pos: \(position[i])")
            print("--- place rec: \(self.rects[i])")
        }
        return Just(position).eraseToAnyPublisher()
    }
    
    func getRandomPointInRect2() -> AnyPublisher<[CGPoint], Never> {
        
        var position: [CGPoint] = [CGPoint]( repeating: .zero, count: words.count)
        let rc = rects[0]
        let range = (
            Int(rc.minX)..<Int(rc.maxX),
            Int(rc.minY)..<Int(rc.maxY)
        )
        
        for i in 1..<words.count {

            let x = Int.random(in: range.0)
            let y = Int.random(in: range.1)

            // 计算当前View移动到 以随机点为中点的View的偏移量
            let offsetX = CGFloat(x) - rects[0].midX
            let offsetY = CGFloat(y) - rects[0].midY
            self.rects[i] = self.rects[i].offsetBy(
                dx: offsetX ,
                dy: offsetY
            )
            // 计算offset
            position[i] = CGPoint(x: offsetX, y: offsetY)
        }
        return Just(position).eraseToAnyPublisher()

    }
    
    /// 获取矩形内随机点并将词云View放置到随机点
    /// - Output为[CGPoint]的Publisher
    ///  [CGPoint]为词云View放置到随机点时Offset所需的偏移量
    func getRandomPointInRect() -> AnyPublisher<[CGPoint], Never> {
        
        var position: [CGPoint] = [CGPoint]( repeating: .zero, count: words.count)
        let rc = rects[0]
        oldrects = rects

        // 左中区域
        let leftRange: (Range<Int>, Range<Int>) =
            (
                Int(rc.minX)..<Int(rc.minX + (rc.width / 4)),
                Int(rc.minY + rc.height / 4)..<Int(rc.minY + rc.height * 3 / 4 )
            )
        // 上区域
        let topRange: (Range<Int>, Range<Int>) =
            (
                Int(rc.minX)..<Int(rc.maxX),
                Int(rc.minY)..<Int( rc.minY + rc.height / 4)
            )
        // 下区域
        let bottomRange: (Range<Int>, Range<Int>) =
            (Int(rc.minX)..<Int(rc.maxX),
             Int(rc.midY + (rc.midY - rc.minY) / 2 )..<Int(rc.maxY)
            )
        
        guard !words.isEmpty else { return Just([]).eraseToAnyPublisher() }

        print("words.count = \(words.count)")
        // 随机取点并分配位置
        for i in 1..<words.count {

            var r: (Range<Int>, Range<Int>)
            
            if i < 2 {
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

            print("--- Random Place Rect ---- ")
            print("--- [\(i)] . range: \(r)")
            print("--- random point: x \(x), y \(y)")

            // 计算当前View移动到 以随机点为中点的View的偏移量
            let offsetX = CGFloat(x) - rects[0].midX
            let offsetY = CGFloat(y) - rects[0].midY
            self.rects[i] = self.rects[i].offsetBy(
                dx: offsetX ,
                dy: offsetY
            )
            // 计算offset
            position[i] = CGPoint(x: offsetX, y: offsetY)
            print("--- place pos: \(position[i])")
            print("--- place rec: \(self.rects[i])")

        }
        
        return Just(position).eraseToAnyPublisher()
    }
  
    // 判断两个View是否有重叠部分
    func moveUntilNoIntersection(rc1: CGRect, rc2: inout CGRect) -> CGPoint {
        
        
        var p: CGPoint = .zero
        var rcold: CGRect = rc2
        var condition: Int = 0

        repeat {
            let rc = rc1.intersection(rc2)
            if rc.isNull {
                p.x = rc2.midX - rcold.midX
                p.y = rc2.midY - rcold.midY
                print(" ")
                print("rc1:\(rc1) rc2:\(rc2) 不重叠")
                print("rc2old: \(rcold) p: \(p)")
                print(" ")

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
                
               // let rightCondition = rc2.minX > rc1.minX
                
             //   print("rc1: \(rc1), rc2: \(rc2)")
                    // Condition 1: rc1包含rc2
                    if rc1.contains(rc2) {

                        print("rc1 包含 rc2")
                        
                        rc2 = rc2.offsetBy(dx: 0, dy: (rc2.midY == self.majorRect.minY) ? -1 : 1)
                        // 根据rc1中心点和rc2中心点设定直线方程,让rc2沿直线方程移动出rc1
//                        rc2 = rc2.offsetBy(
//                            dx: 1,
//                            dy: getYinLine(
//                                pt1: CGPoint(x: rc1.midX, y: rc1.midY),
//                                pt2: CGPoint(x: rc2.midX, y: rc2.midY),
//                                x: 1)
//                        )
//                        print("rc2: \(rc2)")

                    }
                    // Condition 2: rc1不包含rc2，但有重叠部分
                    else {
                        
                        // 右移动
                        if rc2.minX > rc1.minX {
                            print("右移动")
                            rc2 = rc2.offsetBy(dx: 1, dy: 0)
                        } else {
                            print("左移动")

                            rc2 = rc2.offsetBy(dx: -1, dy: 0)
                        }
//                        // Condition 2.1: 重叠在正下方,rc2向下移动
//                        if topLeading && topTrailing {
//                            print("condition 2.1")
//                            rc2 = rc2.offsetBy(dx: 0, dy: 1)
//                        }
//                        // Condition 2.2: 重叠在右下方,rc2向右、下移动
//                        else if topLeading && !topTrailing {
//                            print("condition 2.2")
//                            rc2 = rc2.offsetBy(dx: 0, dy: 1)
//                        }
//                        // Condition 2.3: 重叠在右方,rc2向右移动
//                        else if topLeading && !topTrailing && bottomLeading {
//                            print("condition 2.3")
//
//                            rc2 = rc2.offsetBy(dx: 1, dy: 0)
//                        }
//                        // Condition 2.4: 重叠在右上方,rc2向右、上移动
//                        else if !topLeading && bottomLeading {
//                            print("condition 2.4")
//
//                            rc2 = rc2.offsetBy(dx: 0, dy: -1)
//                        }
//                        // Condition 2.5: 重叠在上方,rc2向上移动
//                        else if bottomLeading && bottomTrailing {
//                            print("condition 2.5")
//
//                            rc2 = rc2.offsetBy(dx: 0, dy: -1)
//                        }
//                        // Condition 2.6: 重叠在左上方,rc2向左、上移动
//                        else if !bottomLeading && bottomTrailing && !topTrailing {
//                            print("condition 2.6")
//
//                            rc2 = rc2.offsetBy(dx: 0, dy: -1)
//                        }
//                        // Condition 2.7: 重叠在左方,rc2向左移动
//                        else if !bottomLeading && bottomTrailing && topTrailing {
//                            print("condition 2.7")
//
//                            rc2 = rc2.offsetBy(dx: -1, dy: 0)
//                        }
//                        // Condition 2.8: 重叠在左下方,rc2向左、下移动
//                        else if !bottomLeading && !bottomTrailing && topTrailing {
//                            print("condition 2.8")
//
//                            rc2 = rc2.offsetBy(dx: 0, dy: 1)
//                        }
//                        else {
//                          print("condition else")
//
//                            rc2 = rc2.offsetBy(dx: 0, dy: 1)
//                        }
                }
                
            }
        } while condition == 0
        
        return p
    }
    
    // 根据两点直线方程，计算给定x值的对应的y
    func getYinLine(pt1: CGPoint, pt2: CGPoint, x: CGFloat) -> CGFloat {
        let y = ((x - pt1.x) / (pt2.x - pt1.x) * (pt2.y - pt1.y)) + pt1.y
        print("y : \(y)")
        return y
    }
   
}

// 循环比较是否有两个重叠的矩形
//func compareRC() {
//
//    // do while ...
//    for _ in 0..<20 {
//        for i in 0..<.count {
//            let left = rectArray[i]
//            for j in (i + 1)..<rectArray.count {
//                if compare2Rects(rc1: left, rc2: &rectArray[j]) {
//                    withAnimation(.linear) {
//                        self.offset[j].x = rectArray[j].minX
//                        self.offset[j].y = rectArray[j].minY
//                    }
//               //     print("offset[\(j)]: \(self.offset[j])")
//                }
//            }
//        }
//    }
//}
//}
