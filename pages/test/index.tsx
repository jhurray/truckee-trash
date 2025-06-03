import { useRouter } from 'next/router';
import { useState } from 'react';
import Head from 'next/head';

export default function TestIndexPage() {
  const router = useRouter();
  const [selectedDate, setSelectedDate] = useState('');

  const handleDateChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const date = event.target.value;
    setSelectedDate(date);
    if (date) {
      router.push(`/test/${date}`);
    }
  };

  return (
    <div className="week-status-container normal-trash-bg">
      <Head>
        <title>Select a Date - Truckee Trash Test</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main className="week-status-content">
        <div className="week-status-emoji">📅</div>
        <h1 className="week-status-title">Test Any Date</h1>
        <p className="week-status-subtitle">Choose a date to see pickup status</p>
        <input
          type="date"
          value={selectedDate}
          onChange={handleDateChange}
          style={{ 
            padding: '1rem', 
            fontSize: '1.2rem', 
            marginTop: '2rem',
            borderRadius: '8px',
            border: '2px solid white',
            background: 'rgba(255,255,255,0.9)',
            color: '#333'
          }}
        />
      </main>
      <footer className="week-status-footer">
        <a href="/">← Back to Current Week</a>
      </footer>
    </div>
  );
} 