//
//  ViewController.m
//  DataBaseTest
//
//  Created by sun jianfeng on 2/26/13.
//  Copyright (c) 2013 sun jianfeng. All rights reserved.
//

#import "ViewController.h"
#define DATA_FILE @"file.sqlite"
#import <sqlite3.h>
@interface ViewController ()

@end

@implementation ViewController
@synthesize  selectBtn,deleteBtn,inserBtn,imageView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)dataFilePath {
    NSArray * myPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,
                                                             NSUserDomainMask, YES); NSString * myDocPath = [myPaths objectAtIndex:0];
    NSString *filename = [myDocPath stringByAppendingPathComponent:DATA_FILE];
    return filename;
}
sqlite3 * sqlite;
-(void)openDataBase{
    NSString* file=[self dataFilePath];
    if (sqlite3_open([file UTF8String], &sqlite)!=SQLITE_OK) {
        NSLog(@"打开数据库失败");
        sqlite3_close(sqlite);
        return;
    }else{
        char * error=nil;
        char* sql="create table if not exists imageTable (imageID INTEGER primary key autoincrement,imageName text,imageData blob,time date)";
        NSLog(@"创建表的语句 =%s",sql);
        
        if (sqlite3_exec(sqlite, sql, NULL, NULL, &error)!=SQLITE_OK) {
            NSLog(@"创建表失败");
            NSLog(@"error=%s",error);
        }
    }
}




-(void)writeImageDataWithDescription:(NSString*)description andData:(NSData*)data{
    sqlite3_stmt * stmt;
    const char* sql="insert into imageTable (imageName,imageData,time) values(?,?,date('2013-03-05','localtime'))";
    //NSString* st=[NSString stringWithFormat:@"insert into imageTable (imageName,imageData) values('%@',0)",description];
    if (sqlite3_prepare_v2(sqlite, sql, -1, &stmt, NULL)==SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [description UTF8String], -1, NULL);
        sqlite3_bind_blob(stmt, 2, [data bytes], [data length], NULL);
        int result=sqlite3_step(stmt);
        if (result==SQLITE_DONE) {
            NSLog(@"插入成功");
            
        }
         NSLog(@"%d",result);
        sqlite3_finalize(stmt);

    }
//    char* error;
//    if (sqlite3_exec(sqlite, [st UTF8String], NULL, NULL, &error)==SQLITE_OK) {
//        NSLog(@"插入成功 !ddd");
//    }
//    else{
//        printf("error= %s",error);
//    }
}
-(NSMutableArray *)getALLImageData{
    NSMutableArray * mutale=[[NSMutableArray alloc]initWithCapacity:0];
    sqlite3_stmt* stmt;
    const char* sql="select * from imageTable where time>'2012-01-01' and time < '2013-06-01' ";
    if(sqlite3_prepare_v2(sqlite, sql, -1, &stmt, NULL)==SQLITE_OK){
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            int index=sqlite3_column_int(stmt, 0);
            char *name = (char *) sqlite3_column_text(stmt, 1);
            NSString *nameStr = [[NSString alloc] initWithUTF8String: name];
            int bytes=sqlite3_column_bytes(stmt, 2);
            const void* data=sqlite3_column_blob(stmt, 2);
            if (bytes>0&&data!=NULL) {
                NSData* imagedata=[NSData dataWithBytes:data length:bytes];
                NSDictionary* dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"imageID",nameStr,@"imageName",imagedata,@"imageData", nil];
                [mutale addObject:dic];
            }
            char* time=(char*)sqlite3_column_text(stmt, 3);
            NSLog(@"%s",time);
        }
    }
    NSLog(@"返回了%d条数据",[mutale count]);
    return mutale;
}
int indexs;
-(IBAction)btnPressed:(UIButton*)sender{
    switch (sender.tag) {
        case 0:// inser
        {
            indexs++;
            NSString* desc=[NSString stringWithFormat:@"description %d",indexs];
             NSData *image=UIImagePNGRepresentation([UIImage imageNamed:@"sun.png"]);
            [self writeImageDataWithDescription:desc andData:image];
            break;
         }
            case 1://select
        {
            NSMutableArray * arr=[self getALLImageData];
            if ([arr count]>0) {
                NSDictionary* dic=[arr objectAtIndex:0];
                NSLog(@"imageID =%@",[dic objectForKey:@"imageID"]);
                 NSLog(@"imageDesc =%@",[dic objectForKey:@"imageName"]);
                NSData* data=[dic objectForKey:@"imageData"];
               [ self.imageView setImage:[UIImage imageWithData:data]];
            }
            break;
        }
            case 2://delete{
            
        {
            
            break;
        }
        default:
            break;
    }
}

static dispatch_queue_t queue;
static int lastReadCount = 0;
static int readCount = 0;
static int lastWriteCount = 0;
static int writeCount = 0;

- (void)count {
    int lastRead = lastReadCount;
    int lastWrite = lastWriteCount;
    lastReadCount = readCount;
    lastWriteCount = writeCount;
    NSLog(@"%d, %d", lastReadCount - lastRead, lastWriteCount - lastWrite);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    strcpy(dbPath, [[documentsDirectory stringByAppendingPathComponent:@"data.sqlite3"] UTF8String]);
    

     database = openDb();
    //2 单线程的配置
       //queue = dispatch_queue_create("net.keakon.db", NULL);
       //sqlite3_config(SQLITE_CONFIG_SINGLETHREAD);
    //end
    
    //3 多线程模式的配置
     // queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
     // sqlite3_config(SQLITE_CONFIG_MULTITHREAD);//多线程模式
    // end
    
    // 4
    queue = dispatch_queue_create("net.keakon.db", NULL);
    sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    
    NSLog(@"%d", sqlite3_threadsafe());
    NSLog(@"%s", sqlite3_libversion());
    //////////////
     char* errorMsg;
//    if (sqlite3_exec(database, "PRAGMA journal_mode=WAL;", NULL, NULL, &errorMsg) != SQLITE_OK) {
//        NSLog(@"Failed to set WAL mode: %s", errorMsg);
//    }
//    
//    sqlite3_wal_checkpoint(database, NULL); // 每次测试前先checkpoint，避免WAL文件过大而影响性能
    ////////////////
    
    if (sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, value INTEGER);", NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"Failed to create table: %s", errorMsg);
    }
    
    
    
   
     [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
    
    // singnal thread 未开启journal_mode=WAL 同时读写 每秒 大约在读370  写 370
    //只读或者写的情况下是800左右 但是也有200左右的情况
    
    
    // 单线程开启 WAL 只读 600 只写的情况不稳定如下 ke可以肯定的是在开启WAL同事读写要比 journal——modal=delete 要效率高
    /*
     , 0
     2013-04-29 10:32:03.830 DataBaseTest[3094:c07] 0, 0
     2013-04-29 10:32:04.830 DataBaseTest[3094:c07] 0, 1000
     2013-04-29 10:32:05.830 DataBaseTest[3094:c07] 0, 0
     2013-04-29 10:32:06.830 DataBaseTest[3094:c07] 0, 0
     2013-04-29 10:32:07.830 DataBaseTest[3094:c07] 0, 83
     2013-04-29 10:32:08.830 DataBaseTest[3094:c07] 0, 2917
     2013-04-29 10:32:09.829 DataBaseTest[3094:c07] 0, 3000
     2013-04-29 10:32:10.829 DataBaseTest[3094:c07] 0, 4000
     */
    /*
     单线程下 开启WAL 同事进行读写 大约在400 ~ 600 之间
     2013-04-29 10:33:35.111 DataBaseTest[3131:c07] 433, 433
     2013-04-29 10:33:36.110 DataBaseTest[3131:c07] 591, 591
     2013-04-29 10:33:37.111 DataBaseTest[3131:c07] 442, 442
     2013-04-29 10:33:38.110 DataBaseTest[3131:c07] 605, 605
     2013-04-29 10:33:39.110 DataBaseTest[3131:c07] 472, 472
     2013-04-29 10:33:40.110 DataBaseTest[3131:c07] 585, 585
     2013-04-29 10:33:41.110 DataBaseTest[3131:c07] 495, 495
     2013-04-29 10:33:42.110 DataBaseTest[3131:c07] 519, 518
     2013-04-29 10:33:43.110 DataBaseTest[3131:c07] 572, 573
     2013-04-29 10:33:44.109 DataBaseTest[3131:c07] 428, 427
     2013-04-29 10:33:45.110 DataBaseTest[3131:c07] 602, 603
     2013-04-29 10:33:46.110 DataBaseTest[3131:c07] 432, 432
     */
    
    // insertdata();
    
   
    /*多线程情况下 波动也是较大的 读一般为240左右  写波动更大10- 2050 为1000左右较为平衡
     只读 340 左右  只写的情况下，刚开启的线程的速度有点慢，但是大部分还是很高的
     3 DataBaseTest[3535:c07] 0, 2151
     2013-04-29 10:54:15.262 DataBaseTest[3535:c07] 0, 524
     2013-04-29 10:54:16.261 DataBaseTest[3535:c07] 0, 613
     2013-04-29 10:54:17.262 DataBaseTest[3535:c07] 0, 626
     2013-04-29 10:54:18.262 DataBaseTest[3535:c07] 0, 835
     2013-04-29 10:54:19.262 DataBaseTest[3535:c07] 0, 1435
     2013-04-29 10:54:20.262 DataBaseTest[3535:c07] 0, 2271
     2013-04-29 10:54:21.261 DataBaseTest[3535:c07] 0, 1376
     2013-04-29 10:54:22.262 DataBaseTest[3535:c07] 0, 353
     2013-04-29 10:54:23.262 DataBaseTest[3535:c07] 0, 1726
     2013-04-29 10:54:24.261 DataBaseTest[3535:c07] 0, 2206
     2013-04-29 10:54:25.261 DataBaseTest[3535:c07] 0, 2218
     2013-04-29 10:54:26.261 DataBaseTest[3535:c07] 0, 2284
     2013-04-29 10:54:27.260 DataBaseTest[3535:c07] 0, 2398
     2013-04-29 10:54:28.261 DataBaseTest[3535:c07] 0, 1088
     2013-04-29 10:54:29.260 DataBaseTest[3535:c07] 0, 1668
     2013-04-29 10:54:30.260 DataBaseTest[3535:c07] 0, 5
     2013-04-29 10:54:31.260 DataBaseTest[3535:c07] 0, 3
     2013-04-29 10:54:32.260 DataBaseTest[3535:c07] 0, 5
     2013-04-29 10:54:33.260 DataBaseTest[3535:c07] 0, 1185
     2013-04-29 10:54:34.260 DataBaseTest[3535:c07] 0, 2249
     2013-04-29 10:54:35.259 DataBaseTest[3535:c07] 0, 2343
     2013-04-29 10:54:36.259 DataBaseTest[3535:c07] 0, 2352
     2013-04-29 10:54:37.260 DataBaseTest[3535:c07] 0, 1438
     2013-04-29 10:54:38.259 DataBaseTest[3535:c07] 0, 1853
     
     同时读写 ，且加入过个block 读的效率提高，但是写的速度降低了也不太稳定
     583 DataBaseTest[3612:c07] 219, 399
     2013-04-29 10:56:33.583 DataBaseTest[3612:c07] 363, 897
     2013-04-29 10:56:34.583 DataBaseTest[3612:c07] 365, 845
     2013-04-29 10:56:35.583 DataBaseTest[3612:c07] 344, 828
     2013-04-29 10:56:36.583 DataBaseTest[3612:c07] 356, 797
     2013-04-29 10:56:37.582 DataBaseTest[3612:c07] 357, 849
     2013-04-29 10:56:38.583 DataBaseTest[3612:c07] 356, 826
     2013-04-29 10:56:39.583 DataBaseTest[3612:c07] 364, 863
     2013-04-29 10:56:40.583 DataBaseTest[3612:c07] 370, 805
     2013-04-29 10:56:41.582 DataBaseTest[3612:c07] 362, 781
     2013-04-29 10:56:42.582 DataBaseTest[3612:c07] 370, 496
     2013-04-29 10:56:43.582 DataBaseTest[3612:c07] 368, 747
     2013-04-29 10:56:44.582 DataBaseTest[3612:c07] 357, 847
     2013-04-29 10:56:45.582 DataBaseTest[3612:c07] 354, 821
     2013-04-29 10:56:46.582 DataBaseTest[3612:c07] 344, 695
     2013-04-29 10:56:47.582 DataBaseTest[3612:c07] 326, 714
     2013-04-29 10:56:48.582 DataBaseTest[3612:c07] 394, 379
     2013-04-29 10:56:49.581 DataBaseTest[3612:c07] 361, 689
     2013-04-29 10:56:50.581 DataBaseTest[3612:c07] 339, 765
     2013-04-29 10:57:33.576 DataBaseTest[3612:c07] 357, 368
     2013-04-29 10:57:34.577 DataBaseTest[3612:c07] 318, 768
     2013-04-29 10:57:35.576 DataBaseTest[3612:c07] 421, 82
     2013-04-29 10:57:36.576 DataBaseTest[3612:c07] 460, 178
     2013-04-29 10:57:37.576 DataBaseTest[3612:c07] 414, 270
     2013-04-29 10:57:38.576 DataBaseTest[3612:c07] 362, 264
     2013-04-29 10:57:39.576 DataBaseTest[3612:c07] 366, 470
     2013-04-29 10:57:40.576 DataBaseTest[3612:c07] 467, 3
     2013-04-29 10:57:41.576 DataBaseTest[3612:c07] 379, 371
     2013-04-29 10:57:42.576 DataBaseTest[3612:c07] 385, 227
     2013-04-29 10:57:43.576 DataBaseTest[3612:c07] 457, 168
     2013-04-29 10:57:44.575 DataBaseTest[3612:c07] 316, 640
     2013-04-29 10:57:45.575 DataBaseTest[3612:c07] 382, 385
     2013-04-29 10:57:46.575 DataBaseTest[3612:c07] 342, 338
     */
    
    readData();
    writeData();
    // [self openDataBase];
	// Do any additional setup after loading the view, typically from a nib.
}

//////////////////////////////////////////////////////
/////////////////////////////////////////////////////
static void insertdata(){
    char * errormsg;
    if (sqlite3_exec(database, "begin transaction", NULL, NULL, &errormsg)!=SQLITE_OK){
        NSLog(@"failed to  begin transaction: %s",errormsg);
        }
    NSLog(@"%s",errormsg);
     const char * insert="insert into test (value)  values (?)";
    sqlite3_stmt *stmt;
   // NSLog(@"datebase=%s",database);
  int result=  sqlite3_prepare_v2(database, insert, -1, &stmt, NULL);
    NSLog(@"result=%d",result);
    if(result==SQLITE_OK){
        for (int i=0; i<1000; i++) {
            sqlite3_bind_int(stmt, 1, arc4random());
            if (sqlite3_step(stmt)!=SQLITE_DONE) {
                writeCount--;
                --i;
                NSLog(@"error insert table %s",sqlite3_errmsg(database));
            }
            sqlite3_reset(stmt);
            writeCount++;
            NSLog(@"writecoutn=%d",writeCount);
        }
        sqlite3_finalize(stmt);
    }
    
    if (sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errormsg) != SQLITE_OK) {
        NSLog(@"Failed to commit transaction: %s", errormsg);
    }
    
    static const char *query = "SELECT count(*) FROM test;";
    if (sqlite3_prepare_v2(database, query, -1, &stmt, NULL) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            NSLog(@"Table size: %d", sqlite3_column_int(stmt, 0));
        } else {
            NSLog(@"Failed to read table: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(stmt);
    }
}
/* // 单线程 情况下SQLite使用单线程模式，
 用一个线程队列来访问数据库，队列一次只允许一个线程执行，队列里的线程共用一个数据库连接。用dispatch_queue_create()来创建一个serial queue，或者用一个maxConcurrentOperationCount为1的NSOperationQueue来实现。
 这种方式的缺点就是事务必须在一个block或operation里完成，否则会乱序；而耗时较长的事务会阻塞队列。另外，没法利用多核CPU的优势。
 
 
static void readData() {
    static const char *query = "SELECT value FROM test WHERE value < ? ORDER BY value DESC LIMIT 1;";
    
    void (^ __block readBlock)() = ^{
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, query, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, arc4random());
            int returnCode = sqlite3_step(stmt);
            if (returnCode == SQLITE_ROW || returnCode == SQLITE_DONE) {
                ++readCount;
                //NSLog(@"readCount=%d",readCount);
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(database));
        }
        dispatch_async(queue, readBlock);
    };
    dispatch_async(queue, readBlock);
}

static void writeData() {
    static const char *update = "UPDATE test SET value = ? WHERE id = ?;";
    
    void (^ __block writeBlock)() = ^{
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, update, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, arc4random());
            sqlite3_bind_int(stmt, 2, arc4random() % 1000 + 1);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                ++writeCount;
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(database));
        }
        dispatch_async(queue, writeBlock);
    };
    dispatch_async(queue, writeBlock);
}

static char dbPath[200];
static sqlite3 *database;

static sqlite3 *openDb() {
    if (sqlite3_open(dbPath, &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database: %s", sqlite3_errmsg(database));
    }
    return database;
}
 */


// 第三种方式SQLite使用多线程模式，每个线程创建自己的数据库连接
//第三种方式需要打开和关闭数据库连接，所以会额外消耗一些时间。此外还要维持各个连接间的互斥，事务也比较容易冲突，但能确保事务正确执行。
/*
static char dbPath[200];
static sqlite3 *database;
static sqlite3 *openDb() {
    sqlite3 *database = NULL;
    if (sqlite3_open(dbPath, &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database: %s", sqlite3_errmsg(database));
    }
    return database;
}

static void readData() {
    static const char *query = "SELECT value FROM test WHERE value < ? ORDER BY value DESC LIMIT 1;";
    
    dispatch_async(queue, ^{
        sqlite3 *database = openDb();
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, query, -1, &stmt, NULL) == SQLITE_OK) {
            while (YES) {
                sqlite3_bind_int(stmt, 1, arc4random());
                int returnCode = sqlite3_step(stmt);
                if (returnCode == SQLITE_ROW || returnCode == SQLITE_DONE) {
                    ++readCount;
                }
                sqlite3_reset(stmt);
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(database));
        }
        sqlite3_close(database);
    });
}

static void writeData() {
    static const char *update = "UPDATE test SET value = ? WHERE id = ?;";
    
    dispatch_async(queue, ^{
        sqlite3 *database = openDb();
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
            while (YES) {
                sqlite3_bind_int(stmt, 1, arc4random());
                sqlite3_bind_int(stmt, 2, arc4random() % 1000 + 1);
                if (sqlite3_step(stmt) == SQLITE_DONE) {
                    ++writeCount;
                }
                sqlite3_reset(stmt);
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(database));
        }
        sqlite3_close(database);
    });
}
 */

// 4
static char dbPath[200];
static sqlite3 *database;

static sqlite3 *openDb() {
    if (sqlite3_open(dbPath, &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database: %s", sqlite3_errmsg(database));
    }
    return database;
}

static void readData() {
    static const char *query = "SELECT value FROM test WHERE value < ? ORDER BY value DESC LIMIT 1;";
    
    dispatch_async(queue, ^{
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, query, -1, &stmt, NULL) == SQLITE_OK) {
            while (YES) {
                sqlite3_bind_int(stmt, 1, arc4random());
                int returnCode = sqlite3_step(stmt);
                if (returnCode == SQLITE_ROW || returnCode == SQLITE_DONE) {
                    ++readCount;
                }
                sqlite3_reset(stmt);
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(database));
        }
    });
}

static void writeData() {
    static const char *update = "UPDATE test SET value = ? WHERE id = ?;";
    
    dispatch_async(queue, ^{
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, update, -1, &stmt, NULL) == SQLITE_OK) {
            while (YES) {
                sqlite3_bind_int(stmt, 1, arc4random());
                sqlite3_bind_int(stmt, 2, arc4random() % 100 + 1);
                if (sqlite3_step(stmt) == SQLITE_DONE) {
                    ++writeCount;
                    NSLog(@"write count =%d",writeCount);
                }
                sqlite3_reset(stmt);
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(database));
        }
    });
}
@end
