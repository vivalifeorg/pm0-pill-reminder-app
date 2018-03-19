//
//  PhaxioAPI.m
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import "PhaxioAPI.h"

@implementation PhaxioAPI

@synthesize delegate;

int SENT_FAX = 0;
int CANCEL_FAX = 1;
int RESEND_FAX = 2;
int TEST_RECEIVE = 3;
int PROVISION_NUMBER = 4;
int CREATE_PHAXIO = 5;
int FAX_INFO = 6;
int FAX_CONTENT_FILE = 7;
int FAX_THUMBNAIL_S = 8;
int FAX_THUMBNAIL_L = 9;
int LIST_FAXES = 10;
int SUPPORTED_COUNTRIES = 11;
int NUMBER_INFO = 12;
int LIST_NUMBERS = 13;
int LIST_AREA_CODES = 14;
int RETRIEVE_PHAX_CODE = 15;
int RETRIEVE_PHAX_CODE_ID = 16;
int ACCOUNT_STATUS = 17;
int DELETE_FAX = 18;
int DELETE_FILE = 19;
int RELEASE_PHONE_NUMBER = 20;

static NSString* api_key = @"key";
static NSString* api_secret = @"secret";

NSString* api_url = @"https://api.phaxio.com/v2/";

- (void)createAndSendFaxWithParameters:(NSMutableDictionary*)parameters
{
    NSString* url = [NSString stringWithFormat:@"%@faxes", api_url];
    
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:api_secret forKey:@"api_secret"];
    
    [self makePostRequest:url postParameters:parameters apiMethod:SENT_FAX];
}

- (void)cancelFax:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@/cancel", api_url, fax_id];
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:fax_id forKey:fax_id];
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:api_secret forKey:@"api_secret"];
    
    [self makePostRequest:url postParameters:parameters apiMethod:CANCEL_FAX];
}

- (void)resendFax:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@/resend", api_url, fax_id];
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:fax_id forKey:fax_id];
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:api_secret forKey:@"api_secret"];
    
    [self makePostRequest:url postParameters:parameters apiMethod:RESEND_FAX];
}

- (void)testReceive
{
    NSString* url = [NSString stringWithFormat:@"%@faxes?direction=received", api_url];
    [self makePostRequest:url postParameters:nil apiMethod:TEST_RECEIVE];
}

- (void)getFaxInfoWithID:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@", api_url, fax_id];
    [self makeGetRequest:url apiMethod:FAX_INFO];
}

- (void)getFaxContentFileWithID:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@/file", api_url, fax_id];
    [self makeGetRequest:url apiMethod:FAX_CONTENT_FILE];
}

- (void)getFaxContentThumbnailSmallWithID:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@/file?thumbnail=s", api_url, fax_id];
    [self makeGetRequest:url apiMethod:FAX_THUMBNAIL_S];
}

- (void)getFaxContentThumbnailLargeWithID:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@/file?thumbnail=l", api_url, fax_id];
    [self makeGetRequest:url apiMethod:FAX_THUMBNAIL_L];
}

- (void)deleteFaxWithID:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@", api_url, fax_id];
    [self makeDeleteRequest:url apiMethod:DELETE_FAX];
}

- (void)deleteFaxFileWithID:(NSString*)fax_id
{
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@/file", api_url, fax_id];
    [self makeDeleteRequest:url apiMethod:DELETE_FILE];
}

- (void)listFaxesInDateRangeCreatedBefore:(NSDate*)created_before createdAfter:(NSDate*)created_after direction:(NSString*)direction status:(NSString*)status phoneNumber:(NSString*)phone_number tag:(NSString*)tag
{
    NSString* ampersand = @"";
    NSString* parameters = @"";
    
    if (created_before != nil) {
        
        parameters = [NSString stringWithFormat:@"%@?created_before=%@", parameters, created_before];
        
        ampersand = @"&";
    }

    if (created_after != nil) {
        
        parameters = [NSString stringWithFormat:@"%@?created_after=%@", parameters, created_after];
        
        ampersand = @"&";
    }
    
    if (direction != nil) {
        
        parameters = [NSString stringWithFormat:@"%@?direction=%@", parameters, direction];
        
        ampersand = @"&";
    }
    
    if (status != nil) {
        
        parameters = [NSString stringWithFormat:@"%@?status=%@", parameters, status];
        
        ampersand = @"&";
    }
    
    if (phone_number != nil) {
        
        parameters = [NSString stringWithFormat:@"%@?phone_number=%@", parameters, phone_number];
        
        ampersand = @"&";
    }
    
    if (tag != nil) {
        
        parameters = [NSString stringWithFormat:@"%@?tag[%@]=%@", parameters, tag, tag];
        
        ampersand = @"&";
    }
    
    NSString* url = [NSString stringWithFormat:@"%@faxes/%@", api_url, parameters];
    [self makeGetRequest:url apiMethod:LIST_FAXES];
}

- (void)listSentFaxes
{
    [self listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:@"sent" status:nil phoneNumber:nil tag:nil];
}

- (void)listReceivedFaxes
{
    [self listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:@"received" status:nil phoneNumber:nil tag:nil];
}

- (void)listFaxesWithStatus:(NSString*)status
{
    [self listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:nil status:status phoneNumber:nil tag:nil];
}


- (void)listFaxesForPhoneNumber:(NSString*)phone_number
{
    [self listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:nil status:nil phoneNumber:phone_number tag:nil];
}

- (void)listFaxesForTag:(NSString*)tag
{
    [self listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:nil status:nil phoneNumber:nil tag:tag];
}

- (void)getAListOfSupportedCountries
{
    NSString* url = [NSString stringWithFormat:@"%@public/countries", api_url];
    [self makeGetRequest:url apiMethod:SUPPORTED_COUNTRIES];
}

- (void)provisionPhoneNumberWithPostParameters:(NSMutableDictionary*)parameters
{
    NSString* url = [NSString stringWithFormat:@"%@phone_numbers", api_url];
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:api_secret forKey:@"api_secret"];
    [self makePostRequest:url postParameters:parameters apiMethod:PROVISION_NUMBER];
}

- (void)getNumberInfoForNumber:(NSString*)number
{
    NSString* url = [NSString stringWithFormat:@"%@phone_numbers/%@", api_url, number];
    [self makeGetRequest:url apiMethod:NUMBER_INFO];
}

- (void)listNumbersWithCountryCode:(NSString*)country_code areaCode:(NSString*)area_code
{
    NSString* leading = @"?";
    NSString* parameters = @"";
    
    if (country_code != nil) {
        
        parameters = [NSString stringWithFormat:@"%@%@country_code=%@", parameters, leading, country_code];
        
        leading = @"&";
    }
    
    if (area_code != nil) {
        
        parameters = [NSString stringWithFormat:@"%@%@area_code=%@", parameters, leading, area_code];
        
        leading = @"&";
    }
    
    NSString* url = [NSString stringWithFormat:@"%@phone_numbers%@", api_url, parameters];
    [self makeGetRequest:url apiMethod:LIST_NUMBERS];

}

- (void)releasePhoneNumber:(NSString*)number
{
    NSString* url = [NSString stringWithFormat:@"%@phone_numbers/%@", api_url, number];
    [self makeDeleteRequest:url apiMethod:RELEASE_PHONE_NUMBER];
}

- (void)listAreaCodesAvailableForPurchasingNumbersWithTollFree:(NSString*)toll_free countryCode:(NSString*)country_code country:(NSString*)country state:(NSString*)state
{
    NSString* leading = @"?";
    NSString* parameters = @"";
    
    if (toll_free != nil && ![toll_free isEqualToString:@""]) {
        
        parameters = [NSString stringWithFormat:@"%@%@toll_free=%@", parameters, leading, toll_free];
        
        leading = @"&";
    }
    
    if (country_code != nil && ![country_code isEqualToString:@""]) {
        
        parameters = [NSString stringWithFormat:@"%@%@country_code=%@", parameters, leading, country_code];
        
        leading = @"&";
    }
    
    if (country != nil && ![country isEqualToString:@""]) {
        
        parameters = [NSString stringWithFormat:@"%@%@country=%@", parameters, leading, country];
        
        leading = @"&";
    }
    
    if (state != nil && ![state isEqualToString:@""]) {
        
        parameters = [NSString stringWithFormat:@"%@%@state=%@", parameters, leading, state];
        
        leading = @"&";
    }
    
    NSString* url = [NSString stringWithFormat:@"%@public/area_codes%@", api_url, parameters];
    [self makeGetRequest:url apiMethod:LIST_AREA_CODES];
}

-(void)createPhaxCodeWithMetadata:(NSString*)metadata;
{
    NSString* url = [NSString stringWithFormat:@"%@phax_codes", api_url];
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:api_secret forKey:@"api_secret"];
    [parameters setValue:metadata forKey:@"metadata"];
    
    [self makePostRequest:url postParameters:parameters apiMethod:CREATE_PHAXIO];
}

- (void)retrievePhaxCode
{
    NSString* url = [NSString stringWithFormat:@"%@phax_code", api_url];
    [self makeGetRequest:url apiMethod:RETRIEVE_PHAX_CODE];
}

- (void)retrievePhaxCodeWithID:(NSString*)phax_id
{
    NSString* url = [NSString stringWithFormat:@"%@phax_code/%@", api_url, phax_id];
    [self makeGetRequest:url apiMethod:RETRIEVE_PHAX_CODE_ID];
}

- (void)getAccountStatus
{
    NSString* url = [NSString stringWithFormat:@"%@account/status", api_url];
    [self makeGetRequest:url apiMethod:ACCOUNT_STATUS];
}

-(void)makePostRequest:(NSString*)url postParameters:(NSMutableDictionary*)parameters apiMethod:(int)api_method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    if ([parameters valueForKey:@"file"] != nil)
    {
        NSString *boundaryConstant = @"----------V2nBsIHs01cEs16iSu91ia";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryConstant];
        
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *mutableData = [NSMutableData data];
        NSData* photoData = [parameters valueForKey:@"file"];
        [parameters removeObjectForKey:@"file"];
        
        NSArray* parameterArray = [parameters allKeys];
        
        for (int i = 0; i < [parameterArray count]; i++) {
            NSString* parameter = [parameterArray objectAtIndex:i];
            [mutableData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameter] dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:parameter]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSString* fileParamConstant = @"file";
        if (photoData) {
            [mutableData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", fileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableData appendData:photoData];
            [mutableData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [mutableData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:mutableData];
    }
    else
    {
        [request setHTTPBody:[self httpBodyForParamsDictionary:parameters]];
    }

    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"dataTaskWithRequest error: %@", error);
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                NSLog(@"Expected responseCode == 200; received %ld", (long)statusCode);
            }
        }
        
         NSError *parseError;

         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
         if (!json) {
             NSLog(@"JSON parse error: %@", parseError);
         } else {
             NSLog(@"responseObject = %@", json);
          }

        [self handlePostResponseForAPIMethod:api_method AndJSONResponse:json];
        
    }];
    [task resume];
}

-(void)makeGetRequest:(NSString*)url apiMethod:(int)api_method
{
    NSString* leading = @"?";
    if ([url containsString:@"?"])
    {
        leading = @"&";
    }
    NSString* urlWithKeyAndSecret = [NSString stringWithFormat:@"%@%@api_key=%@&api_secret=%@", url, leading, api_key, api_secret];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlWithKeyAndSecret]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"dataTaskWithRequest error: %@", error);
        }

        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if (statusCode != 200) {
                NSLog(@"Expected responseCode == 200; received %ld", (long)statusCode);
            }
        }
        
        NSError *parseError;
        
        if  (api_method != FAX_CONTENT_FILE && api_method != FAX_THUMBNAIL_S && api_method != FAX_THUMBNAIL_L)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (!json) {
                NSLog(@"JSON parse error: %@", parseError);
            } else {
                NSLog(@"responseObject = %@", json);
            }
            
            [self handleGetResponseForAPIMethod:api_method AndJSONResponse:json];
        }
        else
        {
            [self handleGetFileResponseForAPIMethod:api_method AndData:data AndSuccess:statusCode];
        }
        
    }];
    [task resume];
}

-(void)makeDeleteRequest:(NSString*)url apiMethod:(int)api_method
{
    NSString* leading = @"?";
    if ([url containsString:@"?"])
    {
        leading = @"&";
    }
    NSString* urlWithKeyAndSecret = [NSString stringWithFormat:@"%@%@api_key=%@&api_secret=%@", url, leading, api_key, api_secret];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlWithKeyAndSecret]];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"dataTaskWithRequest error: %@", error);
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                NSLog(@"Expected responseCode == 200; received %ld", (long)statusCode);
            }
        }
        
        // If response was JSON (hopefully you designed web service that returns JSON!),
        // you might parse it like so:
        //
        NSError *parseError;
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (!json) {
            NSLog(@"JSON parse error: %@", parseError);
        } else {
            NSLog(@"responseObject = %@", json);
        }
        
        [self handleDeleteResponseForAPIMethod:api_method AndJSONResponse:json];
        
    }];
    [task resume];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (void)handlePostResponseForAPIMethod:(int)api_method AndJSONResponse:(NSDictionary*)json
{
    if (api_method == SENT_FAX)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] sentFax:success andResponse:json];
    }
    else if (api_method == CANCEL_FAX)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] cancelledFax:success andResponse:json];
    }
    else if(api_method == RESEND_FAX)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] resentFax:success andResponse:json];
    }
    else if(api_method == TEST_RECEIVE)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] testReceive:success andResponse:json];
    }
    else if(api_method == PROVISION_NUMBER)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] provisionNumber:success andResponse:json];
    }
    else if(api_method == CREATE_PHAXIO)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] createPhaxio:success andResponse:json];
    }
}

- (void)handleGetResponseForAPIMethod:(int)api_method AndJSONResponse:(NSDictionary*)json
{
    if (api_method == FAX_INFO)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] faxInfo:success andResponse:json];
    }
    else if(api_method == LIST_FAXES)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] listFaxes:success andResponse:json];
    }
    else if(api_method == SUPPORTED_COUNTRIES)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] listOfSupportedCountries:success andResponse:json];
    }
    else if(api_method == NUMBER_INFO)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] getNumberInfo:success andResponse:json];
    }
    else if(api_method == LIST_NUMBERS)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] listNumbers:success andResponse:json];
    }
    else if(api_method == LIST_AREA_CODES)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] listAreaCodes:success andResponse:json];
    }
    else if(api_method == RETRIEVE_PHAX_CODE)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] retrievePhaxCode:success andResponse:json];
    }
    else if(api_method == RETRIEVE_PHAX_CODE_ID)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] retrievePhaxCode:success andResponse:json];
    }
    else if(api_method == ACCOUNT_STATUS)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] getAccountStatus:success andResponse:json];
    }
}

- (void)handleGetFileResponseForAPIMethod:(int)api_method AndData:(NSData*)data AndSuccess:(NSInteger)statusCode
{
    if (api_method == FAX_THUMBNAIL_L)
    {
        BOOL success = statusCode != 500;
        [[self delegate] largeThumbnail:success andResponse:[UIImage imageWithData:data]];
    }
    else if (api_method == FAX_THUMBNAIL_S)
    {
        BOOL success = statusCode != 500;
        [[self delegate] smallThumbnail:success andResponse:[UIImage imageWithData:data]];
    }
    else if(api_method == FAX_CONTENT_FILE)
    {
        BOOL success = statusCode != 500;
        [[self delegate] contentFile:success andResponse:data];
    }
}

- (void)handleDeleteResponseForAPIMethod:(int)api_method AndJSONResponse:(NSDictionary*)json
{
    if (api_method == DELETE_FAX)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] deleteFax:success andResponse:json];
    }
    else if (api_method == DELETE_FILE)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] deleteFaxFile:success andResponse:json];
    }
    
    else if (api_method == RELEASE_PHONE_NUMBER)
    {
        BOOL success = [json valueForKey:@"success"];
        [[self delegate] releasePhoneNumber:success andResponse:json];
    }
}

+ (void)setAPIKey:(NSString*)_api_key andSecret:(NSString*)_api_secret
{
    api_key = _api_key;
    api_secret = _api_secret;
}

@end
