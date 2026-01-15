<template>
  <div
    class="bg-white rounded-xl border border-slate-200 shadow-sm animate-fade-in p-6"
  >
    <div class="grid md:grid-cols-2 gap-4">
      <div
        v-for="(doc, idx) in documents"
        :key="idx"
        class="flex items-center p-4 border border-slate-200 rounded-xl hover:border-blue-300 hover:shadow-md transition-all cursor-pointer group"
        @click="$emit('download-document', doc)"
      >
        <div
          class="w-12 h-12 bg-red-100 text-red-500 rounded-lg flex items-center justify-center text-2xl mr-4"
        >
          <i class="fa-regular fa-file-pdf"></i>
        </div>
        <div class="flex-1">
          <h4
            class="font-bold text-slate-800 group-hover:text-blue-600 transition-colors"
          >
            {{ doc.name }}
          </h4>
          <div class="text-xs text-slate-500 mt-1">
            {{ doc.size }} • {{ doc.date }}
          </div>
        </div>
        <button
          class="w-8 h-8 rounded-full bg-slate-100 text-slate-500 flex items-center justify-center hover:bg-blue-600 hover:text-white transition-colors"
        >
          <i class="fa-solid fa-download"></i>
        </button>
      </div>
      <div
        v-if="documents.length === 0"
        class="col-span-2 text-center py-12 text-slate-400"
      >
        <i class="fa-solid fa-inbox text-3xl mb-2"></i>
        <p>{{ $t('student.classes.detail.documents.noDocuments') }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Document {
  name: string;
  size: string;
  date: string;
  url: string;
}

interface Props {
  documents: Document[];
}

defineProps<Props>();

defineEmits<{
  'download-document': [document: Document];
}>();
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}

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
</style>
