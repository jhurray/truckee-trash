// lib/pickupLogic.test.ts
import { getDayPickupTypeLogic } from './pickupLogic';

describe('getDayPickupTypeLogic', () => {
  // Test for invalid date formats
  test('should return error for invalid date format', () => {
    expect(getDayPickupTypeLogic('invalid-date')).toEqual({ error: 'invalid_date_format' });
    expect(getDayPickupTypeLogic('2025-13-01')).toEqual({ error: 'invalid_date_format' }); // Invalid month
    expect(getDayPickupTypeLogic('2025-02-30')).toEqual({ error: 'invalid_date_format' }); // Invalid day
    expect(getDayPickupTypeLogic('2025-1-1')).toEqual({ error: 'invalid_date_format' }); // Needs leading zeros
  });

  // Test a known recycling week. The week of 2025-05-05 is a recycling week.
  // Monday 2025-05-05 is the date in the allRecyclingDates set.
  describe('Recycling Week of 2025-05-05', () => {
    const datesInRecyclingWeek = ['2025-05-05', '2025-05-06', '2025-05-07', '2025-05-08', '2025-05-09'];
    datesInRecyclingWeek.forEach(date => {
      test(`should return "recycling" for ${date}`, () => {
        const result = getDayPickupTypeLogic(date);
        if ('type' in result) {
          expect(result.type).toBe('recycling');
        } else {
          fail('Expected a valid pickup type but got an error');
        }
      });
    });
  });

  // Test a known yard waste week. The week of 2025-05-12 is a yard waste week.
  // Monday 2025-05-12 is in the allYardWasteDates set.
  describe('Yard Waste Week of 2025-05-12', () => {
    const datesInYardWasteWeek = ['2025-05-12', '2025-05-13', '2025-05-14', '2025-05-15', '2025-05-16'];
    datesInYardWasteWeek.forEach(date => {
      test(`should return "yard_waste" for ${date}`, () => {
        const result = getDayPickupTypeLogic(date);
        if ('type' in result) {
          expect(result.type).toBe('yard_waste');
        } else {
          fail('Expected a valid pickup type but got an error');
        }
      });
    });
  });

  // Test a week with no special pickup, should be trash-only.
  // The week of 2025-04-21 to 2025-04-25 is a trash-only week.
  describe('Trash-Only Week of 2025-04-21', () => {
    const datesInTrashOnlyWeek = ['2025-04-21', '2025-04-22', '2025-04-23', '2025-04-24', '2025-04-25'];
    datesInTrashOnlyWeek.forEach(date => {
      test(`should return "trash_only" for ${date}`, () => {
        const result = getDayPickupTypeLogic(date);
        if ('type' in result) {
          expect(result.type).toBe('trash_only');
        } else {
          fail('Expected a valid pickup type but got an error');
        }
      });
    });
  });

  // Test for weekends
  describe('Weekends', () => {
    test('should return next week\'s status for Saturday (yard waste)', () => {
      // Sat 2025-05-10 should check Mon 2025-05-12, which is a yard waste week (pickup on Fri 2025-05-16)
      const result = getDayPickupTypeLogic('2025-05-10');
      if ('type' in result) {
        expect(result.type).toBe('yard_waste');
      } else {
        fail('Expected a valid pickup type but got an error');
      }
    });

    test('should return next week\'s status for Sunday (yard waste)', () => {
      // Sun 2025-05-11 should check Mon 2025-05-12, which is a yard waste week (pickup on Fri 2025-05-16)
      const result = getDayPickupTypeLogic('2025-05-11');
      if ('type' in result) {
        expect(result.type).toBe('yard_waste');
      } else {
        fail('Expected a valid pickup type but got an error');
      }
    });

    test('should return next week\'s status for Saturday (recycling)', () => {
        // Sat 2025-05-03 should check Mon 2025-05-05, which is a recycling week (pickup on Fri 2025-05-09)
        const result = getDayPickupTypeLogic('2025-05-03');
        if ('type' in result) {
          expect(result.type).toBe('recycling');
        } else {
          fail('Expected a valid pickup type but got an error');
        }
    });

    test('should return next week\'s status for Saturday (trash only)', () => {
        // Sat 2025-04-19 should check Mon 2025-04-21, which is a trash only week.
        const result = getDayPickupTypeLogic('2025-04-19');
        if ('type' in result) {
          expect(result.type).toBe('trash_only');
        } else {
          fail('Expected a valid pickup type but got an error');
        }
    });
  });

  // Test date outside of the known pickup schedule range
  test('should return trash_only for a weekday outside of special pickup schedule', () => {
    const result = getDayPickupTypeLogic('2026-01-05'); // A Monday in the future
    if ('type' in result) {
      expect(result.type).toBe('trash_only');
    } else {
      fail('Expected a valid pickup type but got an error');
    }
  });

  // Test edge cases like the beginning and end of a year
  test('should correctly handle year boundaries', () => {
    // A week that spans two years. Monday is 2023-12-25
    // This isn't a recycling or yard waste week.
    let result = getDayPickupTypeLogic('2024-01-01'); // Monday
    if ('type' in result) {
      expect(result.type).toBe('trash_only');
    } else {
      fail('Expected a valid pickup type but got an error');
    }

    // Friday of the same week
    result = getDayPickupTypeLogic('2024-01-05');
    if ('type' in result) {
      expect(result.type).toBe('trash_only');
    } else {
      fail('Expected a valid pickup type but got an error');
    }
  });
});