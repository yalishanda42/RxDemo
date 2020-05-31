//
//  ViewModel.swift
//  RxDemo
//
//  Created by Alexander Ignatov on 30.05.20.
//  Copyright © 2020 Alexander Ignatov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    enum RegisterState {
        case initial
        case failure
        case success
    }
    
    // MARK: - Properties
    
    private lazy var networking = Networking.shared
    
    private let disposeBag = DisposeBag()
    
    private let messageSubject = BehaviorSubject<String>(value: "")
    private let registerStateSubject = BehaviorSubject<RegisterState>(value: .initial)
        
    // MARK: - Bindings
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let password2Text: Observable<String>
        let buttonTap: Observable<Void>
    }
    
    struct Output {
        let message: Driver<String>
        let messageIsHidden: Driver<Bool>
        let buttonIsEnabled: Driver<Bool>
        let registerSuccessful: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        requestHandler(input)
        handleInvalidInput(input)
        let isValid = inputIsValid(input)
        let buttonIsEnabled = isValid.asDriver(onErrorJustReturn: false)
        return Output(
            message: messageSubject.asDriver(onErrorJustReturn: ""),
            messageIsHidden: messageIsEmpty,
            buttonIsEnabled: buttonIsEnabled,
            registerSuccessful: registerSuccessful
        )
    }
}

private extension ViewModel {
    func requestHandler(_ input: Input) {
        input.buttonTap
            .withLatestFrom(
                Observable.combineLatest(
                    input.emailText,
                    input.passwordText
                )
            ).subscribe(onNext: sendRegisterRequest(email:pass:))
            .disposed(by: disposeBag)
    }
    
    func sendRegisterRequest(email: String, pass: String) {
        networking
            .registerUser(email: email, pass: pass)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.messageSubject.onNext("")
                    self?.registerStateSubject.onNext(.success)
                },
                onError: { [weak self] error in
                    self?.messageSubject.onNext((error as? Networking.APIError)?.localizedDescription ?? "Some error occured.")
                    self?.registerStateSubject.onNext(.failure)
                }
            ).disposed(by: disposeBag)
    }
    
    func inputIsValid(_ input: Input) -> Observable<Bool> {
        Observable
            .combineLatest(input.emailText, input.passwordText, input.password2Text)
            .map { email, pass1, pass2 in
                !email.isEmpty && !pass1.isEmpty && email.isValidEmail && pass1 == pass2
            }
    }
    
    func handleInvalidInput(_ input: Input) {
        Observable
            .combineLatest(input.emailText, input.passwordText, input.password2Text)
            .subscribe(onNext: { [unowned self] email, pass1, pass2 in
                if email.isEmpty {
                    self.messageSubject.onNext("Please fill in your e-mail.")
                } else if !email.isValidEmail {
                    self.messageSubject.onNext("Please provide a valid e-mail!")
                } else if pass1.isEmpty {
                    self.messageSubject.onNext("Please create a password.")
                } else if pass2.isEmpty {
                    self.messageSubject.onNext("Please type your password again.")
                } else if pass2 != pass1 {
                    self.messageSubject.onNext("Passwords should match!")
                } else {
                    self.messageSubject.onNext("")
                }
            }).disposed(by: disposeBag)
    }
    
    private var messageIsEmpty: Driver<Bool> {
        messageSubject.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
    }
    
    private var registerSuccessful: Driver<Void> {
        registerStateSubject
            .filter { $0 == .success}
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
    }
}

extension String {
    var isValidEmail: Bool {
        /* Thanks to https://stackoverflow.com/a/25471164 */
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
