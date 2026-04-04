<script setup lang="ts">
import { ref, shallowRef } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { MailIcon, LockIcon, EyeIcon } from 'vue-tabler-icons';

// define consts
const page = ref({ title: 'Textfield' });
const caption_email1 = ref('demo@company.com');
const caption_email2 = ref('demo@company.com');
const caption_email3 = ref('demo@company.com');
const validate_email1 = ref('demo.sd');
const validate_email2 = ref('demo.sd');
const multiline2 = ref('Default Value');
const select_sm = ref<string>('Small');
const full_text = ref('Default');
const some_imp1 = ref('Default');
const some_imp2 = ref('Default');
const some_imp3 = ref('Default');

// confirm edit text
const model = shallowRef('Egg plant');

// rules for email textfield
const rules = ref({
  required: (value: string) => !!value || 'Required.',
  counter: (value: string) => value.length <= 20 || 'Max 20 characters',
  email: (value: string) => {
    const pattern =
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return pattern.test(value) || 'Invalid e-mail.';
  }
});

//  data of select
const items = ref(['None', 'demo@company.com', 'Judiya@company.com', 'taju_diya@company.com']);

// password
const passwordrules = {
  required: (value: string) => !!value || 'Required.',
  min: (v: string) => v.length >= 8 || 'Min 8 characters',
  emailMatch: () => "The email and password you entered don't match"
};

const show1 = ref(false);
const show2 = ref(true);
const password = ref('Password');

// theme breadcrumb
const breadcrumbs = ref([
  {
    title: 'Components',
    disabled: false,
    href: '#'
  },
  {
    title: 'Textfield',
    disabled: true,
    href: '#'
  }
]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs"></BaseBreadcrumb>
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Textfield">
        <v-row>
          <v-col cols="12" lg="6">
            <!-- variant -->
            <UiChildCard title="Variant">
              <div>
                <v-text-field label="Outlined"></v-text-field>

                <v-text-field label="Filled" variant="filled" rounded="false"></v-text-field>

                <v-text-field label="Underlined" variant="underlined"></v-text-field>
              </div>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- general -->
            <UiChildCard title="General">
              <div>
                <v-text-field color="primary" persistent-placeholder placeholder="Email Address"></v-text-field>

                <v-text-field persistent-placeholder placeholder="Email Address" value="demo@company.com"></v-text-field>

                <v-text-field persistent-placeholder placeholder="demo@company.com" disabled></v-text-field>
              </div>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- with caption -->
            <UiChildCard title="With Caption">
              <v-text-field v-model="caption_email1" label="Email Address">
                <template v-slot:prepend-inner>
                  <MailIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
              <v-text-field v-model="caption_email2" label="Email Address"></v-text-field>
              <v-text-field v-model="caption_email3" label="Email Address">
                <template v-slot:append-inner>
                  <MailIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- with validation -->
            <UiChildCard title="With Validation">
              <v-text-field
                color="error"
                v-model="validate_email1"
                :rules="[rules.required, rules.email]"
                label="Email Address"
                class="mb-4"
                error
              >
                <template v-slot:prepend-inner>
                  <MailIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
              <v-text-field
                color="error"
                error
                v-model="validate_email2"
                :rules="[rules.required, rules.email]"
                label="Email Address"
                class="mb-4"
              >
              </v-text-field>
              <v-text-field color="error" label="Email Address"> </v-text-field>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- With Icon & Adornments -->
            <UiChildCard title="With Icon & Adornments">
              <v-text-field persistent-placeholder placeholder="Email address">
                <template v-slot:prepend-inner>
                  <MailIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
              <v-text-field persistent-placeholder placeholder="Email address">
                <template v-slot:prepend-inner>
                  <LockIcon stroke-width="1.5" size="22" />
                </template>
                <template v-slot:append-inner>
                  <EyeIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
              <v-text-field persistent-placeholder placeholder="John Deo">
                <template v-slot:prepend-inner>
                  <span class="v-card-subtitle px-0">Mr</span>
                  <v-divider class="ms-3" inset vertical></v-divider>
                </template>
              </v-text-field>
              <v-text-field persistent-placeholder placeholder="Password">
                <template v-slot:append-inner>
                  <v-divider class="me-3" inset vertical></v-divider>
                  <span class="v-card-subtitle px-0">.com</span>
                </template>
              </v-text-field>
              <v-text-field persistent-placeholder placeholder="Email address">
                <template v-slot:prepend>
                  <MailIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
              <v-text-field persistent-placeholder placeholder="Email address">
                <template v-slot:prepend>
                  <LockIcon stroke-width="1.5" size="22" />
                </template>
                <template v-slot:append>
                  <EyeIcon stroke-width="1.5" size="22" />
                </template>
              </v-text-field>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- Multiline -->
            <UiChildCard title="Multiline">
              <v-textarea filled auto-grow label="Multiline Placeholder" rows="1" variant="outlined" row-height="20"></v-textarea>
              <v-textarea filled auto-grow label="Multiline Placeholder" rows="4" variant="outlined" v-model="multiline2"></v-textarea>
              <v-textarea
                clearable
                clear-icon="$closeCircle"
                label="Multiline Clearable"
                rows="1"
                row-height="20"
                hide-details="auto"
                variant="outlined"
                model-value="This is clearable text."
              ></v-textarea>
            </UiChildCard>
          </v-col>
          <v-col cols="12" md="12">
            <UiChildCard title="Prefixes and suffixes">
              <v-row density="compact">
                <v-col cols="12" md="4">
                  <v-list-subheader class="pt-md-4" style="min-height: unset">Prefix for dollar currency</v-list-subheader>
                </v-col>

                <v-col cols="12" md="8">
                  <v-text-field placeholder="Amount" model-value="10.00" prefix="$" persistent-placeholder></v-text-field>
                </v-col>
              </v-row>

              <v-row density="compact">
                <v-col cols="12" md="4">
                  <v-list-subheader class="pt-md-4" style="min-height: unset">Suffix for weight</v-list-subheader>
                </v-col>

                <v-col cols="12" md="8">
                  <v-text-field placeholder="Weight" model-value="28.00" suffix="lbs" persistent-placeholder></v-text-field>
                </v-col>
              </v-row>

              <v-row density="compact">
                <v-col cols="12" md="4">
                  <v-list-subheader class="pt-md-4" style="min-height: unset">Suffix for email domain</v-list-subheader>
                </v-col>

                <v-col cols="12" md="8">
                  <v-text-field placeholder="Email address" model-value="example" suffix="@gmail.com" persistent-placeholder></v-text-field>
                </v-col>
              </v-row>

              <v-row density="compact">
                <v-col cols="12" md="4">
                  <v-list-subheader class="pt-md-4" style="min-height: unset">Suffix for time zone</v-list-subheader>
                </v-col>

                <v-col cols="12" md="8">
                  <v-text-field
                    placeholder="Label Text"
                    model-value="12:30:00"
                    suffix="PST"
                    type="time"
                    persistent-placeholder
                  ></v-text-field>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- Select -->
            <UiChildCard title="Select">
              <v-select :items="items" color="primary" label="Email Address" variant="outlined" density="comfortable"></v-select>
              <v-select :items="items" color="primary" label="Email Address" variant="outlined" v-model="select_sm"></v-select>
            </UiChildCard>
          </v-col>
          <v-col cols="12" lg="6">
            <!-- size -->
            <UiChildCard title="Size">
              <v-text-field label="Default"> </v-text-field>
              <v-text-field label="compact" density="compact"> </v-text-field>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <!-- Layout -->
            <UiChildCard title="Layout">
              <v-text-field label="Label" hint="Full Width!" v-model="full_text" persistent-hint></v-text-field>
              <v-row class="mt-5">
                <v-col cols="12" lg="4">
                  <v-text-field label="None" hint="Some important text" v-model="some_imp1" persistent-hint></v-text-field>
                </v-col>

                <v-col cols="12" lg="4">
                  <v-text-field
                    label="Dense"
                    hint="Some important text"
                    v-model="some_imp2"
                    persistent-hint
                    density="compact"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" lg="4">
                  <v-text-field label="Normal" hint="Some important text" v-model="some_imp3" persistent-hint></v-text-field>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Confirm Edit">
              <v-confirm-edit v-model="model">
                <template v-slot:default="{ model: proxyModel, actions }">
                  <v-card class="mx-auto pa-0" variant="text">
                    <v-label class="mb-2 mt-1" for="update-value">Update field</v-label>
                    <v-text-field v-model="proxyModel.value" id="update-value" single-line messages="Modify my value"></v-text-field>
                    <template v-slot:actions>
                      <v-spacer />

                      <component :is="actions"></component>
                    </template>
                  </v-card>
                </template>
              </v-confirm-edit>
            </UiChildCard>
          </v-col>
          <v-col cols="12">
            <UiChildCard title="Password input">
              <v-row>
                <v-col cols="12" sm="6">
                  <v-text-field
                    v-model="password"
                    :append-inner-icon="show1 ? '$eye' : '$eyeOff'"
                    :rules="[passwordrules.required, passwordrules.min]"
                    :type="show1 ? 'text' : 'password'"
                    hint="At least 8 characters"
                    label="Normal with hint text"
                    name="input-10-1"
                    counter
                    @click:append-inner="show1 = !show1"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" sm="6">
                  <v-text-field
                    :append-icon="show2 ? '$eye' : '$eyeOff'"
                    :rules="[passwordrules.required, passwordrules.min]"
                    :type="show2 ? 'text' : 'password'"
                    class="input-group--focused"
                    hint="At least 8 characters"
                    label="Visible"
                    name="input-10-2"
                    @click:append="show2 = !show2"
                  ></v-text-field>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
