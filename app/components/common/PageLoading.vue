<template>
  <transition name="fade" @enter="onEnter" @leave="onLeave">
    <div
      v-if="isLoading"
      class="fixed inset-0 z-50 flex items-center justify-center bg-white/80 backdrop-blur-sm"
    >
      <div
        class="flex flex-col items-center gap-4 bg-white rounded-xl shadow-lg border border-slate-100 p-8"
      >
        <!-- Spinner -->
        <svg
          class="animate-spin h-12 w-12 text-blue-600"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            class="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            stroke-width="4"
          ></circle>
          <path
            class="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          ></path>
        </svg>

        <!-- Text -->
        <p class="text-sm font-semibold text-slate-700">{{ message }}</p>

        <!-- Dots animation -->
        <div class="flex gap-1">
          <div
            class="w-2 h-2 bg-blue-600 rounded-full animate-bounce"
            style="animation-delay: 0s"
          ></div>
          <div
            class="w-2 h-2 bg-blue-600 rounded-full animate-bounce"
            style="animation-delay: 0.2s"
          ></div>
          <div
            class="w-2 h-2 bg-blue-600 rounded-full animate-bounce"
            style="animation-delay: 0.4s"
          ></div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup lang="ts">
import { ref } from 'vue';

interface Props {
  isLoading: boolean;
  message?: string;
}

withDefaults(defineProps<Props>(), {
  message: 'Đang tải dữ liệu...',
});

const onEnter = (el: Element) => {
  const elem = el as HTMLElement;
  elem.style.opacity = '0';
  setTimeout(() => {
    elem.style.transition = 'opacity 0.3s ease-out';
    elem.style.opacity = '1';
  }, 0);
};

const onLeave = (el: Element) => {
  const elem = el as HTMLElement;
  elem.style.transition = 'opacity 0.3s ease-out';
  elem.style.opacity = '0';
};
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
