#import "ModeEventListener.h"

NSString *const ModeWebsocketURL = @"wss://api.tinkermode.com/userSession/websocket";

@implementation MODEEventListener

@synthesize didClose;
@synthesize didFail;
@synthesize didOpen;
@synthesize didReceive;
@synthesize autoReconnect;

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if (didReceive) {

        NSError* err = nil;
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];

        if (err) {
            didReceive(nil, err);
            return;
        }

        MODEDeviceEvent* event = [MTLJSONAdapter modelOfClass:MODEDeviceEvent.class fromJSONDictionary:dict error:&err];
        didReceive(event, err);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    if (self.didOpen) {
        self.didOpen();
    }

    self.retryWait = 1;
    self.fibCounter = 1;

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (self.didFail) {
        self.didFail(error);
    }

    if (self.autoReconnect) {
        [NSTimer scheduledTimerWithTimeInterval:self.retryWait target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
    }
}

/**
 *  Auto reconnection retry time interval is calculated by Fibonacci numbers.
 */
-(void)reconnect
{
    int nextRetry = self.retryWait + self.fibCounter;
    if (nextRetry < 60) {
        self.fibCounter = self.retryWait;
        self.retryWait = nextRetry;
    }
    // this is cyclic reference, but SRWebSocket.delegate is weak reference, so it is fine.
    self.websocket = [[SRWebSocket alloc] initWithURL:self.url];
    self.websocket.delegate = self;
    [self.websocket open];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (self.didClose) {
        self.didClose(code, reason, wasClean);
    }

    if (self.autoReconnect) {
        [NSTimer scheduledTimerWithTimeInterval:self.retryWait target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
    }
}

-(MODEEventListener *)initWithClientAuthentication:(MODEClientAuthentication *)clientAuthentication
{
    self.autoReconnect = @YES;
    self.retryWait = 1;
    self.fibCounter = 1;

    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                NULL, (CFStringRef)clientAuthentication.token, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));

    // SocketRocket library doesn't allow to pass 'Authorization' HTTP header, so pass the token as URL param. 
    self.url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@?authToken=%@", ModeWebsocketURL, encodedString]];

    return self;
}


- (MODEEventListener *)startListenToEvents:(void (^)(MODEDeviceEvent *, NSError *))didReceiveLocal
{
    self.didReceive = didReceiveLocal;

    // this is cyclic reference, but SRWebSocket.delegate is weak reference, so it is fine.
    self.websocket = [[SRWebSocket alloc] initWithURL:self.url];
    self.websocket.delegate = self;
    [self.websocket open];

    return self;
}

- (void)stopListenToEvents
{
    [self.websocket close];
    self.websocket = nil;
    self.retryWait = 1;
    self.fibCounter = 1;
}

@end
