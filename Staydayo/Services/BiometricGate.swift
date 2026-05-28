import LocalAuthentication
import SwiftUI

@Observable
final class BiometricGate {
    var isUnlocked = false
    var lastError: String?

    func authenticate(reason: String = "Unlock your document vault") {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, err in
                DispatchQueue.main.async {
                    self.isUnlocked = success
                    self.lastError = err?.localizedDescription
                }
            }
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, err in
            DispatchQueue.main.async {
                self.isUnlocked = success
                self.lastError = err?.localizedDescription
            }
        }
    }

    func lock() {
        isUnlocked = false
    }
}
