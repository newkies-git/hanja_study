<script setup lang="ts">
import { ref } from 'vue';
import { Form } from 'vee-validate';

const name = ref('');
const inline = ref('home');
const isdefault = ref(false);
interface ValidationRules {
  name: (value: string) => boolean | string;
  required: (value: string) => boolean | string;
}
const rules: ValidationRules = {
  name: (value: string) => value.length > 2 || 'More than two letters required',
  required: (value: string) => !!value || 'This field is required'
};
</script>

<template>
  <v-card>
    <v-card-text class="pb-4">
      <div class="d-flex justify-space-between">
        <h3>Add Billing Address</h3>
        <v-btn icon @click="$emit('handledialog')" size="small" flat><XIcon size="16" /></v-btn>
      </div>
    </v-card-text>
    <v-divider></v-divider>
    <v-card-text>
      <Form class="py-3">
        <v-row>
          <v-col cols="12" lg="6">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="First Name"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="6">
            <v-radio-group v-model="inline" inline hide-details="auto">
              <v-radio label="Home" value="home" color="primary"></v-radio>
              <v-radio label="Office" value="office" color="secondary"></v-radio>
            </v-radio-group>
          </v-col>
          <v-col cols="12" lg="12">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="Building No"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="12">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="Street"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="6">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="City"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="6">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="State"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="6">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="Country"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="6">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="Area code"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="12">
            <v-text-field
              v-model="name"
              :rules="[rules.required, rules.name]"
              label="Contact"
              hide-details="auto"
              :color="name.length > 2 ? 'success' : 'primary'"
            ></v-text-field>
          </v-col>
          <v-col cols="12" lg="12">
            <v-switch v-model="isdefault" label="Default"></v-switch>
          </v-col>
          <v-col cols="12" lg="12" class="text-end">
            <v-btn color="error" type="submit" variant="text" class="me-2" @click="$emit('handledialog')">Cancel</v-btn>
            <v-btn color="primary" type="submit" @click="$emit('handledialog')">Submit</v-btn>
          </v-col>
        </v-row>
      </Form>
    </v-card-text>
  </v-card>
</template>
