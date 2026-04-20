<script setup lang="ts">
import { RouterView } from "vue-router";
import { useHanjaFontStackStyleBinding } from "@/composables/useHanjaFontStackStyleBinding";

const hanjaFontStackStyle = useHanjaFontStackStyleBinding();
</script>

<template>
  <!-- 한자 폰트 변수: 문서Element 인라인보다 Vue 트리에 두는 편이 상속·input 등에서 안정적 -->
  <div id="chusa-font-scope" class="min-h-dvh min-w-0" :style="hanjaFontStackStyle">
    <RouterView />
  </div>
</template>
