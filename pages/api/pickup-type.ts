// pages/api/pickup-type.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { getDayPickupTypeLogic, DayPickupType } from '../../lib/pickupLogic';

type ApiResponseData = {
  date: string;
  pickupType: DayPickupType;
};
type ApiErrorResponse = { error: string };

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<ApiResponseData | ApiErrorResponse>
) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET']);
    return res.status(405).json({ error: `Method ${req.method} Not Allowed` });
  }

  const { date } = req.query;

  if (typeof date !== 'string') { // Basic check, more robust in logic function
    return res.status(400).json({ error: 'Date parameter is required.' });
  }

  const result = getDayPickupTypeLogic(date);

  if ('error' in result) {
    return res.status(400).json({ error: "Date parameter must be in YYYY-MM-DD format." });
  }

  res.status(200).json({ date: date, pickupType: result.type });
}