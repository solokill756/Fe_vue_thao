<template>
  <div class="relative">
    <!-- Language Button -->
    <button
      @click="showDropdown = !showDropdown"
      class="flex items-center gap-2 px-3 py-2 bg-white border border-slate-200 rounded-lg hover:border-blue-300 hover:bg-blue-50 transition-colors text-sm font-medium text-slate-700"
    >
      <i class="fa-solid fa-globe text-slate-500"></i>
      <span class="hidden sm:inline">{{ currentLanguageName }}</span>
      <span class="sm:hidden">{{ currentLanguageCode.toUpperCase() }}</span>
      <i
        class="fa-solid fa-chevron-down text-xs text-slate-400 transition-transform"
        :class="{ 'rotate-180': showDropdown }"
      ></i>
    </button>

    <!-- Dropdown Menu -->
    <Transition
      enter-active-class="transition ease-out duration-100"
      enter-from-class="transform opacity-0 scale-95"
      enter-to-class="transform opacity-100 scale-100"
      leave-active-class="transition ease-in duration-75"
      leave-from-class="transform opacity-100 scale-100"
      leave-to-class="transform opacity-0 scale-95"
    >
      <div
        v-if="showDropdown"
        ref="dropdownRef"
        class="absolute right-0 mt-2 w-48 bg-white border border-slate-200 rounded-lg shadow-lg z-50 overflow-hidden"
      >
        <button
          @click="changeLanguage('vi')"
          :class="[
            'w-full px-4 py-2.5 text-left flex items-center gap-3 hover:bg-blue-50 transition-colors text-sm font-medium',
            locale === 'vi'
              ? 'bg-blue-50 text-blue-600'
              : 'text-slate-700',
          ]"
        >
          <span class="text-lg">🇻🇳</span>
          <span>Tiếng Việt</span>
          <i
            v-if="locale === 'vi'"
            class="fa-solid fa-check ml-auto text-blue-600"
          ></i>
        </button>
        <button
          @click="changeLanguage('en')"
          :class="[
            'w-full px-4 py-2.5 text-left flex items-center gap-3 hover:bg-blue-50 transition-colors text-sm font-medium',
            locale === 'en'
              ? 'bg-blue-50 text-blue-600'
              : 'text-slate-700',
          ]"
        >
          <span class="text-lg">🇺🇸</span>
          <span>English</span>
          <i
            v-if="locale === 'en'"
            class="fa-solid fa-check ml-auto text-blue-600"
          ></i>
        </button>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

const { locale, setLocale } = useI18n();
const showDropdown = ref(false);
const dropdownRef = ref<HTMLElement | null>(null);

const languages = {
  vi: { name: 'Tiếng Việt', flag: '🇻🇳' },
  en: { name: 'English', flag: '🇺🇸' },
};

const currentLanguageName = computed(() => {
  return languages[locale.value as keyof typeof languages]?.name || 'Tiếng Việt';
});

const currentLanguageCode = computed(() => locale.value);

const changeLanguage = (lang: 'vi' | 'en') => {
  setLocale(lang);
  showDropdown.value = false;
};

</script>
