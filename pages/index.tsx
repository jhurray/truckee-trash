// pages/index.tsx
import { GetServerSideProps } from 'next';
import { format, toZonedTime } from 'date-fns-tz';
import { RelevantWeekStatus } from '../lib/weekLogic';
import Head from 'next/head';
import WeekStatusDisplay from '../components/WeekStatusDisplay';

interface HomeProps {
  weekStatus: RelevantWeekStatus;
  currentDate: string;
}

export default function Home({ weekStatus, currentDate }: HomeProps) {
  return (
    <>
      <Head>
        <title>Truckee Trash</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="description" content="Truckee trash pickup schedule - see what's being collected this week" />
      </Head>
      <WeekStatusDisplay weekStatus={weekStatus} />
    </>
  );
}

export const getServerSideProps: GetServerSideProps = async () => {
  try {
    // Get current date in Truckee timezone
    const now = new Date();
    const truckeeDateString = format(toZonedTime(now, 'America/Los_Angeles'), 'yyyy-MM-dd');
    
    // Import the logic function dynamically to avoid import issues in serverless
    const { getRelevantWeekStatusLogic } = await import('../lib/weekLogic');
    
    const result = getRelevantWeekStatusLogic(truckeeDateString);
    
    if ('error' in result) {
      throw new Error(result.error);
    }

    return {
      props: {
        weekStatus: result,
        currentDate: truckeeDateString,
      },
    };
  } catch (error) {
    console.error('Error in getServerSideProps:', error);
    
    // Fallback response
    return {
      props: {
        weekStatus: {
          reportedWeek: {
            startDate: '2025-01-01',
            endDate: '2025-01-05'
          },
          weekStatus: 'normal_trash_week' as const,
          specialPickupDayInWeek: null,
          specialPickupTypeOnDate: null,
        },
        currentDate: '2025-01-01',
      },
    };
  }
};