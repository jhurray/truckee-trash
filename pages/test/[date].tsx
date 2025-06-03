import { GetServerSideProps } from 'next';
import { format } from 'date-fns-tz';
import { isValid, parseISO } from 'date-fns';
import { RelevantWeekStatus } from '../../lib/weekLogic';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useState, useEffect } from 'react';
import WeekStatusDisplay from '../../components/WeekStatusDisplay';

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

  const formatDateDisplay = (dateString: string) => {
    const date = parseISO(dateString);
    return format(date, 'MMM d, yyyy');
  };

  if (error) {
    return (
      <div className="week-status-container no-pickup-bg">
        <Head>
          <title>Error - Truckee Trash</title>
          <meta name="viewport" content="width=device-width, initial-scale=1" />
        </Head>
        <main className="week-status-content">
          <div className="week-status-emoji">⚠️</div>
          <h1 className="week-status-title">Error</h1>
          <p className="week-status-subtitle">{error}</p>
        </main>
        <footer className="week-status-footer">
          <a href="/test">← Choose Another Date</a>
        </footer>
      </div>
    );
  }

  return (
    <>
      <Head>
        <title>Truckee Trash - {formatDateDisplay(inputDate)}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      
      {/* Date picker overlay */}
      <div style={{
        position: 'fixed',
        top: '20px',
        right: '20px',
        background: 'rgba(0,0,0,0.8)',
        color: 'white',
        padding: '1rem',
        borderRadius: '8px',
        fontSize: '0.9rem',
        zIndex: 1000,
        display: 'flex',
        flexDirection: 'column',
        gap: '0.5rem'
      }}>
        <div style={{ fontWeight: 'bold' }}>
          Test Date: {formatDateDisplay(inputDate)}
        </div>
        <input
          type="date"
          value={selectedDate}
          onChange={handleDateChange}
          style={{
            padding: '0.5rem',
            borderRadius: '4px',
            border: 'none',
            fontSize: '0.9rem'
          }}
        />
        <a href="/test" style={{ color: 'white', textAlign: 'center' }}>← Back</a>
      </div>

      <WeekStatusDisplay weekStatus={weekStatus} />
    </>
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