import type { PaginationInfo } from './common';

interface SchoolClass {
  id: number;
  name: string;
  subject: string;
  grade_level: string;
  teacher_id: number;
  schedule: Record<string, string>;
  created_at: string;
  updated_at: string;
  description?: string;
  fee_per_session?: string;
  status: string;
  cover_image?: string | null;
}

export interface Assignment {
  id?: number;
  title: string;
  content?: string;
  due_date: string;
  school_class: SchoolClass;
  submission_status:
    | 'no_submission'
    | 'submitted'
    | 'late'
    | 'graded'
    | 'resubmit_requested';

  // Legacy fields for backward compatibility
  subject?: string;
  teacher_name?: string;
  description?: string;
  dueDate?: string;
  isUrgent?: boolean;
  status?: string;
  score?: number;
  feedback?: string;
  assignment_attachments?: AssignmentAttachment[];
  submission?: SubmissionHistory;
}

export interface SubmissionHistory {
  id: number;
  file_name?: string;
  content?: string;
  submitted_at?: string;
  status?: string;
  teacher_feedback?: string;
  score?: number;
}

export interface AssignmentFilter {
  status: string;
  subject: string;
  searchTerm: string;
}

export interface AssignmentListResponse {
  assignments: Assignment[];
  pagination: PaginationInfo;
}

export interface SubmissionListResponse {
  submissions: SubmissionHistory[];
  pagination: PaginationInfo;
}

export interface AssignmentAttachment {
  id: number;
  assignment_id: number;
  file_url: string;
  created_at: string;
  updated_at: string;
  file_name: string;
}
