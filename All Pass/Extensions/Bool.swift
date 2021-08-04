//
//  Bool.swift
//  All Keys
//
//  Created by Lam Nguyen on 7/11/21.
//

import Foundation
import UIKit

extension Bool{
    static func NOR (left: Bool, right: Bool) -> Bool {
        return !(left || right)
    }
}
