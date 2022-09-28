//
//  FirebaseAuthManager.swift
//
//
//  Created by Dhruv Jariwala on 28/09/22.
//
import Firebase

public class FirebaseAuthManager{
    public func signIn(with email : String, password : String){
        Auth.auth().signIn(withEmail : email, password: password) {  result, error in
            NetworkManager.sendWelcomeEmail(to: result?.user.email)
        }
    }
}

