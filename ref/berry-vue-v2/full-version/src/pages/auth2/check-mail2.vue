<script setup lang="ts">
import Logo from '@/layouts/full/logo/LogoMain.vue';
import AuthCheckMail from '@/components/auth/forms/AuthCheckMail.vue';
import TextSlider from '@/components/auth/TextSlider.vue';
</script>

<template>
  <v-row class="h-screen" gap="0">
    <!---Left Part-->
    <v-col cols="12" lg="7" xl="7" class="d-flex">
      <v-container>
        <Logo />
        <div class="pa-7 pa-sm-12 d-flex align-center">
          <v-row justify="center" align="center" class="heightCalc">
            <v-col cols="12" lg="10" xl="6" md="7">
              <div elevation="0" class="loginBox">
                <!---Left Part Logo -->
                <v-row>
                  <v-col cols="12" class="text-center">
                    <h2 class="text-secondary">Hi, Check Your Mail</h2>
                  </v-col>
                </v-row>
                <!---Left Part Logo -->

                <!---Left Part Form-->
                <AuthCheckMail />
                <!---Left Part Form-->
              </div>
            </v-col>
          </v-row>
        </div>
      </v-container>
    </v-col>
    <!---Left Part-->
    <!---Right Part-->
    <v-col cols="12" lg="5" xl="5" class="d-none d-lg-flex align-end justify-center bg-lightprimary position-relative">
      <div class="bgpattern">
        <v-container>
          <div class="pa-10">
            <v-row justify="center">
              <v-col cols="12" xl="11">
                <div class="mb-8 pb-8">
                  <TextSlider />
                </div>

                <div class="text-center">
                  <img src="@/assets/images/auth/img-a2-login.svg" alt="login2" width="250" />
                </div>
              </v-col>
            </v-row>
          </div>
        </v-container>
      </div>
    </v-col>
    <!---Right Part-->
  </v-row>
</template>
<style lang="scss" scoped>
.loginBox {
  max-width: 475px;
  margin: 0 auto;
}

.heightCalc {
  height: calc(100vh - 150px);
}

.bgpattern {
  background: url('@/assets/images/auth/img-a2-grid.svg') repeat;
  position: absolute;
  background-position: left bottom;
  background-repeat: no-repeat;
  overflow: hidden;
  margin: 0px 0px 0px auto;
  inset: 0px;
}

.DarkPurpleTheme,
.DarkGreenTheme,
.DarkPinkTheme,
.DarkYellowTheme,
.DarkSeaGreenTheme,
.DarkOliveGreenTheme,
.DarkSpeechBlueTheme,
.v-theme--DarkPurpleTheme {
  .bgpattern {
    background-color: rgb(var(--v-theme-lightprimary));
  }
}
</style>
