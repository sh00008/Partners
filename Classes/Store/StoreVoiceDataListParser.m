//
//  StoreVoiceDataListParser.m
//  Sanger
//
//  Created by JiaLi on 12-9-19.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#import "StoreVoiceDataListParser.h"
#import "VoicePkgInfoObject.h"

@implementation StoreVoiceDataListParser
@synthesize pkgsArray;
@synthesize serverlistArray;

- (void)loadWithPath:(NSString*)path
{
    NSData* filedata = [NSData dataWithContentsOfFile:path];
    [self loadWithData:filedata];
}

- (void)loadWithData:(NSData*)filedata
{
    TBXML* tbxml = [[TBXML tbxmlWithXMLData:filedata] retain];
	
	// Obtain root element
	TBXMLElement * root = tbxml.rootXMLElement;
    if (root) {
        // head
        TBXMLElement * header = [TBXML childElementNamed:@"head" parentElement:root];
        if (header) {
            // load serverList
            TBXMLElement* serverlist = [TBXML childElementNamed:@"serverList" parentElement:header];
            if (serverlist) {
                TBXMLElement* urlElement = [TBXML childElementNamed:@"url" parentElement:serverlist];
                NSMutableArray* array = [[NSMutableArray alloc] init];
                while (urlElement) {
                    NSString* urltxt = [TBXML textForElement:urlElement];
                    [array addObject:urltxt];
                     urlElement = [TBXML nextSiblingNamed:@"url" searchFromElement:urlElement];
               }
                self.serverlistArray = array;
                [array release];
            }
        }
        
        // body
        TBXMLElement * body = [TBXML childElementNamed:@"body" parentElement:root];
		if (body) {
            TBXMLElement * pkgs = [TBXML childElementNamed:@"pkgs" parentElement:body];
            if (pkgs) {
                //NSString* countText = [TBXML valueOfAttributeNamed:@"count" forElement:pkgs];
                //V_NSLog(@"pkgs count: %d", [countText intValue]);
                NSMutableArray* array = [[NSMutableArray alloc] init];
                [self loadPkgs:pkgs withArray:array];
                self.pkgsArray = array;
                [array release];
            }
		}
        
    }
	
	if (root) {
		
	}
	[tbxml release];

}

- (void)loadPkgs:(TBXMLElement*)parentElement withArray:(NSMutableArray*)array
{
    TBXMLElement* pkg = [TBXML childElementNamed:@"pkg" parentElement:parentElement];
    while (pkg) {
        DownloadDataPkgInfo* pkgInfo = [[DownloadDataPkgInfo alloc] init];
        NSString* title = [TBXML valueOfAttributeNamed:@"title" forElement:pkg];
        pkgInfo.title = title;
        
        NSString* count = [TBXML valueOfAttributeNamed:@"count" forElement:pkg];
        pkgInfo.count = [count intValue];
        
        NSString* cover = [TBXML valueOfAttributeNamed:@"cover" forElement:pkg];
        pkgInfo.coverURL = cover;
        
        NSString* url = [TBXML valueOfAttributeNamed:@"url" forElement:pkg];
        pkgInfo.url = url;
        
        TBXMLElement* introElement = [TBXML childElementNamed:@"intro" parentElement:pkg];
        if (introElement) {
            NSString* introText = [TBXML textForElement:introElement];
            pkgInfo.intro = introText;
        }
        TBXMLElement* pkgCourseElement =  [TBXML nextSiblingNamed:@"course" searchFromElement:introElement];
        
        if (pkgCourseElement == nil) {
            pkgCourseElement = [TBXML childElementNamed:@"course" parentElement:pkg];
        }
        NSMutableArray* pkgCourseArray = [[NSMutableArray alloc] init];
        while (pkgCourseElement) {
            DownloadDataPkgCourseInfo* courseInfo = [[DownloadDataPkgCourseInfo alloc] init];
            NSString* title = [TBXML valueOfAttributeNamed:@"title" forElement:pkgCourseElement];
            courseInfo.title = title;
 
            NSString* path = [TBXML valueOfAttributeNamed:@"path" forElement:pkgCourseElement];
            courseInfo.path = path;

            NSString* file = [TBXML valueOfAttributeNamed:@"file" forElement:pkgCourseElement];
            courseInfo.file = file;

            NSString* cover = [TBXML valueOfAttributeNamed:@"cover" forElement:pkgCourseElement];
            courseInfo.cover = cover;

            NSString* url = [TBXML valueOfAttributeNamed:@"url" forElement:pkgCourseElement];
            courseInfo.url = url;
            
            [pkgCourseArray addObject:courseInfo];
            [courseInfo release];
            pkgCourseElement =  [TBXML nextSiblingNamed:@"course" searchFromElement:pkgCourseElement];
            
        }
        pkgInfo.dataPkgCourseInfoArray = pkgCourseArray;
        [pkgCourseArray release];
        [array addObject:pkgInfo];
        [pkgInfo release];
        
        pkg = [TBXML nextSiblingNamed:@"pkg" searchFromElement:pkg];
    }
}

- (void)dealloc
{
    [self.pkgsArray release];
    [super dealloc];
}
@end
