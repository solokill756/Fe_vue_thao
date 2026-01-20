<template>
  <div class="max-w-2xl mx-auto space-y-6">
    <div class="bg-white border border-slate-200 rounded-xl p-6 space-y-6">
      <h3 class="text-xl font-bold text-slate-800">{{ $t('teacher.classes.settingsTab.classInfo') }}</h3>

      <div class="grid grid-cols-2 gap-6">
        <div class="space-y-1">
          <label class="text-sm font-bold text-slate-700"
            >{{ $t('teacher.classes.settingsTab.className') }} <span class="text-red-500">{{ $t('teacher.classes.settingsTab.required') }}</span></label
          >
          <input
            v-model="settingsForm.name"
            type="text"
            :placeholder="$t('teacher.classes.settingsTab.classNamePlaceholder')"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:border-blue-500 outline-none"
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-bold text-slate-700"
            >{{ $t('teacher.classes.settingsTab.subject') }} <span class="text-red-500">{{ $t('teacher.classes.settingsTab.required') }}</span></label
          >
          <input
            v-model="settingsForm.subject"
            type="text"
            :placeholder="$t('teacher.classes.settingsTab.subjectPlaceholder')"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:border-blue-500 outline-none"
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-bold text-slate-700">{{ $t('teacher.classes.settingsTab.gradeLevel') }}</label>
          <input
            v-model="settingsForm.grade_level"
            type="text"
            :placeholder="$t('teacher.classes.settingsTab.gradeLevelPlaceholder')"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:border-blue-500 outline-none"
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-bold text-slate-700"
            >{{ $t('teacher.classes.settingsTab.monthlyTuitionFee') }}</label
          >
          <input
            v-model.number="settingsForm.monthly_tuition_fee"
            type="number"
            min="0"
            :placeholder="$t('teacher.classes.settingsTab.feePlaceholder')"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:border-blue-500 outline-none"
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-bold text-slate-700">{{ $t('teacher.classes.settingsTab.status') }}</label>
          <select
            v-model="settingsForm.status"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:border-blue-500 outline-none"
          >
            <option value="active">{{ $t('teacher.classes.settingsTab.statusActive') }}</option>
            <option value="paused">{{ $t('teacher.classes.settingsTab.statusPaused') }}</option>
          </select>
        </div>
        <div class="space-y-1">
          <label class="text-sm font-bold text-slate-700">{{ $t('teacher.classes.settingsTab.classCode') }}</label>
          <input
            :value="classDetail.code"
            disabled
            class="w-full px-4 py-2 border border-slate-200 rounded-lg bg-slate-100 text-slate-500 cursor-not-allowed"
          />
        </div>
        <div class="col-span-2 space-y-1">
          <label class="text-sm font-bold text-slate-700"
            >{{ $t('teacher.classes.settingsTab.description') }}</label
          >
          <textarea
            v-model="settingsForm.description"
            rows="4"
            :placeholder="$t('teacher.classes.settingsTab.descriptionPlaceholder')"
            class="w-full px-4 py-2 border border-slate-200 rounded-lg focus:border-blue-500 outline-none resize-none"
          ></textarea>
        </div>
        <div class="col-span-2 space-y-1">
          <label class="text-sm font-bold text-slate-700">{{ $t('teacher.classes.settingsTab.coverImage') }}</label>

          <!-- Image Preview -->
          <div
            v-if="coverImagePreview || settingsForm.cover_image"
            class="mb-3"
          >
            <img
              :src="coverImagePreview || settingsForm.cover_image"
              alt="Cover preview"
              class="w-full h-48 object-cover rounded-lg border border-slate-200"
            />
          </div>

          <!-- File Input -->
          <div class="flex items-center gap-3">
            <label
              class="flex-1 px-4 py-2 border border-slate-200 rounded-lg cursor-pointer hover:bg-slate-50 transition-colors flex items-center justify-center gap-2 text-slate-700 font-medium"
            >
              <i class="fa-solid fa-upload"></i>
              <span>{{
                coverImageFile ? $t('teacher.classes.settingsTab.changeImage') : $t('teacher.classes.settingsTab.selectImage')
              }}</span>
              <input
                type="file"
                accept="image/jpeg,image/jpg,image/png,image/webp"
                @change="handleCoverImageChange"
                class="hidden"
              />
            </label>
            <button
              v-if="coverImagePreview || settingsForm.cover_image"
              @click="removeCoverImage"
              type="button"
              class="px-4 py-2 border border-red-200 text-red-600 rounded-lg hover:bg-red-50 transition-colors"
            >
              <i class="fa-solid fa-trash"></i> {{ $t('teacher.classes.settingsTab.remove') }}
            </button>
          </div>
          <p class="text-xs text-slate-500 mt-1">
            {{ $t('teacher.classes.settingsTab.imageFormat') }}
          </p>
        </div>
      </div>

      <div class="flex justify-end pt-4 border-t border-slate-200">
        <button
          @click="handleSaveSettings"
          :disabled="savingSettings"
          class="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg shadow-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
              <i v-if="savingSettings" class="fa-solid fa-spinner fa-spin"></i>
              <span>{{ savingSettings ? $t('teacher.classes.settingsTab.saving') : $t('teacher.classes.settingsTab.saveChanges') }}</span>
        </button>
      </div>
    </div>

    <div class="bg-red-50 border border-red-100 rounded-xl p-5">
      <h4 class="font-bold text-red-700 mb-2 flex items-center gap-2">
        <i class="fa-solid fa-triangle-exclamation"></i>
        {{ $t('teacher.classes.settingsTab.dangerZone') }}
      </h4>
      <p class="text-sm text-red-600 mb-4">
        {{ $t('teacher.classes.settingsTab.dangerDescription') }}
      </p>
      <button
        @click="showDeleteConfirm = true"
        :disabled="deletingClass"
        class="px-4 py-2 border border-red-200 text-red-600 font-bold text-sm rounded-lg hover:bg-red-100 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
      >
        <i v-if="deletingClass" class="fa-solid fa-spinner fa-spin"></i>
        <i v-else class="fa-solid fa-trash"></i>
        <span>{{ deletingClass ? $t('teacher.classes.settingsTab.deleting') : $t('teacher.classes.settingsTab.deleteClass') }}</span>
      </button>
    </div>

    <!-- Delete Confirmation Modal -->
    <div
      v-if="showDeleteConfirm"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="showDeleteConfirm = false"
    >
      <div
        class="bg-white rounded-xl shadow-xl p-6 w-full max-w-md mx-4"
        @click.stop
      >
        <div class="flex items-center gap-3 mb-4">
          <div
            class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center"
          >
            <i
              class="fa-solid fa-triangle-exclamation text-red-600 text-xl"
            ></i>
          </div>
          <div>
            <h3 class="text-xl font-bold text-slate-800">
              {{ $t('teacher.classes.settingsTab.deleteConfirm.title') }}
            </h3>
            <p class="text-sm text-slate-600">
              {{ $t('teacher.classes.settingsTab.deleteConfirm.description') }}
            </p>
          </div>
        </div>

        <div class="bg-red-50 border border-red-200 rounded-lg p-4 mb-4">
          <p class="text-sm text-red-800 font-medium mb-2">
            {{ $t('teacher.classes.settingsTab.deleteConfirm.confirmText') }}
          </p>
          <p class="text-sm font-bold text-red-900">{{ classDetail.name }}</p>
        </div>

        <p class="text-sm text-slate-600 mb-6">
          {{ $t('teacher.classes.settingsTab.deleteConfirm.warning') }}
        </p>
        <ul
          class="text-sm text-slate-600 mb-6 space-y-1 list-disc list-inside"
        >
          <li>{{ $t('teacher.classes.settingsTab.deleteConfirm.items.students') }}</li>
          <li>{{ $t('teacher.classes.settingsTab.deleteConfirm.items.assignments') }}</li>
          <li>{{ $t('teacher.classes.settingsTab.deleteConfirm.items.attendance') }}</li>
          <li>{{ $t('teacher.classes.settingsTab.deleteConfirm.items.invoices') }}</li>
          <li>{{ $t('teacher.classes.settingsTab.deleteConfirm.items.other') }}</li>
        </ul>

        <div class="flex gap-3">
          <button
            @click="showDeleteConfirm = false"
            :disabled="deletingClass"
            class="flex-1 px-4 py-2 border border-slate-200 text-slate-700 font-bold rounded-lg hover:bg-slate-50 transition-colors disabled:opacity-50"
          >
            {{ $t('teacher.classes.settingsTab.deleteConfirm.cancel') }}
          </button>
          <button
            @click="handleDeleteClass"
            :disabled="deletingClass"
            class="flex-1 px-4 py-2 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <i v-if="deletingClass" class="fa-solid fa-spinner fa-spin"></i>
            <span>{{ deletingClass ? $t('teacher.classes.settingsTab.deleting') : $t('teacher.classes.settingsTab.deleteConfirm.delete') }}</span>
          </button>
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
}>();

const emit = defineEmits<{
  refresh: [];
}>();

const toast = useToast();
const { updateClass, deleteClass } = useTeacherClassApi();

const settingsForm = ref({
  name: '',
  subject: '',
  grade_level: '',
  description: '',
  monthly_tuition_fee: 0,
  status: 'active',
  cover_image: '',
});
const coverImageFile = ref<File | null>(null);
const coverImagePreview = ref<string | null>(null);
const savingSettings = ref(false);
const showDeleteConfirm = ref(false);
const deletingClass = ref(false);

watch(
  () => props.classDetail,
  (newDetail) => {
    if (newDetail) {
      settingsForm.value = {
        name: newDetail.name || '',
        subject: newDetail.subject || '',
        grade_level: (newDetail as any).grade_level || newDetail.grade || '',
        description: newDetail.description || '',
        monthly_tuition_fee: (newDetail as any).monthly_tuition_fee || 0,
        status: newDetail.status || 'active',
        cover_image: (newDetail as any).cover_image || '',
      };

      coverImageFile.value = null;
      coverImagePreview.value = null;
    }
  },
  { immediate: true }
);

const handleCoverImageChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];

  if (!file) return;

  // Validate file type
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  if (!allowedTypes.includes(file.type)) {
    toast.error(t('teacher.classes.settingsTab.messages.invalidImageFormat'));
    return;
  }

  // Validate file size (5MB)
  const maxSize = 5 * 1024 * 1024; // 5MB in bytes
  if (file.size > maxSize) {
    toast.error(t('teacher.classes.settingsTab.messages.imageTooLarge'));
    return;
  }

  coverImageFile.value = file;

  // Create preview
  const reader = new FileReader();
  reader.onload = (e) => {
    coverImagePreview.value = e.target?.result as string;
  };
  reader.readAsDataURL(file);
};

const removeCoverImage = () => {
  coverImageFile.value = null;
  coverImagePreview.value = null;
  settingsForm.value.cover_image = '';
};

const handleSaveSettings = async () => {
  if (!settingsForm.value.name || !settingsForm.value.subject) {
    toast.error(t('teacher.classes.settingsTab.messages.validationError'));
    return;
  }

  try {
    savingSettings.value = true;

    // Prepare form data for file upload
    const formData = new FormData();
    formData.append('name', settingsForm.value.name);
    formData.append('subject', settingsForm.value.subject);
    if (settingsForm.value.grade_level) {
      formData.append('grade_level', settingsForm.value.grade_level);
    }
    if (settingsForm.value.description) {
      formData.append('description', settingsForm.value.description);
    }
    formData.append(
      'monthly_tuition_fee',
      settingsForm.value.monthly_tuition_fee.toString()
    );
    formData.append('status', settingsForm.value.status);

    // Add cover image file if selected
    if (coverImageFile.value) {
      formData.append('cover_image_file', coverImageFile.value);
    } else if (settingsForm.value.cover_image) {
      // If no new file but has existing URL, keep the URL
      formData.append('cover_image', settingsForm.value.cover_image);
    }

    const response = await updateClass(props.classDetail.id, formData);

    if (response.data) {
      toast.success(t('teacher.classes.settingsTab.messages.updateSuccess'));
      // Clear file and preview after successful save
      coverImageFile.value = null;
      coverImagePreview.value = null;
      // Refresh class detail
      emit('refresh');
    }
  } catch (error: any) {
    toast.error(error?.data?.message || t('teacher.classes.settingsTab.messages.updateError'));
  } finally {
    savingSettings.value = false;
  }
};

const handleDeleteClass = async () => {
  try {
    deletingClass.value = true;
    await deleteClass(props.classDetail.id);
    toast.success(t('teacher.classes.settingsTab.messages.deleteSuccess'));
    // Navigate back to class list
    navigateTo('/teacher/classes');
  } catch (error: any) {
    toast.error(error?.data?.message || t('teacher.classes.settingsTab.messages.deleteError'));
    showDeleteConfirm.value = false;
  } finally {
    deletingClass.value = false;
  }
};
</script>
