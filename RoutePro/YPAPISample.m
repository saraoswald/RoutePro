//
//  YPAPISample.m
//  YelpAPI

#import "YPAPISample.h"
#import "SharedBusinessInfo.h"

/**
 IMPORTANT///////
 
 CREDIT: Class .h and .m files were provided from Yelp API. Modifications were made to original file to include data from SharedBusinessInfo and to handle exceptions and adds to SharedBusinessInfo as we saw fit. Depends on NSURLRequest+OAuth files which came bundled with these.
 
 ////////////////
 
 */

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"10";

@implementation YPAPISample

#pragma mark - Public

- (void)queryTopBusinessInfoForTerm:(NSString *)term location:(NSString *)location cll:(NSString*)cll completionHandler:(void (^)(NSDictionary *topBusinessJSON, NSError *error))completionHandler {
   
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    //Make a first request to get the search results with the passed term and location
    NSURLRequest *searchRequest = [self _searchRequestWithTerm:term location:location cll:cll];
    
    NSString *requestPath = [[searchRequest URL] absoluteString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSMutableDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if([searchResponseJSON[@"businesses"] count]>0){
                NSArray *businessArray = searchResponseJSON[@"businesses"];
                
                NSMutableDictionary *tmpObject = [[NSMutableDictionary alloc] init];
                [tmpObject setObject:term forKey:@"type"];
                [tmpObject setObject:businessArray forKey:@"bArray"];
                //only add items if there is not an existing list of cached values for the term
                if([[allInfo CachedBusinesses] containsObject:tmpObject]==NO){
                    [[allInfo CachedBusinesses] addObject:tmpObject];
                }
                else{
    //                NSLog(@"This object already existed in CachedBusinesses");
                }
                //make sure that we only add a business if the response yielded a list of businesses
                if ([businessArray count] > 0) {
                    NSDictionary *firstBusiness = [businessArray firstObject];
                    NSString *firstBusinessID = firstBusiness[@"id"];
                    
                    NSMutableDictionary *tmpObject = [[NSMutableDictionary alloc] init];
                    [tmpObject setObject:term forKey:@"type"];
                    [tmpObject setObject:firstBusiness[@"name"] forKey:@"bName"];
                    
                    if([[allInfo SelectedBusinesses] containsObject:tmpObject]==NO){
                        [[allInfo SelectedBusinesses] addObject:tmpObject];
                    }
                    
                    [self queryBusinessInfoForBusinessId:firstBusinessID completionHandler:completionHandler];
                }
                else {
                    completionHandler(nil, error); // No business was found
                }
            }
            else {
                [allInfo setSize:[allInfo size]-1];
                [[allInfo userInputs] removeAllObjects];
                completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
            }
        }
        
    }] resume];
}


/**
 Make call to Yelp Business API. Calls to this function originate form queryTopBusinessForInfo and rely on the ID generated from the Yelp Search API.
 */
- (void)queryBusinessInfoForBusinessId:(NSString *)businessID completionHandler:(void (^)(NSDictionary *topBusinessJSON, NSError *error))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *businessInfoRequest = [self _businessInfoRequestForID:businessID];
    [[session dataTaskWithRequest:businessInfoRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode == 200) {
            NSDictionary *businessResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            completionHandler(businessResponseJSON, error);
        } else {
            completionHandler(nil, error);
        }
    }] resume];
    
}


#pragma mark - API Request Builders

/**
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA
 
 @return The NSURLRequest needed to perform the search
 */
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location cll:(NSString*)cll{
    NSDictionary *params = @{
                             @"term": term,
                             //@"location": location,
                             @"ll": cll,
                             @"limit": kSearchLimit
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

/**
 Builds a request to hit the business endpoint with the given business ID.
 
 @param businessID The id of the business for which we request informations
 
 @return The NSURLRequest needed to query the business info
 */
- (NSURLRequest *)_businessInfoRequestForID:(NSString *)businessID {
    
    NSString *businessPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, businessID];
    return [NSURLRequest requestWithHost:kAPIHost path:businessPath];
}

@end