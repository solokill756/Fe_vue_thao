<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4"
    @click.self="close"
  >
    <div
      class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]"
    >
      <div
        class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50"
      >
        <h3 class="font-bold text-lg text-slate-800">
          {{ $t('teacher.grading.editModal.title') || 'Sửa bài tập' }}
        </h3>
        <button @click="close" class="text-slate-400 hover:text-slate-600">
          <i class="fa-solid fa-xmark text-xl"></i>
        </button>
      </div>
      <div class="p-6 space-y-4 overflow-y-auto">
        <!-- Class Selection -->
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.grading.editModal.class') || 'Lớp học' }}
            <span class="text-red-500">*</span>
          </label>
          <select
            v-model="formData.class_id"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            :class="{ 'border-red-300': errors.class_id }"
            :disabled="true"
          >
            <option :value="formData.class_id">{{ currentClassName }}</option>
          </select>
          <p v-if="errors.class_id" class="text-xs text-red-600 mt-1">
            {{ errors.class_id }}
          </p>
        </div>

        <!-- Title -->
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.grading.editModal.title') || 'Tiêu đề bài tập' }}
            <span class="text-red-500">*</span>
          </label>
          <input
            v-model="formData.title"
            type="text"
            :placeholder="$t('teacher.grading.editModal.titlePlaceholder') || 'Nhập tiêu đề bài tập'"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            :class="{ 'border-red-300': errors.title }"
          />
          <p v-if="errors.title" class="text-xs text-red-600 mt-1">
            {{ errors.title }}
          </p>
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.grading.editModal.description') || 'Mô tả' }}
          </label>
          <textarea
            v-model="formData.content"
            rows="5"
            :placeholder="$t('teacher.grading.editModal.descriptionPlaceholder') || 'Nhập mô tả bài tập (tùy chọn)'"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none resize-none"
          ></textarea>
        </div>

        <!-- Due Date -->
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.grading.editModal.dueDate') || 'Hạn nộp bài' }}
            <span class="text-red-500">*</span>
          </label>
          <input
            v-model="formData.due_date"
            type="datetime-local"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg text-sm focus:border-blue-500 outline-none"
            :class="{ 'border-red-300': errors.due_date }"
          />
          <p v-if="errors.due_date" class="text-xs text-red-600 mt-1">
            {{ errors.due_date }}
          </p>
        </div>

        <!-- Current File -->
        <div v-if="currentFile">
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.grading.editModal.currentFile') || 'File hiện tại' }}
          </label>
          <div class="flex items-center justify-between bg-slate-50 p-3 rounded-lg border border-slate-200">
            <div class="flex items-center gap-3">
              <i class="fa-regular fa-file text-2xl text-blue-600"></i>
              <div>
                <p class="text-sm font-bold text-slate-800">{{ currentFile }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- File Upload -->
        <div>
          <label class="block text-sm font-bold text-slate-700 mb-1">
            {{ $t('teacher.grading.editModal.attachment') || 'File đính kèm mới (tùy chọn)' }}
          </label>
          <div
            @dragover.prevent
            @drop.prevent="handleDrop"
            class="border-2 border-dashed border-slate-300 rounded-lg p-6 text-center hover:border-blue-500 transition-colors cursor-pointer"
            :class="{ 'border-blue-500 bg-blue-50': selectedFile }"
          >
            <input
              ref="fileInput"
              type="file"
              class="hidden"
              accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.txt"
              @change="handleFileSelect"
            />
            <div v-if="!selectedFile">
              <i class="fa-solid fa-cloud-arrow-up text-4xl text-slate-400 mb-2"></i>
              <p class="text-sm text-slate-600 font-bold mb-1">
                {{ $t('teacher.grading.editModal.dragDropFile') || 'Kéo thả file vào đây hoặc' }}
              </p>
              <button
                type="button"
                @click="fileInput?.click()"
                class="text-blue-600 hover:text-blue-700 text-sm font-bold underline"
              >
                {{ $t('teacher.grading.editModal.selectFile') || 'chọn file' }}
              </button>
              <p class="text-xs text-slate-500 mt-2">
                {{ $t('teacher.grading.editModal.supportedFormats') || 'Hỗ trợ: PDF, DOCX, JPG, PNG, TXT (Max 100MB)' }}
              </p>
            </div>
            <div v-else class="flex items-center justify-between bg-white p-3 rounded-lg border border-slate-200">
              <div class="flex items-center gap-3">
                <i class="fa-regular fa-file text-2xl text-blue-600"></i>
                <div>
                  <p class="text-sm font-bold text-slate-800">{{ selectedFile.name }}</p>
                  <p class="text-xs text-slate-500">{{ formatFileSize(selectedFile.size) }}</p>
                </div>
              </div>
              <button
                type="button"
                @click="removeFile"
                class="text-red-500 hover:text-red-700"
              >
                <i class="fa-solid fa-times"></i>
              </button>
            </div>
          </div>
          <p v-if="errors.file" class="text-xs text-red-600 mt-1">
            {{ errors.file }}
          </p>
        </div>
      </div>
      <div
        class="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3"
      >
        <button
          @click="close"
          :disabled="updating"
          class="px-4 py-2 text-slate-500 font-bold text-sm hover:bg-slate-200 rounded-lg transition-colors disabled:opacity-50"
        >
          {{ $t('teacher.grading.editModal.cancel') || 'Hủy' }}
        </button>
        <button
          @click="handleUpdateAssignment"
          :disabled="updating"
          class="px-4 py-2 bg-blue-600 text-white font-bold text-sm rounded-lg hover:bg-blue-700 shadow-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <i v-if="updating" class="fa-solid fa-spinner fa-spin"></i>
          <span>{{
            updating
              ? $t('teacher.grading.editModal.updating') || 'Đang cập nhật...'
              : $t('teacher.grading.editModal.update') || 'Cập nhật'
          }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue';
import { useAssignmentApi } from '../../../composables/useAssignmentApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import { getErrorMessage } from '../../../utils/errorHandler';
import type { TeacherAssignment } from '../../../composables/useTeacherGradingApi';

interface Props {
  isOpen: boolean;
  assignment: TeacherAssignment | null;
  classes: Array<{ id: number; name: string }>;
}

const props = defineProps<Props>();

const emit = defineEmits<{
  close: [];
  updated: [];
}>();

const { t } = useI18n();
const toast = useToast();
const { updateAssignment } = useAssignmentApi();

const formData = reactive({
  class_id: '',
  title: '',
  content: '',
  due_date: '',
});

const errors = reactive<{
  class_id?: string;
  title?: string;
  due_date?: string;
  file?: string;
}>({});

const updating = ref(false);
const selectedFile = ref<File | null>(null);
const fileInput = ref<HTMLInputElement | null>(null);
const currentFile = ref<string | null>(null);
const currentClassName = ref<string>('');

const validate = (): boolean => {
  errors.class_id = undefined;
  errors.title = undefined;
  errors.due_date = undefined;

  if (!formData.class_id) {
    errors.class_id = t('teacher.grading.editModal.errors.classRequired') || 'Vui lòng chọn lớp học';
  }

  if (!formData.title || formData.title.trim().length < 3) {
    errors.title = t('teacher.grading.editModal.errors.titleRequired') || 'Tiêu đề phải có ít nhất 3 ký tự';
  }

  if (!formData.due_date) {
    errors.due_date = t('teacher.grading.editModal.errors.dueDateRequired') || 'Vui lòng chọn hạn nộp bài';
  } else {
    const dueDate = new Date(formData.due_date);
    const now = new Date();
    if (dueDate <= now) {
      errors.due_date = t('teacher.grading.editModal.errors.dueDateFuture') || 'Hạn nộp bài phải là thời gian trong tương lai';
    }
  }

  return !errors.class_id && !errors.title && !errors.due_date;
};

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (file) {
    validateFile(file);
  }
};

const handleDrop = (event: DragEvent) => {
  const file = event.dataTransfer?.files?.[0];
  if (file) {
    validateFile(file);
  }
};

const validateFile = (file: File | null | undefined) => {
  if (!file) return;
  
  errors.file = undefined;
  
  // Check file size (100MB max)
  const maxSize = 100 * 1024 * 1024; // 100MB
  if (file.size > maxSize) {
    errors.file = t('teacher.grading.editModal.errors.fileTooLarge') || 'File quá lớn. Tối đa 100MB';
    return;
  }
  
  // Check file type
  const allowedTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/jpeg',
    'image/png',
    'text/plain'
  ];
  
  if (!allowedTypes.includes(file.type)) {
    errors.file = t('teacher.grading.editModal.errors.invalidFileType') || 'Định dạng file không được hỗ trợ';
    return;
  }
  
  selectedFile.value = file;
};

const removeFile = () => {
  selectedFile.value = null;
  if (fileInput.value) {
    fileInput.value.value = '';
  }
  errors.file = undefined;
};

const formatFileSize = (bytes: number): string => {
  const kb = bytes / 1024;
  return kb > 1024 ? `${(kb / 1024).toFixed(2)} MB` : `${kb.toFixed(2)} KB`;
};

const handleUpdateAssignment = async () => {
  if (!validate() || !props.assignment) {
    return;
  }

  updating.value = true;
  try {
    // Format due_date to ISO string
    const dueDateISO = new Date(formData.due_date).toISOString();

    // Create FormData if file exists, otherwise use JSON
    if (selectedFile.value) {
      const formDataToSend = new FormData();
      formDataToSend.append('assignment[title]', formData.title.trim());
      formDataToSend.append('assignment[content]', formData.content.trim() || '');
      formDataToSend.append('assignment[due_date]', dueDateISO);
      formDataToSend.append('file', selectedFile.value);

      await updateAssignment(props.assignment.id, formDataToSend);
    } else {
      await updateAssignment(props.assignment.id, {
        title: formData.title.trim(),
        content: formData.content.trim() || undefined,
        due_date: dueDateISO,
      });
    }

    toast.success(t('teacher.grading.editModal.success') || 'Cập nhật bài tập thành công!');
    
    emit('updated');
    close();
  } catch (error) {
    console.error('Error updating assignment:', error);
    const errorMsg = getErrorMessage(error, 'teacher.grading.editModal', t);
    toast.error(errorMsg || 'Có lỗi xảy ra khi cập nhật bài tập');
  } finally {
    updating.value = false;
  }
};

const close = () => {
  if (!updating.value) {
    emit('close');
  }
};

// Load assignment data when modal opens
watch(() => props.isOpen, (isOpen) => {
  if (isOpen && props.assignment) {
    formData.class_id = String(props.assignment.class_id);
    formData.title = props.assignment.title;
    formData.content = props.assignment.description || '';
    
    // Format due_date for datetime-local input
    if (props.assignment.due_date) {
      const date = new Date(props.assignment.due_date);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      formData.due_date = `${year}-${month}-${day}T${hours}:${minutes}`;
    }
    
    currentClassName.value = props.assignment.class_name;
    // Note: We don't have file info in TeacherAssignment type, so we'll leave it empty
    currentFile.value = null;
    selectedFile.value = null;
    if (fileInput.value) {
      fileInput.value.value = '';
    }
    errors.class_id = undefined;
    errors.title = undefined;
    errors.due_date = undefined;
    errors.file = undefined;
  } else if (!isOpen) {
    // Reset form when modal closes
    formData.class_id = '';
    formData.title = '';
    formData.content = '';
    formData.due_date = '';
    selectedFile.value = null;
    currentFile.value = null;
    currentClassName.value = '';
    if (fileInput.value) {
      fileInput.value.value = '';
    }
    errors.class_id = undefined;
    errors.title = undefined;
    errors.due_date = undefined;
    errors.file = undefined;
  }
});
</script>
