#import "ButtonUtils.h"
#import "UIColor+Extentions.h"

UIButton* setupEditButton(UIView* view, id target, SEL edit) {
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    editButton.frame = CGRectMake(0, 0, 50, 50);
    editButton.tintColor = [UIColor defaultThemeColor];
    [editButton addTarget:target action:edit forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:editButton];

    return editButton;
}

UIButton* setupAddButton(UIView* view, id target, SEL add) {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.frame = CGRectMake(250, 0, 100, 50);
    addButton.tintColor = [UIColor defaultThemeColor];
    [addButton addTarget:target action:add forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addButton];
 
    return addButton;
}


UILabel* setupTitle(NSString* title) {
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


void setupProfileButton(UINavigationItem* navigationItem, id target, SEL selector) {
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Prof" style:UIBarButtonItemStylePlain target:target action:selector];


    navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}
