//
//  SearchableCustomPicker.swift
//  
//
//  Created by Wttch on 2023/7/21.
//

import SwiftUI
import Combine

#if os(OSX)


/// 可进行搜索、并自定义视图的 Picker
public struct SearchableCustomPicker<T: Hashable & Identifiable, Content: View, Label: View>: View {
    // 要渲染的数据
    let data: [T]
    // 绑定值
    @Binding var selection: T?
    // 选择项目的视图
    private var content: (T?) -> Content
    // 标签
    private var label: Label
    // 是否展示选项弹框
    @State private var showPopover: Bool = false
    
    @StateObject private var vm: SearchableCustomPickerViewModel
    @FocusState private var textFieldFocus: Bool
    // placehold
    private var title: (T?) -> String
    
    /// 默认构造函数
    /// - Parameters:
    ///   - data: 数据列表
    ///   - selection: 绑定值
    ///   - content: 项目渲染视图的闭包方法
    ///   - label: 标签
    ///   - searchCallback: 文本框数值改变时进行的回调函数
    public init(_ title: @escaping (T?) -> String,
                data: [T], selection: Binding<T?>,
                @ViewBuilder content: @escaping (T?) -> Content,
                @ViewBuilder label: () -> Label,
                searchCallback: @escaping (String) -> Void) {
        self.title = title
        self.data = data
        self._selection = selection
        self.content = content
        self.label = label()
        self._vm = StateObject(wrappedValue: SearchableCustomPickerViewModel(searchCallback))
    }
    
    public var body: some View {
        HStack {
            // 标签
            label
            
            ZStack {
                TextField(title(selection), text: $vm.searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($textFieldFocus)
                    .onChange(of: textFieldFocus) { newValue in
                        showPopover = newValue
                    }
                HStack {
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.radians(showPopover ? -.pi : 0))
                        .padding(.trailing, 8)
                }
            }
            // 弹窗, 向下弹出
            .popover(isPresented: $showPopover.animation(.spring()), attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                ScrollView {
                    VStack(spacing: 10) {
                        // 值为 nil 的视图
                        createContent(nil as T?)
                        ForEach(data, content: { createContent($0) })
                    }
                    .padding()
                }
                // 弹窗最大高度
                .frame(maxHeight: 400)
            })
        }
    }
    
    // 生成选项视图
    private func createContent(_ item: T?) -> some View {
        self.content(item)
            .onTapGesture {
                selection = item
                withAnimation(.spring()) {
                    showPopover.toggle()
                }
                textFieldFocus.toggle()
            }
    }
}


/// 包装 searchText 只是为了 debounce 去抖动
fileprivate class SearchableCustomPickerViewModel: ObservableObject {
    @Published var searchText: String = ""
    private var anyCancellables: [AnyCancellable] = []
    
    
    init(_ callback: @escaping (String) -> Void) {
        $searchText.debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { value in
                callback(value)
            }
            .store(in: &anyCancellables)
    }
}

struct SearchableCustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TextField("test", text: .constant("test value"))
            SearchableCustomPicker(
                { t in if let t = t { return "\(t.id)" } else { return "可以输入选择" } } ,
                data: datas, selection: .constant(Data(id: 1)), content: { data in
                Text("\(data?.id ?? -1)")
                    .font(.largeTitle)
                    .padding(.horizontal)
            }, label: { Text("选择") }, searchCallback: { print($0) })
            Spacer()
        }
    }
}
#endif
