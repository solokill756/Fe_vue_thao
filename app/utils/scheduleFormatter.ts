/**
 * Format schedule object to readable string
 * @param schedule - Schedule object with day keys (0-6: Monday-Sunday)
 * @returns Formatted schedule string (e.g., "T2: 18:00-19:30, T4: 18:00-19:30")
 */
export const formatScheduleObject = (schedule: any): string => {
  if (typeof schedule === 'string') return schedule;
  if (!schedule || typeof schedule !== 'object') return 'Không có lịch';

  console.log('schedule', schedule);
  const dayMap: Record<string, string> = {
    '0': 'T2',  
    '1': 'T3',  
    '2': 'T4',  
    '3': 'T5',  
    '4': 'T6',  
    '5': 'T7',  
    '6': 'CN',  
  };

  const scheduleDays = Object.entries(schedule)
    .filter(([_, time]) => time)
    .map(([day, time]) => ({ day: dayMap[day] || day, time }));

  if (scheduleDays.length === 0) return 'Không có lịch';

  const timeGroups: Record<string, string[]> = {};
  scheduleDays.forEach(({ day, time }) => {
    const timeStr = time as string;
    if (!timeGroups[timeStr]) timeGroups[timeStr] = [];
    timeGroups[timeStr].push(day);
  });

  return Object.entries(timeGroups)
    .map(([time, days]) => `${days.join(', ')}: ${time}`)
    .join(' | ');
};
