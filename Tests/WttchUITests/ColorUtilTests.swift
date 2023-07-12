//
//  ColorUtilTests.swift
//  
//
//  Created by Wttch on 2023/7/12.
//

import XCTest
@testable import WttchUI
import SwiftUI

final class ColorUtilTests: XCTestCase {
    func testColorFromHex() throws {
        // 测试 三位
        var color1 = ColorUtil.from(hex: "#F00")
        assert(color1.description == "#FF0000FF")
        
        var color2 = ColorUtil.from(hex: "#0F0")
        assert(color2.description == "#00FF00FF")
        
        var color3 = ColorUtil.from(hex: "#00F")
        assert(color3.description == "#0000FFFF")
        
        // 测试 四位 F
        color1 = ColorUtil.from(hex: "#F00F")
        assert(color1.description == "#FF0000FF")
        
        color2 = ColorUtil.from(hex: "#0F0F")
        assert(color2.description == "#00FF00FF")
        
        color3 = ColorUtil.from(hex: "#00FF")
        assert(color3.description == "#0000FFFF")
        
        // 测试 四位 A
        color1 = ColorUtil.from(hex: "#F000")
        assert(color1.description == "#FF000000")
        
        color2 = ColorUtil.from(hex: "#0F00")
        assert(color2.description == "#00FF0000")
        
        color3 = ColorUtil.from(hex: "#00F0")
        assert(color3.description == "#0000FF00")
        
        // 测试 六位
        color1 = ColorUtil.from(hex: "#FF0000")
        assert(color1.description == "#FF0000FF")
        
        color2 = ColorUtil.from(hex: "#00FF00")
        assert(color2.description == "#00FF00FF")
        
        color3 = ColorUtil.from(hex: "#0000FF")
        assert(color3.description == "#0000FFFF")
        
        // 测试 八位
        color1 = ColorUtil.from(hex: "#FF0000FF")
        assert(color1.description == "#FF0000FF")
        
        color2 = ColorUtil.from(hex: "#00FF00FF")
        assert(color2.description == "#00FF00FF")
        
        color3 = ColorUtil.from(hex: "#0000FFFF")
        assert(color3.description == "#0000FFFF")
        
        
        color1 = ColorUtil.from(hex: "#FF0000AA")
        assert(color1.description == "#FF0000AA")
        
        color2 = ColorUtil.from(hex: "#00FF00AA")
        assert(color2.description == "#00FF00AA")
        
        color3 = ColorUtil.from(hex: "#0000FFAA")
        assert(color3.description == "#0000FFAA")
    }
}
