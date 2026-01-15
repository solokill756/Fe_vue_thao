<template>
  <div
    class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6"
  >
    <div
      class="flex flex-col md:flex-row justify-between md:items-center gap-4 mb-4"
    >
      <div>
        <h2 class="text-2xl font-bold text-slate-800">
          {{ t('student.assignments.myAssignments') }}
        </h2>
        <p class="text-sm text-slate-500">
          {{ t('student.assignments.manageDeadlinesAndScores') }}
        </p>
      </div>
      <div class="flex gap-2">
        <!-- Class Filter -->
        <select
          v-model="localFilterSubject"
          @change="handleSubjectChange"
          class="px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 font-bold text-slate-600"
        >
          <option value="all">
            {{ t('student.assignments.allSubjects') }}
          </option>
          <option
            v-for="subject in uniqueSubjects"
            :key="subject"
            :value="subject"
          >
            {{ subject }}
          </option>
        </select>

        <!-- Search -->
        <div class="relative">
          <input
            v-model="localSearchTerm"
            @input="handleSearchChange"
            type="text"
            :placeholder="t('student.assignments.searchPlaceholder')"
            class="pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 text-sm w-48"
          />
          <i
            class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
          ></i>
        </div>
      </div>
    </div>

    <!-- Status Tabs -->
    <div class="flex gap-2 overflow-x-auto pb-2 md:pb-0">
      <button
        @click="handleStatusChange('all')"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
          localFilterStatus === 'all'
            ? 'bg-blue-600 text-white shadow-md'
            : 'bg-slate-100 text-slate-600 hover:bg-slate-200',
        ]"
      >
        {{ t('student.assignments.allStatus') }}
      </button>
      <button
        @click="handleStatusChange('no_submission')"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
          localFilterStatus === 'no_submission'
            ? 'bg-yellow-500 text-white shadow-md'
            : 'bg-white border border-slate-200 text-slate-600 hover:bg-yellow-50 hover:text-yellow-600',
        ]"
      >
        {{ t('student.assignments.noSubmission') }}
      </button>
      <button
        @click="handleStatusChange('submitted')"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
          localFilterStatus === 'submitted'
            ? 'bg-blue-500 text-white shadow-md'
            : 'bg-white border border-slate-200 text-slate-600 hover:bg-blue-50 hover:text-blue-600',
        ]"
      >
        {{ t('student.assignments.submitted') }}
      </button>
      <button
        @click="handleStatusChange('graded')"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap',
          localFilterStatus === 'graded'
            ? 'bg-green-600 text-white shadow-md'
            : 'bg-white border border-slate-200 text-slate-600 hover:bg-green-50 hover:text-green-600',
        ]"
      >
        {{ t('student.assignments.graded') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

interface Props {
  uniqueSubjects: string[];
  initialStatus?: string;
  initialSubject?: string;
  initialSearch?: string;
}

const props = withDefaults(defineProps<Props>(), {
  initialStatus: 'all',
  initialSubject: 'all',
  initialSearch: '',
});

const emit = defineEmits<{
  'update:status': [status: string];
  'update:subject': [subject: string];
  'update:search': [search: string];
}>();

const { t } = useI18n();

const localFilterStatus = ref(props.initialStatus);
const localFilterSubject = ref(props.initialSubject);
const localSearchTerm = ref(props.initialSearch);

watch(
  () => props.initialStatus,
  (newVal) => {
    localFilterStatus.value = newVal;
  }
);

watch(
  () => props.initialSubject,
  (newVal) => {
    localFilterSubject.value = newVal;
  }
);

watch(
  () => props.initialSearch,
  (newVal) => {
    localSearchTerm.value = newVal;
  }
);

const handleStatusChange = (status: string) => {
  localFilterStatus.value = status;
  emit('update:status', status);
};

const handleSubjectChange = () => {
  emit('update:subject', localFilterSubject.value);
};

const handleSearchChange = () => {
  emit('update:search', localSearchTerm.value);
};
</script>
