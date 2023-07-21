//
//  SwiftUIView.swift
//  
//
//  Created by Wttch on 2023/7/21.
//

import SwiftUI

#if os(OSX)
/// 自定义 Picker，自带的 Picker 无法自定义视图（或者自己不会），所以自定义一个。
public struct CustomPicker<T: Hashable & Identifiable, SelectionContent: View, Content: View, Label: View>: View {
    // 要渲染的数据
    let data: [T]
    // 绑定值
    @Binding var selection: T?
    // 选择项目的视图
    private var selectionContent: (T?) -> SelectionContent
    // 选择项目的视图
    private var content: (T?) -> Content
    // 标签
    private var label: Label
    // 是否展示选项弹框
    @State private var showPopover: Bool = false

    
    /// 默认构造函数
    /// - Parameters:
    ///   - data: 数据列表
    ///   - selection: 绑定值
    ///   - selectionContent: 已选择值的视图的闭包方法
    ///   - content: 项目渲染视图的闭包方法
    ///   - label: 标签
    public init(_ data: [T], selection: Binding<T?>,
                @ViewBuilder selectionContent: @escaping (T?) -> SelectionContent,
                @ViewBuilder content: @escaping (T?) -> Content,
                @ViewBuilder label: () -> Label) {
        self.data = data
        self._selection = selection
        self.selectionContent = selectionContent
        self.content = content
        self.label = label()
    }
    
    public var body: some View {
        HStack {
            label
            HStack {
                selectionContent(selection)
                Image(systemName: "chevron.down")
                    .rotationEffect(.radians(showPopover ? -.pi : 0))
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    showPopover.toggle()
                }
            }
            .popover(isPresented: $showPopover.animation(.spring()), attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                ScrollView {
                    VStack {
                        content(nil as T?)
                            .onTapGesture {
                                selection = nil
                                withAnimation(.spring()) {
                                    showPopover.toggle()
                                }
                            }
                        ForEach(data, content: { item in
                            content(item)
                                .onTapGesture {
                                    selection = item
                                    withAnimation(.spring()) {
                                        showPopover.toggle()
                                    }
                                }
                        })
                    }
                }
            })
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GeometryReader { geo in
                CustomPicker(datas, selection: .constant(Data(id: 1)),
                    selectionContent: { data in
                        Text("\(data?.id ?? -1)")
                    },
                    content: { i in
                        if let i = i {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.pink)
                                
                                Text("Data: \(i.id)")
                                    .font(.largeTitle)
                            }
                            .frame(maxHeight: 36)
                            .frame(minWidth: geo.size.width - 60)
                        } else {
                            Text("请选择")
                        }
                    }, label: {
                        Text("选择")
                    }
                )
            }
            Spacer()
        }
    }
}
#endif
