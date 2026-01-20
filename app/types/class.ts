/**
 * Class-related types and interfaces
 */

import type { PaginationInfo } from './common';

// Schedule format: { "0": "18:00-19:30", "1": "18:00-19:30", ... }
// 0 = Monday, 1 = Tuesday, 2 = Wednesday, 3 = Thursday, 4 = Friday, 5 = Saturday, 6 = Sunday
export interface ClassSchedule {
  [key: string]: string; // Key: "0"-"6" (Monday-Sunday), Value: time range like "18:00-19:30"
}

interface Teacher {
  id: number;
  full_name: string;
  email: string;
}

export interface Class {
  id: number;
  name: string;
  subject: string;
  grade_level: string;
  monthly_tuition_fee: string | number;
  teacher: Teacher | null;
  schedule: ClassSchedule;
  student_count: number;
  created_at: string; // ISO date string
  updated_at: string; // ISO date string
}

export interface StudentClass {
  id: string;
  code: string;
  name: string;
  teacher: string;
  schedule: string;
  rawSchedule?: Record<string, string>; 
  room: string;
  attended: number;
  totalSessions: number;
  class_id: number;
  status: 'dropped' | 'pending' | 'active';
}

export interface DailyScheduleClass {
  timeStart: string;
  subject: string;
  teacher: string;
  room: string;
  status: 'live' | 'upcoming';
}

export interface ClassDetail extends Class {
  description?: string;
  max_students?: number;
  room?: string;
  status?: 'active' | 'inactive' | 'completed';
  duration_per_session?: number; // minutes
  total_sessions?: number;
  attended_sessions?: number;
}

export interface ClassCard extends Class {
  code?: string;
  room?: string;
  attended?: number;
  totalSessions?: number;
}

export interface AvailableClass {
  id: number;
  name: string;
  teacher: string;
  schedule: string;
  price: string;
  slots: number;
  tags: string[];
  subject?: string;
  grade_level?: string;
}

export interface ClassFilterParams {
  search?: string;
  subject?: string;
  grade_level?: string;
  sort?: 'name' | 'monthly_tuition_fee' | 'student_count';
  order?: 'asc' | 'desc';
  page?: number;
  limit?: number;
}

export interface ClassListResponse {
  classes: Class[];
  pagination: PaginationInfo;
}

export interface RegisterClassRequest {
  classId: number;
}

export interface RegisterClassResponse {
  success: boolean;
  message: string;
  data?: Class;
}

export interface LeaveClassRequest {
  classId: string | number;
  reason: string;
  leave_date?: string;
}

export interface LeaveClassResponse {
  success: boolean;
  message: string;
}

export interface ClassStatistics {
  totalClasses: number;
  activeClasses: number;
  totalStudents: number;
  totalRevenue: number;
  averageStudentsPerClass: number;
}
