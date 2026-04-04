<script setup lang="ts">
import { ref } from 'vue';
// common components
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import UiParentCard from '@/components/shared/UiParentCard.vue';
import UiChildCard from '@/components/shared/UiChildCard.vue';

// icons
import { UserIcon, UserPlusIcon, UsersIcon, PhotoIcon, StarIcon, FileDescriptionIcon, CreditCardIcon, KeyIcon } from 'vue-tabler-icons';

// theme breadcrumb
const page = ref({ title: 'Tabs' });
const breadcrumbs = ref([
  {
    title: 'Ui elements',
    disabled: false,
    href: '#'
  },
  {
    title: 'Tabs',
    disabled: true,
    href: '#'
  }
]);

// tabs data
const tab = ref(null);
const tab2 = ref(null);
const tab3 = ref(null);
const tab4 = ref(null);
const tab5 = ref(null);
const tab6 = ref(null);
const tab7 = ref(null);
const colortab = ref(null);
const hideSliderTab = ref(null);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />
  <v-row>
    <v-col cols="12">
      <UiParentCard title="Tabs">
        <v-row>
          <!-- Basic -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Basic">
              <v-tabs v-model="tab" color="primary">
                <v-tab value="one"> Profile </v-tab>
                <v-tab value="two"> Followers </v-tab>
                <v-tab value="three"> Friends </v-tab>
                <v-tab value="four"> Gallery </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="tab">
                  <v-tabs-window-item value="one">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="two">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="three">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="four">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>
          <!-- With Icons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="With Icons">
              <v-tabs v-model="tab2" color="primary">
                <v-tab value="11">
                  <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Profile
                </v-tab>
                <v-tab value="22">
                  <UserPlusIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Followers
                </v-tab>
                <v-tab value="33">
                  <UsersIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Friends
                </v-tab>
                <v-tab value="44">
                  <PhotoIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Gallery
                </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="tab2">
                  <v-tabs-window-item value="11">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="22">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="33">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="44">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>
          <!-- Icons -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Icons">
              <v-tabs v-model="tab3" color="primary">
                <v-tab value="111">
                  <UserIcon stroke-width="1.5" width="22" />
                </v-tab>
                <v-tab value="222">
                  <StarIcon stroke-width="1.5" width="22" />
                </v-tab>
                <v-tab value="444">
                  <PhotoIcon stroke-width="1.5" width="22" />
                </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="tab3">
                  <v-tabs-window-item value="111">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="222">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="444">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>

          <!-- Disabled -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Disabled">
              <v-tabs v-model="tab4" color="primary">
                <v-tab value="1111">
                  <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Profile
                </v-tab>
                <v-tab value="2222" disabled>
                  <UserPlusIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Followers
                </v-tab>
                <v-tab value="4444">
                  <PhotoIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Gallery
                </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="tab4">
                  <v-tabs-window-item value="1111">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="2222">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="4444">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>

          <!-- Center -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Center">
              <v-tabs v-model="tab5" align-tabs="center" color="primary">
                <v-tab value="11111">
                  <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Profile
                </v-tab>
                <v-tab value="22222">
                  <UserPlusIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Followers
                </v-tab>
                <v-tab value="44444">
                  <PhotoIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Gallery
                </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="tab5">
                  <v-tabs-window-item value="11111">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="22222">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="44444">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>

          <!-- Colors -->
          <v-col cols="12" lg="6">
            <UiChildCard title="Colors">
              <v-tabs v-model="tab6">
                <v-tab value="111111" color="secondary">
                  <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Profile
                </v-tab>
                <v-tab value="222222" color="warning">
                  <UserPlusIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Followers
                </v-tab>
                <v-tab value="444444" color="primary">
                  <PhotoIcon stroke-width="1.5" width="20" class="v-icon--start" />
                  Gallery
                </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="tab6">
                  <v-tabs-window-item value="111111">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="222222">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="444444">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>

          <v-col cols="12" lg="6">
            <UiChildCard title="Tab color">
              <v-tabs v-model="colortab" color="primary" bg-color="lightprimary">
                <v-tab value="one"> Profile </v-tab>
                <v-tab value="two"> Followers </v-tab>
                <v-tab value="three"> Friends </v-tab>
                <v-tab value="four"> Gallery </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="colortab">
                  <v-tabs-window-item value="one">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="two">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="three">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="four">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>

          <v-col cols="12" lg="6">
            <UiChildCard title="Hide tab slider">
              <v-tabs v-model="hideSliderTab" color="primary" hide-slider bg-color="lightprimary">
                <v-tab value="one"> Profile </v-tab>
                <v-tab value="two"> Followers </v-tab>
                <v-tab value="three"> Friends </v-tab>
                <v-tab value="four"> Gallery </v-tab>
              </v-tabs>
              <v-divider />
              <v-card-text>
                <v-tabs-window v-model="hideSliderTab">
                  <v-tabs-window-item value="one">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="two">
                    Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia
                    aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="three">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident.
                  </v-tabs-window-item>

                  <v-tabs-window-item value="four">
                    Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur
                    butcher vice lomo. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch.
                  </v-tabs-window-item>
                </v-tabs-window>
              </v-card-text>
            </UiChildCard>
          </v-col>

          <!-- Vertical Tabs -->
          <v-col cols="12">
            <UiChildCard title="Vertical Tabs">
              <v-row class="d-flex flex-row">
                <v-col cols="12" md="3" sm="4">
                  <v-tabs v-model="tab7" direction="vertical" color="primary">
                    <v-tab value="option-1" rounded="md" class="mb-3 text-start" height="70">
                      <UserIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>User Profile</div>
                        <h6 class="text-lightText text-medium-emphasis">Profile Settings</h6>
                      </div>
                    </v-tab>
                    <v-tab value="option-2" rounded="md" class="mb-3 text-start" height="70">
                      <FileDescriptionIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>Billing</div>
                        <h6 class="text-lightText text-medium-emphasis">Billing Information</h6>
                      </div>
                    </v-tab>
                    <v-tab value="option-3" rounded="md" class="mb-3 text-start" height="70">
                      <CreditCardIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>Payment</div>
                        <h6 class="text-lightText text-medium-emphasis">Add & Update Card</h6>
                      </div>
                    </v-tab>
                    <v-tab value="option-4" rounded="md" class="mb-3 text-start" height="70">
                      <KeyIcon stroke-width="1.5" width="20" class="v-icon--start" />
                      <div>
                        <div>Change Password</div>
                        <h6 class="text-lightText text-medium-emphasis">Update Profile Security</h6>
                      </div>
                    </v-tab>
                  </v-tabs>
                </v-col>
                <v-col cols="12" md="9" sm="8">
                  <v-tabs-window v-model="tab7">
                    <v-tabs-window-item value="option-1">
                      <v-card variant="outlined">
                        <v-card-text>
                          <p>
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>

                          <p class="mt-4 mb-0">
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>
                        </v-card-text>
                      </v-card>
                    </v-tabs-window-item>
                    <v-tabs-window-item value="option-2">
                      <v-card variant="outlined">
                        <v-card-text>
                          <p>
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>

                          <p class="mt-4 mb-0">
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>
                        </v-card-text>
                      </v-card>
                    </v-tabs-window-item>
                    <v-tabs-window-item value="option-3">
                      <v-card variant="outlined">
                        <v-card-text>
                          <p>
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>

                          <p class="mt-4 mb-0">
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>
                        </v-card-text>
                      </v-card>
                    </v-tabs-window-item>
                    <v-tabs-window-item value="option-4">
                      <v-card variant="outlined">
                        <v-card-text>
                          <p>
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>

                          <p class="mt-4 mb-0">
                            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon
                            officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod.
                          </p>
                        </v-card-text>
                      </v-card>
                    </v-tabs-window-item>
                  </v-tabs-window>
                </v-col>
              </v-row>
            </UiChildCard>
          </v-col>
        </v-row>
      </UiParentCard>
    </v-col>
  </v-row>
</template>
