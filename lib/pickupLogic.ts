// lib/pickupLogic.ts
import { toZonedTime, format } from 'date-fns-tz';
import { parseISO, getDay, isValid } from 'date-fns';
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

  // Parse the date string. IMPORTANT: date-fns parseISO treats date-only strings as UTC.
  // To correctly interpret it as a local date in Truckee, we effectively treat the input YYYY-MM-DD
  // as "that date at midnight in Truckee".
  const parsedDate = parseISO(dateString); // This is YYYY-MM-DD_T00:00:00Z_
  if (!isValid(parsedDate)) {
      return { error: "invalid_date_format" }; // Should be caught by regex, but good practice
  }

  // The `dateString` itself is what we check against our sets.
  // For day-of-week logic, we need to know what day it is *in Truckee*.
  // `toZonedTime` converts a UTC Date object to a Date object whose local parts reflect the target timezone.
  const dateInTruckee = toZonedTime(parsedDate, TRUCKEE_TIMEZONE);

  if (allRecyclingDates.has(dateString)) {
    return { type: "recycling", dateInTruckee };
  }
  if (allYardWasteDates.has(dateString)) {
    return { type: "yard_waste", dateInTruckee };
  }

  // `getDay` from `date-fns` returns 0 for Sunday, 1 for Monday, ..., 6 for Saturday.
  // We need the day of the week as it is in Truckee for the given `dateString`.
  const dayOfWeekInTruckee = getDay(dateInTruckee); // 0 (Sun) to 6 (Sat)

  if (dayOfWeekInTruckee >= 1 && dayOfWeekInTruckee <= 5) { // Monday to Friday
    return { type: "trash_only", dateInTruckee };
  } else { // Saturday or Sunday
    return { type: "no_pickup", dateInTruckee };
  }
}