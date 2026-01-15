<template>
  <div
    class="h-full flex flex-col bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"
  >
    <div
      class="p-4 border-b border-slate-100 bg-slate-50 flex justify-between items-center"
    >
      <div class="flex items-center gap-2">
        <div
          class="w-8 h-8 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-lg flex items-center justify-center text-white"
        >
          <i class="fa-solid fa-wand-magic-sparkles"></i>
        </div>
        <div>
          <h3 class="font-bold text-slate-800">Teacher AI Assistant</h3>
          <p class="text-xs text-slate-500">Hỗ trợ soạn bài, phân tích dữ liệu</p>
        </div>
      </div>
      <span class="bg-amber-100 text-amber-700 text-xs font-bold px-2 py-1 rounded"
        >VIP</span
      >
    </div>

    <div class="flex-1 overflow-y-auto p-4 space-y-4 bg-slate-50/30 custom-scroll">
      <div class="flex gap-3">
        <div
          class="w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 flex-shrink-0"
        >
          <i class="fa-solid fa-robot"></i>
        </div>
        <div
          class="bg-white border border-slate-200 p-3 rounded-2xl rounded-tl-none text-sm text-slate-700 shadow-sm max-w-[80%]"
        >
          Chào thầy! Em có thể giúp thầy:<br />
          - Soạn nhận xét học sinh<br />
          - Thống kê điểm số<br />
          - Gợi ý bài tập về nhà<br />
          Thầy cần hỗ trợ gì không ạ?
        </div>
      </div>

      <!-- Suggestion Chips -->
      <div class="flex flex-wrap gap-2 pl-11">
        <button
          @click="sendMessage('Soạn nhận xét cho em An (điểm 9)')"
          class="px-3 py-1.5 bg-white border border-slate-200 text-xs font-bold text-slate-600 rounded-full hover:border-indigo-300 hover:text-indigo-600 transition-colors"
        >
          "Soạn nhận xét cho em An (điểm 9)"
        </button>
        <button
          @click="sendMessage('Danh sách học sinh vắng > 2 buổi')"
          class="px-3 py-1.5 bg-white border border-slate-200 text-xs font-bold text-slate-600 rounded-full hover:border-indigo-300 hover:text-indigo-600 transition-colors"
        >
          "Danh sách học sinh vắng > 2 buổi"
        </button>
      </div>

      <!-- Messages -->
      <div
        v-for="(message, idx) in messages"
        :key="idx"
        class="flex gap-3"
        :class="message.type === 'user' ? 'flex-row-reverse' : ''"
      >
        <div
          v-if="message.type === 'assistant'"
          class="w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 flex-shrink-0"
        >
          <i class="fa-solid fa-robot"></i>
        </div>
        <div
          v-else
          class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 flex-shrink-0"
        >
          <i class="fa-solid fa-user"></i>
        </div>
        <div
          :class="[
            'border border-slate-200 p-3 rounded-2xl text-sm text-slate-700 shadow-sm max-w-[80%]',
            message.type === 'user'
              ? 'bg-blue-50 rounded-tr-none'
              : 'bg-white rounded-tl-none',
          ]"
        >
          {{ message.content }}
        </div>
      </div>
    </div>

    <div class="p-4 border-t border-slate-200 bg-white">
      <div class="relative">
        <input
          v-model="inputMessage"
          @keyup.enter="sendMessage(inputMessage)"
          type="text"
          placeholder="Nhập yêu cầu của thầy..."
          class="w-full pl-4 pr-12 py-3 bg-slate-100 border-none rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 focus:bg-white transition-all"
        />
        <button
          @click="sendMessage(inputMessage)"
          class="absolute right-2 top-2 w-8 h-8 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg flex items-center justify-center transition-colors"
        >
          <i class="fa-solid fa-paper-plane text-xs"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const inputMessage = ref('');

const messages = ref([
  {
    type: 'assistant',
    content:
      'Chào thầy! Em có thể giúp thầy:\n- Soạn nhận xét học sinh\n- Thống kê điểm số\n- Gợi ý bài tập về nhà\nThầy cần hỗ trợ gì không ạ?',
  },
]);

const sendMessage = (content: string) => {
  if (!content.trim()) return;

  messages.value.push({
    type: 'user',
    content,
  });

  inputMessage.value = '';

  // Simulate AI response
  setTimeout(() => {
    messages.value.push({
      type: 'assistant',
      content: 'Đây là phản hồi mẫu từ AI. Tính năng này đang được phát triển.',
    });
  }, 1000);
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
