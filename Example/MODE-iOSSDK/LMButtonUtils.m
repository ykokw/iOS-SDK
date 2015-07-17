#import "LMButtonUtils.h"
#import "LMUIColor+Extentions.h"

UIButton *setupEditButton(UIView *view, id target, SEL edit)
{
    UIButton *editButton = [[UIButton alloc] init];
    [editButton setImage:[UIImage imageNamed:@"Settings.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"Settings Red.png"] forState:UIControlStateSelected];
    editButton.frame = CGRectMake(0, 0, 50, 50);
    [editButton addTarget:target action:edit forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:editButton];

    return editButton;
}

UIButton *setupAddButton(UIView *view, id target, SEL add)
{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(250, 0, 100, 50);
    addButton.tintColor = [UIColor defaultThemeColor];
    [addButton addTarget:target action:add forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addButton];
 
    return addButton;
}

void setupRightBarButtonItem(UINavigationItem *navigationItem, NSString *title, id target, SEL selector)
{
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
        style:UIBarButtonItemStylePlain target:target action:selector];
    
}

void setupProfileButton(UINavigationItem *navigationItem, id target, SEL selector)
{
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Profile.png"]
        style:UIBarButtonItemStylePlain target:target action:selector];

}
