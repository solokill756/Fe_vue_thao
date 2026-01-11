export interface StudentProfile {
  id: number;
  full_name: string;
  email: string;
  dob: string | null;
  parent_name: string | null;
  parent_phone: string | null;
  school: string | null;
  note: string | null;
  student_code: string;
  wallet_balance: string;
  class_count: number;
  created_at: string;
  updated_at: string;
  phone_number: string | null;
  address: string | null;
  avatar: string | null;
  parent_linked_at: string | null;
}
