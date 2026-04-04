<script setup lang="ts"></script>

<template>
  <v-row gap="0" class="h-screen">
    <v-col class="d-flex align-center justify-center">
      <div class="text-center">
        <div class="CardMediaWrapper">
          <img src="@/assets/images/maintenance/img-bg-grid.svg" alt="grid" class="w-100 grid-bg" />
          <img src="@/assets/images/maintenance/img-bg-parts.svg" alt="grid" class="CardMediaParts" />
          <img src="@/assets/images/maintenance/img-build.svg" alt="build" class="CardMediaBuild" />
        </div>
        <h2 class="text-display-large">Under Construction</h2>
        <p>
          <small>This site is on under construction!! Please check <br />after some time </small>
        </p>
        <v-btn variant="flat" color="primary" class="mt-4" to="/" prepend-icon="$home"> Home </v-btn>
      </div>
    </v-col>
  </v-row>
</template>
<style lang="scss">
.CardMediaWrapper {
  max-width: 720px;
  margin: 0 auto;
  position: relative;
}
.CardMediaBuild {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  animation: 5s bounce ease-in-out infinite;
}
.CardMediaParts {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  animation: 10s blink ease-in-out infinite;
}
.DarkPurpleTheme,
.DarkGreenTheme,
.DarkPinkTheme,
.DarkYellowTheme,
.DarkSeaGreenTheme,
.DarkOliveGreenTheme,
.DarkSpeechBlueTheme,
.v-theme--DarkPurpleTheme {
  .CardMediaWrapper {
    .grid-bg {
      filter: brightness(0.5) invert(1);
    }
  }
}
</style>
