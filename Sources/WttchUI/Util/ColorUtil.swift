//
//  ColorUtil.swift
//  
//
//  Created by Wttch on 2023/7/12.
//

import Foundation
import SwiftUI

public class ColorUtil {
    /// 将十六进制颜色字符串转换为颜色。
    ///
    /// 只处理 3、4、6、8位长度的颜色串，可以在字符串前添加 `#`符号。
    ///
    /// `FFF`，`#FFF`，`FFFF`，`#FFFF`，`FFFFFF`，`#FFFFFF`，`FFFFFFFF`，`#FFFFFFFF`。
    ///
    /// ⚠️：如果字符串无法处理，则返回默认颜色 `Color.white`。
    ///
    /// - Parameter hexString: 颜色字符串
    /// - Returns: 十六进制颜色字符串转换的颜色
    public static func from(hex hexString: String) -> Color {
        // 移除空格
        var string: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        guard string.count <= 8 else { return .white }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        // 三个十六进制字符
        // #RGB
        if string.count == 3 {
            let mask = 0x00F
            let r = Int(color >> 8) & mask
            let g = Int(color >> 4) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 15.0
            let green = Double(g) / 15.0
            let blue = Double(b) / 15.0
            
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        }
        // 四个十六进制字符
        // #RGBA
        if string.count == 4 {
            let mask = 0x000F
            
            let r = Int(color >> 12) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color >> 4) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 15.0
            let green = Double(g) / 15.0
            let blue = Double(b) / 15.0
            let alpha = Double(a) / 15.0

            return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        }
        // 六个十六进制字符
        // #RRGGBB
        if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        }
        // 八个十六进制
        // #RRGGBBAA
        if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        }
        
        return .white
    }
}

public extension Color {
    /// 将十六进制颜色字符串转换为颜色。
    ///
    /// 只处理 3、4、6、8位长度的颜色串，可以在字符串前添加 `#`符号。
    ///
    /// 例如：`FFF`，`#FFF`，`FFFF`，`#FFFF`，`FFFFFF`，`#FFFFFF`，`FFFFFFFF`，`#FFFFFFFF`。
    /// 
    /// ⚠️：如果字符串无法处理，则返回默认颜色 `Color.white`。
    ///
    /// - Parameter hexString: 颜色字符串
    init(hex hexString: String) {
        self = ColorUtil.from(hex: hexString)
    }
}


struct ColorUtil_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("测试颜色")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(hex: "#FA00FB8A"))
        }
    }
}
