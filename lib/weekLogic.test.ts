// lib/weekLogic.test.ts
import { getRelevantWeekStatusLogic } from './weekLogic';

describe('getRelevantWeekStatusLogic', () => {
  test('should return error for invalid date format', () => {
    expect(getRelevantWeekStatusLogic('invalid')).toEqual({ 
      error: 'currentDate parameter must be in YYYY-MM-DD format.' 
    });
    expect(getRelevantWeekStatusLogic('2025-1-1')).toEqual({ 
      error: 'currentDate parameter must be in YYYY-MM-DD format.' 
    });
  });

  test('should return current week for weekday input', () => {
    // Tuesday May 6, 2025 should return the week of May 5-9, 2025
    const result = getRelevantWeekStatusLogic('2025-05-06');
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.reportedWeek.startDate).toBe('2025-05-05'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-05-09'); // Friday
    }
  });

  test('should return next week for weekend input', () => {
    // Saturday May 10, 2025 should return the week of May 12-16, 2025
    const result = getRelevantWeekStatusLogic('2025-05-10');
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.reportedWeek.startDate).toBe('2025-05-12'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-05-16'); // Friday
    }
  });

  test('should identify recycling week correctly', () => {
    // Week containing Friday May 2, 2025 (recycling day)
    const result = getRelevantWeekStatusLogic('2025-04-29'); // Tuesday of that week
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.weekStatus).toBe('recycling_week');
      expect(result.specialPickupDayInWeek).toBe('2025-05-02');
      expect(result.specialPickupTypeOnDate).toBe('recycling');
      expect(result.reportedWeek.startDate).toBe('2025-04-28'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-05-02'); // Friday
    }
  });

  test('should identify yard waste week correctly', () => {
    // Week containing Friday May 9, 2025 (yard waste day)
    const result = getRelevantWeekStatusLogic('2025-05-06'); // Tuesday of that week
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.weekStatus).toBe('yard_waste_week');
      expect(result.specialPickupDayInWeek).toBe('2025-05-09');
      expect(result.specialPickupTypeOnDate).toBe('yard_waste');
      expect(result.reportedWeek.startDate).toBe('2025-05-05'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-05-09'); // Friday
    }
  });

  test('should identify normal trash week correctly', () => {
    // Week with no special pickups (April 2025, before pickup schedule starts)
    const result = getRelevantWeekStatusLogic('2025-04-22'); // Tuesday of a normal week
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.weekStatus).toBe('normal_trash_week');
      expect(result.specialPickupDayInWeek).toBe(null);
      expect(result.specialPickupTypeOnDate).toBe(null);
      expect(result.reportedWeek.startDate).toBe('2025-04-21'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-04-25'); // Friday
    }
  });

  test('should handle Thursday July 3rd yard waste correctly', () => {
    // Week containing Thursday July 3, 2025 (special case yard waste day)
    const result = getRelevantWeekStatusLogic('2025-07-01'); // Tuesday of that week
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.weekStatus).toBe('yard_waste_week');
      expect(result.specialPickupDayInWeek).toBe('2025-07-03');
      expect(result.specialPickupTypeOnDate).toBe('yard_waste');
      expect(result.reportedWeek.startDate).toBe('2025-06-30'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-07-04'); // Friday
    }
  });

  test('should return next week when called on Sunday', () => {
    // Sunday May 11, 2025 should return the week of May 12-16, 2025
    const result = getRelevantWeekStatusLogic('2025-05-11');
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      // May 16 is a recycling day, so this should be a recycling week
      expect(result.weekStatus).toBe('recycling_week');
      expect(result.reportedWeek.startDate).toBe('2025-05-12'); // Monday
      expect(result.reportedWeek.endDate).toBe('2025-05-16'); // Friday
      expect(result.specialPickupDayInWeek).toBe('2025-05-16');
      expect(result.specialPickupTypeOnDate).toBe('recycling');
    }
  });

  test('should handle edge case dates', () => {
    // Test date far in the future (should be normal trash week)
    const result = getRelevantWeekStatusLogic('2027-01-01');
    expect('error' in result).toBe(false);
    if (!('error' in result)) {
      expect(result.weekStatus).toBe('normal_trash_week');
      expect(result.specialPickupDayInWeek).toBe(null);
      expect(result.specialPickupTypeOnDate).toBe(null);
    }
  });
});