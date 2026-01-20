<template>
  <div class="flex flex-col gap-4 h-full">
    <!-- Tools Bar -->
    <div
      class="flex flex-col sm:flex-row justify-between items-center gap-4 bg-white p-4 rounded-xl shadow-sm border border-slate-200"
    >
      <div class="relative w-full sm:w-64">
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="$t('teacher.classes.searchPlaceholder')"
          class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 transition-all"
        />
        <i
          class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
        ></i>
      </div>
      <div class="flex gap-2">
        <select
          v-model="statusFilter"
          class="px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm text-slate-600 focus:border-blue-500 outline-none"
        >
          <option value="">{{ $t('teacher.classes.allStatus') }}</option>
          <option value="active">
            {{ $t('teacher.classes.list.active') }}
          </option>
          <option value="ended">{{ $t('teacher.classes.ended') }}</option>
        </select>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="pending" class="flex items-center justify-center py-12">
      <div class="text-center">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-2"
        ></div>
        <p class="text-sm text-slate-500">
          {{ $t('teacher.classes.list.loading') }}
        </p>
      </div>
    </div>

    <!-- Error State -->
    <div
      v-else-if="error"
      class="bg-red-50 border border-red-200 rounded-lg p-4 text-center"
    >
      <p class="text-red-600 text-sm">
        {{ $t('teacher.classes.list.error') }}
      </p>
      <button
        @click="$emit('refresh')"
        class="mt-2 px-4 py-2 bg-red-600 text-white text-sm rounded-lg hover:bg-red-700"
      >
        {{ $t('teacher.classes.list.retry') }}
      </button>
    </div>

    <!-- Classes Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="cls in filteredClasses"
        :key="cls.id"
        class="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-lg transition-all group overflow-hidden flex flex-col"
      >
        <!-- Cover Image -->
        <div
          v-if="cls.cover_image"
          class="relative w-full h-40 overflow-hidden bg-slate-100"
        >
          <img
            :src="cls.cover_image"
            :alt="cls.name"
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            @error="handleImageError($event)"
          />
          <div class="absolute top-3 right-3 flex items-center gap-2">
            <span
              v-if="cls.status === 'active'"
              class="px-2 py-1 bg-green-500 text-white text-xs font-bold rounded-full shadow-sm"
            >
              {{ $t('teacher.classes.list.active') }}
            </span>
          </div>
        </div>
        <div
          v-else
          class="relative w-full h-40 overflow-hidden bg-gradient-to-br from-blue-100 to-slate-100 flex items-center justify-center"
        >
          <div class="text-center">
            <i
              class="fa-solid fa-graduation-cap text-4xl text-slate-300 mb-2"
            ></i>
            <p class="text-xs text-slate-400 font-medium">{{ cls.subject }}</p>
          </div>
          <div class="absolute top-3 right-3 flex items-center gap-2">
            <span
              v-if="cls.status === 'active'"
              class="px-2 py-1 bg-green-500 text-white text-xs font-bold rounded-full shadow-sm"
            >
              {{ $t('teacher.classes.list.active') }}
            </span>
          </div>
        </div>

        <div
          class="p-5 border-b border-slate-100 flex justify-between items-start bg-white"
        >
          <div class="flex-1">
            <div class="flex items-center gap-2 mb-1">
              <h3
                class="font-bold text-lg text-slate-800 group-hover:text-blue-600 cursor-pointer transition-colors"
                @click="navigateTo(`/teacher/classes/${cls.id}`)"
              >
                {{ cls.name }}
              </h3>
            </div>
            <p
              class="text-xs text-slate-500 font-medium uppercase tracking-wide"
            >
              {{ cls.code }}
            </p>
          </div>
          <div
            class="w-10 h-10 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center font-bold text-lg ml-3"
          >
            {{ cls.grade }}
          </div>
        </div>

        <div class="p-5 flex-1 space-y-3">
          <div class="flex items-center justify-between text-sm">
            <span class="text-slate-500"
              ><i class="fa-regular fa-calendar mr-2 w-4"></i
              >{{ $t('teacher.classes.schedule') }}:</span
            >
            <span class="font-medium text-slate-700">{{ formatScheduleObject(cls.schedule) }}</span>
          </div>
          <div class="flex items-center justify-between text-sm">
            <span class="text-slate-500"
              ><i class="fa-solid fa-location-dot mr-2 w-4"></i
              >{{ $t('teacher.classes.room') }}:</span
            >
            <span class="font-medium text-slate-700">{{ cls.room }}</span>
          </div>
          <div class="flex items-center justify-between text-sm">
            <span class="text-slate-500"
              ><i class="fa-solid fa-users mr-2 w-4"></i
              >{{ $t('teacher.classes.students') }}:</span
            >
            <span class="font-medium text-slate-700"
              >{{ cls.students }}/{{ cls.maxStudents }}</span
            >
          </div>
          <div class="mt-2 w-full bg-slate-100 rounded-full h-1.5">
            <div
              class="bg-blue-500 h-1.5 rounded-full"
              :style="{
                width: (cls.students / cls.maxStudents) * 100 + '%',
              }"
            ></div>
          </div>
        </div>

        <div
          class="p-4 bg-slate-50 border-t border-slate-100 grid grid-cols-2 gap-3"
        >
          <button
            @click="navigateTo(`/teacher/classes/${cls.id}?tab=settings`)"
            class="px-3 py-2 bg-white border border-slate-200 text-slate-600 text-xs font-bold rounded-lg hover:text-blue-600 hover:border-blue-200 transition-colors flex items-center justify-center gap-2"
          >
            <i class="fa-solid fa-pen"></i>
            {{ $t('teacher.classes.list.edit') }}
          </button>
          <button
            @click="navigateTo(`/teacher/classes/${cls.id}?tab=students`)"
            class="px-3 py-2 bg-white border border-slate-200 text-slate-600 text-xs font-bold rounded-lg hover:text-blue-600 hover:border-blue-200 transition-colors flex items-center justify-center gap-2"
          >
            <i class="fa-solid fa-list-check"></i>
            {{ $t('teacher.classes.studentList') }}
          </button>
        </div>
      </div>

      <!-- Add New Class Card -->
      <div
        @click="$emit('create-class')"
        class="border-2 border-dashed border-slate-300 rounded-xl flex flex-col items-center justify-center p-6 text-slate-400 hover:border-blue-400 hover:text-blue-500 hover:bg-blue-50 cursor-pointer transition-all min-h-[250px]"
      >
        <div
          class="w-14 h-14 rounded-full bg-slate-100 flex items-center justify-center mb-3 group-hover:bg-white transition-colors"
        >
          <i class="fa-solid fa-plus text-2xl"></i>
        </div>
        <span class="font-bold text-sm">{{
          $t('teacher.classes.createNewClass')
        }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { TeacherClass } from '../../../composables/useTeacherClassApi';
import { formatScheduleObject } from '../../../utils/scheduleFormatter';

const props = defineProps<{
  classes: TeacherClass[];
  pending: boolean;
  error: any;
}>();

const searchQuery = defineModel<string>('searchQuery', { required: true });
const statusFilter = defineModel<string>('statusFilter', { required: true });

defineEmits<{
  'create-class': [];
  refresh: [];
}>();

const filteredClasses = computed(() => {
  let filtered = props.classes;

  if (searchQuery.value) {
    filtered = filtered.filter((c) =>
      c.name.toLowerCase().includes(searchQuery.value?.toLowerCase() || '')
    );
  }

  if (statusFilter.value) {
    filtered = filtered.filter((c) => c.status === statusFilter.value);
  }

  return filtered;
});

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement;
  img.style.display = 'none';
};
</script>
