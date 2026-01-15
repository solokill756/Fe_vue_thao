<template>
  <div
    v-if="assignment?.submission_status !== 'graded'"
    class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden"
  >
    <div
      class="bg-slate-50 p-4 border-b border-slate-200 flex justify-between items-center"
    >
      <h3 class="font-bold text-slate-800">
        {{ t('student.assignments.submissionArea') }}
      </h3>
      <span
        v-if="assignment?.submission_status === 'submitted'"
        class="text-xs font-bold text-blue-600 bg-blue-100 px-2 py-1 rounded"
      >
        {{ t('student.assignments.alreadySubmitted') }}
      </span>
    </div>

    <div class="p-6">
      <!-- Tabs -->
      <div class="flex gap-4 mb-4 border-b border-slate-100 pb-1">
        <button
          @click="submissionTab = 'file'"
          :class="[
            'text-sm font-bold pb-2 border-b-2 transition-colors',
            submissionTab === 'file'
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-slate-500',
          ]"
        >
          <i class="fa-solid fa-upload mr-1"></i>
          {{ t('student.assignments.fileUploadTab') }}
        </button>
        <button
          @click="submissionTab = 'text'"
          :class="[
            'text-sm font-bold pb-2 border-b-2 transition-colors',
            submissionTab === 'text'
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-slate-500',
          ]"
        >
          <i class="fa-solid fa-pen mr-1"></i>
          {{ t('student.assignments.textInputTab') }}
        </button>
      </div>

      <!-- File Upload -->
      <div v-if="submissionTab === 'file'" class="space-y-4">
        <div
          @dragover="handleDragOver"
          @drop="handleDrop"
          @click="fileInput?.click()"
          class="border-2 border-dashed border-slate-300 rounded-xl p-8 text-center bg-slate-50 hover:bg-blue-50 hover:border-blue-300 transition-colors cursor-pointer group"
        >
          <i
            class="fa-solid fa-cloud-arrow-up text-4xl text-slate-400 group-hover:text-blue-500 mb-3 transition-colors"
          ></i>
          <p class="text-sm font-bold text-slate-600">
            {{ t('student.assignments.dragDropFile') }}
            <span class="text-blue-600 underline">{{
              t('student.assignments.selectFile')
            }}</span>
          </p>
          <p class="text-xs text-slate-400 mt-2">
            {{ t('student.assignments.supportedFormats') }}
          </p>
          <input
            ref="fileInput"
            type="file"
            hidden
            @change="handleFileSelect"
            accept=".pdf,.docx,.jpg,.jpeg,.png,.txt"
          />
        </div>

        <!-- Selected File Display -->
        <div
          v-if="localSelectedFile"
          class="flex items-center gap-3 p-3 bg-blue-50 border border-blue-200 rounded-lg"
        >
          <i class="fa-solid fa-file text-blue-600 text-lg"></i>
          <div class="flex-1">
            <div class="text-sm font-bold text-blue-900">
              {{ localSelectedFile.name }}
            </div>
            <div class="text-xs text-blue-700">
              {{ formatFileSize(localSelectedFile.size) }}
            </div>
          </div>
          <button
            @click="handleRemoveFile"
            class="text-blue-600 hover:text-blue-800 transition"
            :title="t('common.delete')"
          >
            <i class="fa-solid fa-trash"></i>
          </button>
        </div>
      </div>

      <!-- Text Entry -->
      <div v-else>
        <textarea
          v-model="localSubmissionText"
          rows="6"
          class="w-full p-3 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-blue-500 resize-none"
          :placeholder="t('student.assignments.textSubmissionPlaceholder')"
        ></textarea>
      </div>

      <!-- Action Button -->
      <button
        @click="handleSubmit"
        :disabled="uploading"
        class="w-full mt-4 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-bold rounded-lg shadow-md transition-all flex items-center justify-center gap-2"
      >
        <i v-if="uploading" class="fa-solid fa-spinner fa-spin"></i>
        <span v-else>
          {{
            assignment?.submission_status === 'submitted'
              ? t('student.assignments.submitButtonResubmit')
              : t('student.assignments.submitButtonDefault')
          }}
        </span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import type { Assignment } from '@/types/assignment';

interface Props {
  assignment: Assignment | null;
  uploading?: boolean;
  submissionText?: string;
  selectedFile?: File | undefined;
}

const props = withDefaults(defineProps<Props>(), {
  uploading: false,
  submissionText: '',
  selectedFile: undefined,
});

const emit = defineEmits<{
  'update:submission-text': [text: string];
  'update:selected-file': [file: File | undefined];
  'submit': [];
}>();

const { t } = useI18n();

const submissionTab = ref<'file' | 'text'>('file');
const localSubmissionText = ref(props.submissionText);
const fileInput = ref<HTMLInputElement>();
const localSelectedFile = ref<File | undefined>(props.selectedFile);

watch(() => props.submissionText, (newVal) => {
  localSubmissionText.value = newVal;
});

watch(() => props.selectedFile, (newVal) => {
  localSelectedFile.value = newVal;
});

watch(localSubmissionText, (newVal) => {
  emit('update:submission-text', newVal);
});

watch(localSelectedFile, (newVal) => {
  emit('update:selected-file', newVal);
});

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files?.length) {
    localSelectedFile.value = target.files[0];
  }
};

const handleDragOver = (e: DragEvent) => {
  e.preventDefault();
  e.stopPropagation();
};

const handleDrop = (e: DragEvent) => {
  e.preventDefault();
  e.stopPropagation();
  if (e.dataTransfer?.files?.length) {
    localSelectedFile.value = e.dataTransfer.files[0];
  }
};

const handleRemoveFile = () => {
  localSelectedFile.value = undefined;
};

const formatFileSize = (bytes: number) => {
  const kb = bytes / 1024;
  return kb > 1024 ? `${(kb / 1024).toFixed(2)} MB` : `${kb.toFixed(2)} KB`;
};

const handleSubmit = () => {
  emit('submit');
};

// Expose values for parent component
defineExpose({
  submissionText: localSubmissionText,
  selectedFile: localSelectedFile,
  submissionTab,
});
</script>
