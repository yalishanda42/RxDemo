//
//  String+isValdEmail.swift
//  RxDemo
//
//  Created by Alexander Ignatov on 31.05.20.
//  Copyright © 2020 Alexander Ignatov. All rights reserved.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        /* Thanks to https://stackoverflow.com/a/25471164 */
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
