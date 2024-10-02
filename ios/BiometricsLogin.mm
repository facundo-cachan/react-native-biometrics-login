objective-c
#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *stateView;
@property (weak, nonatomic) IBOutlet UILabel *faceIDLabel;

@property (strong, nonatomic) LAContext *context;

typedef NS_ENUM(NSInteger, AuthenticationState) {
    loggedin,
    loggedout
};

@property (assign, nonatomic) AuthenticationState state;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.context = [[LAContext alloc] init];
    NSError *error = nil;
    [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];

    self.state = loggedout;
}

- (IBAction)tapButton:(UIButton *)sender {
    if (self.state == loggedin) {
        self.state = loggedout;
    } else {
        self.context = [[LAContext alloc] init];
        self.context.localizedCancelTitle = @"Enter Username/Password";

        NSError *error = nil;
        if (![self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            NSLog(@"%@", error.localizedDescription ? error.localizedDescription : @"Can't evaluate policy");
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                     localizedReason:@"Log in to your account"
                               reply:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        self.state = loggedin;
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                });
            }];
        });
    }
}

- (void)setState:(AuthenticationState)state {
    _state = state;

    self.loginButton.highlighted = (state == loggedin);
    self.stateView.backgroundColor = (state == loggedin) ? [UIColor greenColor] : [UIColor redColor];
    self.faceIDLabel.hidden = (state == loggedin) || (self.context.biometryType != LABiometryTypeFaceID);
}

@end

