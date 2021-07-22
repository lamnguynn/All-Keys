# All Keys

A simple and secure password manager app used to store and utilize your credentials. Avaliable for iOS on the app store [now](https://apps.apple.com/us/app/all-keys/id1576077213)!

## Features
- Autofill credentials into supporting apps and websites
- Password generator that creates strong and unique passwords
- Create password reset reminder
- Login using Face ID / Touch ID

## Implementation
- To secure the passwords, I used Apple's Keychain API and SwiftKeychainWrapper (via Cocoapods), which implements a strong AES-256-GCM Encryption. Additionally, I set Data Protection Entitlement and added the "FileProtectionType.complete" to the Core Data Stack to protect any other persisting non-password items.

## Lessons Learned
- Working with entitlements and capabilities such as App Groups and Keychain Sharing to utilize in a multi-target project.
- Implementing GCD features to ensure the app runs smoothly when data is being updated.
- Moving towards programmatically creating assets instead of storyboard to allow for better customization and layout, with about 90-95% of the app being built programmatic.
- Working with class extensions and building custom view controllers from the ground up to allow for greater UI improvements.
- Partially worked with third-party APIs and databases, but idea was scrapped because of how the features on them were limited.
- Put more emphasis on more readable code and organization to allow for scaling in the future if needed.

## Possible New Features
- Adding company logos into the home screen instead of initials via API call. Very easy to update since I purposely put the initials there to add more flair and in case in the future, there is a free API to use.
- Possibly moving away from Keychain API to Realm DB in the future, but unable since Realm does not support database sharing encryption. 
