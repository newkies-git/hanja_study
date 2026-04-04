<script setup lang="ts">
import { ref } from 'vue';

const dialog = ref(false);
</script>

<template>
  <!-- ----------------------------------------------------------------------------- -->
  <!-- Form -->
  <!-- ----------------------------------------------------------------------------- -->
  <div class="text-center">
    <v-dialog v-model="dialog" max-width="600">
      <template #activator="{ props }">
        <v-btn color="primary" v-bind="props"> Edit Profile </v-btn>
      </template>
      <v-card style="height: 300px" class="overflow-auto">
        <v-card-title class="pa-5"> User Profile </v-card-title>
        <v-card-text>
          <v-container class="pa-0">
            <v-row>
              <v-col cols="12" sm="6" md="4">
                <v-text-field label="Legal first name*" variant="filled" required rounded="0" />
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field label="Legal middle name" variant="filled" hint="example of helper text only on focus" rounded="0" />
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field
                  label="Legal last name*"
                  variant="filled"
                  hint="example of persistent helper text"
                  persistent-hint
                  required
                  rounded="0"
                />
              </v-col>
              <v-col cols="12">
                <v-text-field label="Email*" variant="filled" required rounded="0" />
              </v-col>
              <v-col cols="12">
                <v-text-field label="Password*" variant="filled" type="password" required rounded="0" />
              </v-col>
              <v-col cols="12" sm="6">
                <v-select :items="['0-17', '18-29', '30-54', '54+']" label="Age*" required rounded="0" />
              </v-col>
              <v-col cols="12" sm="6">
                <v-autocomplete
                  :items="['Skiing', 'Ice hockey', 'Soccer', 'Basketball', 'Hockey', 'Reading', 'Writing', 'Coding', 'Basejump']"
                  label="Interests"
                  multiple
                  rounded="0"
                />
              </v-col>
            </v-row>
          </v-container>
          <small>*indicates required field</small>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn color="error" variant="text" @click="dialog = false"> Close </v-btn>
          <v-btn color="success" variant="text" @click="dialog = false"> Save </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
