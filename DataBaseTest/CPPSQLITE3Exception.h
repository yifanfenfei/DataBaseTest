//
//  CPPSQLITE3Exception.h
//  DataBaseTest
//
//  Created by sun jianfeng on 4/11/13.
//  Copyright (c) 2013 sun jianfeng. All rights reserved.
//

#ifndef __DataBaseTest__CPPSQLITE3Exception__
#define __DataBaseTest__CPPSQLITE3Exception__

#include <iostream>
#include <cstring>
#include <cstdio>
#include <sqlite3.h>
#define CPPSQLITE_ERROR 1000
class CppSQLITE3Exception{
private:
    int mpErrorCode;
    char* mpErrMessage;
public:
    CppSQLITE3Exception(const int errCode,const char* errMsg,bool bDeleteMsg);
    CppSQLITE3Exception(const CppSQLITE3Exception& cpp);
    ~ CppSQLITE3Exception();
    const int errorCode(){
        return mpErrorCode;
    }
    const char* ErrorMessage(){
        return mpErrMessage;
    }
    static const char * errorCodeAsString(const int errCode);
    
};
#endif /* defined(__DataBaseTest__CPPSQLITE3Exception__) */
