#import "ButtonUtils.h"
#import "UIColor+Extentions.h"

UIView* setupEditButtonsInSectionHeader(UIView* tableHeaderView) {
    UIView *view=[[UIView alloc]init];
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.frame=CGRectMake(250, 0, 100, 50);
    addButton.tintColor = [UIColor defaultThemeColor];
    [view addSubview:addButton];
    
    UIButton *editButton=[UIButton buttonWithType:UIButtonTypeInfoDark];
    editButton.frame=CGRectMake(0, 0, 50, 50);
    editButton.tintColor = [UIColor defaultThemeColor];
    [view addSubview:editButton];
    
    [tableHeaderView insertSubview:view atIndex:0];
    return view;
}

UILabel* setupTitle(NSString* title) {
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.text = @"Homes";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}