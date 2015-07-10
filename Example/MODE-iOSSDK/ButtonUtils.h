#import <UIKit/UIKit.h>

UIButton* setupEditButton(UIView* view, id target, SEL edit);
UIButton* setupAddButton(UIView* view, id target, SEL add);
void setupProfileButton(UINavigationItem* navigationItem, id target, SEL selector);

UILabel* setupTitle(NSString* title);
