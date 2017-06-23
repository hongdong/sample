//
//  HDModelProduct.swift
//  sample
//
//  Created by 洪东 on 21/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

struct HDModelProduct {
    let id: Int
    let name: String
    let unitPrice: Int
    let count: Variable<Int>
}

extension HDModelProduct: Hashable {
    
    var hashValue: Int {
        return id.hashValue
    }
    
    public static func ==(lhs: HDModelProduct, rhs: HDModelProduct) -> Bool{
        return lhs.id == rhs.id
    }

}

extension HDModelProduct: IdentifiableType {
    
    var identity: Int {
        return id.hashValue
    }
    
}
