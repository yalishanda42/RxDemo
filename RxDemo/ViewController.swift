//
//  ViewController.swift
//  RxDemo
//
//  Created by Alexander Ignatov on 30.05.20.
//  Copyright © 2020 Alexander Ignatov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var passwordRepeatedField: UITextField!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var messageLabel: UILabel!
    
    // MARK: - Properties
    
    private let viewModel = ViewModel()
    private let segueId = "success"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Add bindings
    }
    
    // MARK: - Helpers
    
    private func goToSuccessScreen() {
        performSegue(withIdentifier: segueId, sender: self)
    }
}
