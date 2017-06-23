//
//  HDDataPaymentSection.swift
//  TwoWayBind
//
//  Created by 洪东 on 22/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

struct HDDataPaymentSection {
    let selectPayment:Variable<HDModelPayment>
    init(defaultSelected: HDModelPayment) {
        selectPayment = Variable(defaultSelected)
    }
}

extension HDDataPaymentSection : Hashable {
    var hashValue: Int {
        return selectPayment.value.hashValue
    }
    
    static func ==(lhs: HDDataPaymentSection, rhs: HDDataPaymentSection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

extension HDDataPaymentSection : IdentifiableType {
    var identity : Int {
        return selectPayment.value.hashValue
    }
}
