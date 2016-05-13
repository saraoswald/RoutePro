//
//  NSURLRequest+OAuth.m
//  YelpAPISample
//


#import "NSURLRequest+OAuth.h"

#import <TDOAuth/TDOAuth.h>

/**
 IMPORTANT///////
 
 CREDIT: Class .h and .m files were provided from Yelp API. Only minor modifications (the values of the static strings) have been added. This implementation was bundled with YAPISample
 
 ////////////////

 */



/**
 OAuth credential placeholders that must be filled by each user in regards to
 http://www.yelp.com/developers/getting_started/api_access
 */
static NSString * const kConsumerKey       = @"f2M9CzGFZkSfOe8wtGHHVw";
static NSString * const kConsumerSecret    = @"8BFtmihjm46Ypm7V-QUjfC3CbN0";
static NSString * const kToken             = @"vgr5kFLWM6LGGL2m_q1r164vH7_GmziZ";
static NSString * const kTokenSecret       = @"k_DmmzzCE1f4jZVDX46Y_cT08N8";

@implementation NSURLRequest (OAuth)

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path {
    return [self requestWithHost:host path:path params:nil];
}

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params {
    if ([kConsumerKey length] == 0 || [kConsumerSecret length] == 0 || [kToken length] == 0 || [kTokenSecret length] == 0) {
        NSLog(@"WARNING: Please enter your api v2 credentials before attempting any API request. You can do so in NSURLRequest+OAuth.m");
    }
    
    return [TDOAuth URLRequestForPath:path
                        GETParameters:params
                               scheme:@"https"
                                 host:host
                          consumerKey:kConsumerKey
                       consumerSecret:kConsumerSecret
                          accessToken:kToken
                          tokenSecret:kTokenSecret];
}

@end