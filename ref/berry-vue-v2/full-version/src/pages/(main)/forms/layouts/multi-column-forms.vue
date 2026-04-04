<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';

// icons
import { LockIcon, LinkIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Multi Column Forms' });
const breadcrumbs = ref([
  {
    title: 'Layouts',
    disabled: false,
    href: '#'
  },
  {
    title: 'Multi Column Forms',
    disabled: true,
    href: '#'
  }
]);

const checkbox1 = ref(true);
const checkbox2 = ref(false);
const checkbox3 = ref(false);
const checkbox4 = ref(true);
const checkbox5 = ref(false);
const checkbox6 = ref(true);
const checkbox7 = ref(false);
const checkbox8 = ref(true);
const checkbox9 = ref(false);
const checkbox10 = ref(false);
</script>

<template>
  <!-- ----------------------------------------------------- -->
  <!-- Multi Column Forms -->
  <!-- ----------------------------------------------------- -->
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <!-- 2 Columns Form Layout -->
    <v-col cols="12">
      <UiParentCard title="2 Columns Form Layout">
        <v-row>
          <!-- column 1 -->
          <v-col cols="12" lg="6">
            <v-label class="mb-2 font-weight-medium"> Name </v-label>
            <v-text-field
              hint="Please enter your full name"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter full name"
              color="primary"
            />
          </v-col>
          <!-- column 2 -->
          <v-col cols="12" lg="6">
            <v-label class="mb-2 font-weight-medium"> Email </v-label>
            <v-text-field
              hint="Please enter your Email"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter email"
              color="primary"
            />
          </v-col>
          <!-- column 3 -->
          <v-col cols="12" lg="6">
            <v-label class="mb-2 font-weight-medium"> Password </v-label>
            <v-text-field
              hint="Please enter Password"
              persistent-hint
              variant="outlined"
              type="password"
              persistent-placeholder
              placeholder="Enter password"
              color="primary"
            >
              <template #append-inner>
                <LockIcon stroke-width="1.5" size="22" />
              </template>
            </v-text-field>
          </v-col>
          <!-- column 4 -->
          <v-col cols="12" lg="6">
            <v-label class="mb-2 font-weight-medium"> Profile URL </v-label>
            <v-text-field
              hint="Please enter your Profile URL"
              persistent-hint
              variant="outlined"
              type="password"
              persistent-placeholder
              placeholder="Please enter your Profile URL"
              color="primary"
            >
              <template #append-inner>
                <LinkIcon stroke-width="1.5" size="22" />
              </template>
            </v-text-field>
          </v-col>
          <!-- column 5 -->
          <v-col cols="12" lg="6">
            <v-label class="mb-2 font-weight-medium"> Language </v-label>
            <div class="d-flex ga-4">
              <v-checkbox v-model="checkbox1" density="compact" hide-details color="primary" label="English" class="flex-grow-0" />
              <v-checkbox v-model="checkbox2" density="compact" hide-details color="primary" label="French" class="flex-grow-0" />
              <v-checkbox v-model="checkbox3" density="compact" hide-details color="primary" label="Dutch" class="flex-grow-0" />
            </div>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
    <!-- 2 Columns Horizontal Form Layout -->
    <v-col cols="12">
      <UiParentCard title="2 Columns Horizontal Form Layout">
        <v-row>
          <!-- column 1 -->
          <v-col cols="12" lg="6">
            <!-- row 1 -->
            <v-row class="mb-6" density="compact">
              <v-col cols="12" md="4" class="pb-md-3 pb-0">
                <v-label class="font-weight-medium mt-md-4"> Name </v-label>
              </v-col>
              <v-col cols="12" md="8">
                <v-text-field
                  hint="Please enter your full name"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter full name"
                  color="primary"
                />
              </v-col>
            </v-row>
            <!-- row 2 -->
            <v-row class="mt-3 mb-6" density="compact">
              <v-col cols="12" md="4" class="pb-md-3 pb-0">
                <v-label class="font-weight-medium mt-md-4"> Password </v-label>
              </v-col>
              <v-col cols="12" md="8">
                <v-text-field
                  hint="Please enter Password"
                  persistent-hint
                  variant="outlined"
                  type="password"
                  persistent-placeholder
                  placeholder="Enter password"
                  color="primary"
                >
                  <template #append-inner>
                    <LockIcon stroke-width="1.5" size="22" />
                  </template>
                </v-text-field>
              </v-col>
            </v-row>
            <!-- row 3 -->
            <v-row class="mt-3" density="compact">
              <v-col cols="12" md="4" class="pb-md-3 pb-0">
                <v-label class="font-weight-medium mt-3"> Language </v-label>
              </v-col>
              <v-col cols="12" md="8">
                <div class="d-flex ga-4">
                  <v-checkbox v-model="checkbox8" density="compact" hide-details color="primary" label="English" class="flex-grow-0" />
                  <v-checkbox v-model="checkbox9" density="compact" hide-details color="primary" label="French" class="flex-grow-0" />
                  <v-checkbox v-model="checkbox10" density="compact" hide-details color="primary" label="Dutch" class="flex-grow-0" />
                </div>
              </v-col>
            </v-row>
          </v-col>
          <!-- column 2 -->
          <v-col cols="12" lg="6">
            <!-- row 1 -->
            <v-row class="mb-6" density="compact">
              <v-col cols="12" md="4" class="pb-md-3 pb-0">
                <v-label class="font-weight-medium mt-md-4"> Email </v-label>
              </v-col>
              <v-col cols="12" md="8">
                <v-text-field
                  hint="Please enter your Email"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter email"
                  color="primary"
                />
              </v-col>
            </v-row>
            <!-- row 2 -->
            <v-row class="mt-3 mb-6" density="compact">
              <v-col cols="12" md="4" class="pb-md-3 pb-0">
                <v-label class="font-weight-medium mt-md-4"> Profile URL </v-label>
              </v-col>
              <v-col cols="12" md="8">
                <v-text-field
                  hint="Please enter your Profile URL"
                  persistent-hint
                  variant="outlined"
                  type="password"
                  persistent-placeholder
                  placeholder="Please enter your Profile URL"
                  color="primary"
                >
                  <template #append-inner>
                    <LinkIcon stroke-width="1.5" size="22" />
                  </template>
                </v-text-field>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
    <!-- 3 Columns Form Layout -->
    <v-col cols="12">
      <UiParentCard title="3 Columns Form Layout">
        <v-row>
          <!-- column 1 -->
          <v-col cols="12" lg="4">
            <v-label class="font-weight-medium mb-2"> Name </v-label>

            <v-text-field
              hint="Please enter your full name"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter full name"
              color="primary"
            />
            <v-label class="font-weight-medium mb-2 mt-5"> Contact </v-label>

            <v-text-field
              hint="Please enter your contact"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter contact number"
              color="primary"
            />
            <v-label class="font-weight-medium mb-2 mt-5"> Address </v-label>

            <v-text-field
              hint="Please enter your address"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter your address"
              color="primary"
            />
          </v-col>
          <!-- column 2 -->
          <v-col cols="12" lg="4">
            <v-label class="font-weight-medium mb-2"> Email </v-label>

            <v-text-field
              hint="Please enter your Email"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter email"
              color="primary"
            />

            <v-label class="font-weight-medium mb-2 mt-5"> Profile URL </v-label>

            <v-text-field
              hint="Please enter your Profile URL"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter Profile URL"
              color="primary"
            >
              <template #append-inner>
                <LinkIcon stroke-width="1.5" size="22" />
              </template>
            </v-text-field>

            <v-label class="font-weight-medium mb-2 mt-5"> User Type </v-label>
            <div class="d-flex ga-4">
              <v-checkbox v-model="checkbox4" density="compact" hide-details color="primary" label="Administrator" class="flex-grow-0" />
              <v-checkbox v-model="checkbox5" density="compact" hide-details color="primary" label="Author" class="flex-grow-0" />
            </div>
          </v-col>
          <!-- column 3 -->
          <v-col cols="12" lg="4">
            <v-label class="font-weight-medium mb-2"> Password </v-label>

            <v-text-field
              hint="Please enter Password"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter password"
              color="primary"
            >
              <template #prepend-inner>
                <LockIcon stroke-width="1.5" size="22" />
              </template>
            </v-text-field>
            <v-label class="font-weight-medium mb-2 mt-5"> Pincode </v-label>

            <v-text-field
              hint="Please enter your postcode"
              persistent-hint
              variant="outlined"
              persistent-placeholder
              placeholder="Enter your postcode"
              color="primary"
            />
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
    <!-- 3 Columns Form Layout -->
    <v-col cols="12">
      <UiParentCard title="3 Columns Form Layout">
        <!-- Row 1 -->
        <v-row class="pb-6">
          <!-- column 1 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Name </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter your full name"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter full name"
                  color="primary"
                />
              </v-col>
            </v-row>
          </v-col>
          <!-- column 2 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Email </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter your Email"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter email"
                  color="primary"
                />
              </v-col>
            </v-row>
          </v-col>
          <!-- column 3 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Password </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter Password"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter password"
                  color="primary"
                >
                  <template #prepend-inner>
                    <LockIcon stroke-width="1.5" size="22" />
                  </template>
                </v-text-field>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
        <v-divider />
        <!-- row 2 -->
        <v-row class="pt-6">
          <!-- column 1 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center pb-6" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Contact </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter your contact"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter contact number"
                  color="primary"
                />
              </v-col>
            </v-row>
          </v-col>
          <!-- column 2 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center pb-6" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Profile URL </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter your Profile URL"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter Profile URL"
                  color="primary"
                >
                  <template #append-inner>
                    <LinkIcon stroke-width="1.5" size="22" />
                  </template>
                </v-text-field>
              </v-col>
            </v-row>
          </v-col>
          <!-- column 3 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center pb-6" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Pincode </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter your postcode"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter your postcode"
                  color="primary"
                />
              </v-col>
            </v-row>
          </v-col>
        </v-row>
        <v-divider />
        <!-- row 3 -->
        <v-row class="pt-6">
          <!-- column 1 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center pb-6" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> Address </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <v-text-field
                  hint="Please enter your address"
                  persistent-hint
                  variant="outlined"
                  persistent-placeholder
                  placeholder="Enter your address"
                  color="primary"
                />
              </v-col>
            </v-row>
          </v-col>
          <!-- column 2 -->
          <v-col cols="12" lg="4">
            <v-row class="align-center pb-6" density="compact">
              <v-col cols="12" lg="4" class="py-0 py-lg-3">
                <v-label class="font-weight-medium d-flex justify-start justify-lg-end mb-0 mb-lg-5"> User Type </v-label>
              </v-col>
              <v-col cols="12" lg="8">
                <div>
                  <v-checkbox
                    v-model="checkbox6"
                    density="compact"
                    hide-details
                    color="primary"
                    label="Administrator"
                    class="flex-grow-0"
                  />
                  <v-checkbox v-model="checkbox7" density="compact" hide-details color="primary" label="Author" class="flex-grow-0" />
                </div>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
