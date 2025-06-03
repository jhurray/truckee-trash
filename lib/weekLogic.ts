// lib/weekLogic.ts
import { toZonedTime, format } from 'date-fns-tz';
import { parseISO, getDay, addDays, startOfWeek, isValid, eachDayOfInterval } from 'date-fns';
import { getDayPickupTypeLogic, DayPickupType } from './pickupLogic';

const TRUCKEE_TIMEZONE = 'America/Los_Angeles';

export type WeekStatusType = "recycling_week" | "yard_waste_week" | "normal_trash_week" | "no_pickup_week";

export interface RelevantWeekStatus {
  reportedWeek: {
    startDate: string; // YYYY-MM-DD
    endDate: string;   // YYYY-MM-DD
  };
  weekStatus: WeekStatusType;
  specialPickupDayInWeek: string | null;
  specialPickupTypeOnDate: "recycling" | "yard_waste" | null;
}

export function getRelevantWeekStatusLogic(currentDateString: string): RelevantWeekStatus | { error: string } {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(currentDateString)) {
    return { error: "currentDate parameter must be in YYYY-MM-DD format." };
  }

  const parsedCurrentDate = parseISO(currentDateString); // Represents UTC midnight
  if (!isValid(parsedCurrentDate)) {
      return { error: "Invalid currentDate." };
  }
  // Convert the UTC midnight representation to the actual date in Truckee
  const currentDateInTruckee = toZonedTime(parsedCurrentDate, TRUCKEE_TIMEZONE);

  let serviceWeekStartInTruckee: Date;
  const dayOfWeekInTruckee = getDay(currentDateInTruckee); // 0 (Sun) to 6 (Sat)

  // Determine the Monday of the service week to report on
  if (dayOfWeekInTruckee === 0 || dayOfWeekInTruckee === 6) { // Sunday or Saturday
    // Report next week. Find next Monday.
    const daysToNextMonday = dayOfWeekInTruckee === 0 ? 1 : 2; // Sunday: add 1 day, Saturday: add 2 days
    serviceWeekStartInTruckee = addDays(currentDateInTruckee, daysToNextMonday);
  } else { // Monday to Friday
    // Report current week. Find current Monday.
    serviceWeekStartInTruckee = startOfWeek(currentDateInTruckee, { weekStartsOn: 1 });
  }

  const serviceWeekEndInTruckee = addDays(serviceWeekStartInTruckee, 4); // Monday + 4 days = Friday

  let weekStatus: WeekStatusType = "normal_trash_week"; // Default
  let specialPickupDayInWeek: string | null = null;
  let specialPickupTypeOnDate: "recycling" | "yard_waste" | null = null;

  const daysInServiceWeek = eachDayOfInterval({
    start: serviceWeekStartInTruckee,
    end: serviceWeekEndInTruckee,
  });

  let hasAnyWeekdayPickup = false;
  for (const day of daysInServiceWeek) {
    const dayString = format(day, 'yyyy-MM-dd', { timeZone: TRUCKEE_TIMEZONE }); // Format as Truckee date string
    const pickupResult = getDayPickupTypeLogic(dayString);

    if ('type' in pickupResult) {
        if (pickupResult.type === "recycling") {
            weekStatus = "recycling_week";
            specialPickupDayInWeek = dayString;
            specialPickupTypeOnDate = "recycling";
            hasAnyWeekdayPickup = true;
            break; // Found special pickup, define week by it
        } else if (pickupResult.type === "yard_waste") {
            weekStatus = "yard_waste_week";
            specialPickupDayInWeek = dayString;
            specialPickupTypeOnDate = "yard_waste";
            hasAnyWeekdayPickup = true;
            break; // Found special pickup
        } else if (pickupResult.type !== "no_pickup") {
            hasAnyWeekdayPickup = true; // e.g. trash_only
        }
    }
  }

  if (!hasAnyWeekdayPickup && weekStatus === "normal_trash_week") {
      // If after checking all 5 days, no pickup (not even trash_only) was found.
      weekStatus = "no_pickup_week";
  }

  return {
    reportedWeek: {
      startDate: format(serviceWeekStartInTruckee, 'yyyy-MM-dd', { timeZone: TRUCKEE_TIMEZONE }),
      endDate: format(serviceWeekEndInTruckee, 'yyyy-MM-dd', { timeZone: TRUCKEE_TIMEZONE }),
    },
    weekStatus,
    specialPickupDayInWeek,
    specialPickupTypeOnDate,
  };
}