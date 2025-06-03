// pages/index.tsx
import { GetServerSideProps } from 'next';
import { format, toZonedTime } from 'date-fns-tz';
import { RelevantWeekStatus } from '../lib/weekLogic';

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

  const getWeekStatusColor = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return 'text-blue-600 bg-blue-50 border-blue-200';
      case 'yard_waste_week':
        return 'text-green-600 bg-green-50 border-green-200';
      case 'normal_trash_week':
        return 'text-gray-600 bg-gray-50 border-gray-200';
      case 'no_pickup_week':
        return 'text-red-600 bg-red-50 border-red-200';
      default:
        return 'text-gray-600 bg-gray-50 border-gray-200';
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString + 'T00:00:00');
    return format(date, 'MMM d, yyyy');
  };

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-2xl mx-auto px-4">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Truckee Trash
          </h1>
          <p className="text-gray-600">
            Current Date: {formatDate(currentDate)}
          </p>
        </div>

        <div className={`bg-white rounded-lg shadow-lg p-8 border-2 ${getWeekStatusColor(weekStatus.weekStatus)}`}>
          <div className="text-center">
            <h2 className="text-3xl font-bold mb-4">
              {getWeekDisplayName(weekStatus.weekStatus)}
            </h2>
            
            <div className="text-lg mb-6">
              <p className="font-semibold text-gray-800">
                Service Week: {formatDate(weekStatus.reportedWeek.startDate)} - {formatDate(weekStatus.reportedWeek.endDate)}
              </p>
            </div>

            {weekStatus.specialPickupDayInWeek && weekStatus.specialPickupTypeOnDate && (
              <div className="bg-white bg-opacity-60 rounded-lg p-4 mb-4">
                <h3 className="text-xl font-semibold mb-2">Special Pickup</h3>
                <p className="text-lg">
                  {weekStatus.specialPickupTypeOnDate === 'recycling' ? 'Recycling' : 'Yard Waste'} Day: {formatDate(weekStatus.specialPickupDayInWeek)}
                </p>
              </div>
            )}

            <div className="text-base text-gray-700">
              {weekStatus.weekStatus === 'recycling_week' && (
                <div>
                  <p className="mb-2">🗂️ <strong>Recycling pickup</strong> this week</p>
                  <p>Regular trash is also collected on the same day</p>
                </div>
              )}
              {weekStatus.weekStatus === 'yard_waste_week' && (
                <div>
                  <p className="mb-2">🌿 <strong>Yard waste pickup</strong> this week</p>
                  <p>Regular trash is also collected on the same day</p>
                </div>
              )}
              {weekStatus.weekStatus === 'normal_trash_week' && (
                <div>
                  <p className="mb-2">🗑️ <strong>Regular trash only</strong> this week</p>
                  <p>Pickup available Monday through Friday</p>
                </div>
              )}
              {weekStatus.weekStatus === 'no_pickup_week' && (
                <div>
                  <p className="mb-2">❌ <strong>No pickup services</strong> this week</p>
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="mt-8 text-center text-sm text-gray-500">
          <p>Schedule updates automatically based on official Truckee waste collection calendar</p>
        </div>
      </div>
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