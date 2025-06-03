export const recyclingDates2025 = new Set([
  "2025-05-09",
  "2025-05-23",
  "2025-06-06",
  "2025-06-20",
  "2025-07-04", // Friday, July 4th
  "2025-07-18",
  "2025-08-01",
  "2025-08-15",
  "2025-08-29",
  "2025-09-12",
  "2025-09-26",
  "2025-10-10",
  "2025-10-24",
  "2025-11-07",
  "2025-11-21",
  "2025-12-05",
  "2025-12-19",
]);

export const yardWasteDates2025 = new Set([
  "2025-05-02",
  "2025-05-16",
  "2025-05-30",
  "2025-06-13",
  "2025-06-27",
  "2025-07-11",
  "2025-07-25",
  "2025-08-08",
  "2025-08-22",
  "2025-09-05",
  "2025-09-19",
  "2025-10-03",
  "2025-10-17",
  "2025-10-31",
  "2025-11-14",
  "2025-11-28",
]);

export const recyclingDates2026 = new Set([
  "2026-01-02",
  "2026-01-16",
  "2026-01-30",
  "2026-02-13",
  "2026-02-27",
  "2026-03-13",
  "2026-03-27",
  "2026-04-10",
  "2026-04-24",
]);

// Based on the provided CSV, there are no Yard Waste dates listed for 2026
// within the range of the CSV (which ends May 1, 2026).
export const yardWasteDates2026 = new Set<string>([
  "2026-05-01",
]);

// Consolidate all dates
export const allRecyclingDates = new Set([
  ...Array.from(recyclingDates2025),
  ...Array.from(recyclingDates2026)
]);
export const allYardWasteDates = new Set([
  ...Array.from(yardWasteDates2025),
  ...Array.from(yardWasteDates2026)
]);