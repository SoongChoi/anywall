#include <unzip.h>
#include <zran.h>
#include "XSyncv20.h"

const int NOT_IMPLEMENTED_YET =-2;

#if 0
size_t DRMZipFileImpl_Read ( void *instance, char *byteArray, long  len )
{
   return static_cast<Markany::XSync::DRMZipFileImpl *> ( instance )->Read ( byteArray, len );
}

size_t DRMZipFileImpl_ReadFromOffset ( void *instance, void *stream, long  offset, char *byteArray, long  len )
{
   return static_cast<Markany::XSync::DRMZipFileImpl *> ( instance )->ZipRead ( stream, offset, byteArray, len );
}
#endif

static voidpf fopen64_xdrm_file_func ( voidpf opaque, const void *filename, int mode )
{
   FILE *file = NULL;
   const char *mode_fopen = NULL;
   if ( ( mode & ZLIB_FILEFUNC_MODE_READWRITEFILTER ) ==ZLIB_FILEFUNC_MODE_READ )
      mode_fopen = "rb";
   else if ( mode & ZLIB_FILEFUNC_MODE_EXISTING )
      mode_fopen = "r+b";
   else if ( mode & ZLIB_FILEFUNC_MODE_CREATE )
      mode_fopen = "wb";
   if ( ( filename!=NULL ) && ( mode_fopen != NULL ) )
      file = fopen64 ( ( const char * ) filename, mode_fopen );
   return file;
}

static uLong fread_xdrm_file_func ( voidpf opaque, voidpf stream, void *buf, uLong size )
{
   uLong ret;
   int crrOffset = 0;
   char *charBuf = ( char * ) ( ( buf ) );
   //crrOffset = ftell ( ( FILE * ) ( ( stream ) ) );
   //ret = DRMZipFileImpl_ReadFromOffset ( opaque, stream, crrOffset, ( char * ) ( ( charBuf ) ), ( size_t ) ( ( size ) ) );
   ret = XSYNC_Read( opaque, buf, size, E_PARTIAL_ENCRYPTED );
   return ret;
}

static uLong fwrite_xdrm_file_func ( voidpf opaque, voidpf stream, const void *buf, uLong size )
{
   uLong ret;
   //   ret = DRMZipFileImpl_Write ( opaque, ( char * ) buf, ( size_t ) size );
   ret = ( uLong ) ( ( fwrite ( buf, 1, ( size_t ) ( ( size ) ), ( FILE * ) ( ( stream ) ) ) ) );
   return ret;
}

static ZPOS64_T ftell64_xdrm_file_func ( voidpf opaque, voidpf stream )
{
   ZPOS64_T ret;
   //   ret = DRMZipFileImpl_Tell ( opaque );
//   ret = ftello64 ( ( FILE * ) stream );
   ret = XSYNC_ftell((XDRM_CTRL_CONTEXT_PTR )opaque );
   return ret;
}

static long fseek64_xdrm_file_func ( voidpf opaque, voidpf stream, ZPOS64_T offset, int origin )
{
   int fseek_origin = 0;
   long ret;
   switch ( origin ) {
   case ZLIB_FILEFUNC_SEEK_CUR :
      fseek_origin = SEEK_CUR;
      break;
   case ZLIB_FILEFUNC_SEEK_END :
      fseek_origin = SEEK_END;
      break;
   case ZLIB_FILEFUNC_SEEK_SET :
      fseek_origin = SEEK_SET;
      break;
   default:
      return -1;
   }
   ret = 0;

   //if ( XSYNC_Seek((XDRM_CTRL_CONTEXT_PTR)opaque,  offset, fseek_origin ) != 0 )
   if ( XSYNC_fseek((XDRM_CTRL_CONTEXT_PTR)opaque,  offset, fseek_origin ) != 0 )
	   ret=-1;
   return ret;
}

static int fclose_xdrm_file_func ( voidpf opaque, voidpf stream )
{
   int ret;
   //   ret =  DRMZipFileImpl_Close ( opaque );
   ret = fclose ( ( FILE * ) ( ( stream ) ) );
   return ret;
}

static int ferror_xdrm_file_func ( voidpf opaque, voidpf stream )
{
   int ret;
   ret = ferror ( ( FILE * ) stream );
   return ret;
}

static void fill_fopen64_xdrm_filefunc_fromOutside ( zlib_filefunc64_def *pzlib_filefunc_def, void *instance )
{
   pzlib_filefunc_def->zopen64_file = fopen64_xdrm_file_func;
   pzlib_filefunc_def->zread_file = fread_xdrm_file_func;
   pzlib_filefunc_def->zwrite_file = fwrite_xdrm_file_func;
   pzlib_filefunc_def->ztell64_file = ftell64_xdrm_file_func;
   pzlib_filefunc_def->zseek64_file = fseek64_xdrm_file_func;
   pzlib_filefunc_def->zclose_file = fclose_xdrm_file_func;
   pzlib_filefunc_def->zerror_file = ferror_xdrm_file_func;
   pzlib_filefunc_def->opaque = instance;
}

int XSYNCZIP_Open(IN XDRM_KEYOBJ_PTR pKeyObj,
                       IN const char* pszFilePath,
                       IN time_t tmDateTime,
                       OUT XDRM_CTRL_CONTEXT_PTR* phContext)
{
		int xr;

		if(NULL==*phContext)
		{
			xr= XSYNC_Open( pKeyObj, pszFilePath,tmDateTime, phContext);
			CHECKXR(xr);
		}

		//register function pointers
		registerIOFuncPtrsForZlib(*phContext);

		(*phContext)->pZipFile =(unz64_s*) unzOpen2_64(pszFilePath, &((*phContext)->zipFile.z_filefunc.zfile_func64));
		if(NULL == (*phContext)->pZipFile)
		{
			xr=XDRM_E_FAIL;
			goto ErrorExit;
		}

EXIT:
    return  xr;
ErrorExit:
    free(*phContext);
    *phContext = NULL;
    goto EXIT;
}

//entry manipulation
int XSYNCZIP_openEntryByName ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle, char *name )
{
   int retval =0;
   int interRetval = 0;

   int compSize =0;
   int uncompSize=0;
   unz64_s dummy;

   //extra infos, need these to calculate current entrys's offset from entire zip file
   int entryNameLen =0;
   int extraFieldLen = 0;
   int extraLen =0;

   entryHandle->isAbleToRandomAccess = 0;
   entryHandle->index = NULL;

   if ( name == NULL || entryHandle == NULL ) {
      return UNZ_PARAMERROR;
   }

   if ( UNZ_OK != ( interRetval = unzLocateFile ( pCtx->pZipFile,name,0/*CASESENSITIVITY*/ ) )  ) {
      retval =-1;
      entryHandle->name = NULL;
      entryHandle->idx = -1;
      entryHandle->crrPos = -1;
      entryHandle->endOffsetOnEntireFile=-1;
      entryHandle->isDir = NOT_IMPLEMENTED_YET;

   } else {

      // open current entry
	   dummy= *(pCtx->pZipFile);  //copy base infos
      dummy.pfile_in_zip_read= NULL;    // we want new zip read info so.

      if ( UNZ_OK == ( retval =  unzOpenCurrentFile ( &dummy ) ) ) {
         compSize = dummy.cur_file_info.compressed_size;
         uncompSize = dummy.cur_file_info.uncompressed_size;
         entryNameLen = dummy.cur_file_info.size_filename;
         extraFieldLen = unzGetLocalExtrafield ( &dummy,NULL,0 ); //pCtx->pZipFile->cur_file_info.external_fa;

         //total extra len = name len + extra field len
         extraLen = extraFieldLen + entryNameLen;

         entryHandle->offsetOnEntireFile =  dummy.byte_before_the_zipfile +
                                            dummy.cur_file_info_internal.offset_curfile +
                                            0x1e/*SIZEZIPLOCALHEADER*/+
                                            extraLen;

         entryHandle->idx= dummy.num_file;
         entryHandle->crrPos = 0;
         entryHandle->prePos = 0;
         entryHandle->compSize = compSize; //size of entry
         entryHandle->uncompSize = uncompSize; //size of entry
         entryHandle->endPos = entryHandle->crrPos + uncompSize;  //offset+size
         entryHandle->endOffsetOnEntireFile = entryHandle->offsetOnEntireFile + uncompSize;  //offsetoffsetOnEntireFile+size
         entryHandle->isDir = NOT_IMPLEMENTED_YET;
         entryHandle->name = ( char * ) calloc ( entryNameLen+1, sizeof ( char ) );
         strncpy ( entryHandle->name, name, entryNameLen );

         entryHandle->readInfo = dummy.pfile_in_zip_read;

         //do not close, because we'll keep its decompressing history
         //closeEntry will do this clean up
         //unzCloseCurrentFile ( pCtx->pZipFile );
      }

   }

   return retval;
}

int XSYNCZIP_openEntryByIdx ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle, int idx )
{
   return NOT_IMPLEMENTED_YET;
}

int XSYNCZIP_openEntryClone ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *srcEntry, EntryHandle *copiedEntry )
{
   return NOT_IMPLEMENTED_YET;
}

int XSYNCZIP_closeEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle )
{
   int retval = 0;
   unz64_s dummy;

   //free entry name
   free ( entryHandle->name );
   entryHandle->name = NULL;

   //free entry zip info
   dummy.pfile_in_zip_read = entryHandle->readInfo;

   retval = unzCloseCurrentFile ( &dummy );
#if 0
   pCtx->pZipFile->pfile_in_zip_read = NULL;
#endif

   //free entry random access infos
   if ( entryHandle->isAbleToRandomAccess || entryHandle->index ) {

      free_index ( entryHandle->index );
      entryHandle->index = NULL;
      entryHandle->isAbleToRandomAccess = 0;

   }

   return retval;
}



int XSYNCZIP_prepareEntryToSeek ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle )
{
   int retval = 0;
   int len = 0;
   unz64_s dummy;

   // check already initialized
   if ( 1== entryHandle->isAbleToRandomAccess ) {

      //but did not build index
      if ( NULL == entryHandle->index ) {
         entryHandle->isAbleToRandomAccess = 0;
         // rebuild
         goto BUILD_INDEX;
      }
      return 0;

   } else if ( NULL != entryHandle->index ) {
      //?why it is not NULL, invalid parameter
      return -1;
   }


BUILD_INDEX: {

      dummy.pfile_in_zip_read = entryHandle->readInfo;
      len = build_index_forZip ( ( unzFile ) &dummy, entryHandle->offsetOnEntireFile, entryHandle->compSize, SPAN, & ( entryHandle->index ), 1 );

      if ( len < 0 ) {
//               fclose((FILE*)in);
         switch ( len ) {
         case Z_MEM_ERROR:
            fprintf ( stderr, "zran: out of memory\n" );
            break;
         case Z_DATA_ERROR:
            fprintf ( stderr, "zran: compressed data error in \n" );
            break;
         case Z_ERRNO:
            fprintf ( stderr, "zran: read error on \n" );
            break;
         default:
            fprintf ( stderr, "zran: error %d while building index\n", len );
         }
         entryHandle->isAbleToRandomAccess = 0;
         retval = -1;
      } else {
         entryHandle->isAbleToRandomAccess = 1;
         retval = 0;
      }
      fprintf ( stderr, "zran: built index with %d access points\n", len );

   }//end of BUILD_INDEX

   return retval;
}

// like input stream
int XSYNCZIP_readEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle, char *buffer, int size )
{
   int retval = 0;

   unz64_s dummy;
   dummy.pfile_in_zip_read=entryHandle->readInfo;

#if 0
   if ( 0 != entryHandle->didRandomAccess ) {
#else
   if ( entryHandle->readInfo->total_out_64 == entryHandle->crrPos ) {
#endif
      retval = unzReadEntry ( &dummy, buffer, entryHandle->offsetOnEntireFile+ entryHandle->crrPos/*not being used*/,  size , Z_SYNC_FLUSH );
      entryHandle->didRandomAccess = 0;

   } else {

      if ( entryHandle->isAbleToRandomAccess ) {
         retval = extract_forZip ( ( unzFile  ) &dummy, entryHandle->index, entryHandle->crrPos, ( unsigned char * ) buffer, size, ( int ) entryHandle->offsetOnEntireFile  );
         entryHandle->didRandomAccess = 1;

      } else {
         retval =-3; //err can't perform random access
      }

   }

   //if there is no err then update pos
   if ( retval > 0 ) {
      //plus reading len
      entryHandle->prePos = entryHandle->crrPos;
      entryHandle->crrPos += retval;
   }

   //never, so after this we can chase the point we've finished
   //unzCloseCurrentFile ( pCtx->pZipFile );
   return retval;
}

// like random access : slow
int XSYNCZIP_readEntryOffset ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle,  int offset, char *buffer, int size )
{

   int retval = -1;

   unz64_s dummy;
   dummy.pfile_in_zip_read=entryHandle->readInfo;

   if ( entryHandle->isAbleToRandomAccess ) {

      retval = extract_forZip ( ( unzFile ) &dummy,
                                entryHandle->index,
                                offset,
                                ( unsigned char * ) buffer,
                                size,
                                entryHandle->offsetOnEntireFile );


      if ( retval != UNZ_OK )
         retval =-1;

   } else {
      retval = -3;
   }

   //if there is no err then update pos
#if 1
   if ( retval > 0 ) {

      int isMovedFoward = 0;
      //TODO:
      //update readInfo infos also

      entryHandle->prePos = entryHandle->crrPos; // right ?
//      entryHandle->prePos = offset; // right ?
      //entryHandle->crrPos += retval;
      entryHandle->crrPos += offset+ retval;

      isMovedFoward = entryHandle->prePos - entryHandle->crrPos;
      if ( isMovedFoward ) {
         if ( retval == isMovedFoward ) { // no random access, but we need to update readInfo
            // TODO: need to update readInfo
            entryHandle->didRandomAccess = 0;
         } else {
            entryHandle->didRandomAccess = retval;
         }
      } else { //moved to backward
         entryHandle->didRandomAccess = retval;
      }

   }
#endif

   return retval;

}

// move position
int XSYNCZIP_seekEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, EntryHandle *entryHandle, int offset, int opt )
{
//   int retval = fseek ( ( FILE * ) pCtx->pZipFile->filestream, entryHandle->offsetOnEntireFile+offset, opt );

   int retval = 0;
   int prePosBackup= entryHandle->prePos;

   if ( entryHandle->isAbleToRandomAccess ) {

      entryHandle->prePos = entryHandle->crrPos;

      switch ( opt ) {
      case 0: //from the start
      case 3:
         if ( offset > entryHandle->endPos || offset <0 ) {
            if ( opt == 3 ) {
               if ( offset <0 )
                  entryHandle->crrPos =0;
               else
                  entryHandle->crrPos = entryHandle ->endPos;
            } else {
               return -1;
            }
         } else {
            entryHandle->crrPos = offset;
         }
         break;
      case 1: //from the current
      case 4:
         entryHandle->crrPos += offset;
         //over the line
         if ( entryHandle->crrPos > entryHandle->endPos ) {

            if ( opt ==4 ) {
               entryHandle->crrPos = entryHandle->endPos;
            } else {
               retval =-1;
            }
         }
         break;
      case 2: //from the end
      case 5:
         entryHandle->crrPos = entryHandle->endPos - offset;
         //over the line
         if ( entryHandle->crrPos <0 ) {
            if ( opt == 5 ) {
               entryHandle->crrPos = 0;
            } else {
               retval = -1;
            }
         }
         break;
      default:
         retval = -4;
         break;
      }

      //finish
      if ( retval < 0 ) {
         entryHandle-> crrPos = entryHandle->prePos;
         entryHandle->prePos = prePosBackup;
      } else {
         //random access performed -seeking
         entryHandle->didRandomAccess = 1;
         retval = entryHandle->crrPos;
      }

   } else {
      // this entry is unable to seek -->  uninitialized
      retval =-3;
   }

   return retval;

}



int XSYNCZIP_getCrrEntryFile ( XDRM_CTRL_CONTEXT_PTR pCtx, char *path )
{

#if 0
   int retval = 0;
   int opt =0;
   chdir ( path );
   if ( 0 != do_extract_currentfile ( ( unzFile ) pCtx->pZipFile, &opt, &opt, NULL, path ) )
      retval = -1;

   return retval;
#else
   return NOT_IMPLEMENTED_YET;
#endif

}

int XSYNCZIP_getCrrEntryData ( XDRM_CTRL_CONTEXT_PTR pCtx, char *buffer )
{

   int retval = unzOpenCurrentFile ( pCtx->pZipFile );
   if ( retval ==0 ) {
#if 0
      retval =unzReadCurrentFile ( pCtx->pZipFile, buffer, ( unsigned int ) pCtx->pZipFile->cur_file_info.uncompressed_size );
#else
      retval =unzReadEntry ( pCtx->pZipFile,  buffer, 0, ( unsigned int ) pCtx->pZipFile->cur_file_info.uncompressed_size , Z_FINISH );
#endif
   } else {
      retval =-1;
   }

   unzCloseCurrentFile ( pCtx->pZipFile );

   return retval;
}

int XSYNCZIP_getAllEntriesCounts(XDRM_CTRL_CONTEXT_PTR pCtx)
{
   return pCtx->pZipFile->gi.number_entry;
}

int XSYNCZIP_getEntryNameList ( XDRM_CTRL_CONTEXT_PTR pCtx, char *** entryList )
{
   int listLen = -1;
   int retval = 0;

   retval = getList ( pCtx->pZipFile , entryList, &listLen );
   if ( 0 != retval ) {
      //free?
   }

   return listLen;
}

int XSYNCZIP_diplaySummary(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   int retval =-1;
   if ( NULL != pCtx->pZipFile )
      retval = displayList ( pCtx->pZipFile );

   return retval;
}


int XSYNCZIP_getOffsetOfEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, char *entryName )
{
   int retval = -1;
   if ( unzLocateFile ( pCtx->pZipFile,entryName,0/*CASESENSITIVITY*/ ) ==UNZ_OK ) {
      retval = pCtx->pZipFile->pos_in_central_dir;
   }
   return retval;
}

int XSYNCZIP_getIndexOfEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, char *entryName )
{

   int retval = -1;
   if ( unzLocateFile ( pCtx->pZipFile,entryName,0/*CASESENSITIVITY*/ ) ==UNZ_OK ) {
      retval = pCtx->pZipFile->num_file;
   }
   return retval;
}

int XSYNCZIP_getCompSizeOfEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, char *name )
{

   int retval = -1;
   if ( unzLocateFile ( pCtx->pZipFile,name,0/*CASESENSITIVITY*/ ) ==UNZ_OK ) {
      retval = pCtx->pZipFile->cur_file_info.compressed_size;
   }

   return retval;
}

int XSYNCZIP_getUncompSizeOfEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, char *name )
{

   int retval = -1;
   if ( unzLocateFile ( pCtx->pZipFile,name,0/*CASESENSITIVITY*/ ) ==UNZ_OK ) {
      retval = pCtx->pZipFile->cur_file_info.uncompressed_size;
   }

   return retval;
}

char *XSYNCZIP_getEntryNameFromOffset ( XDRM_CTRL_CONTEXT_PTR pCtx, int offset  )
{
   return NULL; //NOT_IMPLEMENTED_YET; //not implemente yet
}

char *XSYNCZIP_getEntryNameFromIdx ( XDRM_CTRL_CONTEXT_PTR pCtx, int idx )
{
   return NULL; //NOT_IMPLEMENTED_YET;	//not implemente yet
}

int XSYNCZIP_getAllEntryFiles ( XDRM_CTRL_CONTEXT_PTR pCtx, char *path )
{
#if 0
   //  need to move index 0
   int opt =0;
   chdir ( path );
   int retval = unzGoToFirstFile ( ( unzFile ) ( ( ( ( pCtx->pZipFile ) ) ) ) );
   if ( UNZ_OK != retval )
      return -1;
   return  do_extract ( ( unzFile ) pCtx->pZipFile, 0, 0, NULL, path );
#else
   return  NOT_IMPLEMENTED_YET;
#endif
}

int XSYNCZIP_getEntryFileByName ( XDRM_CTRL_CONTEXT_PTR pCtx,  char *desiredName, char *path )
{
#if 0
   chdir ( path );
   return do_extract_onefile ( ( unzFile ) pCtx->pZipFile, desiredName, 0, 0, NULL, path );
#else
   return NOT_IMPLEMENTED_YET;
#endif
}

int XSYNCZIP_getEntryDataByName ( XDRM_CTRL_CONTEXT_PTR pCtx,  char *name, char *buffer )
{
   int retval =0;

#if 0
   // before info
   unz_file_info64 cur_file_infoSaved;
   unz_file_info64_internal cur_file_info_internalSaved;
   ZPOS64_T num_fileSaved;
   ZPOS64_T pos_in_central_dirSaved;

   /* Save the current state */
   num_fileSaved = s->num_file;
   pos_in_central_dirSaved = s->pos_in_central_dir;
   cur_file_infoSaved = s->cur_file_info;
   cur_file_info_internalSaved = s->cur_file_info_internal;
#endif

   if ( unzLocateFile ( pCtx->pZipFile,name,0/*CASESENSITIVITY*/ ) !=UNZ_OK ) {
      retval= -1;
   } else {
      retval = unzOpenCurrentFile ( pCtx->pZipFile );
      if ( retval == UNZ_OK ) {
#if 0
         retval =unzReadCurrentFile ( pCtx->pZipFile, buffer, ( unsigned int ) pCtx->pZipFile->cur_file_info.uncompressed_size );
#else
         retval =unzReadEntry ( pCtx->pZipFile, buffer, 0, ( unsigned int ) pCtx->pZipFile->cur_file_info.uncompressed_size, Z_FINISH );
#endif
      } else {
         retval =-1;
      }
   }

   unzCloseCurrentFile ( pCtx->pZipFile );
   return retval;

}

int XSYNCZIP_getEntryFileByIdx ( XDRM_CTRL_CONTEXT_PTR pCtx,  int idx, char *path )
{
#if 0
   char *name;
   if ( NULL!=name ) {
      return do_extract_onefile ( ( unzFile ) pCtx->pZipFile, name, 0, 0, NULL , path );
   } else
      return -1;
#else
   return NOT_IMPLEMENTED_YET;
#endif
}


int XSYNCZIP_getEntryDataByIdx ( XDRM_CTRL_CONTEXT_PTR pCtx, int idx, char *buffer )
{
   int retval  = -1;
   return NOT_IMPLEMENTED_YET;
}

int XSYNCZIP_getCrrEntryIdx(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   int idx =-1;
   if ( pCtx->pZipFile->current_file_ok ) {
      idx= pCtx->pZipFile->num_file;
   }
   return idx;
}

char *XSYNCZIP_getCrrEntryName ( XDRM_CTRL_CONTEXT_PTR pCtx )
{
   int retval  = -1;

   int nameLen = pCtx->pZipFile->cur_file_info.size_filename;

   char *name = ( char * ) calloc ( sizeof ( char ), nameLen+1 );

   if ( pCtx->pZipFile->current_file_ok ) {
      retval = unzGetCurrentFileInfo ( pCtx->pZipFile,NULL, name, nameLen, NULL,0,NULL,0 ) ;
   }

   if ( retval != UNZ_OK ) {
      free ( name );
      name = NULL;
   }

   return name;
}

int XSYNCZIP_getCrrEntryOffset(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   int offset =-1;
   if ( pCtx->pZipFile->current_file_ok ) {
      offset = pCtx->pZipFile->pos_in_central_dir; //+ extra
   }
   return offset;
}

int XSYNCZIP_getCrrEntryCompSize(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   int compSize = -1;
   compSize = pCtx->pZipFile->cur_file_info.compressed_size;

   return compSize;

}

int XSYNCZIP_getCrrEntryUncompSize(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   int uncompSize = -1;
   uncompSize = pCtx->pZipFile->cur_file_info.uncompressed_size;

   return uncompSize;

}

int XSYNCZIP_goNextEntry(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   return unzGoToNextFile ( pCtx->pZipFile );
}

int XSYNCZIP_goPrevEntry(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   return NOT_IMPLEMENTED_YET;
}

int XSYNCZIP_goFirstEntry(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   return unzGoToFirstFile ( pCtx->pZipFile );
}

int XSYNCZIP_gotoEntry ( XDRM_CTRL_CONTEXT_PTR pCtx, char *entryName )
{
//    unzG
   int retval = 0;
   if ( unzLocateFile ( pCtx->pZipFile,entryName,0/*CASESENSITIVITY*/ ) !=UNZ_OK )
      retval= -1;

   return retval;
}

int XSYNCZIP_goEntryByIdx ( XDRM_CTRL_CONTEXT_PTR pCtx, int idx )
{
   return NOT_IMPLEMENTED_YET;
}

int XSYNCZIP_goEntryByOffset (XDRM_CTRL_CONTEXT_PTR pCtx,  int offset )
{
   return NOT_IMPLEMENTED_YET;
}

// register zip - io functions
static void registerIOFuncPtrsForZlib(XDRM_CTRL_CONTEXT_PTR pCtx )
{
   //xdrm file io
   fill_fopen64_xdrm_filefunc_fromOutside ( &(pCtx->zipFile.z_filefunc.zfile_func64), pCtx );
}



