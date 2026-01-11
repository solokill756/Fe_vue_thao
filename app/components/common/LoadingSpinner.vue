<template>
  <div class="flex items-center justify-center" :class="containerClass">
    <div class="flex flex-col items-center gap-3">
      <!-- Spinner -->
      <svg
        :class="[
          'animate-spin',
          {
            'h-6 w-6': size === 'sm',
            'h-8 w-8': size === 'md',
            'h-12 w-12': size === 'lg',
          },
          colorClass,
        ]"
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
      <p v-if="text" :class="['text-sm font-semibold', textColorClass]">
        {{ text }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

interface Props {
  size?: 'sm' | 'md' | 'lg';
  text?: string;
  color?: 'blue' | 'slate' | 'green' | 'red';
  fullScreen?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  color: 'blue',
  fullScreen: false,
});

const containerClass = computed(() => {
  if (props.fullScreen) {
    return 'fixed inset-0 z-50 bg-white/80 backdrop-blur-sm';
  }
  return 'py-8';
});

const colorClass = computed(() => {
  const colors = {
    blue: 'text-blue-600',
    slate: 'text-slate-600',
    green: 'text-green-600',
    red: 'text-red-600',
  };
  return colors[props.color] || colors.blue;
});

const textColorClass = computed(() => {
  const colors = {
    blue: 'text-slate-700',
    slate: 'text-slate-600',
    green: 'text-green-700',
    red: 'text-red-700',
  };
  return colors[props.color] || colors.blue;
});
</script>
