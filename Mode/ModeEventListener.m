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
    } else {
        NSLog(@"didReceiveMessage is called but no callback block.");
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    if (self.didOpen) {
        self.didOpen();
    } else {
         NSLog(@"webSocketDidOpen is called but no callback block.");
    }

    retryWait = 1;
    fibCounter = 1;

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (self.didFail) {
        self.didFail(error);
    } else {
        NSLog(@"didFailWithError is called but no callback block.");
    }

    if (self.autoReconnect) {
        [NSTimer scheduledTimerWithTimeInterval:retryWait target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
    }
}

/**
 *  Auto reconnection retry time interval is calculated by Fibonacci numbers.
 */
-(void)reconnect
{
    int nextRetry = retryWait + fibCounter;
    if (nextRetry < 60) {
        fibCounter = retryWait;
        retryWait = nextRetry;
    }
    // this is cyclic reference, but SRWebSocket.delegate is weak reference, so it is fine.
    websocket = [[SRWebSocket alloc] initWithURL:url];
    websocket.delegate = self;
    [websocket open];
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (self.didClose) {
        self.didClose(code, reason, wasClean);
    } else {
        NSLog(@"didCloseWithCode is called but no callback block.");
    }

    if (self.autoReconnect) {
        [NSTimer scheduledTimerWithTimeInterval:retryWait target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
    }
}

-(MODEEventListener *)initWithClientAuthentication:(MODEClientAuthentication *)clientAuthentication
{
    self.autoReconnect = @YES;
    retryWait = 1;
    fibCounter = 1;

    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                NULL, (CFStringRef)clientAuthentication.token, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));

    // SocketRocket library doesn't allow to pass 'Authorization' HTTP header, so pass the token as URL param. 
    url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@?authToken=%@", ModeWebsocketURL, encodedString]];

    return self;
}


- (MODEEventListener *)startListenToEvents:(void (^)(MODEDeviceEvent *, NSError *))didReceiveLocal
{
    self.didReceive = didReceiveLocal;

    // this is cyclic reference, but SRWebSocket.delegate is weak reference, so it is fine.
    websocket = [[SRWebSocket alloc] initWithURL:url];
    websocket.delegate = self;
    [websocket open];

    return self;
}

- (void)stopListenToEvents
{
    [websocket close];
    websocket = nil;
    retryWait = 1;
    fibCounter = 1;
}

@end
