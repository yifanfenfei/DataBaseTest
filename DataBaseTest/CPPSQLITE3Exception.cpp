//
//  CPPSQLITE3Exception.cpp
//  DataBaseTest
//
//  Created by sun jianfeng on 4/11/13.
//  Copyright (c) 2013 sun jianfeng. All rights reserved.
//

#include "CPPSQLITE3Exception.h"
static const bool DONT_DELETE_MSG=false;

CppSQLITE3Exception::CppSQLITE3Exception(const int errCode ,const char* errMEG,bool bDeleteMsg){
    mpErrorCode=errCode;
    mpErrMessage=sqlite3_mprintf("%s[%d]:%s",errorCodeAsString(errCode),errCode,errMEG?errMEG:"");
    if (errMEG&&bDeleteMsg) {
        sqlite3_free(mpErrMessage);
    }
}
CppSQLITE3Exception::CppSQLITE3Exception(const CppSQLITE3Exception& cpp){
    mpErrorCode=cpp.mpErrorCode;
    mpErrMessage=0;
    if (cpp.mpErrMessage) {
        mpErrMessage=sqlite3_mprintf("%s",cpp.mpErrMessage);
    }
}

 const char* CppSQLITE3Exception::errorCodeAsString(const int errCode){
     switch (errCode)
     {
         case SQLITE_OK          : return "SQLITE_OK";
         case SQLITE_ERROR       : return "SQLITE_ERROR";
         case SQLITE_INTERNAL    : return "SQLITE_INTERNAL";
         case SQLITE_PERM        : return "SQLITE_PERM";
         case SQLITE_ABORT       : return "SQLITE_ABORT";
         case SQLITE_BUSY        : return "SQLITE_BUSY";
         case SQLITE_LOCKED      : return "SQLITE_LOCKED";
         case SQLITE_NOMEM       : return "SQLITE_NOMEM";
         case SQLITE_READONLY    : return "SQLITE_READONLY";
         case SQLITE_INTERRUPT   : return "SQLITE_INTERRUPT";
         case SQLITE_IOERR       : return "SQLITE_IOERR";
         case SQLITE_CORRUPT     : return "SQLITE_CORRUPT";
         case SQLITE_NOTFOUND    : return "SQLITE_NOTFOUND";
         case SQLITE_FULL        : return "SQLITE_FULL";
         case SQLITE_CANTOPEN    : return "SQLITE_CANTOPEN";
         case SQLITE_PROTOCOL    : return "SQLITE_PROTOCOL";
         case SQLITE_EMPTY       : return "SQLITE_EMPTY";
         case SQLITE_SCHEMA      : return "SQLITE_SCHEMA";
         case SQLITE_TOOBIG      : return "SQLITE_TOOBIG";
         case SQLITE_CONSTRAINT  : return "SQLITE_CONSTRAINT";
         case SQLITE_MISMATCH    : return "SQLITE_MISMATCH";
         case SQLITE_MISUSE      : return "SQLITE_MISUSE";
         case SQLITE_NOLFS       : return "SQLITE_NOLFS";
         case SQLITE_AUTH        : return "SQLITE_AUTH";
         case SQLITE_FORMAT      : return "SQLITE_FORMAT";
         case SQLITE_RANGE       : return "SQLITE_RANGE";
         case SQLITE_ROW         : return "SQLITE_ROW";
         case SQLITE_DONE        : return "SQLITE_DONE";
         case CPPSQLITE_ERROR    : return "CPPSQLITE_ERROR";  
         default: return "UNKNOWN_ERROR";  
     }
}
CppSQLITE3Exception::~CppSQLITE3Exception(){
    if (mpErrMessage) {
        sqlite3_free(mpErrMessage);
        mpErrMessage=0;
    }
}