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
    <div className="page-container">
      <Head>
        <title>Select a Date - Truckee Trash Test</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main className="status-display" style={{ textAlign: 'center', paddingTop: '50px' }}>
        <h1>Select a Date</h1>
        <p>Choose a date to view its trash and recycling status.</p>
        <input
          type="date"
          value={selectedDate}
          onChange={handleDateChange}
          style={{ padding: '10px', fontSize: '16px', marginTop: '20px' }}
        />
        {selectedDate && (
          <p style={{ marginTop: '20px' }}>
            Navigating to status for: {selectedDate}
          </p>
        )}
      </main>
      <footer className="page-footer">
        <p>Choose a date to see the pickup schedule.</p>
      </footer>
    </div>
  );
} 