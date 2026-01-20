<template>
  <div class="h-full flex flex-col gap-4">
    <!-- Top Bar -->
    <div
      class="flex flex-col sm:flex-row justify-between items-center gap-4 bg-white p-4 rounded-xl shadow-sm border border-slate-200"
    >
      <div class="relative w-full sm:w-64">
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="$t('teacher.grading.searchPlaceholder')"
          class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 transition-all"
        />
        <i
          class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
        ></i>
      </div>
      <div class="flex gap-2">
        <select
          v-model="selectedClassId"
          class="px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm text-slate-600 focus:border-blue-500 outline-none"
        >
          <option value="">{{ $t('teacher.grading.selectClass') }}</option>
          <option v-for="cls in classes" :key="cls.id" :value="cls.id">
            {{ cls.name }}
          </option>
        </select>
        <button
          @click="$emit('create-assignment')"
          class="px-4 py-2 bg-blue-600 text-white text-xs font-bold rounded-lg shadow-sm flex items-center gap-2 hover:bg-blue-700 transition-colors"
        >
          <i class="fa-solid fa-plus"></i>
          {{ $t('teacher.grading.newAssignment') }}
        </button>
      </div>
    </div>

    <!-- Assignments Grid -->
    <div v-if="pending" class="flex items-center justify-center h-full">
      <CommonLoadingSpinner
        :full-screen="false"
        :text="$t('loading.assignments')"
      />
    </div>
    <div
      v-else-if="error"
      class="flex flex-col items-center justify-center h-full text-slate-400"
    >
      <i class="fa-solid fa-exclamation-triangle text-4xl mb-2"></i>
      <p>{{ $t('teacher.grading.errorLoading') }}</p>
      <button
        @click="$emit('refresh')"
        class="mt-4 px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg"
      >
        {{ $t('teacher.grading.retry') }}
      </button>
    </div>
    <div
      v-else-if="assignments.length === 0"
      class="flex flex-col items-center justify-center h-full text-slate-400"
    >
      <i class="fa-solid fa-clipboard-list text-4xl mb-2"></i>
      <p>{{ $t('teacher.grading.noAssignments') }}</p>
    </div>
    <div v-else class="flex flex-col gap-4">
      <div
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 overflow-y-auto custom-scroll pr-1 pb-2"
      >
        <div
          v-for="assign in assignments"
          :key="assign.id"
          class="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-lg hover:border-blue-300 transition-all group flex flex-col"
        >
          <div class="p-5 border-b border-slate-100">
            <div class="flex justify-between items-start mb-2">
              <span
                class="text-xs font-bold text-slate-400 uppercase tracking-wide"
              >
                {{ assign.class_name }}
              </span>
              <div class="flex items-center gap-2">
                <span
                  :class="[
                    'text-[10px] font-bold px-2 py-1 rounded-full uppercase',
                    assign.status === 'open'
                      ? 'bg-green-100 text-green-700'
                      : 'bg-slate-100 text-slate-500',
                  ]"
                >
                  {{
                    assign.status === 'open'
                      ? $t('teacher.grading.statusOpen')
                      : $t('teacher.grading.statusClosed')
                  }}
                </span>
                <div class="flex gap-1" @click.stop>
                  <button
                    @click.stop="$emit('editAssignment', assign)"
                    class="p-1.5 text-blue-600 hover:bg-blue-50 rounded transition-colors"
                    :title="$t('teacher.grading.edit') || 'Sửa'"
                  >
                    <i class="fa-solid fa-edit text-xs"></i>
                  </button>
                  <button
                    @click.stop="$emit('deleteAssignment', assign)"
                    class="p-1.5 text-red-600 hover:bg-red-50 rounded transition-colors"
                    :title="$t('teacher.grading.delete') || 'Xóa'"
                  >
                    <i class="fa-solid fa-trash text-xs"></i>
                  </button>
                </div>
              </div>
            </div>
            <div @click.stop="$emit('assignmentClick', assign.id)" class="cursor-pointer">
              <h3
                class="font-bold text-lg text-slate-800 group-hover:text-blue-600 transition-colors line-clamp-2"
              >
                {{ assign.title }}
              </h3>
              <p class="text-sm text-slate-500 mt-1">
                <i class="fa-regular fa-clock mr-1"></i>
                {{ $t('teacher.grading.dueDate') }}:
                {{ formatDate(assign.due_date) }}
              </p>
            </div>
          </div>
          <div class="p-5 flex-1 flex flex-col justify-end">
            <div class="flex justify-between text-sm mb-1.5">
              <span class="text-slate-500">
                {{ $t('teacher.grading.gradingProgress') }}
              </span>
              <span class="font-bold text-blue-600">
                {{ assign.graded_submissions_count || 0 }}/{{ assign.submissions_count || 0 }}
                {{ $t('teacher.grading.submissions') }}
              </span>
            </div>
            <div class="w-full bg-slate-100 rounded-full h-2 mb-4">
              <div
                class="bg-blue-500 h-2 rounded-full transition-all duration-500"
                :style="{
                  width:
                    assign.submissions_count && assign.submissions_count > 0
                      ? ((assign.graded_submissions_count || 0) / assign.submissions_count) *
                          100 +
                        '%'
                      : '0%',
                }"
              ></div>
            </div>
            <div
              class="flex items-center justify-between text-xs text-slate-400"
            >
              <span>
                {{ $t('teacher.grading.total') }}:
                {{ assign.total_students || 0 }}
                {{ $t('teacher.grading.students') }}
              </span>
              <span
                v-if="
                  assign.total_students &&
                  (assign.submissions_count || 0) < assign.total_students
                "
                class="text-orange-500 font-bold"
              >
                {{ assign.total_students - (assign.submissions_count || 0) }}
                {{ $t('teacher.grading.notSubmitted') }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <CommonPagination
        v-if="pagination.totalPages > 1 && pagination.totalItems > 0"
        :current-page="pagination.currentPage"
        :total-pages="pagination.totalPages"
        :items-per-page="pagination.itemsPerPage"
        :total-items="pagination.totalItems"
        @update:currentPage="$emit('pageChange', $event)"
        @update:itemsPerPage="$emit('itemsPerPageChange', $event)"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { TeacherAssignment } from '../../../composables/useTeacherGradingApi';
import { useTeacherGradingApi } from '../../../composables/useTeacherGradingApi';

const { formatDate } = useTeacherGradingApi();

defineProps<{
  assignments: TeacherAssignment[];
  pending: boolean;
  error: any;
  pagination: {
    currentPage: number;
    totalPages: number;
    itemsPerPage: number;
    totalItems: number;
  };
  classes: Array<{ id: number; name: string }>;
}>();

// Use defineModel for v-model binding - exactly like TeacherClassList.vue
const searchQuery = defineModel<string>('searchQuery', { required: true });
const selectedClassId = defineModel<number | string>('selectedClassId', {
  required: true,
});

defineEmits<{
  refresh: [];
  pageChange: [page: number];
  itemsPerPageChange: [itemsPerPage: number];
  assignmentClick: [assignmentId: number];
  'create-assignment': [];
  editAssignment: [assignment: TeacherAssignment];
  deleteAssignment: [assignment: TeacherAssignment];
}>();
</script>
