import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    let context = LAContext()
    var error: NSError?
    var reason = "Authenticate"
    let entryContents = "Hello!"
    
    let key = "test_entry"
    let secret = "Hello!"
    let password = "qwerty"
    
    enum Result {
        case Success(String?)
        case Failure(OSStatus)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addSecretSuccess = addSecret(secret: secret, usingPassword: password)
        print(addSecretSuccess)
        let readSecret = retrieveSecretUsing(password: password)
        print(readSecret)
    }

    func addSecret(secret: String, usingPassword password : String) -> Result {
        if let secretData = secret.data(using: .utf8) as NSData? {
            var error : Unmanaged<CFError>?
            let acl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .applicationPassword, &error)
            if error != nil {
                return .Failure(errSecNotAvailable)
            }
            context.setCredential(password.data(using: .utf8), type: .applicationPassword)
            var attributes = [String : AnyObject]()
            attributes[kSecClass as String] = kSecClassGenericPassword as CFString
            attributes[kSecAttrAccount as String] = "exampleAccount" as CFString
            attributes[kSecAttrService as String] = "secretService" as CFString
            attributes[kSecValueData as String] = secretData
            attributes[kSecAttrAccessControl as String] = acl
            attributes[kSecUseAuthenticationContext as String] = context
            let status = SecItemAdd(attributes as CFDictionary, nil)
            if status == errSecSuccess {
                return .Success(nil)
            } else {
                return .Failure(status)
            }
        }
        return .Success(nil)
    }

    func retrieveSecretUsing(password : String) -> Result {
        var error : Unmanaged<CFError>?
        let acl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .applicationPassword, &error)
        if error != nil {
            return .Failure(errSecNotAvailable)
        }
        context.setCredential(password.data(using: .utf8), type: .applicationPassword)
        var attributes = [String : AnyObject]()
        attributes[kSecClass as String] = kSecClassGenericPassword as CFString
        attributes[kSecAttrAccount as String] = "exampleAccount" as CFString
        attributes[kSecAttrService as String] = "secretService" as CFString
        attributes[kSecReturnData as String] = kCFBooleanTrue
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne
        attributes[kSecAttrAccessControl as String] = acl
        attributes[kSecUseAuthenticationContext as String] = context
        var resultEntry : AnyObject? = nil
        let status = SecItemCopyMatching(attributes as CFDictionary, &resultEntry)
        if let data = resultEntry as? Data, let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? { // (3)
            return .Success(str)
        } else {
            return .Failure(status)
        }
    }
    
}

