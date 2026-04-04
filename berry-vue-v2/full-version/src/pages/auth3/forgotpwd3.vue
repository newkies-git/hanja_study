<script setup lang="ts">
import Logo from '@/layouts/full/logo/LogoMain.vue';
import AuthForgotPwd from '@/components/auth/forms/AuthForgotPwd.vue';
</script>

<template>
  <v-row class="h-screen" gap="0">
    <!---Left Part-->
    <v-col cols="12" class="d-flex align-center bg-lightprimary">
      <v-container>
        <div class="pa-4 pa-sm-12">
          <v-row justify="center">
            <v-col cols="12" lg="10" xl="6" md="7">
              <v-card elevation="0" class="loginBox">
                <v-card variant="outlined">
                  <v-card-text class="pa-9">
                    <!---Left Part Logo -->
                    <v-row>
                      <v-col cols="12" class="text-center">
                        <Logo />
                        <h2 class="text-secondary mt-8">Forgot password?</h2>
                      </v-col>
                    </v-row>
                    <!---Left Part Logo -->

                    <!---Left Part Form-->
                    <h4 class="my-4 mb-8 font-weight-regular text-medium-emphasis text-center">
                      Enter your email address below and we'll send you password reset OTP.
                    </h4>
                    <AuthForgotPwd />
                    <!---Left Part Form-->
                  </v-card-text>
                </v-card>
              </v-card>
            </v-col>
          </v-row>
        </div>
      </v-container>
    </v-col>
    <!---Left Part-->
  </v-row>
</template>
<style lang="scss">
.loginBox {
  max-width: 475px;
  margin: 0 auto;
}

.cardAnimation {
  &:after {
    content: '';
    position: absolute;
    top: 18%;
    left: 18%;
    background-size: 600px;
    width: 500px;
    height: 470px;
    background-image: url('@/assets/images/auth/auth-forgot-pass-multi-card.svg');
    background-repeat: no-repeat;
    background-position: center;
    animation: 15s wings ease-in-out infinite;
  }
}

.bgpattern {
  background: url('@/assets/images/auth/auth-pattern.svg') repeat;
}
</style>
