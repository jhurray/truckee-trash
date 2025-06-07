// lib/weekLogic.ts
import { toZonedTime, format, fromZonedTime } from 'date-fns-tz';
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
    return { error: "currentDate parameter must be in yyyy-MM-dd format." };
  }

  const currentDateUtcEquivalent = fromZonedTime(currentDateString, TRUCKEE_TIMEZONE);
  if (!isValid(currentDateUtcEquivalent)) {
      return { error: "Invalid currentDate." };
  }

  const isoDayOfWeekForCurrentDate = parseInt(format(currentDateUtcEquivalent, 'i', { timeZone: TRUCKEE_TIMEZONE }), 10);
  const dayOfWeekInTruckee = isoDayOfWeekForCurrentDate % 7; // JS: 0=Sun, 1=Mon...

  let serviceWeekStartInTruckee: Date;

  // Use currentDateUtcEquivalent for date math (addDays, startOfWeek)
  if (dayOfWeekInTruckee === 0 || dayOfWeekInTruckee === 6) { // Sunday or Saturday
    // Report next week.
    const daysToNextMonday = dayOfWeekInTruckee === 0 ? 1 : 2; // If Sun, next day is Mon. If Sat, 2 days to Mon.
    serviceWeekStartInTruckee = addDays(currentDateUtcEquivalent, daysToNextMonday);
  } else { // Monday to Friday
    // Report current week.
    serviceWeekStartInTruckee = startOfWeek(currentDateUtcEquivalent, { weekStartsOn: 1 }); // weekStartsOn: 1 is Monday
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
  for (const day of daysInServiceWeek.reverse()) {
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