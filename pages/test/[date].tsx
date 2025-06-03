import { GetServerSideProps } from 'next';
import { format, toZonedTime } from 'date-fns-tz';
import { isValid, parseISO } from 'date-fns';
import { RelevantWeekStatus } from '../../lib/weekLogic';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useState, useEffect } from 'react';

interface TestPageProps {
  weekStatus: RelevantWeekStatus;
  inputDate: string;
  error?: string;
}

export default function TestPage({ weekStatus, inputDate, error }: TestPageProps) {
  const router = useRouter();
  const [selectedDate, setSelectedDate] = useState(inputDate);

  useEffect(() => {
    setSelectedDate(inputDate);
  }, [inputDate]);

  const handleDateChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const date = event.target.value;
    setSelectedDate(date);
    if (date) {
      router.push(`/test/${date}`);
    }
  };

  const getWeekDisplayName = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return 'Recycling Week';
      case 'yard_waste_week':
        return 'Yard Waste Week';
      case 'normal_trash_week':
        return 'Normal Trash Week';
      case 'no_pickup_week':
        return 'No Pickup Week';
      default:
        return 'Unknown';
    }
  };

  const getBgClass = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return 'recycling-bg';
      case 'yard_waste_week':
        return 'yard-waste-bg';
      case 'normal_trash_week':
        return 'normal-trash-bg';
      case 'no_pickup_week':
        return 'no-pickup-bg';
      default:
        return 'normal-trash-bg';
    }
  };

  const getEmoji = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return '♻️';
      case 'yard_waste_week':
        return '🌿';
      case 'normal_trash_week':
        return '🗑️';
      case 'no_pickup_week':
        return '❌';
      default:
        return '🗑️';
    }
  };

  const getTitle = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return 'Recycling';
      case 'yard_waste_week':
        return 'Yard Waste';
      case 'normal_trash_week':
        return 'Trash Only';
      case 'no_pickup_week':
        return 'No Pickup';
      default:
        return 'Trash Only';
    }
  };

  const formatDateDisplay = (dateString: string) => {
    const date = parseISO(dateString);
    return format(date, 'MMM d, yyyy');
  };
  
  const getDetail = (status: RelevantWeekStatus) => {
    if (status.specialPickupDayInWeek && status.specialPickupTypeOnDate) {
      const type = status.specialPickupTypeOnDate === 'recycling' ? '♻️ Recycling' : '🌿 Yard Waste';
      return `${type} Day: ${formatDateDisplay(status.specialPickupDayInWeek)}`;
    }
    if (status.weekStatus === 'normal_trash_week') {
      return 'Regular weekly pickup';
    }
    return null;
  };

  if (error) {
    return (
      <div className="page-container error-bg">
        <Head>
          <title>Error - Truckee Trash</title>
          <meta name="viewport" content="width=device-width, initial-scale=1" />
        </Head>
        <main className="status-display">
          <div className="status-emoji" aria-label="error-emoji">⚠️</div>
          <h1 className="status-title">Error</h1>
          <p className="status-detail">{error}</p>
        </main>
      </div>
    );
  }

  return (
    <div className={`page-container ${getBgClass(weekStatus.weekStatus)}`}>
      <Head>
        <title>Truckee Trash Status for {inputDate}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 20px', backgroundColor: 'rgba(0,0,0,0.1)' }}>
        <h2 style={{ margin: 0, fontSize: '1.2em' }}>Trash Status</h2>
        <div>
          <label htmlFor="date-picker" style={{ marginRight: '8px' }}>Change Date:</label>
          <input
            type="date"
            id="date-picker"
            value={selectedDate}
            onChange={handleDateChange}
            style={{ padding: '8px', fontSize: '1em' }}
          />
        </div>
      </header>
      <main className="status-display">
        <div className="status-emoji" aria-label="emoji">{getEmoji(weekStatus.weekStatus)}</div>
        <h1 className="status-title">{getTitle(weekStatus.weekStatus)}</h1>
        <p className="status-date-range">
          For date: {formatDateDisplay(inputDate)}
        </p>
        <p className="status-date-range">
          Week: {formatDateDisplay(weekStatus.reportedWeek.startDate)} – {formatDateDisplay(weekStatus.reportedWeek.endDate)}
        </p>
        {getDetail(weekStatus) && (
          <p className="status-detail">{getDetail(weekStatus)}</p>
        )}
      </main>
      <footer className="page-footer">
        <p>Displaying status for: {inputDate}</p>
        <a
          href="https://www.keeptruckeegreen.org/wp-content/uploads/2025/04/Recycling-Calendar-2025-2026.pdf"
          target="_blank"
          rel="noopener noreferrer"
        >
          Official Truckee Recycling & Trash Calendar (Source)
        </a>
      </footer>
    </div>
  );
}

export const getServerSideProps: GetServerSideProps = async (context) => {
  const { date } = context.params || {};
  const dateString = Array.isArray(date) ? date[0] : date;

  if (!dateString || !/^\d{4}-\d{2}-\d{2}$/.test(dateString) || !isValid(parseISO(dateString))) {
    return {
      props: {
        weekStatus: { // Provide a default/fallback structure
            reportedWeek: { startDate: 'N/A', endDate: 'N/A' },
            weekStatus: 'normal_trash_week',
            specialPickupDayInWeek: null,
            specialPickupTypeOnDate: null,
        },
        inputDate: dateString || 'invalid',
        error: 'Invalid date format. Please use YYYY-MM-DD.',
      },
    };
  }

  try {
    // Import the logic function dynamically
    const { getRelevantWeekStatusLogic } = await import('../../lib/weekLogic');
    const result = getRelevantWeekStatusLogic(dateString);

    if ('error' in result) {
      return {
        props: {
          weekStatus: { // Provide a default/fallback structure
            reportedWeek: { startDate: 'N/A', endDate: 'N/A' },
            weekStatus: 'normal_trash_week',
            specialPickupDayInWeek: null,
            specialPickupTypeOnDate: null,
          },
          inputDate: dateString,
          error: result.error,
        },
      };
    }

    return {
      props: {
        weekStatus: result,
        inputDate: dateString,
      },
    };
  } catch (error: any) {
    console.error('Error in getServerSideProps for /test/[date]:', error);
    return {
      props: {
        weekStatus: { // Provide a default/fallback structure
            reportedWeek: { startDate: 'N/A', endDate: 'N/A' },
            weekStatus: 'normal_trash_week',
            specialPickupDayInWeek: null,
            specialPickupTypeOnDate: null,
        },
        inputDate: dateString,
        error: 'Failed to calculate week status.',
      },
    };
  }
}; 