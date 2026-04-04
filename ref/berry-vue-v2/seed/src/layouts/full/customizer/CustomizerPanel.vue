<script setup lang="ts">
import { computed, ref } from 'vue';
import { useCustomizerStore } from '@/stores/customizer';
import { ThemeMode } from '@/types/themeTypes/ThemeMode';

import { ChecksIcon, ColorSwatchIcon, TextSizeIcon, CpuIcon, MoonIcon, SunIcon } from 'vue-tabler-icons';

const customizer = useCustomizerStore();

// RTL mode state
const rtlmode = ref(true);

// themes color options
const themeColors = ref([
  { name: 'PurpleTheme', bg: 'themeBluePurple' },
  { name: 'GreenTheme', bg: 'themeGreenDark' },
  { name: 'PinkTheme', bg: 'themePink' },
  { name: 'YellowTheme', bg: 'themeYellow' },
  { name: 'SeaGreenTheme', bg: 'themeSeaGreen' },
  { name: 'OliveGreenTheme', bg: 'themeOliveGreen' },
  { name: 'SpeechBlueTheme', bg: 'themeSpeechBlue' }
]);

// Show all colors but use base names
const currentThemeColors = computed(() => {
  return themeColors.value;
});

// Handle theme selection - pass base theme name
function handleThemeSelect(themeName: string) {
  customizer.SET_THEME(themeName);
}

// themes font Family options
const fontFamily = ref(['Roboto', 'Poppins', 'Inter']);
// themes font Family options

const tab = ref(null);

function clearoptions() {
  customizer.SET_THEME('PurpleTheme');
  customizer.SET_THEME_MODE(ThemeMode.Light);
  customizer.setHorizontalLayout = false;
  customizer.inputBg = false;
  customizer.boxed = false;
  customizer.fontTheme = 'Roboto';
  customizer.isRtl = false;
}
</script>

<!------------------------------------->
<!-- Customizer -->
<!------------------------------------->
<template>
  <v-navigation-drawer v-model="customizer.Customizer_drawer" app temporary elevation="10" location="end" width="350">
    <PerfectScrollbar style="height: 100%" :options="{ suppressScrollX: true }">
      <div>
        <v-row class="ma-0 ga-0">
          <v-col cols="12" class="pa-0">
            <div class="pa-5 d-flex justify-space-between align-center">
              <h5>Theme customizer</h5>
              <div>
                <v-btn color="error" variant="outlined" size="small" class="me-2" @click="clearoptions"> Reset </v-btn>
                <v-btn
                  variant="text"
                  icon="$close"
                  color="lightText"
                  density="compact"
                  aria-label="customizer close icon"
                  @click.stop="customizer.SET_CUSTOMIZER_DRAWER(!customizer.Customizer_drawer)"
                />
              </div>
            </div>
            <v-divider />
          </v-col>
          <v-col cols="12" class="pa-0">
            <v-tabs v-model="tab" color="primary" bg-color="lightprimary" grow height="55">
              <v-tab value="one" max-height="55" aria-label="customization tab">
                <ColorSwatchIcon />
              </v-tab>
              <v-tab value="two" max-height="55" aria-label="font family customization tab">
                <TextSizeIcon />
              </v-tab>
            </v-tabs>
            <v-window v-model="tab">
              <v-window-item value="one">
                <v-divider />
                <!------------------------------------->
                <!-- Theme mode -->
                <!------------------------------------->
                <div class="d-flex justify-space-between align-center pa-5">
                  <h5>Theme mode</h5>
                  <div>
                    <v-radio-group v-model="customizer.themeMode" class="custom-radio-icon custom-radio ma-n2" hide-details>
                      <v-radio class="ma-2 text-center" color="primary" label="Light" :value="ThemeMode.Light">
                        <SunIcon class="text-warning" size="20" />
                      </v-radio>
                      <v-radio class="ma-2 text-center" color="primary" label="Dark" :value="ThemeMode.Dark">
                        <MoonIcon class="text-dark" size="20" />
                      </v-radio>
                      <v-radio class="ma-2 text-center" color="primary" label="System" :value="ThemeMode.System">
                        <CpuIcon class="text-dark" size="20" />
                      </v-radio>
                    </v-radio-group>
                  </div>
                </div>
                <v-divider />
                <!------------------------------------->
                <!-- Preset color -->
                <!------------------------------------->
                <v-card-item class="py-5">
                  <v-card-title class="text-body-large mb-2"> {{ customizer.isDarkMode ? 'Dark' : 'Light' }} Preset Colors </v-card-title>
                  <v-card-text class="pa-0">
                    <v-item-group v-model="customizer.actTheme" mandatory>
                      <div class="d-flex flex-wrap">
                        <v-avatar
                          v-for="theme in currentThemeColors"
                          :key="theme.name"
                          :class="[
                            theme.bg,
                            'me-2 cursor-pointer ma-2',
                            {
                              'selected-theme': customizer.baseTheme === theme.name
                            }
                          ]"
                          rounded="circle"
                          size="40"
                          @click="handleThemeSelect(theme.name)"
                        >
                          <ChecksIcon v-if="customizer.baseTheme === theme.name" color="white" />
                        </v-avatar>
                      </div>
                    </v-item-group>
                  </v-card-text>
                </v-card-item>
                <v-divider />
                <!------------------------------------->
                <!-- end Preset color -->
                <!------------------------------------->
                <!------------------------------------->
                <!-- sidebar layout -->
                <!------------------------------------->
                <div class="d-flex justify-space-between align-center pa-5">
                  <h5>Sidebar Layout</h5>
                  <div>
                    <v-radio-group v-model="customizer.setHorizontalLayout" class="custom-radio ma-n2" hide-details>
                      <v-radio :value="false" color="primary" aria-label="vertical layout" class="ma-2">
                        <img src="@/assets/images/customizer/vertical.svg" alt="menu layout" />
                      </v-radio>
                      <v-radio :value="true" color="primary" aria-label="horizontal layout" class="ma-2">
                        <img src="@/assets/images/customizer/horizontal.svg" alt="menu layout" />
                      </v-radio>
                    </v-radio-group>
                  </div>
                </div>
                <v-divider />
                <!------------------------------------->
                <!-- end sidebar layout -->
                <!------------------------------------->
                <!------------------------------------->
                <!-- RTL layout -->
                <!------------------------------------->
                <div class="d-flex justify-space-between align-center pa-5">
                  <h5>RTL</h5>
                  <div>
                    <v-radio-group v-model="customizer.isRtl" class="custom-radio ma-n2" hide-details>
                      <v-radio :value="false" color="primary" aria-label="ltr mode" class="ma-2">
                        <img src="@/assets/images/customizer/vertical.svg" alt="ltr mode" />
                      </v-radio>
                      <v-radio :value="rtlmode" color="primary" aria-label="rtl mode" class="ma-2">
                        <img src="@/assets/images/customizer/rtl.svg" alt="rtl mode" />
                      </v-radio>
                    </v-radio-group>
                  </div>
                </div>
                <v-divider />
                <!------------------------------------->
                <!-- end RTL layout -->
                <!------------------------------------->
                <!------------------------------------->
                <!-- Input Outlined With Filled -->
                <!------------------------------------->
                <div class="d-flex justify-space-between align-center pa-5">
                  <h5>Input Background</h5>
                  <div>
                    <v-radio-group v-model="customizer.inputBg" class="custom-radio input-radio ma-n2" hide-details>
                      <v-radio :value="true" color="primary" aria-label="input background" class="ma-2 input-bg" />
                      <v-radio :value="false" color="primary" aria-label="without background" class="ma-2" />
                    </v-radio-group>
                  </div>
                </div>
                <v-divider />
                <!------------------------------------->
                <!-- End Input Outlined With Filled -->
                <!------------------------------------->
                <!-- Boxed Container -->
                <!------------------------------------->
                <div class="d-flex justify-space-between align-center pa-5">
                  <h5>Theme width</h5>
                  <div>
                    <v-radio-group v-model="customizer.boxed" class="custom-radio ma-n2" hide-details>
                      <v-radio :value="false" color="primary" aria-label="container fluid" class="ma-2">
                        <img src="@/assets/images/customizer/big.svg" height="28" width="28" alt="layout" />
                      </v-radio>
                      <v-radio :value="true" color="primary" aria-label="container width" class="ma-2">
                        <img src="@/assets/images/customizer/small.svg" height="28" width="28" alt="layout" />
                      </v-radio>
                    </v-radio-group>
                  </div>
                </div>
                <v-divider />
                <!------------------------------------->
                <!-- End Box Container -->
                <!------------------------------------->
              </v-window-item>
              <v-window-item value="two">
                <!------------------------------------->
                <!-- Font Family -->
                <!------------------------------------->
                <v-card-item class="py-5">
                  <v-card-title class="text-body-large mb-4"> Font Style </v-card-title>
                  <v-card-text class="pa-0">
                    <v-radio-group v-model="customizer.fontTheme" hide-details class="custom-font">
                      <v-radio v-for="font in fontFamily" :key="font" :label="font" :value="font" color="primary" class="mb-5" />
                    </v-radio-group>
                  </v-card-text>
                </v-card-item>
                <!------------------------------------->
                <!-- end Font Family -->
                <!------------------------------------->
                <!------------------------------------->
              </v-window-item>
            </v-window>
          </v-col>
        </v-row>
      </div>
    </PerfectScrollbar>
  </v-navigation-drawer>
</template>
<style lang="scss">
.custom-radio {
  .v-selection-control-group {
    flex-direction: row;
    .v-selection-control {
      width: 48px;
      height: 48px;
      align-items: center;
      justify-content: center;
      flex: unset;
      border: 2px solid rgba(var(--v-theme-borderLight), 0.36);
      border-radius: 4px;
      &.v-selection-control--dirty {
        border: 2px solid rgba(var(--v-theme-primary), 1);
      }
      .v-selection-control__wrapper {
        .v-selection-control__input {
          opacity: 0;
        }
        img,
        .icon-tabler {
          position: absolute;
        }
      }
      .v-label {
        width: unset;
        height: unset;
        font-size: 0;
      }
    }
  }
}
.input-bg {
  background-color: rgb(var(--v-theme-gray100)) !important;
}
.input-radio {
  .v-selection-control-group {
    .v-selection-control {
      height: 30px;
    }
  }
}
.custom-font {
  .v-selection-control-group {
    .v-selection-control {
      position: relative;
      border: 2px solid rgba(var(--v-theme-borderLight), 0.36);
      outline: 6px solid rgba(var(--v-theme-borderLight), 0.1);
      border-radius: 4px;
      margin: 6px;
      padding: 12px 16px;
      &.v-selection-control--dirty {
        border: 1px solid rgba(var(--v-theme-primary), 1);
        outline: 6px solid rgba(var(--v-theme-primary), 0.1);
      }

      .v-selection-control__wrapper {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;

        .v-selection-control__input {
          position: absolute;
          inset: 0;
          opacity: 0;
          width: 100%;
          height: 100%;
          cursor: pointer;
          margin: 0;
        }
      }
    }
  }
}

.selected-theme {
  border: 3px solid rgba(var(--v-theme-primary), 1) !important;
  box-shadow: 0 0 0 2px rgba(var(--v-theme-primary), 0.2);
}
</style>
