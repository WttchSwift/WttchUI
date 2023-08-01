//
//  SearchablePicker.swift
//  
//
//  Created by Wttch on 2023/7/24.
//

import SwiftUI
import Combine

#if os(OSX)


/// 可进行搜索、并自定义视图的 Picker
public struct SearchablePicker<Content: View, Label: View>: View {
    // 是否展示选项弹框
    @Binding private var showPopover: Bool
    // 选择项目的视图
    private var content: Content
    // 标签
    private var label: Label
    private var title: String
    private var searchCallback: (String) -> Void
    // 搜索文本
    @State private var searchText: String = ""
    private let searchTextPublisher = PassthroughSubject<String, Never>()
    @FocusState private var textFieldFocus: Bool

    public init(showPopover: Binding<Bool>, content: @escaping () -> Content, label: Label,
                title: String,
                searchCallback: @escaping (String) -> Void) {
        self._showPopover = showPopover
        self.content = content()
        self.label = label
        self.title = title
        self.searchCallback = searchCallback
    }
    
    public var body: some View {
        HStack {
            // 标签
            label
            
            ZStack {
                TextField(title, text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($textFieldFocus)
                    .disabled(!showPopover)
                    .onChange(of: textFieldFocus) { newValue in
                        searchCallback(searchText)
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
                content
                    .padding()
            })
        }
        .background()
        .onTapGesture {
            showPopover = true
            textFieldFocus = true
        }
        .onChange(of: searchText, perform: { newValue in
            searchTextPublisher.send(newValue)
        })
        .onChange(of: showPopover, perform: { newValue in
            if !newValue {
                self.textFieldFocus = false
            }
        })
        .onReceive(searchTextPublisher.debounce(for: .seconds(1), scheduler: DispatchQueue.main), perform: { newValue in
            searchCallback(newValue)
        })
    }
}

struct SearchablePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SearchablePicker(showPopover: .constant(true), content: {
                ScrollView {
                    ForEach(datas) { data in
                        Text("Data:\(data.id)")
                    }
                }
                .frame(width: 200, height: 400)
            }, label: Text("选择"), title: "可以搜索", searchCallback: { newValue in
                print(newValue)
            })
            SearchablePicker(showPopover: .constant(true), content: {
                ScrollView {
                    ForEach(datas) { data in
                        Text("Data:\(data.id)")
                    }
                }
                .frame(width: 200, height: 400)
            }, label: Text("选择1"), title: "可以搜索1", searchCallback: { newValue in
                print(newValue)
            })
            Spacer()
        }
    }
}
#endif
