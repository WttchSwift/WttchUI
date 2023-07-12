//
//  SwiftUIView.swift
//  
//
//  Created by Wttch on 2023/7/12.
//

import SwiftUI

public struct RangeSlider<Label, ValueLabel, V> : View where Label : View, ValueLabel : View, V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    private var value: Binding<ClosedRange<V>>
    private let bounds: ClosedRange<V>
    private let label: () -> Label
    private let minLabel: () -> ValueLabel
    private let maxLabel: () -> ValueLabel
    private let onEditingChanged: (Bool) -> Void

    @Environment(\.colorScheme) var colorScheme
    
    // 游标大小
    private let cursorWidth: CGFloat = 20
    private let axleCoordinateSpaceName = "axle"
    
    /// 默认私有构造函数。所有的扩展构造函数都是调用的该函数。
    /// 用给定的范围和提供的显示的标签创建一个可以选择一个范围的 RangeSlider。
    /// ⚠️: 使用时要保证 label、 minimumValueLabel、maximumValueLabel宽度不变, 不然重绘可能导致游标抖动。
    /// - Parameters:
    ///   - beginValue: 指定范围内选择的范围的下限
    ///   - endValue: 指定范围内选择的范围的上限
    ///   - bounds: 有效值的范围
    ///   - label: 描述实例目的的视图。并非所有滑块样式都显示标签，但即使在这些情况下，SwiftUI也使用标签进行可访问。例如，旁白使用标签来识别滑块的目的。
    ///   - minimumValueLabel: 一个描述 bounds.lowerBound 的视图
    ///   - maximumValueLabel: 一个描述 bounds.upperBound 的视图
    ///   - onEditingChanged: 当编辑开始和结束时的一个回调函数
    public init(
        value: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 100...200,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.bounds = bounds
        
        self.label = label
        self.minLabel = minimumValueLabel
        self.maxLabel = maximumValueLabel
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            label()
            
            minLabel()
                .font(.caption)
                .foregroundStyle(.tint)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    // 整个背景 bar
                    backgroundBar(proxy)
                    // 范围线 bar
                    rangeBar(proxy)
                    // 左游标
                    cursor(proxy, offsetX: minPosition(proxy)) { value in
                        self.setBoundLower(value.location.x, proxy: proxy)
                    }
                    // 右游标
                    cursor(proxy, offsetX: maxPosition(proxy)) { value in
                        self.setBoundUpper(value.location.x, proxy: proxy)
                    }
                }
                .coordinateSpace(name: axleCoordinateSpaceName)
            }
            .padding(.horizontal, 4)
            
            maxLabel()
                .font(.caption)
                .foregroundStyle(.tint)
        }
        .frame(height: 20)
    }
    // MARK: 视图
    private func backgroundBar(_ proxy: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .frame(height: 4)
            .foregroundStyle(.quaternary)
            .zIndex(0)
            .onTapGesture(
                coordinateSpace: .named(axleCoordinateSpaceName),
                perform: { value in
                    let lower = min(self.value.wrappedValue.lowerBound, bounds.value(percent: value.x / proxy.size.width))
                    let upper = max(self.value.wrappedValue.upperBound, bounds.value(percent: value.x / proxy.size.width))
                    self.value.wrappedValue = lower...upper
            })
    }
    
    private func rangeBar(_ proxy: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.tint)
            .frame(height: 4)
            .frame(width: maxPosition(proxy) - minPosition(proxy))
            .offset(x: minPosition(proxy))
            .foregroundColor(.white.opacity(0.1))
            .zIndex(1)
    }
    
    // 游标
    private func cursor(_ proxy: GeometryProxy, offsetX: CGFloat, onChanged: @escaping (DragGesture.Value) -> Void) -> some View {
        return Circle()
            .frame(width: cursorWidth, height: cursorWidth)
            .foregroundStyle(colorScheme == .dark ? .gray : .white)
            .shadow(radius: 16)
            .offset(x: offsetX - cursorWidth / 2)
            .zIndex(10)
            .gesture(
                DragGesture(coordinateSpace: .named(axleCoordinateSpaceName))
                    .onChanged { value in
                        // 防抖
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                            onChanged(value)
                        })
                    }
                    .onEnded({ _ in
                        onEditingChanged(false)
                    })
            )
    }
    
    // MARK: 属性计算
    // 小值百分比
    private var lowerPercent: CGFloat {
        return bounds.percent(value: value.wrappedValue.lowerBound)
    }
    // 大值百分比
    private var upperPercent: CGFloat {
        return bounds.percent(value: value.wrappedValue.upperBound)
    }
    // 小值游标位置
    private func minPosition(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width * lowerPercent
    }
    
    // 大值游标位置
    private func maxPosition(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width * upperPercent
    }
    
    /// 设置范围数值的下限
    /// - Parameters:
    ///   - value: 数值位置
    ///   - proxy: GeometryProxy
    private func setBoundLower(_ value: CGFloat, proxy: GeometryProxy) {
        // 最小为位置 0
        let percent: CGFloat = max(value, 0) / proxy.size.width
        let newValue = bounds.value(percent: percent)
        // 不能超过大值 百分比
        let lowerBound = min(newValue, self.value.wrappedValue.upperBound)
        let upperBound = self.value.wrappedValue.upperBound
        self.value.wrappedValue = lowerBound...upperBound
        onEditingChanged(true)
    }
    
    /// 设置范围数值的上限
    /// - Parameters:
    ///   - value: 数值位置
    ///   - proxy: GeometryProxy
    private func setBoundUpper(_ value: CGFloat, proxy: GeometryProxy) {
        // 最大位置为 1
        let percent: CGFloat = min(value, proxy.size.width) / proxy.size.width
        let newValue = bounds.value(percent: percent)
        // 不小于小值 百分比
        let upperBound = max(newValue, self.value.wrappedValue.lowerBound)
        let lowerBound = self.value.wrappedValue.lowerBound
        self.value.wrappedValue = lowerBound...upperBound
        onEditingChanged(true)
    }
    

}

// 为 ClosedRange 扩展一些属性和方法
private extension ClosedRange where Bound: BinaryFloatingPoint {
    /// 范围的长度
    var range: Bound {
        return upperBound - lowerBound
    }
    
    
    /// 根据百分比计算数值的大小
    /// - Parameter percent: 给定百分比的位置
    /// - Returns: 百分比位置所在的数值
    func value(percent: CGFloat) -> Bound {
        return Bound(percent) * range + lowerBound
    }
    
    /// 计算数值在范围中的百分比
    /// - Parameter value: 给定的数值
    /// - Returns: 数值在范围中的百分比位置
    func percent(value: Bound) -> CGFloat {
        return CGFloat((value - lowerBound) / range)
    }
}

// MARK: 扩展
// 对指定类型进行扩展
extension RangeSlider where Label == EmptyView, ValueLabel == EmptyView, V: BinaryFloatingPoint {
    /// 创建一个可以选择一个范围的 RangeSlider
    /// - Parameters:
    ///   - beginValue: 指定范围内选择的范围的下限
    ///   - endValue: 指定范围内选择的范围的上限
    ///   - bounds: 有效值的范围
    ///   - onEditingChanged: 当编辑开始和结束时的一个回调函数
    public init(
        value: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 0...1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            label: { EmptyView() },
            minimumValueLabel: { EmptyView() },
            maximumValueLabel: { EmptyView() },
            onEditingChanged: onEditingChanged
        )
    }
}

extension RangeSlider where ValueLabel == EmptyView, V: BinaryFloatingPoint {
    
    /// 用给定的范围和提供的显示的标签创建一个可以选择一个范围的 RangeSlider
    /// ⚠️: 使用时要保证 label 宽度不变, 不然重绘可能导致游标抖动。
    /// - Parameters:
    ///   - beginValue: 指定范围内选择的范围的下限
    ///   - endValue: 指定范围内选择的范围的上限
    ///   - bounds: 有效值的范围
    ///   - label: 描述实例目的的视图。并非所有滑块样式都显示标签，但即使在这些情况下，SwiftUI也使用标签进行可访问。例如，旁白使用标签来识别滑块的目的。
    ///   - onEditingChanged: 当编辑开始和结束时的一个回调函数
    public init(
        value: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 100...200,
        @ViewBuilder label: @escaping () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in })
    where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            label: label,
            minimumValueLabel: { EmptyView() },
            maximumValueLabel: { EmptyView() },
            onEditingChanged: onEditingChanged
        )
    }
}


// MARK: 预览
struct RangeSlider_Preview: PreviewProvider {
    
    private struct Wrapper: View {
        @State private var value: CGFloat = 3000
        @State private var rangedValue: ClosedRange<CGFloat> = 3000...10000
        var body: some View {
            VStack {
                Slider(
                    value: $value,
                    in: 2000...12000,
                    // step: 2,
                    label: { Text("\(value)") },
                    minimumValueLabel: { Text("Min") },
                    maximumValueLabel: { Text("Max") }) { value in
                    }
                
                RangeSlider(
                    value: $rangedValue,
                    in: 2000...12000,
                    label: { EmptyView() }, minimumValueLabel: { EmptyView() }, maximumValueLabel: { EmptyView() }
                )


                RangeSlider(
                    value: $rangedValue,
                    in: 2000...12000,
                    label: {
                        Text("Label")
                    }
                )

                HStack {
                    Text("\(Int(rangedValue.lowerBound))")
                    RangeSlider(
                        value: $rangedValue,
                        in: 2000...12000,
                        label: {
                            Text("Label")
                        }, minimumValueLabel: {
                            Text("Min")
                        }, maximumValueLabel: {
                            Text("Max")
                        })
                    Text("\(Int(rangedValue.upperBound))")
                }

                RangeSlider(
                    value: $rangedValue,
                    in: 2000...12000,
                    label: {
                        Text("Label")
                    }, minimumValueLabel: {
                        Text("\(Int(rangedValue.lowerBound))")
                    }, maximumValueLabel: {
                        Text("\(Int(rangedValue.upperBound))")
                    })
            }
            .tint(.pink)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
    
}
