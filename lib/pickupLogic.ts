// lib/pickupLogic.ts
import { toZonedTime, format, fromZonedTime } from 'date-fns-tz';
import { parseISO, isValid } from 'date-fns';
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

  // Check against corrected special pickup date sets
  if (allRecyclingDates.has(dateString)) {
    return { type: "recycling", dateInTruckee: representativeUtcDateForTruckeeDay };
  }
  if (allYardWasteDates.has(dateString)) {
    return { type: "yard_waste", dateInTruckee: representativeUtcDateForTruckeeDay };
  }

  // Determine the day of the week for 'dateString' as experienced in Truckee.
  // 'i' gives ISO day of week: 1 for Monday, ..., 7 for Sunday.
  const isoDayOfWeekInTruckee = parseInt(format(representativeUtcDateForTruckeeDay, 'i', { timeZone: TRUCKEE_TIMEZONE }), 10);

  // Convert ISO day (1=Mon...7=Sun) to JavaScript standard day (0=Sun...6=Sat)
  const jsDayOfWeekInTruckee = isoDayOfWeekInTruckee % 7;

  if (jsDayOfWeekInTruckee >= 1 && jsDayOfWeekInTruckee <= 5) { // Monday to Friday
    return { type: "trash_only", dateInTruckee: representativeUtcDateForTruckeeDay };
  } else { // Saturday or Sunday
    return { type: "no_pickup", dateInTruckee: representativeUtcDateForTruckeeDay };
  }
}