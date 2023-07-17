//
//  SwiftUIView.swift
//  
//
//  Created by Wttch on 2023/7/13.
//

import SwiftUI

/// 在有限空间内，循环播放同一类型的图片、文字等内容。
///
/// 简单的视线：自动播放时暂时无法拖动（暂无处理方式），拖动时暂停自动播放。
public struct CarouselView<Content: View>: View {
    
    // 播放的所有视图
    private let content: [Content]
    
    private init(_ content: [Content]) {
        self.content = content
    }
    
    private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @State private var curIndex = 0
    // 定时器动画中
    @State private var timerAnimating = false
    // 拖动中
    @State private var draging = false
    // 拖动偏移
    @State private var dragValue: CGFloat = 0
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<content.count, id: \.self ,content: { id in
                    let item = content[id]
                    
                    item
                        .scaledToFill()
                        .background(Color.gray)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .offset(x: distance(id) * geo.size.width + dragValue)
                        .zIndex(Double(content.count) - abs(distance(id)))
                })
                
                VStack {
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<content.count, id: \.self, content: { index in
                            RoundedRectangle(cornerRadius: indicatorHeight / 2)
                                .fill(Color.white)
                                .opacity(index == curIndex ? 1 : 0.4)
                                .frame(width: indicatorWidth(geo), height: indicatorHeight)
                            // 手机太小，点不到
//                                .highPriorityGesture(TapGesture().onEnded({ _ in
//                                    draging = true
//                                    let duration = 0.1 * CGFloat(abs(curIndex - index))
//                                    withAnimation(.easeInOut(duration: duration)) {
//                                        self.curIndex = index
//                                    }
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + duration , execute: {
//                                        draging = false
//                                    })
//                                }))
                        })
                    }
                    .padding(.bottom, 8)
                }
                .zIndex(Double(content.count + 1))
            }
            .highPriorityGesture(DragGesture().onChanged({ value in
                if !timerAnimating {
                    draging = true
                    dragValue = value.translation.width
                }
            }).onEnded({ value in
                if draging {
                    // 左边划 正
                    // 右边划 负
                    let tWidth = value.translation.width
                    withAnimation(.spring()) {
                        if tWidth > 0 {
                            if tWidth > geo.size.width / 2 {
                                let next = curIndex - 1
                                curIndex = next != -1 ? next : content.count - 1
                            }
                        } else {
                            if abs(tWidth) > geo.size.width / 2 {
                                let next = curIndex + 1
                                curIndex = next % content.count
                            }
                        }
                        dragValue = 0
                        draging = false
                    }
                }
            }))
        }
        .onReceive(timer, perform: { _ in
            if !draging && !self.content.isEmpty {
                timerAnimating = true
                let duration = 0.3
                withAnimation(.linear(duration: duration)) {
                    self.curIndex += 1
                    self.curIndex %= self.content.count
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                    timerAnimating = false
                })
            }
        })
    }
    
    
    private func distance(_ id: Int) -> Double {
        if curIndex == 0 && id == self.content.count - 1 {
            return -1
        }
        
        if id == 0 && curIndex == self.content.count - 1 {
            return 1
        }
        
        return Double(id - curIndex)
    }
    
    // 指示器宽度
    private func indicatorWidth(_ geo: GeometryProxy) -> CGFloat {
        // return max(geo.size.width / (CGFloat(content.count) * 1.5) - 10, indicatorHeight)
        return indicatorHeight
    }
    // 指示器高度
    private var indicatorHeight: CGFloat {
        return 4
    }
}

public extension CarouselView {
    init<T>(_ data: [T], @ViewBuilder content: @escaping (T) -> Content ) {
        self.init(data.map({ content($0) }))
    }
    
    init(_ data: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.init(data.map({ content($0) }))
    }
}

struct CarouselView_Previews: PreviewProvider {
    private static var data: [Int] {
        var data = Array(repeating: 0, count: 10)
        for i in 0..<data.count {
            data[i] = i
        }
        return data
    }
    static var previews: some View {
        VStack {
            CarouselView(0..<10) { i in
                HStack(alignment: .center) {
                    Text("\(i)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 400, height: 200)
            .cornerRadius(16)
            
            CarouselView(data, content: { id in
                HStack {
                    Text("data: \(id)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
            .frame(width: 400, height: 200)
            .cornerRadius(16)
            
        }
        .bold()
        .font(.largeTitle)
        .foregroundColor(.orange)
    }
}
