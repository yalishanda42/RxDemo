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
    
    // MARK: - Properties
    
    private lazy var networking = Networking.shared
    
    private let disposeBag = DisposeBag()
    
    private let messageSubject = BehaviorSubject<String>(value: "")
    private let registerEventSubject = PublishSubject<Void>()
        
    // MARK: - Bindings
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let password2Text: Observable<String>
        let buttonTap: Observable<Void>
    }
    
    struct Output {
        let messageText: Driver<String>
        let messageIsHidden: Driver<Bool>
        let buttonIsEnabled: Driver<Bool>
        let registerSuccessful: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        handleValidInputMessage(input)
        handleRegisterButtonTap(input)
        
        return Output(
            messageText: messageText,
            messageIsHidden: messageIsEmpty,
            buttonIsEnabled: inputIsValid(input),
            registerSuccessful: registerSuccessful
        )
    }
}

// MARK: - Helpers

private extension ViewModel {
    var messageText: Driver<String> {
        messageSubject.asDriver(onErrorJustReturn: "")
    }
    
    var messageIsEmpty: Driver<Bool> {
        messageText.map { $0.isEmpty }
    }
    
    var registerSuccessful: Driver<Void> {
        registerEventSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    func inputIsValid(_ input: Input) -> Driver<Bool> {
        Observable
            .combineLatest(input.emailText, input.passwordText, input.password2Text)
            .map { email, pass1, pass2 in
                !email.isEmpty && !pass1.isEmpty && email.isValidEmail && pass1 == pass2
            }.asDriver(onErrorJustReturn: false)
    }
    
    func handleValidInputMessage(_ input: Input) {
        Observable
            .combineLatest(input.emailText, input.passwordText, input.password2Text)
            .map { email, pass1, pass2 in
                if email.isEmpty {
                    return "Please provide an e-mail."
                } else if !email.isValidEmail {
                    return "E-mail address is not valid."
                } else if pass1.isEmpty {
                    return "Please create a password."
                } else if pass2.isEmpty {
                    return "Please repeat your password in the second field."
                } else if pass1 != pass2 {
                    return "Passwords should match!"
                } else {
                    return ""
                }
            }.subscribe(messageSubject)
            .disposed(by: disposeBag)
    }
    
    func handleRegisterButtonTap(_ input: Input) {
        let result = input.buttonTap
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText))
            .flatMapLatest { email, pass in
                self.networking
                    .registerUser(email: email, pass: pass)
                    .catchError({ error in
                        let errorMessage = (error as? Networking.APIError)?.localizedDescription
                                            ?? error.localizedDescription
                        self.messageSubject.onNext(errorMessage)
                        return .empty()
                    })
            }.share()
        
        result.map { _ in "" }.subscribe(messageSubject).disposed(by: disposeBag)
        result.map { _ in }.subscribe(registerEventSubject).disposed(by: disposeBag)
    }
}
