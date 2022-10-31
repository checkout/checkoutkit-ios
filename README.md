> :warning: ***We're ending support for these SDKs on 28th April 2023. You should upgrade to the newest versions of our [Frames iOS SDK](https://github.com/checkout/frames-ios/), and release a new version of your application with these SDKs by that date. We would recommend starting this process ASAP.*** :warning:

### Requirements

Swift 3, iOS 8.0 and later

If you are using Swift 1.2, refer to [CheckoutKit 1.0.0](https://github.com/checkout/checkoutkit-ios/tree/1.0.0).

If you are using Swift 2.0, refer to [CheckoutKit 2.0.0](https://github.com/checkout/checkoutkit-ios/tree/2.0.0).

If you are using Objective-C, refer to [CheckoutKit objective-c](https://github.com/checkout/checkoutkit-ios/tree/objective-c).

### How to use the library

There are 2 ways you can add CheckoutKit to your project:

__CocoaPods__

The framework is available on CocoaPods. The following needs to be added in the ```Podfile```:
```
use_frameworks!
pod 'CheckoutKit', '~>3.0.6'
xcodeproj 'path/to/proj.xcodeproj'
```

Then run ```pod install``` and the framework is ready to be used.

__Carthage__

To integrate the framework into your Xcode project using Carthage, specify it in your ```Cartfile```:
```
github "checkout/checkoutkit-ios" ~> 3.0.6
```

__Manually__

Otherwise, the framework source code can be downloaded and manually added in your Xcode workspace.
Download or clone the [github repository](https://github.com/checkout/checkoutkit-ios). In your workspace, choose File > "Add files to ... " and select ```CheckoutKit/CheckoutKit.xcodeproj```.
Go to your project > General > Linked Frameworks and Libraries and add ```CheckoutKit.framework```.

### Example

A demo application is available in the folder *CheckoutKit/CheckoutKitExample*

Import the **CheckoutKit** framework in your code as below:
```
import CheckoutKit
```

You will need to specify at least the public key when creating an instance of ***CheckoutKit***. We offer a wide range of constructors, the ***CheckoutKit*** instance is entirely customizable:

```
CheckoutKit.getInstance(pk: String, env: Environment, debug: Bool, logger: Log) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String, debug: Bool, logger: Log) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String, env: Environment, logger: Log) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String, env: Environment, debug: Bool) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String, env: Environment) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String, logger: Log) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String, debug: Bool) throws -> CheckoutKit?
CheckoutKit.getInstance(pk: String) throws -> CheckoutKit?
CheckoutKit.getInstance() throws -> CheckoutKit? // to be called only once the CheckoutKit object has been initialized and a public key has been provided

```

These functions can throw a CheckoutError. If the public key is invalid, the error thrown is  CheckoutError.InvalidPK and if getInstance without the public key argument is called before the object is instantiated, the error thrown is CheckoutError.NoPK (both contains custom error messages).
Here are more details about the parameters :
- pk : String containing the public key. It is tested against the following regular expression : ```^pk_(?:test_)?(?:\w{8})-(?:\w{4})-(?:\w{4})-(?:\w{4})-(?:\w{12})$```. Mandatory otherwise the ***CheckoutKit*** object cannot be instantiated.
- env : Environment object containing the information of the merchant's environment, default is SANDBOX. Optional.
- debug : Bool, if the debug mode is activated or not, default is true. Optional.
- logger : Log object printing information, warnings and errors to the console (for now). Optional.

If **debug** is set to true, many actions will be traced to the logging system.

The available functions of ***CheckoutKit*** can be found in the [documentation](http://developers.checkout.com/docs/mobile/ios-kit/reference/checkoutkit).

Another class is available for utility functions: ***CardValidator***. It provides static functions for validating all the card related information before processing them. The list of the available functions is available in the [documentation](http://developers.checkout.com/docs/mobile/ios-kit/reference/cardvalidator).


**Create card token**

```swift
import CheckoutKit

let publicKey: String = "your_public_key"

/* Instantiates the CheckoutKit object with the minimum parameters, default configuration for the other ones */
var ck: CheckoutKit? = nil
do {
    try ck = CheckoutKit.getInstance(publicKey)
} catch _ as NSError {
    /* Happens when the public key is not valid, raised during the instanciation of the CheckoutKit object */
    /* Type of the error in the enum CheckoutError. Different types are NoPK (if getInstance is called with no parameters and no public key has been provided before) and InvalidPK (if the public key is invalid) */
}


/* Take the card information where ever you want (form, fields in the application page...) */
var card: Card? = nil
do {
    try card = Card(name: nameField.text!, number: numberField.text!, expYear: year, expMonth: month, cvv: cvvField.text!, billingDetails: nil)
} catch let err as CardError {
    /* Happens when the card informations entered by the user are not correct */
    /* Type of the error in the enum CardError. Different types are InvalidCVV (if the CVV does not have the correct format), InvalidExpiryDate (if the card is expired), InvalidNumber (if the card's number is wrong). */
} catch _ as NSError {
    /* If any other exception was thrown */
}

ck!.createCardToken(card!, completion:{ (resp: Response<CardTokenResponse>) -> Void in
        if (resp.hasError) {
            /* Print error message or handle it */
        } else {
            /* The card object */
            let ct: CardToken = resp.model!.card
            /* The field containing the card token to make a charge */
            let cardToken: String = resp.model!.getCardToken()
        }
    })
}
```

**Swift 3 - Create card token sample function**

```swift
func getCardToken() {
        
        var ck: CheckoutKit? = nil
        let customerDetails = CustomerDetails(address1: "test address 1",
                                              address2: "test address2",
                                              postCode: "B16123",
                                              country: "GB",
                                              city: "London",
                                              state: "xyz",
                                              phoneNumber: "7777777777",
                                              phoneCountryCode: "44")
        
        do {
            try ck = CheckoutKit.getInstance("pk_test_XXXXXXXXX",
                                             env: Environment.SANDBOX)
        } catch _ as NSError {
        
        }
        
        if ck != nil {
            if (CardValidator.validateCardNumber("4242424242424242")) {
                
                var card: Card? = nil
                do {
                    try card = Card(name: "test name",
                                    number: "4242424242424242",
                                    expYear: "2018",
                                    expMonth: "06",
                                    cvv: "100",
                                    billingDetails: customerDetails)
                    
                } catch _ as CardError {
                    
                } catch _ as NSError {
                    
                }
                if card != nil {
                    ck!.createCardToken(card!, completion:{ (resp: Response<CardTokenResponse>) -> Void in
                        if (resp.hasError) {
                           
                        } else {
                            print (resp.model?.cardToken)
                        }
                    })
                }
            }
        }
    }
```

### Logging

Most of the activity of the **CheckoutKit** is logged either as information, warning or error. All the logs are made to the console for now. Logging occurs only if the debug mode is activated (true as default, but can be explicitely set to false). The printing format is ```date (yyyy/MM/dd HH:mm:ss)  **Subject/Class name**  logged message```. The logger can be modified via the functions setLogger or getInstance. The log entries are then added to the logger specified.

### Unit Tests

All the unit tests are written using XCTest and Nimble and reside in CheckoutKit/CheckoutKitTests. 
You need to install [Nimble v5.0](https://github.com/Quick/Nimble/tree/v5.0.0) in order to run the tests.
This can be done by running ```pod install``` inside the CheckoutKit project (the Podfile has already been written), or installing it by any other mean.
