// pages/api/relevant-week-pickup-status.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { getRelevantWeekStatusLogic, RelevantWeekStatus } from '../../lib/weekLogic';

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<RelevantWeekStatus | { error: string }>
) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET']);
    return res.status(405).json({ error: `Method ${req.method} Not Allowed` });
  }

  const { currentDate } = req.query;

  if (typeof currentDate !== 'string') {
    return res.status(400).json({ error: 'currentDate parameter is required.' });
  }

  const result = getRelevantWeekStatusLogic(currentDate);

  if ('error' in result) {
    return res.status(400).json({ error: result.error });
  }

  res.status(200).json(result);
}