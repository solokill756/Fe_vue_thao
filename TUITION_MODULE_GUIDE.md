# Module Quản Lý Học Phí - Implementation Guide

## Overview
Module Quản Lý Học Phí (Tuition Management) cung cấp các chức năng quản lý hóa đơn, theo dõi nợ học phí, và xử lý thanh toán cho học sinh.

## Architecture

### Backend (Rails)

#### Models
- **TuitionInvoice** (`backend/app/models/tuition_invoice.rb`)
  - Lưu trữ thông tin hóa đơn học phí
  - Relationships: `belongs_to :student`, `has_many :transactions`
  - Statuses: pending, paid, overdue

#### Controllers
1. **TuitionInvoicesController** (`backend/app/controllers/api/v1/tuition_invoices_controller.rb`)
   - CRUD operations cho tuition invoices
   - Endpoints: GET, POST, PATCH, DELETE

2. **TuitionDashboardController** (`backend/app/controllers/api/v1/tuition_dashboard_controller.rb`)
   - GET `/api/v1/tuition-dashboard` - Lấy dashboard data
   - Returns: total_debt, next_due_date, wallet_balance, pending_invoices, history

3. **PaymentsController** (`backend/app/controllers/api/v1/payments_controller.rb`)
   - POST `/api/v1/payments/process` - Xử lý thanh toán
   - GET `/api/v1/payments/history` - Lịch sử giao dịch

#### Database
- Migration: `backend/db/migrate/20260113_create_tuition_invoices.rb`
  - Columns: student_id, title, description, amount, status, due_date, paid_date, invoice_code
  - Indices: on student_id + status, due_date, invoice_code

#### Serializers
- **TuitionInvoiceSerializer** - Format dữ liệu khi return API

### Frontend (Nuxt/Vue3)

#### Types
- `app/types/tuition.ts` - TypeScript interfaces
  - TuitionInvoice, TuitionData, PaymentRequest, PaymentResponse

#### Composables
- `app/composables/useTuitionApi.ts` - API calls
  - getTuitionDashboard()
  - getTuitionInvoices()
  - processPayment()
  - getPaymentHistory()

#### Components
1. **TuitionManager** (`app/components/student/TuitionManager.vue`)
   - Main component hiển thị dashboard học phí
   - Features:
     - Hiển thị tổng nợ, hạn thanh toán, ví học phí
     - Danh sách hóa đơn chờ thanh toán (với status indicator)
     - Lịch sử giao dịch
     - Payment modal với QR code
   - Tabs: pending, history

2. **TuitionAlert** (`app/components/student/TuitionAlert.vue`)
   - Alert card hiển thị trên dashboard
   - Props: totalPendingDebt, nextDueDate
   - Link tới trang quản lý học phí

#### Pages
- `app/pages/student/tuition.vue` - Trang quản lý học phí chính
  - Layout: student
  - Middleware: auth

#### Composables (Dashboard)
- `app/composables/useDashboard.ts` - Updated
  - Fetch tuition data on mount
  - Update wallet balance stats

## API Endpoints

### Tuition Invoices
```
GET    /api/v1/tuition_invoices           # List all invoices
GET    /api/v1/tuition_invoices/:id       # Get specific invoice
POST   /api/v1/tuition_invoices           # Create invoice
PATCH  /api/v1/tuition_invoices/:id       # Update invoice
DELETE /api/v1/tuition_invoices/:id       # Delete invoice
```

### Dashboard & Payments
```
GET  /api/v1/tuition-dashboard              # Get tuition dashboard data
POST /api/v1/payments/process               # Process payment
GET  /api/v1/payments/history               # Get payment history
```

## Data Flow

### Getting Tuition Data
1. Frontend: `TuitionManager.vue` mounts → calls `getTuitionDashboard()`
2. API: `TuitionDashboardController#show` fetches:
   - Pending invoices từ student
   - Calculated total_debt
   - Next due date
   - Wallet balance
   - Transaction history
3. Frontend: Updates component state, displays data

### Processing Payment
1. User clicks "Thanh toán" button → opens payment modal
2. User confirms payment → calls `processPayment(invoice_id, amount, method)`
3. API: `PaymentsController#process_payment`:
   - Creates Transaction record
   - Marks invoice as paid
   - Updates wallet balance
4. Frontend: Shows success message, reloads data

## Status Workflow

```
Invoice Created
     ↓
  pending (chờ thanh toán)
     ↓
  [Check if overdue] → overdue (quá hạn)
     ↓
  [User pays] → paid (đã thanh toán)
```

## Integration Points

### Routes (config/routes.rb)
```ruby
resources :tuition_invoices, only: [:index, :show, :create, :update, :destroy]
get 'tuition-dashboard', to: 'tuition_dashboard#show'
post 'payments/process', to: 'payments#process_payment'
get 'payments/history', to: 'payments#history'
```

### Sidebar Navigation
- Already integrated in `StudentSidebar.vue`
- Route: `/student/tuition`

### Dashboard
- TuitionAlert displays on dashboard
- Links to full tuition management page

## Localization
Strings are available in `locales/en.json` and `locales/vi.json`:
```json
{
  "student": {
    "menu": {
      "tuition": "Học phí"
    },
    "tuition": {
      "title": "Thông báo học phí",
      "important": "Quan trọng",
      "message": "Bạn có {...} nợ học phí...",
      "amountDue": "Tổng nợ",
      "payNow": "Thanh toán ngay"
    }
  }
}
```

## Setup Instructions

### Backend
1. Run migration:
```bash
rails db:migrate
```

2. Seed sample data (optional):
```bash
rails db:seed:tuition_invoices
```

3. Restart Rails server:
```bash
rails s
```

### Frontend
1. No additional setup needed
2. Components are auto-imported by Nuxt
3. Pages are auto-routed

## Testing

### Backend
Test endpoints using curl or Postman:
```bash
# Get tuition dashboard
curl -X GET http://localhost:3000/api/v1/tuition-dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"

# Process payment
curl -X POST http://localhost:3000/api/v1/payments/process \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "payment": {
      "invoice_id": "INV-202601-ABC123",
      "amount": 2000000,
      "method": "transfer"
    }
  }'
```

### Frontend
1. Navigate to `/student/tuition`
2. Check if data loads correctly
3. Test payment flow with modal

## Troubleshooting

### Data Not Loading
- Check authentication token
- Verify student profile exists
- Check API logs for errors

### Payment Failed
- Verify invoice exists and is pending
- Check wallet balance
- Verify payment method is valid

### Component Not Showing
- Check if Nuxt auto-import is working
- Verify component path is correct
- Clear Nuxt cache: `rm -rf .nuxt`

## Future Enhancements
1. Payment gateway integration (Stripe, VietPay)
2. Email notifications for overdue invoices
3. Automatic status updates
4. Payment reminders
5. Invoice PDF generation
6. Bulk payment options
7. Payment plans/installments
8. Discount/promotion codes
