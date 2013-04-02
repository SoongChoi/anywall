/**************************************************************************************
 * DESCRIPTION:
 *       These are application routines for DATE and TIME
  **************************************************************************************/
#include <time.h>
#include <stdio.h>
#include "XSyncv20_Date.h"

unsigned int gMSCTime;

//==============================================================
//
//		Internal Variable
//
//==============================================================
const char nMonthDays[13] =
{
	0,		// Reserved
	31,		// January
	28,		// February	[ Ignore leap Month ]
	31,		// March
	30,		// April
	31,		// May
	30,		// June
	31,		// July
	31,		// August
	30,		// September
	31,		// October
	30,		// November
	31		// December
};


/*************************************************************************************
 *          DATE_GetTotalDaysUntilTodayFrom1970
 *
 * Description  :
 * Argument     :
 * Return       :
 *
 *************************************************************************************/
int DATE_GetTotalDaysUntilTodayFrom1970(int nThisYear, int nMonth, int nDay)
{
	int dwTotalDays;

	/* Check if Month parameter are valid */
	if (nThisYear < 1970)
		return 0;

	dwTotalDays =	(nThisYear-1970)*365 +
					(nThisYear-1969)/4 -
					(nThisYear-1969)/100 +
					(nThisYear-1969)/400;

	dwTotalDays += DATE_GetTotalDaysUntilTodayInThisYear(nThisYear, nMonth, nDay);

	return dwTotalDays;
}

/*************************************************************************************
 *         DATE_GetTotalDaysUntilTodayInThisYear
 *
 * Description  :
 * Argument     :
 * Return       :
 *
 *************************************************************************************/
int DATE_GetTotalDaysUntilTodayInThisYear(int nThisYear, int nMonth, int nDay)
{
	unsigned int	i;
	int			dwTotalDays;

	/* Check if Month parameter are valid */
	if (nMonth < 1 || nMonth > 12)	// [ 1 - 12 ]
		return 0;
	/* Check if Day parameter are valid */
	if (nDay > DATE_GetTotalDaysInMonth(nThisYear, nMonth))
		return 0;

	dwTotalDays = nDay;

	for (i = 1; i < nMonth; ++i)
		dwTotalDays += DATE_GetTotalDaysInMonth(nThisYear, i);

	return 	dwTotalDays;
}

/*************************************************************************************
 *          DATE_GetTotalDaysInMonth
 *
 * Description  :
 * Argument     :
 * Return       :
 *
 *************************************************************************************/
int DATE_GetTotalDaysInMonth(int nThisYear, int nMonth)
{
	/* Check if Month parameter are valid */
	if (nMonth < 1 || nMonth > 12)	// [ 1 - 12 ]
		return 0;

	/* Get total Days */
	if (nMonth == DATE_FEBRUARY)
	{
		if (DATE_GetIsThisYearLeapYear(nThisYear) == DATE_LEAP_YEAR)
			return nMonthDays[nMonth] + 1;
		else
			return nMonthDays[nMonth];
	}

	return nMonthDays[nMonth];
}

/*************************************************************************************
 *          DATE_GetIsThisYearLeapYear
 *
 * Description  :
 * Argument     :
 * Return       :
 *
 *************************************************************************************/
int DATE_GetIsThisYearLeapYear(int nThisYear)
{
	if (((nThisYear % 4) == 0 && (nThisYear % 100) != 0) || (nThisYear % 400 == 0))
		return DATE_LEAP_YEAR;

	return DATE_COMMON_YEAR;
}

/*************************************************************************************
 *          XDRM_GetTime
 *
 * Description : device의 RTC를 가져오는 함수.
 * Argument   : [strDate] 년(4)-월(2)-일(2)의 형태로, 2006년 2월 16일 이라면 "2006-02-16"으로 넘겨주면 됨.  
                       [sec] 현재 시간을 초단위로 나타낸 정보로, 현재 시간이 14시 30분 25초라면, 52225의 값을 가짐.
 * Return       :
 *
 *************************************************************************************/
void XDRM_GetTime(time_t tmDateTime, char *strDate, unsigned int *nTotalTimes)
{
    struct	tm *sDateTime;
    time_t	long_time = tmDateTime;

	if (0 == long_time)
	{
		long_time = time(NULL);
	}

	sDateTime = localtime(&long_time);

    sprintf(strDate, "%04d-%02d-%02d", sDateTime->tm_year+1900, sDateTime->tm_mon+1, sDateTime->tm_mday);
	*nTotalTimes = sDateTime->tm_hour*3600+sDateTime->tm_min*60+sDateTime->tm_sec;
}