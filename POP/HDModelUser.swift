//
//  HDModelUser.swift
//  POP
//
//  Created by Abner on 2017/6/24.
//  Copyright © 2017年 abner. All rights reserved.
//
// {"name":"abner","message":"Hello World!"}
// User.swift
import Foundation

struct HDModelUser {
    
    let name: String
    let message: String
    
    init?(data: Data) {
        
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        guard let name = obj?["name"] as? String else {
            return nil
        }
        guard let message = obj?["message"] as? String else {
            return nil
        }
        
        self.name = name
        self.message = message
        
    }
}
