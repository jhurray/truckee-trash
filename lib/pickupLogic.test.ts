// lib/pickupLogic.test.ts
import { getDayPickupTypeLogic } from './pickupLogic';

describe('getDayPickupTypeLogic', () => {
  test('should return error for invalid date format', () => {
    expect(getDayPickupTypeLogic('invalid')).toEqual({ error: 'invalid_date_format' });
    expect(getDayPickupTypeLogic('2025-1-1')).toEqual({ error: 'invalid_date_format' });
    expect(getDayPickupTypeLogic('25-01-01')).toEqual({ error: 'invalid_date_format' });
  });

  test('should return recycling for recycling dates', () => {
    const result = getDayPickupTypeLogic('2025-05-02');
    expect('type' in result).toBe(true);
    if ('type' in result) {
      expect(result.type).toBe('recycling');
    }
  });

  test('should return yard_waste for yard waste dates', () => {
    const result = getDayPickupTypeLogic('2025-05-09');
    expect('type' in result).toBe(true);
    if ('type' in result) {
      expect(result.type).toBe('yard_waste');
    }
  });

  test('should return yard_waste for Thursday July 3rd (special case)', () => {
    const result = getDayPickupTypeLogic('2025-07-03');
    expect('type' in result).toBe(true);
    if ('type' in result) {
      expect(result.type).toBe('yard_waste');
    }
  });

  test('should return trash_only for regular weekdays', () => {
    const result = getDayPickupTypeLogic('2025-05-01'); // Thursday, not special
    expect('type' in result).toBe(true);
    if ('type' in result) {
      expect(result.type).toBe('trash_only');
    }
  });

  test('should return no_pickup for weekends', () => {
    const saturdayResult = getDayPickupTypeLogic('2025-05-03'); // Saturday
    expect('type' in saturdayResult).toBe(true);
    if ('type' in saturdayResult) {
      expect(saturdayResult.type).toBe('no_pickup');
    }

    const sundayResult = getDayPickupTypeLogic('2025-05-04'); // Sunday
    expect('type' in sundayResult).toBe(true);
    if ('type' in sundayResult) {
      expect(sundayResult.type).toBe('no_pickup');
    }
  });

  test('should handle dates outside calendar range', () => {
    const result = getDayPickupTypeLogic('2027-01-01'); // Friday, outside calendar
    expect('type' in result).toBe(true);
    if ('type' in result) {
      expect(result.type).toBe('trash_only');
    }
  });

  test('should test various 2025 recycling dates', () => {
    const recyclingDates = [
      '2025-05-02', '2025-05-16', '2025-05-30',
      '2025-06-13', '2025-06-27',
      '2025-07-11', '2025-07-25',
      '2025-08-08', '2025-08-22',
      '2025-09-05', '2025-09-19',
      '2025-10-03', '2025-10-17', '2025-10-31',
      '2025-11-14', '2025-11-28',
      '2025-12-12', '2025-12-26',
    ];

    recyclingDates.forEach(date => {
      const result = getDayPickupTypeLogic(date);
      expect('type' in result).toBe(true);
      if ('type' in result) {
        expect(result.type).toBe('recycling');
      }
    });
  });

  test('should test various 2025 yard waste dates', () => {
    const yardWasteDates = [
      '2025-05-09', '2025-05-23',
      '2025-06-06', '2025-06-20',
      '2025-07-03', // Thursday special case
      '2025-07-18',
      '2025-08-01', '2025-08-15', '2025-08-29',
      '2025-09-12', '2025-09-26',
      '2025-10-10', '2025-10-24',
      '2025-11-07', '2025-11-21',
    ];

    yardWasteDates.forEach(date => {
      const result = getDayPickupTypeLogic(date);
      expect('type' in result).toBe(true);
      if ('type' in result) {
        expect(result.type).toBe('yard_waste');
      }
    });
  });
});