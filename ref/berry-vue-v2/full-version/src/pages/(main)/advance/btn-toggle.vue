<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// theme breadcrumb
const page = ref({ title: 'Button Toggle' });
const breadcrumbs = ref([
  {
    title: 'Advance',
    disabled: false,
    href: '#'
  },
  {
    title: 'Button Toggle',
    disabled: true,
    href: '#'
  }
]);

const toggle = ref(null);
const toggle1 = ref(2);
const toggle4 = ref(1);
const toggle5 = ref(0);
const toggle6 = ref(0);
const toggle7 = ref(0);
const toggle8 = ref(2);
const toggle9 = ref(2);
const toggle10 = ref(2);
const toggle2 = ref(undefined);
const toggle3 = ref([]);

const alignment = ref(1);
const formatting = ref([]);
const value = ref('Toggle button requirements.\r\rHave at least three toggle buttons in a group\rLabel buttons with text, an icon, or');
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Button Toggle">
        <v-row>
          <!-- Default -->
          <v-col cols="12" lg="3">
            <UiChildCard title="Default">
              <div class="text-center">
                <v-btn-toggle v-model="toggle" color="primary">
                  <v-btn icon="$formatAlignLeft" />
                  <v-btn icon="$formatAlignCenter" />
                  <v-btn icon="$formatAlignRight" />
                  <v-btn icon="$formatAlignJustify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Outlined -->
          <v-col cols="12" lg="3">
            <UiChildCard title="Outlined">
              <div class="text-center">
                <v-btn-toggle v-model="toggle4" variant="outlined" color="primary">
                  <v-btn icon="$formatAlignLeft" />
                  <v-btn icon="$formatAlignCenter" />
                  <v-btn icon="$formatAlignRight" />
                  <v-btn icon="$formatAlignJustify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Text -->
          <v-col cols="12" lg="3">
            <UiChildCard title="Text">
              <div class="text-center">
                <v-btn-toggle v-model="toggle1" variant="text" color="primary">
                  <v-btn icon="$formatAlignLeft" />
                  <v-btn icon="$formatAlignCenter" />
                  <v-btn icon="$formatAlignRight" />
                  <v-btn icon="$formatAlignJustify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Plain -->
          <v-col cols="12" lg="3">
            <UiChildCard title="Plain">
              <div class="text-center">
                <v-btn-toggle v-model="toggle5" variant="plain" color="primary">
                  <v-btn icon="$formatAlignLeft" />
                  <v-btn icon="$formatAlignCenter" />
                  <v-btn icon="$formatAlignRight" />
                  <v-btn icon="$formatAlignJustify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Mandatory -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Mandatory">
              <div class="text-center">
                <v-btn-toggle v-model="toggle2" color="primary" mandatory>
                  <v-btn icon="$formatAlignLeft" value="left" />
                  <v-btn icon="$formatAlignCenter" value="center" />
                  <v-btn icon="$formatAlignRight" value="right" />
                  <v-btn icon="$formatAlignJustify" value="justify" />
                </v-btn-toggle>
                <div class="font-weight-medium text-medium-emphasis pa-2">
                  {{ toggle2 }}
                </div>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Multiple -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Multiple">
              <div class="text-center">
                <v-btn-toggle v-model="toggle3" color="primary" variant="text" multiple>
                  <v-btn size="small" icon="$formatItalic" value="italic" />
                  <v-btn size="small" icon="$formatBold" value="bold" />
                  <v-btn size="small" icon="$formatUnderline" value="underline" />
                  <v-btn size="small" icon="$formatColorFill" value="color" />
                </v-btn-toggle>
                <div class="font-weight-medium text-medium-emphasis pa-2">
                  {{ toggle3 }}
                </div>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Rounded Sqaure -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Rounded Sqaure">
              <div class="text-center">
                <v-btn-toggle v-model="toggle6" color="primary" variant="outlined" rounded="0">
                  <v-btn icon="$formatAlignLeft" value="left" />
                  <v-btn icon="$formatAlignCenter" value="center" />
                  <v-btn icon="$formatAlignRight" value="right" />
                  <v-btn icon="$formatAlignJustify" value="justify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>
          <!-- Rounded Pill -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Rounded Pill">
              <div class="text-center">
                <v-btn-toggle v-model="toggle7" color="primary" variant="outlined" rounded="xl">
                  <v-btn icon="$formatAlignLeft" value="left" />
                  <v-btn icon="$formatAlignCenter" value="center" />
                  <v-btn icon="$formatAlignRight" value="right" />
                  <v-btn icon="$formatAlignJustify" value="justify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>

          <!-- Density -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Density">
              <div class="text-center">
                <v-btn-toggle v-model="toggle8" class="d-block mb-4" color="primary" variant="outlined" density="compact">
                  <v-btn size="small" icon="$formatAlignLeft" value="left" />
                  <v-btn size="small" icon="$formatAlignCenter" value="center" />
                  <v-btn size="small" icon="$formatAlignRight" value="right" />
                  <v-btn size="small" icon="$formatAlignJustify" value="justify" />
                </v-btn-toggle>

                <v-btn-toggle v-model="toggle9" class="d-block mb-4" color="primary" variant="outlined" density="comfortable">
                  <v-btn size="small" icon="$formatAlignLeft" value="left" />
                  <v-btn size="small" icon="$formatAlignCenter" value="center" />
                  <v-btn size="small" icon="$formatAlignRight" value="right" />
                  <v-btn size="small" icon="$formatAlignJustify" value="justify" />
                </v-btn-toggle>

                <v-btn-toggle v-model="toggle10" class="d-block mb-4" color="primary" variant="outlined">
                  <v-btn icon="$formatAlignLeft" value="left" />
                  <v-btn icon="$formatAlignCenter" value="center" />
                  <v-btn icon="$formatAlignRight" value="right" />
                  <v-btn icon="$formatAlignJustify" value="justify" />
                </v-btn-toggle>
              </div>
            </UiChildCard>
          </v-col>

          <!-- Customized -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Customized">
              <div class="d-sm-flex justify-space-between pa-4 pb-0">
                <v-btn-toggle v-model="formatting" multiple variant="outlined" class="mb-4 mb-sm-0 overflow-auto" color="primary" divided>
                  <v-btn size="small">
                    <v-icon icon="$formatItalic" />
                  </v-btn>

                  <v-btn size="small">
                    <v-icon icon="$formatBold" />
                  </v-btn>

                  <v-btn size="small">
                    <v-icon icon="$formatUnderline" />
                  </v-btn>

                  <v-btn size="small">
                    <div class="d-flex align-center flex-column justify-center">
                      <v-icon icon="$formatColorText" />

                      <v-sheet tile height="4" width="26" color="primary" />
                    </div>
                  </v-btn>
                </v-btn-toggle>

                <v-btn-toggle v-model="alignment" variant="outlined" color="primary" divided>
                  <v-btn size="small">
                    <v-icon icon="$formatAlignCenter" />
                  </v-btn>

                  <v-btn size="small">
                    <v-icon icon="$formatAlignLeft" />
                  </v-btn>

                  <v-btn size="small">
                    <v-icon icon="$formatAlignRight" />
                  </v-btn>
                </v-btn-toggle>
              </div>

              <v-sheet class="pa-4 text-center">
                <v-textarea v-model="value" class="textarea-radius" variant="outlined" auto-grow full-width rows="2" hide-details />
              </v-sheet>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
<style lang="scss">
.textarea-radius {
  &.v-textarea {
    .v-field__field {
      border-radius: 8px;
    }
  }
}
</style>
