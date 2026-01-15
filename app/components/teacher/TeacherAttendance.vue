<template>
  <div class="h-full flex flex-col space-y-4">
    <div
      class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-4 items-center justify-between"
    >
      <div class="flex gap-4 w-full md:w-auto">
        <select
          v-model="selectedClass"
          class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-700 outline-none focus:border-blue-500"
        >
          <option value="">Chọn lớp</option>
          <option
            v-for="cls in classes"
            :key="cls.id"
            :value="cls.id"
          >
            {{ cls.name }}
          </option>
        </select>
        <input
          v-model="selectedDate"
          type="date"
          class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm font-bold text-slate-700 outline-none"
        />
      </div>
      <div class="flex gap-2">
        <div class="text-sm text-slate-500 mr-2 flex items-center">
          Sĩ số: <b class="text-slate-800 ml-1">{{ attendanceList.length }}</b>
        </div>
        <button
          @click="saveAttendance"
          class="px-4 py-2 bg-blue-600 text-white text-sm font-bold rounded-lg hover:bg-blue-700 shadow-sm"
        >
          Lưu điểm danh
        </button>
      </div>
    </div>

    <div
      class="bg-white rounded-xl border border-slate-200 shadow-sm flex-1 overflow-hidden flex flex-col"
    >
      <div class="overflow-y-auto custom-scroll flex-1">
        <table class="w-full text-sm text-left">
          <thead
            class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200 sticky top-0 z-10"
          >
            <tr>
              <th class="px-6 py-3">Học sinh</th>
              <th class="px-6 py-3 text-center">Có mặt</th>
              <th class="px-6 py-3 text-center">Vắng CP</th>
              <th class="px-6 py-3 text-center">Vắng KP</th>
              <th class="px-6 py-3 text-center">Đi muộn</th>
              <th class="px-6 py-3">Ghi chú</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr
              v-for="(student, idx) in attendanceList"
              :key="idx"
              class="hover:bg-slate-50"
            >
              <td class="px-6 py-3 font-medium text-slate-800">
                {{ student.name }}
              </td>
              <td class="px-6 py-3 text-center">
                <input
                  v-model="student.status"
                  type="radio"
                  :name="'att-' + idx"
                  value="present"
                  class="w-4 h-4 text-green-600 focus:ring-green-500"
                />
              </td>
              <td class="px-6 py-3 text-center">
                <input
                  v-model="student.status"
                  type="radio"
                  :name="'att-' + idx"
                  value="absent_excused"
                  class="w-4 h-4 text-yellow-500 focus:ring-yellow-500"
                />
              </td>
              <td class="px-6 py-3 text-center">
                <input
                  v-model="student.status"
                  type="radio"
                  :name="'att-' + idx"
                  value="absent_unexcused"
                  class="w-4 h-4 text-red-600 focus:ring-red-500"
                />
              </td>
              <td class="px-6 py-3 text-center">
                <input
                  v-model="student.status"
                  type="radio"
                  :name="'att-' + idx"
                  value="late"
                  class="w-4 h-4 text-orange-500 focus:ring-orange-500"
                />
              </td>
              <td class="px-6 py-3">
                <input
                  v-model="student.note"
                  type="text"
                  placeholder="Nhập ghi chú..."
                  class="w-full px-2 py-1 bg-transparent border-b border-slate-200 focus:border-blue-500 outline-none text-xs"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const selectedClass = ref('');
const selectedDate = ref(new Date().toISOString().split('T')[0]);

const classes = ref([
  { id: 1, name: 'Toán Luyện Thi 12A' },
  { id: 2, name: 'Toán Cơ Bản 10' },
]);

const attendanceList = ref([
  { name: 'Nguyễn Văn An', status: 'present', note: '' },
  { name: 'Trần Thị Bình', status: 'present', note: '' },
  { name: 'Lê Hoàng Cường', status: 'present', note: '' },
  { name: 'Phạm Minh Dung', status: 'present', note: '' },
  { name: 'Đỗ Quang Em', status: 'present', note: '' },
  { name: 'Hoàng Thị Gấm', status: 'present', note: '' },
  { name: 'Vũ Văn Hùng', status: 'present', note: '' },
  { name: 'Trịnh Thu Ích', status: 'present', note: '' },
]);

const saveAttendance = () => {
  // TODO: Implement save attendance API call
  console.log('Saving attendance:', attendanceList.value);
};
</script>

<style scoped>
.custom-scroll {
  scrollbar-width: thin;
  scrollbar-color: #cbd5e1 #f1f1f1;
}

.custom-scroll::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.custom-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.custom-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.custom-scroll::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
