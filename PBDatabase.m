//
//  PBDatabase.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 8..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PBDatabase.h"
#import "JMDevKit.h"


@implementation PBDatabase

+ (BOOL) existsDatabase
{
	TRACE(@"");

	NSFileManager	*fm		= [NSFileManager defaultManager];
	NSString		*path	= [JMDevKit appDocumentFilePath:@"pbdatabase.db"];
	FMDatabase		*db		= nil;
	
	if ([fm fileExistsAtPath:path] == NO)
	{
		TRACE(@"not exists database file");
		
		[fm release];
		
		return NO;
	}
	
	[fm release];
	
	db = [FMDatabase databaseWithPath:path];
	[db open];
	
	if ([db tableExists:@"bookContent"] == NO)
	{
		TRACE(@"not exists bookmaster table or bookvolume table");
		
		[db close];
		
		return NO;
	}
	
	[db close];
	
	return YES;
}

+ (void) initDatabase
{
	TRACE(@"");

	NSFileManager	*fm		= [NSFileManager defaultManager];
	NSString		*path	= [JMDevKit appDocumentFilePath:@"pbdatabase.db"];
	FMDatabase		*db		= nil;
	
	if ([fm fileExistsAtPath:path] == YES)
	{
		TRACE(@"not exists database file");
		
		[fm removeItemAtPath:path error:nil];
	}
	
	[fm release];
	
	db = [FMDatabase databaseWithPath:path];
	
	[db open];
	
	[db setShouldCacheStatements:YES];
	
	[db executeUpdate:@"create table bookContent (bill_code text, master_number text, file_number text, main_group text, sub_group text, title text, writer text, volume_number text, file_path_remote text, file_path_local text, content_type text, drm_type text, end_date text, counter text, pre_drm text, read_state integer, read_position integer, download_status integer, image_path text, title_image blob)"];	
	[db close];
}

+ (FMDatabase *) getDatabase
{
	TRACE(@"");

	if ([PBDatabase existsDatabase] == NO)
	{
		TRACE(@"not exists database");

		return nil;
	}
	
	NSString		*path	= [JMDevKit appDocumentFilePath:@"pbdatabase.db"];
	FMDatabase		*db		= nil;
	
	db = [FMDatabase databaseWithPath:path];
	
	[db setShouldCacheStatements:YES];
	[db open];
	
	return [db retain];
}


+ (BOOL) existsBookContent:(NSString*)masterNumber fileNumber:(NSString*)fileNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler = nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookContent where master_number='%@' and file_number='%@'", masterNumber, fileNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		[rs close];
		[db close];
		
		return YES;
	}
	
	[rs close];
	[db close];
	
	return NO;
}

+ (ContentDownloadStatus) getBookContentDownloadStatus:(NSString*)masterNumber fileNumber:(NSString*)fileNumber
{
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler = nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookContent where master_number='%@' and file_number='%@'", masterNumber, fileNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		ContentDownloadStatus downloadStatus = (ContentDownloadStatus)[rs intForColumn:@"download_status"];
		
		[rs close];
		[db close];

		NSLog(@"masterNumber=[%@], fileNumber=[%@], ContentDownloadStatus=[%d]", masterNumber, fileNumber, downloadStatus);
		
		return downloadStatus;
	}
	
	[rs close];
	[db close];
	
	return ContentDownloadStatusNone;
}

+ (NSDictionary *) getBookContent:(NSString*)masterNumber fileNumber:(NSString*)fileNumber
{
	TRACE(@"");
	
	if ([PBDatabase existsBookContent:masterNumber fileNumber:fileNumber] == NO)
	{
		TRACE(@"not exists record of master number = %@", masterNumber);
		
		return nil;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler is nil");
		
		return nil;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookContent where master_number = '%@' and file_number = '%@'", masterNumber, fileNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		NSMutableDictionary *	dicResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												 [rs stringForColumn:@"bill_code"]			, @"billcode"		  ,
												 [rs stringForColumn:@"master_number"]		, @"master_no"		  ,
												 [rs stringForColumn:@"file_number"]		, @"file_no"		  , 
												 [rs stringForColumn:@"main_group"]			, @"main_group"		  , 
												 [rs stringForColumn:@"sub_group"]			, @"sub_group"		  , 									  
												 [rs stringForColumn:@"title"]				, @"title"			  , 
												 [rs stringForColumn:@"writer"]				, @"writer"			  ,
												 [rs stringForColumn:@"volume_number"]		, @"volume_number"	  ,
												 [rs stringForColumn:@"file_path_remote"]	, @"file_path_remote" ,
												 [rs stringForColumn:@"file_path_local"]	, @"file_path_local"  ,									 
												 [rs stringForColumn:@"content_type"]		, @"content_type"	  ,
												 [rs stringForColumn:@"drm_type"]			, @"drm_type"		  ,
												 [rs stringForColumn:@"end_date"]			, @"enddt"			  ,
												 [rs stringForColumn:@"counter"]			, @"counter"		  , 											 
												 [rs stringForColumn:@"pre_drm"]		    , @"pre_drm"		  ,
												 [NSNumber numberWithInteger:[rs intForColumn:@"read_state"]]	  , @"read_state"	  , 
												 [NSNumber numberWithInteger:[rs intForColumn:@"read_position"]]  , @"read_position"  , 
												 [NSNumber numberWithInteger:[rs intForColumn:@"download_status"]], @"download_status",
												 [rs stringForColumn:@"image_path"]			, @"image_path"		  ,
												 nil];						
		
		NSData* titleImage = [rs dataForColumn:@"title_image"];
		if (titleImage != nil) {
			[dicResult setObject:titleImage forKey:@"title_image"];
		}
		
		[rs close];
		[db close];
		
		return dicResult;
	}
	
	[rs close];
	[db close];
	
	return nil;	
}

+ (NSMutableArray*) getBookContentItems
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return nil;
	}
	
	NSMutableArray *	arrResult	= [[NSMutableArray alloc] initWithCapacity:0];
	NSString *			sql			= nil; 
	
	sql = [NSString stringWithFormat:@"select * from bookContent"];
	
	
	FMResultSet * rs = [db executeQuery:sql];
	
	while ([rs next])
	{		
		NSMutableDictionary *	dicItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [rs stringForColumn:@"bill_code"]			, @"billcode"		  ,
									 [rs stringForColumn:@"master_number"]		, @"master_no"		  ,
									 [rs stringForColumn:@"file_number"]		, @"file_no"		  , 
									 [rs stringForColumn:@"main_group"]			, @"main_group"		  , 
									 [rs stringForColumn:@"sub_group"]			, @"sub_group"		  , 									  
									 [rs stringForColumn:@"title"]				, @"title"			  , 
									 [rs stringForColumn:@"writer"]				, @"writer"			  ,
									 [rs stringForColumn:@"volume_number"]		, @"volume_number"	  ,
									 [rs stringForColumn:@"file_path_remote"]	, @"file_path_remote" ,
									 [rs stringForColumn:@"file_path_local"]	, @"file_path_local"  ,									 
									 [rs stringForColumn:@"content_type"]		, @"content_type"	  ,
								     [rs stringForColumn:@"drm_type"]			, @"drm_type"		  ,
								     [rs stringForColumn:@"end_date"]			, @"enddt"			  ,
									 [rs stringForColumn:@"counter"]			, @"counter"		  , 
									 [rs stringForColumn:@"pre_drm"]			, @"pre_drm"		  ,										   
									 [NSNumber numberWithInteger:[rs intForColumn:@"read_state"]]	  , @"read_state"	  , 
									 [NSNumber numberWithInteger:[rs intForColumn:@"read_position"]]  , @"read_position"  , 
									 [NSNumber numberWithInteger:[rs intForColumn:@"download_status"]], @"download_status", 									 
									 [rs stringForColumn:@"image_path"]			, @"image_path"		  ,
									 nil];
		
		NSData* titleImage = [rs dataForColumn:@"title_image"];
		if (titleImage != nil) {
			[dicItem setObject:titleImage forKey:@"title_image"];
		}
		
//		NSLog(@"dicItem=[%@]", dicItem);
		
		[arrResult addObject:dicItem];
	}
	
	[rs close];
	[db close];
	
	return arrResult;
}

+ (NSInteger) getBookReadPosition:(NSString*)masterNumber filaNumber:(NSString*)fileNumber
{
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler = nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookContent where master_number='%@' and file_number='%@'", masterNumber, fileNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		NSInteger readPosition = (ContentDownloadStatus)[rs intForColumn:@"read_position"];
		
		[rs close];
		[db close];
		
		NSLog(@"masterNumber=[%@], fileNumber=[%@], readPosition=[%d]", masterNumber, fileNumber, readPosition);
		
		return readPosition;
	}
	
	[rs close];
	[db close];
	
	return 0;
}

+ (NSDictionary *) getBookContentWithVolumeNumber:(NSString *)volumeNumber masterNumber:(NSString*)masterNumber
{
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler is nil");
		
		return nil;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookContent where master_number=? and volume_number=?", masterNumber, volumeNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		NSDictionary *	dicResult = [NSDictionary dictionaryWithObjectsAndKeys:
										 [rs stringForColumn:@"bill_code"]			, @"billcode"		  ,
										 [rs stringForColumn:@"master_number"]		, @"master_no"		  ,
										 [rs stringForColumn:@"file_number"]		, @"file_no"		  , 
										 [rs stringForColumn:@"main_group"]			, @"main_group"		  , 
										 [rs stringForColumn:@"sub_group"]			, @"sub_group"		  , 									  
										 [rs stringForColumn:@"title"]				, @"title"			  , 
										 [rs stringForColumn:@"writer"]				, @"writer"			  ,
										 [rs stringForColumn:@"volume_number"]		, @"volume_number"	  ,
										 [rs stringForColumn:@"file_path_remote"]	, @"file_path_remote" ,
										 [rs stringForColumn:@"file_path_local"]	, @"file_path_local"  ,									 
										 [rs stringForColumn:@"content_type"]		, @"content_type"	  ,
										 [rs stringForColumn:@"drm_type"]			, @"drm_type"		  ,
										 [rs stringForColumn:@"end_date"]			, @"enddt"			  ,
										 [rs stringForColumn:@"counter"]			, @"counter"		  , 
										 [rs stringForColumn:@"pre_drm"]		    , @"pre_drm"		  ,
										 [NSNumber numberWithInteger:[rs intForColumn:@"read_state"]]	  , @"read_state"	  , 
										 [NSNumber numberWithInteger:[rs intForColumn:@"read_position"]]  , @"read_position"  , 
										 [NSNumber numberWithInteger:[rs intForColumn:@"download_status"]], @"download_status",
										 [rs stringForColumn:@"image_path"]			, @"image_path"		  ,
										 nil];								
		[rs close];
		[db close];
		
		return dicResult;
	}
	
	[rs close];
	[db close];
	
	return nil;		
}


+ (BOOL) insertBookContent:(NSString *)billCode
			  masterNumber:(NSString *)masterNumber
				fileNumber:(NSString *)fileNumber
				 mainGroup:(NSString *)mainGroup 
				  subGroup:(NSString *)subGroup 
					 title:(NSString *)title 
					writer:(NSString *)writer 
			  volumeNumber:(NSString *)volumeNumber
			filePathRemote:(NSString *)filePathRemote
			 filePathLocal:(NSString *)filePathLocal
			   contentType:(NSString *)contentType
				   drmType:(NSString *)drmType
				   endDate:(NSString *)endDate
				   counter:(NSString *)counter
					preDrm:(NSString *)preDrm
				 readState:(NSInteger)readState
			  readPosition:(NSInteger)readPosition
			downloadStatus:(NSInteger)downloadStatus
				 imagePath:(NSString *)imagePath 
				titleImage:(NSData *)titleImage
{
	TRACE(@"");
	
	if ([PBDatabase existsBookContent:masterNumber fileNumber:fileNumber] == YES)
	{
		return [PBDatabase updateBookContent:billCode
								masterNumber:masterNumber
								  fileNumber:fileNumber
								   mainGroup:mainGroup 
									subGroup:subGroup 
									   title:title 
									  writer:writer 
								volumeNumber:volumeNumber
							  filePathRemote:filePathRemote
							   filePathLocal:filePathLocal
								 contentType:contentType
									 drmType:drmType
									 endDate:endDate
									 counter:counter
									  preDrm:preDrm
								   readState:readState
								readPosition:readPosition
							  downloadStatus:downloadStatus
								   imagePath:imagePath 
								  titleImage:titleImage];
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	[db beginTransaction];
	[db executeUpdate:@"insert into bookContent (bill_code, master_number, file_number, main_group, sub_group, title, writer, volume_number, file_path_remote, file_path_local, content_type, drm_type, end_date, counter, pre_drm, read_state, read_position, download_status, image_path, title_image) values (?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?)",
	 billCode, masterNumber, fileNumber, mainGroup, subGroup, title, writer, volumeNumber, filePathRemote, filePathLocal, contentType, drmType, endDate, counter, preDrm, readState, readPosition, downloadStatus, imagePath, titleImage];
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) updateBookContent:(NSString *)billCode
			  masterNumber:(NSString *)masterNumber
				fileNumber:(NSString *)fileNumber
				 mainGroup:(NSString *)mainGroup 
				  subGroup:(NSString *)subGroup 
					 title:(NSString *)title 
					writer:(NSString *)writer 
			  volumeNumber:(NSString *)volumeNumber
			filePathRemote:(NSString *)filePathRemote
			 filePathLocal:(NSString *)filePathLocal
			   contentType:(NSString *)contentType
				   drmType:(NSString *)drmType
				   endDate:(NSString *)endDate
				   counter:(NSString *)counter
					preDrm:(NSString *)preDrm
				 readState:(NSInteger)readState
			  readPosition:(NSInteger)readPosition
			downloadStatus:(NSInteger)downloadStatus
				 imagePath:(NSString *)imagePath 
				titleImage:(NSData *)titleImage
{
	TRACE(@"");
	
	if ([PBDatabase existsBookContent:masterNumber fileNumber:fileNumber] == NO)
	{
		return [PBDatabase insertBookContent:billCode
								masterNumber:masterNumber
								  fileNumber:fileNumber
								   mainGroup:mainGroup 
									subGroup:subGroup 
									   title:title 
									  writer:writer 
								volumeNumber:volumeNumber
							  filePathRemote:filePathRemote
							   filePathLocal:filePathLocal
								 contentType:contentType
									 drmType:drmType
									 endDate:endDate
									 counter:counter	
									  preDrm:preDrm
								   readState:readState
								readPosition:readPosition
							  downloadStatus:downloadStatus
								   imagePath:imagePath 
								  titleImage:titleImage];
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	[db beginTransaction];
	
	[db executeUpdate:@"update bookContent set main_group=?, sub_group=?, title=?, writer=?, volume_number=?, file_path_remote=?, file_path_local=?, content_type=?, drm_type=?, end_date=?, counter=?, pre_drm=?, read_state=?, read_position=?, download_status=?, image_path=?, title_image=? where master_number=? and file_number=?",
	 mainGroup, subGroup, title, writer, volumeNumber, filePathRemote, filePathLocal, contentType, drmType, endDate, counter, preDrm, [NSNumber numberWithInteger:readState], [NSNumber numberWithInteger:readPosition], [NSNumber numberWithInteger:downloadStatus], imagePath, titleImage, masterNumber, fileNumber];
	
	[db commit];
	[db close];
	
	return YES;	
}

+ (BOOL) deleteBookContent:(NSString*)masterNumber fileNumber:(NSString*)fileNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	NSString *	sql = [NSString stringWithFormat:@"delete from bookContent where master_number='%@' and file_number='%@'", masterNumber, fileNumber];
	
	[db beginTransaction];
	[db executeUpdate:sql];
	[db commit];
	[db close];
	
	return YES;	
}

+ (BOOL) updateBookContentWithReadState:(NSString*)masterNumber fileNumber:(NSString*)fileNumber readState:(NSInteger)readState readPosition:(NSInteger)readPosition
{
	TRACE(@"");
	
	if ([PBDatabase existsBookContent:masterNumber fileNumber:fileNumber] == NO)
	{
		TRACE(@"not exists record of file number = %@", fileNumber);
		
		return NO;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	[db beginTransaction];
	
	[db executeUpdate:@"update bookContent set read_state=?, read_position=? where master_number=? and file_number=?", [NSNumber numberWithInteger:readState], [NSNumber numberWithInteger:readPosition], masterNumber, fileNumber];
	
	[db commit];
	[db close];
	
	return YES;	
}

+ (BOOL) updateBookContentWithDownloadStatus:(NSString*)masterNumber fileNumber:(NSString*)fileNumber downloadStatus:(NSInteger)downloadStatus
{
	NSLog(@"masterNumber=[%@], fileNumber=[%@], ContentDownloadStatus=[%d]", masterNumber, fileNumber, downloadStatus);
	
	if ([PBDatabase existsBookContent:masterNumber fileNumber:fileNumber] == NO)
	{
		TRACE(@"not exists record of file number = %@", fileNumber);
		
		return NO;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	[db beginTransaction];
	
	[db executeUpdate:@"update bookContent set download_status=? where master_number=? and file_number=?", [NSNumber numberWithInteger:downloadStatus], masterNumber, fileNumber];
	
	[db commit];
	[db close];
	
	return YES;
}

////////////////////////////////////////////////////////////////////////////
+ (BOOL) existsBookMasterForMasterNumber:(NSString *)masterNumber
{
	TRACE(@"");

	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler = nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookmaster where master_number = '%@'", masterNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		[rs close];
		[db close];
		
		return YES;
	}
	
	[rs close];
	[db close];
	
	return NO;
}

+ (NSDictionary *) getBookMasterForMasterNumber:(NSString *)masterNumber
{
	TRACE(@"");

	if ([PBDatabase existsBookMasterForMasterNumber:masterNumber] == NO)
	{
		TRACE(@"not exists record of master number = %@", masterNumber);
		
		return nil;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handler is nil");
		
		return nil;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookmaster where master_number = '%@'", masterNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		NSDictionary *	dicResult = [NSDictionary dictionaryWithObjectsAndKeys:
									 [rs stringForColumn:@"title"], @"title", 
									 [NSNumber numberWithInteger:[rs intForColumn:@"total_volumes"]], @"total_volumes", 
									 [rs stringForColumn:@"writer"], @"writer", 
									 [rs stringForColumn:@"illustrator"], @"illustrator", 
									 [rs stringForColumn:@"main_group"], @"main_group", 
									 [rs stringForColumn:@"sub_group"], @"sub_group", 
									 [rs stringForColumn:@"summary_content"], @"summary_content", 
									 [rs stringForColumn:@"category1"], @"category1", 
									 [rs stringForColumn:@"category2"], @"category2", 
									 [rs stringForColumn:@"image_path"], @"image_path", 
									 [rs dataForColumn:@"title_image"], @"title_image", 
									 nil];
				
		[rs close];
		[db close];
		
		return dicResult;
	}
	
	[rs close];
	[db close];
	
	return nil;
}

+ (NSMutableArray *) getItemsByBookMasterWithCondition:(NSString *)condition
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return nil;
	}
	
	NSMutableArray *	arrResult	= [[NSMutableArray alloc] initWithCapacity:0];
	NSString *			sql			= nil; 
	
	if (condition == nil)
	{
		sql = [NSString stringWithFormat:@"select * from bookmaster"];
	}
	else if ([condition length] == 0)
	{
		sql = [NSString stringWithFormat:@"select * from bookmaster"];
	}
	else 
	{
		sql = [NSString stringWithFormat:@"select * from bookmaster where %@", condition];
	}
	
	FMResultSet * rs = [db executeQuery:sql];

	while ([rs next])
	{
		NSDictionary *	dicItem = [NSDictionary dictionaryWithObjectsAndKeys:
									 [rs stringForColumn:@"master_number"], @"master_number", 
									 [rs stringForColumn:@"title"], @"title", 
									 [NSNumber numberWithInteger:[rs intForColumn:@"total_volumes"]], @"total_volumes", 
									 [rs stringForColumn:@"writer"], @"writer", 
									 [rs stringForColumn:@"illustrator"], @"illustrator", 
									 [rs stringForColumn:@"main_group"], @"main_group", 
									 [rs stringForColumn:@"sub_group"], @"sub_group", 
									 [rs stringForColumn:@"summary_content"], @"summary_content", 
									 [rs stringForColumn:@"category1"], @"category1", 
									 [rs stringForColumn:@"category2"], @"category2", 
									 [rs stringForColumn:@"image_path"], @"image_path", 
									 [rs dataForColumn:@"title_image"], @"title_image", 
									 nil];
		
		[arrResult addObject:dicItem];
	}
	
	[rs close];
	[db close];
	
	return arrResult;
}


+ (BOOL) insertBookMasterWithMasterNumber:(NSString *)masterNumber 
									title:(NSString *)title 
							 totalVolumes:(NSInteger)totalVolumes 
								   writer:(NSString *)writer 
							  illustrator:(NSString *)illustrator 
								mainGroup:(NSString *)mainGroup 
								 subGroup:(NSString *)subGroup 
						   summaryContent:(NSString *)summaryContent 
								category1:(NSString *)category1 
								category2:(NSString *)category2 
								imagePath:(NSString *)imagePath 
							   titleImage:(NSData *)titleImage
{
	TRACE(@"");
	
	if ([PBDatabase existsBookMasterForMasterNumber:masterNumber] == YES)
	{
		return [PBDatabase updateBookMasterForMasterNumber:masterNumber 
													 title:title 
											  totalVolumes:totalVolumes 
													writer:writer 
											   illustrator:illustrator 
												 mainGroup:mainGroup 
												  subGroup:subGroup 
											summaryContent:summaryContent 
												 category1:category1 
												 category2:category2 
												 imagePath:imagePath 
												titleImage:titleImage];
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}

	[db beginTransaction];
	[db executeUpdate:@"insert into bookmaster (master_number, title, total_volumes, writer, illustrator, main_group, sub_group, summary_content, category1, category2, image_path, title_image) values (?,?,?,?,?,?,?,?,?,?,?,?)",
	 masterNumber, title, [NSNumber numberWithInteger:totalVolumes], writer, illustrator, mainGroup, subGroup, summaryContent, category1, category2, imagePath, titleImage];
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) updateBookMasterForMasterNumber:(NSString *)masterNumber 
									title:(NSString *)title 
							 totalVolumes:(NSInteger)totalVolumes 
								   writer:(NSString *)writer 
							  illustrator:(NSString *)illustrator 
								mainGroup:(NSString *)mainGroup 
								 subGroup:(NSString *)subGroup 
						   summaryContent:(NSString *)summaryContent 
								category1:(NSString *)category1 
								category2:(NSString *)category2 
								imagePath:(NSString *)imagePath 
							   titleImage:(NSData *)titleImage
{
	TRACE(@"");
	
	if ([PBDatabase existsBookMasterForMasterNumber:masterNumber] == NO)
	{
		return [PBDatabase insertBookMasterWithMasterNumber:masterNumber 
													  title:title 
											   totalVolumes:totalVolumes 
													 writer:writer 
												illustrator:illustrator 
												  mainGroup:mainGroup 
												   subGroup:subGroup 
											 summaryContent:summaryContent 
												  category1:category1 
												  category2:category2 
												  imagePath:imagePath 
												 titleImage:titleImage];
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	[db beginTransaction];

	[db executeUpdate:@"update bookmaster set title = ?, total_volumes = ?, writer = ?, illustrator = ?, main_group = ?, sub_group = ?, category1 = ?, category2 = ?, image_path = ?, title_image = ? where master_number = ?",
		title, [NSNumber numberWithInteger:totalVolumes], writer, illustrator, mainGroup, subGroup, summaryContent, category1, category2, imagePath, titleImage, masterNumber];
	
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) deleteBookMasterForMasterNumber:(NSString *)masterNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	NSString *	sql = [NSString stringWithFormat:@"delete from bookmaster where master_number = '%@'", masterNumber];
	
	[db beginTransaction];
	[db executeUpdate:sql];
	[db commit];
	[db close];
	
	return YES;
}

////////////////////////////////////////////////////////////////////////////
+ (BOOL) existsBookVolumeForMasterNumber:(NSString *)masterNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookvolume where master_number = '%@'", masterNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		[rs close];
		[db close];
		
		return YES;
	}
	
	[rs close];
	[db close];
	
	return NO;
}

+ (BOOL) existsBookVolumeForFileNumber:(NSString *)fileNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookvolume where file_number = '%@'", fileNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		[rs close];
		[db close];
		
		return YES;
	}
	
	[rs close];
	[db close];
	
	return NO;
}

+ (BOOL) existsBookVolumeForVolumeNumber:(NSString *)volumeNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	NSString *		sql = [NSString stringWithFormat:@"select * from bookvolume where volume_number = '%@'", volumeNumber];
	FMResultSet *	rs	= [db executeQuery:sql];
	
	if ([rs next])
	{
		[rs close];
		[db close];
		
		return YES;
	}
	
	[rs close];
	[db close];
	
	return NO;
}

+ (NSMutableArray *) getBookVolumeForMasterNumber:(NSString *)masterNumber
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForMasterNumber:masterNumber] == NO)
	{
		TRACE(@"not exists record of master number = %@", masterNumber);
		
		return nil;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return nil;
	}

	NSMutableArray *	arrResult	= [[NSMutableArray alloc] initWithCapacity:0];
	NSString *			sql			= [NSString stringWithFormat:@"select * from bookvolume where master_number = '%@' order by volume_number", masterNumber];
	NSLog(@"sql : %@", sql);
	//FMResultSet *		rs			= [db executeQuery:@"select * from bookvolume where master_number = ? order by volume_number", masterNumber];
	FMResultSet *		rs			= [db executeQuery:sql];

	while ([rs next])
	{
		NSMutableDictionary *	dicRecord = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [rs stringForColumn:@"master_number"], @"master_number", 
									 [rs stringForColumn:@"file_number"], @"file_number", 
									 [rs stringForColumn:@"volume_number"], @"volume_number", 
									 [NSNumber numberWithInteger:[rs intForColumn:@"pre_drm"]], @"pre_drm", 
									 [rs stringForColumn:@"file_path_remote"], @"file_path_remote", 
									 [rs stringForColumn:@"file_path_local"], @"file_path_local", 
									 [rs stringForColumn:@"content_type"], @"content_type", 
									 [NSNumber numberWithInteger:[rs intForColumn:@"download_status"]], @"download_status", 
									 [NSNumber numberWithInteger:[rs intForColumn:@"read_state"]], @"read_state", 
									 [NSNumber numberWithInteger:[rs intForColumn:@"read_position"]], @"read_position", 
									 nil];
		
		NSLog(@"bookvolume : %@", dicRecord);
		[arrResult addObject:dicRecord];
	}
	
	[rs close];
	[db close];
	
	if ([arrResult count] == 0)
	{
		[arrResult release];
		
		return nil;
	}
	
	return [arrResult retain];
}

+ (NSDictionary *) getBookVolumeForFileNumber:(NSString *)fileNumber
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForFileNumber:fileNumber] == NO)
	{
		TRACE(@"not exists record of file number = %@", fileNumber);
		
		return nil;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return nil;
	}

	FMResultSet *	rs = [db executeQuery:@"select * from bookvolume where file_number = ?", fileNumber];
	
	if ([rs next])
	{
		NSDictionary * dicResult = [NSDictionary dictionaryWithObjectsAndKeys:
									[rs stringForColumn:@"master_number"], @"master_number",
									[rs stringForColumn:@"file_number"], @"file_number", 
									[rs stringForColumn:@"volume_number"], @"volume_number", 
									[NSNumber numberWithInteger:[rs intForColumn:@"pre_drm"]], @"pre_drm", 
									[rs stringForColumn:@"file_path_remote"], @"file_path_remote", 
									[rs stringForColumn:@"file_path_local"], @"file_path_local", 
									[rs stringForColumn:@"content_type"], @"content_type", 
									[NSNumber numberWithInteger:[rs intForColumn:@"download_status"]], @"download_status", 
									[NSNumber numberWithInteger:[rs intForColumn:@"read_state"]], @"read_state", 
									[NSNumber numberWithInteger:[rs intForColumn:@"read_position"]], @"read_position", 
									nil];
		
		[rs close];
		[db close];
		
		NSLog(@"%@", dicResult);
		
		return dicResult;
	}
	
	[rs close];
	[db close];
	
	return nil;
}

+ (NSDictionary *) getBookVolumeForVolumeNumber:(NSString *)volumeNumber
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForVolumeNumber:volumeNumber] == NO)
	{
		TRACE(@"not exists record of volume number = %@", volumeNumber);
		
		return nil;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return nil;
	}
	
	FMResultSet *	rs = [db executeQuery:@"select * from bookvolume where volume_number = ?", volumeNumber];
	
	if ([rs next])
	{
		NSDictionary * dicResult = [NSDictionary dictionaryWithObjectsAndKeys:
									[rs stringForColumn:@"master_number"], @"master_number",
									[rs stringForColumn:@"file_number"], @"file_number", 
									[rs stringForColumn:@"volume_number"], @"volume_number", 
									[NSNumber numberWithInteger:[rs intForColumn:@"pre_drm"]], @"pre_drm", 
									[rs stringForColumn:@"file_path_remote"], @"file_path_remote", 
									[rs stringForColumn:@"file_path_local"], @"file_path_local", 
									[rs stringForColumn:@"content_type"], @"content_type", 
									[NSNumber numberWithInteger:[rs intForColumn:@"download_status"]], @"download_status", 
									[NSNumber numberWithInteger:[rs intForColumn:@"read_state"]], @"read_state", 
									[NSNumber numberWithInteger:[rs intForColumn:@"read_position"]], @"read_position", 
									nil];
		
		[rs close];
		[db close];
		
		return dicResult;
	}
	
	[rs close];
	[db close];
	
	return nil;
}

+ (BOOL) insertBookVolumeWithMasterNumber:(NSString *)masterNumber 
							   fileNumber:(NSString *)fileNumber 
							 volumeNumber:(NSString *)volumeNumber 
								   preDrm:(NSInteger)preDrm 
						   filePathRemote:(NSString *)filePathRemote 
							filePathLocal:(NSString *)filePathLocal 
							  contentType:(NSString *)contentType 
						   downloadStatus:(NSInteger)downloadStatus 
								readState:(NSInteger)readState 
							 readPosition:(NSInteger)readPosition
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForFileNumber:fileNumber] == YES)
	{
		return [PBDatabase updateBookVolumeForMasterNumber:masterNumber 
												fileNumber:fileNumber 
											  volumeNumber:volumeNumber 
													preDrm:preDrm 
											filePathRemote:filePathRemote 
											 filePathLocal:filePathLocal 
											   contentType:contentType 
											downloadStatus:downloadStatus 
												 readState:readState 
											  readPosition:readPosition];
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return NO;
	}
	
	[db beginTransaction];
	
	[db executeUpdate:@"insert into bookvolume (master_number, file_number, volume_number, pre_drm, file_path_remote, file_path_local, content_type, download_status, read_state, read_position) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
				masterNumber, 
				fileNumber, 
				volumeNumber, 
				[NSNumber numberWithInteger:preDrm], 
				filePathRemote, 
				filePathLocal, 
				contentType, 
				[NSNumber numberWithInteger:downloadStatus], 
				[NSNumber numberWithInteger:readState], 
				[NSNumber numberWithInteger:readPosition]];
	
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) updateBookVolumeForMasterNumber:(NSString *)masterNumber 
							   fileNumber:(NSString *)fileNumber 
							 volumeNumber:(NSString *)volumeNumber 
								   preDrm:(NSInteger)preDrm 
						   filePathRemote:(NSString *)filePathRemote 
							filePathLocal:(NSString *)filePathLocal 
							  contentType:(NSString *)contentType 
						   downloadStatus:(NSInteger)downloadStatus 
								readState:(NSInteger)readState 
							 readPosition:(NSInteger)readPosition
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForFileNumber:fileNumber] == NO)
	{
		return [PBDatabase insertBookVolumeWithMasterNumber:masterNumber 
												 fileNumber:fileNumber 
											   volumeNumber:volumeNumber 
													 preDrm:preDrm 
											 filePathRemote:filePathRemote 
											  filePathLocal:filePathLocal 
												contentType:contentType 
											 downloadStatus:downloadStatus 
												  readState:readState 
											   readPosition:readPosition];
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return NO;
	}
	
	[db beginTransaction];
	
	[db executeUpdate:@"update bookvolume set master_number = ?, volume_number = ?, pre_drm = ?, file_path_remote = ?, file_path_local = ?, content_type = ?, download_status = ?, read_state = ?, read_position = ? where file_number = ?",
					masterNumber, 
					volumeNumber, 
					[NSNumber numberWithInteger:preDrm], 
					filePathRemote, 
					filePathLocal, 
					contentType, 
					[NSNumber numberWithInteger:downloadStatus], 
					[NSNumber numberWithInteger:readState], 
					[NSNumber numberWithInteger:readPosition],
					fileNumber];
	
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) updateBookVolumeWithFileNumber:(NSString *)fileNumber readState:(NSInteger)readState readPosition:(NSInteger)readPosition
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForFileNumber:fileNumber] == NO)
	{
		TRACE(@"not exists record of file number = %@", fileNumber);
		
		return NO;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return NO;
	}
	
	[db beginTransaction];

	[db executeUpdate:@"update bookvolume set read_state = ?, read_position = ? where file_number = ?", [NSNumber numberWithInteger:readState], [NSNumber numberWithInteger:readPosition], fileNumber];
	
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) updateBookVolumeWithFileNumber:(NSString *)fileNumber downloadStatus:(NSInteger)downloadStatus
{
	TRACE(@"");
	
	if ([PBDatabase existsBookVolumeForFileNumber:fileNumber] == NO)
	{
		TRACE(@"not exists record of file number = %@", fileNumber);
		
		return NO;
	}
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");
		
		return NO;
	}
	
	[db beginTransaction];
	
	[db executeUpdate:@"update bookvolume set download_status = ? where file_number = ?", [NSNumber numberWithInteger:downloadStatus], fileNumber];
	
	[db commit];
	[db close];
	
	return YES;
}


+ (BOOL) deleteBookVolumeForMasterNumber:(NSString *)masterNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return NO;
	}
	
	NSString *	sql = [NSString stringWithFormat:@"delete from bookvolume where master_number = '%@'", masterNumber];
	
	[db beginTransaction];
	[db executeUpdate:sql];
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) deleteBookVolumeForFileNumber:(NSString *)fileNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return NO;
	}
	
	NSString *	sql = [NSString stringWithFormat:@"delete from bookvolume where file_number = '%@'", fileNumber];
	
	[db beginTransaction];
	[db executeUpdate:sql];
	[db commit];
	[db close];
	
	return YES;
}

+ (BOOL) deleteBookVolumeForVolumeNumber:(NSString *)volumeNumber
{
	TRACE(@"");
	
	FMDatabase *	db = [PBDatabase getDatabase];
	if (db == nil)
	{
		TRACE(@"db handle is nil");

		return NO;
	}
	
	NSString *	sql = [NSString stringWithFormat:@"delete from bookvolume where volume_number = '%@'", volumeNumber];
	
	[db beginTransaction];
	[db executeUpdate:sql];
	[db commit];
	[db close];
	
	return YES;
}

@end
