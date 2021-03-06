//
//  RequestListHelperMethods.m
//  Instagram - Clone
//
//  Created by Yilmaz  on 03/01/16.
//  Copyright © 2016 Yilmaz . All rights reserved.
//

#import "RequestListHelperMethods.h"
#import "AppConstants.h"

@interface RequestListHelperMethods()

@property (strong, nonatomic) RequestListHelperMethods *requestObject;

@end

static NSMutableArray *allList;

@implementation RequestListHelperMethods

#pragma mark - SingletonPattern



-(instancetype)initWithDelegate:(id)delegate{
    
    if( self ) {

        _requestObject = [[RequestListHelperMethods alloc]init];
        
        _requestObject.delegate = delegate;
    
    }
    
    return self;
}



-(void)getSendingRequestUserListWithControl:(BOOL)boolean{
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSMutableArray *newUserIDs = [[NSMutableArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:RequestsClassID];
    
    [query whereKey:@"senderID" equalTo:currentUser.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if( error ) {
            NSLog(@"There is an error  =  -(void)deleteUserRequestFromRequests:(PFUser *)user{");
        } else {
            for( PFObject *newObject in objects ) {
                
                [newUserIDs addObject:newObject[@"receipentsID"]];
            
            }
            [self setAllChangesParseBackend:newUserIDs withControl:boolean];
        }
    }];
}

-(void)setAllChangesParseBackend:(NSMutableArray*)currentList withControl:(BOOL)boolean{
    
    PFUser *currentUser = [PFUser currentUser];
    
    [currentUser setObject:currentList forKey:WaitingRequestsListID];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error) {
            NSLog(@"There is an error : -(void)addRequestListToThisUser:(PFUser*)user");
            [_requestObject.delegate getAllUserListsFromParseBackendFailed];
        } else {
            NSLog(@"Request listesine obje yükleme başarılı");
            if(_requestObject) {
                allList = currentList;
                [_requestObject.delegate getAllUserListsFromParseBackend:currentList control:boolean];
            }
        }
    }];
}

-(NSMutableArray *)getStaticUserList{

    return allList;
}

+(void)removeUserFromRequestLists:(PFUser *)deletingUser{
    
    PFQuery *query = [PFQuery queryWithClassName:RequestsClassID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if( error ) {
            NSLog(@"There is an error  =  -(void)deleteUserRequestFromRequests:(PFUser *)user{");
        } else {
            PFUser *currentUser = [PFUser currentUser];
            for(PFObject *currentObject in objects) {
                if([currentObject[@"senderID"] isEqualToString:deletingUser.objectId] && [currentObject[@"receipentsID"] isEqualToString:currentUser.objectId]){
                    [currentObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if( error ) {
                            NSLog(@"There is an error = -(void)deleteUserRequestFromRequests:(PFUser *)user{");
                        } else {
                            NSLog(@"Request silme başarılı");
                        }
                    }];
                }
            }
        }
    }];
}

@end
