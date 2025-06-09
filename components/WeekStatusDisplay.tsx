// components/WeekStatusDisplay.tsx
import { RelevantWeekStatus } from '../lib/weekLogic';

interface WeekStatusDisplayProps {
  weekStatus: RelevantWeekStatus;
  showFooter?: boolean;
}

export default function WeekStatusDisplay({ weekStatus, showFooter = true }: WeekStatusDisplayProps) {
  const getWeekMessage = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return 'This Week: Recycling + Trash';
      case 'yard_waste_week':
        return 'This Week: Yard Waste + Trash';
      case 'normal_trash_week':
        return 'This Week: Trash Only';
      case 'no_pickup_week':
        return 'This Week: No Pickup';
      default:
        return 'This Week: Trash Only';
    }
  };

  const getSymbol = (status: string): { type: 'emoji' | 'image'; value: string } => {
    switch (status) {
      case 'recycling_week':
        return { type: 'image', value: '/Recycling-medium.png' };
      case 'yard_waste_week':
        return { type: 'image', value: '/YardWaste-medium.png' };
      case 'normal_trash_week':
        return { type: 'emoji', value: '🗑️' };
      case 'no_pickup_week':
        return { type: 'emoji', value: '🚫' };
      default:
        return { type: 'emoji', value: '🗑️' };
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

  const getSubMessage = (status: string) => {
    switch (status) {
      case 'recycling_week':
        return 'Put out recycling bins with your regular trash';
      case 'yard_waste_week':
        return 'Put out yard waste with your regular trash';
      case 'normal_trash_week':
        return 'Regular trash pickup only';
      case 'no_pickup_week':
        return 'No pickup services this week';
      default:
        return 'Regular trash pickup only';
    }
  };

  const symbol = getSymbol(weekStatus.weekStatus);

  return (
    <div className={`week-status-container ${getBgClass(weekStatus.weekStatus)}`}>
      <main className="week-status-content">
        <div className="week-status-emoji">
          {symbol.type === 'image' ? (
            <img src={symbol.value} alt={weekStatus.weekStatus} />
          ) : (
            symbol.value
          )}
        </div>
        <h1 className="week-status-title">{getWeekMessage(weekStatus.weekStatus)}</h1>
        <p className="week-status-subtitle">{getSubMessage(weekStatus.weekStatus)}</p>
      </main>
      
      {showFooter && (
        <footer className="week-status-footer">
          <a
            href="https://www.keeptruckeegreen.org/wp-content/uploads/2025/04/Recycling-Calendar-2025-2026.pdf"
            target="_blank"
            rel="noopener noreferrer"
          >
            Official Truckee Calendar
          </a>
          <a href="mailto:jhurray33@gmail.com">Contact Me</a>
        </footer>
      )}
    </div>
  );
}