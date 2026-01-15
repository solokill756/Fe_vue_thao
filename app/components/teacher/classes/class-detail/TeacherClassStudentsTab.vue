<template>
  <div class="space-y-6">
    <!-- Pending Requests Section -->
    <div
      v-if="pendingEnrollments.length > 0 || pendingLeaveRequests.length > 0"
      class="space-y-4"
    >
      <h3 class="text-lg font-bold text-slate-800">
        {{ $t('teacher.classes.studentsTab.pendingRequests') }}
      </h3>

      <!-- Enrollment Requests -->
      <div
        v-if="pendingEnrollments.length > 0"
        class="bg-yellow-50 border border-yellow-200 rounded-lg p-4"
      >
        <h4 class="font-bold text-yellow-800 mb-3 flex items-center gap-2">
          <i class="fa-solid fa-user-plus"></i>
          {{ $t('teacher.classes.studentsTab.enrollmentRequests') }} ({{
            pendingEnrollments.length
          }})
        </h4>
        <div class="space-y-3">
          <div
            v-for="enrollment in pendingEnrollments"
            :key="enrollment.id"
            class="bg-white rounded-lg p-3 border border-yellow-200"
          >
            <div class="flex justify-between items-start">
              <div>
                <p class="font-medium text-slate-800">
                  {{ enrollment.student_name }}
                </p>
                <p class="text-sm text-slate-600">
                  {{ enrollment.student_phone }}
                </p>
                <p class="text-xs text-slate-500 mt-1">
                  {{ $t('teacher.classes.studentsTab.sentAt') }}:
                  {{ formatDate(enrollment.created_at) }}
                </p>
              </div>
              <div class="flex gap-2">
                <button
                  @click="handleApproveEnrollment(enrollment.id)"
                  :disabled="processingRequest === enrollment.id"
                  class="px-3 py-1.5 bg-green-600 hover:bg-green-700 text-white text-xs font-bold rounded-lg transition-colors disabled:opacity-50"
                >
                  <i class="fa-solid fa-check"></i>
                  {{ $t('teacher.classes.studentsTab.approve') }}
                </button>
                <button
                  @click="handleRejectEnrollment(enrollment.id)"
                  :disabled="processingRequest === enrollment.id"
                  class="px-3 py-1.5 bg-red-600 hover:bg-red-700 text-white text-xs font-bold rounded-lg transition-colors disabled:opacity-50"
                >
                  <i class="fa-solid fa-times"></i>
                  {{ $t('teacher.classes.studentsTab.reject') }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Leave Requests -->
      <div
        v-if="pendingLeaveRequests.length > 0"
        class="bg-orange-50 border border-orange-200 rounded-lg p-4"
      >
        <h4 class="font-bold text-orange-800 mb-3 flex items-center gap-2">
          <i class="fa-solid fa-calendar-times"></i>
          {{ $t('teacher.classes.studentsTab.leaveRequests') }} ({{
            pendingLeaveRequests.length
          }})
        </h4>
        <div class="space-y-3">
          <div
            v-for="request in pendingLeaveRequests"
            :key="request.id"
            class="bg-white rounded-lg p-3 border border-orange-200"
          >
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <p class="font-medium text-slate-800">
                  {{ request.student_name }}
                </p>
                <p class="text-sm text-slate-600">
                  {{ request.student_phone }}
                </p>
                <div class="mt-2 space-y-1">
                  <p class="text-xs text-slate-600">
                    <span class="font-medium"
                      >{{ $t('teacher.classes.studentsTab.type') }}:</span
                    >
                    {{
                      request.leave_type === 'temporary'
                        ? $t('teacher.classes.studentsTab.temporary')
                        : $t('teacher.classes.studentsTab.permanent')
                    }}
                  </p>
                  <p v-if="request.date" class="text-xs text-slate-600">
                    <span class="font-medium"
                      >{{ $t('teacher.classes.studentsTab.date') }}:</span
                    >
                    {{ formatDate(request.date) }}
                  </p>
                  <p class="text-xs text-slate-600">
                    <span class="font-medium"
                      >{{ $t('teacher.classes.studentsTab.reason') }}:</span
                    >
                    {{ request.reason }}
                  </p>
                  <p class="text-xs text-slate-500 mt-1">
                    {{ $t('teacher.classes.studentsTab.sentAt') }}:
                    {{ formatDate(request.created_at) }}
                  </p>
                </div>
              </div>
              <div class="flex gap-2 ml-4">
                <button
                  @click="handleApproveLeaveRequest(request.id)"
                  :disabled="processingRequest === request.id"
                  class="px-3 py-1.5 bg-green-600 hover:bg-green-700 text-white text-xs font-bold rounded-lg transition-colors disabled:opacity-50"
                >
                  <i class="fa-solid fa-check"></i>
                  {{ $t('teacher.classes.studentsTab.approve') }}
                </button>
                <button
                  @click="handleRejectLeaveRequest(request.id)"
                  :disabled="processingRequest === request.id"
                  class="px-3 py-1.5 bg-red-600 hover:bg-red-700 text-white text-xs font-bold rounded-lg transition-colors disabled:opacity-50"
                >
                  <i class="fa-solid fa-times"></i>
                  {{ $t('teacher.classes.studentsTab.reject') }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Students List -->
    <div class="space-y-4">
      <div class="flex justify-between items-center mb-2">
        <div class="relative w-64">
          <input
            type="text"
            :placeholder="$t('teacher.classes.studentsTab.searchStudent')"
            class="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500"
          />
          <i
            class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
          ></i>
        </div>
        <button
          @click="showAddStudentModal = true"
          class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-bold rounded-lg flex items-center gap-2 transition-colors"
        >
          <i class="fa-solid fa-user-plus"></i>
          {{ $t('teacher.classes.studentsTab.addStudent') }}
        </button>
      </div>
      <table class="w-full text-sm text-left border-collapse">
        <thead
          class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200"
        >
          <tr>
            <th class="px-4 py-3 rounded-tl-lg">
              {{ $t('teacher.classes.studentsTab.table.fullName') }}
            </th>
            <th class="px-4 py-3">
              {{ $t('teacher.classes.studentsTab.table.dob') }}
            </th>
            <th class="px-4 py-3">
              {{ $t('teacher.classes.studentsTab.table.contact') }}
            </th>
            <th class="px-4 py-3">
              {{ $t('teacher.classes.studentsTab.table.parent') }}
            </th>
            <th class="px-4 py-3 rounded-tr-lg text-right">
              {{ $t('teacher.classes.studentsTab.table.actions') }}
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr
            v-for="student in classStudents"
            :key="student.id"
            class="hover:bg-slate-50 group"
          >
            <td class="px-4 py-3 font-medium text-slate-800">
              {{ student.name }}
            </td>
            <td class="px-4 py-3 text-slate-600">{{ student.dob }}</td>
            <td class="px-4 py-3 text-slate-600">{{ student.phone }}</td>
            <td class="px-4 py-3 text-slate-600">{{ student.parent }}</td>
            <td class="px-4 py-3 text-right">
              <button
                @click="handleRemoveStudent(student.id)"
                class="text-red-500 hover:text-red-700 font-bold text-xs"
              >
                <i class="fa-solid fa-trash"></i>
                {{ $t('teacher.classes.studentsTab.table.remove') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add Student Modal -->
    <div
      v-if="showAddStudentModal"
      class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4"
      @click.self="showAddStudentModal = false"
    >
      <div
        class="bg-white rounded-xl shadow-lg max-w-2xl w-full p-6 space-y-4 max-h-[80vh] overflow-y-auto"
      >
        <div class="flex justify-between items-center">
          <h3 class="text-lg font-bold text-slate-800">
            Thêm học sinh vào lớp
          </h3>
          <button
            @click="showAddStudentModal = false"
            class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-600 transition-colors"
          >
            <i class="fa-solid fa-times"></i>
          </button>
        </div>

        <div class="relative">
          <input
            v-model="studentSearchQuery"
            type="text"
            :placeholder="
              $t('teacher.classes.studentsTab.modal.searchPlaceholder')
            "
            class="w-full pl-10 pr-4 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500"
            @input="handleSearchStudents"
          />
          <i
            class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
          ></i>
        </div>

        <div v-if="searchingStudents" class="text-center py-8">
          <div
            class="inline-block animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"
          ></div>
          <p class="text-sm text-slate-500 mt-2">Đang tìm kiếm...</p>
        </div>

        <div
          v-else-if="searchResults.length > 0"
          class="space-y-2 max-h-64 overflow-y-auto"
        >
          <div
            v-for="student in searchResults"
            :key="student.id"
            class="flex justify-between items-center p-3 border border-slate-200 rounded-lg hover:bg-slate-50"
          >
            <div>
              <p class="font-medium text-slate-800">{{ student.name }}</p>
              <p class="text-xs text-slate-600">{{ student.email }}</p>
              <p class="text-xs text-slate-500">
                {{ $t('teacher.classes.studentsTab.modal.code') }}:
                {{ student.student_code }} • {{ student.phone }}
              </p>
            </div>
            <button
              @click="handleAddStudent(student.id)"
              :disabled="addingStudent === student.id"
              class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-lg transition-colors disabled:opacity-50"
            >
              <i class="fa-solid fa-plus"></i> Thêm
            </button>
          </div>
        </div>

        <div
          v-else-if="studentSearchQuery && !searchingStudents"
          class="text-center py-8 text-slate-500 text-sm"
        >
          {{ $t('teacher.classes.studentsTab.modal.noResults') }}
        </div>

        <div v-else class="text-center py-8 text-slate-500 text-sm">
          {{ $t('teacher.classes.studentsTab.modal.enterKeyword') }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { TeacherClassDetail } from '../../../../composables/useTeacherClassApi';
import { useTeacherClassApi } from '../../../../composables/useTeacherClassApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

const props = defineProps<{
  classDetail: TeacherClassDetail;
  pendingEnrollments: Array<{
    id: number;
    student_id: number;
    student_name: string;
    student_phone: string;
    created_at: string;
  }>;
  pendingLeaveRequests: Array<{
    id: number;
    student_id: number;
    student_name: string;
    student_phone: string;
    leave_type: string;
    date: string | null;
    reason: string;
    created_at: string;
  }>;
}>();

const emit = defineEmits<{
  refresh: [];
  refreshPendingRequests: [];
}>();

const toast = useToast();
const {
  approveEnrollment,
  rejectEnrollment,
  approveLeaveRequest,
  rejectLeaveRequest,
  addStudent,
  removeStudent,
  searchStudents,
} = useTeacherClassApi();

const classStudents = computed(() => {
  return props.classDetail?.students_list || [];
});

const processingRequest = ref<number | null>(null);
const showAddStudentModal = ref(false);
const studentSearchQuery = ref('');
const searchResults = ref<
  Array<{
    id: number;
    name: string;
    email: string;
    student_code: string;
    phone: string;
  }>
>([]);
const searchingStudents = ref(false);
const addingStudent = ref<number | null>(null);
let searchTimeout: NodeJS.Timeout;

const formatDate = (dateString: string) => {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  return date.toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
};

const handleApproveEnrollment = async (enrollmentId: number) => {
  try {
    processingRequest.value = enrollmentId;
    await approveEnrollment(props.classDetail.id, enrollmentId);
    toast.success(
      t('teacher.classes.studentsTab.messages.approveEnrollmentSuccess')
    );
    emit('refreshPendingRequests');
    emit('refresh');
  } catch (error: any) {
    toast.error(
      error?.data?.message ||
        t('teacher.classes.studentsTab.messages.approveError')
    );
  } finally {
    processingRequest.value = null;
  }
};

const handleRejectEnrollment = async (enrollmentId: number) => {
  if (!confirm(t('teacher.classes.studentsTab.modal.confirmReject'))) return;

  try {
    processingRequest.value = enrollmentId;
    await rejectEnrollment(props.classDetail.id, enrollmentId);
    toast.success(
      t('teacher.classes.studentsTab.messages.rejectEnrollmentSuccess')
    );
    emit('refreshPendingRequests');
  } catch (error: any) {
    toast.error(
      error?.data?.message ||
        t('teacher.classes.studentsTab.messages.rejectError')
    );
  } finally {
    processingRequest.value = null;
  }
};

const handleApproveLeaveRequest = async (leaveRequestId: number) => {
  try {
    processingRequest.value = leaveRequestId;
    await approveLeaveRequest(props.classDetail.id, leaveRequestId);
    toast.success(
      t('teacher.classes.studentsTab.messages.approveLeaveSuccess')
    );
    emit('refreshPendingRequests');
    emit('refresh');
  } catch (error: any) {
    toast.error(
      error?.data?.message ||
        t('teacher.classes.studentsTab.messages.approveError')
    );
  } finally {
    processingRequest.value = null;
  }
};

const handleRejectLeaveRequest = async (leaveRequestId: number) => {
  if (!confirm(t('teacher.classes.studentsTab.modal.confirmReject'))) return;

  try {
    processingRequest.value = leaveRequestId;
    await rejectLeaveRequest(props.classDetail.id, leaveRequestId);
    toast.success(t('teacher.classes.studentsTab.messages.rejectLeaveSuccess'));
    emit('refreshPendingRequests');
  } catch (error: any) {
    toast.error(
      error?.data?.message ||
        t('teacher.classes.studentsTab.messages.rejectError')
    );
  } finally {
    processingRequest.value = null;
  }
};

const handleSearchStudents = () => {
  clearTimeout(searchTimeout);
  if (!studentSearchQuery.value.trim()) {
    searchResults.value = [];
    return;
  }

  searchTimeout = setTimeout(async () => {
    try {
      searchingStudents.value = true;
      const response = await searchStudents(
        props.classDetail.id,
        studentSearchQuery.value.trim()
      );
      if (response.data) {
        const enrolledStudentIds = classStudents.value.map((s) => s.id);
        searchResults.value = response.data.students.filter(
          (s) => !enrolledStudentIds.includes(s.id)
        );
      }
    } catch (error) {
      console.error('Error searching students:', error);
      searchResults.value = [];
    } finally {
      searchingStudents.value = false;
    }
  }, 500);
};

const handleAddStudent = async (studentId: number) => {
  try {
    addingStudent.value = studentId;
    await addStudent(props.classDetail.id, studentId);
    toast.success(t('teacher.classes.studentsTab.messages.addStudentSuccess'));
    showAddStudentModal.value = false;
    studentSearchQuery.value = '';
    searchResults.value = [];
    emit('refresh');
  } catch (error: any) {
    toast.error(
      error?.data?.message || t('teacher.classes.studentsTab.messages.addError')
    );
  } finally {
    addingStudent.value = null;
  }
};

const handleRemoveStudent = async (studentId: number) => {
  if (!confirm(t('teacher.classes.studentsTab.modal.confirmRemove'))) return;

  try {
    await removeStudent(props.classDetail.id, studentId);
    toast.success(
      t('teacher.classes.studentsTab.messages.removeStudentSuccess')
    );
    emit('refresh');
  } catch (error: any) {
    toast.error(
      error?.data?.message ||
        t('teacher.classes.studentsTab.messages.removeError')
    );
  }
};

// Reset search when modal closes
watch(showAddStudentModal, (isOpen) => {
  if (!isOpen) {
    studentSearchQuery.value = '';
    searchResults.value = [];
  }
});
</script>
