import type { PaginationInfo } from './common';

export type AttendanceStatus =
  | 'present'
  | 'absent_w_reason'
  | 'absent_no_reason'
  | 'late';

export interface StudentAttendanceRecord {
  id: number;
  status: AttendanceStatus;
  note?: string | null;
  score_in_class?: number | null;
}

export interface StudentAttendanceSession {
  id: number;
  class_id: number;
  date: string;
  teacher_note?: string | null;
  student_record: StudentAttendanceRecord | null;
}

export interface AttendanceSessionsResponse {
  sessions: StudentAttendanceSession[];
  pagination: PaginationInfo;
}
