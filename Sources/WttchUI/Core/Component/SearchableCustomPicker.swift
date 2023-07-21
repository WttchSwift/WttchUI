//
//  SearchableCustomPicker.swift
//  
//
//  Created by Wttch on 2023/7/21.
//

import SwiftUI
import Combine

#if os(OSX)

class SearchableCustomPickerViewModel: ObservableObject {
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
    
    private var title: (T?) -> String
    
    /// 默认构造函数
    /// - Parameters:
    ///   - data: 数据列表
    ///   - selection: 绑定值
    ///   - selectionContent: 已选择值的视图的闭包方法
    ///   - content: 项目渲染视图的闭包方法
    ///   - label: 标签
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
            .popover(isPresented: $showPopover.animation(.spring()), attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                ScrollView {
                    VStack {
                        content(nil as T?)
                            .onTapGesture {
                                selection = nil
                                withAnimation(.spring()) {
                                    showPopover.toggle()
                                }
                                textFieldFocus.toggle()
                            }
                        ForEach(data, content: { item in
                            content(item)
                                .onTapGesture {
                                    selection = item
                                    withAnimation(.spring()) {
                                        showPopover.toggle()
                                    }
                                    textFieldFocus.toggle()
                                }
                        })
                    }
                }
                .frame(maxHeight: 400)
            })
        }
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
