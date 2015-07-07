#ifndef MODE_iOSSDK_Utils_h
#define MODE_iOSSDK_Utils_h

void showAlert(NSError* err);


@interface NumericTextFieldDelegate : NSObject<UITextFieldDelegate>

@end

@interface PhoneNumberFieldDelegate : NSObject<UITextFieldDelegate>

- (id)initWithTextField:(UITextField*)textField;

@end


#endif
