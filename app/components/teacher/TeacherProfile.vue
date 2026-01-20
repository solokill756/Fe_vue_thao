<template>
  <div class="component-box h-full flex flex-col gap-6 animate-fade-in">
    <!-- Header Banner -->
    <div
      class="relative bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden flex-shrink-0"
    >
      <div class="h-32 "></div>
      <ClientOnly>
        <div
          class="px-8 pb-6 flex flex-col md:flex-row items-end md:items-center -mt-10 gap-6"
        >
          <div class="relative">
            <img
              :src="avatarUrl"
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
            <p class="text-slate-500 text-sm">Giáo viên</p>
          </div>
          <div class="mb-2 hidden md:block">
            <div class="text-right">
              <span
                class="text-xs font-bold text-slate-400 uppercase tracking-wider"
                >Email</span
              >
              <div class="font-mono font-bold text-slate-700 text-sm">
                {{ formData.email }}
              </div>
            </div>
          </div>
        </div>
        <template #fallback>
          <div
            class="px-8 pb-6 flex flex-col md:flex-row items-end md:items-center -mt-10 gap-6"
          >
            <div class="relative">
              <div
                class="w-24 h-24 rounded-full border-4 border-white shadow-md bg-slate-200"
              ></div>
            </div>
            <div class="flex-1 mb-2">
              <div class="h-8 w-48 bg-slate-200 rounded"></div>
              <div class="h-4 w-24 bg-slate-200 rounded mt-2"></div>
            </div>
            <div class="mb-2 hidden md:block">
              <div class="h-6 w-32 bg-slate-200 rounded"></div>
            </div>
          </div>
        </template>
      </ClientOnly>
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
              <label class="text-sm font-bold text-slate-600"
                >Số điện thoại</label
              >
              <input
                v-model="formData.phone_number"
                type="tel"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all font-medium text-slate-800"
              />
            </div>
            <div class="md:col-span-2 space-y-1">
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
          </div>

          <!-- QR Code Section -->
          <div class="border-t border-slate-100 pt-6 mt-6">
            <h3 class="text-lg font-bold text-slate-800 mb-4">Mã QR Code</h3>
            <div class="flex flex-col md:flex-row gap-6 items-start">
              <div class="flex-shrink-0">
                <div class="relative w-48 h-48 bg-slate-50 border-2 border-dashed border-slate-300 rounded-lg flex items-center justify-center overflow-hidden">
                  <img
                    v-if="qrCodeUrl"
                    :src="qrCodeUrl"
                    alt="QR Code"
                    class="w-full h-full object-contain p-2"
                  />
                  <div
                    v-else
                    class="text-center p-4 text-slate-400"
                  >
                    <i class="fa-solid fa-qrcode text-4xl mb-2"></i>
                    <p class="text-xs font-medium">Chưa có QR Code</p>
                  </div>
                </div>
              </div>
              <div class="flex-1 space-y-4">
                <div>
                  <label class="text-sm font-bold text-slate-600 block mb-2">
                    Upload ảnh QR Code
                  </label>
                  <div class="flex gap-2">
                    <input
                      ref="qrCodeFileInput"
                      type="file"
                      accept="image/*"
                      class="hidden"
                      @change="handleQrCodeFileSelect"
                    />
                    <button
                      @click="triggerQrCodeFileInput"
                      :disabled="isUploadingQrCode"
                      class="px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700 shadow-sm transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                    >
                      <i
                        v-if="!isUploadingQrCode"
                        class="fa-solid fa-upload text-xs"
                      ></i>
                      <i
                        v-else
                        class="fa-solid fa-spinner text-xs animate-spin"
                      ></i>
                      {{ isUploadingQrCode ? 'Đang upload...' : 'Chọn ảnh' }}
                    </button>
                  </div>
                  <p class="text-xs text-slate-500 mt-2">
                    Hỗ trợ định dạng: JPG, PNG. Kích thước tối đa: 5MB
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- TAB 2: SECURITY -->
        <div
          v-else-if="activeTab === 'security'"
          class="space-y-6 animate-fade-in"
        >
          <div class="border-b border-slate-100 pb-4">
            <h2 class="text-xl font-bold text-slate-800">Bảo mật</h2>
            <p class="text-sm text-slate-500 mt-1">
              Thay đổi mật khẩu để bảo vệ tài khoản của bạn.
            </p>
          </div>

          <div class="grid md:grid-cols-2 gap-6">
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
              class="px-6 py-2 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 shadow-sm transition-all mt-8"
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
import { ref, computed, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToast } from 'vue-toastification';

const { t } = useI18n();
const toast = useToast();
const authStore = useAuthStore();
const { updateUser, uploadAvatar, uploadQrCode } = useUserApi();

const fileInput = ref<HTMLInputElement | null>(null);
const qrCodeFileInput = ref<HTMLInputElement | null>(null);
const isUploading = ref(false);
const isUploadingQrCode = ref(false);
const activeTab = ref('general');


const formData = ref({
  fullName: authStore.user?.full_name || '',
  phone_number: authStore.user?.phone_number || '',
  email: authStore.user?.email || '',
});

watch(
  () => authStore.user,
  (user) => {
    if (user) {
      formData.value = {
        fullName: user.full_name || '',
        phone_number: user.phone_number || '',
        email: user.email || '',
      };
    }
  },
  { immediate: true }
);

const avatarUrl = computed(() => {
  return (
    authStore.user?.photo_url ||
    `https://ui-avatars.com/api/?name=${encodeURIComponent(
      authStore.user?.full_name || 'Teacher'
    )}&background=random`
  );
});

const qrCodeUrl = computed(() => {
  return (authStore.user?.teacher_qr_code || null);
});

const triggerFileInput = () => {
  fileInput.value?.click();
};

const triggerQrCodeFileInput = () => {
  qrCodeFileInput.value?.click();
};

const handleFileSelect = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];

  if (!file) return;

  if (file.size > 5 * 1024 * 1024) {
    toast.error('File quá lớn. Max 5MB');
    return;
  }

  if (!file.type.startsWith('image/')) {
    toast.error('Vui lòng chọn file ảnh');
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
      authStore.refreshUser({
        ...authStore.user!,
        photo_url: response.data.avatar,
      });
      toast.success(t('teacher.profile.success.avatarUploaded'));
    }
  } catch (error: any) {
    toast.error(error.data?.message || t('teacher.profile.errors.uploadAvatarFailed'));
  } finally {
    isUploading.value = false;
  }
};

const handleQrCodeFileSelect = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];

  if (!file) return;

  if (file.size > 5 * 1024 * 1024) {
    toast.error(t('teacher.profile.errors.fileTooLarge'));
    return;
  }

  if (!file.type.startsWith('image/')) {
    toast.error(t('teacher.profile.errors.invalidFileType'));
    return;
  }

  await uploadQrCodeUser(file);
  target.value = '';
};

const uploadQrCodeUser = async (file: File) => {
  isUploadingQrCode.value = true;
  try {
    const response = await uploadQrCode(file);
    if (response.data) {
      // Update authStore with new qr_code
      // Store qr_code in user object (may need to extend UserModel type)
      const updatedUser = {
        ...authStore.user!,
        teacher: {
          ...((authStore.user as any)?.teacher || {}),
          qr_code: response.data.qr_code,
        },
      } as any;
      authStore.refreshUser(updatedUser);
      toast.success(t('teacher.profile.success.qrCodeUploaded'));
    }
  } catch (error: any) {
    toast.error(error.data?.message || t('teacher.profile.errors.uploadQrCodeFailed'));
  } finally {
    isUploadingQrCode.value = false;
  }
};

const saveChanges = async () => {
  try {
    await updateUser({
      full_name: formData.value.fullName,
      phone_number: formData.value.phone_number,
    });
    authStore.refreshUser({
      ...authStore.user!,
      full_name: formData.value.fullName,
      phone_number: formData.value.phone_number,
    });
    toast.success(t('teacher.profile.success.updated'));
  } catch (error: any) {
    toast.error(error.data?.message || t('teacher.profile.errors.updateFailed'));
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