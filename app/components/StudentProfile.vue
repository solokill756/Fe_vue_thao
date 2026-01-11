<template>
  <div class="component-box h-full flex flex-col gap-6 animate-fade-in">
    <!-- Header Banner -->
    <div
      class="relative bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden flex-shrink-0"
    >
      <div class="h-32"></div>
      <div
        class="px-8 pb-6 flex flex-col md:flex-row items-end md:items-center -mt-10 gap-6"
      >
        <div class="relative">
          <img
            :src="student.avatar || '/default-avatar.png'"
            class="w-24 h-24 rounded-full border-4 border-white shadow-md bg-white"
          />
          <button
            @click="triggerFileInput"
            :disabled="isUploading"
            class="absolute bottom-0 right-0 w-8 h-8 bg-slate-100 hover:bg-blue-100 text-slate-600 hover:text-blue-600 rounded-full border border-white shadow-sm flex items-center justify-center transition-colors disabled:opacity-50"
          >
            <i v-if="!isUploading" class="fa-solid fa-camera text-xs"></i>
            <i v-else class="fa-solid fa-spinner text-xs animate-spin"></i>
          </button>
          <input
            ref="fileInput"
            type="file"
            accept="image/*"
            class="hidden"
            @change="handleFileSelect"
          />
        </div>
        <div class="flex-1 mb-2">
          <h1 class="text-2xl font-bold text-slate-800">
            {{ formData.fullName }}
          </h1>
          <p class="text-slate-500 text-sm">
            Học sinh trường {{ formData.school }}
          </p>
        </div>
        <div class="mb-2 hidden md:block">
          <div class="text-right">
            <span
              class="text-xs font-bold text-slate-400 uppercase tracking-wider"
              >Mã học sinh</span
            >
            <div class="font-mono font-bold text-slate-700">TMS-2024-001</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Content Area -->
    <div class="flex flex-col md:flex-row gap-6 flex-1 overflow-hidden">
      <!-- Left Menu -->
      <div
        class="w-full md:w-64 bg-white rounded-xl border border-slate-200 shadow-sm h-fit"
      >
        <nav class="p-2 space-y-1">
          <button
            @click="activeTab = 'general'"
            :class="[
              'w-full flex items-center gap-3 px-4 py-3 text-sm font-bold rounded-lg transition-colors text-left',
              activeTab === 'general'
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-600 hover:bg-slate-50',
            ]"
          >
            <i class="fa-regular fa-id-card w-5"></i> Thông tin chung
          </button>
          <button
            @click="activeTab = 'parents'"
            :class="[
              'w-full flex items-center gap-3 px-4 py-3 text-sm font-bold rounded-lg transition-colors text-left',
              activeTab === 'parents'
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-600 hover:bg-slate-50',
            ]"
          >
            <i class="fa-solid fa-user-group w-5"></i> Phụ huynh liên kết
          </button>
          <button
            @click="activeTab = 'security'"
            :class="[
              'w-full flex items-center gap-3 px-4 py-3 text-sm font-bold rounded-lg transition-colors text-left',
              activeTab === 'security'
                ? 'bg-blue-50 text-blue-600'
                : 'text-slate-600 hover:bg-slate-50',
            ]"
          >
            <i class="fa-solid fa-shield-halved w-5"></i> Bảo mật
          </button>
        </nav>
      </div>

      <!-- Right Content Form -->
      <div
        class="flex-1 bg-white rounded-xl border border-slate-200 shadow-sm overflow-y-auto p-6 md:p-8"
      >
        <!-- TAB 1: GENERAL INFO -->
        <div v-if="activeTab === 'general'" class="space-y-6 animate-fade-in">
          <div
            class="flex items-center justify-between border-b border-slate-100 pb-4"
          >
            <h2 class="text-xl font-bold text-slate-800">Thông tin cá nhân</h2>
            <button
              id="saveBtn"
              @click="saveChanges"
              class="px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700 shadow-sm transition-all"
            >
              Lưu thay đổi
            </button>
          </div>

          <div class="grid md:grid-cols-2 gap-6">
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600">Họ và tên</label>
              <input
                v-model="formData.fullName"
                type="text"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600">Ngày sinh</label>
              <input
                v-model="formData.dob"
                type="date"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Số điện thoại</label
              >
              <input
                v-model="formData.phone_number"
                type="tel"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Email (Không thể sửa)</label
              >
              <input
                v-model="formData.email"
                type="email"
                disabled
                class="w-full px-4 py-2 bg-slate-100 border border-slate-200 rounded-lg text-slate-500 cursor-not-allowed"
              />
            </div>
            <div class="md:col-span-2 space-y-1">
              <label class="text-sm font-bold text-slate-600">Địa chỉ</label>
              <input
                v-model="formData.address"
                type="text"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Trường học hiện tại</label
              >
              <input
                v-model="formData.school"
                type="text"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Giới thiệu thêm</label
              >
              <input
                v-model="formData.note"
                type="text"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
          </div>
        </div>

        <!-- TAB 2: PARENTS -->
        <div
          v-else-if="activeTab === 'parents'"
          class="space-y-6 animate-fade-in"
        >
          <div class="border-b border-slate-100 pb-4">
            <h2 class="text-xl font-bold text-slate-800">Phụ huynh liên kết</h2>
            <p class="text-sm text-slate-500 mt-1">
              Thông tin tài khoản phụ huynh đang quản lý hồ sơ học tập của bạn.
            </p>
          </div>

          <div
            class="bg-blue-50 border border-blue-100 rounded-xl p-5 flex items-start gap-4"
          >
            <div
              class="w-12 h-12 rounded-full bg-white flex items-center justify-center text-blue-600 border border-blue-100 text-xl"
            >
              <i class="fa-solid fa-user-shield"></i>
            </div>
            <div class="flex-1">
              <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div class="flex items-center gap-2 text-slate-600">
                  <i class="fa-solid fa-phone text-slate-400 w-4"></i>
                  {{ props.student.parent_name || '' }}
                </div>
                <div class="flex items-center gap-2 text-slate-600">
                  <i class="fa-solid fa-envelope text-slate-400 w-4"></i>
                  {{ props.student.parent_phone || '' }}
                </div>
                <div
                  class="flex items-center gap-2 text-slate-600 md:col-span-2"
                >
                  <i class="fa-solid fa-calendar-check text-slate-400 w-4"></i>
                  Liên kết ngày: {{ props.student.parent_linked_at || '' }}
                </div>
              </div>
            </div>
          </div>

          <div
            class="p-4 bg-slate-50 rounded-xl border border-slate-200 text-center text-sm text-slate-500"
          >
            <i class="fa-solid fa-circle-info text-blue-500 mr-1"></i>
            Cần thay đổi thông tin phụ huynh? Vui lòng liên hệ Văn phòng trung
            tâm.
          </div>
        </div>

        <!-- TAB 3: SECURITY -->
        <div
          v-else-if="activeTab === 'security'"
          class="space-y-6 animate-fade-in"
        >
          <div class="border-b border-slate-100 pb-4">
            <h2 class="text-xl font-bold text-slate-800">Đổi mật khẩu</h2>
            <p class="text-sm text-slate-500 mt-1">
              Vui lòng sử dụng mật khẩu mạnh để bảo vệ tài khoản.
            </p>
          </div>

          <div class="space-y-4 max-w-md">
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Mật khẩu hiện tại</label
              >
              <input
                type="password"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 transition-all"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Mật khẩu mới</label
              >
              <input
                type="password"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 transition-all"
              />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-bold text-slate-600"
                >Xác nhận mật khẩu mới</label
              >
              <input
                type="password"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 transition-all"
              />
            </div>
            <button
              class="px-6 py-2 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-sm transition-all mt-2"
            >
              Cập nhật mật khẩu
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { StudentProfile } from '@/types/student';
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToast } from 'vue-toastification';

const { updateProfile } = useStudentApi();
const toast = useToast();
const { startLoading, stopLoading } = useLoading();
const { t } = useI18n();
const { updateUser, uploadAvatar } = useUserApi();
const props = defineProps<{
  student: StudentProfile;
}>();

const fileInput = ref<HTMLInputElement | null>(null);
const isUploading = ref(false);
const authStore = useAuthStore();

const formData = ref({
  fullName: props.student.full_name || '',
  dob: props.student.dob || '',
  phone_number: props.student.phone_number || '',
  email: props.student.email || '',
  address: props.student.address || '',
  school: props.student.school || '',
  note: props.student.note || '',
});

const activeTab = ref('general');

const triggerFileInput = () => {
  fileInput.value?.click();
};

const handleFileSelect = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];

  if (!file) return;

  if (file.size > 5 * 1024 * 1024) {
    toast.error(t('toast.fileTooLarge') || 'File quá lớn. Max 5MB');
    return;
  }

  if (!file.type.startsWith('image/')) {
    toast.error(t('toast.invalidFileType') || 'Vui lòng chọn file ảnh');
    return;
  }

  await uploadAvatarUser(file);
  target.value = '';
};

const uploadAvatarUser = async (file: File) => {
  isUploading.value = true;
  try {
    const response = await uploadAvatar(file);
    if (response.data) {
      props.student.avatar = response.data.avatar;
      authStore.refreshUser({
        ...authStore.user!,
        photo_url: response.data.avatar,
      });
      toast.success(t('toast.avatarUploaded') || 'Upload ảnh thành công');
    }
  } catch (error: any) {
    toast.error(
      error.data?.message || t('toast.uploadError') || 'Upload ảnh thất bại'
    );
  } finally {
    isUploading.value = false;
  }
};

const saveChanges = async () => {
  startLoading(t('loading.savingChanges'));
  try {
    if (formData.value.fullName || formData.value.phone_number) {
      await updateUser({
        full_name: formData.value.fullName,
        phone_number: formData.value.phone_number,
      });
    }
    await updateProfile({
      dob: formData.value.dob,
      address: formData.value.address,
      school: formData.value.school,
      note: formData.value.note,
    });
    authStore.refreshUser({
      ...authStore.user!,
      full_name: formData.value.fullName,
      phone_number: formData.value.phone_number,
    });
    toast.success(t('toast.profileUpdated'));
  } catch (error) {
    toast.error(t('toast.errorSavingChanges'));
  } finally {
    stopLoading();
  }
};
</script>

<style scoped>
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}
</style>
