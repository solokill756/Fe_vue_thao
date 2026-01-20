Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/sign_up', to: 'authentications#sign_up'
      post 'auth/login', to: 'authentications#login'
      post 'auth/verify-otp', to: 'authentications#verify_otp'
      post 'auth/resend-otp', to: 'authentications#resend_otp'
      post 'auth/forget-password', to: 'authentications#forget_password'
      post 'auth/google-login', to: 'authentications#google_login'
      post 'auth/refresh-token', to: 'authentications#refresh_token'
      
      # Admin
      get 'admin/pending-users', to: 'admins#pending_users'
      post 'admin/approve-user', to: 'admins#approve_user'
      post 'admin/reject-user', to: 'admins#reject_user'
      
      # Admin User Management
      get 'admin/users', to: 'admins#users'
      get 'admin/users/:id', to: 'admins#show'
      post 'admin/users', to: 'admins#create'
      patch 'admin/users/:id', to: 'admins#update'
      delete 'admin/users/:id', to: 'admins#destroy'
      patch 'admin/users/:id/toggle-status', to: 'admins#toggle_status'
      # Users
      resources :users do
        patch 'profile', to: 'users#update_profile', on: :collection
        post 'upload_avatar', to: 'users#upload_avatar', on: :collection
      end
      resources :teachers do
        post 'upload_qr_code', to: 'teachers#upload_qr_code', on: :collection
      end
      resources :students do
        get 'profile', to: 'students#user_profile', on: :collection
        patch 'profile', to: 'students#change_profile', on: :collection
      end
      resources :parents do
        resources :parent_student_links, only: [:index, :create, :destroy]
      end

      # Packages
      resources :packages, only: [:index, :show]

      # Classes
      resources :classes do
        # Leave Requests (nested under classes)
        resources :leave_requests, only: [:index, :create]
        # Enrollments (nested under classes)
        resources :enrollments, only: [:index, :create, :destroy]
        
        # Attendance Sessions (nested under classes)
        resources :attendance_sessions do
          resources :attendance_records, only: [:index, :create, :update]
        end
        
        # Assignments (nested under classes)
        resources :assignments
        
        # Transactions (nested under classes)
        resources :transactions, only: [:index, :create]
       
        get :student_class , on: :collection, to: 'class_enrollment#student_classes'
        get 'student_class', to: 'class_enrollment#student_class', on: :member
        post 'enroll', to: 'class_enrollment#enroll_class', on: :member
        get 'subjects', to: 'classes#subjects', on: :collection
        delete 'quit', to: 'class_enrollment#quit_class', on: :member
        post 'payments/process', to: 'payments#process_payment', on: :collection
      end

      # Standalone resources
      resources :attendance_sessions, only: [:show]
      resources :attendance_records, only: [:show]
      resources :assignments do 
        get 'list-by-student', to: 'assignments#list_by_student', on: :collection
        get 'list-by-class', to: 'assignments#list_by_class', on: :collection
        get 'submissions', to: 'assignments#submissions', on: :member
      end
      resources :assignment_attachments, only: [:index, :show, :create, :destroy] do
        get 'file-url', to: 'assignment_attachments#file_url', on: :member
      end
      resources :submissions, only: [:show, :update , :create] do
        get 'list-by-student', to: 'submissions#list_by_student', on: :collection
        get 'file-url', to: 'submissions#file_url_submission', on: :member
      end
      resources :transactions, only: [:show, :index]
      
      # Leave Requests
      resources :leave_requests, only: [:show, :update, :destroy] do
        patch :approve, on: :member
        patch :reject, on: :member
      end

      # AI Conversations
      resources :ai_conversations do
        resources :ai_messages, only: [:index, :create]
      end

      # Tuition Management
      resources :tuition_invoices, only: [:index, :show, :create, :update, :destroy]
      get 'tuition-dashboard', to: 'tuition_dashboard#show'
      post 'payments/process', to: 'payments#process_payment'
      get 'payments/history', to: 'payments#history'
      patch 'transactions/:id/approve', to: 'transactions#approve'
      patch 'transactions/:id/reject', to: 'transactions#reject'
      
      # Student Dashboard
      get 'student-dashboard', to: 'student_dashboard#show'
      
      # Teacher Classes Management
      post 'teacher/classes', to: 'teacher_classes#create'
      get 'teacher/classes', to: 'teacher_classes#index'
      get 'teacher/classes/:id', to: 'teacher_classes#show'
      patch 'teacher/classes/:id', to: 'teacher_classes#update'
      delete 'teacher/classes/:id', to: 'teacher_classes#destroy'
      get 'teacher/classes/:id/pending_requests', to: 'teacher_classes#pending_requests'
      post 'teacher/classes/:id/enrollments/:enrollment_id/approve', to: 'teacher_classes#approve_enrollment'
      post 'teacher/classes/:id/enrollments/:enrollment_id/reject', to: 'teacher_classes#reject_enrollment'
      post 'teacher/classes/:id/leave_requests/:leave_request_id/approve', to: 'teacher_classes#approve_leave_request'
      post 'teacher/classes/:id/leave_requests/:leave_request_id/reject', to: 'teacher_classes#reject_leave_request'
      post 'teacher/classes/:id/students', to: 'teacher_classes#add_student'
      delete 'teacher/classes/:id/students/:student_id', to: 'teacher_classes#remove_student'
      get 'teacher/classes/:id/search_students', to: 'teacher_classes#search_students'
      get 'teacher/classes/:id/schedule', to: 'teacher_classes#schedule'
      post 'teacher/classes/:id/attendance_sessions', to: 'teacher_classes#create_attendance_session'
      patch 'teacher/classes/:id/attendance_sessions/:session_id', to: 'teacher_classes#update_attendance_session'
      delete 'teacher/classes/:id/attendance_sessions/:session_id', to: 'teacher_classes#delete_attendance_session'
      patch 'teacher/classes/:id/schedule', to: 'teacher_classes#update_schedule'
      get 'teacher/classes/finance/stats', to: 'teacher_classes#finance_stats'
      get 'teacher/classes/:id/finance', to: 'teacher_classes#finance'
      post 'teacher/classes/:id/enrollments/:enrollment_id/record_payment', to: 'teacher_classes#record_payment'
      post 'teacher/classes/:id/enrollments/:enrollment_id/send_reminder', to: 'teacher_classes#send_reminder'
      post 'teacher/classes/:id/send_all_reminders', to: 'teacher_classes#send_all_reminders'
      get 'teacher/classes/:id/enrollments/:enrollment_id/payment_history', to: 'teacher_classes#payment_history'
      get 'teacher/classes/:id/pending_transactions', to: 'teacher_classes#pending_transactions'
      post 'teacher/classes/:id/enrollments/:enrollment_id/create_invoice', to: 'teacher_classes#create_invoice'
    end
  end
end
