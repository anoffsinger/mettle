//
//  SplashPageView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 5/17/24.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct SplashPageView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentNonce: String?  // Used to store a cryptographic nonce, necessary to validate that the response was sent in reply to our request

    var body: some View {
        VStack {
            Text("Welcome to Mettle")
                .font(.largeTitle)
                .padding()

            SignInWithAppleButton(
                onRequest: configureRequest,
                onCompletion: handleAuthorization
            )
            .signInWithAppleButtonStyle(.black) // Style the button
            .frame(width: 280, height: 44)
            .padding()
        }
    }

    private func configureRequest(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    private func handleAuthorization(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = appleIDCredential.identityToken,
                  let idTokenString = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                fatalError("Invalid state or user was not authenticated")
            }
            authenticateUserWithApple(idToken: idTokenString, nonce: nonce)
        case .failure(let error):
            print("Authentication failed: \(error.localizedDescription)")
        }
    }

    private func authenticateUserWithApple(idToken: String, nonce: String) {
        // Here you'd send the token and nonce to your server to create a session after validating the token
        // For demonstration, we'll assume authentication is successful and store the userIdentifier
        let userIdentifier = "example_user_identifier" // Replace with actual user identifier
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
        appState.isAuthenticated = true
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

#Preview {
    SplashPageView()
}
