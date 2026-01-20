<template>
  <div class="h-full flex flex-col gap-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-bold text-slate-800">Quản lý Người dùng</h1>
      <button
        @click="openCreateModal"
        class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white text-sm font-bold rounded-lg shadow-sm flex items-center gap-2"
      >
        <i class="fa-solid fa-plus"></i>
        Tạo người dùng mới
      </button>
    </div>

    <!-- Filters -->
    <div
      class="bg-white rounded-xl border border-slate-200 shadow-sm p-4 flex flex-col sm:flex-row gap-4"
    >
      <div class="flex-1">
        <div class="relative">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Tìm kiếm theo email hoặc tên..."
            class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:border-purple-500"
          />
          <i
            class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"
          ></i>
        </div>
      </div>
      <select
        v-model="filterRole"
        class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-700 outline-none focus:border-purple-500"
      >
        <option value="">Tất cả vai trò</option>
        <option value="teacher">Giáo viên</option>
        <option value="student">Học sinh</option>
      </select>
      <select
        v-model="filterStatus"
        class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-700 outline-none focus:border-purple-500"
      >
        <option value="">Tất cả trạng thái</option>
        <option value="active">Đã kích hoạt</option>
        <option value="inactive">Chưa kích hoạt</option>
      </select>
    </div>

    <!-- Table -->
    <div
      class="bg-white rounded-xl border border-slate-200 shadow-sm flex-1 overflow-hidden flex flex-col"
    >
      <div v-if="pending" class="flex items-center justify-center h-full">
        <div class="text-center">
          <i class="fa-solid fa-spinner fa-spin text-4xl text-purple-600 mb-2"></i>
          <p class="text-slate-500">Đang tải...</p>
        </div>
      </div>

      <div
        v-else-if="error"
        class="flex flex-col items-center justify-center h-full text-slate-400 p-8"
      >
        <i class="fa-solid fa-exclamation-triangle text-4xl mb-2 text-red-500"></i>
        <p>{{ error.message || $t('admin.users.modal.errors.errorOccurred') }}</p>
      </div>

      <div v-else-if="users.length === 0" class="flex flex-col items-center justify-center h-full text-slate-400 p-8">
        <i class="fa-solid fa-users text-4xl mb-2"></i>
        <p>{{ $t('admin.users.noUsers') }}</p>
      </div>

      <table v-else class="w-full text-sm text-left border-collapse">
        <thead
          class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200 sticky top-0 z-10 shadow-sm"
        >
          <tr>
            <th class="px-6 py-3">ID</th>
            <th class="px-6 py-3">Email</th>
            <th class="px-6 py-3">Tên</th>
            <th class="px-6 py-3">Vai trò</th>
            <th class="px-6 py-3">Trạng thái</th>
            <th class="px-6 py-3">Ngày tạo</th>
            <th class="px-6 py-3 text-right">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr
            v-for="user in users"
            :key="user.id"
            class="hover:bg-slate-50 transition-colors"
          >
            <td class="px-6 py-4 font-mono text-xs text-slate-500">{{ user.id }}</td>
            <td class="px-6 py-4 font-medium text-slate-800">{{ user.email }}</td>
            <td class="px-6 py-4 text-slate-700">{{ user.full_name }}</td>
            <td class="px-6 py-4">
              <span
                :class="[
                  'px-2.5 py-1 rounded-full text-xs font-bold border',
                  user.role === 'teacher'
                    ? 'bg-blue-100 text-blue-700 border-blue-200'
                    : 'bg-green-100 text-green-700 border-green-200',
                ]"
              >
                {{ user.role === 'teacher' ? 'Giáo viên' : 'Học sinh' }}
              </span>
            </td>
            <td class="px-6 py-4">
              <span
                :class="[
                  'px-2.5 py-1 rounded-full text-xs font-bold border',
                  user.is_active
                    ? 'bg-green-100 text-green-700 border-green-200'
                    : 'bg-red-100 text-red-700 border-red-200',
                ]"
              >
                {{ user.is_active ? 'Đã kích hoạt' : 'Chưa kích hoạt' }}
              </span>
            </td>
            <td class="px-6 py-4 text-slate-600 text-xs">
              {{ formatDate(user.created_at) }}
            </td>
            <td class="px-6 py-4 text-right">
              <div class="flex justify-end gap-2">
                <button
                  @click="openEditModal(user)"
                  class="px-3 py-1.5 bg-blue-50 text-blue-600 text-xs font-bold rounded hover:bg-blue-100 transition-colors"
                >
                  <i class="fa-solid fa-edit"></i>
                </button>
                <button
                  @click="handleToggleStatus(user)"
                  :disabled="processing"
                  :class="[
                    'px-3 py-1.5 text-xs font-bold rounded transition-colors',
                    user.is_active
                      ? 'bg-orange-50 text-orange-600 hover:bg-orange-100'
                      : 'bg-green-50 text-green-600 hover:bg-green-100',
                    processing ? 'opacity-50 cursor-not-allowed' : '',
                  ]"
                >
                  <i
                    :class="user.is_active ? 'fa-solid fa-lock' : 'fa-solid fa-unlock'"
                  ></i>
                </button>
                <!-- <button
                  @click="handleDelete(user)"
                  :disabled="processing"
                  class="px-3 py-1.5 bg-red-50 text-red-600 text-xs font-bold rounded hover:bg-red-100 transition-colors disabled:opacity-50"
                >
                  <i class="fa-solid fa-trash"></i>
                </button> -->
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination - Outside table container for better visibility -->
    <div v-if="!pending && !error && pagination && pagination.total_count > 0" class="bg-white rounded-xl border border-slate-200 shadow-sm">
      <CommonPagination
        :current-page="pagination.current_page"
        :total-pages="pagination.total_pages"
        :items-per-page="pagination.per_page"
        :total-items="pagination.total_count"
        @update:current-page="handlePageChange"
        @update:items-per-page="handlePerPageChange"
        class="p-4"
      />
    </div>

    <!-- Create/Edit Modal -->
    <Teleport to="body">
      <div
        v-if="showModal"
        class="fixed inset-0 z-[9999] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4"
        @click.self="closeModal"
      >
        <div
          class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden flex flex-col max-h-[90vh]"
        >
          <div
            class="p-5 border-b border-slate-100 flex justify-between items-center bg-slate-50"
          >
            <h3 class="font-bold text-lg text-slate-800">
              {{ editingUser ? 'Sửa người dùng' : 'Tạo người dùng mới' }}
            </h3>
            <button @click="closeModal" class="text-slate-400 hover:text-slate-600">
              <i class="fa-solid fa-xmark text-xl"></i>
            </button>
          </div>
          <div class="p-6 overflow-y-auto custom-scroll space-y-4">
            <div>
              <label class="text-sm font-bold text-slate-600 mb-1 block">Email *</label>
              <input
                v-model="userForm.email"
                type="email"
                :disabled="!!editingUser"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-purple-500 disabled:bg-slate-100 disabled:cursor-not-allowed"
              />
            </div>
            <div>
              <label class="text-sm font-bold text-slate-600 mb-1 block">Họ và tên *</label>
              <input
                v-model="userForm.full_name"
                type="text"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-purple-500"
              />
            </div>
            <div>
              <label class="text-sm font-bold text-slate-600 mb-1 block">Mật khẩu {{ editingUser ? '(để trống nếu không đổi)' : '*' }}</label>
              <input
                v-model="userForm.password"
                type="password"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-purple-500"
              />
            </div>
            <div>
              <label class="text-sm font-bold text-slate-600 mb-1 block">Vai trò *</label>
              <select
                v-model="userForm.role"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-purple-500"
              >
                <option value="teacher">Giáo viên</option>
                <option value="student">Học sinh</option>
              </select>
            </div>
            <div>
              <label class="text-sm font-bold text-slate-600 mb-1 block">Số điện thoại</label>
              <input
                v-model="userForm.phone_number"
                type="tel"
                class="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:border-purple-500"
              />
            </div>
            <div v-if="editingUser" class="flex items-center gap-2">
              <input
                v-model="userForm.is_active"
                type="checkbox"
                id="is_active"
                class="w-4 h-4 text-purple-600 border-slate-300 rounded focus:ring-purple-500"
              />
              <label for="is_active" class="text-sm font-bold text-slate-600">Kích hoạt tài khoản</label>
            </div>
            <div class="flex gap-3 pt-2">
              <button
                @click="closeModal"
                class="flex-1 px-4 py-2 bg-slate-100 text-slate-700 text-sm font-bold rounded-lg hover:bg-slate-200 transition-colors"
              >
                Hủy
              </button>
              <button
                @click="handleSubmit"
                :disabled="submitting"
                class="flex-1 px-4 py-2 bg-purple-600 text-white text-sm font-bold rounded-lg hover:bg-purple-700 transition-colors disabled:opacity-50"
              >
                {{ submitting ? 'Đang xử lý...' : editingUser ? 'Cập nhật' : 'Tạo' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToast } from 'vue-toastification';
import { clearNuxtData } from 'nuxt/app';
import type { AdminUser, CreateUserParams, UpdateUserParams } from '@/composables/useAdminApi';

definePageMeta({
  layout: 'admin',
  middleware: 'auth',
});

const { t } = useI18n();
const toast = useToast();
const { getUsers, createUser, updateUser, deleteUser, toggleUserStatus } = useAdminApi();

const searchQuery = ref('');
const filterRole = ref<'teacher' | 'student' | ''>('');
const filterStatus = ref<'active' | 'inactive' | ''>('');
const currentPage = ref(1);
const perPage = ref(20);
const processing = ref(false);
const submitting = ref(false);
const showModal = ref(false);
const editingUser = ref<AdminUser | null>(null);

const userForm = ref<CreateUserParams & { is_active?: boolean }>({
  email: '',
  full_name: '',
  password: '',
  role: 'teacher',
  is_active: true,
  phone_number: '',
});

// Load users with useAsyncData
const { data: usersData, pending, error, refresh } = useAsyncData(
  () => `admin-users-${currentPage.value}-${perPage.value}-${filterRole.value}-${filterStatus.value}-${searchQuery.value}`,
  async () => {
    const response = await getUsers({
      page: currentPage.value,
      per_page: perPage.value,
      role: filterRole.value || undefined,
      status: filterStatus.value || undefined,
      search: searchQuery.value || undefined,
    });
    return response.data;
  },
  {
    watch: [currentPage, perPage, filterRole, filterStatus, searchQuery],
    default: () => ({ users: [], pagination: null }),
    server: false, // Only fetch on client side to avoid SSR issues
  }
);

const users = computed(() => usersData.value?.users || []);
const pagination = computed(() => usersData.value?.pagination || null);

watch([filterRole, filterStatus, searchQuery], () => {
  currentPage.value = 1; // Reset to first page on filter change
});

const handlePageChange = (page: number) => {
  currentPage.value = page;
};

const handlePerPageChange = (newPerPage: number) => {
  perPage.value = newPerPage;
  currentPage.value = 1;
};

const openCreateModal = () => {
  editingUser.value = null;
  userForm.value = {
    email: '',
    full_name: '',
    password: '',
    role: 'teacher',
    is_active: true,
    phone_number: '',
  };
  showModal.value = true;
};

const openEditModal = (user: AdminUser) => {
  editingUser.value = user;
  userForm.value = {
    email: user.email,
    full_name: user.full_name,
    password: '',
    role: user.role as 'teacher' | 'student',
    is_active: user.is_active,
    phone_number: user.phone_number || '',
  };
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  editingUser.value = null;
};

const handleSubmit = async () => {
  if (!userForm.value.email || !userForm.value.full_name) {
    toast.error(t('admin.users.modal.errors.fillAllFields'));
    return;
  }

  if (!editingUser.value && !userForm.value.password) {
    toast.error(t('admin.users.modal.errors.passwordRequired'));
    return;
  }

  submitting.value = true;
  try {
    if (editingUser.value) {
      const updateParams: UpdateUserParams = {
        full_name: userForm.value.full_name,
        role: userForm.value.role,
        is_active: userForm.value.is_active,
        phone_number: userForm.value.phone_number || undefined,
      };
      if (userForm.value.password) {
        updateParams.password = userForm.value.password;
      }
      await updateUser(editingUser.value.id, updateParams);
      toast.success(t('admin.users.modal.success.update'));
    } else {
      await createUser(userForm.value as CreateUserParams);
      toast.success(t('admin.users.modal.success.create'));
    }
    closeModal();
    // Clear cache and refresh to get updated data
    const key = `admin-users-${currentPage.value}-${perPage.value}-${filterRole.value}-${filterStatus.value}-${searchQuery.value}`;
    clearNuxtData(key);
    await refresh();
  } catch (err: any) {
    toast.error(err.data?.message || t('admin.users.modal.errors.errorOccurred'));
  } finally {
    submitting.value = false;
  }
};

const handleToggleStatus = async (user: AdminUser) => {
  const oldStatus = user.is_active;
  
  if (!confirm(oldStatus ? t('admin.users.toggleStatus.confirmLock') : t('admin.users.toggleStatus.confirmActivate'))) {
    return;
  }

  processing.value = true;
  try {
    await toggleUserStatus(user.id);
    
    // Show success message
    toast.success(oldStatus ? t('admin.users.toggleStatus.locked') : t('admin.users.toggleStatus.activated'));
    
    // Clear cache and refresh
    const cacheKey = `admin-users-${currentPage.value}-${perPage.value}-${filterRole.value}-${filterStatus.value}-${searchQuery.value}`;
    clearNuxtData(cacheKey);
    
    // Force refresh
    await refresh();
  } catch (err: any) {
    console.error('Toggle status error:', err);
    const errorMessage = err.data?.message || err.data?.error || err.message || t('admin.users.toggleStatus.error');
    toast.error(errorMessage);
  } finally {
    processing.value = false;
  }
};

const handleDelete = async (user: AdminUser) => {
  if (!confirm(t('admin.users.delete.confirm', { name: user.full_name }))) {
    return;
  }

  processing.value = true;
  try {
    await deleteUser(user.id);
    toast.success(t('admin.users.delete.success'));
    // Clear cache and refresh to get updated data
    const key = `admin-users-${currentPage.value}-${perPage.value}-${filterRole.value}-${filterStatus.value}-${searchQuery.value}`;
    clearNuxtData(key);
    await refresh();
  } catch (err: any) {
    toast.error(err.data?.message || t('admin.users.delete.error'));
  } finally {
    processing.value = false;
  }
};

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('vi-VN');
};
</script>

<style scoped>
.custom-scroll::-webkit-scrollbar {
  width: 6px;
}

.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.custom-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}
</style>
