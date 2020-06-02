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
    private let disposeBag = DisposeBag()
    private let segueId = "success"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(ViewModel.Input(
            emailText: emailField.rx.text.orEmpty.asObservable(),
            passwordText: passwordField.rx.text.orEmpty.asObservable(),
            password2Text: passwordRepeatedField.rx.text.orEmpty.asObservable(),
            buttonTap: registerButton.rx.tap.asObservable()
        ))
        
        output.buttonIsEnabled.drive(registerButton.rx.isEnabled).disposed(by: disposeBag)
        output.messageIsHidden.drive(messageLabel.rx.isHidden).disposed(by: disposeBag)
        output.messageText.drive(messageLabel.rx.text).disposed(by: disposeBag)
        output.registerSuccessful.drive(onNext: goToSuccessScreen).disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    private func goToSuccessScreen() {
        performSegue(withIdentifier: segueId, sender: self)
    }
}
