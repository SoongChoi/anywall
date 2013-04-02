#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "XSyncv20.h"
#include "xdrmcommon.h"
#include "xsyncdrm_client.h"


//-------------------------------------------------------
//	함수:	XSYNC_Initialize
//	설명:	XSYNC Lib.를 초기화하고 디바이스 키를 설정한다.
//	인자:	pbtDeviceKey - [입력] 디바이스 키
//		 	nDevKeyLen - [입력] 디바이스 키 길이
//			phXSync - [출력] 초기화 된 XSync 핸들
//-------------------------------------------------------
XDRM_RESULT XSYNC_Initialize(IN XDRM_BYTE* pbtDeviceKey,
							 IN XDRM_UINT nDevKeyLen,
							 OUT HANDLE* phXSync)
{
	XDRM_RESULT	Result = XDRM_SUCCESS;

	if (32 < nDevKeyLen)
	{
		Result = XDRM_E_INVALIDARG;
	}
	else
	{
		Result = XDRM_KEY_Init((XDRM_CHAR*)pbtDeviceKey, nDevKeyLen, phXSync);
	}

	return	Result;
}

//-------------------------------------------------------
//	함수:	XSYNC_UnInitialize
//	설명:	XSYNC Lib. 초기화를 해제한다.
//	인자:	hXSync - [입력] 초기화 된 XSync 핸들
//-------------------------------------------------------
XDRM_RESULT XSYNC_UnInitialize(IN HANDLE hXSync)
{
	XDRM_RESULT	Result = XDRM_SUCCESS;

	CHECKRESULT(XDRM_KEY_UnInit(hXSync));

FUNCTION_ERROR:

	return	Result;
}

//-------------------------------------------------------
//	함수:	XSYNC_Open
//	설명:	XSync 형식 파일을 오픈한다.
//	인자:	pszFilePath - [입력] 오픈 할 파일 경로
//			tmDateTime - [입력] 라이선스 기준 시간 (0=무시)
//		 	phContext - [출력] 초기화 된 파일 핸들
//-------------------------------------------------------
XDRM_RESULT XSYNC_Open(IN HANDLE hXSync,
					   IN const char* pszFilePath,
					   IN time_t tmDateTime,
					   OUT HANDLE* phContext)
{
	PXDRM_CTRL_CONTEXT	pContext;
	XDRM_RESULT	Result = XDRM_SUCCESS;

    
	if (NULL == (*phContext = malloc(sizeof(XDRM_CTRL_CONTEXT))))
	{
		CHECKRESULT(XDRM_E_OUTOFMEMORY);
	}

	pContext = (PXDRM_CTRL_CONTEXT)*phContext;
	memset(pContext, 0, sizeof(XDRM_CTRL_CONTEXT));
    
    //라이선스 타입 초기화
    pContext->m_enLicType = E_LIC_TYPE_NOT_FOUND;
    pContext->m_enLicState = E_LIC_STATE_NO_RIGHT;
    
	pContext->m_pDRMFile = fopen(pszFilePath, "rb");

	if (NULL == pContext->m_pDRMFile)
	{
		CHECKRESULT(XDRM_E_DEVIF_FILEOP);
	}

	pContext->m_pKeyObj = (PXDRM_KEYOBJ)hXSync;

	//	DRM Header & License를 검사한다.
	//
	if (XDRM_SUCCESS == (Result = XDRM_HDR_Verify(pContext)) &&
		XDRM_SUCCESS == (Result = XDRM_LIC_Verify(pContext, tmDateTime)))
	{
		XDRM_CNT_DecryptInit(pContext);
	}

	//	평문 파일 크기를 계산한다.
	//
	fseek(pContext->m_pDRMFile, 0, SEEK_END);
	pContext->m_lFileSize = ftell(pContext->m_pDRMFile);
	pContext->m_lFileSize -= pContext->m_lXDRMHdrSize + pContext->m_lXDRMLicSize;

	//	DRM Header & License 위치를 건너뛴다.
	//
	fseek(pContext->m_pDRMFile, pContext->m_lXDRMHdrSize + pContext->m_lXDRMLicSize, SEEK_SET);
    
    //버퍼 모드 아님
    pContext->m_bBufferedMode = FALSE;
    
    
FUNCTION_ERROR:
    
    
	return	Result;
}

//-------------------------------------------------------
//	함수:	XSYNC_Open_BufferedMode
//	설명:	XSync 형식 파일을 오픈한다.
//          XSync_Open 과 달리 파일 패스가 없다.
//          스트리밍 형식의 작업을 지원 할 수 있도록, 버퍼 단위로 복호화를 제공한다.
//	인자:	tmDateTime - [입력] 라이선스 기준 시간 (0=무시)
//		 	phContext - [출력] 초기화 된 파일 핸들
//-------------------------------------------------------
XDRM_RESULT XSYNC_Open_BufferedMode(IN HANDLE hXSync,
					   IN time_t tmDateTime,
					   OUT HANDLE* phContext,
                        IN OUT int* dueToRead)
{
	PXDRM_CTRL_CONTEXT	pContext;
	XDRM_RESULT	Result = XDRM_SUCCESS;
    
    
	if (NULL == (*phContext = malloc(sizeof(XDRM_CTRL_CONTEXT))))
	{
		CHECKRESULT(XDRM_E_OUTOFMEMORY);
	}
    
	pContext = (PXDRM_CTRL_CONTEXT)*phContext;
	memset(pContext, 0, sizeof(XDRM_CTRL_CONTEXT));
	pContext->m_pDRMFile = NULL;
    
	pContext->m_pKeyObj = (PXDRM_KEYOBJ)hXSync;
    
    //버퍼 모드임
    pContext->m_bBufferedMode = TRUE;
    pContext->m_tmTime = tmDateTime;
    
    //앞으로 읽어야 할 데이터 길이 세팅
    *dueToRead = XSYNC20_HDR_SIZE_BEFORE_META; // meta 데이터 전까지 헤더 크기
    
    
FUNCTION_ERROR:
    
    //라이선스 타입 초기화
    pContext->m_enLicType = E_LIC_TYPE_NOT_FOUND;
    pContext->m_enLicState = E_LIC_STATE_NO_RIGHT;
    
	return	Result;
}



//-------------------------------------------------------
//	함수:	XSYNC_Close
//	설명:	열려진 파일을 닫는다.
//	인자:	hContext - [입력] 초기화 된 파일 핸들
//-------------------------------------------------------
void XSYNC_Close(IN HANDLE hContext)
{
	PXDRM_CTRL_CONTEXT	pContext = (PXDRM_CTRL_CONTEXT)hContext;
	
	if (NULL != pContext->m_pDRMFile)
	{
		fclose(pContext->m_pDRMFile);
		pContext->m_pDRMFile = NULL;
	}
	
	SAFE_FREE(pContext->m_pcMeta);
	SAFE_FREE(pContext->m_pcLicense);
	
	free(pContext);
}

//-------------------------------------------------------
//	함수:	XSYNC_GetMeta
//	설명:	Meta 정보를 반환한다.
//	인자:	hContext - [입력] 초기화 된 파일 핸들
//		 	pvBuffer - [입/출력] Meta를 복사할 버퍼
//			pnBufLen - [입/출력] Meta 길이
//-------------------------------------------------------
XDRM_RESULT XSYNC_GetMeta(IN HANDLE hContext,
						  OUT void* pvBuffer,
						  IN OUT int* pnBufLen)
{
	XDRM_RESULT	Result = XDRM_S_FALSE;
	PXDRM_CTRL_CONTEXT	pContext = (PXDRM_CTRL_CONTEXT)hContext;

	if (NULL == pvBuffer)
	{
		*pnBufLen = pContext->m_nMetaLen;
	}
	else if (NULL != pContext->m_pcMeta)
	{
		if (pContext->m_nMetaLen > *pnBufLen)
		{
			*pnBufLen = pContext->m_nMetaLen;
		}
		else
		{
			memset(pvBuffer, 0, *pnBufLen);
			memcpy(pvBuffer, pContext->m_pcMeta, pContext->m_nMetaLen);

			*pnBufLen = pContext->m_nMetaLen;
			Result = XDRM_SUCCESS;
		}
	}

	return	Result;
}

//-------------------------------------------------------
//	함수:	XSYNC_Read
//	설명:	열려진 파일을 읽는다.
//	인자:	hContext - [입력] 초기화 된 파일 핸들
//		 	pvBuff - [입/출력] 데이타를 복사할 버퍼
//			nReadSize - [입력] 버퍼(읽을) 길이
//-------------------------------------------------------
int XSYNC_Read(IN HANDLE hContext,
			   OUT void* pvBuff,
			   IN int nReadSize)
{
	XDRM_ULONG	ulFilePos=0;
	XDRM_DWORD	dwReadBytes=0;
	XDRM_INT	nTotalRead = 0;
	XDRM_LONG	lOrgSize = 0, lCopySize = 0;

	PXDRM_CTRL_CONTEXT	pContext = (PXDRM_CTRL_CONTEXT)hContext;

    if( FALSE == pContext->m_bBufferedMode)
    {
        ulFilePos = ftell(pContext->m_pDRMFile) - pContext->m_lXDRMHdrSize - pContext->m_lXDRMLicSize;
        
        //	현재 파일 포인터가 평문 범위에 있는지 검사한다.
        //
        if (ulFilePos < pContext->m_lSkipOffset)
        {
            lCopySize = (nReadSize <= (int)(pContext->m_lSkipOffset - ulFilePos)) ? nReadSize : (pContext->m_lSkipOffset - ulFilePos);
            lOrgSize = nReadSize;
            
            dwReadBytes = fread(pvBuff, 1, nReadSize, pContext->m_pDRMFile);
            
            nTotalRead = lCopySize;
            lOrgSize -= lCopySize;
            
            //	평문 이외 암호화 된 데이터는 복호화한다.
            //
            if (0 < lOrgSize)
            {
                ulFilePos += lCopySize;
                
                //	평문 위치만큼 건너 뛴 후 복호화한다.
                //
                XDRM_CNT_Decrypt(pContext, (XDRM_BYTE*)pvBuff + lCopySize, lOrgSize, ulFilePos);
                
                nTotalRead += lOrgSize;
            }
        }
        else
        {
            dwReadBytes = fread(pvBuff, 1, nReadSize, pContext->m_pDRMFile);
            
            if (0 < dwReadBytes)
            {
                XDRM_CNT_Decrypt(pContext, (XDRM_BYTE*)pvBuff, nReadSize, ulFilePos);
                
                nTotalRead = dwReadBytes;
            }
        }
        
    } 
    else 
    {
        //buffered mode ( streaming )
        //
        
        if(NULL != pContext->m_pDRMFile)
        {
           //buffered mode 인데 로컬 파일이 설정되어 있음 
           return XDRM_E_FAIL;
        }
        
        // 파일 기반이 아니고 버퍼 기반이므로
        ulFilePos =0;
        
        XDRM_CNT_Decrypt(pContext, (XDRM_BYTE*)pvBuff, nReadSize, ulFilePos);
        nTotalRead = nReadSize;
        
    }

	return	nTotalRead;
}

//-------------------------------------------------------
//	함수:	XSYNC_Seek
//	설명:	파일 포인터를 이동한다.
//	인자:	hContext - [입력] 초기화 된 파일 핸들
//		 	lOffset - [입력] 오프셋
//			nWhence - [입력] 기준 구분
//-------------------------------------------------------
int	XSYNC_Seek(IN HANDLE hContext,
			   IN long lOffset,
			   IN int nWhence)
{
	PXDRM_CTRL_CONTEXT	pContext = (PXDRM_CTRL_CONTEXT)hContext;

	if (SEEK_SET == nWhence)
	{
		lOffset += pContext->m_lXDRMHdrSize + pContext->m_lXDRMLicSize;
	}

	return	fseek(pContext->m_pDRMFile, lOffset, nWhence);
}

//-------------------------------------------------------
//	함수:	XSYNC_GetLength
//	설명:	평문 파일 크기를 반환한다.
//	인자:	hContext - [입력] 초기화 된 파일 핸들
//-------------------------------------------------------
long XSYNC_GetLength(IN HANDLE hContext)
{
	return	((PXDRM_CTRL_CONTEXT)hContext)->m_lFileSize;
}