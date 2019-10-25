//
//  String+Extension.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

extension String {
    var unwrapped: String {
        let componenets = self.components(separatedBy: .whitespacesAndNewlines)
        return componenets.first ?? self
    }
    
    var toDateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self)!)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
