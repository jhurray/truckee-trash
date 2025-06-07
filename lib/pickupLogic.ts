// lib/pickupLogic.ts
import { toZonedTime, format, fromZonedTime } from 'date-fns-tz';
import { parseISO, isValid, subDays, addDays } from 'date-fns';
import { allRecyclingDates, allYardWasteDates } from './pickupData';

export type DayPickupType =
  | "recycling"
  | "yard_waste"
  | "trash_only"
  | "no_pickup";

export type GetDayPickupTypeResult = { type: DayPickupType; dateInTruckee?: Date } | { error: "invalid_date_format" };

const TRUCKEE_TIMEZONE = 'America/Los_Angeles';

export function getDayPickupTypeLogic(dateString: string): GetDayPickupTypeResult {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
    return { error: "invalid_date_format" };
  }

  const representativeUtcDateForTruckeeDay = fromZonedTime(dateString, TRUCKEE_TIMEZONE);
  if (!isValid(representativeUtcDateForTruckeeDay)) {
    return { error: "invalid_date_format" }; // Handles cases like "2025-02-30"
  }

  // Determine the day of the week for 'dateString' as experienced in Truckee.
  // 'i' gives ISO day of week: 1 for Monday, ..., 7 for Sunday.
  let isoDayOfWeekInTruckee = parseInt(format(representativeUtcDateForTruckeeDay, 'i', { timeZone: TRUCKEE_TIMEZONE }), 10);

  let dateToEvaluate = representativeUtcDateForTruckeeDay;
  if (isoDayOfWeekInTruckee > 5) { // For Saturday or Sunday, we report next week's status by checking next Monday
      const daysToAdd = 8 - isoDayOfWeekInTruckee; // 2 for Sat (6), 1 for Sun (7)
      dateToEvaluate = addDays(dateToEvaluate, daysToAdd);
      isoDayOfWeekInTruckee = 1; // We are evaluating for a Monday
  }

  // For weekdays, check if it's a recycling or yard waste week.
  // The dates in allRecyclingDates and allYardWasteDates are the Friday of the pickup week.
  const fridayOfSameWeek = addDays(dateToEvaluate, 5 - isoDayOfWeekInTruckee);
  const fridayDateString = format(fridayOfSameWeek, 'yyyy-MM-dd', { timeZone: TRUCKEE_TIMEZONE });

  if (allRecyclingDates.has(fridayDateString)) {
    return { type: "recycling", dateInTruckee: representativeUtcDateForTruckeeDay };
  }

  if (allYardWasteDates.has(fridayDateString)) {
    return { type: "yard_waste", dateInTruckee: representativeUtcDateForTruckeeDay };
  }

  // If it's a weekday and not a special pickup week, it's trash only.
  return { type: "trash_only", dateInTruckee: representativeUtcDateForTruckeeDay };
}