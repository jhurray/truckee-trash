// pages/index.tsx
import { GetServerSideProps } from 'next';
import { format, toZonedTime } from 'date-fns-tz';
import { RelevantWeekStatus } from '../lib/weekLogic';
import Head from 'next/head';

interface HomeProps {
  weekStatus: RelevantWeekStatus;
  currentDate: string;
}

export default function Home({ weekStatus, currentDate }: HomeProps) {
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

  const getDetail = (weekStatus: RelevantWeekStatus) => {
    if (weekStatus.specialPickupDayInWeek && weekStatus.specialPickupTypeOnDate) {
      const type = weekStatus.specialPickupTypeOnDate === 'recycling' ? '♻️ Recycling' : '🌿 Yard Waste';
      return `${type} Day: ${formatDate(weekStatus.specialPickupDayInWeek)}`;
    }
    if (weekStatus.weekStatus === 'normal_trash_week') {
      return 'Regular weekly pickup';
    }
    return null;
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString + 'T00:00:00');
    return format(date, 'MMM d, yyyy');
  };

  return (
    <div className={`page-container ${getBgClass(weekStatus.weekStatus)}`}>
      <Head>
        <title>Truckee Trash</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main className="status-display">
        <div className="status-emoji" aria-label="emoji">{getEmoji(weekStatus.weekStatus)}</div>
        <h1 className="status-title">{getTitle(weekStatus.weekStatus)}</h1>
        <p className="status-date-range">
          {formatDate(weekStatus.reportedWeek.startDate)} – {formatDate(weekStatus.reportedWeek.endDate)}
        </p>
        {getDetail(weekStatus) && (
          <p className="status-detail">{getDetail(weekStatus)}</p>
        )}
      </main>
      <footer className="page-footer">
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