<script setup lang="ts">
import { ref } from 'vue';

const dialog = ref(false);
const dialog2 = ref(false);
const dialog3 = ref(false);
</script>

<template>
  <!-- ----------------------------------------------------------------------------- -->
  <!-- Nested -->
  <!-- ----------------------------------------------------------------------------- -->
  <div class="text-center">
    <v-btn color="secondary" @click="dialog = true"> Open Dialog 1 </v-btn>
    <v-dialog v-model="dialog" max-width="400">
      <v-card>
        <v-card-title class="pa-4"> Dialog 1 </v-card-title>
        <v-card-text>
          <v-btn color="primary" class="ma-2" @click="dialog2 = true"> Open Dialog 2 </v-btn>
        </v-card-text>
        <v-card-actions>
          <v-btn color="error" variant="text" @click="dialog = false"> Close </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="dialog2" max-width="300">
      <v-card>
        <v-card-title class="pa-4"> Dialog 2 </v-card-title>
        <v-card-text>
          <v-btn color="secondary" @click="dialog3 = !dialog3"> Open Dialog 3 </v-btn>
        </v-card-text>
        <v-card-actions>
          <v-btn color="error" variant="text" @click="dialog2 = false"> Close </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="dialog3" max-width="250">
      <v-card>
        <v-card-title class="pa-4">
          <span>Dialog 3</span>
        </v-card-title>
        <v-card-actions>
          <v-btn color="error" variant="text" @click="dialog3 = false"> Close </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
