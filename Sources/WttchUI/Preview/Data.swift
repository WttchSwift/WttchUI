//
//  Data.swift
//  
//
//  Created by Wttch on 2023/7/21.
//

import Foundation
import SwiftUI

struct Data: Identifiable, Hashable {
    var id: Int
    
    var hashValue: Int {
        return id.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PreviewProvider {
    static var datas: [Data] { return [Data(id: 1), Data(id: 2), Data(id: 3)] }
}
