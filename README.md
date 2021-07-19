# All Keys

A simple and secure password manager app used to store and utilize your credentials. Avaliable on the app store now!

## Features
- Autofill credentials into supporting apps and websites
- Password generator that creates strong and unique passwords
- Create password reset reminder
- Login using Face ID / Touch ID

## Implementation
- To securely the passwords, I used Apple's Keychain API and SwiftKeychainWrapper, which implements a strong AES-256-GCM Encryption. Additionally, I set Data Protection Entitlement and added the "FileProtectionType.complete" to the Core Data Stack to protect any other persisting non-password items.
